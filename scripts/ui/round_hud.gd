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

const COLOR_DEFAULT: Color = Color(0.94, 0.963, 1.0, 1.0)
const COLOR_WARNING: Color = Color(0.965, 0.757, 0.216, 1.0)
const COLOR_DANGER: Color = Color(0.973, 0.38, 0.298, 1.0)
const COLOR_SUCCESS: Color = Color(0.188, 0.839, 0.482, 1.0)
const COLOR_INFO: Color = Color(0.365, 0.906, 0.576, 1.0)
const COLOR_CYAN: Color = Color(0.286, 0.824, 0.996, 1.0)
const COLOR_BORDER: Color = Color(0.286, 0.365, 0.537, 0.96)
const COLOR_MUTED: Color = Color(0.667, 0.741, 0.824, 1.0)
const COLOR_PANEL_TIMER: Color = Color(0.047, 0.071, 0.149, 0.9)
const COLOR_PANEL_TOP_LEFT: Color = Color(0.063, 0.098, 0.192, 0.92)
const COLOR_PANEL_TOP_CENTER: Color = Color(0.082, 0.122, 0.224, 0.86)
const COLOR_PANEL_CONTROLS: Color = Color(0.035, 0.051, 0.118, 0.8)
const COLOR_CARD_BG: Color = Color(0.043, 0.067, 0.149, 0.9)
const COLOR_CARD_BG_INACTIVE: Color = Color(0.043, 0.047, 0.067, 0.88)
const COLOR_BAR_BG: Color = Color(0.051, 0.078, 0.145, 0.98)
const COLOR_BAR_FILL_READY: Color = Color(0.173, 0.878, 0.529, 1.0)
const COLOR_BAR_FILL_COOLDOWN: Color = Color(0.286, 0.824, 0.996, 1.0)
const COLOR_BAR_FILL_INACTIVE: Color = Color(0.486, 0.525, 0.588, 0.92)
const COLOR_CARD_BORDER_READY: Color = Color(0.173, 0.878, 0.529, 0.98)
const COLOR_CARD_BORDER_COOLDOWN: Color = Color(0.286, 0.824, 0.996, 0.95)
const COLOR_CARD_BORDER_POLICE: Color = Color(0.965, 0.757, 0.216, 0.98)
const COLOR_CARD_BORDER_INACTIVE: Color = Color(0.353, 0.4, 0.471, 0.85)
const SHOW_TOP_CENTER_STATUS_PANEL: bool = false
const SHOW_TOP_LEFT_INFO_PANEL: bool = false

var result_overlay: PanelContainer = null
var result_backdrop: ColorRect = null
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
var banner_centered: bool = false
var bottom_skills: MarginContainer = null
var skill_block_cards: Array[PanelContainer] = []
var skill_block_slot_labels: Array[Label] = []
var skill_block_name_labels: Array[Label] = []
var skill_block_ability_labels: Array[Label] = []
var skill_block_bars: Array[ProgressBar] = []
var last_timer_seconds: int = -1
var last_timer_warning: bool = false
var last_counts_text: String = ""
var last_match_text: String = ""
var last_score_text: String = ""
var last_skill_text: String = ""
var last_status_text: String = ""
var last_status_color: Color = Color(0.0, 0.0, 0.0, 0.0)
var last_controls_text: String = ""
var last_skill_blocks_hash: String = ""
var round_points_overlay: PanelContainer = null
var round_points_title_label: Label = null
var round_points_confirm_prompt: ControllerPromptStrip = null
var round_points_row_containers: Array[HBoxContainer] = []
var round_points_name_labels: Array[Label] = []
var round_points_gain_labels: Array[Label] = []
var round_points_total_labels: Array[Label] = []
var round_points_bar_tracks: Array[Panel] = []
var round_points_bars: Array[ColorRect] = []
var round_points_tween: Tween = null
var round_start_label: Label = null
var last_round_start_text: String = ""
var is_match_result_visible: bool = false

func _ready() -> void:
	if not get_viewport().size_changed.is_connected(_apply_responsive_layout):
		get_viewport().size_changed.connect(_apply_responsive_layout)
	_apply_hud_style()
	_apply_responsive_layout()
	if top_left:
		top_left.visible = SHOW_TOP_LEFT_INFO_PANEL
		_sync_panel_for(top_left)
	if top_center:
		top_center.visible = false
		_sync_panel_for(top_center)
	_update_timer_pivot()
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
		if not SHOW_TOP_LEFT_INFO_PANEL:
			cash_icon.visible = false
	if alarm_icon:
		if SHOW_TOP_LEFT_INFO_PANEL:
			alarm_icon.visible = capture_flash_time > 0.0 or time_label.modulate == COLOR_WARNING
		else:
			alarm_icon.visible = false
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
			var banner_modulate: Color = banner_label.modulate
			if banner_centered:
				var blink_alpha: float = 0.45 + ((sin(hud_time * 8.0) + 1.0) * 0.5) * 0.55
				banner_label.scale = Vector2.ONE
				banner_modulate.a = blink_alpha * min(banner_time * 2.0, 1.0)
			else:
				var pulse: float = (sin(hud_time * 14.0) + 1.0) * 0.5
				banner_label.scale = Vector2.ONE * (1.0 + pulse * 0.08)
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
		_update_timer_pivot()
	if is_warning != last_timer_warning:
		last_timer_warning = is_warning
		time_label.modulate = COLOR_WARNING if is_warning else COLOR_DEFAULT
		time_label.add_theme_color_override(
			"font_shadow_color",
			Color(0.937, 0.267, 0.267, 0.95) if is_warning else Color(0.918, 0.702, 0.031, 0.55)
		)
	if is_warning:
		var pulse: float = (sin(hud_time * 12.0) + 1.0) * 0.5
		_update_timer_pivot()
		time_label.scale = Vector2.ONE * (1.0 + pulse * 0.1)
	else:
		time_label.scale = Vector2.ONE

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

