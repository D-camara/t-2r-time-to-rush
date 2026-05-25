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
const LIGHTING_STYLE_LABELS: Array[String] = [
	"DIA SUAVE",
	"GOLDEN HOUR",
	"NUBLADO",
	"NOIR CYBER",
	"LUAR",
]
const RAIN_OPTION_LABELS: Array[String] = [
	"ATIVADA",
	"DESATIVADA",
]
const LIGHTING_STYLE_PREVIEW_PRESETS: Array[Dictionary] = [
	{
		"description": "Dia limpo e neutro para leitura de jogo.",
		"sun_color": Color(1.0, 0.97, 0.9, 1.0),
		"sun_energy": 1.45,
		"sun_rotation_degrees": Vector3(-52.0, 35.0, 0.0),
		"ambient_color": Color(0.74, 0.8, 0.9, 1.0),
		"ambient_energy": 0.52,
		"background_color": Color(0.53, 0.62, 0.74, 1.0),
		"floor_color": Color(0.18, 0.2, 0.23, 1.0),
		"subject_color": Color(0.87, 0.9, 0.95, 1.0),
	},
	{
		"description": "Fim de tarde quente, cinematico e dourado.",
		"sun_color": Color(1.0, 0.84, 0.62, 1.0),
		"sun_energy": 1.28,
		"sun_rotation_degrees": Vector3(-34.0, 20.0, 0.0),
		"ambient_color": Color(0.66, 0.56, 0.42, 1.0),
		"ambient_energy": 0.42,
		"background_color": Color(0.66, 0.48, 0.34, 1.0),
		"floor_color": Color(0.24, 0.18, 0.14, 1.0),
		"subject_color": Color(1.0, 0.86, 0.74, 1.0),
	},
	{
		"description": "Nublado suave com contraste mais baixo.",
		"sun_color": Color(0.88, 0.92, 0.98, 1.0),
		"sun_energy": 0.95,
		"sun_rotation_degrees": Vector3(-60.0, 10.0, 0.0),
		"ambient_color": Color(0.7, 0.75, 0.82, 1.0),
		"ambient_energy": 0.68,
		"background_color": Color(0.47, 0.54, 0.62, 1.0),
		"floor_color": Color(0.21, 0.23, 0.27, 1.0),
		"subject_color": Color(0.84, 0.88, 0.94, 1.0),
	},
	{
		"description": "Noir cyber com ambiente escuro e recorte forte.",
		"sun_color": Color(0.7, 0.8, 1.0, 1.0),
		"sun_energy": 1.02,
		"sun_rotation_degrees": Vector3(-57.0, 46.0, 0.0),
		"ambient_color": Color(0.12, 0.17, 0.26, 1.0),
		"ambient_energy": 0.36,
		"background_color": Color(0.08, 0.12, 0.2, 1.0),
		"floor_color": Color(0.07, 0.1, 0.16, 1.0),
		"subject_color": Color(0.67, 0.8, 1.0, 1.0),
	},
	{
		"description": "Luar frio, noturno e tenso.",
		"sun_color": Color(0.55, 0.68, 0.96, 1.0),
		"sun_energy": 0.72,
		"sun_rotation_degrees": Vector3(-66.0, 28.0, 0.0),
		"ambient_color": Color(0.14, 0.19, 0.29, 1.0),
		"ambient_energy": 0.31,
		"background_color": Color(0.07, 0.1, 0.16, 1.0),
		"floor_color": Color(0.06, 0.08, 0.12, 1.0),
		"subject_color": Color(0.66, 0.74, 0.92, 1.0),
	},
]
const CHARACTER_PORTRAITS: Dictionary = {
	"sagui": preload("res://assets/ui/characters/sagui.png"),
	"coelha": preload("res://assets/ui/characters/coelha.png"),
	"tigre": preload("res://assets/ui/characters/tigre.png"),
	"raposa": preload("res://assets/ui/characters/raposa.png"),
}
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
@onready var reveal_column: VBoxContainer = $RevealOverlay/RevealColumn
@onready var reveal_title_label: Label = $RevealOverlay/RevealColumn/RevealTitle
@onready var reveal_label: Label = $RevealOverlay/RevealColumn/RevealLabel
@onready var volume_slider: HSlider = $SettingsOverlay/SettingsColumn/VolumeSlider
@onready var lighting_style_option: OptionButton = $SettingsOverlay/SettingsColumn/LightingStyleOption
@onready var rain_option: OptionButton = $SettingsOverlay/SettingsColumn/RainOption
@onready var lighting_preview_container: SubViewportContainer = $SettingsOverlay/SettingsColumn/LightingPreviewViewport
@onready var lighting_preview_desc_label: Label = $SettingsOverlay/SettingsColumn/LightingPreviewDesc
@onready var close_settings_button: Button = $SettingsOverlay/SettingsColumn/CloseSettingsButton
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
var character_focus_labels: Array[Label] = []
var character_code_labels: Array[Label] = []
var menu_decals: Array[Control] = []
var terminal_overlays: Array[Control] = []
var lobby_slot_cards: Array[PanelContainer] = []
var lobby_slot_numbers: Array[Label] = []
var lobby_slot_icons: Array[Label] = []
var lobby_prompt_strip: ControllerPromptStrip = null
var character_prompt_strip: ControllerPromptStrip = null
var reveal_prompt_strip: ControllerPromptStrip = null
var character_progress_label: Label = null
var character_operation_label: Label = null
var reveal_dossier_panel: PanelContainer = null
var reveal_dossier_title_label: Label = null
var reveal_dossier_name_label: Label = null
var reveal_dossier_role_label: Label = null
var reveal_character_preview: TextureRect = null
var reveal_support_label: Label = null
var reveal_status_label: Label = null
var reveal_bottom_label: Label = null
var lighting_preview_viewport: SubViewport = null
var lighting_preview_world_environment: WorldEnvironment = null
var lighting_preview_sunlight: DirectionalLight3D = null
var lighting_preview_floor_material: StandardMaterial3D = null
var lighting_preview_subject_material: StandardMaterial3D = null
var ui_update_accumulator: float = 0.0
const MENU_UI_UPDATE_INTERVAL: float = 0.12

func _ready() -> void:
	_apply_visual_style()
	_apply_responsive_layout()
	_connect_menu_signals()
	_setup_lighting_style_options()
	_setup_rain_options()
	_setup_lighting_preview()
	volume_slider.value_changed.connect(_on_volume_changed)
	lighting_style_option.item_selected.connect(_on_lighting_style_selected)
	rain_option.item_selected.connect(_on_rain_option_selected)
	_disable_pointer_input()

	if InputManager.has_method("clear_joined_devices"):
		InputManager.clear_joined_devices()

	settings_panel.visible = false
	reveal_panel.visible = false
	_set_menu_state(MenuState.LOBBY_CONTROLS)
	_sync_volume_slider()
	_sync_lighting_style_option()
	_sync_rain_option()
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
		if settings_panel.visible:
			_handle_settings_joypad_input(joypad_event)
			return
		if current_state == MenuState.LOBBY_CONTROLS:
			if joypad_event.button_index == JOY_BUTTON_Y:
				_on_settings_pressed()
				return
			if _is_join_button(joypad_event.button_index) and InputManager.try_join_device(joypad_event.device):
				_update_lobby_ui()
				return
			if _is_start_button(joypad_event.button_index) or _is_join_button(joypad_event.button_index):
				_start_character_selection_if_ready()
				return
		if current_state == MenuState.CHARACTER_SELECT:
			_handle_character_select_button(joypad_event)
		return

	if event is InputEventKey:
		var key_event: InputEventKey = event
		if not key_event.pressed or key_event.echo:
			return
		_handle_keyboard_menu_input(key_event)

func _on_play_pressed() -> void:
	_start_character_selection_if_ready()

func _start_character_selection_if_ready() -> void:
	var joined_players: Array[int] = InputManager.get_joined_devices()
	if joined_players.size() < MIN_PLAYERS_TO_START:
		status_label.text = "Entre com pelo menos 1 jogador (E ou ESPACO) para iniciar o assalto"
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
	if settings_panel.visible:
		_sync_volume_slider()
		_sync_lighting_style_option()
		_sync_rain_option()
		_apply_lighting_style_preview(lighting_style_option.get_selected())
		status_label.text = "CONFIGURACOES ABERTAS: ajuste luz, volume e chuva."
	else:
		status_label.text = "Configuracoes salvas."

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_volume_changed(value: float) -> void:
	var volume_db: float = linear_to_db(max(value, 0.001))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)

func _connect_menu_signals() -> void:
	if not play_button.pressed.is_connected(_on_play_pressed):
		play_button.pressed.connect(_on_play_pressed)
	if not settings_button.pressed.is_connected(_on_settings_pressed):
		settings_button.pressed.connect(_on_settings_pressed)
	if not quit_button.pressed.is_connected(_on_quit_pressed):
		quit_button.pressed.connect(_on_quit_pressed)
	if not close_settings_button.pressed.is_connected(_on_settings_pressed):
		close_settings_button.pressed.connect(_on_settings_pressed)

	for character_index: int in range(character_buttons.size()):
		var target_button: Button = character_buttons[character_index]
		var callback: Callable = _on_character_button_pressed.bind(character_index)
		if not target_button.pressed.is_connected(callback):
			target_button.pressed.connect(callback)

func _setup_lighting_style_options() -> void:
	lighting_style_option.clear()
	for label: String in LIGHTING_STYLE_LABELS:
		lighting_style_option.add_item(label)

func _setup_rain_options() -> void:
	rain_option.clear()
	for label: String in RAIN_OPTION_LABELS:
		rain_option.add_item(label)

