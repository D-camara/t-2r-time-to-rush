class_name PolicePlayer
extends CharacterBody3D

@export var device_id: int = 0
@export var move_speed: float = 11.0
@export var acceleration: float = 9.5
@export var rotation_lerp_speed: float = 9.0

var gravity: float = 0.0
var input_enabled: bool = true
var rotation_direction: float = 0.0

func _physics_process(delta: float) -> void:
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
	global_position = spawn_position
	velocity = Vector3.ZERO
	gravity = 0.0
	input_enabled = true

func configure_movement(speed: float, new_acceleration: float) -> void:
	move_speed = speed
	acceleration = new_acceleration

func is_controller_connected() -> bool:
	return InputManager.has_device(device_id)

func _get_move_direction() -> Vector3:
	var controller_direction: Vector3 = InputManager.get_movement(device_id)
	if controller_direction.length() > 0.0:
		return controller_direction

	var keyboard_direction: Vector3 = Vector3.ZERO
	keyboard_direction.x = Input.get_axis("police_left", "police_right")
	keyboard_direction.z = Input.get_axis("police_foward", "police_backwards")
	return keyboard_direction.normalized() if keyboard_direction.length() > 0.0 else Vector3.ZERO