func update_player_skill_blocks(blocks: Array[Dictionary]) -> void:
	if skill_block_cards.is_empty():
		return

	var next_hash: String = JSON.stringify(blocks)
	if next_hash == last_skill_blocks_hash:
		return
	last_skill_blocks_hash = next_hash

	for block_index: int in range(skill_block_cards.size()):
		var should_show: bool = block_index < blocks.size()
		if skill_block_cards[block_index].visible != should_show:
			skill_block_cards[block_index].visible = should_show
		if not should_show:
			continue

		var block_data: Dictionary = blocks[block_index] if block_index < blocks.size() else {}
		var slot_label: Label = skill_block_slot_labels[block_index]
		var name_label: Label = skill_block_name_labels[block_index]
		var ability_label: Label = skill_block_ability_labels[block_index]
		var cooldown_bar: ProgressBar = skill_block_bars[block_index]

		var slot_text: String = str(block_data.get("slot_label", "P%d" % [block_index + 1]))
		var player_name: String = str(block_data.get("player_name", "AGUARDANDO"))
		var ability_name: String = str(block_data.get("ability_name", "SEM HABILIDADE"))
		var cooldown_fill_ratio: float = clampf(float(block_data.get("cooldown_fill_ratio", 0.0)), 0.0, 1.0)
		var is_ready: bool = bool(block_data.get("is_ready", false))
		var is_police: bool = bool(block_data.get("is_police", false))
		var is_active: bool = bool(block_data.get("is_active", false))
		var player_color_variant: Variant = block_data.get("player_color", COLOR_CARD_BORDER_COOLDOWN)
		var player_color: Color = COLOR_CARD_BORDER_COOLDOWN
		if player_color_variant is Color:
			player_color = player_color_variant as Color

		slot_label.text = slot_text
		name_label.text = player_name
		ability_label.text = ability_name
		cooldown_bar.value = cooldown_fill_ratio * 100.0

		var fill_color: Color = COLOR_BAR_FILL_COOLDOWN
		var bar_background_color: Color = COLOR_BAR_BG
		var card_border: Color = Color(player_color.r, player_color.g, player_color.b, 0.95)
		var card_bg: Color = COLOR_CARD_BG
		var player_name_color: Color = player_color.lightened(0.1)
		var ability_text_color: Color = player_color.lightened(0.05)
		var slot_text_color: Color = player_color.lightened(0.12)
		var card_border_width: int = 2
		if not is_active or is_police:
			fill_color = COLOR_BAR_FILL_INACTIVE
			bar_background_color = COLOR_CARD_BG_INACTIVE
		if not is_active:
			card_border = Color(player_color.r, player_color.g, player_color.b, 0.36)
			card_bg = COLOR_CARD_BG_INACTIVE
			player_name_color = Color(player_color.r, player_color.g, player_color.b, 0.56)
			ability_text_color = Color(player_color.r, player_color.g, player_color.b, 0.52)
			slot_text_color = Color(player_color.r, player_color.g, player_color.b, 0.58)
		elif is_police:
			card_border = Color(player_color.r, player_color.g, player_color.b, 0.98)
			card_bg = Color(COLOR_CARD_BG.r + 0.015, COLOR_CARD_BG.g + 0.01, COLOR_CARD_BG.b, COLOR_CARD_BG.a)
			card_border_width = 3
		elif is_ready:
			fill_color = COLOR_BAR_FILL_READY
			card_border = Color(player_color.r, player_color.g, player_color.b, 0.98)
			card_border_width = 3

		skill_block_cards[block_index].add_theme_stylebox_override("panel", _make_skill_block_card_style(card_bg, card_border, card_border_width))
		slot_label.add_theme_color_override("font_color", slot_text_color)
		name_label.add_theme_color_override("font_color", player_name_color)
		ability_label.add_theme_color_override("font_color", ability_text_color)
		cooldown_bar.add_theme_stylebox_override("background", _make_skill_bar_background_style(bar_background_color))
		cooldown_bar.add_theme_stylebox_override("fill", _make_skill_bar_fill_style(fill_color))