func _sync_lighting_style_option() -> void:
	var selected_index: int = 0
	if InputManager != null and InputManager.has_method("get_lighting_style_index"):
		selected_index = int(InputManager.call("get_lighting_style_index"))

	selected_index = clampi(selected_index, 0, max(LIGHTING_STYLE_LABELS.size() - 1, 0))
	lighting_style_option.select(selected_index)
	_apply_lighting_style_preview(selected_index)

func _on_lighting_style_selected(index: int) -> void:
	if index < 0 or index >= LIGHTING_STYLE_LABELS.size():
		return
	if InputManager != null and InputManager.has_method("set_lighting_style_index"):
		InputManager.call("set_lighting_style_index", index)
	_apply_lighting_style_preview(index)
	status_label.text = "Estilo de iluminacao: %s" % LIGHTING_STYLE_LABELS[index]

func _sync_rain_option() -> void:
	var rain_enabled: bool = true
	if InputManager != null and InputManager.has_method("is_rain_enabled"):
		rain_enabled = bool(InputManager.call("is_rain_enabled"))
	rain_option.select(0 if rain_enabled else 1)

func _on_rain_option_selected(index: int) -> void:
	var rain_enabled: bool = index == 0
	if InputManager != null and InputManager.has_method("set_rain_enabled"):
		InputManager.call("set_rain_enabled", rain_enabled)
	_apply_lighting_style_preview(lighting_style_option.get_selected())
	status_label.text = "Chuva: %s" % ("ativada" if rain_enabled else "desativada")

func _setup_lighting_preview() -> void:
	if lighting_preview_container == null or lighting_preview_viewport != null:
		return

	lighting_preview_viewport = SubViewport.new()
	lighting_preview_viewport.disable_3d = false
	lighting_preview_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	lighting_preview_viewport.msaa_3d = Viewport.MSAA_2X
	lighting_preview_viewport.size = Vector2i(420, 180)
	lighting_preview_container.add_child(lighting_preview_viewport)

	var preview_root: Node3D = Node3D.new()
	lighting_preview_viewport.add_child(preview_root)

	var camera: Camera3D = Camera3D.new()
	camera.current = true
	camera.look_at_from_position(Vector3(0.0, 1.25, 3.2), Vector3(0.0, 0.7, 0.0), Vector3.UP)
	preview_root.add_child(camera)

	lighting_preview_world_environment = WorldEnvironment.new()
	lighting_preview_world_environment.environment = Environment.new()
	var environment: Environment = lighting_preview_world_environment.environment
	environment.background_mode = Environment.BG_COLOR
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	preview_root.add_child(lighting_preview_world_environment)

	lighting_preview_sunlight = DirectionalLight3D.new()
	lighting_preview_sunlight.shadow_enabled = false
	preview_root.add_child(lighting_preview_sunlight)

	var floor_mesh: MeshInstance3D = MeshInstance3D.new()
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(5.2, 5.2)
	floor_mesh.mesh = plane
	lighting_preview_floor_material = StandardMaterial3D.new()
	lighting_preview_floor_material.roughness = 0.95
	floor_mesh.material_override = lighting_preview_floor_material
	preview_root.add_child(floor_mesh)

	var subject_mesh: MeshInstance3D = MeshInstance3D.new()
	var capsule: CapsuleMesh = CapsuleMesh.new()
	capsule.radius = 0.3
	capsule.height = 1.45
	subject_mesh.mesh = capsule
	subject_mesh.position = Vector3(0.0, 0.78, 0.0)
	lighting_preview_subject_material = StandardMaterial3D.new()
	lighting_preview_subject_material.roughness = 0.28
	subject_mesh.material_override = lighting_preview_subject_material
	preview_root.add_child(subject_mesh)

	var backdrop: MeshInstance3D = MeshInstance3D.new()
	var backdrop_box: BoxMesh = BoxMesh.new()
	backdrop_box.size = Vector3(4.8, 2.2, 0.2)
	backdrop.mesh = backdrop_box
	backdrop.position = Vector3(0.0, 1.0, -1.9)
	var backdrop_material: StandardMaterial3D = StandardMaterial3D.new()
	backdrop_material.roughness = 0.9
	backdrop_material.albedo_color = Color(0.12, 0.14, 0.18, 1.0)
	backdrop.material_override = backdrop_material
	preview_root.add_child(backdrop)

func _apply_lighting_style_preview(index: int) -> void:
	if lighting_preview_world_environment == null or lighting_preview_sunlight == null:
		return
	if LIGHTING_STYLE_PREVIEW_PRESETS.is_empty():
		return

	var preset_index: int = clampi(index, 0, LIGHTING_STYLE_PREVIEW_PRESETS.size() - 1)
	var preset: Dictionary = LIGHTING_STYLE_PREVIEW_PRESETS[preset_index]
	var environment: Environment = lighting_preview_world_environment.environment
	if environment != null:
		environment.background_color = preset.get("background_color", Color(0.08, 0.1, 0.16, 1.0))
		environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		environment.ambient_light_color = preset.get("ambient_color", Color(0.7, 0.75, 0.82, 1.0))
		environment.ambient_light_energy = float(preset.get("ambient_energy", 0.5))

	lighting_preview_sunlight.light_color = preset.get("sun_color", Color(1.0, 0.97, 0.9, 1.0))
	lighting_preview_sunlight.light_energy = float(preset.get("sun_energy", 1.0))
	lighting_preview_sunlight.rotation_degrees = preset.get("sun_rotation_degrees", Vector3(-52.0, 35.0, 0.0))

	if lighting_preview_floor_material != null:
		lighting_preview_floor_material.albedo_color = preset.get("floor_color", Color(0.2, 0.22, 0.25, 1.0))
	if lighting_preview_subject_material != null:
		lighting_preview_subject_material.albedo_color = preset.get("subject_color", Color(0.87, 0.9, 0.95, 1.0))
	if lighting_preview_desc_label != null:
		var preview_description: String = str(preset.get("description", "Previa em tempo real."))
		lighting_preview_desc_label.text = "%s\nChuva: %s" % [
			preview_description,
			_get_rain_status_label()
		]

func _get_rain_status_label() -> String:
	if InputManager != null and InputManager.has_method("is_rain_enabled"):
		return "ATIVADA" if bool(InputManager.call("is_rain_enabled")) else "DESATIVADA"
	return "ATIVADA"

func _cycle_lighting_style(step: int) -> void:
	var item_count: int = lighting_style_option.get_item_count()
	if item_count <= 0:
		return
	var selected_index: int = lighting_style_option.get_selected()
	selected_index = wrapi(selected_index + step, 0, item_count)
	lighting_style_option.select(selected_index)
	_on_lighting_style_selected(selected_index)

func _adjust_volume_slider(step: float) -> void:
	volume_slider.value = clampf(volume_slider.value + step, volume_slider.min_value, volume_slider.max_value)

func _handle_settings_joypad_input(joypad_event: InputEventJoypadButton) -> void:
	if _is_cancel_button(joypad_event.button_index) or _is_start_button(joypad_event.button_index) or _is_join_button(joypad_event.button_index):
		_on_settings_pressed()
		return
	if joypad_event.button_index == JOY_BUTTON_DPAD_LEFT:
		_cycle_lighting_style(-1)
		return
	if joypad_event.button_index == JOY_BUTTON_DPAD_RIGHT:
		_cycle_lighting_style(1)
		return
	if joypad_event.button_index == JOY_BUTTON_DPAD_UP:
		_adjust_volume_slider(0.05)
		return
	if joypad_event.button_index == JOY_BUTTON_DPAD_DOWN:
		_adjust_volume_slider(-0.05)

func _on_character_button_pressed(character_index: int) -> void:
	if current_state != MenuState.CHARACTER_SELECT:
		return

	character_cursor_index = character_index
	_try_select_current_character()

