class_name FugitivePlayer
extends CharacterBody3D

const DEFAULT_STUN: float = 2.0

@export var use_keyboard_input: bool = true
@export var device_id: int = -1
@export var move_speed: float = 10.0
@export var acceleration: float = 14.0
@export var rotation_lerp_speed: float = 12.0
@export var camera_path: NodePath = ^"../CAMERA"
@export var fugitive_body_color: Color = Color(0.92, 0.18, 0.15, 1.0)
@export var fugitive_emission_color: Color = Color(0.42, 0.06, 0.05, 1.0)
@export var fugitive_emission_energy: float = 0.65
@export var hunter_body_color: Color = Color(0.15, 0.78, 0.32, 1.0)
@export var hunter_emission_color: Color = Color(0.04, 0.32, 0.09, 1.0)
@export var hunter_emission_energy: float = 1.1
@export var fall_limit_y: float = -5.0

@onready var animator: AnimationPlayer = find_child("AnimationPlayer", true, false) as AnimationPlayer
@onready var view: Node3D = get_node_or_null(camera_path)

var movement_velocity: Vector3 = Vector3.ZERO
var gravity: float = 0.0
var rotation_direction: float = 0.0
var is_stunned: bool = false
var stun_timer: float = 0.0
var input_enabled: bool = true
var is_captured: bool = false
var is_infected: bool = false
var respawn_position: Vector3 = Vector3.ZERO
var is_participating: bool = true

func _ready() -> void:
	_apply_current_palette()

func _physics_process(delta: float) -> void:
	if not is_participating:
		return

	if global_position.y < fall_limit_y:
		_restore_to_spawn()
		return

	if is_stunned:
		stun_timer -= delta
		if stun_timer <= 0.0:
			is_stunned = false
		velocity = Vector3.ZERO
		handle_animation()
		return

	handle_input()
	apply_gravity(delta)

	var applied_velocity: Vector3 = velocity.lerp(movement_velocity, delta * acceleration)
	applied_velocity.y = -gravity
	velocity = applied_velocity

	move_and_slide()

	if Vector2(velocity.z, velocity.x).length() > 0.0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * rotation_lerp_speed)
	handle_animation()

func apply_trap_stun(duration: float = DEFAULT_STUN) -> void:
	is_stunned = true
	stun_timer = duration
	velocity = Vector3.ZERO
	movement_velocity = Vector3.ZERO

func handle_input() -> void:
	if not input_enabled:
		movement_velocity = Vector3.ZERO
		return

	var input: Vector3 = _get_input_direction()
	if view:
		input = input.rotated(Vector3.UP, view.rotation.y)

	movement_velocity = input.normalized() * move_speed if input.length() > 0.0 else Vector3.ZERO

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		gravity += 25.0 * delta
	else:
		gravity = 0.0

func handle_animation() -> void:
	if not animator or not is_on_floor():
		return

	if is_stunned or (abs(velocity.x) <= 1.0 and abs(velocity.z) <= 1.0):
		_play_animation_by_suffix("Idle")
	else:
		_play_animation_by_suffix("FastRun")

func _play_animation_by_suffix(suffix: String) -> void:
	for animation_name: String in animator.get_animation_list():
		if animation_name.ends_with("/" + suffix) or animation_name == suffix:
			animator.play(animation_name, 0.3)
			return

func set_input_enabled(enabled: bool) -> void:
	input_enabled = enabled
	if not enabled:
		velocity = Vector3.ZERO
		movement_velocity = Vector3.ZERO

func configure_movement(speed: float, new_acceleration: float) -> void:
	move_speed = speed
	acceleration = new_acceleration

func capture() -> void:
	infect()

func infect() -> void:
	is_captured = true
	is_infected = true
	is_stunned = false
	stun_timer = 0.0
	input_enabled = true
	_apply_current_palette()

func reset_state(spawn_position: Vector3) -> void:
	is_participating = true
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	respawn_position = spawn_position
	global_position = spawn_position
	velocity = Vector3.ZERO
	movement_velocity = Vector3.ZERO
	gravity = 0.0
	is_stunned = false
	stun_timer = 0.0
	input_enabled = true
	is_captured = false
	is_infected = false
	_apply_current_palette()

func deactivate_slot() -> void:
	is_participating = false
	visible = false
	input_enabled = false
	is_captured = true
	is_infected = false
	is_stunned = false
	stun_timer = 0.0
	velocity = Vector3.ZERO
	movement_velocity = Vector3.ZERO

func is_controller_connected() -> bool:
	if device_id < 0:
		return false

	var input_manager: Node = _get_input_manager()
	if input_manager == null or not input_manager.has_method("has_device"):
		return false
	return bool(input_manager.call("has_device", device_id))

func _get_input_direction() -> Vector3:
	if use_keyboard_input:
		return _get_keyboard_direction()

	if device_id < 0:
		return Vector3.ZERO

	var input_manager: Node = _get_input_manager()
	if input_manager != null and input_manager.has_method("get_movement"):
		var movement_result: Variant = input_manager.call("get_movement", device_id)
		if movement_result is Vector3:
			return movement_result

	return Vector3.ZERO

func _get_keyboard_direction() -> Vector3:
	var input: Vector3 = Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_foward", "move_backwards")
	return input

func _get_input_manager() -> Node:
	return get_node_or_null("/root/InputManager")

func _apply_current_palette() -> void:
	var palette_material: StandardMaterial3D = StandardMaterial3D.new()
	if is_infected:
		palette_material.albedo_color = hunter_body_color
		palette_material.emission = hunter_emission_color
		palette_material.emission_energy_multiplier = hunter_emission_energy
	else:
		palette_material.albedo_color = fugitive_body_color
		palette_material.emission = fugitive_emission_color
		palette_material.emission_energy_multiplier = fugitive_emission_energy

	palette_material.roughness = 0.28
	palette_material.metallic = 0.05
	palette_material.emission_enabled = palette_material.emission_energy_multiplier > 0.0
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
	movement_velocity = Vector3.ZERO
	gravity = 0.0
