extends Control

const FONT_ARCADE: FontFile = preload("res://assets/ui/fonts/PressStart2P-Regular.ttf")
const FONT_UI: FontFile = preload("res://assets/ui/fonts/KenneyFuture.ttf")
const ICON_PLAY: Texture2D = preload("res://assets/ui/kenney/icon_play.png")
const ICON_REPEAT: Texture2D = preload("res://assets/ui/kenney/icon_repeat.png")
const CARD_DIVIDER: Texture2D = preload("res://assets/ui/kenney/divider.png")
const GAME_SCENE_PATH: String = "res://scenes/player/move.tscn"
const MAX_PLAYERS: int = 4
const MIN_PLAYERS_TO_START: int = 1
const CHARACTER_IDS: Array[String] = ["sagui", "coelha", "tigre", "raposa"]
const COLOR_SURFACE: Color = Color(0.035, 0.045, 0.032, 0.96)
const COLOR_SURFACE_HOVER: Color = Color(0.112, 0.132, 0.075, 1.0)
const COLOR_BORDER: Color = Color(0.56, 0.405, 0.105, 1.0)
const COLOR_BG: Color = Color(0.006, 0.009, 0.012, 1.0)
const COLOR_GREEN: Color = Color(0.075, 0.56, 0.255, 1.0)
const COLOR_GREEN_HIGHLIGHT: Color = Color(0.22, 0.86, 0.42, 1.0)
const COLOR_GOLD: Color = Color(0.94, 0.68, 0.16, 1.0)
const COLOR_AMBER: Color = Color(1.0, 0.48, 0.12, 1.0)
const COLOR_RED: Color = Color(0.94, 0.12, 0.095, 1.0)
const COLOR_ORANGE: Color = Color(0.98, 0.35, 0.08, 1.0)
const COLOR_CYAN: Color = Color(0.31, 0.78, 0.74, 1.0)
const COLOR_TEXT: Color = Color(0.96, 0.91, 0.78, 1.0)
const COLOR_MUTED: Color = Color(0.64, 0.62, 0.52, 1.0)
const COLOR_BLACK: Color = Color(0.004, 0.005, 0.006, 1.0)

# Fonte visual da tela de selecao. Edite estes campos para trocar nome,
# habilidade, altura/peso/cooldown e cor dos cards. Veja docs/character_select_ui.md.
const CHARACTER_CARD_DATA: Dictionary = {
	"sagui": {
		"name": "SAGUI",
		"role": "ARMADILHA",
		"skill": "Trap holografica",
		"stats": "SETOR CAIXAS\nMALOTE: MEDIO\nCOOLDOWN 45s",
		"color": Color(0.29, 0.871, 0.502, 1.0),
	},
	"coelha": {
		"name": "COELHA",
		"role": "ROTA DE FUGA",
		"skill": "Rabbit Hole",
		"stats": "SETOR COFRE\nMALOTE: ALTO\nCOOLDOWN 60s",
		"color": Color(0.22, 0.741, 0.973, 1.0),
	},
	"tigre": {
		"name": "TIGRE",
		"role": "QUEBRA CERCO",
		"skill": "Golpe de sorte",
		"stats": "SETOR SAGUAO\nMALOTE: PESADO\nCOOLDOWN 45s",
		"color": Color(0.976, 0.451, 0.086, 1.0),
	},
	"raposa": {
		"name": "RAPOSA",
		"role": "ESCAPISTA",
		"skill": "Fuga improvisada",
		"stats": "SETOR GARAGEM\nMALOTE: LEVE\nCOOLDOWN 30s",
		"color": Color(0.937, 0.267, 0.267, 1.0),
	},
}

enum MenuState {
	LOBBY_CONTROLS,
	CHARACTER_SELECT,
	POLICE_REVEAL,
}

@onready var play_button: Button = $Root/Columns/MenuPanel/MenuColumn/PlayButton
@onready var settings_button: Button = $Root/Columns/MenuPanel/MenuColumn/SettingsButton
@onready var quit_button: Button = $Root/Columns/MenuPanel/MenuColumn/QuitButton
@onready var root_margin: MarginContainer = $Root
@onready var columns: HBoxContainer = $Root/Columns
@onready var menu_column: VBoxContainer = $Root/Columns/MenuPanel/MenuColumn
@onready var status_label: Label = $Root/Columns/MenuPanel/MenuColumn/StatusLabel
@onready var title_label: Label = $Root/Columns/MenuPanel/MenuColumn/Title
@onready var subtitle_label: Label = $Root/Columns/MenuPanel/MenuColumn/Subtitle
@onready var lobby_column: VBoxContainer = $Root/Columns/LobbyPanel/LobbyColumn
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
@onready var character_panel: PanelContainer = $Root/Columns/CharacterPanel
@onready var character_column: VBoxContainer = $Root/Columns/CharacterPanel/CharacterColumn
@onready var character_title_label: Label = $Root/Columns/CharacterPanel/CharacterColumn/CharacterTitle
@onready var character_turn_label: Label = $Root/Columns/CharacterPanel/CharacterColumn/CharacterTurnLabel
@onready var character_status_label: Label = $Root/Columns/CharacterPanel/CharacterColumn/CharacterStatusLabel
@onready var character_grid: GridContainer = $Root/Columns/CharacterPanel/CharacterColumn/CharacterGrid
@onready var character_buttons: Array[Button] = [
	$Root/Columns/CharacterPanel/CharacterColumn/CharacterGrid/SaguiButton,
	$Root/Columns/CharacterPanel/CharacterColumn/CharacterGrid/CoelhaButton,
	$Root/Columns/CharacterPanel/CharacterColumn/CharacterGrid/TigreButton,
	$Root/Columns/CharacterPanel/CharacterColumn/CharacterGrid/RaposaButton,
]
@onready var reveal_panel: PanelContainer = $RevealOverlay
@onready var reveal_title_label: Label = $RevealOverlay/RevealColumn/RevealTitle
@onready var reveal_label: Label = $RevealOverlay/RevealColumn/RevealLabel
@onready var volume_slider: HSlider = $SettingsOverlay/SettingsColumn/VolumeSlider
@onready var lobby_title_label: Label = $Root/Columns/LobbyPanel/LobbyColumn/LobbyTitle

