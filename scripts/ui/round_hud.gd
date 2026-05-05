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

func _ready() -> void:
	_apply_hud_style()
	controls_label.text = "Controle 1 vira Policia | Capturados viram pegadores | R: Reiniciar"
	status_label.modulate = COLOR_DEFAULT
	time_label.modulate = COLOR_DEFAULT

func update_timer(time_left: float, is_warning: bool = false) -> void:
	time_label.text = "Tempo: %02d" % int(ceil(time_left))
	time_label.modulate = COLOR_WARNING if is_warning else COLOR_DEFAULT

func update_active_fugitives(active_count: int, total_count: int) -> void:
	fugitives_label.text = "Fugitivos livres: %d/%d" % [active_count, total_count]

func set_status(message: String, color: Color = COLOR_DEFAULT) -> void:
	status_label.text = message
	status_label.modulate = color

func set_controls_hint(message: String) -> void:
	controls_label.text = message

func _apply_hud_style() -> void:
	_create_panel_for(top_left, Color(0.094, 0.133, 0.208, 0.9))
	_create_panel_for(top_center, Color(0.094, 0.133, 0.208, 0.78))
	_create_panel_for(bottom_left, Color(0.043, 0.063, 0.125, 0.72))

	time_label.add_theme_color_override("font_color", COLOR_WARNING)
	time_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.72))
	time_label.add_theme_constant_override("outline_size", 4)
	fugitives_label.add_theme_color_override("font_color", COLOR_SUCCESS)
	fugitives_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.72))
	fugitives_label.add_theme_constant_override("outline_size", 3)
	status_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.75))
	status_label.add_theme_constant_override("outline_size", 4)
	controls_label.add_theme_color_override("font_color", COLOR_MUTED)
	controls_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.65))
	controls_label.add_theme_constant_override("outline_size", 3)

func _create_panel_for(target: Control, fill: Color) -> void:
	var parent: Control = target.get_parent() as Control
	if parent == null:
		return

	var panel: Panel = Panel.new()
	panel.name = "%sCard" % target.name
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.anchor_left = target.anchor_left
	panel.anchor_top = target.anchor_top
	panel.anchor_right = target.anchor_right
	panel.anchor_bottom = target.anchor_bottom
	panel.offset_left = target.offset_left - 10.0
	panel.offset_top = target.offset_top - 8.0
	panel.offset_right = target.offset_right + 10.0
	panel.offset_bottom = target.offset_bottom + 8.0
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
	style_box.shadow_color = Color(0.0, 0.0, 0.0, 0.28)
	style_box.shadow_size = 8
	return style_box
