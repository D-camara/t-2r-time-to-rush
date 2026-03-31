extends CharacterBody3D

@export var device_id: int = 0

var speed := 5.0

func _physics_process(delta):
	var direction = InputManager.get_movement(device_id)

	print(direction) # teste

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()