var menu_time: float = 0.0
var button_targets: Array[Button] = []
var panel_targets: Array[Control] = []
var current_state: int = MenuState.LOBBY_CONTROLS
var selecting_player_index: int = 0
var character_cursor_index: int = 0
var character_name_labels: Array[Label] = []
var character_role_labels: Array[Label] = []
var character_skill_labels: Array[Label] = []
var character_stat_labels: Array[Label] = []
var character_portrait_panels: Array[Panel] = []
var character_lock_labels: Array[Label] = []
var menu_decals: Array[Control] = []
var lobby_prompt_strip: ControllerPromptStrip = null
var character_prompt_strip: ControllerPromptStrip = null
var reveal_prompt_strip: ControllerPromptStrip = null
var ui_update_accumulator: float = 0.0
const MENU_UI_UPDATE_INTERVAL: float = 0.12

func _ready() -> void:
	_apply_visual_style()
	_apply_responsive_layout()
	volume_slider.value_changed.connect(_on_volume_changed)
	_disable_pointer_input()

	if InputManager.has_method("clear_joined_devices"):
		InputManager.clear_joined_devices()

	settings_panel.visible = false
	reveal_panel.visible = false
	_set_menu_state(MenuState.LOBBY_CONTROLS)
	_sync_volume_slider()
	_update_lobby_ui()

func _process(delta: float) -> void:
	menu_time += delta
	ui_update_accumulator += delta
	if ui_update_accumulator >= MENU_UI_UPDATE_INTERVAL:
		ui_update_accumulator = 0.0
		if current_state == MenuState.LOBBY_CONTROLS:
			_update_lobby_ui()
		elif current_state == MenuState.CHARACTER_SELECT:
			_update_character_select_ui()
	_update_menu_motion(delta)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_apply_responsive_layout()

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		var joypad_event: InputEventJoypadButton = event
		if not joypad_event.pressed:
			return
		if current_state == MenuState.LOBBY_CONTROLS:
			if _is_join_button(joypad_event.button_index) and InputManager.try_join_device(joypad_event.device):
				_update_lobby_ui()
				return
			if _is_start_button(joypad_event.button_index) or _is_join_button(joypad_event.button_index):
				_start_character_selection_if_ready()
				return
		if current_state == MenuState.CHARACTER_SELECT:
			_handle_character_select_button(joypad_event)

func _on_play_pressed() -> void:
	_start_character_selection_if_ready()

func _start_character_selection_if_ready() -> void:
	var joined_players: Array[int] = InputManager.get_joined_devices()
	if joined_players.size() < MIN_PLAYERS_TO_START:
		status_label.text = "Entre com pelo menos 1 controle para iniciar o assalto"
		return

	InputManager.reset_match_setup()
	if InputManager.has_method("clear_pressed_buttons"):
		InputManager.clear_pressed_buttons()
	selecting_player_index = 0
	character_cursor_index = 0
	_set_menu_state(MenuState.CHARACTER_SELECT)
	_update_character_select_ui()

func _on_settings_pressed() -> void:
	settings_panel.visible = not settings_panel.visible

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_volume_changed(value: float) -> void:
	var volume_db: float = linear_to_db(max(value, 0.001))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)

func _on_character_button_pressed(character_index: int) -> void:
	if current_state != MenuState.CHARACTER_SELECT:
		return

	character_cursor_index = character_index
	_try_select_current_character()

func _update_lobby_ui() -> void:
	var connected_devices: PackedInt32Array = InputManager.get_connected_devices()
	var joined_players: Array[int] = InputManager.get_joined_devices()
	var ready_players: int = joined_players.size()

	connected_label.text = "CONTROLES %d  |  EQUIPE %d/%d" % [connected_devices.size(), ready_players, MAX_PLAYERS]
	play_button.disabled = ready_players < MIN_PLAYERS_TO_START
	if ready_players >= MIN_PLAYERS_TO_START:
		play_button.text = "Selecionar"
	else:
		play_button.text = "Entrar"

	for slot_index: int in range(slot_labels.size()):
		if slot_index < ready_players:
			slot_labels[slot_index].text = "OPERADOR %d  //  CONTROLE %d  //  PRONTO" % [slot_index + 1, joined_players[slot_index]]
			continue

		slot_labels[slot_index].text = "OPERADOR %d  //  AGUARDANDO CONTROLE" % [slot_index + 1]

	if connected_devices.is_empty():
		status_label.text = "Conecte os controles para montar a equipe do cofre"
	elif ready_players < MIN_PLAYERS_TO_START:
		status_label.text = "Entre com pelo menos 1 controle. O policial sera revelado depois."
	else:
		status_label.text = "Equipe pronta. Abra os dossies do assalto."

func _sync_volume_slider() -> void:
	var master_bus_index: int = AudioServer.get_bus_index("Master")
	var current_db: float = AudioServer.get_bus_volume_db(master_bus_index)
	volume_slider.value = db_to_linear(current_db)

func _is_join_button(button_index: int) -> bool:
	return button_index == JOY_BUTTON_A or button_index == JOY_BUTTON_X

