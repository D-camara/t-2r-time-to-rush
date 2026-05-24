class_name ExtractionPoint
extends Area3D

signal fugitive_entered(player: FugitivePlayer, point: ExtractionPoint)

@export var label_text: String = "EXTRACAO"
@export var active_color: Color = Color(0.15, 0.9, 1.0, 0.78)
@export var inactive_color: Color = Color(0.15, 0.2, 0.26, 0.18)

@onready var ring: MeshInstance3D = get_node_or_null("Ring") as MeshInstance3D
@onready var beacon: MeshInstance3D = get_node_or_null("Beacon") as MeshInstance3D
@onready var label: Label3D = get_node_or_null("Label3D") as Label3D
@onready var collision_shape: CollisionShape3D = get_node_or_null("CollisionShape3D") as CollisionShape3D

var is_active: bool = false
var pulse_time: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if label:
		label.text = label_text
	set_extraction_active(false)

func _process(delta: float) -> void:
	if not is_active:
		return

	pulse_time += delta
	var pulse: float = (sin(pulse_time * 6.0) + 1.0) * 0.5
	if ring:
		ring.scale = Vector3.ONE * (1.0 + pulse * 0.12)
	if beacon:
		beacon.rotation_degrees.y += delta * 95.0

func set_extraction_active(enabled: bool) -> void:
	is_active = enabled
	monitoring = enabled
	monitorable = enabled
	visible = enabled
	if collision_shape:
		collision_shape.disabled = not enabled

	var material_color: Color = active_color if enabled else inactive_color
	_apply_material(ring, material_color, 1.35 if enabled else 0.0)
	_apply_material(beacon, material_color, 1.9 if enabled else 0.0)
	if label:
		label.visible = enabled

func _on_body_entered(body: Node3D) -> void:
	if not is_active:
		return
	if body is FugitivePlayer:
		var player: FugitivePlayer = body
		if player.is_participating and not player.is_captured and not player.is_infected and not player.is_extracted:
			fugitive_entered.emit(player, self)

func _apply_material(target: MeshInstance3D, color: Color, emission_energy: float) -> void:
	if target == null:
		return

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.emission_enabled = emission_energy > 0.0
	material.emission = Color(color.r, color.g, color.b, 1.0)
	material.emission_energy_multiplier = emission_energy
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.no_depth_test = true
	target.material_override = material
