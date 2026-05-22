class_name RoundHud
extends CanvasLayer

const FONT_ARCADE: FontFile = preload("res://assets/ui/fonts/PressStart2P-Regular.ttf")
const FONT_UI: FontFile = preload("res://assets/ui/fonts/KenneyFuture.ttf")

@onready var time_label: Label = $Control/TopLeft/InfoColumn/TimeLabel
@onready var fugitives_label: Label = $Control/TopLeft/InfoColumn/FugitivesLabel
@onready var skill_label: Label = $Control/TopLeft/InfoColumn/SkillLabel
@onready var status_label: Label = $Control/TopCenter/StatusLabel
@onready var controls_label: Label = $Control/BottomLeft/ControlsLabel
@onready var top_left: MarginContainer = $Control/TopLeft
@onready var top_center: CenterContainer = $Control/TopCenter
@onready var bottom_left: MarginContainer = $Control/BottomLeft

const COLOR_DEFAULT: Color = Color(0.898, 0.933, 0.973, 1.0)
const COLOR_WARNING: Color = Color(0.918, 0.702, 0.031, 1.0)
const COLOR_DANGER: Color = Color(0.976, 0.451, 0.086, 1.0)
const COLOR_SUCCESS: Color = Color(0.133, 0.773, 0.369, 1.0)
const COLOR_INFO: Color = Color(0.29, 0.871, 0.502, 1.0)
const COLOR_CYAN: Color = Color(0.22, 0.741, 0.973, 1.0)
const COLOR_BORDER: Color = Color(0.165, 0.224, 0.325, 0.95)
const COLOR_MUTED: Color = Color(0.58, 0.639, 0.722, 1.0)

var result_overlay: PanelContainer = null
var result_title_label: Label = null
var result_subtitle_label: Label = null
var danger_flash: ColorRect = null
var banner_label: Label = null
var vault_icon: HeistIcon = null
var cash_icon: HeistIcon = null
var alarm_icon: HeistIcon = null
var keycard_icon: HeistIcon = null
var hud_time: float = 0.0
var capture_flash_time: float = 0.0
var banner_time: float = 0.0
var timer_base_position: Vector2 = Vector2.ZERO
var status_base_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	_apply_hud_style()
	timer_base_position = time_label.position
	status_base_position = status_label.position
	controls_label.text = "Controle 1 vira guarda | Capturados viram seguranca | R: Reiniciar"
	skill_label.text = ""
	status_label.modulate = COLOR_DEFAULT
	time_label.modulate = COLOR_DEFAULT

func _process(delta: float) -> void:
	hud_time += delta
	if vault_icon:
		vault_icon.rotation = sin(hud_time * 0.9) * 0.025
	if cash_icon:
		cash_icon.modulate.a = 0.7 + (sin(hud_time * 2.6) + 1.0) * 0.12
	if alarm_icon:
		alarm_icon.visible = capture_flash_time > 0.0 or time_label.modulate == COLOR_WARNING
	if capture_flash_time > 0.0:
		capture_flash_time = max(capture_flash_time - delta, 0.0)
		if danger_flash:
			danger_flash.visible = true
			danger_flash.color = Color(0.937, 0.267, 0.267, capture_flash_time * 0.72)
	else:
		if danger_flash:
			danger_flash.visible = false

	if banner_time > 0.0:
		banner_time = max(banner_time - delta, 0.0)
		if banner_label:
			banner_label.visible = true
			var pulse: float = (sin(hud_time * 14.0) + 1.0) * 0.5
			banner_label.scale = Vector2.ONE * (1.0 + pulse * 0.08)
			var banner_modulate: Color = banner_label.modulate
			banner_modulate.a = min(banner_time * 2.0, 1.0)
			banner_label.modulate = banner_modulate
	else:
		if banner_label:
			banner_label.visible = false

