class_name RoundHud
extends CanvasLayer

const FONT_ARCADE: FontFile = preload("res://assets/ui/fonts/PressStart2P-Regular.ttf")
const FONT_UI: FontFile = preload("res://assets/ui/fonts/KenneyFuture.ttf")

@onready var time_label: Label = $Control/TopLeft/InfoColumn/TimeLabel
@onready var fugitives_label: Label = $Control/TopLeft/InfoColumn/FugitivesLabel
@onready var skill_label: Label = $Control/TopLeft/InfoColumn/SkillLabel
@onready var status_label: Label = $Control/TopCenter/StatusLabel
@onready var controls_label: Label = $Control/BottomLeft/ControlsLabel
@onready var info_column: VBoxContainer = $Control/TopLeft/InfoColumn
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
var controls_prompt_strip: ControllerPromptStrip = null
var top_timer: CenterContainer = null
var match_label: Label = null
var score_label: Label = null
var hud_time: float = 0.0
var capture_flash_time: float = 0.0
var banner_time: float = 0.0
var timer_base_position: Vector2 = Vector2.ZERO
var status_base_position: Vector2 = Vector2.ZERO
var last_timer_seconds: int = -1
var last_timer_warning: bool = false
var last_counts_text: String = ""
var last_match_text: String = ""
var last_score_text: String = ""
var last_skill_text: String = ""
var last_status_text: String = ""
var last_status_color: Color = Color(0.0, 0.0, 0.0, 0.0)
var last_controls_text: String = ""

func _ready() -> void:
	if not get_viewport().size_changed.is_connected(_apply_responsive_layout):
		get_viewport().size_changed.connect(_apply_responsive_layout)
	_apply_hud_style()
	_apply_responsive_layout()
	timer_base_position = time_label.position
	status_base_position = status_label.position
	set_controls_hint("")
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
	var timer_seconds: int = int(ceil(time_left))
	if timer_seconds != last_timer_seconds:
		last_timer_seconds = timer_seconds
		time_label.text = "TEMPO %02d" % timer_seconds
	if is_warning != last_timer_warning:
		last_timer_warning = is_warning
		time_label.modulate = COLOR_WARNING if is_warning else COLOR_DEFAULT
		time_label.add_theme_color_override(
			"font_shadow_color",
			Color(0.937, 0.267, 0.267, 0.95) if is_warning else Color(0.918, 0.702, 0.031, 0.55)
		)
	if is_warning:
		var pulse: float = (sin(hud_time * 12.0) + 1.0) * 0.5
		var shake_x: float = sin(hud_time * 40.0) * 3.0
		time_label.scale = Vector2.ONE * (1.0 + pulse * 0.1)
		time_label.position = timer_base_position + Vector2(shake_x, 0.0)
	else:
		time_label.scale = Vector2.ONE
		time_label.position = timer_base_position

func update_active_fugitives(active_count: int, total_count: int) -> void:
	var next_text: String = "FUGITIVOS  %d/%d" % [active_count, total_count]
	if next_text != last_counts_text:
		last_counts_text = next_text
		fugitives_label.text = next_text

func update_round_counts(active_fugitives: int, total_fugitives: int, hunter_count: int) -> void:
	var next_text: String = "FUG %d/%d   PEG %d" % [active_fugitives, total_fugitives, hunter_count]
	if next_text != last_counts_text:
		last_counts_text = next_text
		fugitives_label.text = next_text

func update_match_info(round_index: int, total_rounds: int, police_name: String) -> void:
	if match_label == null:
		return
	var next_text: String = "R%d/%d  POL %s" % [round_index, total_rounds, _short_label(police_name)]
	if next_text != last_match_text:
		last_match_text = next_text
		match_label.text = next_text

func update_scoreboard(score_text: String) -> void:
	if score_label == null:
		return
	var next_text: String = score_text.replace("PLACAR  ", "")
	if next_text != last_score_text:
		last_score_text = next_text
		score_label.text = next_text
	var should_show: bool = not score_text.is_empty()
	if score_label.visible != should_show:
		score_label.visible = should_show