func _is_cancel_button(button_index: int) -> bool:
	return button_index == JOY_BUTTON_B

func _is_start_button(button_index: int) -> bool:
	return button_index == JOY_BUTTON_START

func _set_menu_state(new_state: int) -> void:
	current_state = new_state
	var is_character_select: bool = current_state == MenuState.CHARACTER_SELECT
	var is_reveal: bool = current_state == MenuState.POLICE_REVEAL
	menu_panel.visible = not is_character_select and not is_reveal
	lobby_panel.visible = not is_character_select and not is_reveal
	character_panel.visible = is_character_select and not is_reveal
	reveal_panel.visible = is_reveal
	settings_panel.visible = false
	play_button.disabled = is_character_select or is_reveal
	play_button.text = "Selecionando..." if is_character_select else play_button.text
	call_deferred("_prime_menu_layout")

func _handle_character_select_button(joypad_event: InputEventJoypadButton) -> void:
	var joined_players: Array[int] = InputManager.get_joined_devices()
	if selecting_player_index >= joined_players.size():
		return

	var current_device: int = joined_players[selecting_player_index]
	if joypad_event.device != current_device:
		return

	if _is_cancel_button(joypad_event.button_index):
		InputManager.reset_match_setup()
		selecting_player_index = 0
		character_cursor_index = 0
		_set_menu_state(MenuState.LOBBY_CONTROLS)
		_update_lobby_ui()
	elif joypad_event.button_index == JOY_BUTTON_DPAD_LEFT:
		_move_character_cursor(-1)
	elif joypad_event.button_index == JOY_BUTTON_DPAD_RIGHT:
		_move_character_cursor(1)
	elif joypad_event.button_index == JOY_BUTTON_DPAD_UP:
		_move_character_cursor(-2)
	elif joypad_event.button_index == JOY_BUTTON_DPAD_DOWN:
		_move_character_cursor(2)
	elif _is_join_button(joypad_event.button_index):
		_try_select_current_character()

func _move_character_cursor(step: int) -> void:
	character_cursor_index = wrapi(character_cursor_index + step, 0, CHARACTER_IDS.size())
	_update_character_select_ui()

func _try_select_current_character() -> void:
	var joined_players: Array[int] = InputManager.get_joined_devices()
	if selecting_player_index >= joined_players.size():
		return

	var character_id: String = CHARACTER_IDS[character_cursor_index]
	var current_device: int = joined_players[selecting_player_index]
	if not InputManager.set_character_for_device(current_device, character_id):
		character_status_label.text = "%s ja foi escolhido. Escolha outro." % InputManager.get_character_display_name(character_id)
		return

	selecting_player_index += 1
	character_cursor_index = _get_first_available_character_index()
	if selecting_player_index >= joined_players.size():
		_start_police_reveal()
		return

	_update_character_select_ui()

func _get_first_available_character_index() -> int:
	var selected_ids: Array[String] = InputManager.get_selected_character_ids()
	for character_index: int in range(CHARACTER_IDS.size()):
		if CHARACTER_IDS[character_index] not in selected_ids:
			return character_index
	return 0

func _update_character_select_ui() -> void:
	var joined_players: Array[int] = InputManager.get_joined_devices()
	var selected_ids: Array[String] = InputManager.get_selected_character_ids()
	if joined_players.is_empty():
		_set_menu_state(MenuState.LOBBY_CONTROLS)
		return

	var current_player_label: String = "Todos escolheram"
	if selecting_player_index < joined_players.size():
		current_player_label = "Jogador %d | Controle %d" % [selecting_player_index + 1, joined_players[selecting_player_index]]

	character_title_label.text = "DOSSIER DO ASSALTO"
	character_turn_label.text = "%s" % current_player_label.to_upper()
	character_status_label.text = "ESCOLHA UM OPERADOR UNICO PARA A FUGA"

	for character_index: int in range(character_buttons.size()):
		var character_id: String = CHARACTER_IDS[character_index]
		var button: Button = character_buttons[character_index]
		var is_selected: bool = character_id in selected_ids
		var is_cursor: bool = character_index == character_cursor_index
		button.disabled = is_selected
		_apply_character_card_state(character_index, is_cursor, is_selected)

