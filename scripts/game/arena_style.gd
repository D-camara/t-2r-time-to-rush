class_name ArenaStyle
extends Node3D

const BG: Color = Color(0.012, 0.018, 0.055, 1.0)
const BG_SECONDARY: Color = Color(0.027, 0.041, 0.102, 1.0)
const BOARD_DARK: Color = Color(0.035, 0.047, 0.086, 1.0)
const BOARD_MID: Color = Color(0.075, 0.102, 0.165, 1.0)
const BOARD_TOP: Color = Color(0.118, 0.153, 0.235, 1.0)
const BORDER: Color = Color(0.22, 0.286, 0.408, 1.0)
const MONEY_GREEN: Color = Color(0.133, 0.773, 0.369, 1.0)
const NEON_GREEN: Color = Color(0.29, 0.871, 0.502, 1.0)
const GOLD: Color = Color(0.918, 0.702, 0.031, 1.0)
const CYAN: Color = Color(0.22, 0.741, 0.973, 1.0)
const ALARM: Color = Color(0.937, 0.267, 0.267, 1.0)
const WHITE: Color = Color(0.918, 0.949, 0.984, 1.0)

@export var arena_size: float = 62.0
@export var tile_size: float = 6.0
@export var floor_y: float = 1.82
@export var visual_y: float = 2.01

var pulse_time: float = 0.0
var pulsing_nodes: Array[Node3D] = []
var floating_nodes: Array[Node3D] = []

func _ready() -> void:
	_style_environment()
	_add_heist_lighting()
	_add_premium_board()
	_add_heist_zones()
	_add_vault_markings()
	_style_props()

func _process(delta: float) -> void:
	pulse_time += delta
	var pulse: float = (sin(pulse_time * 2.8) + 1.0) * 0.5
	for node: Node3D in pulsing_nodes:
		if node == null:
			continue
		var scale_value: float = 1.0 + pulse * 0.035
		node.scale = Vector3(scale_value, 1.0, scale_value)

	for index: int in range(floating_nodes.size()):
		var node: Node3D = floating_nodes[index]
		if node == null:
			continue
		var wobble: float = sin(pulse_time * 2.0 + float(index) * 0.8)
		node.rotation_degrees.z = wobble * 1.8

func _style_environment() -> void:
	var world_environment: WorldEnvironment = get_parent().get_node_or_null("CAMERA/WorldEnvironment") as WorldEnvironment
	if world_environment == null or world_environment.environment == null:
		return

	var environment: Environment = world_environment.environment
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = BG
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = BG_SECONDARY
	environment.ambient_light_energy = 1.05
	environment.glow_enabled = true
	environment.glow_intensity = 0.9
	environment.glow_strength = 1.22
	environment.ssao_enabled = true
	environment.ssao_intensity = 1.8
	environment.ssao_radius = 3.0

func _add_heist_lighting() -> void:
	var key_light: DirectionalLight3D = DirectionalLight3D.new()
	key_light.name = "ArcadeVaultKeyLight"
	key_light.light_color = Color(0.96, 0.98, 1.0, 1.0)
	key_light.light_energy = 2.0
	key_light.shadow_enabled = true
	key_light.rotation_degrees = Vector3(-64.0, 38.0, 0.0)
	add_child(key_light)

	_add_omni_light("EmeraldTableGlow", MONEY_GREEN, 1.75, 30.0, Vector3(-14.0, 7.5, 7.0))
	_add_omni_light("GoldVaultGlow", GOLD, 1.25, 25.0, Vector3(12.0, 7.0, -12.0))
	_add_omni_light("AlarmCornerGlow", ALARM, 1.15, 22.0, Vector3(18.0, 6.5, 12.0))

func _add_omni_light(light_name: String, color: Color, energy: float, light_range: float, position: Vector3) -> void:
	var light: OmniLight3D = OmniLight3D.new()
	light.name = light_name
	light.light_color = color
	light.light_energy = energy
	light.omni_range = light_range
	light.position = position
	add_child(light)

