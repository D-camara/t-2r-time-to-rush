extends Node3D

enum RoundState {
	PLAYING,
	FUGITIVE_WIN,
	POLICE_WIN,
}

@export var round_duration: float = 45.0
@export var capture_distance: float = 2.2
@export var fugitive_spawn: Vector3 = Vector3.ZERO
@export var police_spawn: Vector3 = Vector3(7.0, 0.0, 0.0)

@onready var fugitive: FugitivePlayer = $PERSONAGEM
@onready var police: PolicePlayer = $POLICIAL
@onready var hud: RoundHud = $HUD

var current_state: int = RoundState.PLAYING
var remaining_time: float = 0.0

func _ready() -> void:
	start_round()

func _process(delta: float) -> void:
	if current_state != RoundState.PLAYING:
		return

	remaining_time = max(remaining_time - delta, 0.0)
	_update_hud("Fuja ate o tempo acabar")

	if remaining_time <= 0.0:
		_finish_round(RoundState.FUGITIVE_WIN)

func _physics_process(_delta: float) -> void:
	if current_state != RoundState.PLAYING:
		return

	var distance_between_players: float = Vector2(
		fugitive.global_position.x - police.global_position.x,
		fugitive.global_position.z - police.global_position.z
	).length()

	if distance_between_players <= capture_distance:
		fugitive.capture()
		_finish_round(RoundState.POLICE_WIN)

func _unhandled_input(_event: InputEvent) -> void:
	if current_state == RoundState.PLAYING:
		return

	if Input.is_action_just_pressed("restart_round"):
		get_tree().reload_current_scene()

func start_round() -> void:
	current_state = RoundState.PLAYING
	remaining_time = round_duration
	fugitive.reset_state(fugitive_spawn)
	police.reset_state(police_spawn)
	fugitive.set_input_enabled(true)
	police.set_input_enabled(true)
	_update_hud("Fuja ate o tempo acabar")

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
	hud.update_timer(remaining_time)
	hud.update_active_fugitives(active_fugitives, 1)
	hud.set_status(status_message)