func _update_lobby_ui() -> void:
	var connected_devices: PackedInt32Array = InputManager.get_connected_devices()
	var joined_players: Array[int] = InputManager.get_joined_devices()
	var ready_players: int = joined_players.size()

	connected_label.text = "CONTROLES %d/%d  //  EQUIPE %d/%d" % [connected_devices.size(), MAX_PLAYERS, ready_players, MAX_PLAYERS]
	play_button.disabled = ready_players < MIN_PLAYERS_TO_START
	play_button.text = "INICIAR ASSALTO"

	for slot_index: int in range(slot_labels.size()):
		if slot_index < ready_players:
			slot_labels[slot_index].text = "OPERADOR %d\n%s\nPRONTO" % [slot_index + 1, _get_device_label(int(joined_players[slot_index]))]
			_apply_lobby_slot_state(slot_index, true)
			continue

		slot_labels[slot_index].text = "OPERADOR %d\nAGUARDANDO CONTROLE\nSTANDBY" % [slot_index + 1]
		_apply_lobby_slot_state(slot_index, false)

	if connected_devices.is_empty():
		status_label.text = "Use E (teclado 1) ou ESPACO (teclado 2) para entrar"
	elif ready_players < MIN_PLAYERS_TO_START:
		status_label.text = "Entre com pelo menos 1 jogador. O policial sera revelado depois."
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
	for decal: Control in menu_decals:
		decal.visible = not is_reveal
	for overlay: Control in terminal_overlays:
		overlay.visible = not is_reveal
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
		current_player_label = "Jogador %d | %s" % [selecting_player_index + 1, _get_device_label(int(joined_players[selecting_player_index]))]

	character_title_label.text = "DOSSIER DO ASSALTO"
	character_turn_label.text = "%s" % current_player_label.to_upper()
	if character_progress_label:
		character_progress_label.text = "SELECAO DE OPERADORES // %d/%d" % [min(selecting_player_index + 1, joined_players.size()), joined_players.size()]
	character_status_label.text = "ESCOLHA UM OPERADOR UNICO PARA A FUGA."

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
	var police_character_id: String = InputManager.get_police_character_id()
	_update_police_reveal_ui(police_character_id, police_character_name)
	status_label.text = "Alarme disparado. Fechando as portas do banco..."
	if InputManager.has_method("clear_pressed_buttons"):
		InputManager.clear_pressed_buttons()
	_set_menu_state(MenuState.POLICE_REVEAL)
	await get_tree().create_timer(2.2).timeout
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _apply_visual_style() -> void:
	_add_background()
	_add_heist_decals()
	_add_terminal_overlays()
	_build_lobby_slot_cards()
	_build_character_selection_header()
	_build_character_cards()
	_build_police_reveal_layout()
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
	reveal_panel.z_index = 100
	reveal_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_style_button(play_button, COLOR_GOLD, Color(1.0, 0.78, 0.26, 1.0), true)
	_style_button(settings_button, COLOR_GREEN, COLOR_GREEN_HIGHLIGHT, false)
	_style_button(quit_button, COLOR_RED, COLOR_ORANGE, false)
	_style_button(close_settings_button, COLOR_RED, COLOR_ORANGE, false)
	play_button.text = "INICIAR ASSALTO"
	settings_button.text = "CONFIGURACOES"
	quit_button.text = "SAIR"
	close_settings_button.text = "FECHAR CONFIGURACOES"
	play_button.icon = ICON_PLAY
	settings_button.icon = ICON_REPEAT
	for character_button: Button in character_buttons:
		_style_character_button(character_button, COLOR_BORDER, false, false)
	_style_slider(volume_slider)
	_connect_button_feedback()

	title_label.text = "TIME TO RUSH"
	title_label.add_theme_font_override("font", FONT_ARCADE)
	title_label.add_theme_color_override("font_color", COLOR_GREEN_HIGHLIGHT)
	title_label.add_theme_color_override("font_shadow_color", Color(COLOR_GREEN_HIGHLIGHT.r, COLOR_GREEN_HIGHLIGHT.g, COLOR_GREEN_HIGHLIGHT.b, 0.88))
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
	join_hint_label.text = "E (WASD) ENTRA  //  ESPACO (SETAS) ENTRA"
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
	reveal_title_label.add_theme_color_override("font_shadow_color", Color(COLOR_RED.r, COLOR_RED.g, COLOR_RED.b, 0.75))
	reveal_title_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.82))
	reveal_title_label.add_theme_constant_override("outline_size", 7)
	reveal_label.add_theme_color_override("font_color", COLOR_RED)
	reveal_label.add_theme_font_override("font", FONT_ARCADE)
	reveal_label.add_theme_color_override("font_shadow_color", Color(COLOR_RED.r, COLOR_RED.g, COLOR_RED.b, 0.7))
	reveal_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.9))
	reveal_label.add_theme_constant_override("outline_size", 10)

	for label: Label in slot_labels:
		label.add_theme_color_override("font_color", COLOR_TEXT)
		label.add_theme_font_override("font", FONT_UI)
		label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.7))
		label.add_theme_constant_override("outline_size", 3)
		label.add_theme_font_size_override("font_size", 20)
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	_style_settings_labels()
	call_deferred("_prime_menu_layout")

