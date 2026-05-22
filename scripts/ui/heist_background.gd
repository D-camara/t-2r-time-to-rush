class_name HeistBackground
extends Control

const BG_TOP: Color = Color(0.02, 0.031, 0.086, 1.0)
const BG_BOTTOM: Color = Color(0.043, 0.063, 0.125, 1.0)
const PANEL_DARK: Color = Color(0.067, 0.094, 0.153, 0.72)
const MONEY_GREEN: Color = Color(0.133, 0.773, 0.369, 1.0)
const GREEN_GLOW: Color = Color(0.29, 0.871, 0.502, 1.0)
const GOLD: Color = Color(0.918, 0.702, 0.031, 1.0)
const ALARM: Color = Color(0.937, 0.267, 0.267, 1.0)
const CHASE_ORANGE: Color = Color(0.976, 0.451, 0.086, 1.0)
const CYAN: Color = Color(0.22, 0.741, 0.973, 1.0)
const GRID: Color = Color(0.133, 0.196, 0.322, 0.26)

var animation_time: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)

func _process(delta: float) -> void:
	animation_time += delta
	queue_redraw()

func _draw() -> void:
	var rect_size: Vector2 = size
	if rect_size.x <= 0.0 or rect_size.y <= 0.0:
		return

	_draw_layered_gradient(rect_size)
	_draw_tactical_grid(rect_size)
	_draw_floating_bills(rect_size)
	_draw_light_beams(rect_size)
	_draw_security_lanes(rect_size)
	_draw_bank_facade(Vector2(rect_size.x * 0.5, rect_size.y * 0.17), min(rect_size.x, rect_size.y) * 0.22)
	_draw_vault_door(Vector2(rect_size.x * 0.78, rect_size.y * 0.42), min(rect_size.x, rect_size.y) * 0.245)
	_draw_money_stack(Vector2(rect_size.x * 0.12, rect_size.y * 0.78), min(rect_size.x, rect_size.y) * 0.19)
	_draw_alarm_panel(Vector2(rect_size.x * 0.58, rect_size.y * 0.16), min(rect_size.x, rect_size.y) * 0.115)
	_draw_physical_table(Vector2(rect_size.x * 0.36, rect_size.y * 0.62), min(rect_size.x, rect_size.y) * 0.28)
	_draw_vignette(rect_size)

func _draw_layered_gradient(rect_size: Vector2) -> void:
	var bands: int = 34
	for band: int in range(bands):
		var weight: float = float(band) / float(max(bands - 1, 1))
		var band_color: Color = BG_TOP.lerp(BG_BOTTOM, weight)
		draw_rect(Rect2(0.0, rect_size.y * weight, rect_size.x, rect_size.y / float(bands) + 1.0), band_color)

	var pulse: float = (sin(animation_time * 1.35) + 1.0) * 0.5
	draw_circle(Vector2(rect_size.x * 0.24, rect_size.y * 0.22), rect_size.y * 0.34, Color(MONEY_GREEN.r, MONEY_GREEN.g, MONEY_GREEN.b, 0.08 + pulse * 0.035))
	draw_circle(Vector2(rect_size.x * 0.83, rect_size.y * 0.72), rect_size.y * 0.42, Color(GOLD.r, GOLD.g, GOLD.b, 0.07))
	draw_circle(Vector2(rect_size.x * 0.62, rect_size.y * 0.18), rect_size.y * 0.25, Color(ALARM.r, ALARM.g, ALARM.b, 0.06 + pulse * 0.03))

func _draw_tactical_grid(rect_size: Vector2) -> void:
	var grid_gap: float = 42.0
	var drift: float = fposmod(animation_time * 8.0, grid_gap)
	var x: float = -grid_gap + drift
	while x <= rect_size.x + grid_gap:
		draw_line(Vector2(x, 0.0), Vector2(x - rect_size.y * 0.18, rect_size.y), GRID, 1.0)
		x += grid_gap

	var y: float = -grid_gap + drift * 0.55
	while y <= rect_size.y + grid_gap:
		draw_line(Vector2(0.0, y), Vector2(rect_size.x, y + rect_size.x * 0.055), Color(GRID.r, GRID.g, GRID.b, 0.18), 1.0)
		y += grid_gap

func _draw_light_beams(rect_size: Vector2) -> void:
	var sweep: float = sin(animation_time * 0.9) * rect_size.x * 0.025
	var beam_color: Color = Color(CYAN.r, CYAN.g, CYAN.b, 0.075)
	for index: int in range(3):
		var start_x: float = rect_size.x * (0.12 + float(index) * 0.27) + sweep
		var points: PackedVector2Array = PackedVector2Array([
			Vector2(start_x, 0.0),
			Vector2(start_x + rect_size.x * 0.16, 0.0),
			Vector2(start_x + rect_size.x * 0.33, rect_size.y),
			Vector2(start_x + rect_size.x * 0.17, rect_size.y),
		])
		draw_colored_polygon(points, beam_color)

