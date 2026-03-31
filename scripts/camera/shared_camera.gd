extends Camera3D

@export var base_height: float = 18.0
@export var base_distance: float = 10.0
@export var smoothing: float = 6.0
@export var distance_influence: float = 0.45
@export var max_bonus_height: float = 8.0

@onready var fugitive: Node3D = get_parent().get_node_or_null("PERSONAGEM")
@onready var police: Node3D = get_parent().get_node_or_null("POLICIAL")

func _process(delta: float) -> void:
	if not fugitive:
		return

	var midpoint: Vector3 = fugitive.global_position
	var separation: float = 0.0

	if police:
		midpoint = (fugitive.global_position + police.global_position) * 0.5
		separation = Vector2(
			fugitive.global_position.x - police.global_position.x,
			fugitive.global_position.z - police.global_position.z
		).length()

	var bonus_height: float = min(separation * distance_influence, max_bonus_height)
	var desired_position: Vector3 = midpoint + Vector3(0.0, base_height + bonus_height, base_distance + bonus_height * 0.5)
	global_position = global_position.lerp(desired_position, delta * smoothing)
	look_at(midpoint + Vector3.UP * 1.5, Vector3.UP)