func _create_controller_prompt_strips() -> void:
	if lobby_prompt_strip == null:
		lobby_prompt_strip = ControllerPromptStrip.new()
		lobby_prompt_strip.name = "LobbyControllerPrompts"
		lobby_prompt_strip.set_prompts([
			{"prompt": "confirm", "text": "entrar"},
			{"prompt": "start", "text": "iniciar"},
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
		reveal_column.add_child(reveal_prompt_strip)

func _build_police_reveal_layout() -> void:
	if reveal_dossier_panel != null:
		return

	reveal_column.alignment = BoxContainer.ALIGNMENT_CENTER
	reveal_column.add_theme_constant_override("separation", 16)

	var top_status: Label = _make_card_label("T2R // TIME TO RUSH      COFRE CENTRAL      SISTEMA: ONLINE  |  COFRE: TRANCADO  |  ALARMES: ATIVO", 13, COLOR_GREEN_HIGHLIGHT, HORIZONTAL_ALIGNMENT_CENTER)
	top_status.name = "RevealTopStatus"
	reveal_column.add_child(top_status)
	reveal_column.move_child(top_status, 0)

	var alarm_panel: PanelContainer = PanelContainer.new()
	alarm_panel.name = "AlarmPanel"
	alarm_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	alarm_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	alarm_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	alarm_panel.add_theme_stylebox_override("panel", _make_alarm_panel_style(COLOR_RED))
	reveal_column.add_child(alarm_panel)
	reveal_column.move_child(alarm_panel, 1)

	var alarm_margin: MarginContainer = MarginContainer.new()
	alarm_margin.name = "AlarmMargin"
	alarm_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	alarm_margin.add_theme_constant_override("margin_left", 24)
	alarm_margin.add_theme_constant_override("margin_top", 20)
	alarm_margin.add_theme_constant_override("margin_right", 24)
	alarm_margin.add_theme_constant_override("margin_bottom", 20)
	alarm_panel.add_child(alarm_margin)

	var alarm_row: HBoxContainer = HBoxContainer.new()
	alarm_row.name = "AlarmRow"
	alarm_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	alarm_row.add_theme_constant_override("separation", 28)
	alarm_margin.add_child(alarm_row)

	reveal_dossier_panel = PanelContainer.new()
	reveal_dossier_panel.name = "CharacterDossier"
	reveal_dossier_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reveal_dossier_panel.custom_minimum_size = Vector2(250.0, 0.0)
	reveal_dossier_panel.add_theme_stylebox_override("panel", _make_alarm_dossier_style(COLOR_RED))
	alarm_row.add_child(reveal_dossier_panel)

	var dossier_margin: MarginContainer = MarginContainer.new()
	dossier_margin.name = "DossierMargin"
	dossier_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dossier_margin.add_theme_constant_override("margin_left", 14)
	dossier_margin.add_theme_constant_override("margin_top", 12)
	dossier_margin.add_theme_constant_override("margin_right", 14)
	dossier_margin.add_theme_constant_override("margin_bottom", 12)
	reveal_dossier_panel.add_child(dossier_margin)

	var dossier_column: VBoxContainer = VBoxContainer.new()
	dossier_column.name = "DossierColumn"
	dossier_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dossier_column.add_theme_constant_override("separation", 6)
	dossier_margin.add_child(dossier_column)

	reveal_dossier_title_label = _make_card_label("DOSSIER // 00", 12, COLOR_RED, HORIZONTAL_ALIGNMENT_LEFT)
	dossier_column.add_child(reveal_dossier_title_label)

	var preview_panel: Panel = Panel.new()
	preview_panel.name = "RevealPreviewPanel"
	preview_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_panel.custom_minimum_size = Vector2(0.0, 190.0)
	preview_panel.add_theme_stylebox_override("panel", _make_portrait_style(COLOR_RED, true))
	dossier_column.add_child(preview_panel)
	_add_portrait_backplate(preview_panel, COLOR_RED)

	reveal_character_preview = TextureRect.new()
	reveal_character_preview.name = "PoliceCharacterPreview"
	reveal_character_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reveal_character_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	reveal_character_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	reveal_character_preview.set_anchors_preset(Control.PRESET_FULL_RECT)
	reveal_character_preview.offset_left = 4.0
	reveal_character_preview.offset_top = -4.0
	reveal_character_preview.offset_right = -4.0
	reveal_character_preview.offset_bottom = -4.0
	preview_panel.add_child(reveal_character_preview)

	reveal_dossier_name_label = _make_card_label("POLICIAL", 24, COLOR_RED, HORIZONTAL_ALIGNMENT_CENTER)
	dossier_column.add_child(reveal_dossier_name_label)

	reveal_dossier_role_label = _make_card_label("OPERADOR POLICIAL\nFUNCAO: CACADOR\nCOMBATE E PERSEGUICAO", 11, COLOR_TEXT, HORIZONTAL_ALIGNMENT_LEFT)
	dossier_column.add_child(reveal_dossier_role_label)

	var message_column: VBoxContainer = VBoxContainer.new()
	message_column.name = "RevealMessageColumn"
	message_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	message_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	message_column.alignment = BoxContainer.ALIGNMENT_CENTER
	message_column.add_theme_constant_override("separation", 18)
	alarm_row.add_child(message_column)

	reveal_title_label.get_parent().remove_child(reveal_title_label)
	message_column.add_child(reveal_title_label)
	reveal_label.get_parent().remove_child(reveal_label)
	message_column.add_child(reveal_label)

	reveal_support_label = _make_card_label("PREPAREM A FUGA", 30, COLOR_GREEN_HIGHLIGHT, HORIZONTAL_ALIGNMENT_CENTER)
	message_column.add_child(reveal_support_label)

	reveal_status_label = _make_card_label("RODADA INICIANDO...", 16, COLOR_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	message_column.add_child(reveal_status_label)

	reveal_bottom_label = _make_card_label("! O SISTEMA DE SEGURANCA ACIONOU UM NOVO POLICIAL !", 15, COLOR_RED, HORIZONTAL_ALIGNMENT_CENTER)
	reveal_bottom_label.name = "RevealBottomStatus"
	reveal_column.add_child(reveal_bottom_label)

func _build_character_selection_header() -> void:
	if character_progress_label == null:
		character_progress_label = _make_card_label("SELECAO DE OPERADORES // 1/4", 15, COLOR_GREEN_HIGHLIGHT, HORIZONTAL_ALIGNMENT_LEFT)
		character_progress_label.name = "CharacterProgressLabel"
		character_column.add_child(character_progress_label)
		character_column.move_child(character_progress_label, character_turn_label.get_index() + 1)

	if character_operation_label == null:
		character_operation_label = _make_card_label("T2R // TIME TO RUSH\nOPERACAO: QUEBRA DE BANCO\nNIVEL DE ALERTA", 12, COLOR_GREEN_HIGHLIGHT, HORIZONTAL_ALIGNMENT_RIGHT)
		character_operation_label.name = "CharacterOperationLabel"
		character_operation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		character_column.add_child(character_operation_label)
		character_column.move_child(character_operation_label, character_progress_label.get_index() + 1)

func _build_lobby_slot_cards() -> void:
	if not lobby_slot_cards.is_empty():
		return

	for slot_index: int in range(slot_labels.size()):
		var slot_label: Label = slot_labels[slot_index]
		var original_parent: Node = slot_label.get_parent()
		if original_parent == null:
			continue

		var original_index: int = slot_label.get_index()
		original_parent.remove_child(slot_label)

		var card: PanelContainer = PanelContainer.new()
		card.name = "OperatorCard%02d" % [slot_index + 1]
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.custom_minimum_size = Vector2(0.0, 104.0)
		original_parent.add_child(card)
		original_parent.move_child(card, original_index)
		lobby_slot_cards.append(card)

		var row: HBoxContainer = HBoxContainer.new()
		row.name = "OperatorRow"
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 14)
		card.add_child(row)

		var number_label: Label = _make_card_label("%02d" % [slot_index + 1], 24, COLOR_GOLD, HORIZONTAL_ALIGNMENT_CENTER)
		number_label.name = "OperatorNumber"
		number_label.custom_minimum_size = Vector2(54.0, 0.0)
		number_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(number_label)
		lobby_slot_numbers.append(number_label)

		var dossier_panel: Panel = _make_lobby_dossier_panel()
		row.add_child(dossier_panel)

		slot_label.name = "OperatorInfo"
		slot_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		slot_label.clip_text = true
		row.add_child(slot_label)

		var icon_label: Label = _make_card_label("", 26, COLOR_GREEN_HIGHLIGHT, HORIZONTAL_ALIGNMENT_CENTER)
		icon_label.name = "OperatorStateIcon"
		icon_label.custom_minimum_size = Vector2(88.0, 0.0)
		icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(icon_label)
		lobby_slot_icons.append(icon_label)

func _make_lobby_dossier_panel() -> Panel:
	var panel: Panel = Panel.new()
	panel.name = "DossierPortrait"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.custom_minimum_size = Vector2(128.0, 76.0)
	panel.add_theme_stylebox_override("panel", _make_lobby_dossier_style(COLOR_GREEN_HIGHLIGHT, false))

	var head: ColorRect = _make_portrait_rect(Color(COLOR_GREEN_HIGHLIGHT.r, COLOR_GREEN_HIGHLIGHT.g, COLOR_GREEN_HIGHLIGHT.b, 0.62), Vector2(0.18, 0.18), Vector2(0.22, 0.28))
	panel.add_child(head)

	var body: ColorRect = _make_portrait_rect(Color(COLOR_GREEN_HIGHLIGHT.r, COLOR_GREEN_HIGHLIGHT.g, COLOR_GREEN_HIGHLIGHT.b, 0.42), Vector2(0.12, 0.5), Vector2(0.34, 0.32))
	panel.add_child(body)

	for line_index: int in range(4):
		var line_rect: ColorRect = _make_portrait_rect(Color(COLOR_GOLD.r, COLOR_GOLD.g, COLOR_GOLD.b, 0.62), Vector2(0.54, 0.22 + float(line_index) * 0.13), Vector2(0.32, 0.035))
		panel.add_child(line_rect)

	return panel

func _apply_lobby_slot_state(slot_index: int, is_ready: bool) -> void:
	if slot_index >= lobby_slot_cards.size():
		return

	var accent: Color = COLOR_GREEN_HIGHLIGHT if is_ready else COLOR_GOLD
	lobby_slot_cards[slot_index].add_theme_stylebox_override("panel", _make_lobby_slot_style(accent, is_ready))

	if slot_index < lobby_slot_numbers.size():
		lobby_slot_numbers[slot_index].add_theme_color_override("font_color", accent)
	if slot_index < lobby_slot_icons.size():
		lobby_slot_icons[slot_index].text = "CHECK" if is_ready else "PAD"
		lobby_slot_icons[slot_index].add_theme_color_override("font_color", accent if is_ready else Color(COLOR_GOLD.r, COLOR_GOLD.g, COLOR_GOLD.b, 0.78))
	if slot_index < slot_labels.size():
		slot_labels[slot_index].add_theme_color_override("font_color", COLOR_GREEN_HIGHLIGHT if is_ready else Color(0.78, 0.75, 0.62, 1.0))

func _make_lobby_slot_style(accent: Color, is_ready: bool) -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color(0.008, 0.02, 0.012, 0.94) if is_ready else Color(0.018, 0.018, 0.012, 0.76)
	style_box.border_color = Color(accent.r, accent.g, accent.b, 0.88 if is_ready else 0.58)
	style_box.set_border_width_all(3 if is_ready else 2)
	style_box.corner_radius_top_left = 4
	style_box.corner_radius_top_right = 4
	style_box.corner_radius_bottom_right = 4
	style_box.corner_radius_bottom_left = 4
	style_box.shadow_color = Color(accent.r, accent.g, accent.b, 0.28 if is_ready else 0.12)
	style_box.shadow_size = 16 if is_ready else 5
	style_box.content_margin_left = 14
	style_box.content_margin_right = 14
	style_box.content_margin_top = 10
	style_box.content_margin_bottom = 10
	return style_box

func _make_lobby_dossier_style(accent: Color, is_dim: bool) -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color(0.02, 0.055, 0.035, 0.84) if not is_dim else Color(0.018, 0.018, 0.018, 0.62)
	style_box.border_color = Color(accent.r, accent.g, accent.b, 0.72)
	style_box.set_border_width_all(2)
	style_box.corner_radius_top_left = 2
	style_box.corner_radius_top_right = 2
	style_box.corner_radius_bottom_right = 2
	style_box.corner_radius_bottom_left = 2
	return style_box

func _update_police_reveal_ui(character_id: String, character_name: String) -> void:
	var display_name: String = character_name.to_upper()
	if display_name.is_empty():
		display_name = "POLICIAL"
	var accent: Color = _get_character_accent(character_id)
	var dossier_number: int = max(CHARACTER_IDS.find(character_id) + 1, 0)

	reveal_title_label.text = "ALARME DO BANCO"
	reveal_label.text = "%s VIROU\nPOLICIAL" % display_name
	reveal_label.add_theme_color_override("font_color", COLOR_RED)
	reveal_label.add_theme_color_override("font_shadow_color", Color(COLOR_RED.r, COLOR_RED.g, COLOR_RED.b, 0.8))

	if reveal_support_label:
		reveal_support_label.text = "PREPAREM A FUGA"
	if reveal_status_label:
		reveal_status_label.text = "RODADA INICIANDO..."
	if reveal_bottom_label:
		reveal_bottom_label.text = "! O SISTEMA DE SEGURANCA ACIONOU %s COMO POLICIAL !" % display_name

	if reveal_dossier_title_label:
		reveal_dossier_title_label.text = "DOSSIER // %02d" % dossier_number
		reveal_dossier_title_label.add_theme_color_override("font_color", accent.lightened(0.15))
	if reveal_dossier_name_label:
		reveal_dossier_name_label.text = display_name
		reveal_dossier_name_label.add_theme_color_override("font_color", accent.lightened(0.18))
	if reveal_dossier_role_label:
		reveal_dossier_role_label.add_theme_color_override("font_color", COLOR_TEXT)
	if reveal_dossier_panel:
		reveal_dossier_panel.add_theme_stylebox_override("panel", _make_alarm_dossier_style(accent))
	if reveal_character_preview:
		reveal_character_preview.texture = CHARACTER_PORTRAITS.get(character_id, null) as Texture2D

func _get_character_accent(character_id: String) -> Color:
	if CHARACTER_CARD_DATA.has(character_id):
		var data: Dictionary = CHARACTER_CARD_DATA[character_id] as Dictionary
		return data["color"] as Color
	return COLOR_RED

func _make_alarm_panel_style(accent: Color) -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color(0.035, 0.004, 0.004, 0.96)
	style_box.border_color = Color(accent.r, accent.g, accent.b, 0.95)
	style_box.set_border_width_all(5)
	style_box.corner_radius_top_left = 5
	style_box.corner_radius_top_right = 5
	style_box.corner_radius_bottom_right = 5
	style_box.corner_radius_bottom_left = 5
	style_box.shadow_color = Color(accent.r, accent.g, accent.b, 0.42)
	style_box.shadow_size = 34
	style_box.content_margin_left = 8
	style_box.content_margin_right = 8
	style_box.content_margin_top = 8
	style_box.content_margin_bottom = 8
	return style_box

func _make_alarm_dossier_style(accent: Color) -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color(0.038 + accent.r * 0.025, 0.006 + accent.g * 0.015, 0.006 + accent.b * 0.015, 0.94)
	style_box.border_color = Color(accent.r, accent.g, accent.b, 0.86)
	style_box.set_border_width_all(3)
	style_box.corner_radius_top_left = 4
	style_box.corner_radius_top_right = 4
	style_box.corner_radius_bottom_right = 4
	style_box.corner_radius_bottom_left = 4
	style_box.shadow_color = Color(accent.r, accent.g, accent.b, 0.2)
	style_box.shadow_size = 14
	style_box.content_margin_left = 10
	style_box.content_margin_right = 10
	style_box.content_margin_top = 10
	style_box.content_margin_bottom = 10
	return style_box

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
	var card_width: float = 174.0 if is_compact else (236.0 if is_large else 208.0)
	var card_height: float = 384.0 if is_compact else (520.0 if is_large else 460.0)
	var portrait_height: float = 142.0 if is_compact else (222.0 if is_large else 190.0)
	var card_title_size: int = 19 if is_compact else (28 if is_large else 24)
	var card_role_size: int = 12 if is_compact else (16 if is_large else 14)
	var card_text_size: int = 10 if is_compact else (14 if is_large else 12)

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
	if character_progress_label:
		character_progress_label.add_theme_font_size_override("font_size", 12 if is_compact else (17 if is_large else 14))
	if character_operation_label:
		character_operation_label.add_theme_font_size_override("font_size", 9 if is_compact else (13 if is_large else 11))
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
		label.add_theme_font_size_override("font_size", 14 if is_compact else (20 if is_large else 17))

	for card: PanelContainer in lobby_slot_cards:
		card.custom_minimum_size = Vector2(0.0, 78.0 if is_compact else (108.0 if is_large else 92.0))
	for label: Label in lobby_slot_numbers:
		label.add_theme_font_size_override("font_size", 19 if is_compact else (27 if is_large else 23))
	for label: Label in lobby_slot_icons:
		label.add_theme_font_size_override("font_size", 16 if is_compact else (24 if is_large else 20))

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
		if character_focus_labels.size() > character_index:
			character_focus_labels[character_index].add_theme_font_size_override("font_size", 9 if is_compact else (12 if is_large else 10))
		if character_code_labels.size() > character_index:
			character_code_labels[character_index].add_theme_font_size_override("font_size", 8 if is_compact else (11 if is_large else 9))
		if character_portrait_panels.size() > character_index:
			character_portrait_panels[character_index].custom_minimum_size = Vector2(0.0, portrait_height)

	reveal_panel.anchor_left = 0.0
	reveal_panel.anchor_top = 0.0
	reveal_panel.anchor_right = 1.0
	reveal_panel.anchor_bottom = 1.0
	reveal_panel.offset_left = 0.0
	reveal_panel.offset_top = 0.0
	reveal_panel.offset_right = 0.0
	reveal_panel.offset_bottom = 0.0
	reveal_title_label.add_theme_font_size_override("font_size", 25 if is_compact else (38 if is_large else 32))
	reveal_label.add_theme_font_size_override("font_size", 42 if is_compact else (76 if is_large else 62))
	if reveal_support_label:
		reveal_support_label.add_theme_font_size_override("font_size", 23 if is_compact else (34 if is_large else 30))
	if reveal_status_label:
		reveal_status_label.add_theme_font_size_override("font_size", 13 if is_compact else (18 if is_large else 16))
	if reveal_dossier_title_label:
		reveal_dossier_title_label.add_theme_font_size_override("font_size", 10 if is_compact else (14 if is_large else 12))
	if reveal_dossier_name_label:
		reveal_dossier_name_label.add_theme_font_size_override("font_size", 18 if is_compact else (28 if is_large else 24))
	if reveal_dossier_role_label:
		reveal_dossier_role_label.add_theme_font_size_override("font_size", 9 if is_compact else (13 if is_large else 11))
	if reveal_bottom_label:
		reveal_bottom_label.add_theme_font_size_override("font_size", 11 if is_compact else (16 if is_large else 14))
	if reveal_dossier_panel:
		reveal_dossier_panel.custom_minimum_size = Vector2(205.0 if is_compact else (280.0 if is_large else 250.0), 0.0)
	var reveal_style: StyleBoxFlat = reveal_panel.get_theme_stylebox("panel") as StyleBoxFlat
	if reveal_style:
		reveal_style.content_margin_left = 52 if is_compact else (126 if is_large else 92)
		reveal_style.content_margin_right = 52 if is_compact else (126 if is_large else 92)
		reveal_style.content_margin_top = 38 if is_compact else (84 if is_large else 64)
		reveal_style.content_margin_bottom = 34 if is_compact else (72 if is_large else 52)
	settings_panel.offset_left = -220.0 if is_compact else -260.0
	settings_panel.offset_top = -240.0 if is_compact else -280.0
	settings_panel.offset_right = 220.0 if is_compact else 260.0
	settings_panel.offset_bottom = 240.0 if is_compact else 280.0
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

	var cash_trail: HeistIcon = _make_screen_decal(HeistIcon.IconType.CASH_TRAIL, Vector2(0.0, 0.76), Vector2(1.0, 0.16), COLOR_GREEN_HIGHLIGHT, 0.72)
	cash_trail.name = "MenuCashTrail"
	menu_decals.append(cash_trail)

	var vault_icon: HeistIcon = _make_screen_decal(HeistIcon.IconType.VAULT, Vector2(0.865, 0.2), Vector2(0.16, 0.42), COLOR_GOLD, 0.86)
	vault_icon.name = "MenuVaultIcon"
	menu_decals.append(vault_icon)

	var alarm_icon: HeistIcon = _make_screen_decal(HeistIcon.IconType.ALARM, Vector2(0.018, 0.065), Vector2(0.085, 0.15), COLOR_RED, 0.92)
	alarm_icon.name = "MenuAlarmIcon"
	menu_decals.append(alarm_icon)

	var bag_icon: HeistIcon = _make_screen_decal(HeistIcon.IconType.MONEY_BAG, Vector2(0.02, 0.71), Vector2(0.14, 0.21), COLOR_GREEN_HIGHLIGHT, 0.9)
	bag_icon.name = "MenuMoneyBagIcon"
	menu_decals.append(bag_icon)

	menu_decals.append(_make_screen_label("ALERTA", Vector2(0.012, 0.205), Vector2(0.1, 0.052), COLOR_RED))
	menu_decals.append(_make_screen_label("SEGURANCA", Vector2(0.025, 0.35), Vector2(0.12, 0.052), COLOR_MUTED))
	menu_decals.append(_make_screen_label("ACESSO AUTORIZADO", Vector2(0.02, 0.59), Vector2(0.15, 0.052), COLOR_GREEN_HIGHLIGHT))
	menu_decals.append(_make_screen_label("NIVEL B1", Vector2(0.905, 0.165), Vector2(0.085, 0.052), COLOR_GOLD))
	menu_decals.append(_make_screen_label("DINHEIRO SEGURO", Vector2(0.875, 0.73), Vector2(0.11, 0.052), COLOR_GOLD))

func _add_terminal_overlays() -> void:
	if not terminal_overlays.is_empty():
		return

	var outer_frame: Panel = _make_terminal_panel("OuterMetalFrame", Vector2(0.006, 0.028), Vector2(0.988, 0.935), Color(0.018, 0.021, 0.019, 0.9), COLOR_BORDER, 4, 30)
	terminal_overlays.append(outer_frame)

	var menu_crt_frame: Panel = _make_terminal_panel("LeftCrtHousing", Vector2(0.014, 0.04), Vector2(0.525, 0.91), Color(0.01, 0.018, 0.012, 0.72), COLOR_GOLD, 3, 26)
	terminal_overlays.append(menu_crt_frame)

	var lobby_housing: Panel = _make_terminal_panel("RightLobbyHousing", Vector2(0.555, 0.04), Vector2(0.43, 0.91), Color(0.008, 0.02, 0.013, 0.72), COLOR_GREEN_HIGHLIGHT, 3, 26)
	terminal_overlays.append(lobby_housing)

	var menu_inner_glow: Panel = _make_terminal_panel("LeftInnerGreenBezel", Vector2(0.048, 0.07), Vector2(0.455, 0.77), Color(0.0, 0.05, 0.018, 0.28), COLOR_GREEN_HIGHLIGHT, 2, 18)
	terminal_overlays.append(menu_inner_glow)

	var lobby_inner_glow: Panel = _make_terminal_panel("RightInnerGreenBezel", Vector2(0.585, 0.075), Vector2(0.365, 0.75), Color(0.0, 0.035, 0.016, 0.28), COLOR_GREEN_HIGHLIGHT, 2, 18)
	terminal_overlays.append(lobby_inner_glow)

	_add_terminal_screws()
	_add_terminal_side_panels()

	var scanline_overlay: Control = Control.new()
	scanline_overlay.name = "TerminalScanlines"
	scanline_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scanline_overlay.anchor_left = 0.13
	scanline_overlay.anchor_top = 0.07
	scanline_overlay.anchor_right = 0.49
	scanline_overlay.anchor_bottom = 0.87
	scanline_overlay.offset_left = 0.0
	scanline_overlay.offset_top = 0.0
	scanline_overlay.offset_right = 0.0
	scanline_overlay.offset_bottom = 0.0
	add_child(scanline_overlay)
	move_child(scanline_overlay, 3)
	terminal_overlays.append(scanline_overlay)

	for line_index: int in range(22):
		var line: ColorRect = ColorRect.new()
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.color = Color(0.16, 0.95, 0.23, 0.072)
		line.anchor_left = 0.0
		line.anchor_right = 1.0
		line.anchor_top = float(line_index) / 22.0
		line.anchor_bottom = line.anchor_top
		line.offset_left = 0.0
		line.offset_right = 0.0
		line.offset_top = 0.0
		line.offset_bottom = 2.0
		scanline_overlay.add_child(line)

	var metal_top: ColorRect = _make_terminal_plate(Vector2(0.0, 0.0), Vector2(1.0, 0.032), Color(0.06, 0.07, 0.066, 0.98), COLOR_BORDER)
	metal_top.name = "TopMetalPlate"
	terminal_overlays.append(metal_top)

	var metal_bottom: ColorRect = _make_terminal_plate(Vector2(0.0, 0.945), Vector2(1.0, 0.055), Color(0.035, 0.04, 0.038, 0.98), COLOR_BORDER)
	metal_bottom.name = "BottomMetalPlate"
	terminal_overlays.append(metal_bottom)

	var left_rail: ColorRect = _make_terminal_plate(Vector2(0.0, 0.032), Vector2(0.11, 0.913), Color(0.018, 0.022, 0.021, 0.82), COLOR_GREEN)
	left_rail.name = "SecuritySideRail"
	terminal_overlays.append(left_rail)

	var center_glow: ColorRect = _make_terminal_plate(Vector2(0.53, 0.0), Vector2(0.035, 1.0), Color(COLOR_GOLD.r, COLOR_GOLD.g, COLOR_GOLD.b, 0.06), COLOR_GOLD)
	center_glow.name = "CenterWarmGlow"
	terminal_overlays.append(center_glow)

func _make_terminal_panel(name: String, anchor_position: Vector2, anchor_size: Vector2, fill: Color, border: Color, border_width: int, shadow_size: int) -> Panel:
	var panel: Panel = Panel.new()
	panel.name = name
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.anchor_left = anchor_position.x
	panel.anchor_top = anchor_position.y
	panel.anchor_right = anchor_position.x + anchor_size.x
	panel.anchor_bottom = anchor_position.y + anchor_size.y
	panel.offset_left = 0.0
	panel.offset_top = 0.0
	panel.offset_right = 0.0
	panel.offset_bottom = 0.0
	panel.add_theme_stylebox_override("panel", _make_terminal_panel_style(fill, border, border_width, shadow_size))
	add_child(panel)
	move_child(panel, 1)
	return panel

func _make_terminal_panel_style(fill: Color, border: Color, border_width: int, shadow_size: int) -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = fill
	style_box.border_color = Color(border.r, border.g, border.b, 0.64)
	style_box.set_border_width_all(border_width)
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.shadow_color = Color(border.r, border.g, border.b, 0.16)
	style_box.shadow_size = shadow_size
	return style_box

func _add_terminal_screws() -> void:
	var screw_positions: Array[Vector2] = [
		Vector2(0.023, 0.054),
		Vector2(0.518, 0.054),
		Vector2(0.023, 0.92),
		Vector2(0.518, 0.92),
		Vector2(0.57, 0.054),
		Vector2(0.965, 0.054),
		Vector2(0.57, 0.92),
		Vector2(0.965, 0.92),
	]
	for screw_index: int in range(screw_positions.size()):
		var screw: Panel = _make_terminal_panel("TerminalScrew%02d" % screw_index, screw_positions[screw_index], Vector2(0.014, 0.024), Color(0.025, 0.028, 0.026, 0.95), COLOR_GOLD, 2, 6)
		terminal_overlays.append(screw)

func _add_terminal_side_panels() -> void:
	var warning_panel: Panel = _make_terminal_panel("RightWarningPlate", Vector2(0.965, 0.07), Vector2(0.03, 0.085), Color(0.035, 0.033, 0.026, 0.78), COLOR_GOLD, 2, 8)
	terminal_overlays.append(warning_panel)
	menu_decals.append(_make_screen_label("!", Vector2(0.965, 0.078), Vector2(0.03, 0.055), COLOR_GOLD))

	var level_panel: Panel = _make_terminal_panel("RightLevelPlate", Vector2(0.955, 0.185), Vector2(0.04, 0.085), Color(0.035, 0.031, 0.02, 0.76), COLOR_GOLD, 2, 8)
	terminal_overlays.append(level_panel)

	var safe_box: Panel = _make_terminal_panel("RightMoneySafe", Vector2(0.905, 0.755), Vector2(0.075, 0.13), Color(0.04, 0.039, 0.031, 0.86), COLOR_GOLD, 2, 12)
	terminal_overlays.append(safe_box)

	var fingerprint_panel: Panel = _make_terminal_panel("LeftFingerprintPanel", Vector2(0.018, 0.565), Vector2(0.09, 0.16), Color(0.008, 0.028, 0.014, 0.78), COLOR_GREEN_HIGHLIGHT, 2, 12)
	terminal_overlays.append(fingerprint_panel)
	_add_fingerprint_lines(Vector2(0.04, 0.632), Vector2(0.04, 0.065))

func _add_fingerprint_lines(anchor_position: Vector2, anchor_size: Vector2) -> void:
	for line_index: int in range(5):
		var line: ColorRect = _make_terminal_plate(
			Vector2(anchor_position.x + float(line_index) * anchor_size.x * 0.08, anchor_position.y + float(line_index) * anchor_size.y * 0.08),
			Vector2(anchor_size.x - float(line_index) * anchor_size.x * 0.12, 0.004),
			Color(COLOR_GREEN_HIGHLIGHT.r, COLOR_GREEN_HIGHLIGHT.g, COLOR_GREEN_HIGHLIGHT.b, 0.54),
			COLOR_GREEN_HIGHLIGHT
		)
		line.name = "FingerprintLine%02d" % line_index
		terminal_overlays.append(line)

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

func _make_terminal_plate(anchor_position: Vector2, anchor_size: Vector2, color: Color, _border_color: Color) -> ColorRect:
	var plate: ColorRect = ColorRect.new()
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.color = color
	plate.anchor_left = anchor_position.x
	plate.anchor_top = anchor_position.y
	plate.anchor_right = anchor_position.x + anchor_size.x
	plate.anchor_bottom = anchor_position.y + anchor_size.y
	plate.offset_left = 0.0
	plate.offset_top = 0.0
	plate.offset_right = 0.0
	plate.offset_bottom = 0.0
	add_child(plate)
	move_child(plate, 1)
	return plate

func _style_panel(panel: PanelContainer, accent: Color) -> void:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color(0.012, 0.014, 0.012, 0.95)
	if panel == menu_panel:
		style_box.bg_color = Color(0.005, 0.03, 0.012, 0.93)
	if panel == lobby_panel:
		style_box.bg_color = Color(0.007, 0.022, 0.014, 0.95)
	if panel == character_panel:
		style_box.bg_color = Color(0.006, 0.008, 0.006, 0.96)
	if panel == reveal_panel:
		style_box.bg_color = Color(0.004, 0.006, 0.004, 0.985)
		style_box.border_color = Color(COLOR_RED.r, COLOR_RED.g, COLOR_RED.b, 0.22)
		style_box.set_border_width_all(0)
		style_box.shadow_size = 0
		style_box.content_margin_left = 110
		style_box.content_margin_right = 110
		style_box.content_margin_top = 74
		style_box.content_margin_bottom = 60
		panel.add_theme_stylebox_override("panel", style_box)
		return
	style_box.border_color = Color(accent.r, accent.g, accent.b, 0.9)
	style_box.set_border_width_all(4 if panel == menu_panel or panel == lobby_panel else 3)
	style_box.corner_radius_top_left = 6
	style_box.corner_radius_top_right = 6
	style_box.corner_radius_bottom_right = 6
	style_box.corner_radius_bottom_left = 6
	style_box.shadow_color = Color(accent.r, accent.g, accent.b, 0.26)
	style_box.shadow_size = 34 if panel == menu_panel or panel == lobby_panel else 26
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
	character_focus_labels.clear()
	character_code_labels.clear()

	for character_index: int in range(character_buttons.size()):
		var button: Button = character_buttons[character_index]
		var character_id: String = CHARACTER_IDS[character_index]
		var data: Dictionary = CHARACTER_CARD_DATA[character_id] as Dictionary
		var accent: Color = data["color"] as Color
		button.text = ""
		button.custom_minimum_size = Vector2(188.0, 410.0)
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
		column.add_theme_constant_override("separation", 5)
		margin.add_child(column)

		var focus_label: Label = _make_card_label("> EM FOCO <", 11, COLOR_BLACK, HORIZONTAL_ALIGNMENT_CENTER)
		focus_label.name = "FocusStamp"
		focus_label.visible = false
		focus_label.add_theme_stylebox_override("normal", _make_label_chip_style(COLOR_GOLD, COLOR_GOLD))
		column.add_child(focus_label)
		character_focus_labels.append(focus_label)

		var name_label: Label = _make_card_label(str(data["name"]), 26, accent.lightened(0.16), HORIZONTAL_ALIGNMENT_CENTER)
		column.add_child(name_label)
		character_name_labels.append(name_label)

		var dossier_strip: Label = _make_card_label("DOSSIER // %02d        ||||||" % [character_index + 1], 11, accent.lightened(0.2), HORIZONTAL_ALIGNMENT_CENTER)
		column.add_child(dossier_strip)

		var portrait: Panel = Panel.new()
		portrait.name = "Portrait"
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		portrait.custom_minimum_size = Vector2(0.0, 174.0)
		portrait.add_theme_stylebox_override("panel", _make_portrait_style(accent, false))
		column.add_child(portrait)
		character_portrait_panels.append(portrait)

		_add_portrait_backplate(portrait, accent)
		_add_character_portrait_image(portrait, character_id)
		_add_card_heist_icon(portrait, character_id)

		var divider: TextureRect = TextureRect.new()
		divider.name = "CardDivider"
		divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
		divider.texture = CARD_DIVIDER
		divider.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		divider.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		divider.custom_minimum_size = Vector2(0.0, 7.0)
		column.add_child(divider)

		var role_title: Label = _make_card_label("FUNCAO", 9, COLOR_MUTED, HORIZONTAL_ALIGNMENT_CENTER)
		column.add_child(role_title)

		var role_label: Label = _make_card_label(str(data["role"]), 17, accent.lightened(0.12), HORIZONTAL_ALIGNMENT_CENTER)
		column.add_child(role_label)
		character_role_labels.append(role_label)

		var skill_label: Label = _make_card_label("HABILIDADE\n%s" % str(data["skill"]).to_upper(), 12, accent.lightened(0.24), HORIZONTAL_ALIGNMENT_CENTER)
		column.add_child(skill_label)
		character_skill_labels.append(skill_label)

		var stat_label: Label = _make_card_label(_format_character_stats(str(data["stats"])), 12, COLOR_TEXT, HORIZONTAL_ALIGNMENT_LEFT)
		stat_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		column.add_child(stat_label)
		character_stat_labels.append(stat_label)

		var lock_label: Label = _make_card_label("", 18, COLOR_RED, HORIZONTAL_ALIGNMENT_CENTER)
		column.add_child(lock_label)
		character_lock_labels.append(lock_label)

		var code_label: Label = _make_card_label("T2R-%02d" % [character_index + 1], 9, Color(accent.r, accent.g, accent.b, 0.78), HORIZONTAL_ALIGNMENT_RIGHT)
		column.add_child(code_label)
		character_code_labels.append(code_label)

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

func _format_character_stats(raw_stats: String) -> String:
	var lines: PackedStringArray = raw_stats.split("\n", false)
	var formatted_lines: Array[String] = []
	for line: String in lines:
		var parts: PackedStringArray = line.split(":", false, 1)
		if parts.size() == 2:
			formatted_lines.append("%s:  %s" % [parts[0].strip_edges().to_upper(), parts[1].strip_edges().to_upper()])
		else:
			formatted_lines.append(line.to_upper())

	var result: String = ""
	for line_index: int in range(formatted_lines.size()):
		if line_index > 0:
			result += "\n"
		result += formatted_lines[line_index]
	return result

func _make_label_chip_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color(fill.r, fill.g, fill.b, 0.92)
	style_box.border_color = Color(border.r, border.g, border.b, 1.0)
	style_box.set_border_width_all(2)
	style_box.corner_radius_top_left = 2
	style_box.corner_radius_top_right = 2
	style_box.corner_radius_bottom_right = 2
	style_box.corner_radius_bottom_left = 2
	style_box.content_margin_left = 8
	style_box.content_margin_right = 8
	style_box.content_margin_top = 3
	style_box.content_margin_bottom = 3
	return style_box

func _add_portrait_backplate(parent: Panel, accent: Color) -> void:
	var back_glow: ColorRect = _make_portrait_rect(Color(accent.r, accent.g, accent.b, 0.18), Vector2(0.04, 0.08), Vector2(0.92, 0.82))
	parent.add_child(back_glow)

	var vault_line: ColorRect = _make_portrait_rect(COLOR_GOLD, Vector2(0.08, 0.09), Vector2(0.84, 0.045))
	parent.add_child(vault_line)

	var bill_a: ColorRect = _make_portrait_rect(COLOR_GREEN, Vector2(0.08, 0.72), Vector2(0.34, 0.12))
	parent.add_child(bill_a)
	var bill_b: ColorRect = _make_portrait_rect(COLOR_GREEN_HIGHLIGHT, Vector2(0.16, 0.61), Vector2(0.34, 0.12))
	parent.add_child(bill_b)

	var floor_glow: ColorRect = _make_portrait_rect(Color(accent.r, accent.g, accent.b, 0.28), Vector2(0.18, 0.78), Vector2(0.64, 0.055))
	parent.add_child(floor_glow)
	for scan_index: int in range(7):
		var scanline: ColorRect = _make_portrait_rect(Color(accent.r, accent.g, accent.b, 0.065), Vector2(0.04, 0.16 + float(scan_index) * 0.1), Vector2(0.92, 0.012))
		parent.add_child(scanline)

func _add_character_portrait_image(parent: Panel, character_id: String) -> void:
	var texture: Texture2D = CHARACTER_PORTRAITS.get(character_id, null) as Texture2D
	if texture == null:
		return

	var portrait_image: TextureRect = TextureRect.new()
	portrait_image.name = "CharacterPortrait"
	portrait_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_image.texture = texture
	portrait_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_image.anchor_left = 0.0
	portrait_image.anchor_top = 0.0
	portrait_image.anchor_right = 1.0
	portrait_image.anchor_bottom = 1.0
	portrait_image.offset_left = 4.0
	portrait_image.offset_top = -2.0
	portrait_image.offset_right = -4.0
	portrait_image.offset_bottom = -2.0
	parent.add_child(portrait_image)

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
	icon.anchor_left = 0.68
	icon.anchor_top = 0.12
	icon.anchor_right = 0.96
	icon.anchor_bottom = 0.5
	icon.modulate.a = 0.42
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
		character_name_labels[character_index].add_theme_color_override("font_color", accent.lightened(0.18) if not is_selected else COLOR_MUTED)
	if character_focus_labels.size() > character_index:
		character_focus_labels[character_index].visible = is_cursor and not is_selected
		character_focus_labels[character_index].modulate.a = 0.72 + (sin(menu_time * 5.0) + 1.0) * 0.14
	if character_lock_labels.size() > character_index:
		character_lock_labels[character_index].text = "ASSINADO\nOPERADOR BLOQUEADO" if is_selected else ""
		character_lock_labels[character_index].add_theme_color_override("font_color", COLOR_RED if is_selected else accent)

func _style_character_button(button: Button, accent: Color, highlighted: bool, disabled_card: bool) -> void:
	button.add_theme_stylebox_override("normal", _make_character_card_style(accent, highlighted, disabled_card))
	button.add_theme_stylebox_override("hover", _make_character_card_style(accent, true, disabled_card))
	button.add_theme_stylebox_override("focus", _make_character_card_style(accent, true, disabled_card))
	button.add_theme_stylebox_override("pressed", _make_character_card_style(accent.darkened(0.12), true, disabled_card))
	button.add_theme_stylebox_override("disabled", _make_character_card_style(accent, false, true))

func _make_character_card_style(accent: Color, highlighted: bool, disabled_card: bool) -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color(0.016 + accent.r * 0.035, 0.018 + accent.g * 0.025, 0.014 + accent.b * 0.02, 0.98) if not disabled_card else Color(0.012, 0.012, 0.01, 0.72)
	style_box.border_color = Color(accent.r, accent.g, accent.b, 1.0) if highlighted and not disabled_card else Color(accent.r, accent.g, accent.b, 0.78)
	if disabled_card:
		style_box.border_color = Color(accent.r, accent.g, accent.b, 0.34)
	style_box.set_border_width_all(7 if highlighted and not disabled_card else 3)
	style_box.corner_radius_top_left = 4
	style_box.corner_radius_top_right = 4
	style_box.corner_radius_bottom_right = 4
	style_box.corner_radius_bottom_left = 4
	style_box.shadow_color = Color(accent.r, accent.g, accent.b, 0.55 if highlighted and not disabled_card else 0.18)
	style_box.shadow_size = 30 if highlighted and not disabled_card else 10
	style_box.content_margin_left = 12
	style_box.content_margin_right = 12
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
	var text_color: Color = COLOR_GOLD if is_primary else COLOR_GREEN_HIGHLIGHT
	var focus_text_color: Color = COLOR_TEXT if is_primary else hover
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_override("font", FONT_UI)
	button.add_theme_font_size_override("font_size", 30 if is_primary else 24)
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_hover_color", focus_text_color)
	button.add_theme_color_override("font_focus_color", focus_text_color)
	button.add_theme_color_override("font_pressed_color", focus_text_color)
	button.add_theme_color_override("font_disabled_color", Color(COLOR_GOLD.r, COLOR_GOLD.g, COLOR_GOLD.b, 0.78) if is_primary else COLOR_MUTED)
	button.add_theme_color_override("font_shadow_color", Color(accent.r, accent.g, accent.b, 0.44))
	button.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.74))
	button.add_theme_constant_override("outline_size", 4)
	button.add_theme_constant_override("shadow_offset_x", 0)
	button.add_theme_constant_override("shadow_offset_y", 2)
	button.add_theme_constant_override("icon_max_width", 72 if is_primary else 48)
	button.add_theme_color_override("icon_normal_color", text_color)
	button.add_theme_color_override("icon_hover_color", focus_text_color)
	button.add_theme_color_override("icon_focus_color", focus_text_color)
	button.add_theme_color_override("icon_pressed_color", focus_text_color)
	button.add_theme_color_override("icon_disabled_color", Color(COLOR_GOLD.r, COLOR_GOLD.g, COLOR_GOLD.b, 0.58) if is_primary else Color(COLOR_GREEN_HIGHLIGHT.r, COLOR_GREEN_HIGHLIGHT.g, COLOR_GREEN_HIGHLIGHT.b, 0.5))
	button.add_theme_stylebox_override("normal", _make_button_style(accent, false, is_primary))
	button.add_theme_stylebox_override("hover", _make_button_style(hover, true, is_primary))
	button.add_theme_stylebox_override("focus", _make_button_style(hover, true, is_primary))
	button.add_theme_stylebox_override("pressed", _make_button_style(accent.darkened(0.2), true, is_primary))
	button.add_theme_stylebox_override("disabled", _make_button_style(accent.darkened(0.2), false, is_primary))

