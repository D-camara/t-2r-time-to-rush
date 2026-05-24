class_name FugitivePlayer
extends CharacterBody3D

const DEFAULT_STUN: float = 2.0

@export var use_keyboard_input: bool = true
@export var device_id: int = -1
@export var move_speed: float = 10.0
@export var acceleration: float = 14.0
@export var rotation_lerp_speed: float = 12.0
@export var camera_path: NodePath = ^"../CAMERA"
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

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
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

func reset_state(spawn_position: Vector3) -> void:
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

func _restore_to_spawn() -> void:
	global_position = respawn_position
	velocity = Vector3.ZERO
	movement_velocity = Vector3.ZERO
	gravity = 0.0
