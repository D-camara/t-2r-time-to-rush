extends SkillBase

const TP_FLASH_SCENE: PackedScene = preload("res://scenes/skills/coelha_tp_flash.tscn")
const REACTIVATE_WINDOW: float = 8.0
const FALLBACK_PORTAL_VFX_SCRIPT: Script = preload("res://scripts/skills/coelha_portal_fallback_vfx.gd")

var marker: Node3D = null
var window_remaining: float = 0.0
var marked_position: Vector3 = Vector3.ZERO

func _init() -> void:
	display_name = "Rabbit Hole"
	cooldown_duration = 30.0

func _process(delta: float) -> void:
	super._process(delta)
	if window_remaining <= 0.0:
		return

	window_remaining = maxf(window_remaining - delta, 0.0)
	if window_remaining <= 0.0:
		_clear_marker()
		_start_cooldown()

func try_activate() -> void:
	if owner_player == null or owner_player.is_infected:
		return

	if window_remaining > 0.0:
		var from_position: Vector3 = owner_player.global_position
		owner_player.global_position = marked_position
		owner_player.velocity = Vector3.ZERO
		owner_player.movement_velocity = Vector3.ZERO
		_spawn_tp_flash(from_position)
		_spawn_tp_flash(marked_position)
		_clear_marker()
		window_remaining = 0.0
		_start_cooldown()
		_show_message("Rabbit Hole ativado")
		return

	if not can_activate():
		return

	marked_position = owner_player.global_position
	window_remaining = REACTIVATE_WINDOW
	marker = _create_fallback_marker()
	if marker:
		owner_player.get_parent().add_child(marker)
		marker.global_position = marked_position + Vector3(0.0, 0.065, 0.0)
		_spawn_tp_flash(marked_position)
	_show_message("Ponto marcado")

func cancel() -> void:
	super.cancel()
	window_remaining = 0.0
	_clear_marker()

func get_status_text() -> String:
	if window_remaining > 0.0:
		return "%s voltar %.1fs" % [display_name, window_remaining]
	return super.get_status_text()

func get_cooldown_fill_ratio() -> float:
	if window_remaining > 0.0:
		return clampf(window_remaining / REACTIVATE_WINDOW, 0.0, 1.0)
	return super.get_cooldown_fill_ratio()

func is_ready() -> bool:
	if window_remaining > 0.0:
		return false
	return super.is_ready()

func _clear_marker() -> void:
	if marker:
		marker.queue_free()
		marker = null

func _spawn_tp_flash(world_position: Vector3) -> void:
	if TP_FLASH_SCENE == null or owner_player == null:
		return
	var flash: Node3D = TP_FLASH_SCENE.instantiate() as Node3D
	if flash == null:
		return
	owner_player.get_parent().add_child(flash)
	flash.global_position = world_position + Vector3(0.0, 0.2, 0.0)