func _add_premium_board() -> void:
	var board_root: Node3D = Node3D.new()
	board_root.name = "PREMIUM_PHYSICAL_BOARD"
	add_child(board_root)

	var shadow_material: StandardMaterial3D = _make_unshaded_material(Color(0.0, 0.0, 0.0, 0.7), Color(0.0, 0.0, 0.0, 1.0), 0.0)
	var side_material: StandardMaterial3D = _make_material(BOARD_DARK, Color(0.0, 0.0, 0.0, 1.0), 0.0)
	var rim_material: StandardMaterial3D = _make_material(BORDER, CYAN, 0.12)

	_create_box(board_root, "board_cast_shadow", Vector3(1.1, 0.0, 1.5), Vector3(arena_size + 5.0, 0.05, arena_size + 5.0), shadow_material, floor_y - 0.18)
	_create_box(board_root, "board_body", Vector3.ZERO, Vector3(arena_size + 2.0, 0.34, arena_size + 2.0), side_material, floor_y - 0.08)
	_create_box(board_root, "board_gold_rim_north", Vector3(0.0, 0.0, -arena_size * 0.5 - 0.9), Vector3(arena_size + 2.8, 0.18, 0.45), rim_material, visual_y + 0.03)
	_create_box(board_root, "board_gold_rim_south", Vector3(0.0, 0.0, arena_size * 0.5 + 0.9), Vector3(arena_size + 2.8, 0.18, 0.45), rim_material, visual_y + 0.03)
	_create_box(board_root, "board_gold_rim_west", Vector3(-arena_size * 0.5 - 0.9, 0.0, 0.0), Vector3(0.45, 0.18, arena_size + 2.8), rim_material, visual_y + 0.03)
	_create_box(board_root, "board_gold_rim_east", Vector3(arena_size * 0.5 + 0.9, 0.0, 0.0), Vector3(0.45, 0.18, arena_size + 2.8), rim_material, visual_y + 0.03)

	var half_size: float = arena_size * 0.5
	var tile_count: int = int(arena_size / tile_size)
	for x_index: int in range(tile_count):
		for z_index: int in range(tile_count):
			var x: float = -half_size + tile_size * 0.5 + float(x_index) * tile_size
			var z: float = -half_size + tile_size * 0.5 + float(z_index) * tile_size
			var checker: float = float((x_index + z_index) % 2)
			var tile_color: Color = BOARD_MID.lerp(BOARD_TOP, checker * 0.32)
			var tile_material: StandardMaterial3D = _make_material(tile_color, CYAN, 0.03)
			var tile_height: float = 0.12 + checker * 0.04
			_create_box(board_root, "raised_tile_%d_%d" % [x_index, z_index], Vector3(x, 0.0, z), Vector3(tile_size - 0.24, tile_height, tile_size - 0.24), tile_material, floor_y + tile_height * 0.5)
			_create_box(board_root, "tile_highlight_%d_%d" % [x_index, z_index], Vector3(x - 0.72, 0.0, z - 0.72), Vector3(tile_size - 1.1, 0.035, 0.075), _make_unshaded_material(Color(1.0, 1.0, 1.0, 0.1), WHITE, 0.05), visual_y + 0.025)

func _add_heist_zones() -> void:
	var zone_root: Node3D = Node3D.new()
	zone_root.name = "ARCADE_HEIST_ZONES"
	add_child(zone_root)

	_create_zone_plate(zone_root, "VAULT ZONE", Vector3(12.0, 0.0, -12.0), Vector3(17.0, 0.07, 11.5), GOLD, "vault_zone")
	_create_zone_plate(zone_root, "ESCAPE ZONE", Vector3(-13.0, 0.0, 7.0), Vector3(15.0, 0.07, 10.0), MONEY_GREEN, "escape_zone")
	_create_zone_plate(zone_root, "ALARM ZONE", Vector3(16.0, 0.0, 12.0), Vector3(12.0, 0.07, 9.0), ALARM, "alarm_zone")

	_add_radial_floor_glow(zone_root, Vector3(12.0, 0.0, -12.0), 8.2, Color(0.918, 0.702, 0.031, 0.22), "vault_heat_glow")
	_add_radial_floor_glow(zone_root, Vector3(-13.0, 0.0, 7.0), 8.8, Color(0.133, 0.773, 0.369, 0.22), "escape_money_glow")
	_add_radial_floor_glow(zone_root, Vector3(16.0, 0.0, 12.0), 7.0, Color(0.937, 0.267, 0.267, 0.2), "alarm_heat_glow")
	_add_radial_floor_glow(zone_root, Vector3(0.0, 0.0, 0.0), 27.0, Color(0.0, 0.0, 0.0, 0.64), "heavy_table_vignette")

