extends Node3D

var hunters: Array[CharacterBody3D] = []
var duration_remaining: float = 0.0
var trigger_radius: float = 1.6
var stun_seconds: float = 0.8
var slow_multiplier: float = 0.55
var slow_seconds: float = 2.5
var triggered: bool = false
var pulse_time: float = 0.0
var trigger_radius_squared: float = 2.56
var base_visual_scale: Vector3 = Vector3.ONE
var visual_scale_cached: bool = false

@onready var visual: Node3D = $Visual
@onready var banana_model: Node3D = get_node_or_null("Visual/BananaModel") as Node3D

func _ready() -> void:
	call_deferred("_finalize_visual_setup")

func setup(new_hunters: Array[CharacterBody3D], duration: float, radius: float, stun: float, slow: float, slow_duration: float) -> void:
	hunters = new_hunters
	duration_remaining = duration
	trigger_radius = radius
	trigger_radius_squared = trigger_radius * trigger_radius
	stun_seconds = stun
	slow_multiplier = slow
	slow_seconds = slow_duration

func _process(delta: float) -> void:
	pulse_time += delta
	duration_remaining = maxf(duration_remaining - delta, 0.0)
	if visual:
		if not visual_scale_cached:
			base_visual_scale = visual.scale
			visual_scale_cached = true
		var pulse: float = (sin(pulse_time * 8.0) + 1.0) * 0.5
		visual.scale = base_visual_scale * (0.92 + pulse * 0.12)

	if duration_remaining <= 0.0:
		queue_free()
		return

	if triggered:
		return

	for hunter: CharacterBody3D in hunters:
		if hunter == null or not is_instance_valid(hunter):
			continue
		if _planar_distance_squared(global_position, hunter.global_position) <= trigger_radius_squared:
			if hunter.has_method("apply_hunter_disruption"):
				hunter.call("apply_hunter_disruption", stun_seconds, slow_multiplier, slow_seconds)
			triggered = true
			queue_free()
			return

func _planar_distance_squared(point_a: Vector3, point_b: Vector3) -> float:
	var offset_x: float = point_a.x - point_b.x
	var offset_z: float = point_a.z - point_b.z
	return offset_x * offset_x + offset_z * offset_z

func _finalize_visual_setup() -> void:
	var has_visible_model: bool = _prepare_banana_model()
	if not has_visible_model:
		_create_fallback_banana_visual()

func _prepare_banana_model() -> bool:
	if banana_model == null:
		return false

	var mesh_instances: Array[MeshInstance3D] = []
	_collect_mesh_instances(banana_model, mesh_instances)
	if mesh_instances.is_empty():
		return false

	for child: Node in banana_model.get_children():
		if child is Node3D:
			(child as Node3D).visible = true
	for mesh_instance: MeshInstance3D in mesh_instances:
		mesh_instance.visible = true
		_force_double_sided_materials(mesh_instance)
	var fitted: bool = _fit_model_to_trap(mesh_instances)
	return fitted

func _collect_mesh_instances(node: Node, output: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		output.append(node as MeshInstance3D)
	for child: Node in node.get_children():
		_collect_mesh_instances(child, output)

func _force_double_sided_materials(mesh_instance: MeshInstance3D) -> void:
	if mesh_instance.material_override is BaseMaterial3D:
		var override_material: BaseMaterial3D = (mesh_instance.material_override as BaseMaterial3D).duplicate()
		override_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		mesh_instance.material_override = override_material

	var mesh: Mesh = mesh_instance.mesh
	if mesh == null:
		return

	for surface_index: int in range(mesh.get_surface_count()):
		var source_material: Material = mesh_instance.get_surface_override_material(surface_index)
		if source_material == null:
			source_material = mesh.surface_get_material(surface_index)
		if not (source_material is BaseMaterial3D):
			continue

		var surface_material: BaseMaterial3D = (source_material as BaseMaterial3D).duplicate()
		surface_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		surface_material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		var albedo: Color = surface_material.albedo_color
		albedo.a = 1.0
		surface_material.albedo_color = albedo
		mesh_instance.set_surface_override_material(surface_index, surface_material)

func _fit_model_to_trap(mesh_instances: Array[MeshInstance3D]) -> bool:
	var bounds: AABB = _compute_bounds_in_visual_space(mesh_instances)
	if bounds.size.length() <= 0.001:
		return false

	var largest_axis: float = maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
	if largest_axis <= 0.001:
		return false

	var target_visual_size: float = 1.25
	var scale_factor: float = target_visual_size / largest_axis
	banana_model.scale *= scale_factor

	var recentered_bounds: AABB = _compute_bounds_in_visual_space(mesh_instances)
	var center: Vector3 = recentered_bounds.position + recentered_bounds.size * 0.5
	banana_model.position -= center
	banana_model.position.y += recentered_bounds.size.y * 0.5 + 0.02
	return true

func _compute_bounds_in_visual_space(mesh_instances: Array[MeshInstance3D]) -> AABB:
	var has_point: bool = false
	var min_point: Vector3 = Vector3(INF, INF, INF)
	var max_point: Vector3 = Vector3(-INF, -INF, -INF)
	var visual_inverse: Transform3D = visual.global_transform.affine_inverse()

	for mesh_instance: MeshInstance3D in mesh_instances:
		if mesh_instance.mesh == null:
			continue
		var local_aabb: AABB = mesh_instance.get_aabb()
		for corner: Vector3 in _get_aabb_corners(local_aabb):
			var global_corner: Vector3 = mesh_instance.global_transform * corner
			var visual_corner: Vector3 = visual_inverse * global_corner
			if not has_point:
				min_point = visual_corner
				max_point = visual_corner
				has_point = true
				continue
			min_point = Vector3(
				minf(min_point.x, visual_corner.x),
				minf(min_point.y, visual_corner.y),
				minf(min_point.z, visual_corner.z)
			)
			max_point = Vector3(
				maxf(max_point.x, visual_corner.x),
				maxf(max_point.y, visual_corner.y),
				maxf(max_point.z, visual_corner.z)
			)

	if not has_point:
		return AABB()
	return AABB(min_point, max_point - min_point)

func _get_aabb_corners(aabb: AABB) -> Array[Vector3]:
	var p: Vector3 = aabb.position
	var s: Vector3 = aabb.size
	return [
		p,
		p + Vector3(s.x, 0.0, 0.0),
		p + Vector3(0.0, s.y, 0.0),
		p + Vector3(0.0, 0.0, s.z),
		p + Vector3(s.x, s.y, 0.0),
		p + Vector3(s.x, 0.0, s.z),
		p + Vector3(0.0, s.y, s.z),
		p + s,
	]

func _create_fallback_banana_visual() -> void:
	if visual == null:
		return
	if visual.get_node_or_null("FallbackBanana") != null:
		return

	var fallback: MeshInstance3D = MeshInstance3D.new()
	fallback.name = "FallbackBanana"
	var mesh: CapsuleMesh = CapsuleMesh.new()
	mesh.radius = 0.12
	mesh.height = 0.58
	mesh.radial_segments = 16
	fallback.mesh = mesh
	fallback.rotation_degrees = Vector3(88.0, 12.0, -28.0)
	fallback.position = Vector3(0.0, 0.22, 0.0)

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.988, 0.862, 0.184, 1.0)
	material.roughness = 0.58
	material.metallic = 0.02
	material.emission_enabled = true
	material.emission = Color(0.902, 0.745, 0.145, 1.0)
	material.emission_energy_multiplier = 0.22
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	fallback.material_override = material
	visual.add_child(fallback)