func _make_button_style(fill: Color, highlighted: bool, is_primary: bool) -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	var base_fill: Color = Color(0.018, 0.035, 0.02, 0.96)
	if is_primary:
		base_fill = Color(0.042, 0.033, 0.012, 0.98)
	style_box.bg_color = base_fill.lightened(0.08) if highlighted else base_fill
	style_box.border_color = COLOR_GOLD if is_primary else Color(fill.r, fill.g, fill.b, 0.78)
	if highlighted:
		style_box.border_color = COLOR_TEXT if is_primary else fill.lightened(0.24)
	style_box.set_border_width_all(5 if highlighted and is_primary else (4 if highlighted else 2))
	style_box.corner_radius_top_left = 5
	style_box.corner_radius_top_right = 5
	style_box.corner_radius_bottom_right = 5
	style_box.corner_radius_bottom_left = 5
	style_box.shadow_color = Color(fill.r, fill.g, fill.b, 0.58 if highlighted else 0.24)
	style_box.shadow_size = 30 if highlighted and is_primary else (18 if highlighted else 8)
	style_box.content_margin_left = 34 if is_primary else 24
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
	play_button.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_button.mouse_filter = Control.MOUSE_FILTER_STOP
	quit_button.mouse_filter = Control.MOUSE_FILTER_STOP
	close_settings_button.mouse_filter = Control.MOUSE_FILTER_STOP
	for character_button: Button in character_buttons:
		character_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	volume_slider.mouse_filter = Control.MOUSE_FILTER_STOP
	lighting_style_option.mouse_filter = Control.MOUSE_FILTER_STOP
	rain_option.mouse_filter = Control.MOUSE_FILTER_STOP

