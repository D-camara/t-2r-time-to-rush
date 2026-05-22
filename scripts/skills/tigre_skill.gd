extends SkillBase

const HIT_RANGE: float = 4.5
const STUN_SECONDS: float = 1.0
const SLOW_MULTIPLIER: float = 0.55
const SLOW_SECONDS: float = 3.0

func _init() -> void:
	display_name = "Golpe de sorte"
	cooldown_duration = 45.0

func try_activate() -> void:
	if not can_activate():
		return

	var target: CharacterBody3D = _get_nearest_hunter()
	if target == null:
		_show_message("Nenhum pegador no alcance")
		return

	if target.has_method("apply_hunter_disruption"):
		target.call("apply_hunter_disruption", STUN_SECONDS, SLOW_MULTIPLIER, SLOW_SECONDS)
		_start_cooldown()
		_show_message("Golpe de sorte acertou")

func _get_nearest_hunter() -> CharacterBody3D:
	var nearest_hunter: CharacterBody3D = null
	var nearest_distance: float = HIT_RANGE
	for hunter: CharacterBody3D in _get_hunters():
		var distance_to_hunter: float = _planar_distance(owner_player.global_position, hunter.global_position)
		if distance_to_hunter <= nearest_distance:
			nearest_distance = distance_to_hunter
			nearest_hunter = hunter
	return nearest_hunter
