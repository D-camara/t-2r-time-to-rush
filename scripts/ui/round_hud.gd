class_name RoundHud
extends CanvasLayer

@onready var time_label: Label = $Control/TopLeft/InfoColumn/TimeLabel
@onready var fugitives_label: Label = $Control/TopLeft/InfoColumn/FugitivesLabel
@onready var status_label: Label = $Control/TopCenter/StatusLabel
@onready var controls_label: Label = $Control/BottomLeft/ControlsLabel

func _ready() -> void:
	controls_label.text = "WASD: Fugitivo | DualSense: Policia | R: Reiniciar"

func update_timer(time_left: float) -> void:
	time_label.text = "Tempo: %02d" % int(ceil(time_left))

func update_active_fugitives(active_count: int, total_count: int) -> void:
	fugitives_label.text = "Fugitivo ativo: %d/%d" % [active_count, total_count]

func set_status(message: String) -> void:
	status_label.text = message