func _create_fallback_marker() -> Node3D:
	var fallback_root: Node3D = Node3D.new()
	fallback_root.name = "RabbitHoleFallbackMarker"
	if FALLBACK_PORTAL_VFX_SCRIPT != null:
		fallback_root.set_script(FALLBACK_PORTAL_VFX_SCRIPT)

	var base_mesh: PlaneMesh = PlaneMesh.new()
	base_mesh.size = Vector2(3.4, 3.4)
	base_mesh.orientation = PlaneMesh.FACE_Y

	var base_instance: MeshInstance3D = MeshInstance3D.new()
	base_instance.name = "PortalDecalFallback"
	base_instance.mesh = base_mesh
	base_instance.position = Vector3(0.0, 0.065, 0.0)

	var material: StandardMaterial3D = StandardMaterial3D.new()
	var portal_texture: Texture2D = load("res://assets/vfx/coelha/tp.png") as Texture2D
	if portal_texture != null:
		material.albedo_texture = portal_texture
	material.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.emission_enabled = true
	material.emission = Color(1.0, 0.6, 0.8, 1.0)
	material.emission_energy_multiplier = 1.4
	material.no_depth_test = false
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	base_instance.material_override = material

	var ring_mesh: TorusMesh = TorusMesh.new()
	ring_mesh.inner_radius = 1.12
	ring_mesh.outer_radius = 1.22
	ring_mesh.rings = 36
	ring_mesh.ring_segments = 12

	var ring_instance: MeshInstance3D = MeshInstance3D.new()
	ring_instance.name = "PortalRingFallback"
	ring_instance.mesh = ring_mesh
	ring_instance.position = Vector3(0.0, 0.11, 0.0)

	var ring_material: StandardMaterial3D = StandardMaterial3D.new()
	ring_material.albedo_color = Color(1.0, 0.38, 0.74, 0.82)
	ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring_material.emission_enabled = true
	ring_material.emission = Color(1.0, 0.42, 0.76, 1.0)
	ring_material.emission_energy_multiplier = 2.0
	ring_material.no_depth_test = false
	ring_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	ring_instance.material_override = ring_material

	var pulse_ring_mesh_a: TorusMesh = TorusMesh.new()
	pulse_ring_mesh_a.inner_radius = 1.28
	pulse_ring_mesh_a.outer_radius = 1.33
	pulse_ring_mesh_a.rings = 30
	pulse_ring_mesh_a.ring_segments = 10

	var pulse_ring_a: MeshInstance3D = MeshInstance3D.new()
	pulse_ring_a.name = "PortalPulseRingA"
	pulse_ring_a.mesh = pulse_ring_mesh_a
	pulse_ring_a.position = Vector3(0.0, 0.12, 0.0)

	var pulse_ring_material_a: StandardMaterial3D = StandardMaterial3D.new()
	pulse_ring_material_a.albedo_color = Color(1.0, 0.6, 0.82, 0.78)
	pulse_ring_material_a.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pulse_ring_material_a.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pulse_ring_material_a.emission_enabled = true
	pulse_ring_material_a.emission = Color(1.0, 0.62, 0.86, 1.0)
	pulse_ring_material_a.emission_energy_multiplier = 2.0
	pulse_ring_material_a.no_depth_test = false
	pulse_ring_material_a.cull_mode = BaseMaterial3D.CULL_DISABLED
	pulse_ring_a.material_override = pulse_ring_material_a

	var pulse_ring_mesh_b: TorusMesh = TorusMesh.new()
	pulse_ring_mesh_b.inner_radius = 1.44
	pulse_ring_mesh_b.outer_radius = 1.49
	pulse_ring_mesh_b.rings = 30
	pulse_ring_mesh_b.ring_segments = 10

	var pulse_ring_b: MeshInstance3D = MeshInstance3D.new()
	pulse_ring_b.name = "PortalPulseRingB"
	pulse_ring_b.mesh = pulse_ring_mesh_b
	pulse_ring_b.position = Vector3(0.0, 0.13, 0.0)

	var pulse_ring_material_b: StandardMaterial3D = StandardMaterial3D.new()
	pulse_ring_material_b.albedo_color = Color(1.0, 0.42, 0.76, 0.72)
	pulse_ring_material_b.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pulse_ring_material_b.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pulse_ring_material_b.emission_enabled = true
	pulse_ring_material_b.emission = Color(1.0, 0.5, 0.82, 1.0)
	pulse_ring_material_b.emission_energy_multiplier = 1.9
	pulse_ring_material_b.no_depth_test = false
	pulse_ring_material_b.cull_mode = BaseMaterial3D.CULL_DISABLED
	pulse_ring_b.material_override = pulse_ring_material_b

	fallback_root.add_child(base_instance)
	fallback_root.add_child(ring_instance)
	fallback_root.add_child(pulse_ring_a)
	fallback_root.add_child(pulse_ring_b)
	return fallback_root
