extends SkillBase

const BANANA_TRAP_SCENE: PackedScene = preload("res://scenes/skills/banana_trap.tscn")
const TRAP_RADIUS: float = 1.6
const STUN_SECONDS: float = 0.8
const SLOW_MULTIPLIER: float = 0.55
const SLOW_SECONDS: float = 2.5

var active_trap: Node3D = null

func _init() -> void:
	display_name = "Trap"
	cooldown_duration = 20.0

func try_activate() -> void:
	if not can_activate():
		return

	_clear_active_trap()
	var trap: Node3D = BANANA_TRAP_SCENE.instantiate() as Node3D
	if trap == null:
		return

	var spawn_position: Vector3 = owner_player.global_position
	spawn_position.y = owner_player.global_position.y + 0.08
	owner_player.get_parent().add_child(trap)
	trap.global_position = spawn_position
	active_trap = trap
	active_trap.tree_exited.connect(_on_active_trap_exited.bind(trap))
	if trap.has_method("setup"):
		trap.call("setup", round_manager, TRAP_RADIUS, STUN_SECONDS, SLOW_MULTIPLIER, SLOW_SECONDS)

	_start_cooldown()
	_show_message("Banana holografica armada")

func cancel() -> void:
	super.cancel()
	_clear_active_trap()

func _clear_active_trap() -> void:
	if active_trap != null and is_instance_valid(active_trap):
		active_trap.queue_free()
	active_trap = null

func _on_active_trap_exited(exited_trap: Node3D) -> void:
	if active_trap == exited_trap:
		active_trap = null
