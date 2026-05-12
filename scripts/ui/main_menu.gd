extends Control

const GAME_SCENE_PATH: String = "res://scenes/player/move.tscn"
const MAX_PLAYERS: int = 4
const MIN_PLAYERS_TO_START: int = 1
const COLOR_SURFACE: Color = Color(0.094, 0.133, 0.208, 0.94)
const COLOR_SURFACE_HOVER: Color = Color(0.118, 0.169, 0.267, 1.0)
const COLOR_BORDER: Color = Color(0.165, 0.224, 0.325, 1.0)
const COLOR_BG: Color = Color(0.02, 0.031, 0.086, 1.0)
const COLOR_GREEN: Color = Color(0.133, 0.773, 0.369, 1.0)
const COLOR_GREEN_HIGHLIGHT: Color = Color(0.29, 0.871, 0.502, 1.0)
const COLOR_GOLD: Color = Color(0.918, 0.702, 0.031, 1.0)
const COLOR_AMBER: Color = Color(0.961, 0.62, 0.043, 1.0)
const COLOR_RED: Color = Color(0.937, 0.267, 0.267, 1.0)
const COLOR_ORANGE: Color = Color(0.976, 0.451, 0.086, 1.0)
const COLOR_CYAN: Color = Color(0.22, 0.741, 0.973, 1.0)
const COLOR_TEXT: Color = Color(0.898, 0.933, 0.973, 1.0)
const COLOR_MUTED: Color = Color(0.58, 0.639, 0.722, 1.0)

@onready var play_button: Button = $Root/Columns/MenuPanel/MenuColumn/PlayButton
@onready var settings_button: Button = $Root/Columns/MenuPanel/MenuColumn/SettingsButton
@onready var quit_button: Button = $Root/Columns/MenuPanel/MenuColumn/QuitButton
@onready var status_label: Label = $Root/Columns/MenuPanel/MenuColumn/StatusLabel
@onready var title_label: Label = $Root/Columns/MenuPanel/MenuColumn/Title
@onready var subtitle_label: Label = $Root/Columns/MenuPanel/MenuColumn/Subtitle
@onready var connected_label: Label = $Root/Columns/LobbyPanel/LobbyColumn/ConnectedLabel
@onready var join_hint_label: Label = $Root/Columns/LobbyPanel/LobbyColumn/JoinHint
@onready var slot_labels: Array[Label] = [
	$Root/Columns/LobbyPanel/LobbyColumn/Slot1,
	$Root/Columns/LobbyPanel/LobbyColumn/Slot2,
	$Root/Columns/LobbyPanel/LobbyColumn/Slot3,
	$Root/Columns/LobbyPanel/LobbyColumn/Slot4,
]
@onready var menu_panel: PanelContainer = $Root/Columns/MenuPanel
@onready var lobby_panel: PanelContainer = $Root/Columns/LobbyPanel
@onready var settings_panel: PanelContainer = $SettingsOverlay
@onready var volume_slider: HSlider = $SettingsOverlay/SettingsColumn/VolumeSlider
@onready var lobby_title_label: Label = $Root/Columns/LobbyPanel/LobbyColumn/LobbyTitle

var menu_time: float = 0.0
var button_targets: Array[Button] = []
var panel_targets: Array[Control] = []

func _ready() -> void:
	_apply_visual_style()
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)

	if InputManager.has_method("clear_joined_devices"):
		InputManager.clear_joined_devices()

	settings_panel.visible = false
	_sync_volume_slider()
	_update_lobby_ui()

