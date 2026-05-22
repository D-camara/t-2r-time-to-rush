class_name HeistIcon
extends Control

enum IconType {
	MONEY_STACK,
	MONEY_BAG,
	VAULT,
	ALARM,
	KEYCARD,
	CASH_TRAIL,
}

const GREEN: Color = Color(0.133, 0.773, 0.369, 1.0)
const GREEN_LIGHT: Color = Color(0.29, 0.871, 0.502, 1.0)
const GOLD: Color = Color(0.918, 0.702, 0.031, 1.0)
const RED: Color = Color(0.937, 0.267, 0.267, 1.0)
const CYAN: Color = Color(0.22, 0.741, 0.973, 1.0)
const INK: Color = Color(0.006, 0.008, 0.02, 1.0)
const PANEL: Color = Color(0.067, 0.094, 0.153, 1.0)

@export var icon_type: int = IconType.MONEY_STACK
@export var accent: Color = GOLD
@export_range(0.15, 1.0, 0.05) var opacity: float = 0.9
@export var animated: bool = true

var icon_time: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	if not animated:
		return
	icon_time += delta
	queue_redraw()

func _draw() -> void:
	var rect_size: Vector2 = size
	if rect_size.x <= 0.0 or rect_size.y <= 0.0:
		return

	match icon_type:
		IconType.MONEY_STACK:
			_draw_money_stack(rect_size)
		IconType.MONEY_BAG:
			_draw_money_bag(rect_size)
		IconType.VAULT:
			_draw_vault(rect_size)
		IconType.ALARM:
			_draw_alarm(rect_size)
		IconType.KEYCARD:
			_draw_keycard(rect_size)
		IconType.CASH_TRAIL:
			_draw_cash_trail(rect_size)

func _draw_money_stack(rect_size: Vector2) -> void:
	var bill_size: Vector2 = Vector2(rect_size.x * 0.82, rect_size.y * 0.24)
	for index: int in range(4):
		var offset: Vector2 = Vector2(rect_size.x * 0.08 + float(index) * rect_size.x * 0.025, rect_size.y * 0.56 - float(index) * rect_size.y * 0.13)
		var bill: Rect2 = Rect2(offset, bill_size)
		draw_rect(Rect2(bill.position + Vector2(5.0, 6.0), bill.size), Color(INK.r, INK.g, INK.b, 0.28 * opacity))
		draw_rect(bill, Color(GREEN.r, GREEN.g, GREEN.b, 0.82 * opacity))
		draw_rect(Rect2(bill.position + Vector2(bill.size.x * 0.42, 0.0), Vector2(bill.size.x * 0.16, bill.size.y)), Color(GOLD.r, GOLD.g, GOLD.b, 0.58 * opacity))
		draw_rect(Rect2(bill.position + Vector2(5.0, 5.0), bill.size - Vector2(10.0, 10.0)), Color(GREEN_LIGHT.r, GREEN_LIGHT.g, GREEN_LIGHT.b, 0.18 * opacity), false, 2.0)

func _draw_money_bag(rect_size: Vector2) -> void:
	var center: Vector2 = rect_size * 0.5
	var radius: float = min(rect_size.x, rect_size.y) * 0.32
	var pulse: float = (sin(icon_time * 3.0) + 1.0) * 0.5
	draw_circle(center + Vector2(6.0, 8.0), radius * 1.05, Color(INK.r, INK.g, INK.b, 0.32 * opacity))
	draw_circle(center + Vector2(0.0, rect_size.y * 0.09), radius, Color(GREEN.r, GREEN.g, GREEN.b, (0.82 + pulse * 0.12) * opacity))
	draw_rect(Rect2(center.x - radius * 0.48, rect_size.y * 0.13, radius * 0.96, rect_size.y * 0.18), Color(GOLD.r, GOLD.g, GOLD.b, 0.82 * opacity))
	draw_line(Vector2(center.x - radius * 0.38, rect_size.y * 0.18), Vector2(center.x + radius * 0.38, rect_size.y * 0.18), Color(INK.r, INK.g, INK.b, 0.7 * opacity), 3.0)
	draw_line(Vector2(center.x, center.y - radius * 0.18), Vector2(center.x, center.y + radius * 0.42), Color(INK.r, INK.g, INK.b, 0.52 * opacity), 4.0)
	draw_line(Vector2(center.x - radius * 0.24, center.y + radius * 0.04), Vector2(center.x + radius * 0.24, center.y + radius * 0.04), Color(INK.r, INK.g, INK.b, 0.52 * opacity), 4.0)