func _create_zone_plate(parent: Node3D, label_text: String, position: Vector3, size: Vector3, accent: Color, object_name: String) -> void:
	var plate_material: StandardMaterial3D = _make_unshaded_material(Color(accent.r, accent.g, accent.b, 0.16), accent, 0.24)
	var border_material: StandardMaterial3D = _make_unshaded_material(Color(accent.r, accent.g, accent.b, 0.82), accent, 0.46)
	var plate: MeshInstance3D = _create_box(parent, object_name, position, size, plate_material, visual_y + 0.08)
	pulsing_nodes.append(plate)
	_create_box(parent, "%s_front_edge" % object_name, position + Vector3(0.0, 0.0, -size.z * 0.5), Vector3(size.x, 0.08, 0.18), border_material, visual_y + 0.13)
	_create_box(parent, "%s_side_edge" % object_name, position + Vector3(-size.x * 0.5, 0.0, 0.0), Vector3(0.18, 0.08, size.z), border_material, visual_y + 0.13)
	_add_zone_label(parent, label_text, position + Vector3(0.0, 0.1, 0.0), accent)

func _add_zone_label(parent: Node3D, label_text: String, position: Vector3, accent: Color) -> void:
	var label: Label3D = Label3D.new()
	label.name = "%sLabel" % label_text.replace(" ", "")
	label.text = label_text
	label.font_size = 36
	label.modulate = accent
	label.outline_modulate = Color(0.0, 0.0, 0.0, 0.8)
	label.outline_size = 8
	label.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	label.position = Vector3(position.x, visual_y + 0.25, position.z)
	parent.add_child(label)

func _add_vault_markings() -> void:
	var marker_root: Node3D = Node3D.new()
	marker_root.name = "VAULT_ARCADE_MARKINGS"
	add_child(marker_root)

	var gold_material: StandardMaterial3D = _make_unshaded_material(Color(0.918, 0.702, 0.031, 0.88), GOLD, 0.75)
	var alarm_material: StandardMaterial3D = _make_unshaded_material(Color(0.937, 0.267, 0.267, 0.72), ALARM, 0.58)
	var cyan_material: StandardMaterial3D = _make_unshaded_material(Color(0.22, 0.741, 0.973, 0.54), CYAN, 0.38)

	for marker_index: int in range(7):
		var x: float = -14.0 + float(marker_index) * 4.6
		_create_box(marker_root, "vault_tactical_hash_%d" % marker_index, Vector3(x, 0.0, -17.4), Vector3(2.4, 0.08, 0.22), gold_material, visual_y + 0.18)

	for stripe_index: int in range(8):
		var z: float = -2.0 + float(stripe_index) * 2.2
		_create_box(marker_root, "alarm_laser_%d" % stripe_index, Vector3(19.4, 0.0, z), Vector3(0.18, 0.08, 1.25), alarm_material, visual_y + 0.2)

	_create_box(marker_root, "escape_arrow_a", Vector3(-17.2, 0.0, 8.0), Vector3(4.5, 0.08, 0.22), cyan_material, visual_y + 0.2)
	_create_box(marker_root, "escape_arrow_b", Vector3(-18.9, 0.0, 6.7), Vector3(0.22, 0.08, 2.8), cyan_material, visual_y + 0.2)

