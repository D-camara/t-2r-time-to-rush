extends Node

const DEADZONE: float = 0.2

func has_device(device_id: int) -> bool:
	return device_id in Input.get_connected_joypads()

func get_movement(device_id: int) -> Vector3:
	var x = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X)
	var y = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)

	var dir: Vector3 = Vector3(x, 0, y)
	
	if not has_device(device_id):
		return Vector3.ZERO

	# deadzone
	if dir.length() < DEADZONE:
		return Vector3.ZERO

	return dir.normalized()
