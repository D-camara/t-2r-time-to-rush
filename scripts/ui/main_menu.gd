extends Control

const GAME_SCENE_PATH: String = "res://scenes/player/move.tscn"
const MAX_PLAYERS: int = 4
const MIN_PLAYERS_TO_START: int = 2

@onready var play_button: Button = $Root/Columns/MenuPanel/MenuColumn/PlayButton
@onready var settings_button: Button = $Root/Columns/MenuPanel/MenuColumn/SettingsButton
@onready var quit_button: Button = $Root/Columns/MenuPanel/MenuColumn/QuitButton
@onready var status_label: Label = $Root/Columns/MenuPanel/MenuColumn/StatusLabel
@onready var connected_label: Label = $Root/Columns/LobbyPanel/LobbyColumn/ConnectedLabel
@onready var slot_labels: Array[Label] = [
	$Root/Columns/LobbyPanel/LobbyColumn/Slot1,
	$Root/Columns/LobbyPanel/LobbyColumn/Slot2,
	$Root/Columns/LobbyPanel/LobbyColumn/Slot3,
	$Root/Columns/LobbyPanel/LobbyColumn/Slot4,
]
@onready var settings_panel: PanelContainer = $SettingsOverlay
@onready var volume_slider: HSlider = $SettingsOverlay/SettingsColumn/VolumeSlider

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)

	if InputManager.has_method("clear_joined_devices"):
		InputManager.clear_joined_devices()

	settings_panel.visible = false
	_sync_volume_slider()
	_update_lobby_ui()

func _process(_delta: float) -> void:
	_update_lobby_ui()

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		var joypad_event: InputEventJoypadButton = event
		if joypad_event.pressed and _is_join_button(joypad_event.button_index):
			if InputManager.try_join_device(joypad_event.device):
				_update_lobby_ui()

func _on_play_pressed() -> void:
	var joined_players: Array[int] = InputManager.get_joined_devices()
	if joined_players.size() < MIN_PLAYERS_TO_START:
		status_label.text = "Entre com pelo menos 2 controles para iniciar"
		return

	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_settings_pressed() -> void:
	settings_panel.visible = not settings_panel.visible

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_volume_changed(value: float) -> void:
	var volume_db: float = linear_to_db(max(value, 0.001))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)

func _update_lobby_ui() -> void:
	var connected_devices: PackedInt32Array = InputManager.get_connected_devices()
	var joined_players: Array[int] = InputManager.get_joined_devices()
	var ready_players: int = joined_players.size()

	connected_label.text = "Controles conectados: %d | Prontos: %d/%d" % [connected_devices.size(), ready_players, MAX_PLAYERS]
	play_button.disabled = ready_players < MIN_PLAYERS_TO_START
	play_button.text = "Jogar" if ready_players >= MIN_PLAYERS_TO_START else "Jogar (min. 2)"

	for slot_index: int in range(slot_labels.size()):
		if slot_index < ready_players:
			var role_name: String = "Pegador inicial" if slot_index == 0 else "Fugitivo %d" % slot_index
			slot_labels[slot_index].text = "Jogador %d: Controle %d entrou (%s)" % [slot_index + 1, joined_players[slot_index], role_name]
			continue

		slot_labels[slot_index].text = "Jogador %d: Aperte X para entrar" % [slot_index + 1]

	if connected_devices.is_empty():
		status_label.text = "Conecte os controles para montar a partida"
	elif ready_players < MIN_PLAYERS_TO_START:
		status_label.text = "O primeiro controle vira Policia. Os proximos entram como Fugitivos."
	else:
		status_label.text = "Tudo pronto. Aperte Jogar para ir para a arena."

func _sync_volume_slider() -> void:
	var master_bus_index: int = AudioServer.get_bus_index("Master")
	var current_db: float = AudioServer.get_bus_volume_db(master_bus_index)
	volume_slider.value = db_to_linear(current_db)

func _is_join_button(button_index: int) -> bool:
	return button_index == JOY_BUTTON_A or button_index == JOY_BUTTON_X