func _start_police_reveal() -> void:
	var police_device: int = InputManager.pick_random_police()
	if police_device == -1:
		_set_menu_state(MenuState.LOBBY_CONTROLS)
		return

	var police_character_name: String = InputManager.get_police_character_name()
	reveal_label.text = "%s PEGOU O DISTINTIVO" % police_character_name.to_upper()
	status_label.text = "Alarme disparado. Fechando as portas do banco..."
	if InputManager.has_method("clear_pressed_buttons"):
		InputManager.clear_pressed_buttons()
	_set_menu_state(MenuState.POLICE_REVEAL)
	await get_tree().create_timer(2.2).timeout
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _apply_visual_style() -> void:
	_add_background()
	_add_heist_decals()
	_build_character_cards()
	_create_controller_prompt_strips()
	button_targets = [play_button, settings_button, quit_button]
	for character_button: Button in character_buttons:
		button_targets.append(character_button)
	panel_targets = [menu_panel, lobby_panel, character_panel, settings_panel, reveal_panel]
	_style_panel(menu_panel, COLOR_GOLD)
	_style_panel(lobby_panel, COLOR_GREEN_HIGHLIGHT)
	_style_panel(character_panel, COLOR_GOLD)
	_style_panel(settings_panel, COLOR_GOLD)
	_style_panel(reveal_panel, COLOR_RED)
	_style_button(play_button, COLOR_GOLD, Color(1.0, 0.78, 0.26, 1.0), true)
	_style_button(settings_button, COLOR_GREEN, COLOR_GREEN_HIGHLIGHT, false)
	_style_button(quit_button, COLOR_RED, COLOR_ORANGE, false)
	play_button.icon = ICON_PLAY
	settings_button.icon = ICON_REPEAT
	for character_button: Button in character_buttons:
		_style_character_button(character_button, COLOR_BORDER, false, false)
	_style_slider(volume_slider)
	_connect_button_feedback()

	title_label.text = "TIME TO RUSH"
	title_label.add_theme_font_override("font", FONT_ARCADE)
	title_label.add_theme_color_override("font_color", COLOR_GOLD)
	title_label.add_theme_color_override("font_shadow_color", Color(COLOR_GREEN_HIGHLIGHT.r, COLOR_GREEN_HIGHLIGHT.g, COLOR_GREEN_HIGHLIGHT.b, 0.7))
	title_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.88))
	title_label.add_theme_constant_override("outline_size", 8)
	title_label.add_theme_constant_override("shadow_offset_x", 0)
	title_label.add_theme_constant_override("shadow_offset_y", 7)
	title_label.add_theme_font_size_override("font_size", 62)
	subtitle_label.text = "ASSALTO AO BANCO // COFRE CENTRAL"
	subtitle_label.add_theme_font_override("font", FONT_UI)
	subtitle_label.add_theme_color_override("font_color", COLOR_GOLD)
	subtitle_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.72))
	subtitle_label.add_theme_constant_override("outline_size", 4)
	status_label.add_theme_color_override("font_color", COLOR_MUTED)
	status_label.add_theme_font_override("font", FONT_UI)
	status_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.62))
	status_label.add_theme_constant_override("outline_size", 3)
	connected_label.add_theme_color_override("font_color", COLOR_GOLD)
	connected_label.add_theme_font_override("font", FONT_UI)
	join_hint_label.add_theme_color_override("font_color", COLOR_GOLD)
	join_hint_label.add_theme_font_override("font", FONT_UI)
	join_hint_label.text = "Controle conectado entra na equipe do cofre"
	lobby_title_label.text = "LOBBY DO ASSALTO"
	lobby_title_label.add_theme_font_override("font", FONT_ARCADE)
	lobby_title_label.add_theme_color_override("font_color", COLOR_GREEN_HIGHLIGHT)
	lobby_title_label.add_theme_color_override("font_shadow_color", Color(COLOR_GOLD.r, COLOR_GOLD.g, COLOR_GOLD.b, 0.5))
	lobby_title_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.78))
	lobby_title_label.add_theme_constant_override("outline_size", 5)
	lobby_title_label.add_theme_font_size_override("font_size", 34)
	character_title_label.text = "DOSSIER DO ASSALTO"
	character_title_label.add_theme_font_override("font", FONT_ARCADE)
	character_title_label.add_theme_color_override("font_color", COLOR_GOLD)
	character_title_label.add_theme_color_override("font_shadow_color", Color(COLOR_GREEN_HIGHLIGHT.r, COLOR_GREEN_HIGHLIGHT.g, COLOR_GREEN_HIGHLIGHT.b, 0.72))
	character_title_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.78))
	character_title_label.add_theme_constant_override("outline_size", 8)
	character_title_label.add_theme_constant_override("shadow_offset_y", 5)
	character_title_label.add_theme_font_size_override("font_size", 44)
	character_turn_label.add_theme_color_override("font_color", COLOR_TEXT)
	character_turn_label.add_theme_font_override("font", FONT_UI)
	character_turn_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.78))
	character_turn_label.add_theme_constant_override("outline_size", 4)
	character_turn_label.add_theme_font_size_override("font_size", 24)
	character_status_label.add_theme_color_override("font_color", COLOR_MUTED)
	character_status_label.add_theme_font_override("font", FONT_UI)
	character_status_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.72))
	character_status_label.add_theme_constant_override("outline_size", 3)
	reveal_title_label.text = "ALARME DO BANCO"
	reveal_title_label.add_theme_font_override("font", FONT_ARCADE)
	reveal_title_label.add_theme_color_override("font_color", COLOR_GOLD)
	reveal_title_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.82))
	reveal_title_label.add_theme_constant_override("outline_size", 5)
	reveal_label.add_theme_color_override("font_color", COLOR_RED)
	reveal_label.add_theme_font_override("font", FONT_ARCADE)
	reveal_label.add_theme_color_override("font_shadow_color", Color(COLOR_RED.r, COLOR_RED.g, COLOR_RED.b, 0.7))
	reveal_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.9))
	reveal_label.add_theme_constant_override("outline_size", 8)

	for label: Label in slot_labels:
		label.add_theme_color_override("font_color", COLOR_TEXT)
		label.add_theme_font_override("font", FONT_UI)
		label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.7))
		label.add_theme_constant_override("outline_size", 3)
		label.add_theme_font_size_override("font_size", 20)

	_style_settings_labels()
	call_deferred("_prime_menu_layout")

