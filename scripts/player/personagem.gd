extends CharacterBody3D

const SPEED = 10
const DEFAULT_STUN := 2.0

@onready var animator: AnimationPlayer = $"boneco/AnimationPlayer"
@onready var view: Node3D = $"../CAMERA"

var movement_velocity := Vector3.ZERO
var gravity := 0.0
var rotation_direction := 0.0

var is_stunned := false
var stun_timer := 0.0

func _physics_process(delta):
	if is_stunned:
		stun_timer -= delta
		if stun_timer <= 0.0:
			is_stunned = false
		return  # ignora input e movimento enquanto preso

	handle_input(delta)
	apply_gravity(delta)
	handle_animation()

	var applied_velocity := velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	velocity = applied_velocity

	move_and_slide()

	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)

# chamado pela armadilha (Area3D) ao colidir com o player
func apply_trap_stun(duration := DEFAULT_STUN) -> void:
	is_stunned = true
	stun_timer = duration
	velocity = Vector3.ZERO
	movement_velocity = Vector3.ZERO

func handle_input(_delta):
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_foward", "move_backwards")
	input = input.rotated(Vector3.UP, view.rotation.y).normalized()
	movement_velocity = input * SPEED

func apply_gravity(delta):
	if not is_on_floor():
		gravity += 25.0 * delta
	else:
		gravity = 0.0

func handle_animation():
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			animator.play("animaçoesfim/FastRun", 0.3)
		else:
			animator.play("animaçoesfim/Idle", 0.3)
