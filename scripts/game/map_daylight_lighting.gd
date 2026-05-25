class_name MapDaylightLighting
extends Node

enum LightingStyle {
	SOFT_DAY,
	GOLDEN_HOUR,
	OVERCAST,
	NOIR_CYBER,
	MOONLIGHT,
}

@export var lighting_style: LightingStyle = LightingStyle.SOFT_DAY
@export var use_manual_values: bool = false
@export var sun_color: Color = Color(1.0, 0.97, 0.9, 1.0)
@export var sun_energy: float = 1.45
@export var sun_rotation_degrees: Vector3 = Vector3(-52.0, 35.0, 0.0)
@export var ambient_color: Color = Color(0.74, 0.8, 0.9, 1.0)
@export var ambient_energy: float = 0.52
@export var disable_glow: bool = true
@export var enable_moonlight_rain: bool = true
@export var rain_amount: float = 2600.0
@export var rain_fall_speed: float = 28.0
@export var rain_area_size: Vector3 = Vector3(130.0, 8.0, 130.0)
@export var rain_spawn_height: float = 26.0
@export var rain_drop_lifetime: float = 1.5

func _ready() -> void:
	var scene_root: Node = get_tree().current_scene
	if scene_root == null:
		return

	if not use_manual_values:
		lighting_style = _get_saved_lighting_style()
		_apply_style_preset(lighting_style)
	_apply_world_environment(scene_root)
	_ensure_sunlight(scene_root)
	_update_moonlight_rain(scene_root)

func _get_saved_lighting_style() -> int:
	var input_manager: Node = get_node_or_null("/root/InputManager")
	if input_manager != null and input_manager.has_method("get_lighting_style_index"):
		var saved_style: int = int(input_manager.call("get_lighting_style_index"))
		if saved_style >= 0 and saved_style < LightingStyle.size():
			return saved_style
	return int(lighting_style)

func _apply_style_preset(style: LightingStyle) -> void:
	match style:
		LightingStyle.SOFT_DAY:
			sun_color = Color(1.0, 0.97, 0.9, 1.0)
			sun_energy = 1.45
			sun_rotation_degrees = Vector3(-52.0, 35.0, 0.0)
			ambient_color = Color(0.74, 0.8, 0.9, 1.0)
			ambient_energy = 0.52
			disable_glow = true
		LightingStyle.GOLDEN_HOUR:
			sun_color = Color(1.0, 0.84, 0.62, 1.0)
			sun_energy = 1.28
			sun_rotation_degrees = Vector3(-34.0, 20.0, 0.0)
			ambient_color = Color(0.66, 0.56, 0.42, 1.0)
			ambient_energy = 0.42
			disable_glow = true
		LightingStyle.OVERCAST:
			sun_color = Color(0.88, 0.92, 0.98, 1.0)
			sun_energy = 0.95
			sun_rotation_degrees = Vector3(-60.0, 10.0, 0.0)
			ambient_color = Color(0.7, 0.75, 0.82, 1.0)
			ambient_energy = 0.68
			disable_glow = true
		LightingStyle.NOIR_CYBER:
			sun_color = Color(0.7, 0.8, 1.0, 1.0)
			sun_energy = 1.02
			sun_rotation_degrees = Vector3(-57.0, 46.0, 0.0)
			ambient_color = Color(0.12, 0.17, 0.26, 1.0)
			ambient_energy = 0.36
			disable_glow = false
		LightingStyle.MOONLIGHT:
			sun_color = Color(0.55, 0.68, 0.96, 1.0)
			sun_energy = 0.72
			sun_rotation_degrees = Vector3(-66.0, 28.0, 0.0)
			ambient_color = Color(0.14, 0.19, 0.29, 1.0)
			ambient_energy = 0.31
			disable_glow = true

func _apply_world_environment(scene_root: Node) -> void:
	var world_environment: WorldEnvironment = scene_root.get_node_or_null("CAMERA/WorldEnvironment") as WorldEnvironment
	if world_environment == null or world_environment.environment == null:
		return

	var environment: Environment = world_environment.environment
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = ambient_color
	environment.ambient_light_energy = ambient_energy
	environment.glow_enabled = not disable_glow

