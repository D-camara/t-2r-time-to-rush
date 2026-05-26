extends Node3D

@export var pulse_speed: float = 4.6
@export var rotation_speed_a: float = 1.9
@export var rotation_speed_b: float = -2.4

@onready var ring_a: MeshInstance3D = get_node_or_null("PortalPulseRingA") as MeshInstance3D
@onready var ring_b: MeshInstance3D = get_node_or_null("PortalPulseRingB") as MeshInstance3D

var fx_time: float = 0.0
var ring_a_base_scale: Vector3 = Vector3.ONE
var ring_b_base_scale: Vector3 = Vector3.ONE
var ring_a_material: StandardMaterial3D = null
var ring_b_material: StandardMaterial3D = null

func _ready() -> void:
	if ring_a:
		ring_a_base_scale = ring_a.scale
		ring_a_material = _make_unique_material(ring_a)
	if ring_b:
		ring_b_base_scale = ring_b.scale
		ring_b_material = _make_unique_material(ring_b)

func _process(delta: float) -> void:
	fx_time += delta
	var pulse_a: float = (sin(fx_time * pulse_speed) + 1.0) * 0.5
	var pulse_b: float = (sin(fx_time * pulse_speed + PI) + 1.0) * 0.5

	if ring_a:
		ring_a.rotate_y(rotation_speed_a * delta)
		ring_a.scale = ring_a_base_scale * (0.94 + pulse_a * 0.18)
		_set_material_pulse(ring_a_material, pulse_a)

	if ring_b:
		ring_b.rotate_y(rotation_speed_b * delta)
		ring_b.scale = ring_b_base_scale * (0.94 + pulse_b * 0.18)
		_set_material_pulse(ring_b_material, pulse_b)

func _make_unique_material(mesh_instance: MeshInstance3D) -> StandardMaterial3D:
	if mesh_instance == null:
		return null
	var source: Material = mesh_instance.material_override
	if source == null:
		return null
	var copy: StandardMaterial3D = source.duplicate(true) as StandardMaterial3D
	if copy == null:
		return null
	mesh_instance.material_override = copy
	return copy

func _set_material_pulse(material: StandardMaterial3D, pulse: float) -> void:
	if material == null:
		return
	material.emission_energy_multiplier = 1.2 + pulse * 1.1
	var color: Color = material.albedo_color
	color.a = 0.45 + pulse * 0.4
	material.albedo_color = color
