extends Node

const DEADZONE: float = 0.2
const MAX_JOINED_PLAYERS: int = 4

var joined_devices: Array[int] = []

func has_device(device_id: int) -> bool:
	return _resolve_device(device_id) != -1

func get_movement(device_id: int) -> Vector3:
	var resolved_device: int = _resolve_device(device_id)
	if resolved_device == -1:
		return Vector3.ZERO

	var x: float = Input.get_joy_axis(resolved_device, JOY_AXIS_LEFT_X)
	var y: float = Input.get_joy_axis(resolved_device, JOY_AXIS_LEFT_Y)

	var dir: Vector3 = Vector3(x, 0, y)

	# deadzone
	if dir.length() < DEADZONE:
		return Vector3.ZERO

	return dir.normalized()

func get_connected_devices() -> PackedInt32Array:
	return Input.get_connected_joypads()

func clear_joined_devices() -> void:
	joined_devices.clear()

func get_joined_devices() -> Array[int]:
	return joined_devices.duplicate()

func is_joined(device_id: int) -> bool:
	var resolved_device: int = _resolve_device(device_id)
	return resolved_device != -1 and resolved_device in joined_devices

func try_join_device(device_id: int) -> bool:
	var resolved_device: int = _resolve_device(device_id)
	if resolved_device == -1:
		return false
	if resolved_device in joined_devices:
		return false
	if joined_devices.size() >= MAX_JOINED_PLAYERS:
		return false

	joined_devices.append(resolved_device)
	return true

func _resolve_device(device_id: int) -> int:
	var connected_devices: PackedInt32Array = Input.get_connected_joypads()
	if device_id in connected_devices:
		return device_id

	if device_id >= 0 and device_id < connected_devices.size():
		return connected_devices[device_id]

	return -1