func update_skill_status(message: String) -> void:
	if message != last_skill_text:
		last_skill_text = message
		skill_label.text = message
	var should_show: bool = not message.is_empty()
	if skill_label.visible != should_show:
		skill_label.visible = should_show

func set_status(message: String, color: Color = COLOR_DEFAULT) -> void:
	if message != last_status_text:
		last_status_text = message
		status_label.text = message
	if color != last_status_color:
		last_status_color = color
		status_label.modulate = color
	status_label.position = status_base_position
	var has_result_overlay: bool = result_overlay != null and result_overlay.visible
	var should_show: bool = not has_result_overlay and not message.is_empty() and color != COLOR_DEFAULT
	if top_center.visible != should_show:
		top_center.visible = should_show
		_sync_panel_for(top_center)

func set_controls_hint(message: String) -> void:
	if message != last_controls_text:
		last_controls_text = message
		if controls_prompt_strip:
			controls_prompt_strip.set_prompts(_make_control_prompt_items(message))
		controls_label.text = _make_control_detail_text(message)
	var should_show: bool = not message.is_empty()
	if bottom_left.visible != should_show:
		bottom_left.visible = should_show
		_sync_panel_for(bottom_left)

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
	_sync_panel_for(top_center)

func show_capture_flash(message: String = "CONTAGIO!") -> void:
	capture_flash_time = 0.42
	_show_banner(message, COLOR_DANGER)

func show_round_banner(message: String) -> void:
	_show_banner(message, COLOR_WARNING)

func _apply_hud_style() -> void:
	_create_timer_container()
	_create_match_labels()
	_create_controls_prompt_strip()
	_create_panel_for(top_timer, Color(0.043, 0.063, 0.125, 0.82))
	_create_panel_for(top_left, Color(0.094, 0.133, 0.208, 0.9))
	_create_panel_for(top_center, Color(0.094, 0.133, 0.208, 0.78))
	_create_panel_for(bottom_left, Color(0.043, 0.063, 0.125, 0.72))
	_create_screen_flash()
	_create_hud_heist_icons()
	_create_banner()
	_create_result_overlay()

	time_label.add_theme_color_override("font_color", COLOR_WARNING)
	time_label.add_theme_font_override("font", FONT_UI)
	time_label.add_theme_color_override("font_shadow_color", Color(0.918, 0.702, 0.031, 0.55))
	time_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.72))
	time_label.add_theme_constant_override("outline_size", 4)
	time_label.add_theme_constant_override("shadow_offset_x", 0)
	time_label.add_theme_constant_override("shadow_offset_y", 3)
	time_label.add_theme_font_size_override("font_size", 18)
	fugitives_label.add_theme_color_override("font_color", COLOR_SUCCESS)
	fugitives_label.add_theme_font_override("font", FONT_UI)
	fugitives_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.72))
	fugitives_label.add_theme_constant_override("outline_size", 3)
	fugitives_label.add_theme_font_size_override("font_size", 13)
	skill_label.add_theme_color_override("font_color", COLOR_CYAN)
	skill_label.add_theme_font_override("font", FONT_UI)
	skill_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.72))
	skill_label.add_theme_constant_override("outline_size", 3)
	skill_label.add_theme_font_size_override("font_size", 12)
	status_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.75))
	status_label.add_theme_font_override("font", FONT_UI)
	status_label.add_theme_constant_override("outline_size", 4)
	status_label.add_theme_font_size_override("font_size", 14)
	controls_label.add_theme_color_override("font_color", COLOR_MUTED)
	controls_label.add_theme_font_override("font", FONT_UI)
	controls_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.65))
	controls_label.add_theme_constant_override("outline_size", 3)

