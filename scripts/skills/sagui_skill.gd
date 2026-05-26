extends SkillBase

const BANANA_TRAP_SCENE: PackedScene = preload("res://scenes/skills/banana_trap.tscn")
const TRAP_RADIUS: float = 1.6
const STUN_SECONDS: float = 0.8
const SLOW_MULTIPLIER: float = 0.55
const SLOW_SECONDS: float = 2.5

var active_traps: Array[Node3D] = []

func _init() -> void:
	display_name = "Trap"
	cooldown_duration = 20.0

func try_activate() -> void:
	if not can_activate():
		return

	var trap: Node3D = BANANA_TRAP_SCENE.instantiate() as Node3D
	if trap == null:
		return

	var spawn_position: Vector3 = owner_player.global_position
	spawn_position.y = owner_player.global_position.y + 0.08
	owner_player.get_parent().add_child(trap)
	trap.global_position = spawn_position
	active_traps.append(trap)
	trap.tree_exited.connect(_on_active_trap_exited.bind(trap))
	if trap.has_method("setup"):
		trap.call("setup", round_manager, TRAP_RADIUS, STUN_SECONDS, SLOW_MULTIPLIER, SLOW_SECONDS)

	_start_cooldown()
	_show_message("Banana holografica armada")

func cancel() -> void:
	super.cancel()
	_clear_active_traps()

func _clear_active_traps() -> void:
	for trap: Node3D in active_traps:
		if trap != null and is_instance_valid(trap):
			trap.queue_free()
	active_traps.clear()

func _on_active_trap_exited(exited_trap: Node3D) -> void:
	active_traps.erase(exited_trap)
