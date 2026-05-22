extends SkillBase

const BANANA_TRAP_SCENE: PackedScene = preload("res://scenes/skills/banana_trap.tscn")
const THROW_DISTANCE: float = 5.0
const TRAP_DURATION: float = 8.0
const TRAP_RADIUS: float = 1.6
const STUN_SECONDS: float = 0.8
const SLOW_MULTIPLIER: float = 0.55
const SLOW_SECONDS: float = 2.5

func _init() -> void:
	display_name = "Trap"
	cooldown_duration = 45.0

func try_activate() -> void:
	if not can_activate():
		return

	var trap: Node3D = BANANA_TRAP_SCENE.instantiate() as Node3D
	if trap == null:
		return

	var spawn_position: Vector3 = owner_player.global_position + owner_player.get_forward_direction() * THROW_DISTANCE
	spawn_position.y = owner_player.global_position.y + 0.08
	owner_player.get_parent().add_child(trap)
	trap.global_position = spawn_position
	if trap.has_method("setup"):
		trap.call("setup", _get_hunters(), TRAP_DURATION, TRAP_RADIUS, STUN_SECONDS, SLOW_MULTIPLIER, SLOW_SECONDS)

	_start_cooldown()
	_show_message("Banana holografica armada")