func _create_controller_prompt_strips() -> void:
	if lobby_prompt_strip == null:
		lobby_prompt_strip = ControllerPromptStrip.new()
		lobby_prompt_strip.name = "LobbyControllerPrompts"
		lobby_prompt_strip.set_prompts([
			{"prompt": "confirm", "text": "entrar"},
			{"prompt": "start", "text": "selecionar"},
		])
		lobby_column.add_child(lobby_prompt_strip)
		lobby_column.move_child(lobby_prompt_strip, join_hint_label.get_index() + 1)

	if character_prompt_strip == null:
		character_prompt_strip = ControllerPromptStrip.new()
		character_prompt_strip.name = "CharacterControllerPrompts"
		character_prompt_strip.alignment = BoxContainer.ALIGNMENT_CENTER
		character_prompt_strip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		character_prompt_strip.set_prompts([
			{"prompt": "dpad", "text": "navegar"},
			{"prompt": "confirm", "text": "assinar"},
			{"prompt": "cancel", "text": "voltar"},
		])
		character_column.add_child(character_prompt_strip)
		character_column.move_child(character_prompt_strip, character_status_label.get_index())

	if reveal_prompt_strip == null:
		reveal_prompt_strip = ControllerPromptStrip.new()
		reveal_prompt_strip.name = "RevealControllerPrompts"
		reveal_prompt_strip.set_prompts([
			{"prompt": "start", "text": "iniciar"},
		])
		reveal_panel.get_node("RevealColumn").add_child(reveal_prompt_strip)

func _apply_responsive_layout() -> void:
	if root_margin == null:
		return

	var viewport_size: Vector2 = get_viewport_rect().size
	var is_compact: bool = viewport_size.x < 1500.0 or viewport_size.y < 820.0
	var is_large: bool = viewport_size.x >= 1800.0 and viewport_size.y >= 950.0
	var margin_x: int = 24 if is_compact else (56 if is_large else 36)
	var margin_y: int = 18 if is_compact else (42 if is_large else 28)
	var panel_gap: int = 20 if is_compact else (44 if is_large else 32)
	var column_gap: int = 10 if is_compact else (18 if is_large else 14)
	var button_font_size: int = 24 if is_compact else (32 if is_large else 30)
	var secondary_button_font_size: int = 20 if is_compact else (26 if is_large else 24)
	var card_width: float = 162.0 if is_compact else (214.0 if is_large else 184.0)
	var card_height: float = 264.0 if is_compact else (326.0 if is_large else 292.0)
	var portrait_height: float = 84.0 if is_compact else (118.0 if is_large else 98.0)
	var card_title_size: int = 18 if is_compact else (24 if is_large else 21)
	var card_role_size: int = 12 if is_compact else (15 if is_large else 13)
	var card_text_size: int = 11 if is_compact else (14 if is_large else 12)

	root_margin.offset_left = margin_x
	root_margin.offset_top = margin_y
	root_margin.offset_right = -margin_x
	root_margin.offset_bottom = -margin_y
	columns.add_theme_constant_override("separation", panel_gap)
	menu_column.add_theme_constant_override("separation", column_gap + 2)
	lobby_column.add_theme_constant_override("separation", column_gap)
	character_column.add_theme_constant_override("separation", maxi(5, column_gap - 4) if is_compact else column_gap)
	character_grid.columns = 4
	character_grid.add_theme_constant_override("h_separation", 14 if is_compact else (24 if is_large else 18))
	character_grid.add_theme_constant_override("v_separation", 8 if is_compact else 14)

	title_label.add_theme_font_size_override("font_size", 46 if is_compact else (70 if is_large else 62))
	subtitle_label.add_theme_font_size_override("font_size", 21 if is_compact else (28 if is_large else 24))
	lobby_title_label.add_theme_font_size_override("font_size", 28 if is_compact else (38 if is_large else 34))
	character_title_label.add_theme_font_size_override("font_size", 28 if is_compact else (42 if is_large else 36))
	character_turn_label.add_theme_font_size_override("font_size", 16 if is_compact else (22 if is_large else 19))
	character_status_label.add_theme_font_size_override("font_size", 13 if is_compact else (17 if is_large else 15))
	status_label.add_theme_font_size_override("font_size", 17 if is_compact else (21 if is_large else 19))
	connected_label.add_theme_font_size_override("font_size", 18 if is_compact else (23 if is_large else 20))
	join_hint_label.add_theme_font_size_override("font_size", 16 if is_compact else (21 if is_large else 18))
	if lobby_prompt_strip:
		lobby_prompt_strip.set_prompt_size(28 if is_compact else (40 if is_large else 34), 14 if is_compact else (20 if is_large else 17))
	if character_prompt_strip:
		character_prompt_strip.set_prompt_size(20 if is_compact else (30 if is_large else 24), 11 if is_compact else (16 if is_large else 13))
	if reveal_prompt_strip:
		reveal_prompt_strip.set_prompt_size(30 if is_compact else (42 if is_large else 36), 15 if is_compact else (21 if is_large else 18))
	play_button.add_theme_font_size_override("font_size", button_font_size)
	settings_button.add_theme_font_size_override("font_size", secondary_button_font_size)
	quit_button.add_theme_font_size_override("font_size", secondary_button_font_size)

	for label: Label in slot_labels:
		label.add_theme_font_size_override("font_size", 16 if is_compact else (22 if is_large else 20))

	for character_index: int in range(character_buttons.size()):
		character_buttons[character_index].custom_minimum_size = Vector2(card_width, card_height)
		if character_name_labels.size() > character_index:
			character_name_labels[character_index].add_theme_font_size_override("font_size", card_title_size)
		if character_role_labels.size() > character_index:
			character_role_labels[character_index].add_theme_font_size_override("font_size", card_role_size)
		if character_skill_labels.size() > character_index:
			character_skill_labels[character_index].add_theme_font_size_override("font_size", card_text_size)
		if character_stat_labels.size() > character_index:
			character_stat_labels[character_index].add_theme_font_size_override("font_size", card_text_size)
		if character_lock_labels.size() > character_index:
			character_lock_labels[character_index].add_theme_font_size_override("font_size", card_role_size)
		if character_portrait_panels.size() > character_index:
			character_portrait_panels[character_index].custom_minimum_size = Vector2(0.0, portrait_height)

	reveal_panel.offset_left = -280.0 if is_compact else -360.0
	reveal_panel.offset_top = -116.0 if is_compact else -150.0
	reveal_panel.offset_right = 280.0 if is_compact else 360.0
	reveal_panel.offset_bottom = 116.0 if is_compact else 150.0
	reveal_title_label.add_theme_font_size_override("font_size", 27 if is_compact else (38 if is_large else 34))
	reveal_label.add_theme_font_size_override("font_size", 34 if is_compact else (48 if is_large else 42))
	settings_panel.offset_left = -200.0 if is_compact else -240.0
	settings_panel.offset_top = -104.0 if is_compact else -122.0
	settings_panel.offset_right = 200.0 if is_compact else 240.0
	settings_panel.offset_bottom = 104.0 if is_compact else 122.0
	call_deferred("_prime_menu_layout")