func set_status(message: String, color: Color = COLOR_DEFAULT) -> void:
	if message != last_status_text:
		last_status_text = message
		status_label.text = message
	if color != last_status_color:
		last_status_color = color
		status_label.modulate = color
	var has_result_overlay: bool = result_overlay != null and result_overlay.visible
	var should_show: bool = SHOW_TOP_CENTER_STATUS_PANEL and not has_result_overlay and not message.is_empty() and color != COLOR_DEFAULT
	if top_center.visible != should_show:
		top_center.visible = should_show
		_sync_panel_for(top_center)

func set_controls_hint(message: String) -> void:
	if message != last_controls_text:
		last_controls_text = message
		if controls_prompt_strip:
			controls_prompt_strip.set_prompts(_make_control_prompt_items(message))
		controls_label.text = _make_control_detail_text(message)
	var has_result_overlay: bool = result_overlay != null and result_overlay.visible
	var should_show: bool = not has_result_overlay and not message.is_empty()
	if bottom_left.visible != should_show:
		bottom_left.visible = should_show
		_sync_panel_for(bottom_left)

func show_round_result(title: String, subtitle: String, is_success: bool) -> void:
	if result_overlay == null:
		_create_result_overlay()

	is_match_result_visible = false
	_set_gameplay_hud_visible(false)
	if result_backdrop:
		result_backdrop.visible = true
	result_overlay.visible = true
	result_title_label.text = title.to_upper()
	result_subtitle_label.text = subtitle
	var accent: Color = COLOR_SUCCESS if is_success else COLOR_DANGER
	result_title_label.add_theme_color_override("font_color", accent)
	result_overlay.add_theme_stylebox_override("panel", _make_result_style(accent))
	hide_round_start_countdown()
	banner_time = 0.0
	if banner_label:
		banner_label.visible = false
	_apply_responsive_layout()

func show_match_result(title: String, subtitle: String, is_success: bool) -> void:
	show_round_result(title, subtitle, is_success)
	is_match_result_visible = true
	_apply_responsive_layout()

func hide_round_result() -> void:
	is_match_result_visible = false
	if result_overlay:
		result_overlay.visible = false
	if result_backdrop:
		result_backdrop.visible = false
	_set_gameplay_hud_visible(true)
	_sync_panel_for(top_center)

func show_round_start_countdown(round_number: int, seconds_left: int, is_intro_phase: bool = false) -> void:
	if round_start_label == null:
		_create_round_start_label()
	if round_start_label == null:
		return
	var next_text: String = "RODADA %d" % round_number if is_intro_phase else str(maxi(seconds_left, 1))
	if next_text != last_round_start_text:
		last_round_start_text = next_text
		round_start_label.text = next_text
	round_start_label.visible = true
	if is_intro_phase:
		var alpha: float = 0.45 + ((sin(hud_time * 8.0) + 1.0) * 0.5) * 0.55
		round_start_label.modulate = Color(1.0, 1.0, 1.0, alpha)
	else:
		round_start_label.modulate = Color(1.0, 1.0, 1.0, 1.0)

func hide_round_start_countdown() -> void:
	last_round_start_text = ""
	if round_start_label:
		round_start_label.visible = false

