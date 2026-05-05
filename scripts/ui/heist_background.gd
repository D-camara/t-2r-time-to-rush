class_name HeistBackground
extends Control

const BACKGROUND: Color = Color(0.043, 0.063, 0.125, 1.0)
const BACKGROUND_SECONDARY: Color = Color(0.071, 0.102, 0.169, 1.0)
const GRID_LINE: Color = Color(0.133, 0.196, 0.322, 0.22)
const MONEY_GLOW: Color = Color(0.133, 0.773, 0.369, 0.16)
const GOLD_GLOW: Color = Color(0.918, 0.702, 0.031, 0.12)
const CYAN_LINE: Color = Color(0.22, 0.741, 0.973, 0.18)
const ALARM_LINE: Color = Color(0.937, 0.267, 0.267, 0.16)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)

func _draw() -> void:
	var rect_size: Vector2 = size
	var bands: int = 26
	for band: int in range(bands):
		var weight: float = float(band) / float(max(bands - 1, 1))
		var band_color: Color = BACKGROUND.lerp(BACKGROUND_SECONDARY, weight * 0.86)
		draw_rect(
			Rect2(0.0, rect_size.y * weight, rect_size.x, rect_size.y / float(bands) + 1.0),
			band_color
		)

	draw_circle(Vector2(rect_size.x * 0.52, rect_size.y * 0.4), min(rect_size.x, rect_size.y) * 0.62, Color(0.0, 0.0, 0.0, 0.22))
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
	draw_circle(Vector2(rect_size.x * 0.48, rect_size.y * 0.18), 160.0, Color(0.937, 0.267, 0.267, 0.08))
	_draw_vault_door(Vector2(rect_size.x * 0.77, rect_size.y * 0.36), min(rect_size.x, rect_size.y) * 0.21)
	_draw_physical_table(Vector2(rect_size.x * 0.28, rect_size.y * 0.64), min(rect_size.x, rect_size.y) * 0.26)
	_draw_security_lanes(rect_size)

func _draw_vault_door(center: Vector2, radius: float) -> void:
	draw_arc(center, radius, 0.0, TAU, 96, Color(0.918, 0.702, 0.031, 0.2), 3.0)
	draw_arc(center, radius * 0.72, 0.0, TAU, 96, Color(0.22, 0.741, 0.973, 0.16), 2.0)
	draw_arc(center, radius * 0.42, 0.0, TAU, 96, Color(0.898, 0.933, 0.973, 0.12), 2.0)

	for spoke: int in range(8):
		var angle: float = TAU * float(spoke) / 8.0
		var inner: Vector2 = center + Vector2(cos(angle), sin(angle)) * radius * 0.18
		var outer: Vector2 = center + Vector2(cos(angle), sin(angle)) * radius * 0.66
		draw_line(inner, outer, Color(0.918, 0.702, 0.031, 0.15), 2.0)

func _draw_security_lanes(rect_size: Vector2) -> void:
	var lane_y: float = rect_size.y * 0.82
	for lane: int in range(9):
		var x: float = rect_size.x * 0.08 + float(lane) * rect_size.x * 0.095
		draw_line(Vector2(x, lane_y), Vector2(x + rect_size.x * 0.045, lane_y - 34.0), CYAN_LINE, 3.0)

	draw_line(Vector2(0.0, rect_size.y * 0.12), Vector2(rect_size.x, rect_size.y * 0.18), ALARM_LINE, 2.0)
	draw_line(Vector2(0.0, rect_size.y * 0.9), Vector2(rect_size.x, rect_size.y * 0.74), ALARM_LINE, 2.0)

func _draw_physical_table(center: Vector2, radius: float) -> void:
	var shadow_rect: Rect2 = Rect2(center - Vector2(radius * 1.36, radius * 0.52), Vector2(radius * 2.72, radius * 1.04))
	draw_rect(Rect2(shadow_rect.position + Vector2(16.0, 18.0), shadow_rect.size), Color(0.0, 0.0, 0.0, 0.28))
	draw_rect(shadow_rect, Color(0.094, 0.133, 0.208, 0.34))
	draw_rect(Rect2(shadow_rect.position + Vector2(10.0, 10.0), shadow_rect.size - Vector2(20.0, 20.0)), Color(0.22, 0.741, 0.973, 0.08))
	for index: int in range(5):
		var offset: float = -radius * 0.9 + float(index) * radius * 0.45
		draw_line(center + Vector2(offset, -radius * 0.42), center + Vector2(offset + radius * 0.2, radius * 0.42), Color(0.918, 0.702, 0.031, 0.13), 4.0)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
