extends Node3D

enum RoundState {
	COUNTDOWN,
	PLAYING,
	FUGITIVE_WIN,
	POLICE_WIN,
}

@export var round_duration: float = 60.0
@export var pre_round_countdown: float = 3.0
@export var capture_distance: float = 1.75
@export var danger_distance: float = 6.0
@export var low_time_threshold: float = 12.0
@export var fugitive_speed: float = 11.0
@export var fugitive_acceleration: float = 13.5
@export var police_speed: float = 11.6
@export var police_acceleration: float = 9.2
@export var fugitive_spawn: Vector3 = Vector3(0.0, 2.0, 0.0)
@export var police_spawn: Vector3 = Vector3(7.0, 2.0, 0.0)

@onready var fugitive: FugitivePlayer = $PERSONAGEM
@onready var police: PolicePlayer = $POLICIAL
@onready var hud: RoundHud = $HUD
@onready var fugitive_spawn_marker: Node3D = get_node_or_null("FUGITIVE_SPAWN")
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

	var distance_between_players: float = _get_players_distance()

	if distance_between_players <= capture_distance:
		fugitive.capture()
		_finish_round(RoundState.POLICE_WIN)

func _unhandled_input(_event: InputEvent) -> void:
	if current_state == RoundState.PLAYING or current_state == RoundState.COUNTDOWN:
		return

	if Input.is_action_just_pressed("restart_round"):
		get_tree().reload_current_scene()

func start_round() -> void:
	current_state = RoundState.COUNTDOWN
	remaining_time = round_duration
	countdown_remaining = pre_round_countdown
	fugitive.reset_state(_get_fugitive_spawn_position())
	police.reset_state(_get_police_spawn_position())
	fugitive.configure_movement(fugitive_speed, fugitive_acceleration)
	police.configure_movement(police_speed, police_acceleration)
	fugitive.set_input_enabled(false)
	police.set_input_enabled(false)
	_update_hud(_get_countdown_message())

func _finish_round(result: int) -> void:
	if current_state != RoundState.PLAYING:
		return

	current_state = result
	fugitive.set_input_enabled(false)
	police.set_input_enabled(false)

	if result == RoundState.POLICE_WIN:
		_update_hud("Policia venceu! Aperte R para reiniciar")
		return

	remaining_time = 0.0
	_update_hud("Fugitivo venceu! Aperte R para reiniciar")

func _update_hud(status_message: String) -> void:
	if not hud:
		return

	var active_fugitives: int = 0 if fugitive.is_captured else 1
	var timer_warning: bool = current_state == RoundState.PLAYING and remaining_time <= low_time_threshold
	hud.update_timer(remaining_time, timer_warning)
	hud.update_active_fugitives(active_fugitives, 1)
	hud.set_status(status_message, _get_status_color())
	hud.set_controls_hint(_get_controls_hint())

func _process_countdown(delta: float) -> void:
	countdown_remaining = max(countdown_remaining - delta, 0.0)
	_update_hud(_get_countdown_message())

	if countdown_remaining > 0.0:
		return

	current_state = RoundState.PLAYING
	fugitive.set_input_enabled(true)
	police.set_input_enabled(true)
	_update_hud("Valendo! Fuja ate o tempo acabar")

func _get_countdown_message() -> String:
	if countdown_remaining > 0.0:
		return "A rodada comeca em %d" % int(ceil(countdown_remaining))
	return "Valendo!"

func _get_players_distance() -> float:
	return Vector2(
		fugitive.global_position.x - police.global_position.x,
		fugitive.global_position.z - police.global_position.z
	).length()

func _get_playing_status_message() -> String:
	var distance_between_players: float = _get_players_distance()

	if distance_between_players <= danger_distance:
		return "Perigo! A policia esta perto"

	if remaining_time <= low_time_threshold:
		return "Ultimos segundos! Continue fugindo"

	return "Fuja ate o tempo acabar"

func _get_status_color() -> Color:
	if current_state == RoundState.COUNTDOWN:
		return RoundHud.COLOR_INFO

	if current_state == RoundState.POLICE_WIN:
		return RoundHud.COLOR_DANGER

	if current_state == RoundState.FUGITIVE_WIN:
		return RoundHud.COLOR_SUCCESS

	if _get_players_distance() <= danger_distance:
		return RoundHud.COLOR_DANGER

	if remaining_time <= low_time_threshold:
		return RoundHud.COLOR_WARNING

	return RoundHud.COLOR_DEFAULT

func _get_controls_hint() -> String:
	if police.is_controller_connected():
		return "WASD: Fugitivo | DualSense: Policia | R: Reiniciar"

	return "WASD: Fugitivo | Setas: Policia | R: Reiniciar"

func _get_fugitive_spawn_position() -> Vector3:
	if fugitive_spawn_marker:
		return fugitive_spawn_marker.global_position
	return fugitive_spawn

func _get_police_spawn_position() -> Vector3:
	if police_spawn_marker:
		return police_spawn_marker.global_position
	return police_spawn