func _ensure_sunlight(scene_root: Node) -> void:
	var sunlight: DirectionalLight3D = scene_root.get_node_or_null("DaySunLight") as DirectionalLight3D
	if sunlight == null:
		sunlight = DirectionalLight3D.new()
		sunlight.name = "DaySunLight"
		scene_root.add_child(sunlight)

	sunlight.light_color = sun_color
	sunlight.light_energy = sun_energy
	sunlight.rotation_degrees = sun_rotation_degrees
	sunlight.shadow_enabled = true
	sunlight.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS

func _update_moonlight_rain(scene_root: Node) -> void:
	var should_rain: bool = enable_moonlight_rain and _is_rain_enabled_by_settings()
	var rain_node: GPUParticles3D = scene_root.get_node_or_null("MoonlightRain") as GPUParticles3D

	if not should_rain:
		if rain_node != null:
			rain_node.queue_free()
		return

	if rain_node == null:
		rain_node = GPUParticles3D.new()
		rain_node.name = "MoonlightRain"
		scene_root.add_child(rain_node)

	rain_node.amount = int(rain_amount)
	rain_node.lifetime = rain_drop_lifetime
	rain_node.one_shot = false
	rain_node.explosiveness = 0.0
	rain_node.preprocess = rain_drop_lifetime
	rain_node.local_coords = false
	rain_node.draw_pass_1 = _create_rain_drop_mesh()
	rain_node.visibility_aabb = AABB(
		Vector3(-rain_area_size.x * 0.5, -rain_spawn_height, -rain_area_size.z * 0.5),
		Vector3(rain_area_size.x, rain_spawn_height * 1.8, rain_area_size.z)
	)
	var rain_center: Vector3 = _get_rain_center(scene_root)
	rain_node.global_position = rain_center + Vector3(0.0, rain_spawn_height, 0.0)
	rain_node.process_material = _create_rain_process_material()
	rain_node.emitting = true

func _create_rain_drop_mesh() -> BoxMesh:
	var drop_mesh: BoxMesh = BoxMesh.new()
	drop_mesh.size = Vector3(0.016, 0.34, 0.016)
	var drop_material: StandardMaterial3D = StandardMaterial3D.new()
	drop_material.albedo_color = Color(0.78, 0.88, 1.0, 0.72)
	drop_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	drop_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	drop_material.emission_enabled = true
	drop_material.emission = Color(0.52, 0.67, 0.92, 1.0)
	drop_material.emission_energy_multiplier = 0.34
	drop_mesh.material = drop_material
	return drop_mesh

func _create_rain_process_material() -> ParticleProcessMaterial:
	var material: ParticleProcessMaterial = ParticleProcessMaterial.new()
	material.direction = Vector3(0.0, -1.0, 0.0)
	material.initial_velocity_min = rain_fall_speed * 0.9
	material.initial_velocity_max = rain_fall_speed
	material.gravity = Vector3(0.0, -4.0, 0.0)
	material.spread = 2.0
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = rain_area_size * 0.5
	return material

func _get_rain_center(scene_root: Node) -> Vector3:
	var center_sources: Array[Node3D] = []
	var candidate_names: Array[String] = [
		"FUGITIVE_SPAWN",
		"FUGITIVE_2_SPAWN",
		"FUGITIVE_3_SPAWN",
		"POLICE_SPAWN",
	]
	for node_name: String in candidate_names:
		var candidate: Node3D = scene_root.get_node_or_null(node_name) as Node3D
		if candidate != null:
			center_sources.append(candidate)

	if center_sources.is_empty():
		return Vector3.ZERO

	var center: Vector3 = Vector3.ZERO
	for source: Node3D in center_sources:
		center += source.global_position
	return center / float(center_sources.size())

func _is_rain_enabled_by_settings() -> bool:
	var input_manager: Node = get_node_or_null("/root/InputManager")
	if input_manager != null and input_manager.has_method("is_rain_enabled"):
		return bool(input_manager.call("is_rain_enabled"))
	return true
