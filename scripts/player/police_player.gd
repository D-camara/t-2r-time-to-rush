extends CharacterBody3D

@export var device_id := 0
@export var move_speed := 11.0

var gravity := 0.0
var input_enabled := true
var rotation_direction := 0.0

func _physics_process(delta: float) -> void:
	if input_enabled:
		var direction := InputManager.get_movement(device_id)
		var target_velocity := Vector3(direction.x, 0.0, direction.z) * move_speed
		var applied_velocity := velocity.lerp(target_velocity, delta * 12.0)
		applied_velocity.y = _get_vertical_velocity(delta)
		velocity = applied_velocity
	else:
		velocity = Vector3.ZERO

	move_and_slide()

	if Vector2(velocity.z, velocity.x).length() > 0.1:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10.0)

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