func _draw_floating_bills(rect_size: Vector2) -> void:
	for index: int in range(24):
		var wave: float = sin(animation_time * 0.8 + float(index) * 1.7)
		var x: float = fposmod(float(index) * rect_size.x * 0.149 + animation_time * 24.0, rect_size.x + 90.0) - 45.0
		var y: float = rect_size.y * (0.18 + fposmod(float(index) * 0.137, 0.68)) + wave * 18.0
		var bill_size: Vector2 = Vector2(46.0 + float(index % 3) * 8.0, 20.0)
		var bill: Rect2 = Rect2(Vector2(x, y), bill_size)
		draw_rect(Rect2(bill.position + Vector2(4.0, 5.0), bill.size), Color(0.0, 0.0, 0.0, 0.12))
		draw_rect(bill, Color(MONEY_GREEN.r, MONEY_GREEN.g, MONEY_GREEN.b, 0.16))
		draw_rect(Rect2(bill.position + Vector2(bill.size.x * 0.42, 0.0), Vector2(bill.size.x * 0.16, bill.size.y)), Color(GOLD.r, GOLD.g, GOLD.b, 0.12))

func _draw_bank_facade(center: Vector2, radius: float) -> void:
	var base_rect: Rect2 = Rect2(center - Vector2(radius * 1.4, radius * 0.42), Vector2(radius * 2.8, radius * 0.84))
	draw_rect(Rect2(base_rect.position + Vector2(14.0, 16.0), base_rect.size), Color(0.0, 0.0, 0.0, 0.22))
	draw_rect(base_rect, Color(PANEL_DARK.r, PANEL_DARK.g, PANEL_DARK.b, 0.38))
	draw_line(base_rect.position, base_rect.position + Vector2(base_rect.size.x, 0.0), Color(GOLD.r, GOLD.g, GOLD.b, 0.22), 4.0)
	draw_line(base_rect.position + Vector2(0.0, base_rect.size.y), base_rect.position + base_rect.size, Color(CYAN.r, CYAN.g, CYAN.b, 0.17), 3.0)

	var roof: PackedVector2Array = PackedVector2Array([
		Vector2(center.x - radius * 1.55, base_rect.position.y),
		Vector2(center.x, base_rect.position.y - radius * 0.42),
		Vector2(center.x + radius * 1.55, base_rect.position.y),
	])
	draw_colored_polygon(roof, Color(GOLD.r, GOLD.g, GOLD.b, 0.18))
	for column: int in range(5):
		var x: float = center.x - radius * 1.05 + float(column) * radius * 0.52
		draw_rect(Rect2(x, base_rect.position.y + radius * 0.12, radius * 0.16, radius * 0.54), Color(CYAN.r, CYAN.g, CYAN.b, 0.12))

func _draw_security_lanes(rect_size: Vector2) -> void:
	var pulse: float = (sin(animation_time * 4.0) + 1.0) * 0.5
	var alarm_color: Color = Color(ALARM.r, ALARM.g, ALARM.b, 0.14 + pulse * 0.08)
	draw_line(Vector2(0.0, rect_size.y * 0.12), Vector2(rect_size.x, rect_size.y * 0.2), alarm_color, 3.0)
	draw_line(Vector2(0.0, rect_size.y * 0.92), Vector2(rect_size.x, rect_size.y * 0.76), alarm_color, 3.0)

	var lane_y: float = rect_size.y * 0.83
	for lane: int in range(10):
		var x: float = rect_size.x * 0.06 + float(lane) * rect_size.x * 0.097
		draw_line(Vector2(x, lane_y), Vector2(x + rect_size.x * 0.05, lane_y - 38.0), Color(CYAN.r, CYAN.g, CYAN.b, 0.22), 4.0)

func _draw_vault_door(center: Vector2, radius: float) -> void:
	var wobble: float = sin(animation_time * 1.15) * 2.5
	var shifted_center: Vector2 = center + Vector2(wobble, -wobble * 0.35)
	draw_circle(shifted_center + Vector2(18.0, 20.0), radius * 1.04, Color(0.0, 0.0, 0.0, 0.34))
	draw_circle(shifted_center, radius * 1.02, Color(0.067, 0.094, 0.153, 0.52))
	draw_arc(shifted_center, radius, 0.0, TAU, 128, Color(GOLD.r, GOLD.g, GOLD.b, 0.36), 7.0)
	draw_arc(shifted_center, radius * 0.76, 0.0, TAU, 128, Color(CYAN.r, CYAN.g, CYAN.b, 0.26), 4.0)
	draw_arc(shifted_center, radius * 0.46, 0.0, TAU, 128, Color(0.918, 0.949, 0.984, 0.18), 3.0)

	for spoke: int in range(10):
		var angle: float = TAU * float(spoke) / 10.0 + animation_time * 0.045
		var inner: Vector2 = shifted_center + Vector2(cos(angle), sin(angle)) * radius * 0.18
		var outer: Vector2 = shifted_center + Vector2(cos(angle), sin(angle)) * radius * 0.7
		draw_line(inner, outer, Color(GOLD.r, GOLD.g, GOLD.b, 0.23), 3.0)

	draw_circle(shifted_center, radius * 0.13, Color(GOLD.r, GOLD.g, GOLD.b, 0.42))

