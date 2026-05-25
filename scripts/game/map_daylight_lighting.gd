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

func _ready() -> void:
	var scene_root: Node = get_tree().current_scene
	if scene_root == null:
		return

	if not use_manual_values:
		lighting_style = _get_saved_lighting_style()
		_apply_style_preset(lighting_style)
	_apply_world_environment(scene_root)
	_ensure_sunlight(scene_root)

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
