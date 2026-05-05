class_name PolicePlayer
extends CharacterBody3D

@export var device_id: int = 0
@export var move_speed: float = 11.0
@export var acceleration: float = 9.5
@export var rotation_lerp_speed: float = 9.0
@export var body_color: Color = Color(0.937, 0.267, 0.267, 1.0)
@export var emission_color: Color = Color(0.976, 0.451, 0.086, 1.0)
@export var emission_energy: float = 1.25
@export var fall_limit_y: float = -5.0

@onready var animator: AnimationPlayer = find_child("AnimationPlayer", true, false) as AnimationPlayer

var gravity: float = 0.0
var input_enabled: bool = true
var rotation_direction: float = 0.0
var respawn_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	_ensure_player_ring()
	_apply_visual_palette()

func _physics_process(delta: float) -> void:
	if global_position.y < fall_limit_y:
		_restore_to_spawn()
		return

	if input_enabled:
		var direction: Vector3 = _get_move_direction()
		var target_velocity: Vector3 = Vector3(direction.x, 0.0, direction.z) * move_speed
		var applied_velocity: Vector3 = velocity.lerp(target_velocity, delta * acceleration)
		applied_velocity.y = _get_vertical_velocity(delta)
		velocity = applied_velocity
	else:
		velocity = Vector3.ZERO

	move_and_slide()

	if Vector2(velocity.z, velocity.x).length() > 0.1:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * rotation_lerp_speed)
	_handle_animation()

func _get_vertical_velocity(delta: float) -> float:
	if not is_on_floor():
		gravity += 25.0 * delta
	else:
		gravity = 0.0
	return -gravity

func set_input_enabled(enabled: bool) -> void:
	input_enabled = enabled
	if not enabled:
		velocity = Vector3.ZERO

func reset_state(spawn_position: Vector3) -> void:
	respawn_position = spawn_position
	_restore_to_spawn()
	input_enabled = true

func configure_movement(speed: float, new_acceleration: float) -> void:
	move_speed = speed
	acceleration = new_acceleration

func is_controller_connected() -> bool:
	var input_manager: Node = _get_input_manager()
	if input_manager == null or not input_manager.has_method("has_device"):
		return false
	return bool(input_manager.call("has_device", device_id))

func _get_move_direction() -> Vector3:
	var controller_direction: Vector3 = Vector3.ZERO
	var input_manager: Node = _get_input_manager()
	if input_manager != null and input_manager.has_method("get_movement"):
		var movement_result: Variant = input_manager.call("get_movement", device_id)
		if movement_result is Vector3:
			controller_direction = movement_result
	if controller_direction.length() > 0.0:
		return controller_direction

	var keyboard_direction: Vector3 = Vector3.ZERO
	keyboard_direction.x = Input.get_axis("police_left", "police_right")
	keyboard_direction.z = Input.get_axis("police_foward", "police_backwards")
	return keyboard_direction.normalized() if keyboard_direction.length() > 0.0 else Vector3.ZERO

func _get_input_manager() -> Node:
	return get_node_or_null("/root/InputManager")

func _handle_animation() -> void:
	if not animator or not is_on_floor():
		return

	if not input_enabled or (abs(velocity.x) <= 1.0 and abs(velocity.z) <= 1.0):
		_play_animation_by_suffix("Idle")
	else:
		_play_animation_by_suffix("FastRun")

func _play_animation_by_suffix(suffix: String) -> void:
	for animation_name: String in animator.get_animation_list():
		if animation_name.ends_with("/" + suffix) or animation_name == suffix:
			animator.play(animation_name, 0.3)
			return

func _apply_visual_palette() -> void:
	var palette_material: StandardMaterial3D = StandardMaterial3D.new()
	palette_material.albedo_color = body_color
	palette_material.roughness = 0.22
	palette_material.metallic = 0.08
	palette_material.emission_enabled = emission_energy > 0.0
	palette_material.emission = emission_color
	palette_material.emission_energy_multiplier = emission_energy
	_apply_palette_to_meshes(self, palette_material)

func _apply_palette_to_meshes(node: Node, palette_material: Material) -> void:
	for child: Node in node.get_children():
		if child is MeshInstance3D:
			var mesh_instance: MeshInstance3D = child
			mesh_instance.material_override = palette_material
		_apply_palette_to_meshes(child, palette_material)

func _restore_to_spawn() -> void:
	global_position = respawn_position
	velocity = Vector3.ZERO
	gravity = 0.0

func _ensure_player_ring() -> void:
	if get_node_or_null("PlayerReadabilityRing"):
		return

	var ring: MeshInstance3D = MeshInstance3D.new()
	ring.name = "PlayerReadabilityRing"
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = 0.72
	mesh.bottom_radius = 0.72
	mesh.height = 0.045
	mesh.radial_segments = 48
	ring.mesh = mesh
	ring.position = Vector3(0.0, 0.075, 0.0)

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.898, 0.933, 0.973, 0.82)
	material.emission_enabled = true
	material.emission = Color(0.898, 0.933, 0.973, 1.0)
	material.emission_energy_multiplier = 0.5
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = material
	add_child(ring)