func _add_background() -> void:
	var existing_background: Node = get_node_or_null("HeistBackground")
	if existing_background:
		return

	var background: HeistBackground = HeistBackground.new()
	background.name = "HeistBackground"
	add_child(background)
	move_child(background, 0)

func _add_heist_decals() -> void:
	if not menu_decals.is_empty():
		return

	var cash_trail: HeistIcon = _make_screen_decal(HeistIcon.IconType.CASH_TRAIL, Vector2(0.0, 0.72), Vector2(1.0, 0.19), COLOR_GREEN_HIGHLIGHT, 0.78)
	cash_trail.name = "MenuCashTrail"
	menu_decals.append(cash_trail)

	var vault_icon: HeistIcon = _make_screen_decal(HeistIcon.IconType.VAULT, Vector2(0.75, 0.07), Vector2(0.2, 0.3), COLOR_GOLD, 0.92)
	vault_icon.name = "MenuVaultIcon"
	menu_decals.append(vault_icon)

	var alarm_icon: HeistIcon = _make_screen_decal(HeistIcon.IconType.ALARM, Vector2(0.045, 0.12), Vector2(0.105, 0.17), COLOR_RED, 0.82)
	alarm_icon.name = "MenuAlarmIcon"
	menu_decals.append(alarm_icon)

	var bag_icon: HeistIcon = _make_screen_decal(HeistIcon.IconType.MONEY_BAG, Vector2(0.06, 0.58), Vector2(0.15, 0.23), COLOR_GREEN_HIGHLIGHT, 0.9)
	bag_icon.name = "MenuMoneyBagIcon"
	menu_decals.append(bag_icon)

	menu_decals.append(_make_screen_label("ALVO: COFRE CENTRAL", Vector2(0.64, 0.36), Vector2(0.25, 0.055), COLOR_GOLD))
	menu_decals.append(_make_screen_label("ALARME ARMADO", Vector2(0.07, 0.31), Vector2(0.19, 0.055), COLOR_RED))
	menu_decals.append(_make_screen_label("MALOTES // DINHEIRO", Vector2(0.08, 0.82), Vector2(0.23, 0.055), COLOR_GREEN_HIGHLIGHT))
	menu_decals.append(_make_screen_label("SAIDA: GARAGEM", Vector2(0.66, 0.68), Vector2(0.22, 0.055), COLOR_GREEN_HIGHLIGHT))

func _make_screen_decal(icon_type: int, anchor_position: Vector2, anchor_size: Vector2, accent: Color, opacity: float) -> HeistIcon:
	var icon: HeistIcon = HeistIcon.new()
	icon.icon_type = icon_type
	icon.accent = accent
	icon.opacity = opacity
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.anchor_left = anchor_position.x
	icon.anchor_top = anchor_position.y
	icon.anchor_right = anchor_position.x + anchor_size.x
	icon.anchor_bottom = anchor_position.y + anchor_size.y
	icon.offset_left = 0.0
	icon.offset_top = 0.0
	icon.offset_right = 0.0
	icon.offset_bottom = 0.0
	add_child(icon)
	move_child(icon, 1)
	return icon

