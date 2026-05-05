class_name ArenaStyle
extends Node3D

const BG: Color = Color(0.043, 0.063, 0.125, 1.0)
const BG_SECONDARY: Color = Color(0.071, 0.102, 0.169, 1.0)
const SURFACE: Color = Color(0.094, 0.133, 0.208, 1.0)
const BORDER: Color = Color(0.165, 0.224, 0.325, 1.0)
const MONEY_GREEN: Color = Color(0.133, 0.773, 0.369, 1.0)
const GOLD: Color = Color(0.918, 0.702, 0.031, 1.0)

@export var grid_size: float = 58.0
@export var grid_step: float = 4.0
@export var grid_y: float = 0.08

func _ready() -> void:
	_style_environment()
	_add_heist_lighting()
	_add_arena_grid()
	_style_props()

func _style_environment() -> void:
	var world_environment: WorldEnvironment = get_parent().get_node_or_null("CAMERA/WorldEnvironment") as WorldEnvironment
	if world_environment == null or world_environment.environment == null:
		return

	var environment: Environment = world_environment.environment
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = BG
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = BG_SECONDARY
	environment.ambient_light_energy = 1.55
	environment.glow_enabled = true
	environment.glow_intensity = 0.42
	environment.glow_strength = 0.82

func _add_heist_lighting() -> void:
	var key_light: DirectionalLight3D = DirectionalLight3D.new()
	key_light.name = "VaultKeyLight"
	key_light.light_color = Color(0.898, 0.933, 0.973, 1.0)
	key_light.light_energy = 1.55
	key_light.rotation_degrees = Vector3(-62.0, 34.0, 0.0)
	add_child(key_light)

	var money_light: OmniLight3D = OmniLight3D.new()
	money_light.name = "MoneyGlow"
	money_light.light_color = MONEY_GREEN
	money_light.light_energy = 1.25
	money_light.omni_range = 24.0
	money_light.position = Vector3(-10.0, 7.5, 4.0)
	add_child(money_light)

	var vault_light: OmniLight3D = OmniLight3D.new()
	vault_light.name = "VaultGoldGlow"
	vault_light.light_color = GOLD
	vault_light.light_energy = 0.9
	vault_light.omni_range = 20.0
	vault_light.position = Vector3(12.0, 7.0, -10.0)
	add_child(vault_light)

func _add_arena_grid() -> void:
	var grid_root: Node3D = Node3D.new()
	grid_root.name = "HEIST_GRID"
	add_child(grid_root)

	var line_material: StandardMaterial3D = StandardMaterial3D.new()
	line_material.albedo_color = Color(0.133, 0.196, 0.322, 0.36)
	line_material.emission_enabled = true
	line_material.emission = Color(0.133, 0.773, 0.369, 0.32)
	line_material.emission_energy_multiplier = 0.18
	line_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	var half_size: float = grid_size * 0.5
	var line_count: int = int(grid_size / grid_step)
	for index: int in range(line_count + 1):
		var offset: float = -half_size + float(index) * grid_step
		_create_grid_line(grid_root, Vector3(offset, grid_y, 0.0), Vector3(0.035, 0.035, grid_size), line_material)
		_create_grid_line(grid_root, Vector3(0.0, grid_y, offset), Vector3(grid_size, 0.035, 0.035), line_material)

func _create_grid_line(parent: Node3D, position: Vector3, scale_size: Vector3, material: Material) -> void:
	var line: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = scale_size
	line.mesh = mesh
	line.material_override = material
	line.position = position
	parent.add_child(line)

func _style_props() -> void:
	var furniture_root: Node = get_parent().get_node_or_null("MOVEIS")
	if furniture_root == null:
		return

	var vault_material: StandardMaterial3D = _make_material(SURFACE, BORDER, 0.35)
	var cash_material: StandardMaterial3D = _make_material(MONEY_GREEN, MONEY_GREEN, 0.45)
	var gold_material: StandardMaterial3D = _make_material(GOLD, GOLD, 0.28)

	for prop: Node in furniture_root.get_children():
		var prop_name: String = prop.name.to_lower()
		if prop_name.contains("box") or prop_name.contains("caixa"):
			_apply_material_to_meshes(prop, vault_material)
		elif prop_name.contains("book"):
			_apply_material_to_meshes(prop, cash_material)
		elif prop_name.contains("lamp"):
			_apply_material_to_meshes(prop, gold_material)
		else:
			_apply_material_to_meshes(prop, vault_material)

func _make_material(albedo: Color, emission: Color, emission_energy: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = albedo
	material.roughness = 0.28
	material.metallic = 0.12
	material.emission_enabled = emission_energy > 0.0
	material.emission = emission
	material.emission_energy_multiplier = emission_energy
	return material

func _apply_material_to_meshes(node: Node, material: Material) -> void:
	for child: Node in node.get_children():
		if child is MeshInstance3D:
			var mesh_instance: MeshInstance3D = child
			mesh_instance.material_override = material
		_apply_material_to_meshes(child, material)
