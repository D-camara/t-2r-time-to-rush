extends SkillBase

const MARKER_SCENE: PackedScene = preload("res://scenes/skills/rabbit_hole_marker.tscn")
const REACTIVATE_WINDOW: float = 8.0

var marker: Node3D = null
var window_remaining: float = 0.0
var marked_position: Vector3 = Vector3.ZERO

func _init() -> void:
	display_name = "Rabbit Hole"
	cooldown_duration = 60.0

func _process(delta: float) -> void:
	super._process(delta)
	if window_remaining <= 0.0:
		return

	window_remaining = maxf(window_remaining - delta, 0.0)
	if window_remaining <= 0.0:
		_clear_marker()
		_start_cooldown()

func try_activate() -> void:
	if owner_player == null or owner_player.is_infected:
		return

	if window_remaining > 0.0:
		owner_player.global_position = marked_position
		owner_player.velocity = Vector3.ZERO
		owner_player.movement_velocity = Vector3.ZERO
		_clear_marker()
		window_remaining = 0.0
		_start_cooldown()
		_show_message("Rabbit Hole ativado")
		return

	if not can_activate():
		return

	marked_position = owner_player.global_position
	window_remaining = REACTIVATE_WINDOW
	marker = MARKER_SCENE.instantiate() as Node3D
	if marker:
		owner_player.get_parent().add_child(marker)
		marker.global_position = marked_position
	_show_message("Ponto marcado")

func cancel() -> void:
	super.cancel()
	window_remaining = 0.0
	_clear_marker()

func get_status_text() -> String:
	if window_remaining > 0.0:
		return "%s voltar %.1fs" % [display_name, window_remaining]
	return super.get_status_text()

func _clear_marker() -> void:
	if marker:
		marker.queue_free()
		marker = null