func _handle_keyboard_menu_input(key_event: InputEventKey) -> void:
	if settings_panel.visible:
		_handle_settings_keyboard_input(key_event)
		return

	if current_state == MenuState.LOBBY_CONTROLS and (key_event.keycode == KEY_F1 or key_event.keycode == KEY_O):
		_on_settings_pressed()
		return

	if current_state == MenuState.CHARACTER_SELECT and (key_event.keycode == KEY_ESCAPE or key_event.keycode == KEY_BACKSPACE):
		InputManager.reset_match_setup()
		selecting_player_index = 0
		character_cursor_index = 0
		_set_menu_state(MenuState.LOBBY_CONTROLS)
		_update_lobby_ui()
		return

	var keyboard_device: int = _get_keyboard_device_from_key(key_event.keycode)
	if keyboard_device == -1:
		return

	if current_state == MenuState.LOBBY_CONTROLS:
		if _is_keyboard_join_key(key_event.keycode):
			if InputManager.try_join_device(keyboard_device):
				_update_lobby_ui()
				return
			if InputManager.is_joined(keyboard_device):
				_start_character_selection_if_ready()
				return
		if _is_keyboard_start_key(key_event.keycode) and InputManager.is_joined(keyboard_device):
			_start_character_selection_if_ready()
			return

	if current_state == MenuState.CHARACTER_SELECT:
		_handle_character_select_keyboard_input(key_event, keyboard_device)

