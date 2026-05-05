class_name RoundHud
extends CanvasLayer

@onready var time_label: Label = $Control/TopLeft/InfoColumn/TimeLabel
@onready var fugitives_label: Label = $Control/TopLeft/InfoColumn/FugitivesLabel
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
const COLOR_BORDER: Color = Color(0.165, 0.224, 0.325, 0.95)
const COLOR_MUTED: Color = Color(0.58, 0.639, 0.722, 1.0)

var result_overlay: PanelContainer = null
var result_title_label: Label = null
var result_subtitle_label: Label = null
var danger_flash: ColorRect = null
var banner_label: Label = null
var hud_time: float = 0.0
var capture_flash_time: float = 0.0
var banner_time: float = 0.0
var timer_base_position: Vector2 = Vector2.ZERO
var status_base_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	_apply_hud_style()
	timer_base_position = time_label.position
	status_base_position = status_label.position
	controls_label.text = "Controle 1 vira Policia | Capturados viram pegadores | R: Reiniciar"
	status_label.modulate = COLOR_DEFAULT
	time_label.modulate = COLOR_DEFAULT

func _process(delta: float) -> void:
	hud_time += delta
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
	time_label.text = "T-MINUS  %02d" % int(ceil(time_left))
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
	fugitives_label.text = "RUNNERS  %d/%d" % [active_count, total_count]

func update_round_counts(active_fugitives: int, total_fugitives: int, hunter_count: int) -> void:
	fugitives_label.text = "RUNNERS  %d/%d    CHASERS  %d" % [active_fugitives, total_fugitives, hunter_count]

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
	_show_banner("OPERACAO FINALIZADA", accent)

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
	_create_banner()
	_create_result_overlay()

	time_label.add_theme_color_override("font_color", COLOR_WARNING)
	time_label.add_theme_color_override("font_shadow_color", Color(0.918, 0.702, 0.031, 0.55))
	time_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.72))
	time_label.add_theme_constant_override("outline_size", 7)
	time_label.add_theme_constant_override("shadow_offset_x", 0)
	time_label.add_theme_constant_override("shadow_offset_y", 5)
	time_label.add_theme_font_size_override("font_size", 34)
	fugitives_label.add_theme_color_override("font_color", COLOR_SUCCESS)
	fugitives_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.72))
	fugitives_label.add_theme_constant_override("outline_size", 5)
	fugitives_label.add_theme_font_size_override("font_size", 25)
	status_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.75))
	status_label.add_theme_constant_override("outline_size", 6)
	status_label.add_theme_font_size_override("font_size", 30)
	controls_label.add_theme_color_override("font_color", COLOR_MUTED)
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
	result_title_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.82))
	result_title_label.add_theme_constant_override("outline_size", 9)
	column.add_child(result_title_label)

	result_subtitle_label = Label.new()
	result_subtitle_label.name = "ResultSubtitle"
	result_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_subtitle_label.add_theme_font_size_override("font_size", 24)
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
