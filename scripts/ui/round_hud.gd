class_name RoundHud
extends CanvasLayer

@onready var time_label: Label = $Control/TopLeft/InfoColumn/TimeLabel
@onready var fugitives_label: Label = $Control/TopLeft/InfoColumn/FugitivesLabel
@onready var status_label: Label = $Control/TopCenter/StatusLabel
@onready var controls_label: Label = $Control/BottomLeft/ControlsLabel

const COLOR_DEFAULT: Color = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_WARNING: Color = Color(1.0, 0.82, 0.2, 1.0)
const COLOR_DANGER: Color = Color(1.0, 0.35, 0.35, 1.0)
const COLOR_SUCCESS: Color = Color(0.48, 1.0, 0.56, 1.0)
const COLOR_INFO: Color = Color(0.55, 0.82, 1.0, 1.0)

func _ready() -> void:
	controls_label.text = "WASD: Fugitivo | DualSense: Policia | R: Reiniciar"
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
