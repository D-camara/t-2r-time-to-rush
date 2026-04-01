extends CharacterBody3D

@export var device_id: int = 0

var speed: float = 5.0

func _physics_process(_delta: float) -> void:
	var direction: Vector3 = Vector3.ZERO
	var input_manager: Node = get_node_or_null("/root/InputManager")
	if input_manager != null and input_manager.has_method("get_movement"):
		var movement_result: Variant = input_manager.call("get_movement", device_id)
		if movement_result is Vector3:
			direction = movement_result

	print(direction) # teste

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()