func _draw_money_stack(center: Vector2, radius: float) -> void:
	for stack: int in range(5):
		var offset: Vector2 = Vector2(float(stack) * radius * 0.22, -float(stack) * radius * 0.16)
		var rect: Rect2 = Rect2(center + offset, Vector2(radius * 1.55, radius * 0.42))
		draw_rect(Rect2(rect.position + Vector2(10.0, 12.0), rect.size), Color(0.0, 0.0, 0.0, 0.22))
		draw_rect(rect, Color(MONEY_GREEN.r, MONEY_GREEN.g, MONEY_GREEN.b, 0.22))
		draw_rect(Rect2(rect.position + Vector2(radius * 0.62, 0.0), Vector2(radius * 0.22, radius * 0.42)), Color(GOLD.r, GOLD.g, GOLD.b, 0.2))
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, 3.0)), Color(GREEN_GLOW.r, GREEN_GLOW.g, GREEN_GLOW.b, 0.22))

func _draw_alarm_panel(center: Vector2, radius: float) -> void:
	var rect: Rect2 = Rect2(center - Vector2(radius * 1.6, radius * 0.6), Vector2(radius * 3.2, radius * 1.2))
	var pulse: float = (sin(animation_time * 5.5) + 1.0) * 0.5
	draw_rect(Rect2(rect.position + Vector2(12.0, 12.0), rect.size), Color(0.0, 0.0, 0.0, 0.25))
	draw_rect(rect, Color(0.067, 0.094, 0.153, 0.42))
	draw_line(rect.position, rect.position + Vector2(rect.size.x, 0.0), Color(ALARM.r, ALARM.g, ALARM.b, 0.35 + pulse * 0.22), 4.0)
	draw_line(rect.position + Vector2(0.0, rect.size.y), rect.position + rect.size, Color(CHASE_ORANGE.r, CHASE_ORANGE.g, CHASE_ORANGE.b, 0.28), 3.0)
	for dot: int in range(5):
		var dot_center: Vector2 = rect.position + Vector2(radius * 0.45 + float(dot) * radius * 0.52, radius * 0.6)
		draw_circle(dot_center, radius * 0.08, Color(ALARM.r, ALARM.g, ALARM.b, 0.22 + pulse * 0.32))

func _draw_physical_table(center: Vector2, radius: float) -> void:
	var shadow_rect: Rect2 = Rect2(center - Vector2(radius * 1.36, radius * 0.52), Vector2(radius * 2.72, radius * 1.04))
	draw_rect(Rect2(shadow_rect.position + Vector2(20.0, 22.0), shadow_rect.size), Color(0.0, 0.0, 0.0, 0.3))
	draw_rect(shadow_rect, PANEL_DARK)
	draw_rect(Rect2(shadow_rect.position + Vector2(10.0, 10.0), shadow_rect.size - Vector2(20.0, 20.0)), Color(CYAN.r, CYAN.g, CYAN.b, 0.09))
	draw_line(shadow_rect.position, shadow_rect.position + Vector2(shadow_rect.size.x, 0.0), Color(GOLD.r, GOLD.g, GOLD.b, 0.2), 4.0)
	for index: int in range(6):
		var offset: float = -radius * 0.98 + float(index) * radius * 0.4
		draw_line(center + Vector2(offset, -radius * 0.42), center + Vector2(offset + radius * 0.22, radius * 0.42), Color(GOLD.r, GOLD.g, GOLD.b, 0.14), 4.0)

func _draw_vignette(rect_size: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(rect_size.x, rect_size.y * 0.16)), Color(0.0, 0.0, 0.0, 0.2))
	draw_rect(Rect2(0.0, rect_size.y * 0.82, rect_size.x, rect_size.y * 0.18), Color(0.0, 0.0, 0.0, 0.24))
	draw_rect(Rect2(Vector2.ZERO, Vector2(rect_size.x * 0.12, rect_size.y)), Color(0.0, 0.0, 0.0, 0.22))
	draw_rect(Rect2(rect_size.x * 0.88, 0.0, rect_size.x * 0.12, rect_size.y), Color(0.0, 0.0, 0.0, 0.28))

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