func _style_props() -> void:
	var furniture_root: Node = get_parent().get_node_or_null("MOVEIS")
	if furniture_root == null:
		return

	for prop: Node in furniture_root.get_children():
		var prop_name: String = prop.name.to_lower()
		if prop_name.contains("box") or prop_name.contains("caixa"):
			_apply_material_to_meshes(prop, _make_material(Color(0.11, 0.13, 0.18, 1.0), GOLD, 0.32))
			_add_object_dressing(prop, GOLD, "vault")
		elif prop_name.contains("book"):
			_apply_material_to_meshes(prop, _make_material(MONEY_GREEN, NEON_GREEN, 0.55))
			_add_object_dressing(prop, MONEY_GREEN, "cash")
		elif prop_name.contains("lamp"):
			_apply_material_to_meshes(prop, _make_material(ALARM, ALARM, 0.65))
			_add_object_dressing(prop, ALARM, "barrier")
		elif prop_name.contains("table") or prop_name.contains("mesa"):
			_apply_material_to_meshes(prop, _make_material(Color(0.075, 0.102, 0.165, 1.0), CYAN, 0.18))
			_add_object_dressing(prop, CYAN, "control")
		else:
			_apply_material_to_meshes(prop, _make_material(Color(0.09, 0.12, 0.18, 1.0), CYAN, 0.16))
			_add_object_dressing(prop, CYAN, "counter")

func _add_object_dressing(prop: Node, accent: Color, kind: String) -> void:
	if not (prop is Node3D) or get_node_or_null("HeistDressing_%s" % prop.name):
		return

	var prop_3d: Node3D = prop
	var dressing: Node3D = Node3D.new()
	dressing.name = "HeistDressing_%s" % prop.name
	add_child(dressing)
	dressing.global_position = prop_3d.global_position
	dressing.global_rotation = prop_3d.global_rotation
	floating_nodes.append(dressing)

	var shadow_material: StandardMaterial3D = _make_unshaded_material(Color(0.0, 0.0, 0.0, 0.66), Color(0.0, 0.0, 0.0, 1.0), 0.0)
	var side_material: StandardMaterial3D = _make_material(Color(0.03, 0.04, 0.065, 1.0), Color(0.0, 0.0, 0.0, 1.0), 0.0)
	var top_material: StandardMaterial3D = _make_material(Color(accent.r * 0.42 + 0.05, accent.g * 0.42 + 0.06, accent.b * 0.42 + 0.08, 1.0), accent, 0.26)
	var accent_material: StandardMaterial3D = _make_unshaded_material(accent, accent, 0.55)
	var highlight_material: StandardMaterial3D = _make_unshaded_material(Color(1.0, 1.0, 1.0, 0.24), WHITE, 0.18)

	if kind == "vault":
		_create_layered_prop(dressing, Vector3(5.6, 1.0, 4.0), side_material, top_material, shadow_material, highlight_material)
		_create_local_box(dressing, "vault_gold_lock", Vector3(0.0, 1.16, -1.15), Vector3(1.35, 0.16, 0.16), accent_material)
		_create_local_cylinder(dressing, "vault_dial", Vector3(0.0, 1.4, -1.32), 0.52, 0.12, accent_material)
	elif kind == "cash":
		_create_layered_prop(dressing, Vector3(4.2, 0.86, 3.2), side_material, top_material, shadow_material, highlight_material)
		for stack_index: int in range(3):
			var x_offset: float = -1.15 + float(stack_index) * 1.15
			_create_local_box(dressing, "cash_stack_%d" % stack_index, Vector3(x_offset, 1.25 + float(stack_index) * 0.08, -0.15), Vector3(0.9, 0.22, 1.25), accent_material)
	elif kind == "barrier":
		_create_layered_prop(dressing, Vector3(4.6, 0.74, 1.2), side_material, top_material, shadow_material, highlight_material)
		_create_local_box(dressing, "alarm_beam", Vector3(0.0, 1.35, 0.0), Vector3(5.0, 0.12, 0.16), accent_material)
		pulsing_nodes.append(dressing)
	elif kind == "control":
		_create_layered_prop(dressing, Vector3(5.4, 0.9, 3.4), side_material, top_material, shadow_material, highlight_material)
		_create_local_box(dressing, "control_screen", Vector3(0.0, 1.34, -0.65), Vector3(2.25, 0.14, 1.0), _make_unshaded_material(Color(0.22, 0.741, 0.973, 0.6), CYAN, 0.5))
		_create_local_box(dressing, "red_button", Vector3(1.55, 1.48, 0.58), Vector3(0.42, 0.16, 0.42), _make_unshaded_material(ALARM, ALARM, 0.75))
	else:
		_create_layered_prop(dressing, Vector3(5.2, 0.82, 3.0), side_material, top_material, shadow_material, highlight_material)
		_create_local_box(dressing, "glass_counter", Vector3(0.0, 1.24, -0.35), Vector3(4.3, 0.14, 0.8), _make_unshaded_material(Color(0.22, 0.741, 0.973, 0.42), CYAN, 0.28))

