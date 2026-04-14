extends Node3D

enum RoundState {
	COUNTDOWN,
	PLAYING,
	FUGITIVE_WIN,
	POLICE_WIN,
}

@export var round_duration: float = 45.0
@export var pre_round_countdown: float = 3.0
@export var capture_distance: float = 1.75
@export var danger_distance: float = 6.0
@export var low_time_threshold: float = 12.0
@export var fugitive_speed: float = 11.0
@export var fugitive_acceleration: float = 13.5
@export var police_speed: float = 11.9
@export var police_acceleration: float = 9.2
@export var infected_hunter_speed: float = 10.4
@export var infected_hunter_acceleration: float = 8.6
@export var fugitive_spawn: Vector3 = Vector3(0.0, 2.0, 0.0)
@export var second_fugitive_spawn: Vector3 = Vector3(-12.0, 2.0, -4.0)
@export var third_fugitive_spawn: Vector3 = Vector3(-2.0, 2.0, -12.0)
@export var police_spawn: Vector3 = Vector3(7.0, 2.0, 0.0)

@onready var fugitive: FugitivePlayer = $PERSONAGEM
@onready var second_fugitive: FugitivePlayer = $FUGITIVO_2
@onready var third_fugitive: FugitivePlayer = $FUGITIVO_3
@onready var police: PolicePlayer = $POLICIAL
@onready var hud: RoundHud = $HUD
@onready var fugitive_spawn_marker: Node3D = get_node_or_null("FUGITIVE_SPAWN")
@onready var second_fugitive_spawn_marker: Node3D = get_node_or_null("FUGITIVE_2_SPAWN")
@onready var third_fugitive_spawn_marker: Node3D = get_node_or_null("FUGITIVE_3_SPAWN")
@onready var police_spawn_marker: Node3D = get_node_or_null("POLICE_SPAWN")

var current_state: int = RoundState.COUNTDOWN
var remaining_time: float = 0.0
var countdown_remaining: float = 0.0

func _ready() -> void:
	start_round()

func _process(delta: float) -> void:
	if current_state == RoundState.COUNTDOWN:
		_process_countdown(delta)
		return

	if current_state != RoundState.PLAYING:
		return

	remaining_time = max(remaining_time - delta, 0.0)
	_update_hud(_get_playing_status_message())

	if remaining_time <= 0.0:
		_finish_round(RoundState.FUGITIVE_WIN)

func _physics_process(_delta: float) -> void:
	if current_state != RoundState.PLAYING:
		return

	for active_fugitive: FugitivePlayer in _get_active_fugitives():
		for hunter: CharacterBody3D in _get_hunters():
			if _get_distance_between(active_fugitive.global_position, hunter.global_position) <= capture_distance:
				_infect_fugitive(active_fugitive)
				return

func _unhandled_input(_event: InputEvent) -> void:
	if current_state == RoundState.PLAYING or current_state == RoundState.COUNTDOWN:
		return

	if Input.is_action_just_pressed("restart_round"):
		get_tree().reload_current_scene()

func start_round() -> void:
	_configure_players_from_lobby()
	current_state = RoundState.COUNTDOWN
	remaining_time = round_duration
	countdown_remaining = pre_round_countdown
	if fugitive.is_participating:
		fugitive.reset_state(_get_fugitive_spawn_position())
	if second_fugitive.is_participating:
		second_fugitive.reset_state(_get_second_fugitive_spawn_position())
	if third_fugitive.is_participating:
		third_fugitive.reset_state(_get_third_fugitive_spawn_position())
	police.reset_state(_get_police_spawn_position())
	if fugitive.is_participating:
		fugitive.configure_movement(fugitive_speed, fugitive_acceleration)
	if second_fugitive.is_participating:
		second_fugitive.configure_movement(fugitive_speed, fugitive_acceleration)
	if third_fugitive.is_participating:
		third_fugitive.configure_movement(fugitive_speed, fugitive_acceleration)
	police.configure_movement(police_speed, police_acceleration)
	if fugitive.is_participating:
		fugitive.set_input_enabled(false)
	if second_fugitive.is_participating:
		second_fugitive.set_input_enabled(false)
	if third_fugitive.is_participating:
		third_fugitive.set_input_enabled(false)
	police.set_input_enabled(false)
	_update_hud(_get_countdown_message())

func _finish_round(result: int) -> void:
	if current_state != RoundState.PLAYING:
		return

	current_state = result
	if fugitive.is_participating:
		fugitive.set_input_enabled(false)
	if second_fugitive.is_participating:
		second_fugitive.set_input_enabled(false)
	if third_fugitive.is_participating:
		third_fugitive.set_input_enabled(false)
	police.set_input_enabled(false)

	if result == RoundState.POLICE_WIN:
		_update_hud("Pegadores venceram! Aperte R para reiniciar")
		return

	remaining_time = 0.0
	_update_hud("Fugitivos venceram! Aperte R para reiniciar")

func _update_hud(status_message: String) -> void:
	if not hud:
		return

	var active_fugitives: int = _get_active_fugitives().size()
	var participating_fugitives: int = _get_participating_fugitive_count()
	var timer_warning: bool = current_state == RoundState.PLAYING and remaining_time <= low_time_threshold
	hud.update_timer(remaining_time, timer_warning)
	hud.update_active_fugitives(active_fugitives, participating_fugitives)
	hud.set_status(status_message, _get_status_color())
	hud.set_controls_hint(_get_controls_hint())

func _process_countdown(delta: float) -> void:
	countdown_remaining = max(countdown_remaining - delta, 0.0)
	_update_hud(_get_countdown_message())

	if countdown_remaining > 0.0:
		return

	current_state = RoundState.PLAYING
	if fugitive.is_participating:
		fugitive.set_input_enabled(true)
	if second_fugitive.is_participating:
		second_fugitive.set_input_enabled(true)
	if third_fugitive.is_participating:
		third_fugitive.set_input_enabled(true)
	police.set_input_enabled(true)
	_update_hud("Valendo! Sobrevivam ate o tempo acabar")