func _make_screen_label(text: String, anchor_position: Vector2, anchor_size: Vector2, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", FONT_UI)
	label.add_theme_font_size_override("font_size", 19)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", COLOR_BLACK)
	label.add_theme_constant_override("outline_size", 4)
	label.anchor_left = anchor_position.x
	label.anchor_top = anchor_position.y
	label.anchor_right = anchor_position.x + anchor_size.x
	label.anchor_bottom = anchor_position.y + anchor_size.y
	label.offset_left = 0.0
	label.offset_top = 0.0
	label.offset_right = 0.0
	label.offset_bottom = 0.0
	add_child(label)
	move_child(label, 2)
	return label

func _style_panel(panel: PanelContainer, accent: Color) -> void:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color(0.012, 0.014, 0.012, 0.93)
	if panel == menu_panel:
		style_box.bg_color = Color(0.022, 0.026, 0.018, 0.94)
	if panel == lobby_panel:
		style_box.bg_color = Color(0.012, 0.032, 0.02, 0.93)
	if panel == character_panel:
		style_box.bg_color = Color(0.006, 0.008, 0.006, 0.96)
	style_box.border_color = Color(accent.r, accent.g, accent.b, 0.9)
	style_box.set_border_width_all(3)
	style_box.corner_radius_top_left = 6
	style_box.corner_radius_top_right = 6
	style_box.corner_radius_bottom_right = 6
	style_box.corner_radius_bottom_left = 6
	style_box.shadow_color = Color(0.0, 0.0, 0.0, 0.68)
	style_box.shadow_size = 28
	style_box.content_margin_left = 30
	style_box.content_margin_right = 30
	style_box.content_margin_top = 26
	style_box.content_margin_bottom = 26
	panel.add_theme_stylebox_override("panel", style_box)

func _build_character_cards() -> void:
	character_grid.columns = 4
	character_grid.add_theme_constant_override("h_separation", 18)
	character_grid.add_theme_constant_override("v_separation", 18)
	character_name_labels.clear()
	character_role_labels.clear()
	character_skill_labels.clear()
	character_stat_labels.clear()
	character_portrait_panels.clear()
	character_lock_labels.clear()

	for character_index: int in range(character_buttons.size()):
		var button: Button = character_buttons[character_index]
		var character_id: String = CHARACTER_IDS[character_index]
		var data: Dictionary = CHARACTER_CARD_DATA[character_id] as Dictionary
		var accent: Color = data["color"] as Color
		button.text = ""
		button.custom_minimum_size = Vector2(188.0, 330.0)
		button.clip_contents = true
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.focus_mode = Control.FOCUS_ALL

		for child: Node in button.get_children():
			child.queue_free()

		var margin: MarginContainer = MarginContainer.new()
		margin.name = "CardMargin"
		margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		margin.set_anchors_preset(Control.PRESET_FULL_RECT)
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_bottom", 8)
		button.add_child(margin)

		var column: VBoxContainer = VBoxContainer.new()
		column.name = "CardColumn"
		column.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.alignment = BoxContainer.ALIGNMENT_BEGIN
		column.add_theme_constant_override("separation", 4)
		margin.add_child(column)

		var name_label: Label = _make_card_label(str(data["name"]), 25, COLOR_GOLD, HORIZONTAL_ALIGNMENT_CENTER)
		column.add_child(name_label)
		character_name_labels.append(name_label)

		var dossier_strip: Label = _make_card_label("DOSSIER // %02d" % [character_index + 1], 10, COLOR_GREEN_HIGHLIGHT, HORIZONTAL_ALIGNMENT_CENTER)
		column.add_child(dossier_strip)

		var portrait: Panel = Panel.new()
		portrait.name = "Portrait"
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		portrait.custom_minimum_size = Vector2(0.0, 138.0)
		portrait.add_theme_stylebox_override("panel", _make_portrait_style(accent, false))
		column.add_child(portrait)
		character_portrait_panels.append(portrait)

		_add_portrait_shapes(portrait, accent, character_index)
		_add_card_heist_icon(portrait, character_id)

		var divider: TextureRect = TextureRect.new()
		divider.name = "CardDivider"
		divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
		divider.texture = CARD_DIVIDER
		divider.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		divider.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		divider.custom_minimum_size = Vector2(0.0, 7.0)
		column.add_child(divider)

		var role_label: Label = _make_card_label(str(data["role"]), 17, COLOR_GOLD, HORIZONTAL_ALIGNMENT_CENTER)
		column.add_child(role_label)
		character_role_labels.append(role_label)

		var skill_label: Label = _make_card_label("SKILL  //  %s" % str(data["skill"]), 15, accent.lightened(0.24), HORIZONTAL_ALIGNMENT_CENTER)
		column.add_child(skill_label)
		character_skill_labels.append(skill_label)

		var stat_label: Label = _make_card_label(str(data["stats"]), 13, COLOR_TEXT, HORIZONTAL_ALIGNMENT_LEFT)
		stat_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(stat_label)
		character_stat_labels.append(stat_label)

		var lock_label: Label = _make_card_label("", 17, COLOR_RED, HORIZONTAL_ALIGNMENT_CENTER)
		column.add_child(lock_label)
		character_lock_labels.append(lock_label)

func _make_card_label(text: String, font_size: int, color: Color, alignment: HorizontalAlignment) -> Label:
	var label: Label = Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = text
	label.horizontal_alignment = alignment
	label.add_theme_font_override("font", FONT_UI)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.86))
	label.add_theme_constant_override("outline_size", 4)
	return label

func _add_portrait_shapes(parent: Panel, accent: Color, character_index: int) -> void:
	var back_glow: ColorRect = _make_portrait_rect(Color(accent.r, accent.g, accent.b, 0.18), Vector2(0.04, 0.08), Vector2(0.92, 0.82))
	parent.add_child(back_glow)

	var vault_line: ColorRect = _make_portrait_rect(COLOR_GOLD, Vector2(0.08, 0.09), Vector2(0.84, 0.045))
	parent.add_child(vault_line)

	var bill_a: ColorRect = _make_portrait_rect(COLOR_GREEN, Vector2(0.08, 0.72), Vector2(0.34, 0.12))
	parent.add_child(bill_a)
	var bill_b: ColorRect = _make_portrait_rect(COLOR_GREEN_HIGHLIGHT, Vector2(0.16, 0.61), Vector2(0.34, 0.12))
	parent.add_child(bill_b)

	var head: ColorRect = _make_portrait_rect(accent.lightened(0.28), Vector2(0.35, 0.17), Vector2(0.3, 0.22))
	parent.add_child(head)

	var body: ColorRect = _make_portrait_rect(accent.darkened(0.18), Vector2(0.24, 0.43), Vector2(0.52, 0.42))
	parent.add_child(body)

	var visor: ColorRect = _make_portrait_rect(Color(0.92, 0.86, 0.58, 1.0), Vector2(0.28, 0.29), Vector2(0.44, 0.08))
	parent.add_child(visor)

	var stripe_x: float = 0.17 + float(character_index % 2) * 0.5
	var stripe: ColorRect = _make_portrait_rect(COLOR_BLACK, Vector2(stripe_x, 0.43), Vector2(0.08, 0.42))
	parent.add_child(stripe)