func _create_layered_prop(parent: Node3D, size: Vector3, side_material: Material, top_material: Material, shadow_material: Material, highlight_material: Material) -> void:
	_create_local_box(parent, "cast_shadow", Vector3(0.55, -0.52, 0.55), Vector3(size.x + 0.95, 0.05, size.z + 0.95), shadow_material)
	_create_local_box(parent, "dark_side", Vector3(0.18, 0.0, 0.2), Vector3(size.x, size.y, size.z), side_material)
	_create_local_box(parent, "raised_top", Vector3(-0.16, size.y * 0.42, -0.18), Vector3(size.x * 0.9, 0.28, size.z * 0.86), top_material)
	_create_local_box(parent, "front_highlight", Vector3(-0.16, size.y * 0.66, -size.z * 0.46), Vector3(size.x * 0.82, 0.08, 0.12), highlight_material)
	_create_local_box(parent, "left_highlight", Vector3(-size.x * 0.46, size.y * 0.56, -0.16), Vector3(0.12, 0.08, size.z * 0.74), highlight_material)

func _make_material(albedo: Color, emission: Color, emission_energy: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = albedo
	material.roughness = 0.2
	material.metallic = 0.16
	if albedo.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.emission_enabled = emission_energy > 0.0
	material.emission = emission
	material.emission_energy_multiplier = emission_energy
	return material

func _make_unshaded_material(albedo: Color, emission: Color, emission_energy: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = albedo
	material.roughness = 0.18
	material.metallic = 0.08
	if albedo.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.emission_enabled = emission_energy > 0.0
	material.emission = emission
	material.emission_energy_multiplier = emission_energy
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material

func _apply_material_to_meshes(node: Node, material: Material) -> void:
	for child: Node in node.get_children():
		if child is MeshInstance3D:
			var mesh_instance: MeshInstance3D = child
			mesh_instance.material_override = material
		_apply_material_to_meshes(child, material)

func _create_box(parent: Node3D, object_name: String, position: Vector3, size: Vector3, material: Material, y: float) -> MeshInstance3D:
	var box: MeshInstance3D = MeshInstance3D.new()
	box.name = object_name
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	box.mesh = mesh
	box.material_override = material
	box.position = Vector3(position.x, y, position.z)
	parent.add_child(box)
	return box

func _create_local_box(parent: Node3D, object_name: String, position: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var box: MeshInstance3D = MeshInstance3D.new()
	box.name = object_name
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	box.mesh = mesh
	box.material_override = material
	box.position = position
	parent.add_child(box)
	return box

func _create_local_cylinder(parent: Node3D, object_name: String, position: Vector3, radius: float, height: float, material: Material) -> MeshInstance3D:
	var cylinder: MeshInstance3D = MeshInstance3D.new()
	cylinder.name = object_name
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 48
	cylinder.mesh = mesh
	cylinder.material_override = material
	cylinder.position = position
	cylinder.rotation_degrees.x = 90.0
	parent.add_child(cylinder)
	return cylinder

func _add_radial_floor_glow(parent: Node3D, position: Vector3, radius: float, color: Color, object_name: String) -> void:
	var glow: MeshInstance3D = MeshInstance3D.new()
	glow.name = object_name
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.035
	mesh.radial_segments = 64
	glow.mesh = mesh
	glow.position = Vector3(position.x, visual_y + 0.12, position.z)
	glow.material_override = _make_unshaded_material(color, color, 0.32)
	parent.add_child(glow)
	pulsing_nodes.append(glow)
