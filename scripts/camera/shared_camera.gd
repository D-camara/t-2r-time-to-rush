extends Camera3D

@export var base_height: float = 112.0
@export var base_distance: float = 10.0
@export var position_smoothing: float = 6.8
@export var focus_smoothing: float = 7.5
@export var distance_influence: float = 0.22
@export var max_bonus_height: float = 18.0
@export var focus_height: float = 1.2
@export var movement_look_ahead: float = 0.18
@export var max_look_ahead_distance: float = 2.5
@export var orthographic_base_size: float = 78.0
@export var orthographic_distance_influence: float = 0.14
@export var orthographic_max_size: float = 128.0
@export var orthographic_smoothing: float = 5.5
@export var snap_distance: float = 80.0

@onready var fugitive: FugitivePlayer = get_parent().get_node_or_null("PERSONAGEM")
@onready var second_fugitive: FugitivePlayer = get_parent().get_node_or_null("FUGITIVO_2")
@onready var third_fugitive: FugitivePlayer = get_parent().get_node_or_null("FUGITIVO_3")
@onready var police: PolicePlayer = get_parent().get_node_or_null("POLICIAL")

var smoothed_focus_point: Vector3 = Vector3.ZERO
var is_initialized: bool = false

func _ready() -> void:
	projection = Camera3D.PROJECTION_ORTHOGONAL
	size = orthographic_base_size
	if not fugitive:
		return

	smoothed_focus_point = _get_target_focus_point()
	global_position = _get_desired_position(smoothed_focus_point, _get_player_separation())
	look_at(smoothed_focus_point + Vector3.UP * focus_height, Vector3.UP)
	is_initialized = true

func _process(delta: float) -> void:
	if not fugitive:
		return

	if not is_initialized:
		smoothed_focus_point = _get_target_focus_point()
		is_initialized = true

	var target_focus_point: Vector3 = _get_target_focus_point()
	var separation: float = _get_player_separation()
	if smoothed_focus_point.distance_to(target_focus_point) > snap_distance:
		smoothed_focus_point = target_focus_point
		global_position = _get_desired_position(smoothed_focus_point, separation)
		size = _get_desired_orthographic_size(separation)
		look_at(smoothed_focus_point + Vector3.UP * focus_height, Vector3.UP)
		return

	smoothed_focus_point = smoothed_focus_point.lerp(target_focus_point, delta * focus_smoothing)
	var desired_position: Vector3 = _get_desired_position(smoothed_focus_point, separation)
	global_position = global_position.lerp(desired_position, delta * position_smoothing)
	size = lerp(size, _get_desired_orthographic_size(separation), delta * orthographic_smoothing)
	look_at(smoothed_focus_point + Vector3.UP * focus_height, Vector3.UP)

func _get_desired_position(focus_point: Vector3, separation: float) -> Vector3:
	var bonus_height: float = min(separation * distance_influence, max_bonus_height)
	return focus_point + Vector3(
		0.0,
		base_height + bonus_height,
		base_distance + bonus_height * 0.5
	)

func _get_desired_orthographic_size(separation: float) -> float:
	return min(orthographic_base_size + separation * orthographic_distance_influence, orthographic_max_size)

func _get_target_focus_point() -> Vector3:
	var tracked_players: Array[CharacterBody3D] = _get_tracked_players()
	if tracked_players.is_empty():
		return global_position

	var midpoint: Vector3 = Vector3.ZERO
	var average_velocity: Vector3 = Vector3.ZERO

	for tracked_player: CharacterBody3D in tracked_players:
		midpoint += tracked_player.global_position
		average_velocity += Vector3(tracked_player.velocity.x, 0.0, tracked_player.velocity.z)

	midpoint /= float(tracked_players.size())
	average_velocity /= float(tracked_players.size())

	var look_ahead_offset: Vector3 = average_velocity * movement_look_ahead
	if look_ahead_offset.length() > max_look_ahead_distance:
		look_ahead_offset = look_ahead_offset.normalized() * max_look_ahead_distance

	return midpoint + look_ahead_offset

func _get_player_separation() -> float:
	var tracked_players: Array[CharacterBody3D] = _get_tracked_players()
	var largest_distance: float = 0.0

	for first_index: int in range(tracked_players.size()):
		for second_index: int in range(first_index + 1, tracked_players.size()):
			var distance_between_players: float = Vector2(
				tracked_players[first_index].global_position.x - tracked_players[second_index].global_position.x,
				tracked_players[first_index].global_position.z - tracked_players[second_index].global_position.z
			).length()
			largest_distance = max(largest_distance, distance_between_players)

	return largest_distance

func _get_tracked_players() -> Array[CharacterBody3D]:
	var tracked_players: Array[CharacterBody3D] = []
	if fugitive and fugitive.is_participating:
		tracked_players.append(fugitive)
	if second_fugitive and second_fugitive.is_participating:
		tracked_players.append(second_fugitive)
	if third_fugitive and third_fugitive.is_participating:
		tracked_players.append(third_fugitive)
	if police:
		tracked_players.append(police)
	return tracked_players
