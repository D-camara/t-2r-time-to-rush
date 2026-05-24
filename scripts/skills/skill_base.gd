class_name SkillBase
extends Node

var owner_player: FugitivePlayer = null
var round_manager: Node = null
var display_name: String = ""
var cooldown_duration: float = 0.0
var cooldown_remaining: float = 0.0

func setup(new_owner: FugitivePlayer, new_round_manager: Node) -> void:
	owner_player = new_owner
	round_manager = new_round_manager

func _process(delta: float) -> void:
	if cooldown_remaining > 0.0:
		cooldown_remaining = maxf(cooldown_remaining - delta, 0.0)

func can_activate() -> bool:
	return cooldown_remaining <= 0.0 and owner_player != null and owner_player.is_participating and not owner_player.is_infected

func try_activate() -> void:
	pass

func cancel() -> void:
	cooldown_remaining = 0.0

func get_status_text() -> String:
	if display_name.is_empty():
		return ""
	if cooldown_remaining > 0.0:
		return "%s %ds" % [display_name, int(ceil(cooldown_remaining))]
	return "%s READY" % display_name

func _start_cooldown() -> void:
	cooldown_remaining = cooldown_duration

func _show_message(message: String) -> void:
	if round_manager != null and round_manager.has_method("show_skill_message"):
		round_manager.call("show_skill_message", owner_player, message)

func _get_hunters() -> Array[CharacterBody3D]:
	if round_manager == null or not round_manager.has_method("get_skill_hunters"):
		var empty_hunters: Array[CharacterBody3D] = []
		return empty_hunters

	var hunter_result: Variant = round_manager.call("get_skill_hunters", owner_player)
	if hunter_result is Array:
		var hunters: Array[CharacterBody3D] = []
		for hunter: Variant in hunter_result:
			if hunter is CharacterBody3D:
				hunters.append(hunter)
		return hunters

	var fallback_hunters: Array[CharacterBody3D] = []
	return fallback_hunters

func _planar_distance(point_a: Vector3, point_b: Vector3) -> float:
	return Vector2(point_a.x - point_b.x, point_a.z - point_b.z).length()

func _planar_distance_squared(point_a: Vector3, point_b: Vector3) -> float:
	var offset_x: float = point_a.x - point_b.x
	var offset_z: float = point_a.z - point_b.z
	return offset_x * offset_x + offset_z * offset_z