func show_round_points_breakdown(points_by_player: Array[Dictionary]) -> void:
	if round_points_overlay == null:
		_create_round_points_overlay()
	if round_points_overlay == null:
		return
	if points_by_player.is_empty():
		hide_round_points_breakdown()
		return

	if round_points_tween != null and round_points_tween.is_valid():
		round_points_tween.kill()

	round_points_overlay.visible = true
	if round_points_confirm_prompt:
		round_points_confirm_prompt.set_prompts([{"prompt": "confirm", "text": "proximo"}])
	var max_total: int = 1
	for item: Dictionary in points_by_player:
		max_total = maxi(max_total, int(item.get("total_points", 0)))
	var display_count: int = mini(points_by_player.size(), round_points_row_containers.size())

	for row_index: int in range(round_points_row_containers.size()):
		var row_visible: bool = row_index < display_count
		round_points_row_containers[row_index].visible = row_visible
		if not row_visible:
			continue

		var row_data: Dictionary = points_by_player[row_index]
		var player_name: String = str(row_data.get("player_name", "PLAYER")).to_upper()
		var gained_points: int = maxi(0, int(row_data.get("gained_points", 0)))
		var total_points: int = maxi(0, int(row_data.get("total_points", 0)))
		var is_police: bool = bool(row_data.get("is_police", false))
		var previous_total: int = maxi(total_points - gained_points, 0)

		round_points_name_labels[row_index].text = player_name
		round_points_gain_labels[row_index].text = "+%d" % gained_points
		round_points_total_labels[row_index].text = "TOTAL %d" % total_points
		var track_width: float = round_points_bar_tracks[row_index].custom_minimum_size.x
		var start_width: float = track_width * (float(previous_total) / float(max_total))
		var target_width: float = track_width * (float(total_points) / float(max_total))
		round_points_bars[row_index].offset_right = start_width

		var fill_color: Color = COLOR_BAR_FILL_READY if gained_points > 0 else COLOR_BAR_FILL_INACTIVE
		if is_police:
			fill_color = COLOR_WARNING if gained_points > 0 else COLOR_BAR_FILL_INACTIVE
		round_points_bars[row_index].color = fill_color
		round_points_bars[row_index].set_meta("target_width", target_width)

	round_points_tween = create_tween()
	round_points_tween.set_parallel(true)
	for row_index: int in range(display_count):
		var target_width: float = float(round_points_bars[row_index].get_meta("target_width", 0.0))
		round_points_tween.tween_property(round_points_bars[row_index], "offset_right", target_width, 1.35).set_delay(float(row_index) * 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func hide_round_points_breakdown() -> void:
	if round_points_tween != null and round_points_tween.is_valid():
		round_points_tween.kill()
	if round_points_overlay:
		round_points_overlay.visible = false

func _set_gameplay_hud_visible(is_visible: bool) -> void:
	top_left.visible = is_visible and SHOW_TOP_LEFT_INFO_PANEL
	top_timer.visible = is_visible
	top_center.visible = false
	bottom_left.visible = false
	if bottom_skills:
		bottom_skills.visible = is_visible
	_sync_panel_for(top_left)
	_sync_panel_for(top_timer)
	_sync_panel_for(top_center)
	_sync_panel_for(bottom_left)

func show_capture_flash(message: String = "CONTAGIO!") -> void:
	capture_flash_time = 0.42
	_show_banner(message, COLOR_DANGER)

func show_round_banner(message: String, duration: float = 1.15, centered: bool = false) -> void:
	_show_banner(message, COLOR_WARNING, duration, centered)

func _apply_hud_style() -> void:
	_create_timer_container()
	_create_match_labels()
	_create_controls_prompt_strip()
	_create_player_skill_blocks()
	_create_panel_for(top_timer, COLOR_PANEL_TIMER)
	_create_panel_for(top_left, COLOR_PANEL_TOP_LEFT)
	_create_panel_for(top_center, COLOR_PANEL_TOP_CENTER)
	_create_panel_for(bottom_left, COLOR_PANEL_CONTROLS)
	_create_screen_flash()
	_create_hud_heist_icons()
	_create_banner()
	_create_round_start_label()
	_create_result_overlay()
	_create_round_points_overlay()
	info_column.add_theme_constant_override("separation", 4)

	time_label.add_theme_color_override("font_color", COLOR_WARNING)
	time_label.add_theme_font_override("font", FONT_ARCADE)
	time_label.add_theme_color_override("font_shadow_color", Color(0.965, 0.757, 0.216, 0.62))
	time_label.add_theme_color_override("font_outline_color", Color(0.008, 0.012, 0.027, 0.82))
	time_label.add_theme_constant_override("outline_size", 5)
	time_label.add_theme_constant_override("shadow_offset_x", 0)
	time_label.add_theme_constant_override("shadow_offset_y", 4)
	time_label.add_theme_font_size_override("font_size", 18)
	fugitives_label.add_theme_color_override("font_color", COLOR_SUCCESS)
	fugitives_label.add_theme_font_override("font", FONT_UI)
	fugitives_label.add_theme_color_override("font_outline_color", Color(0.008, 0.012, 0.027, 0.76))
	fugitives_label.add_theme_constant_override("outline_size", 3)
	fugitives_label.add_theme_font_size_override("font_size", 13)
	skill_label.add_theme_color_override("font_color", COLOR_CYAN)
	skill_label.add_theme_font_override("font", FONT_UI)
	skill_label.add_theme_color_override("font_outline_color", Color(0.008, 0.012, 0.027, 0.76))
	skill_label.add_theme_constant_override("outline_size", 3)
	skill_label.add_theme_font_size_override("font_size", 12)
	status_label.add_theme_color_override("font_outline_color", Color(0.008, 0.012, 0.027, 0.82))
	status_label.add_theme_font_override("font", FONT_UI)
	status_label.add_theme_constant_override("outline_size", 4)
	status_label.add_theme_font_size_override("font_size", 14)
	controls_label.add_theme_color_override("font_color", COLOR_MUTED)
	controls_label.add_theme_font_override("font", FONT_UI)
	controls_label.add_theme_color_override("font_outline_color", Color(0.008, 0.012, 0.027, 0.72))
	controls_label.add_theme_constant_override("outline_size", 2)

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

func _create_player_skill_blocks() -> void:
	if bottom_skills != null:
		return

	bottom_skills = MarginContainer.new()
	bottom_skills.name = "BottomSkills"
	bottom_skills.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Control.add_child(bottom_skills)

	var row: HBoxContainer = HBoxContainer.new()
	row.name = "SkillBlocksRow"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	bottom_skills.add_child(row)

	for block_index: int in range(4):
		var card: PanelContainer = PanelContainer.new()
		card.name = "SkillBlockCard%d" % block_index
		card.custom_minimum_size = Vector2(220.0, 76.0)
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_theme_stylebox_override("panel", _make_skill_block_card_style(COLOR_CARD_BG, COLOR_CARD_BORDER_INACTIVE))
		row.add_child(card)

		var column: VBoxContainer = VBoxContainer.new()
		column.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.add_theme_constant_override("separation", 2)
		card.add_child(column)

		var top_row: HBoxContainer = HBoxContainer.new()
		top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		top_row.add_theme_constant_override("separation", 6)
		column.add_child(top_row)

		var slot_label: Label = Label.new()
		slot_label.text = "P%d" % [block_index + 1]
		slot_label.add_theme_font_override("font", FONT_UI)
		slot_label.add_theme_font_size_override("font_size", 11)
		slot_label.add_theme_color_override("font_color", COLOR_CARD_BORDER_COOLDOWN)
		slot_label.add_theme_color_override("font_outline_color", Color(0.008, 0.012, 0.027, 0.76))
		slot_label.add_theme_constant_override("outline_size", 2)
		top_row.add_child(slot_label)

		var name_label: Label = Label.new()
		name_label.text = "AGUARDANDO"
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		name_label.clip_text = true
		name_label.add_theme_font_override("font", FONT_UI)
		name_label.add_theme_font_size_override("font_size", 11)
		name_label.add_theme_color_override("font_color", COLOR_DEFAULT)
		name_label.add_theme_color_override("font_outline_color", Color(0.008, 0.012, 0.027, 0.76))
		name_label.add_theme_constant_override("outline_size", 2)
		top_row.add_child(name_label)

		var ability_label: Label = Label.new()
		ability_label.text = "SEM HABILIDADE"
		ability_label.clip_text = true
		ability_label.add_theme_font_override("font", FONT_UI)
		ability_label.add_theme_font_size_override("font_size", 10)
		ability_label.add_theme_color_override("font_color", COLOR_CYAN)
		ability_label.add_theme_color_override("font_outline_color", Color(0.008, 0.012, 0.027, 0.76))
		ability_label.add_theme_constant_override("outline_size", 2)
		column.add_child(ability_label)

		var cooldown_bar: ProgressBar = ProgressBar.new()
		cooldown_bar.min_value = 0.0
		cooldown_bar.max_value = 100.0
		cooldown_bar.value = 0.0
		cooldown_bar.show_percentage = false
		cooldown_bar.custom_minimum_size = Vector2(0.0, 16.0)
		cooldown_bar.add_theme_stylebox_override("background", _make_skill_bar_background_style(COLOR_BAR_BG))
		cooldown_bar.add_theme_stylebox_override("fill", _make_skill_bar_fill_style(COLOR_BAR_FILL_COOLDOWN))
		column.add_child(cooldown_bar)

		skill_block_cards.append(card)
		skill_block_slot_labels.append(slot_label)
		skill_block_name_labels.append(name_label)
		skill_block_ability_labels.append(ability_label)
		skill_block_bars.append(cooldown_bar)

func _make_skill_block_card_style(fill_color: Color = COLOR_CARD_BG, border_color: Color = COLOR_BORDER, border_width: int = 2) -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = fill_color
	style_box.border_color = border_color
	style_box.set_border_width_all(border_width)
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.shadow_color = Color(0.008, 0.012, 0.027, 0.56)
	style_box.shadow_size = 6
	style_box.content_margin_left = 10
	style_box.content_margin_right = 10
	style_box.content_margin_top = 7
	style_box.content_margin_bottom = 7
	return style_box

func _make_skill_bar_background_style(background_color: Color = COLOR_BAR_BG) -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = background_color
	style_box.corner_radius_top_left = 4
	style_box.corner_radius_top_right = 4
	style_box.corner_radius_bottom_right = 4
	style_box.corner_radius_bottom_left = 4
	style_box.border_color = Color(0.122, 0.169, 0.271, 0.88)
	style_box.set_border_width_all(1)
	return style_box

func _make_skill_bar_fill_style(fill_color: Color) -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = fill_color
	style_box.corner_radius_top_left = 4
	style_box.corner_radius_top_right = 4
	style_box.corner_radius_bottom_right = 4
	style_box.corner_radius_bottom_left = 4
	return style_box

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
		return "Skill: E (teclado 1), ESPACO (teclado 2) ou R1"
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
	var skills_height: float = 92.0 if is_compact else (118.0 if is_large else 102.0)
	var controls_gap: float = 20.0 if is_compact else (30.0 if is_large else 24.0)
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
	bottom_left.offset_top = viewport_size.y - bottom_margin - skills_height - controls_gap - bottom_height
	bottom_left.offset_right = minf(safe_left + 640.0, viewport_size.x - safe_left)
	bottom_left.offset_bottom = bottom_left.offset_top + bottom_height

	if bottom_skills != null:
		bottom_skills.anchor_left = 0.0
		bottom_skills.anchor_top = 0.0
		bottom_skills.anchor_right = 1.0
		bottom_skills.anchor_bottom = 0.0
		bottom_skills.offset_left = safe_left
		bottom_skills.offset_top = viewport_size.y - bottom_margin - skills_height
		bottom_skills.offset_right = -safe_left
		bottom_skills.offset_bottom = viewport_size.y - bottom_margin

	var skill_name_font_size: int = 10 if is_compact else (13 if is_large else 11)
	var skill_ability_font_size: int = 9 if is_compact else (12 if is_large else 10)
	var skill_slot_font_size: int = 9 if is_compact else (11 if is_large else 10)
	var skill_bar_height: float = 12.0 if is_compact else (18.0 if is_large else 14.0)
	var skill_card_min_height: float = 64.0 if is_compact else (88.0 if is_large else 74.0)
	for block_index: int in range(skill_block_cards.size()):
		skill_block_cards[block_index].custom_minimum_size = Vector2(180.0 if is_compact else (248.0 if is_large else 214.0), skill_card_min_height)
		skill_block_slot_labels[block_index].add_theme_font_size_override("font_size", skill_slot_font_size)
		skill_block_name_labels[block_index].add_theme_font_size_override("font_size", skill_name_font_size)
		skill_block_ability_labels[block_index].add_theme_font_size_override("font_size", skill_ability_font_size)
		skill_block_bars[block_index].custom_minimum_size = Vector2(0.0, skill_bar_height)

	match_label.add_theme_font_size_override("font_size", 10 if is_compact else (13 if is_large else 11))
	score_label.add_theme_font_size_override("font_size", 10 if is_compact else (12 if is_large else 11))
	time_label.add_theme_font_size_override("font_size", 18 if is_compact else (26 if is_large else 22))
	fugitives_label.add_theme_font_size_override("font_size", 12 if is_compact else (15 if is_large else 13))
	skill_label.add_theme_font_size_override("font_size", 11 if is_compact else (14 if is_large else 12))
	status_label.add_theme_font_size_override("font_size", 13 if is_compact else (17 if is_large else 15))
	controls_label.add_theme_font_size_override("font_size", 14 if is_compact else (18 if is_large else 16))
	if controls_prompt_strip:
		controls_prompt_strip.set_prompt_size(24 if is_compact else (34 if is_large else 28), 12 if is_compact else (17 if is_large else 14))
	_update_timer_pivot()

	if banner_label:
		if banner_centered:
			banner_label.set_anchors_preset(Control.PRESET_CENTER)
			banner_label.offset_left = -340.0 if is_compact else -520.0
			banner_label.offset_top = -40.0 if is_compact else -56.0
			banner_label.offset_right = 340.0 if is_compact else 520.0
			banner_label.offset_bottom = 40.0 if is_compact else 56.0
		else:
			banner_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
			banner_label.offset_left = -300.0 if is_compact else -380.0
			banner_label.offset_top = 74.0 if is_compact else 96.0
			banner_label.offset_right = 300.0 if is_compact else 380.0
			banner_label.offset_bottom = 126.0 if is_compact else 154.0
		banner_label.add_theme_font_size_override("font_size", 20 if is_compact else (30 if is_large else 24))

	if result_overlay:
		result_overlay.offset_left = -360.0 if is_compact else -460.0
		result_overlay.offset_right = 360.0 if is_compact else 460.0
		if is_match_result_visible:
			result_overlay.offset_top = -192.0 if is_compact else -242.0
			result_overlay.offset_bottom = 192.0 if is_compact else 242.0
		else:
			result_overlay.offset_top = -128.0 if is_compact else -164.0
			result_overlay.offset_bottom = 128.0 if is_compact else 164.0
	if result_title_label:
		result_title_label.add_theme_font_size_override("font_size", 38 if is_compact else (56 if is_large else 50))
	if result_subtitle_label:
		if is_match_result_visible:
			result_subtitle_label.add_theme_font_size_override("font_size", 13 if is_compact else (18 if is_large else 16))
		else:
			result_subtitle_label.add_theme_font_size_override("font_size", 20 if is_compact else (27 if is_large else 24))
	if round_start_label:
		round_start_label.add_theme_font_size_override("font_size", 42 if is_compact else (66 if is_large else 54))
	if round_points_overlay:
		round_points_overlay.offset_left = -330.0 if is_compact else (-470.0 if is_large else -410.0)
		round_points_overlay.offset_top = -112.0 if is_compact else (-152.0 if is_large else -132.0)
		round_points_overlay.offset_right = 330.0 if is_compact else (470.0 if is_large else 410.0)
		round_points_overlay.offset_bottom = 112.0 if is_compact else (152.0 if is_large else 132.0)
	if round_points_title_label:
		round_points_title_label.add_theme_font_size_override("font_size", 13 if is_compact else (18 if is_large else 16))
	if round_points_confirm_prompt:
		round_points_confirm_prompt.set_prompt_size(22 if is_compact else (30 if is_large else 26), 11 if is_compact else (14 if is_large else 12))
	for row_index: int in range(round_points_name_labels.size()):
		round_points_name_labels[row_index].add_theme_font_size_override("font_size", 11 if is_compact else (14 if is_large else 13))
		round_points_gain_labels[row_index].add_theme_font_size_override("font_size", 11 if is_compact else (14 if is_large else 13))
		round_points_total_labels[row_index].add_theme_font_size_override("font_size", 9 if is_compact else (12 if is_large else 11))
		round_points_bar_tracks[row_index].custom_minimum_size = Vector2(220.0 if is_compact else (340.0 if is_large else 290.0), 14.0 if is_compact else (20.0 if is_large else 17.0))

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
	style_box.set_border_width_all(3)
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.shadow_color = Color(0.008, 0.012, 0.027, 0.68)
	style_box.shadow_size = 10
	style_box.content_margin_left = 12
	style_box.content_margin_right = 12
	style_box.content_margin_top = 9
	style_box.content_margin_bottom = 9
	return style_box

func _make_depth_shadow_style() -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color(0.0, 0.0, 0.0, 0.4)
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_right = 10
	style_box.corner_radius_bottom_left = 10
	return style_box

func _short_label(text: String) -> String:
	var cleaned_text: String = text.to_upper()
	if cleaned_text.length() <= 4:
		return cleaned_text
	return cleaned_text.substr(0, 4)

func _update_timer_pivot() -> void:
	if time_label == null:
		return
	time_label.pivot_offset = time_label.size * 0.5

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
	if cash_icon:
		cash_icon.visible = SHOW_TOP_LEFT_INFO_PANEL
	if alarm_icon:
		alarm_icon.visible = SHOW_TOP_LEFT_INFO_PANEL and capture_flash_time > 0.0
	if not SHOW_TOP_LEFT_INFO_PANEL:
		return
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
	banner_label.add_theme_color_override("font_outline_color", Color(0.008, 0.012, 0.027, 0.95))
	banner_label.add_theme_constant_override("outline_size", 10)
	$Control.add_child(banner_label)

func _create_round_start_label() -> void:
	if round_start_label != null:
		return

	round_start_label = Label.new()
	round_start_label.name = "RoundStartLabel"
	round_start_label.visible = false
	round_start_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	round_start_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	round_start_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	round_start_label.add_theme_font_override("font", FONT_ARCADE)
	round_start_label.add_theme_font_size_override("font_size", 54)
	round_start_label.add_theme_color_override("font_color", COLOR_WARNING)
	round_start_label.add_theme_color_override("font_outline_color", Color(0.008, 0.012, 0.027, 0.9))
	round_start_label.add_theme_constant_override("outline_size", 8)
	round_start_label.set_anchors_preset(Control.PRESET_CENTER)
	round_start_label.offset_left = -260.0
	round_start_label.offset_top = -72.0
	round_start_label.offset_right = 260.0
	round_start_label.offset_bottom = 72.0
	$Control.add_child(round_start_label)

func _show_banner(message: String, color: Color, duration: float = 1.15, centered: bool = false) -> void:
	if banner_label == null:
		return
	banner_centered = centered
	banner_label.text = message.to_upper()
	banner_label.add_theme_color_override("font_color", color)
	banner_time = maxf(duration, 0.01)
	_apply_responsive_layout()

func _create_round_points_overlay() -> void:
	if round_points_overlay != null:
		return

	round_points_overlay = PanelContainer.new()
	round_points_overlay.name = "RoundPointsOverlay"
	round_points_overlay.visible = false
	round_points_overlay.set_anchors_preset(Control.PRESET_CENTER)
	round_points_overlay.offset_left = -420.0
	round_points_overlay.offset_top = -132.0
	round_points_overlay.offset_right = 420.0
	round_points_overlay.offset_bottom = 132.0
	round_points_overlay.add_theme_stylebox_override("panel", _make_result_style(COLOR_CYAN))
	$Control.add_child(round_points_overlay)

	var column: VBoxContainer = VBoxContainer.new()
	column.name = "RoundPointsColumn"
	column.add_theme_constant_override("separation", 8)
	round_points_overlay.add_child(column)

	round_points_title_label = Label.new()
	round_points_title_label.name = "RoundPointsTitle"
	round_points_title_label.text = "PONTOS DA RODADA"
	round_points_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	round_points_title_label.add_theme_font_override("font", FONT_UI)
	round_points_title_label.add_theme_font_size_override("font_size", 16)
	round_points_title_label.add_theme_color_override("font_color", COLOR_CYAN)
	round_points_title_label.add_theme_color_override("font_outline_color", Color(0.008, 0.012, 0.027, 0.82))
	round_points_title_label.add_theme_constant_override("outline_size", 3)
	column.add_child(round_points_title_label)

	for row_index: int in range(4):
		var row: HBoxContainer = HBoxContainer.new()
		row.name = "RoundPointsRow%d" % row_index
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 8)
		column.add_child(row)

		var name_label: Label = Label.new()
		name_label.text = "PLAYER"
		name_label.custom_minimum_size = Vector2(118.0, 0.0)
		name_label.clip_text = true
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		name_label.add_theme_font_override("font", FONT_UI)
		name_label.add_theme_font_size_override("font_size", 13)
		name_label.add_theme_color_override("font_color", COLOR_DEFAULT)
		name_label.add_theme_color_override("font_outline_color", Color(0.008, 0.012, 0.027, 0.72))
		name_label.add_theme_constant_override("outline_size", 2)
		row.add_child(name_label)

		var bar_track: Panel = Panel.new()
		bar_track.name = "RoundPointsTrack"
		bar_track.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar_track.custom_minimum_size = Vector2(280.0, 18.0)
		bar_track.add_theme_stylebox_override("panel", _make_skill_bar_background_style(COLOR_BAR_BG))
		row.add_child(bar_track)

		var bar: ColorRect = ColorRect.new()
		bar.name = "RoundPointsFill"
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.anchor_left = 0.0
		bar.anchor_top = 0.0
		bar.anchor_right = 0.0
		bar.anchor_bottom = 1.0
		bar.offset_left = 0.0
		bar.offset_top = 0.0
		bar.offset_right = 0.0
		bar.offset_bottom = 0.0
		bar.color = COLOR_BAR_FILL_COOLDOWN
		bar_track.add_child(bar)

		var gain_label: Label = Label.new()
		gain_label.text = "+0"
		gain_label.custom_minimum_size = Vector2(48.0, 0.0)
		gain_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		gain_label.add_theme_font_override("font", FONT_UI)
		gain_label.add_theme_font_size_override("font_size", 13)
		gain_label.add_theme_color_override("font_color", COLOR_SUCCESS)
		gain_label.add_theme_color_override("font_outline_color", Color(0.008, 0.012, 0.027, 0.72))
		gain_label.add_theme_constant_override("outline_size", 2)
		row.add_child(gain_label)

		var total_label: Label = Label.new()
		total_label.text = "TOTAL 0"
		total_label.custom_minimum_size = Vector2(90.0, 0.0)
		total_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		total_label.add_theme_font_override("font", FONT_UI)
		total_label.add_theme_font_size_override("font_size", 11)
		total_label.add_theme_color_override("font_color", COLOR_MUTED)
		total_label.add_theme_color_override("font_outline_color", Color(0.008, 0.012, 0.027, 0.72))
		total_label.add_theme_constant_override("outline_size", 2)
		row.add_child(total_label)

		round_points_row_containers.append(row)
		round_points_name_labels.append(name_label)
		round_points_bar_tracks.append(bar_track)
		round_points_bars.append(bar)
		round_points_gain_labels.append(gain_label)
		round_points_total_labels.append(total_label)

	var confirm_row: HBoxContainer = HBoxContainer.new()
	confirm_row.name = "RoundPointsConfirmRow"
	confirm_row.alignment = BoxContainer.ALIGNMENT_END
	confirm_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_child(confirm_row)

	round_points_confirm_prompt = ControllerPromptStrip.new()
	round_points_confirm_prompt.name = "RoundPointsConfirmPrompt"
	round_points_confirm_prompt.set_prompt_size(26, 12)
	round_points_confirm_prompt.set_prompts([{"prompt": "confirm", "text": "proximo"}])
	confirm_row.add_child(round_points_confirm_prompt)

