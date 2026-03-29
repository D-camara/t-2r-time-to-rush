extends Node



const DEADZONE := 0.2

func get_movement(device_id: int) -> Vector3:
	var x = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X)
	var y = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)

	var dir = Vector3(x, 0, y)

	if dir.length() < DEADZONE:
		return Vector3.ZERO

	return dir.normalized()
