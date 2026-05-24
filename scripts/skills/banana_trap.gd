extends Node3D

var hunters: Array[CharacterBody3D] = []
var duration_remaining: float = 0.0
var trigger_radius: float = 1.6
var stun_seconds: float = 0.8
var slow_multiplier: float = 0.55
var slow_seconds: float = 2.5
var triggered: bool = false
var pulse_time: float = 0.0
var trigger_radius_squared: float = 2.56

@onready var visual: MeshInstance3D = $Visual

func setup(new_hunters: Array[CharacterBody3D], duration: float, radius: float, stun: float, slow: float, slow_duration: float) -> void:
	hunters = new_hunters
	duration_remaining = duration
	trigger_radius = radius
	trigger_radius_squared = trigger_radius * trigger_radius
	stun_seconds = stun
	slow_multiplier = slow
	slow_seconds = slow_duration

func _process(delta: float) -> void:
	pulse_time += delta
	duration_remaining = maxf(duration_remaining - delta, 0.0)
	if visual:
		var pulse: float = (sin(pulse_time * 8.0) + 1.0) * 0.5
		visual.scale = Vector3.ONE * (0.92 + pulse * 0.12)

	if duration_remaining <= 0.0:
		queue_free()
		return

	if triggered:
		return

	for hunter: CharacterBody3D in hunters:
		if hunter == null or not is_instance_valid(hunter):
			continue
		if _planar_distance_squared(global_position, hunter.global_position) <= trigger_radius_squared:
			if hunter.has_method("apply_hunter_disruption"):
				hunter.call("apply_hunter_disruption", stun_seconds, slow_multiplier, slow_seconds)
			triggered = true
			queue_free()
			return

func _planar_distance_squared(point_a: Vector3, point_b: Vector3) -> float:
	var offset_x: float = point_a.x - point_b.x
	var offset_z: float = point_a.z - point_b.z
	return offset_x * offset_x + offset_z * offset_z