func _draw_vault(rect_size: Vector2) -> void:
	var center: Vector2 = rect_size * 0.5
	var radius: float = min(rect_size.x, rect_size.y) * 0.42
	draw_circle(center + Vector2(8.0, 9.0), radius, Color(INK.r, INK.g, INK.b, 0.3 * opacity))
	draw_circle(center, radius, Color(PANEL.r, PANEL.g, PANEL.b, 0.86 * opacity))
	draw_arc(center, radius * 0.92, 0.0, TAU, 96, Color(GOLD.r, GOLD.g, GOLD.b, 0.78 * opacity), 5.0)
	draw_arc(center, radius * 0.62, 0.0, TAU, 96, Color(CYAN.r, CYAN.g, CYAN.b, 0.45 * opacity), 3.0)
	for spoke: int in range(8):
		var angle: float = TAU * float(spoke) / 8.0 + icon_time * 0.08
		draw_line(center, center + Vector2(cos(angle), sin(angle)) * radius * 0.54, Color(GOLD.r, GOLD.g, GOLD.b, 0.36 * opacity), 3.0)
	draw_circle(center, radius * 0.16, Color(GOLD.r, GOLD.g, GOLD.b, 0.82 * opacity))

func _draw_alarm(rect_size: Vector2) -> void:
	var pulse: float = (sin(icon_time * 7.0) + 1.0) * 0.5
	var lamp_rect: Rect2 = Rect2(rect_size.x * 0.23, rect_size.y * 0.22, rect_size.x * 0.54, rect_size.y * 0.42)
	draw_rect(Rect2(lamp_rect.position + Vector2(5.0, 7.0), lamp_rect.size), Color(INK.r, INK.g, INK.b, 0.35 * opacity))
	draw_rect(lamp_rect, Color(RED.r, RED.g, RED.b, (0.62 + pulse * 0.34) * opacity))
	draw_rect(Rect2(rect_size.x * 0.18, rect_size.y * 0.64, rect_size.x * 0.64, rect_size.y * 0.14), Color(PANEL.r, PANEL.g, PANEL.b, 0.95 * opacity))
	draw_line(Vector2(rect_size.x * 0.1, rect_size.y * 0.2), Vector2(rect_size.x * 0.0, rect_size.y * 0.04), Color(RED.r, RED.g, RED.b, (0.35 + pulse * 0.35) * opacity), 4.0)
	draw_line(Vector2(rect_size.x * 0.9, rect_size.y * 0.2), Vector2(rect_size.x, rect_size.y * 0.04), Color(RED.r, RED.g, RED.b, (0.35 + pulse * 0.35) * opacity), 4.0)

func _draw_keycard(rect_size: Vector2) -> void:
	var card: Rect2 = Rect2(rect_size.x * 0.12, rect_size.y * 0.25, rect_size.x * 0.76, rect_size.y * 0.5)
	draw_rect(Rect2(card.position + Vector2(6.0, 7.0), card.size), Color(INK.r, INK.g, INK.b, 0.3 * opacity))
	draw_rect(card, Color(CYAN.r, CYAN.g, CYAN.b, 0.76 * opacity))
	draw_rect(Rect2(card.position + Vector2(card.size.x * 0.08, card.size.y * 0.18), Vector2(card.size.x * 0.24, card.size.y * 0.28)), Color(GOLD.r, GOLD.g, GOLD.b, 0.86 * opacity))
	for line_index: int in range(3):
		var y: float = card.position.y + card.size.y * (0.22 + float(line_index) * 0.19)
		draw_line(Vector2(card.position.x + card.size.x * 0.42, y), Vector2(card.position.x + card.size.x * 0.86, y), Color(INK.r, INK.g, INK.b, 0.46 * opacity), 3.0)

func _draw_cash_trail(rect_size: Vector2) -> void:
	for index: int in range(8):
		var t: float = float(index) / 7.0
		var y_wave: float = sin(icon_time * 1.6 + float(index) * 0.8) * rect_size.y * 0.1
		var bill: Rect2 = Rect2(rect_size.x * t - 22.0, rect_size.y * (0.45 + 0.18 * sin(t * TAU)) + y_wave, 46.0, 20.0)
		draw_rect(bill, Color(GREEN.r, GREEN.g, GREEN.b, 0.44 * opacity))
		draw_rect(Rect2(bill.position + Vector2(18.0, 0.0), Vector2(10.0, bill.size.y)), Color(GOLD.r, GOLD.g, GOLD.b, 0.36 * opacity))