func _create_timer_container() -> void:
	if top_timer:
		return

	top_timer = CenterContainer.new()
	top_timer.name = "TopTimer"
	top_timer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Control.add_child(top_timer)
	$Control.move_child(top_timer, top_left.get_index())
	time_label.reparent(top_timer)
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _create_controls_prompt_strip() -> void:
	if controls_prompt_strip:
		return

	var column: VBoxContainer = VBoxContainer.new()
	column.name = "ControlsColumn"
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 3)
	bottom_left.add_child(column)

	if controls_label.get_parent() == bottom_left:
		controls_label.reparent(column)

	controls_prompt_strip = ControllerPromptStrip.new()
	controls_prompt_strip.name = "ControlsPromptStrip"
	column.add_child(controls_prompt_strip)
	column.move_child(controls_prompt_strip, 0)

func _make_control_prompt_items(message: String) -> Array[Dictionary]:
	var normalized: String = message.to_lower()
	if normalized.is_empty():
		return []
	if normalized.contains("habilidade"):
		return [
			{"prompt": "dpad", "text": "mover"},
			{"prompt": "r1", "text": "habilidade"},
		]
	if normalized.contains("reiniciar"):
		return [
			{"prompt": "start", "text": "reiniciar"},
			{"prompt": "confirm", "text": "confirmar"},
		]
	if normalized.contains("proxima") or normalized.contains("avancar"):
		return [
			{"prompt": "start", "text": "proxima"},
			{"prompt": "confirm", "text": "confirmar"},
		]
	return [
		{"prompt": "start", "text": "confirmar"},
	]

func _make_control_detail_text(message: String) -> String:
	var normalized: String = message.to_lower()
	if normalized.contains("habilidade"):
		return "Fugitivos usam a skill ativa no R1"
	if normalized.contains("reiniciar"):
		return "Fim da partida"
	if normalized.contains("proxima") or normalized.contains("avancar"):
		return "Resultado da rodada"
	return ""