func _process(delta: float) -> void:
	menu_time += delta
	_update_lobby_ui()
	_update_menu_motion(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		var joypad_event: InputEventJoypadButton = event
		if joypad_event.pressed and _is_join_button(joypad_event.button_index):
			if InputManager.try_join_device(joypad_event.device):
				_update_lobby_ui()

func _on_play_pressed() -> void:
	var joined_players: Array[int] = InputManager.get_joined_devices()
	if joined_players.size() < MIN_PLAYERS_TO_START:
		status_label.text = "Entre com pelo menos 1 controle para iniciar"
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
	play_button.text = "Jogar" if ready_players >= MIN_PLAYERS_TO_START else "Jogar (min. 1)"

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

func _apply_visual_style() -> void:
	_add_background()
	button_targets = [play_button, settings_button, quit_button]
	panel_targets = [menu_panel, lobby_panel, settings_panel]
	_style_panel(menu_panel, COLOR_GREEN)
	_style_panel(lobby_panel, COLOR_CYAN)
	_style_panel(settings_panel, COLOR_GOLD)
	_style_button(play_button, COLOR_GREEN, COLOR_GREEN_HIGHLIGHT, true)
	_style_button(settings_button, COLOR_GOLD, Color(1.0, 0.82, 0.2, 1.0), false)
	_style_button(quit_button, COLOR_RED, COLOR_ORANGE, false)
	_style_slider(volume_slider)
	_connect_button_feedback()

	title_label.text = "TIME TO RUSH"
	title_label.add_theme_color_override("font_color", COLOR_TEXT)
	title_label.add_theme_color_override("font_shadow_color", Color(COLOR_GREEN.r, COLOR_GREEN.g, COLOR_GREEN.b, 0.75))
	title_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.88))
	title_label.add_theme_constant_override("outline_size", 8)
	title_label.add_theme_constant_override("shadow_offset_x", 0)
	title_label.add_theme_constant_override("shadow_offset_y", 7)
	title_label.add_theme_font_size_override("font_size", 62)
	subtitle_label.text = "VAULT RUN // HEIST MODE"
	subtitle_label.add_theme_color_override("font_color", COLOR_GOLD)
	subtitle_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.72))
	subtitle_label.add_theme_constant_override("outline_size", 4)
	status_label.add_theme_color_override("font_color", COLOR_MUTED)
	status_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.62))
	status_label.add_theme_constant_override("outline_size", 3)
	connected_label.add_theme_color_override("font_color", COLOR_GREEN_HIGHLIGHT)
	join_hint_label.add_theme_color_override("font_color", COLOR_GOLD)
	lobby_title_label.text = "TACTICAL LOBBY"
	lobby_title_label.add_theme_color_override("font_color", COLOR_CYAN)
	lobby_title_label.add_theme_color_override("font_shadow_color", Color(COLOR_CYAN.r, COLOR_CYAN.g, COLOR_CYAN.b, 0.5))
	lobby_title_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.78))
	lobby_title_label.add_theme_constant_override("outline_size", 5)
	lobby_title_label.add_theme_font_size_override("font_size", 34)

	for label: Label in slot_labels:
		label.add_theme_color_override("font_color", COLOR_TEXT)
		label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.7))
		label.add_theme_constant_override("outline_size", 3)
		label.add_theme_font_size_override("font_size", 20)

	_style_settings_labels()
	call_deferred("_prime_menu_layout")

func _add_background() -> void:
	var existing_background: Node = get_node_or_null("HeistBackground")
	if existing_background:
		return

	var background: HeistBackground = HeistBackground.new()
	background.name = "HeistBackground"
	add_child(background)
	move_child(background, 0)

func _style_panel(panel: PanelContainer, accent: Color) -> void:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color(COLOR_SURFACE.r, COLOR_SURFACE.g, COLOR_SURFACE.b, 0.9)
	style_box.border_color = Color(accent.r, accent.g, accent.b, 0.85)
	style_box.set_border_width_all(4)
	style_box.corner_radius_top_left = 18
	style_box.corner_radius_top_right = 18
	style_box.corner_radius_bottom_right = 18
	style_box.corner_radius_bottom_left = 18
	style_box.shadow_color = Color(0.0, 0.0, 0.0, 0.68)
	style_box.shadow_size = 24
	style_box.content_margin_left = 34
	style_box.content_margin_right = 34
	style_box.content_margin_top = 30
	style_box.content_margin_bottom = 30
	panel.add_theme_stylebox_override("panel", style_box)

func _style_button(button: Button, accent: Color, hover: Color, is_primary: bool) -> void:
	var text_color: Color = Color(0.018, 0.027, 0.055, 1.0)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 30 if is_primary else 24)
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_hover_color", text_color)
	button.add_theme_color_override("font_focus_color", text_color)
	button.add_theme_color_override("font_pressed_color", text_color)
	button.add_theme_color_override("font_disabled_color", COLOR_MUTED)
	button.add_theme_color_override("font_shadow_color", Color(1.0, 1.0, 1.0, 0.24))
	button.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.18))
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_constant_override("shadow_offset_x", 0)
	button.add_theme_constant_override("shadow_offset_y", 2)
	button.add_theme_stylebox_override("normal", _make_button_style(accent, false, is_primary))
	button.add_theme_stylebox_override("hover", _make_button_style(hover, true, is_primary))
	button.add_theme_stylebox_override("focus", _make_button_style(hover, true, is_primary))
	button.add_theme_stylebox_override("pressed", _make_button_style(accent.darkened(0.2), true, is_primary))
	button.add_theme_stylebox_override("disabled", _make_button_style(COLOR_SURFACE_HOVER, false, is_primary))