func update_timer(time_left: float, is_warning: bool = false) -> void:
	time_label.text = "COFRE  %02d" % int(ceil(time_left))
	time_label.modulate = COLOR_WARNING if is_warning else COLOR_DEFAULT
	if is_warning:
		var pulse: float = (sin(float(Time.get_ticks_msec()) * 0.012) + 1.0) * 0.5
		var shake_x: float = sin(float(Time.get_ticks_msec()) * 0.04) * 3.0
		time_label.scale = Vector2.ONE * (1.0 + pulse * 0.1)
		time_label.position = timer_base_position + Vector2(shake_x, 0.0)
		time_label.add_theme_color_override("font_shadow_color", Color(0.937, 0.267, 0.267, 0.95))
	else:
		time_label.scale = Vector2.ONE
		time_label.position = timer_base_position
		time_label.add_theme_color_override("font_shadow_color", Color(0.918, 0.702, 0.031, 0.55))

func update_active_fugitives(active_count: int, total_count: int) -> void:
	fugitives_label.text = "EQUIPE  %d/%d" % [active_count, total_count]

func update_round_counts(active_fugitives: int, total_fugitives: int, hunter_count: int) -> void:
	fugitives_label.text = "EQUIPE  %d/%d    GUARDAS  %d" % [active_fugitives, total_fugitives, hunter_count]

func update_skill_status(message: String) -> void:
	skill_label.text = message
	skill_label.visible = not message.is_empty()

func set_status(message: String, color: Color = COLOR_DEFAULT) -> void:
	status_label.text = message
	status_label.modulate = color
	status_label.position = status_base_position

func set_controls_hint(message: String) -> void:
	controls_label.text = message

func show_round_result(title: String, subtitle: String, is_success: bool) -> void:
	if result_overlay == null:
		_create_result_overlay()

	result_overlay.visible = true
	result_title_label.text = title.to_upper()
	result_subtitle_label.text = subtitle
	var accent: Color = COLOR_SUCCESS if is_success else COLOR_DANGER
	result_title_label.add_theme_color_override("font_color", accent)
	result_overlay.add_theme_stylebox_override("panel", _make_result_style(accent))
	_show_banner("OPERACAO DO COFRE FINALIZADA", accent)

func hide_round_result() -> void:
	if result_overlay:
		result_overlay.visible = false

func show_capture_flash(message: String = "CONTAGIO!") -> void:
	capture_flash_time = 0.42
	_show_banner(message, COLOR_DANGER)

func show_round_banner(message: String) -> void:
	_show_banner(message, COLOR_WARNING)

func _apply_hud_style() -> void:
	_create_panel_for(top_left, Color(0.094, 0.133, 0.208, 0.9))
	_create_panel_for(top_center, Color(0.094, 0.133, 0.208, 0.78))
	_create_panel_for(bottom_left, Color(0.043, 0.063, 0.125, 0.72))
	_create_screen_flash()
	_create_hud_heist_icons()
	_create_banner()
	_create_result_overlay()

	time_label.add_theme_color_override("font_color", COLOR_WARNING)
	time_label.add_theme_font_override("font", FONT_ARCADE)
	time_label.add_theme_color_override("font_shadow_color", Color(0.918, 0.702, 0.031, 0.55))
	time_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.72))
	time_label.add_theme_constant_override("outline_size", 7)
	time_label.add_theme_constant_override("shadow_offset_x", 0)
	time_label.add_theme_constant_override("shadow_offset_y", 5)
	time_label.add_theme_font_size_override("font_size", 32)
	fugitives_label.add_theme_color_override("font_color", COLOR_SUCCESS)
	fugitives_label.add_theme_font_override("font", FONT_UI)
	fugitives_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.72))
	fugitives_label.add_theme_constant_override("outline_size", 5)
	fugitives_label.add_theme_font_size_override("font_size", 24)
	skill_label.add_theme_color_override("font_color", COLOR_CYAN)
	skill_label.add_theme_font_override("font", FONT_UI)
	skill_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.72))
	skill_label.add_theme_constant_override("outline_size", 4)
	skill_label.add_theme_font_size_override("font_size", 20)
	status_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.75))
	status_label.add_theme_font_override("font", FONT_UI)
	status_label.add_theme_constant_override("outline_size", 6)
	status_label.add_theme_font_size_override("font_size", 30)
	controls_label.add_theme_color_override("font_color", COLOR_MUTED)
	controls_label.add_theme_font_override("font", FONT_UI)
	controls_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.65))
	controls_label.add_theme_constant_override("outline_size", 3)