func _apply_responsive_layout() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var is_compact: bool = viewport_size.x < 1500.0 or viewport_size.y < 820.0
	var is_large: bool = viewport_size.x >= 1800.0 and viewport_size.y >= 950.0
	var safe_left: float = 18.0 if is_compact else (30.0 if is_large else 24.0)
	var safe_top: float = 14.0 if is_compact else (24.0 if is_large else 18.0)
	var panel_width: float = 224.0 if is_compact else (286.0 if is_large else 250.0)
	var panel_height: float = 76.0 if is_compact else (96.0 if is_large else 84.0)
	var timer_width: float = 190.0 if is_compact else (250.0 if is_large else 220.0)
	var timer_height: float = 38.0 if is_compact else (50.0 if is_large else 44.0)
	var bottom_height: float = 44.0 if is_compact else (56.0 if is_large else 48.0)
	var bottom_margin: float = 18.0 if is_compact else (32.0 if is_large else 24.0)
	var center_width: float = minf(viewport_size.x * 0.36, 460.0 if is_compact else 560.0)
	var center_height: float = 34.0 if is_compact else (46.0 if is_large else 38.0)

	top_timer.anchor_left = 0.0
	top_timer.anchor_top = 0.0
	top_timer.anchor_right = 0.0
	top_timer.anchor_bottom = 0.0
	top_timer.offset_left = (viewport_size.x - timer_width) * 0.5
	top_timer.offset_top = safe_top
	top_timer.offset_right = top_timer.offset_left + timer_width
	top_timer.offset_bottom = top_timer.offset_top + timer_height

	top_left.anchor_left = 0.0
	top_left.anchor_top = 0.0
	top_left.anchor_right = 0.0
	top_left.anchor_bottom = 0.0
	top_left.offset_left = safe_left
	top_left.offset_top = safe_top
	top_left.offset_right = safe_left + panel_width
	top_left.offset_bottom = safe_top + panel_height

	top_center.anchor_left = 0.0
	top_center.anchor_top = 0.0
	top_center.anchor_right = 0.0
	top_center.anchor_bottom = 0.0
	top_center.offset_left = (viewport_size.x - center_width) * 0.5
	top_center.offset_top = safe_top + timer_height + 8.0
	top_center.offset_right = top_center.offset_left + center_width
	top_center.offset_bottom = top_center.offset_top + center_height

	bottom_left.anchor_left = 0.0
	bottom_left.anchor_top = 0.0
	bottom_left.anchor_right = 0.0
	bottom_left.anchor_bottom = 0.0
	bottom_left.offset_left = safe_left
	bottom_left.offset_top = viewport_size.y - bottom_margin - bottom_height
	bottom_left.offset_right = minf(safe_left + 640.0, viewport_size.x - safe_left)
	bottom_left.offset_bottom = viewport_size.y - bottom_margin

	match_label.add_theme_font_size_override("font_size", 10 if is_compact else (13 if is_large else 11))
	score_label.add_theme_font_size_override("font_size", 10 if is_compact else (12 if is_large else 11))
	time_label.add_theme_font_size_override("font_size", 18 if is_compact else (26 if is_large else 22))
	fugitives_label.add_theme_font_size_override("font_size", 12 if is_compact else (15 if is_large else 13))
	skill_label.add_theme_font_size_override("font_size", 11 if is_compact else (14 if is_large else 12))
	status_label.add_theme_font_size_override("font_size", 13 if is_compact else (17 if is_large else 15))
	controls_label.add_theme_font_size_override("font_size", 14 if is_compact else (18 if is_large else 16))
	if controls_prompt_strip:
		controls_prompt_strip.set_prompt_size(24 if is_compact else (34 if is_large else 28), 12 if is_compact else (17 if is_large else 14))

	if banner_label:
		banner_label.offset_left = -300.0 if is_compact else -380.0
		banner_label.offset_top = 74.0 if is_compact else 96.0
		banner_label.offset_right = 300.0 if is_compact else 380.0
		banner_label.offset_bottom = 126.0 if is_compact else 154.0
		banner_label.add_theme_font_size_override("font_size", 20 if is_compact else (30 if is_large else 24))

	if result_overlay:
		result_overlay.offset_left = -360.0 if is_compact else -460.0
		result_overlay.offset_top = -128.0 if is_compact else -164.0
		result_overlay.offset_right = 360.0 if is_compact else 460.0
		result_overlay.offset_bottom = 128.0 if is_compact else 164.0
	if result_title_label:
		result_title_label.add_theme_font_size_override("font_size", 38 if is_compact else (56 if is_large else 50))
	if result_subtitle_label:
		result_subtitle_label.add_theme_font_size_override("font_size", 20 if is_compact else (27 if is_large else 24))

	timer_base_position = time_label.position
	status_base_position = status_label.position
	_position_hud_heist_icons(is_compact)
	_sync_hud_panel_backplates()

func _sync_hud_panel_backplates() -> void:
	var hud_panels: Array[Control] = [top_timer, top_left, top_center, bottom_left]
	for target: Control in hud_panels:
		_sync_panel_for(target)

func _sync_panel_for(target: Control) -> void:
	var parent: Control = target.get_parent() as Control
	if parent == null:
		return

	var shadow_panel: Panel = parent.get_node_or_null("%sPhysicalShadow" % target.name) as Panel
	if shadow_panel:
		shadow_panel.visible = target.visible
		shadow_panel.anchor_left = target.anchor_left
		shadow_panel.anchor_top = target.anchor_top
		shadow_panel.anchor_right = target.anchor_right
		shadow_panel.anchor_bottom = target.anchor_bottom
		shadow_panel.offset_left = target.offset_left + 12.0
		shadow_panel.offset_top = target.offset_top + 12.0
		shadow_panel.offset_right = target.offset_right + 22.0
		shadow_panel.offset_bottom = target.offset_bottom + 22.0

	var panel: Panel = parent.get_node_or_null("%sCard" % target.name) as Panel
	if panel:
		panel.visible = target.visible
		panel.anchor_left = target.anchor_left
		panel.anchor_top = target.anchor_top
		panel.anchor_right = target.anchor_right
		panel.anchor_bottom = target.anchor_bottom
		panel.offset_left = target.offset_left - 16.0
		panel.offset_top = target.offset_top - 12.0
		panel.offset_right = target.offset_right + 16.0
		panel.offset_bottom = target.offset_bottom + 12.0

