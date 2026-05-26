extends Node3D

@export var outer_rotation_speed: float = 2.2
@export var inner_rotation_speed: float = 3.1
@export var decal_rotation_speed: float = 1.15
@export var hover_height: float = 0.06
@export var pulse_speed: float = 4.2

@onready var portal_decal: MeshInstance3D = $PortalDecal
@onready var base_disc: MeshInstance3D = get_node_or_null("Visual") as MeshInstance3D
@onready var outer_ring: MeshInstance3D = get_node_or_null("PortalOuterRing") as MeshInstance3D
@onready var inner_ring: MeshInstance3D = get_node_or_null("PortalInnerRing") as MeshInstance3D
@onready var core_glow: MeshInstance3D = get_node_or_null("PortalCoreGlow") as MeshInstance3D

var marker_time: float = 0.0
var base_decal_scale: Vector3 = Vector3.ONE
var base_outer_scale: Vector3 = Vector3.ONE
var base_inner_scale: Vector3 = Vector3.ONE
var base_core_scale: Vector3 = Vector3.ONE
var base_decal_y: float = 0.0
var base_outer_y: float = 0.0
var base_inner_y: float = 0.0
var base_core_y: float = 0.0

var decal_material: StandardMaterial3D = null
var disc_material: StandardMaterial3D = null
var outer_material: StandardMaterial3D = null
var inner_material: StandardMaterial3D = null
var core_material: StandardMaterial3D = null

func _ready() -> void:
	base_decal_scale = portal_decal.scale
	if outer_ring:
		base_outer_scale = outer_ring.scale
	if inner_ring:
		base_inner_scale = inner_ring.scale
	base_decal_y = portal_decal.position.y
	if outer_ring:
		base_outer_y = outer_ring.position.y
	if inner_ring:
		base_inner_y = inner_ring.position.y
	if core_glow:
		base_core_scale = core_glow.scale
		base_core_y = core_glow.position.y

	decal_material = _make_unique_material(portal_decal)
	if base_disc:
		disc_material = _make_unique_material(base_disc)
	if outer_ring:
		outer_material = _make_unique_material(outer_ring)
	if inner_ring:
		inner_material = _make_unique_material(inner_ring)
	if core_glow:
		core_material = _make_unique_material(core_glow)

func _process(delta: float) -> void:
	marker_time += delta
	var pulse: float = (sin(marker_time * pulse_speed) + 1.0) * 0.5
	var pulse_fast: float = (sin(marker_time * (pulse_speed * 1.7)) + 1.0) * 0.5
	var hover_offset: float = sin(marker_time * 2.0) * hover_height

	portal_decal.rotate_y(-decal_rotation_speed * delta)
	if outer_ring:
		outer_ring.rotate_y(outer_rotation_speed * delta)
	if inner_ring:
		inner_ring.rotate_y(-inner_rotation_speed * delta)

	portal_decal.position.y = base_decal_y + hover_offset * 0.2
	if outer_ring:
		outer_ring.position.y = base_outer_y + hover_offset * 0.75
	if inner_ring:
		inner_ring.position.y = base_inner_y - hover_offset * 0.45
	if core_glow:
		core_glow.position.y = base_core_y + hover_offset

	portal_decal.scale = base_decal_scale * (0.92 + pulse * 0.16)
	if outer_ring:
		outer_ring.scale = base_outer_scale * (0.94 + pulse * 0.2)
	if inner_ring:
		inner_ring.scale = base_inner_scale * (0.92 + pulse_fast * 0.18)
	if core_glow:
		core_glow.scale = base_core_scale * (0.9 + pulse * 0.16)

	_set_material_glow(decal_material, 1.9 + pulse * 1.35, 0.44 + pulse * 0.22)
	if disc_material:
		_set_material_glow(disc_material, 1.4 + pulse * 1.1, 0.48 + pulse * 0.22)
	if outer_material:
		_set_material_glow(outer_material, 2.3 + pulse * 1.9, 0.62 + pulse * 0.24)
	if inner_material:
		_set_material_glow(inner_material, 2.0 + pulse_fast * 1.6, 0.58 + pulse_fast * 0.26)
	if core_material:
		_set_material_glow(core_material, 2.7 + pulse * 2.2, 0.42 + pulse * 0.2)

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

func _set_material_glow(material: StandardMaterial3D, emission_energy: float, alpha: float) -> void:
	if material == null:
		return
	material.emission_energy_multiplier = emission_energy
	var tinted: Color = material.albedo_color
	tinted.a = clampf(alpha, 0.0, 1.0)
	material.albedo_color = tinted