func _create_panel_for(target: Control, fill: Color) -> void:
	var parent: Control = target.get_parent() as Control
	if parent == null:
		return

	var shadow_panel: Panel = Panel.new()
	shadow_panel.name = "%sPhysicalShadow" % target.name
	shadow_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shadow_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	shadow_panel.anchor_left = target.anchor_left
	shadow_panel.anchor_top = target.anchor_top
	shadow_panel.anchor_right = target.anchor_right
	shadow_panel.anchor_bottom = target.anchor_bottom
	shadow_panel.offset_left = target.offset_left + 12.0
	shadow_panel.offset_top = target.offset_top + 12.0
	shadow_panel.offset_right = target.offset_right + 22.0
	shadow_panel.offset_bottom = target.offset_bottom + 22.0
	shadow_panel.add_theme_stylebox_override("panel", _make_depth_shadow_style())
	parent.add_child(shadow_panel)
	parent.move_child(shadow_panel, target.get_index())

	var panel: Panel = Panel.new()
	panel.name = "%sCard" % target.name
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.anchor_left = target.anchor_left
	panel.anchor_top = target.anchor_top
	panel.anchor_right = target.anchor_right
	panel.anchor_bottom = target.anchor_bottom
	panel.offset_left = target.offset_left - 16.0
	panel.offset_top = target.offset_top - 12.0
	panel.offset_right = target.offset_right + 16.0
	panel.offset_bottom = target.offset_bottom + 12.0
	panel.add_theme_stylebox_override("panel", _make_card_style(fill))
	parent.add_child(panel)
	parent.move_child(panel, target.get_index())

func _make_card_style(fill: Color) -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = fill
	style_box.border_color = COLOR_BORDER
	style_box.set_border_width_all(4)
	style_box.corner_radius_top_left = 14
	style_box.corner_radius_top_right = 14
	style_box.corner_radius_bottom_right = 14
	style_box.corner_radius_bottom_left = 14
	style_box.shadow_color = Color(0.0, 0.0, 0.0, 0.62)
	style_box.shadow_size = 18
	style_box.content_margin_left = 18
	style_box.content_margin_right = 18
	style_box.content_margin_top = 12
	style_box.content_margin_bottom = 12
	return style_box

func _make_depth_shadow_style() -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color(0.0, 0.0, 0.0, 0.48)
	style_box.corner_radius_top_left = 14
	style_box.corner_radius_top_right = 14
	style_box.corner_radius_bottom_right = 14
	style_box.corner_radius_bottom_left = 14
	return style_box

func _create_screen_flash() -> void:
	danger_flash = ColorRect.new()
	danger_flash.name = "CaptureImpactFlash"
	danger_flash.visible = false
	danger_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	danger_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	danger_flash.color = Color(0.937, 0.267, 0.267, 0.0)
	$Control.add_child(danger_flash)
	$Control.move_child(danger_flash, 0)

func _create_hud_heist_icons() -> void:
	vault_icon = _make_hud_icon("VaultTimerIcon", HeistIcon.IconType.VAULT, Vector2(0.012, 0.026), Vector2(0.05, 0.082), COLOR_WARNING, 0.95)
	cash_icon = _make_hud_icon("CashCrewIcon", HeistIcon.IconType.MONEY_STACK, Vector2(0.014, 0.108), Vector2(0.054, 0.072), COLOR_SUCCESS, 0.88)
	alarm_icon = _make_hud_icon("AlarmDangerIcon", HeistIcon.IconType.ALARM, Vector2(0.47, 0.085), Vector2(0.06, 0.086), COLOR_DANGER, 0.95)
	keycard_icon = _make_hud_icon("KeycardControlsIcon", HeistIcon.IconType.KEYCARD, Vector2(0.012, 0.9), Vector2(0.052, 0.07), COLOR_CYAN, 0.75)
	alarm_icon.visible = false