func _handle_settings_keyboard_input(key_event: InputEventKey) -> void:
	if key_event.keycode == KEY_ESCAPE or key_event.keycode == KEY_BACKSPACE:
		_on_settings_pressed()
		return

	var keyboard_device: int = _get_keyboard_device_from_key(key_event.keycode)
	if keyboard_device == -1:
		if _is_keyboard_start_key(key_event.keycode):
			_on_settings_pressed()
		return

	if _is_keyboard_left(key_event.keycode, keyboard_device):
		_cycle_lighting_style(-1)
	elif _is_keyboard_right(key_event.keycode, keyboard_device):
		_cycle_lighting_style(1)
	elif _is_keyboard_up(key_event.keycode, keyboard_device):
		_adjust_volume_slider(0.05)
	elif _is_keyboard_down(key_event.keycode, keyboard_device):
		_adjust_volume_slider(-0.05)
	elif _is_keyboard_select_key(key_event.keycode) or _is_keyboard_start_key(key_event.keycode):
		_on_settings_pressed()

func _handle_character_select_keyboard_input(key_event: InputEventKey, keyboard_device: int) -> void:
	var joined_players: Array[int] = InputManager.get_joined_devices()
	if selecting_player_index >= joined_players.size():
		return

	var current_device: int = int(joined_players[selecting_player_index])
	if keyboard_device != current_device:
		return

	if key_event.keycode == KEY_ESCAPE or key_event.keycode == KEY_BACKSPACE:
		InputManager.reset_match_setup()
		selecting_player_index = 0
		character_cursor_index = 0
		_set_menu_state(MenuState.LOBBY_CONTROLS)
		_update_lobby_ui()
		return

	if _is_keyboard_left(key_event.keycode, keyboard_device):
		_move_character_cursor(-1)
	elif _is_keyboard_right(key_event.keycode, keyboard_device):
		_move_character_cursor(1)
	elif _is_keyboard_up(key_event.keycode, keyboard_device):
		_move_character_cursor(-2)
	elif _is_keyboard_down(key_event.keycode, keyboard_device):
		_move_character_cursor(2)
	elif _is_keyboard_select_key(key_event.keycode):
		_try_select_current_character()