func _create_match_labels() -> void:
	if match_label == null:
		match_label = Label.new()
		match_label.name = "MatchLabel"
		info_column.add_child(match_label)
		info_column.move_child(match_label, 0)

	if score_label == null:
		score_label = Label.new()
		score_label.name = "ScoreLabel"
		info_column.add_child(score_label)

	_style_match_info_label(match_label)
	_style_match_info_label(score_label)

	match_label.add_theme_color_override("font_color", COLOR_WARNING)
	match_label.add_theme_font_size_override("font_size", 19)
	score_label.add_theme_color_override("font_color", COLOR_CYAN)
	score_label.add_theme_font_size_override("font_size", 18)
	score_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	score_label.clip_text = true

func _style_match_info_label(label: Label) -> void:
	label.add_theme_font_override("font", FONT_UI)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.72))
	label.add_theme_constant_override("outline_size", 3)

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
	style_box.set_border_width_all(2)
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.shadow_color = Color(0.0, 0.0, 0.0, 0.62)
	style_box.shadow_size = 8
	style_box.content_margin_left = 10
	style_box.content_margin_right = 10
	style_box.content_margin_top = 8
	style_box.content_margin_bottom = 8
	return style_box

func _make_depth_shadow_style() -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color(0.0, 0.0, 0.0, 0.48)
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_right = 8
	style_box.corner_radius_bottom_left = 8
	return style_box

func _short_label(text: String) -> String:
	var cleaned_text: String = text.to_upper()
	if cleaned_text.length() <= 4:
		return cleaned_text
	return cleaned_text.substr(0, 4)

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
	vault_icon = _make_hud_icon("VaultTimerIcon", HeistIcon.IconType.VAULT, COLOR_WARNING, 0.82)
	cash_icon = _make_hud_icon("CashCrewIcon", HeistIcon.IconType.MONEY_STACK, COLOR_SUCCESS, 0.78)
	alarm_icon = _make_hud_icon("AlarmDangerIcon", HeistIcon.IconType.ALARM, COLOR_DANGER, 0.88)
	keycard_icon = null
	alarm_icon.visible = false

func _make_hud_icon(icon_name: String, icon_type: int, accent: Color, opacity: float) -> HeistIcon:
	var icon: HeistIcon = HeistIcon.new()
	icon.name = icon_name
	icon.icon_type = icon_type
	icon.accent = accent
	icon.opacity = opacity
	icon.animated = false
	icon.anchor_left = 0.0
	icon.anchor_top = 0.0
	icon.anchor_right = 0.0
	icon.anchor_bottom = 0.0
	icon.offset_left = 0.0
	icon.offset_top = 0.0
	icon.offset_right = 28.0
	icon.offset_bottom = 28.0
	$Control.add_child(icon)
	$Control.move_child(icon, 1)
	return icon

func _position_hud_heist_icons(is_compact: bool) -> void:
	var icon_size: float = 22.0 if is_compact else 26.0
	var timer_icon_x: float = top_timer.offset_left + 7.0
	var timer_icon_y: float = top_timer.offset_top + (top_timer.offset_bottom - top_timer.offset_top - icon_size) * 0.5
	var icon_x: float = top_left.offset_left + top_left.offset_right - top_left.offset_left - icon_size - 2.0
	var middle_y: float = top_left.offset_top + 10.0
	var alarm_y: float = top_left.offset_top + 42.0
	_place_hud_icon(vault_icon, timer_icon_x, timer_icon_y, icon_size)
	_place_hud_icon(cash_icon, icon_x, middle_y, icon_size)
	_place_hud_icon(alarm_icon, icon_x, alarm_y, icon_size)

func _place_hud_icon(icon: HeistIcon, x: float, y: float, icon_size: float) -> void:
	if icon == null:
		return
	icon.offset_left = x
	icon.offset_top = y
	icon.offset_right = x + icon_size
	icon.offset_bottom = y + icon_size

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