func _get_countdown_message() -> String:
	if countdown_remaining > 0.0:
		return "A rodada comeca em %d" % int(ceil(countdown_remaining))
	return "Valendo!"

func _get_playing_status_message() -> String:
	if _get_active_fugitives().size() == 1:
		return "So restou um fugitivo livre"

	if _is_any_fugitive_in_danger():
		return "Perigo! Os pegadores estao perto"

	if remaining_time <= low_time_threshold:
		return "Ultimos segundos! Continuem fugindo"

	return "Fujam ate o tempo acabar"

func _get_status_color() -> Color:
	if current_state == RoundState.COUNTDOWN:
		return RoundHud.COLOR_INFO

	if current_state == RoundState.POLICE_WIN:
		return RoundHud.COLOR_DANGER

	if current_state == RoundState.FUGITIVE_WIN:
		return RoundHud.COLOR_SUCCESS

	if _is_any_fugitive_in_danger():
		return RoundHud.COLOR_DANGER

	if remaining_time <= low_time_threshold:
		return RoundHud.COLOR_WARNING

	return RoundHud.COLOR_DEFAULT

func _get_controls_hint() -> String:
	return "Controle 1 vira Policia | Capturados viram pegadores | R: Reiniciar"

func _get_fugitive_spawn_position() -> Vector3:
	if fugitive_spawn_marker:
		return fugitive_spawn_marker.global_position
	return fugitive_spawn

func _get_second_fugitive_spawn_position() -> Vector3:
	if second_fugitive_spawn_marker:
		return second_fugitive_spawn_marker.global_position
	return second_fugitive_spawn

func _get_third_fugitive_spawn_position() -> Vector3:
	if third_fugitive_spawn_marker:
		return third_fugitive_spawn_marker.global_position
	return third_fugitive_spawn

func _get_police_spawn_position() -> Vector3:
	if police_spawn_marker:
		return police_spawn_marker.global_position
	return police_spawn

func _get_active_fugitives() -> Array[FugitivePlayer]:
	var active_fugitives: Array[FugitivePlayer] = []
	if fugitive and fugitive.is_participating and not fugitive.is_captured:
		active_fugitives.append(fugitive)
	if second_fugitive and second_fugitive.is_participating and not second_fugitive.is_captured:
		active_fugitives.append(second_fugitive)
	if third_fugitive and third_fugitive.is_participating and not third_fugitive.is_captured:
		active_fugitives.append(third_fugitive)
	return active_fugitives

func _get_participating_fugitive_count() -> int:
	var total: int = 0
	if fugitive and fugitive.is_participating:
		total += 1
	if second_fugitive and second_fugitive.is_participating:
		total += 1
	if third_fugitive and third_fugitive.is_participating:
		total += 1
	return total

func _get_hunters() -> Array[CharacterBody3D]:
	var hunters: Array[CharacterBody3D] = [police]
	if fugitive and fugitive.is_infected:
		hunters.append(fugitive)
	if second_fugitive and second_fugitive.is_infected:
		hunters.append(second_fugitive)
	if third_fugitive and third_fugitive.is_infected:
		hunters.append(third_fugitive)
	return hunters

func _infect_fugitive(target: FugitivePlayer) -> void:
	if target == null or target.is_infected:
		return

	target.infect()
	_apply_infected_hunter_balance()

	if _get_active_fugitives().is_empty():
		_finish_round(RoundState.POLICE_WIN)
		return

	_update_hud("Contagio! Mais um pegador entrou na perseguicao")

func _is_any_fugitive_in_danger() -> bool:
	for active_fugitive: FugitivePlayer in _get_active_fugitives():
		for hunter: CharacterBody3D in _get_hunters():
			if _get_distance_between(active_fugitive.global_position, hunter.global_position) <= danger_distance:
				return true
	return false

func _get_distance_between(point_a: Vector3, point_b: Vector3) -> float:
	return Vector2(point_a.x - point_b.x, point_a.z - point_b.z).length()

func _apply_infected_hunter_balance() -> void:
	police.configure_movement(infected_hunter_speed, infected_hunter_acceleration)

	if fugitive and fugitive.is_infected:
		fugitive.configure_movement(infected_hunter_speed, infected_hunter_acceleration)

	if second_fugitive and second_fugitive.is_infected:
		second_fugitive.configure_movement(infected_hunter_speed, infected_hunter_acceleration)

	if third_fugitive and third_fugitive.is_infected:
		third_fugitive.configure_movement(infected_hunter_speed, infected_hunter_acceleration)

func _configure_players_from_lobby() -> void:
	var input_manager: Node = get_node_or_null("/root/InputManager")
	if input_manager == null or not input_manager.has_method("get_joined_devices"):
		return

	var joined_result: Variant = input_manager.call("get_joined_devices")
	if not (joined_result is Array):
		return

	var joined_devices: Array = joined_result
	if joined_devices.is_empty():
		return

	police.device_id = int(joined_devices[0])

	_assign_fugitive_slot(fugitive, joined_devices, 1)
	_assign_fugitive_slot(second_fugitive, joined_devices, 2)
	_assign_fugitive_slot(third_fugitive, joined_devices, 3)

func _assign_fugitive_slot(player: FugitivePlayer, joined_devices: Array, joined_index: int) -> void:
	player.use_keyboard_input = false
	if joined_devices.size() > joined_index:
		player.device_id = int(joined_devices[joined_index])
		player.is_participating = true
		player.visible = true
		return

	player.deactivate_slot()