func _get_keyboard_device_from_key(keycode: Key) -> int:
	if keycode == KEY_W or keycode == KEY_A or keycode == KEY_S or keycode == KEY_D or keycode == KEY_E or keycode == KEY_ENTER:
		return int(InputManager.KEYBOARD_P1_DEVICE)
	if keycode == KEY_UP or keycode == KEY_DOWN or keycode == KEY_LEFT or keycode == KEY_RIGHT or keycode == KEY_SPACE or keycode == KEY_KP_ENTER:
		return int(InputManager.KEYBOARD_P2_DEVICE)
	return -1

func _is_keyboard_join_key(keycode: Key) -> bool:
	return keycode == KEY_E or keycode == KEY_SPACE

func _is_keyboard_start_key(keycode: Key) -> bool:
	return keycode == KEY_ENTER or keycode == KEY_KP_ENTER

func _is_keyboard_select_key(keycode: Key) -> bool:
	return keycode == KEY_E or keycode == KEY_SPACE

func _is_keyboard_left(keycode: Key, device_id: int) -> bool:
	if device_id == int(InputManager.KEYBOARD_P1_DEVICE):
		return keycode == KEY_A
	return keycode == KEY_LEFT

func _is_keyboard_right(keycode: Key, device_id: int) -> bool:
	if device_id == int(InputManager.KEYBOARD_P1_DEVICE):
		return keycode == KEY_D
	return keycode == KEY_RIGHT

func _is_keyboard_up(keycode: Key, device_id: int) -> bool:
	if device_id == int(InputManager.KEYBOARD_P1_DEVICE):
		return keycode == KEY_W
	return keycode == KEY_UP

func _is_keyboard_down(keycode: Key, device_id: int) -> bool:
	if device_id == int(InputManager.KEYBOARD_P1_DEVICE):
		return keycode == KEY_S
	return keycode == KEY_DOWN

func _get_device_label(device_id: int) -> String:
	if device_id == int(InputManager.KEYBOARD_P1_DEVICE):
		return "TECLADO 1 (WASD + E)"
	if device_id == int(InputManager.KEYBOARD_P2_DEVICE):
		return "TECLADO 2 (SETAS + ESPACO)"
	return "CONTROLE %d" % device_id

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
		if current_state == MenuState.CHARACTER_SELECT and button in character_buttons:
			var character_button_index: int = character_buttons.find(button)
			if character_button_index == character_cursor_index and not button.disabled:
				target_scale = 1.045
		button.scale = button.scale.lerp(Vector2.ONE * target_scale, delta * 10.0)
		button.rotation = lerp(button.rotation, 0.025 if is_hot and not button.disabled else 0.0, delta * 8.0)

	var title_pulse: float = (sin(menu_time * 2.0) + 1.0) * 0.5
	title_label.scale = title_label.scale.lerp(Vector2.ONE * (1.0 + title_pulse * 0.018), delta * 3.0)
	lobby_title_label.scale = lobby_title_label.scale.lerp(Vector2.ONE * (1.0 + title_pulse * 0.01), delta * 3.0)
	if reveal_panel.visible:
		reveal_panel.scale = reveal_panel.scale.lerp(Vector2.ONE * (1.0 + title_pulse * 0.01), delta * 5.0)
		reveal_title_label.modulate.a = 0.82 + title_pulse * 0.18
		reveal_label.modulate.a = 0.9 + title_pulse * 0.1
		if reveal_support_label:
			reveal_support_label.modulate.a = 0.78 + title_pulse * 0.22

	for decal: Control in menu_decals:
		if decal.name.contains("Alarm") or (decal is Label and (decal as Label).text == "ALERTA"):
			decal.modulate.a = lerp(decal.modulate.a, 0.55 + title_pulse * 0.45, delta * 5.0)

	for slot_index: int in range(lobby_slot_cards.size()):
		var slot_card: PanelContainer = lobby_slot_cards[slot_index]
		if slot_index >= slot_labels.size():
			continue
		var is_waiting: bool = slot_labels[slot_index].text.contains("AGUARDANDO")
		var target_alpha: float = 0.66 + title_pulse * 0.18 if is_waiting else 1.0
		slot_card.modulate.a = lerp(slot_card.modulate.a, target_alpha, delta * 4.0)

func _style_settings_labels() -> void:
	for child: Node in settings_panel.get_node("SettingsColumn").get_children():
		if child is Label:
			var label: Label = child
			label.add_theme_color_override("font_color", COLOR_TEXT)
			label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.72))
			label.add_theme_constant_override("outline_size", 3)
		elif child is OptionButton:
			var option_button: OptionButton = child
			option_button.add_theme_font_override("font", FONT_UI)
			option_button.add_theme_font_size_override("font_size", 20)
			option_button.add_theme_color_override("font_color", COLOR_GOLD)
			option_button.add_theme_color_override("font_hover_color", COLOR_TEXT)
			option_button.add_theme_color_override("font_focus_color", COLOR_TEXT)
			option_button.add_theme_color_override("font_pressed_color", COLOR_TEXT)
			option_button.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.74))
			option_button.add_theme_constant_override("outline_size", 3)
			option_button.add_theme_stylebox_override("normal", _make_button_style(COLOR_GOLD, false, false))
			option_button.add_theme_stylebox_override("hover", _make_button_style(COLOR_GOLD, true, false))
			option_button.add_theme_stylebox_override("focus", _make_button_style(COLOR_GOLD, true, false))
			option_button.add_theme_stylebox_override("pressed", _make_button_style(COLOR_GOLD.darkened(0.2), true, false))