func _add_card_heist_icon(parent: Panel, character_id: String) -> void:
	var icon: HeistIcon = HeistIcon.new()
	match character_id:
		"sagui":
			icon.icon_type = HeistIcon.IconType.ALARM
			icon.opacity = 0.92
		"coelha":
			icon.icon_type = HeistIcon.IconType.KEYCARD
			icon.opacity = 0.9
		"tigre":
			icon.icon_type = HeistIcon.IconType.MONEY_BAG
			icon.opacity = 0.86
		"raposa":
			icon.icon_type = HeistIcon.IconType.MONEY_STACK
			icon.opacity = 0.88
		_:
			icon.icon_type = HeistIcon.IconType.MONEY_STACK
	icon.anchor_left = 0.56
	icon.anchor_top = 0.46
	icon.anchor_right = 0.96
	icon.anchor_bottom = 0.96
	icon.offset_left = 0.0
	icon.offset_top = 0.0
	icon.offset_right = 0.0
	icon.offset_bottom = 0.0
	parent.add_child(icon)

func _make_portrait_rect(color: Color, anchor_position: Vector2, anchor_size: Vector2) -> ColorRect:
	var rect: ColorRect = ColorRect.new()
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.color = color
	rect.anchor_left = anchor_position.x
	rect.anchor_top = anchor_position.y
	rect.anchor_right = anchor_position.x + anchor_size.x
	rect.anchor_bottom = anchor_position.y + anchor_size.y
	rect.offset_left = 0.0
	rect.offset_top = 0.0
	rect.offset_right = 0.0
	rect.offset_bottom = 0.0
	return rect

func _apply_character_card_state(character_index: int, is_cursor: bool, is_selected: bool) -> void:
	var button: Button = character_buttons[character_index]
	var character_id: String = CHARACTER_IDS[character_index]
	var data: Dictionary = CHARACTER_CARD_DATA[character_id] as Dictionary
	var accent: Color = data["color"] as Color
	_style_character_button(button, accent, is_cursor, is_selected)

	if character_portrait_panels.size() > character_index:
		character_portrait_panels[character_index].add_theme_stylebox_override("panel", _make_portrait_style(accent, is_cursor))
	if character_name_labels.size() > character_index:
		character_name_labels[character_index].add_theme_color_override("font_color", COLOR_GOLD if not is_selected else COLOR_MUTED)
	if character_lock_labels.size() > character_index:
		character_lock_labels[character_index].text = "ESCOLHIDO" if is_selected else ""

func _style_character_button(button: Button, accent: Color, highlighted: bool, disabled_card: bool) -> void:
	button.add_theme_stylebox_override("normal", _make_character_card_style(accent, highlighted, disabled_card))
	button.add_theme_stylebox_override("hover", _make_character_card_style(accent, true, disabled_card))
	button.add_theme_stylebox_override("focus", _make_character_card_style(accent, true, disabled_card))
	button.add_theme_stylebox_override("pressed", _make_character_card_style(accent.darkened(0.12), true, disabled_card))
	button.add_theme_stylebox_override("disabled", _make_character_card_style(COLOR_MUTED, false, true))

func _make_character_card_style(accent: Color, highlighted: bool, disabled_card: bool) -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color(0.014, 0.016, 0.012, 0.98) if not disabled_card else Color(0.012, 0.012, 0.01, 0.82)
	style_box.border_color = COLOR_GOLD if highlighted and not disabled_card else Color(accent.r, accent.g, accent.b, 0.82)
	style_box.set_border_width_all(6 if highlighted and not disabled_card else 2)
	style_box.corner_radius_top_left = 4
	style_box.corner_radius_top_right = 4
	style_box.corner_radius_bottom_right = 4
	style_box.corner_radius_bottom_left = 4
	style_box.shadow_color = Color(style_box.border_color.r, style_box.border_color.g, style_box.border_color.b, 0.52)
	style_box.shadow_size = 24 if highlighted and not disabled_card else 10
	style_box.content_margin_left = 10
	style_box.content_margin_right = 10
	style_box.content_margin_top = 10
	style_box.content_margin_bottom = 10
	return style_box

func _make_portrait_style(accent: Color, highlighted: bool) -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color(0.018 + accent.r * 0.08, 0.02 + accent.g * 0.08, 0.012 + accent.b * 0.05, 0.98)
	style_box.border_color = COLOR_GOLD if highlighted else Color(accent.r, accent.g, accent.b, 0.9)
	style_box.set_border_width_all(4 if highlighted else 2)
	style_box.corner_radius_top_left = 3
	style_box.corner_radius_top_right = 3
	style_box.corner_radius_bottom_right = 3
	style_box.corner_radius_bottom_left = 3
	return style_box

func _style_button(button: Button, accent: Color, hover: Color, is_primary: bool) -> void:
	var text_color: Color = Color(0.018, 0.027, 0.055, 1.0)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_override("font", FONT_UI)
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
	style_box.border_color = COLOR_GOLD if highlighted else Color(0.08, 0.06, 0.025, 0.86)
	style_box.set_border_width_all(4 if highlighted else 2)
	style_box.corner_radius_top_left = 5
	style_box.corner_radius_top_right = 5
	style_box.corner_radius_bottom_right = 5
	style_box.corner_radius_bottom_left = 5
	style_box.shadow_color = Color(fill.r, fill.g, fill.b, 0.52 if highlighted else 0.28)
	style_box.shadow_size = 22 if highlighted else 10
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
		if not button.focus_entered.is_connected(_on_menu_button_attention.bind(button)):
			button.focus_entered.connect(_on_menu_button_attention.bind(button))

func _disable_pointer_input() -> void:
	for button: Button in button_targets:
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for character_button: Button in character_buttons:
		character_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	volume_slider.mouse_filter = Control.MOUSE_FILTER_IGNORE

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
		var is_hot: bool = button.has_focus()
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
