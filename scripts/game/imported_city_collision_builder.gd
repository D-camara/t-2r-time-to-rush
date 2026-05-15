extends Node3D

@export var minimum_collision_height: float = 4.0
@export var minimum_collision_footprint: float = 2.0
@export var max_generated_collisions: int = 240
@export_flags_3d_physics var generated_collision_layer: int = 1
@export_flags_3d_physics var generated_collision_mask: int = 1

var generated_count: int = 0

func _ready() -> void:
	call_deferred("_build_city_collisions")

func _build_city_collisions() -> void:
	generated_count = 0
	_add_collisions_recursive(self)

func _add_collisions_recursive(node: Node) -> void:
	if generated_count >= max_generated_collisions:
		return

	if node is MeshInstance3D:
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		_try_add_collision(mesh_instance)

	for child: Node in node.get_children():
		_add_collisions_recursive(child)

func _try_add_collision(mesh_instance: MeshInstance3D) -> void:
	if mesh_instance.mesh == null:
		return
	if _has_collision_child(mesh_instance):
		return
	if _should_ignore_mesh(mesh_instance):
		return
	if not _has_blocking_volume(mesh_instance):
		return

	var local_aabb: AABB = mesh_instance.get_aabb()
	if local_aabb.size.is_zero_approx():
		return

	var body: StaticBody3D = StaticBody3D.new()
	body.name = "GeneratedBuildingCollision"
	body.collision_layer = generated_collision_layer
	body.collision_mask = generated_collision_mask
	body.transform.origin = local_aabb.get_center()

	var collision_shape: CollisionShape3D = CollisionShape3D.new()
	collision_shape.name = "CollisionShape3D"
	var box_shape: BoxShape3D = BoxShape3D.new()
	box_shape.size = local_aabb.size
	collision_shape.shape = box_shape

	mesh_instance.add_child(body)
	body.add_child(collision_shape)
	generated_count += 1

func _has_collision_child(node: Node) -> bool:
	for child: Node in node.get_children():
		if child is CollisionObject3D or child is CollisionShape3D:
			return true
	return false

func _should_ignore_mesh(mesh_instance: MeshInstance3D) -> bool:
	var mesh_name: String = mesh_instance.name.to_lower()
	var parent: Node = mesh_instance.get_parent()
	var parent_name: String = parent.name.to_lower() if parent != null else ""
	var combined_name: String = "%s %s" % [mesh_name, parent_name]
	var ignored_terms: Array[String] = [
		"strada",
		"marcapiede",
		"road",
		"street",
		"floor",
		"plane",
		"tree",
		"stop",
		"semaforo",
		"lamp",
		"light"
	]

	for term: String in ignored_terms:
		if combined_name.contains(term):
			return true

	return false

func _has_blocking_volume(mesh_instance: MeshInstance3D) -> bool:
	var local_aabb: AABB = mesh_instance.get_aabb()
	var basis_scale: Vector3 = mesh_instance.global_transform.basis.get_scale()
	var world_scale: Vector3 = Vector3(absf(basis_scale.x), absf(basis_scale.y), absf(basis_scale.z))
	var world_size: Vector3 = Vector3(
		local_aabb.size.x * world_scale.x,
		local_aabb.size.y * world_scale.y,
		local_aabb.size.z * world_scale.z
	)
	var footprint: float = max(world_size.x, world_size.z)

	return world_size.y >= minimum_collision_height and footprint >= minimum_collision_footprint
