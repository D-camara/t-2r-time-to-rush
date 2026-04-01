extends Camera3D

@export var base_height: float = 20.0
@export var base_distance: float = 12.0
@export var position_smoothing: float = 7.0
@export var focus_smoothing: float = 8.5
@export var distance_influence: float = 0.5
@export var max_bonus_height: float = 10.0
@export var focus_height: float = 1.5
@export var movement_look_ahead: float = 0.35
@export var max_look_ahead_distance: float = 3.5

@onready var fugitive: FugitivePlayer = get_parent().get_node_or_null("PERSONAGEM")
@onready var police: PolicePlayer = get_parent().get_node_or_null("POLICIAL")

var smoothed_focus_point: Vector3 = Vector3.ZERO
var is_initialized: bool = false

func _ready() -> void:
	if not fugitive:
		return

	smoothed_focus_point = _get_target_focus_point()
	is_initialized = true

func _process(delta: float) -> void:
	if not fugitive:
		return

	if not is_initialized:
		smoothed_focus_point = _get_target_focus_point()
		is_initialized = true

	var target_focus_point: Vector3 = _get_target_focus_point()
	var separation: float = _get_player_separation()
	var bonus_height: float = min(separation * distance_influence, max_bonus_height)

	smoothed_focus_point = smoothed_focus_point.lerp(target_focus_point, delta * focus_smoothing)
	var desired_position: Vector3 = smoothed_focus_point + Vector3(
		0.0,
		base_height + bonus_height,
		base_distance + bonus_height * 0.5
	)
	global_position = global_position.lerp(desired_position, delta * position_smoothing)
	look_at(smoothed_focus_point + Vector3.UP * focus_height, Vector3.UP)

func _get_target_focus_point() -> Vector3:
	var midpoint: Vector3 = fugitive.global_position
	var average_velocity: Vector3 = Vector3(fugitive.velocity.x, 0.0, fugitive.velocity.z)

	if police:
		midpoint = (fugitive.global_position + police.global_position) * 0.5
		average_velocity = Vector3(
			(fugitive.velocity.x + police.velocity.x) * 0.5,
			0.0,
			(fugitive.velocity.z + police.velocity.z) * 0.5
		)

	var look_ahead_offset: Vector3 = average_velocity * movement_look_ahead
	if look_ahead_offset.length() > max_look_ahead_distance:
		look_ahead_offset = look_ahead_offset.normalized() * max_look_ahead_distance

	return midpoint + look_ahead_offset

func _get_player_separation() -> float:
	if not police:
		return 0.0

	return Vector2(
		fugitive.global_position.x - police.global_position.x,
		fugitive.global_position.z - police.global_position.z
	).length()
