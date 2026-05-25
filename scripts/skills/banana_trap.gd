extends Node3D

var round_manager: Node = null
var trigger_radius: float = 1.6
var stun_seconds: float = 0.8
var slow_multiplier: float = 0.55
var slow_seconds: float = 2.5
var triggered: bool = false
var pulse_time: float = 0.0
var trigger_radius_squared: float = 2.56

@onready var visual: MeshInstance3D = $Visual

func setup(new_round_manager: Node, radius: float, stun: float, slow: float, slow_duration: float) -> void:
	round_manager = new_round_manager
	trigger_radius = radius
	trigger_radius_squared = trigger_radius * trigger_radius
	stun_seconds = stun
	slow_multiplier = slow
	slow_seconds = slow_duration

func _process(delta: float) -> void:
	pulse_time += delta
	if visual:
		var pulse: float = (sin(pulse_time * 8.0) + 1.0) * 0.5
		visual.scale = Vector3.ONE * (0.92 + pulse * 0.12)

	if triggered:
		return

	for hunter: CharacterBody3D in _get_current_hunters():
		if hunter == null or not is_instance_valid(hunter):
			continue
		if _planar_distance_squared(global_position, hunter.global_position) <= trigger_radius_squared:
			if hunter.has_method("apply_hunter_disruption"):
				hunter.call("apply_hunter_disruption", stun_seconds, slow_multiplier, slow_seconds)
			triggered = true
			queue_free()
			return

func _get_current_hunters() -> Array[CharacterBody3D]:
	var result: Array[CharacterBody3D] = []
	if round_manager == null or not round_manager.has_method("get_skill_hunters"):
		return result

	var hunter_result: Variant = round_manager.call("get_skill_hunters", null)
	if hunter_result is Array:
		for hunter: Variant in hunter_result:
			if hunter is CharacterBody3D:
				result.append(hunter as CharacterBody3D)
	return result

func _planar_distance_squared(point_a: Vector3, point_b: Vector3) -> float:
	var offset_x: float = point_a.x - point_b.x
	var offset_z: float = point_a.z - point_b.z
	return offset_x * offset_x + offset_z * offset_z
