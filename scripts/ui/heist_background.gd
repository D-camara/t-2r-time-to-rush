class_name HeistBackground
extends Control

const BACKGROUND: Color = Color(0.043, 0.063, 0.125, 1.0)
const BACKGROUND_SECONDARY: Color = Color(0.071, 0.102, 0.169, 1.0)
const GRID_LINE: Color = Color(0.133, 0.196, 0.322, 0.22)
const MONEY_GLOW: Color = Color(0.133, 0.773, 0.369, 0.16)
const GOLD_GLOW: Color = Color(0.918, 0.702, 0.031, 0.12)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)

func _draw() -> void:
	var rect_size: Vector2 = size
	var bands: int = 18
	for band: int in range(bands):
		var weight: float = float(band) / float(max(bands - 1, 1))
		var band_color: Color = BACKGROUND.lerp(BACKGROUND_SECONDARY, weight * 0.75)
		draw_rect(
			Rect2(0.0, rect_size.y * weight, rect_size.x, rect_size.y / float(bands) + 1.0),
			band_color
		)

	var grid_gap: float = 42.0
	var x: float = 0.0
	while x <= rect_size.x:
		draw_line(Vector2(x, 0.0), Vector2(x, rect_size.y), GRID_LINE, 1.0)
		x += grid_gap

	var y: float = 0.0
	while y <= rect_size.y:
		draw_line(Vector2(0.0, y), Vector2(rect_size.x, y), GRID_LINE, 1.0)
		y += grid_gap

	draw_circle(Vector2(rect_size.x * 0.18, rect_size.y * 0.22), 180.0, MONEY_GLOW)
	draw_circle(Vector2(rect_size.x * 0.86, rect_size.y * 0.78), 220.0, GOLD_GLOW)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