func _create_result_overlay() -> void:
	if result_overlay != null:
		return

	result_backdrop = ColorRect.new()
	result_backdrop.name = "ResultBackdrop"
	result_backdrop.visible = false
	result_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	result_backdrop.color = Color(0.0, 0.0, 0.0, 0.36)
	$Control.add_child(result_backdrop)

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
	result_title_label.add_theme_color_override("font_outline_color", Color(0.008, 0.012, 0.027, 0.88))
	result_title_label.add_theme_constant_override("outline_size", 9)
	column.add_child(result_title_label)

	result_subtitle_label = Label.new()
	result_subtitle_label.name = "ResultSubtitle"
	result_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_subtitle_label.add_theme_font_size_override("font_size", 24)
	result_subtitle_label.add_theme_font_override("font", FONT_UI)
	result_subtitle_label.add_theme_color_override("font_color", COLOR_DEFAULT)
	result_subtitle_label.add_theme_color_override("font_outline_color", Color(0.008, 0.012, 0.027, 0.78))
	result_subtitle_label.add_theme_constant_override("outline_size", 3)
	column.add_child(result_subtitle_label)

func _make_result_style(accent: Color) -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color(0.016, 0.027, 0.075, 0.97)
	style_box.border_color = accent
	style_box.set_border_width_all(6)
	style_box.corner_radius_top_left = 20
	style_box.corner_radius_top_right = 20
	style_box.corner_radius_bottom_right = 20
	style_box.corner_radius_bottom_left = 20
	style_box.shadow_color = accent.darkened(0.55)
	style_box.shadow_size = 36
	style_box.content_margin_left = 44
	style_box.content_margin_right = 44
	style_box.content_margin_top = 36
	style_box.content_margin_bottom = 36
	return style_box
