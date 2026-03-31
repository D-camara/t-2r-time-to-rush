class_name FugitivePlayer
extends CharacterBody3D

const DEFAULT_STUN: float = 2.0

@export var move_speed: float = 10.0
@export var camera_path: NodePath = ^"../CAMERA"

@onready var animator: AnimationPlayer = get_node_or_null("boneco/AnimationPlayer")
@onready var view: Node3D = get_node_or_null(camera_path)

var movement_velocity: Vector3 = Vector3.ZERO
var gravity: float = 0.0
var rotation_direction: float = 0.0
var is_stunned: bool = false
var stun_timer: float = 0.0
var input_enabled: bool = true
var is_captured: bool = false

func _physics_process(delta: float) -> void:
	if is_captured:
		velocity = Vector3.ZERO
		handle_animation()
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

	var applied_velocity: Vector3 = velocity.lerp(movement_velocity, delta * 10.0)
	applied_velocity.y = -gravity
	velocity = applied_velocity

	move_and_slide()

	if Vector2(velocity.z, velocity.x).length() > 0.0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10.0)
	handle_animation()

func apply_trap_stun(duration: float = DEFAULT_STUN) -> void:
	if is_captured:
		return

	is_stunned = true
	stun_timer = duration
	velocity = Vector3.ZERO
	movement_velocity = Vector3.ZERO

func handle_input() -> void:
	if not input_enabled:
		movement_velocity = Vector3.ZERO
		return

	var input: Vector3 = Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_foward", "move_backwards")

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

	if is_captured or is_stunned or (abs(velocity.x) <= 1.0 and abs(velocity.z) <= 1.0):
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

func capture() -> void:
	is_captured = true
	input_enabled = false
	is_stunned = false
	stun_timer = 0.0
	velocity = Vector3.ZERO
	movement_velocity = Vector3.ZERO

func reset_state(spawn_position: Vector3) -> void:
	global_position = spawn_position
	velocity = Vector3.ZERO
	movement_velocity = Vector3.ZERO
	gravity = 0.0
	is_stunned = false
	stun_timer = 0.0
	input_enabled = true
	is_captured = false
