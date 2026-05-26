extends Node3D

@export var lifetime: float = 0.34
@export var start_scale: float = 0.95
@export var end_scale: float = 1.6
@export var rise_height: float = 0.08

@onready var decal: MeshInstance3D = $Decal

var flash_time: float = 0.0
var flash_material: StandardMaterial3D = null
var base_y: float = 0.0

func _ready() -> void:
	base_y = decal.position.y
	flash_material = _make_unique_material(decal)
	decal.scale = Vector3.ONE * start_scale

func _process(delta: float) -> void:
	flash_time += delta
	var t: float = clampf(flash_time / maxf(lifetime, 0.001), 0.0, 1.0)
	var eased: float = 1.0 - pow(1.0 - t, 2.0)
	decal.scale = Vector3.ONE * lerpf(start_scale, end_scale, eased)
	decal.rotate_y(-delta * 4.8)
	decal.position.y = base_y + rise_height * eased

	if flash_material:
		flash_material.emission_energy_multiplier = lerpf(3.1, 0.0, t)
		var tint: Color = flash_material.albedo_color
		tint.a = lerpf(0.72, 0.0, t)
		flash_material.albedo_color = tint

	if t >= 1.0:
		queue_free()

func _make_unique_material(mesh_instance: MeshInstance3D) -> StandardMaterial3D:
	if mesh_instance == null:
		return null
	var source_material: Material = mesh_instance.material_override
	if source_material == null:
		return null
	var unique_material: StandardMaterial3D = source_material.duplicate(true) as StandardMaterial3D
	if unique_material == null:
		return null
	mesh_instance.material_override = unique_material
	return unique_material
