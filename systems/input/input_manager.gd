extends Node

const DEADZONE: float = 0.2
const MAX_JOINED_PLAYERS: int = 4
const CHARACTER_IDS: Array[String] = ["sagui", "coelha", "tigre", "raposa"]

var joined_devices: Array[int] = []
var selected_characters: Dictionary = {}
var police_device: int = -1
var ability_pressed_devices: Array[int] = []
var confirm_pressed_devices: Array[int] = []
var cancel_pressed_devices: Array[int] = []
var start_pressed_devices: Array[int] = []
var connected_devices_cache: PackedInt32Array = PackedInt32Array()

func _ready() -> void:
	_refresh_connected_devices()
	if not Input.joy_connection_changed.is_connected(_on_joy_connection_changed):
		Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		var joypad_event: InputEventJoypadButton = event
		if not joypad_event.pressed:
			return

		var resolved_device: int = _resolve_device(joypad_event.device)
		if resolved_device == -1:
			return

		if _is_ability_button(joypad_event.button_index):
			_add_pressed_device(ability_pressed_devices, resolved_device)
		elif _is_confirm_button(joypad_event.button_index):
			_add_pressed_device(confirm_pressed_devices, resolved_device)
		elif _is_cancel_button(joypad_event.button_index):
			_add_pressed_device(cancel_pressed_devices, resolved_device)
		elif _is_start_button(joypad_event.button_index):
			_add_pressed_device(start_pressed_devices, resolved_device)

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
	if dir.length_squared() < DEADZONE * DEADZONE:
		return Vector3.ZERO

	return dir.normalized()

func get_connected_devices() -> PackedInt32Array:
	return connected_devices_cache

func clear_joined_devices() -> void:
	joined_devices.clear()
	clear_pressed_buttons()
	reset_match_setup()

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

func reset_match_setup() -> void:
	selected_characters.clear()
	police_device = -1

func set_character_for_device(device_id: int, character_id: String) -> bool:
	var resolved_device: int = _resolve_device(device_id)
	if resolved_device == -1 or resolved_device not in joined_devices:
		return false
	if character_id not in CHARACTER_IDS:
		return false

	for assigned_device: Variant in selected_characters.keys():
		if int(assigned_device) != resolved_device and str(selected_characters[assigned_device]) == character_id:
			return false

	selected_characters[resolved_device] = character_id
	return true

func get_character_for_device(device_id: int) -> String:
	var resolved_device: int = _resolve_device(device_id)
	if resolved_device == -1:
		return ""
	return str(selected_characters.get(resolved_device, ""))

func get_character_name_for_device(device_id: int) -> String:
	return get_character_display_name(get_character_for_device(device_id))

func get_character_display_name(character_id: String) -> String:
	match character_id:
		"sagui":
			return "Sagui"
		"coelha":
			return "Coelha"
		"tigre":
			return "Tigre"
		"raposa":
			return "Raposa"
		_:
			return ""

func get_selected_character_ids() -> Array[String]:
	var selected_ids: Array[String] = []
	for assigned_device: Variant in selected_characters.keys():
		selected_ids.append(str(selected_characters[assigned_device]))
	return selected_ids

func all_joined_devices_have_characters() -> bool:
	if joined_devices.is_empty():
		return false

	for joined_device: int in joined_devices:
		if get_character_for_device(joined_device).is_empty():
			return false

	return true

func pick_random_police() -> int:
	if joined_devices.is_empty():
		police_device = -1
		return police_device

	var random_generator: RandomNumberGenerator = RandomNumberGenerator.new()
	random_generator.randomize()
	var police_index: int = random_generator.randi_range(0, joined_devices.size() - 1)
	police_device = joined_devices[police_index]
	return police_device

func get_police_device() -> int:
	return police_device

func set_police_device(device_id: int) -> bool:
	var resolved_device: int = _resolve_device(device_id)
	if resolved_device == -1 or resolved_device not in joined_devices:
		return false

	police_device = resolved_device
	return true

func get_police_character_id() -> String:
	if police_device == -1:
		return ""
	return get_character_for_device(police_device)

func get_police_character_name() -> String:
	return get_character_display_name(get_police_character_id())

func get_fugitive_devices() -> Array[int]:
	var fugitive_devices: Array[int] = []
	for joined_device: int in joined_devices:
		if joined_device != police_device:
			fugitive_devices.append(joined_device)
	return fugitive_devices

func consume_ability_pressed(device_id: int) -> bool:
	return _consume_pressed_device(ability_pressed_devices, device_id)

func consume_confirm_pressed(device_id: int) -> bool:
	return _consume_pressed_device(confirm_pressed_devices, device_id)

func consume_cancel_pressed(device_id: int) -> bool:
	return _consume_pressed_device(cancel_pressed_devices, device_id)

func consume_start_pressed(device_id: int) -> bool:
	return _consume_pressed_device(start_pressed_devices, device_id)

func consume_match_advance_pressed() -> bool:
	return _consume_pressed_from_joined(start_pressed_devices) or _consume_pressed_from_joined(confirm_pressed_devices)

func clear_pressed_buttons() -> void:
	ability_pressed_devices.clear()
	confirm_pressed_devices.clear()
	cancel_pressed_devices.clear()
	start_pressed_devices.clear()

func _consume_pressed_device(pressed_devices: Array[int], device_id: int) -> bool:
	var resolved_device: int = _resolve_device(device_id)
	if resolved_device == -1:
		return false
	if resolved_device not in pressed_devices:
		return false

	pressed_devices.erase(resolved_device)
	return true

func _consume_pressed_from_joined(pressed_devices: Array[int]) -> bool:
	for joined_device: int in joined_devices:
		if joined_device in pressed_devices:
			pressed_devices.erase(joined_device)
			return true
	return false

func _add_pressed_device(pressed_devices: Array[int], device_id: int) -> void:
	if device_id not in pressed_devices:
		pressed_devices.append(device_id)

func _is_ability_button(button_index: int) -> bool:
	return button_index == JOY_BUTTON_RIGHT_SHOULDER

func _is_confirm_button(button_index: int) -> bool:
	return button_index == JOY_BUTTON_A or button_index == JOY_BUTTON_X

func _is_cancel_button(button_index: int) -> bool:
	return button_index == JOY_BUTTON_B

func _is_start_button(button_index: int) -> bool:
	return button_index == JOY_BUTTON_START

func _resolve_device(device_id: int) -> int:
	if device_id in connected_devices_cache:
		return device_id

	if device_id >= 0 and device_id < connected_devices_cache.size():
		return connected_devices_cache[device_id]

	return -1

func _refresh_connected_devices() -> void:
	connected_devices_cache = Input.get_connected_joypads()

func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	_refresh_connected_devices()