func _make_hud_icon(icon_name: String, icon_type: int, anchor_position: Vector2, anchor_size: Vector2, accent: Color, opacity: float) -> HeistIcon:
	var icon: HeistIcon = HeistIcon.new()
	icon.name = icon_name
	icon.icon_type = icon_type
	icon.accent = accent
	icon.opacity = opacity
	icon.anchor_left = anchor_position.x
	icon.anchor_top = anchor_position.y
	icon.anchor_right = anchor_position.x + anchor_size.x
	icon.anchor_bottom = anchor_position.y + anchor_size.y
	icon.offset_left = 0.0
	icon.offset_top = 0.0
	icon.offset_right = 0.0
	icon.offset_bottom = 0.0
	$Control.add_child(icon)
	$Control.move_child(icon, 1)
	return icon

func _create_banner() -> void:
	banner_label = Label.new()
	banner_label.name = "ArcadeImpactBanner"
	banner_label.visible = false
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	banner_label.offset_left = -330.0
	banner_label.offset_top = 114.0
	banner_label.offset_right = 330.0
	banner_label.offset_bottom = 176.0
	banner_label.add_theme_font_size_override("font_size", 42)
	banner_label.add_theme_font_override("font", FONT_ARCADE)
	banner_label.add_theme_color_override("font_color", COLOR_WARNING)
	banner_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.92))
	banner_label.add_theme_constant_override("outline_size", 9)
	$Control.add_child(banner_label)

func _show_banner(message: String, color: Color) -> void:
	if banner_label == null:
		return
	banner_label.text = message.to_upper()
	banner_label.add_theme_color_override("font_color", color)
	banner_time = 1.15

func _create_result_overlay() -> void:
	if result_overlay != null:
		return

	result_overlay = PanelContainer.new()
	result_overlay.name = "ResultOverlay"
	result_overlay.visible = false
	result_overlay.set_anchors_preset(Control.PRESET_CENTER)
	result_overlay.offset_left = -420.0
	result_overlay.offset_top = -145.0
	result_overlay.offset_right = 420.0
	result_overlay.offset_bottom = 145.0
	result_overlay.add_theme_stylebox_override("panel", _make_result_style(COLOR_SUCCESS))
	$Control.add_child(result_overlay)

	var column: VBoxContainer = VBoxContainer.new()
	column.name = "ResultColumn"
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 12)
	result_overlay.add_child(column)

	result_title_label = Label.new()
	result_title_label.name = "ResultTitle"
	result_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_title_label.add_theme_font_size_override("font_size", 50)
	result_title_label.add_theme_font_override("font", FONT_ARCADE)
	result_title_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.82))
	result_title_label.add_theme_constant_override("outline_size", 9)
	column.add_child(result_title_label)

	result_subtitle_label = Label.new()
	result_subtitle_label.name = "ResultSubtitle"
	result_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_subtitle_label.add_theme_font_size_override("font_size", 24)
	result_subtitle_label.add_theme_font_override("font", FONT_UI)
	result_subtitle_label.add_theme_color_override("font_color", COLOR_DEFAULT)
	result_subtitle_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.72))
	result_subtitle_label.add_theme_constant_override("outline_size", 3)
	column.add_child(result_subtitle_label)

func _make_result_style(accent: Color) -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color(0.012, 0.018, 0.055, 0.96)
	style_box.border_color = accent
	style_box.set_border_width_all(6)
	style_box.corner_radius_top_left = 18
	style_box.corner_radius_top_right = 18
	style_box.corner_radius_bottom_right = 18
	style_box.corner_radius_bottom_left = 18
	style_box.shadow_color = accent.darkened(0.55)
	style_box.shadow_size = 32
	style_box.content_margin_left = 44
	style_box.content_margin_right = 44
	style_box.content_margin_top = 36
	style_box.content_margin_bottom = 36
	return style_box