func _make_button_style(fill: Color, highlighted: bool, is_primary: bool) -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = fill
	style_box.border_color = Color(1.0, 1.0, 1.0, 0.52 if highlighted else 0.34)
	style_box.set_border_width_all(4 if highlighted else 3)
	style_box.corner_radius_top_left = 16
	style_box.corner_radius_top_right = 16
	style_box.corner_radius_bottom_right = 16
	style_box.corner_radius_bottom_left = 16
	style_box.shadow_color = Color(fill.r, fill.g, fill.b, 0.52 if highlighted else 0.28)
	style_box.shadow_size = 18 if highlighted else 12
	style_box.content_margin_left = 30 if is_primary else 24
	style_box.content_margin_right = 30 if is_primary else 24
	style_box.content_margin_top = 16 if is_primary else 13
	style_box.content_margin_bottom = 16 if is_primary else 13
	return style_box

func _style_slider(slider: HSlider) -> void:
	slider.add_theme_stylebox_override("slider", _make_line_style(COLOR_BORDER, 4))
	slider.add_theme_stylebox_override("grabber_area", _make_line_style(COLOR_GREEN, 4))
	slider.add_theme_stylebox_override("grabber_area_highlight", _make_line_style(COLOR_GREEN_HIGHLIGHT, 5))

func _make_line_style(color: Color, height: int) -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = color
	style_box.corner_radius_top_left = height
	style_box.corner_radius_top_right = height
	style_box.corner_radius_bottom_right = height
	style_box.corner_radius_bottom_left = height
	return style_box

func _connect_button_feedback() -> void:
	for button: Button in button_targets:
		if not button.mouse_entered.is_connected(_on_menu_button_attention.bind(button)):
			button.mouse_entered.connect(_on_menu_button_attention.bind(button))
		if not button.focus_entered.is_connected(_on_menu_button_attention.bind(button)):
			button.focus_entered.connect(_on_menu_button_attention.bind(button))

func _on_menu_button_attention(button: Button) -> void:
	button.pivot_offset = button.size * 0.5
	button.scale = Vector2.ONE * 1.055

func _prime_menu_layout() -> void:
	for panel: Control in panel_targets:
		panel.pivot_offset = panel.size * 0.5
	for button: Button in button_targets:
		button.pivot_offset = button.size * 0.5
	title_label.pivot_offset = title_label.size * 0.5
	lobby_title_label.pivot_offset = lobby_title_label.size * 0.5

func _update_menu_motion(delta: float) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var panel_index: int = 0
	for panel: Control in panel_targets:
		if not panel.visible:
			continue
		panel.pivot_offset = panel.size * 0.5
		var panel_pulse: float = sin(menu_time * 1.6 + float(panel_index) * 0.8) * 0.012
		panel.scale = panel.scale.lerp(Vector2.ONE * (1.0 + panel_pulse), delta * 4.0)
		panel.rotation = lerp(panel.rotation, sin(menu_time * 0.9 + float(panel_index)) * 0.006, delta * 3.0)
		panel_index += 1

	for button: Button in button_targets:
		button.pivot_offset = button.size * 0.5
		var is_hot: bool = button.has_focus() or button.get_global_rect().has_point(mouse_position)
		var target_scale: float = 1.075 if is_hot and not button.disabled else 1.0
		button.scale = button.scale.lerp(Vector2.ONE * target_scale, delta * 10.0)
		button.rotation = lerp(button.rotation, 0.025 if is_hot and not button.disabled else 0.0, delta * 8.0)

	var title_pulse: float = (sin(menu_time * 2.0) + 1.0) * 0.5
	title_label.scale = title_label.scale.lerp(Vector2.ONE * (1.0 + title_pulse * 0.018), delta * 3.0)
	lobby_title_label.scale = lobby_title_label.scale.lerp(Vector2.ONE * (1.0 + title_pulse * 0.01), delta * 3.0)

func _style_settings_labels() -> void:
	for child: Node in settings_panel.get_node("SettingsColumn").get_children():
		if child is Label:
			var label: Label = child
			label.add_theme_color_override("font_color", COLOR_TEXT)
			label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.72))
			label.add_theme_constant_override("outline_size", 3)
