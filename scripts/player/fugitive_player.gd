class_name FugitivePlayer
extends CharacterBody3D

const DEFAULT_STUN: float = 2.0
const CHARACTER_VISUAL_SCENES: Dictionary = {
	"sagui": preload("res://assets/models/PERSONAGENS/sagui1.tscn"),
	"coelha": preload("res://assets/models/PERSONAGENS/coelha1.tscn"),
	"tigre": preload("res://assets/models/PERSONAGENS/tigre1.tscn"),
	"raposa": preload("res://assets/models/PERSONAGENS/raposa1.tscn"),
}

@export var device_id: int = -1
@export var move_speed: float = 10.0
@export var acceleration: float = 14.0
@export var rotation_lerp_speed: float = 12.0
@export var camera_path: NodePath = ^"../CAMERA"
@export var fugitive_body_color: Color = Color(0.015, 0.105, 0.32, 1.0)
@export var fugitive_emission_color: Color = Color(0.12, 0.58, 1.0, 1.0)
@export var fugitive_emission_energy: float = 2.15
@export var hunter_body_color: Color = Color(0.03, 0.14, 0.42, 1.0)
@export var hunter_emission_color: Color = Color(0.22, 0.74, 0.97, 1.0)
@export var hunter_emission_energy: float = 2.65
@export var visual_scale: float = 1.2
@export var fall_limit_y: float = -5.0
@export var fall_reset_margin: float = 18.0
@export var speed_boost_vfx_color: Color = Color(0.961, 0.62, 0.043, 1.0)

@onready var animator: AnimationPlayer = find_child("AnimationPlayer", true, false) as AnimationPlayer
@onready var character_visual: Node3D = find_child("boneco", true, false) as Node3D
@onready var view: Node3D = get_node_or_null(camera_path)

var movement_velocity: Vector3 = Vector3.ZERO
var base_move_speed: float = 10.0
var skill_speed_multiplier: float = 1.0
var disruption_speed_multiplier: float = 1.0
var disruption_slow_timer: float = 0.0
var gravity: float = 0.0
var rotation_direction: float = 0.0
var is_stunned: bool = false
var stun_timer: float = 0.0
var input_enabled: bool = true
var is_captured: bool = false
var is_infected: bool = false
var is_extracted: bool = false
var respawn_position: Vector3 = Vector3.ZERO
var is_participating: bool = true
var is_in_danger_visual: bool = false
var visual_pulse_time: float = 0.0
var player_ring: MeshInstance3D = null
var player_shadow: MeshInstance3D = null
var role_beacon: MeshInstance3D = null
var avatar_body: MeshInstance3D = null
var avatar_head: MeshInstance3D = null
var avatar_visor: MeshInstance3D = null
var pop_timer: float = 0.0
var visual_base_position: Vector3 = Vector3.ZERO
var skill_controller: SkillController = null
var idle_animation_name: String = ""
var run_animation_name: String = ""
var input_manager_ref: Node = null
var uses_imported_character_visual: bool = false
var speed_boost_vfx: GPUParticles3D = null
const RING_FLOOR_Y: float = 0.09
const RING_THICKNESS_SCALE: float = 0.11

func _ready() -> void:
	base_move_speed = move_speed
	input_manager_ref = get_node_or_null("/root/InputManager")
	_cache_animation_names()
	if character_visual:
		visual_base_position = character_visual.position
		character_visual.scale = Vector3.ONE * visual_scale
	_ensure_player_shadow()
	_ensure_player_ring()
	_ensure_role_beacon()
	_ensure_speed_boost_vfx()
	if character_visual == null:
		_ensure_presentation_avatar()
	_apply_current_palette()

func _physics_process(delta: float) -> void:
	if not is_participating:
		return

	visual_pulse_time += delta
	_update_player_ring()
	_update_token_presence(delta)
	_update_disruption(delta)

	if global_position.y < _get_current_fall_limit():
		_restore_to_spawn()
		return

	if is_stunned:
		stun_timer -= delta
		if stun_timer <= 0.0:
			is_stunned = false
		velocity = Vector3.ZERO
		handle_animation()
		return

	handle_input()
	apply_gravity(delta)

	var applied_velocity: Vector3 = velocity.lerp(movement_velocity, delta * acceleration)
	applied_velocity.y = -gravity
	velocity = applied_velocity

	move_and_slide()

	if Vector2(velocity.z, velocity.x).length() > 0.0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * rotation_lerp_speed)
	handle_animation()

func apply_trap_stun(duration: float = DEFAULT_STUN) -> void:
	is_stunned = true
	stun_timer = duration
	velocity = Vector3.ZERO
	movement_velocity = Vector3.ZERO

func handle_input() -> void:
	if not input_enabled:
		movement_velocity = Vector3.ZERO
		return

	var input: Vector3 = _get_input_direction()
	if view:
		input = input.rotated(Vector3.UP, view.rotation.y)

	movement_velocity = input.normalized() * _get_effective_move_speed() if input.length_squared() > 0.0 else Vector3.ZERO

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		gravity += 25.0 * delta
	else:
		gravity = 0.0

func handle_animation() -> void:
	if not animator or not is_on_floor():
		return

	if is_stunned or (abs(velocity.x) <= 1.0 and abs(velocity.z) <= 1.0):
		_play_animation_by_suffix("Idle")
	else:
		_play_animation_by_suffix("FastRun")

func _play_animation_by_suffix(suffix: String) -> void:
	var animation_name: String = idle_animation_name if suffix == "Idle" else run_animation_name
	if not animation_name.is_empty() and animator.current_animation != animation_name:
		animator.play(animation_name, 0.3)

func _cache_animation_names() -> void:
	if not animator:
		return
	for animation_name: String in animator.get_animation_list():
		if animation_name.ends_with("/Idle") or animation_name == "Idle":
			idle_animation_name = animation_name
		elif animation_name.ends_with("/FastRun") or animation_name == "FastRun":
			run_animation_name = animation_name

func set_input_enabled(enabled: bool) -> void:
	input_enabled = enabled
	if not enabled:
		velocity = Vector3.ZERO
		movement_velocity = Vector3.ZERO

func configure_movement(speed: float, new_acceleration: float) -> void:
	base_move_speed = speed
	move_speed = _get_effective_move_speed()
	acceleration = new_acceleration

func set_skill_speed_multiplier(multiplier: float) -> void:
	skill_speed_multiplier = maxf(multiplier, 0.0)
	move_speed = _get_effective_move_speed()

func set_speed_boost_vfx_enabled(enabled: bool) -> void:
	_ensure_speed_boost_vfx()
	if speed_boost_vfx == null:
		return
	speed_boost_vfx.emitting = enabled

func get_forward_direction() -> Vector3:
	var forward: Vector3 = -global_transform.basis.z
	forward.y = 0.0
	if forward.length() <= 0.001:
		return Vector3.FORWARD
	return forward.normalized()

func configure_skill(character_id: String, round_manager: Node) -> void:
	clear_skill()
	configure_character_visual(character_id)
	if character_id.is_empty():
		return

	skill_controller = SkillController.new()
	skill_controller.name = "SkillController"
	add_child(skill_controller)
	skill_controller.setup(self, character_id, round_manager)

func configure_character_visual(character_id: String) -> void:
	if not CHARACTER_VISUAL_SCENES.has(character_id):
		return

	var visual_scene: PackedScene = CHARACTER_VISUAL_SCENES[character_id] as PackedScene
	var new_visual: Node3D = visual_scene.instantiate() as Node3D
	if new_visual == null:
		return

	if character_visual:
		var visual_parent: Node = character_visual.get_parent()
		if visual_parent != null:
			visual_parent.remove_child(character_visual)
		character_visual.queue_free()

	new_visual.name = "boneco"
	add_child(new_visual)
	character_visual = new_visual
	uses_imported_character_visual = true
	visual_base_position = Vector3.ZERO
	character_visual.scale = Vector3.ONE * visual_scale
	animator = find_child("AnimationPlayer", true, false) as AnimationPlayer
	_cache_animation_names()
	_remove_presentation_avatar()

func clear_skill() -> void:
	if skill_controller:
		skill_controller.cancel()
		skill_controller.queue_free()
		skill_controller = null
	set_skill_speed_multiplier(1.0)

func get_skill_status_text() -> String:
	if skill_controller == null:
		return ""
	return skill_controller.get_status_text()

func capture() -> void:
	infect()

func infect() -> void:
	is_captured = true
	is_infected = true
	is_extracted = false
	is_in_danger_visual = false
	is_stunned = false
	stun_timer = 0.0
	input_enabled = true
	clear_skill()
	_apply_current_palette()
	_flash_role_change()

func extract() -> void:
	is_extracted = true
	is_captured = true
	is_infected = false
	is_in_danger_visual = false
	is_stunned = false
	stun_timer = 0.0
	input_enabled = false
	clear_skill()
	velocity = Vector3.ZERO
	movement_velocity = Vector3.ZERO
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED

func reset_state(spawn_position: Vector3) -> void:
	is_participating = true
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	respawn_position = spawn_position
	global_position = spawn_position
	velocity = Vector3.ZERO
	movement_velocity = Vector3.ZERO
	gravity = 0.0
	is_stunned = false
	stun_timer = 0.0
	input_enabled = true
	is_captured = false
	is_infected = false
	is_extracted = false
	is_in_danger_visual = false
	disruption_speed_multiplier = 1.0
	disruption_slow_timer = 0.0
	if character_visual:
		character_visual.scale = Vector3.ONE * visual_scale
	_apply_current_palette()
	_update_player_ring()

func deactivate_slot() -> void:
	is_participating = false
	visible = false
	input_enabled = false
	is_captured = true
	is_infected = false
	is_extracted = false
	is_in_danger_visual = false
	is_stunned = false
	stun_timer = 0.0
	clear_skill()
	velocity = Vector3.ZERO
	movement_velocity = Vector3.ZERO

func is_controller_connected() -> bool:
	if device_id < 0:
		return false

	var input_manager: Node = _get_input_manager()
	if input_manager == null or not input_manager.has_method("has_device"):
		return false
	return bool(input_manager.call("has_device", device_id))

func _get_input_direction() -> Vector3:
	if device_id < 0:
		return Vector3.ZERO

	var input_manager: Node = _get_input_manager()
	if input_manager != null and input_manager.has_method("get_movement"):
		var movement_result: Variant = input_manager.call("get_movement", device_id)
		if movement_result is Vector3:
			return movement_result

	return Vector3.ZERO

func _get_input_manager() -> Node:
	return input_manager_ref

func apply_hunter_disruption(stun_seconds: float, slow_multiplier: float, slow_seconds: float) -> void:
	if not is_infected:
		return

	if stun_seconds > 0.0:
		is_stunned = true
		stun_timer = maxf(stun_timer, stun_seconds)
	if slow_seconds > 0.0:
		disruption_speed_multiplier = clampf(slow_multiplier, 0.0, 1.0)
		disruption_slow_timer = maxf(disruption_slow_timer, slow_seconds)
	move_speed = _get_effective_move_speed()

func _update_disruption(delta: float) -> void:
	if disruption_slow_timer <= 0.0:
		return

	disruption_slow_timer = maxf(disruption_slow_timer - delta, 0.0)
	if disruption_slow_timer <= 0.0:
		disruption_speed_multiplier = 1.0
		move_speed = _get_effective_move_speed()

func _get_effective_move_speed() -> float:
	return base_move_speed * skill_speed_multiplier * disruption_speed_multiplier

func _apply_current_palette() -> void:
	var palette_material: StandardMaterial3D = StandardMaterial3D.new()
	if is_infected:
		palette_material.albedo_color = hunter_body_color
		palette_material.emission = hunter_emission_color
		palette_material.emission_energy_multiplier = hunter_emission_energy
	else:
		palette_material.albedo_color = fugitive_body_color
		palette_material.emission = fugitive_emission_color
		palette_material.emission_energy_multiplier = fugitive_emission_energy

	palette_material.roughness = 0.28
	palette_material.metallic = 0.05
	palette_material.emission_enabled = palette_material.emission_energy_multiplier > 0.0
	_apply_palette_to_meshes(self, palette_material)
	_update_presentation_avatar_palette()

func _apply_palette_to_meshes(node: Node, palette_material: Material) -> void:
	if uses_imported_character_visual and character_visual != null:
		if node == character_visual or character_visual.is_ancestor_of(node):
			return
	for child: Node in node.get_children():
		if _is_visual_helper(child):
			continue
		if child is MeshInstance3D:
			var mesh_instance: MeshInstance3D = child
			mesh_instance.material_override = palette_material
		_apply_palette_to_meshes(child, palette_material)

func _is_visual_helper(node: Node) -> bool:
	return node == player_ring or node == player_shadow or node == role_beacon or node.name.begins_with("Token") or node.name.begins_with("HeistAvatar")

func _restore_to_spawn() -> void:
	global_position = respawn_position
	velocity = Vector3.ZERO
	movement_velocity = Vector3.ZERO
	gravity = 0.0

func _get_current_fall_limit() -> float:
	return maxf(fall_limit_y, respawn_position.y - fall_reset_margin)

func set_danger_visual(enabled: bool) -> void:
	is_in_danger_visual = enabled

func _ensure_player_ring() -> void:
	var existing_ring: MeshInstance3D = get_node_or_null("PlayerReadabilityRing") as MeshInstance3D
	if existing_ring:
		player_ring = existing_ring
		player_ring.mesh = _create_ring_mesh()
		if player_ring.material_override == null:
			player_ring.material_override = _create_ring_material()
		player_ring.position = Vector3(0.0, RING_FLOOR_Y, 0.0)
		player_ring.scale = Vector3(1.0, RING_THICKNESS_SCALE, 1.0)
		return

	var ring: MeshInstance3D = MeshInstance3D.new()
	ring.name = "PlayerReadabilityRing"
	ring.mesh = _create_ring_mesh()
	ring.position = Vector3(0.0, RING_FLOOR_Y, 0.0)
	ring.scale = Vector3(1.0, RING_THICKNESS_SCALE, 1.0)
	ring.material_override = _create_ring_material()
	add_child(ring)
	player_ring = ring

func _create_ring_mesh() -> TorusMesh:
	var mesh: TorusMesh = TorusMesh.new()
	mesh.inner_radius = 0.62
	mesh.outer_radius = 0.78
	mesh.rings = 32
	mesh.ring_segments = 18
	return mesh

func _ensure_player_shadow() -> void:
	var existing_shadow: MeshInstance3D = get_node_or_null("TokenGroundShadow") as MeshInstance3D
	if existing_shadow:
		player_shadow = existing_shadow
		return

	var shadow: MeshInstance3D = MeshInstance3D.new()
	shadow.name = "TokenGroundShadow"
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = 0.58
	mesh.bottom_radius = 0.58
	mesh.height = 0.028
	mesh.radial_segments = 24
	shadow.mesh = mesh
	shadow.scale = Vector3(1.18, 1.0, 0.68)
	shadow.position = Vector3(0.1, 0.015, 0.14)
	shadow.material_override = _create_shadow_material()
	add_child(shadow)
	player_shadow = shadow

func _ensure_role_beacon() -> void:
	var existing_beacon: MeshInstance3D = get_node_or_null("TokenRoleBeacon") as MeshInstance3D
	if existing_beacon:
		role_beacon = existing_beacon
		return

	var beacon: MeshInstance3D = MeshInstance3D.new()
	beacon.name = "TokenRoleBeacon"
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.bottom_radius = 0.2
	mesh.top_radius = 0.0
	mesh.height = 0.42
	mesh.radial_segments = 4
	beacon.mesh = mesh
	beacon.position = Vector3(0.0, 2.55, 0.0)
	beacon.rotation_degrees.y = 45.0
	beacon.material_override = _create_beacon_material(fugitive_emission_color)
	add_child(beacon)
	role_beacon = beacon

func _ensure_presentation_avatar() -> void:
	avatar_body = get_node_or_null("HeistAvatarBody") as MeshInstance3D
	avatar_head = get_node_or_null("HeistAvatarHead") as MeshInstance3D
	avatar_visor = get_node_or_null("HeistAvatarVisor") as MeshInstance3D

	if avatar_body == null:
		avatar_body = MeshInstance3D.new()
		avatar_body.name = "HeistAvatarBody"
		var body_mesh: CapsuleMesh = CapsuleMesh.new()
		body_mesh.radius = 0.34
		body_mesh.height = 1.42
		body_mesh.radial_segments = 16
		body_mesh.rings = 6
		avatar_body.mesh = body_mesh
		avatar_body.position = Vector3(0.0, 1.22, 0.0)
		add_child(avatar_body)

	if avatar_head == null:
		avatar_head = MeshInstance3D.new()
		avatar_head.name = "HeistAvatarHead"
		var head_mesh: SphereMesh = SphereMesh.new()
		head_mesh.radius = 0.32
		head_mesh.height = 0.48
		head_mesh.radial_segments = 16
		head_mesh.rings = 8
		avatar_head.mesh = head_mesh
		avatar_head.position = Vector3(0.0, 2.02, -0.02)
		add_child(avatar_head)

	if avatar_visor == null:
		avatar_visor = MeshInstance3D.new()
		avatar_visor.name = "HeistAvatarVisor"
		var visor_mesh: BoxMesh = BoxMesh.new()
		visor_mesh.size = Vector3(0.52, 0.1, 0.08)
		avatar_visor.mesh = visor_mesh
		avatar_visor.position = Vector3(0.0, 2.07, -0.28)
		add_child(avatar_visor)

	_update_presentation_avatar_palette()

func _remove_presentation_avatar() -> void:
	if avatar_body:
		avatar_body.queue_free()
		avatar_body = null
	if avatar_head:
		avatar_head.queue_free()
		avatar_head = null
	if avatar_visor:
		avatar_visor.queue_free()
		avatar_visor = null

func _update_presentation_avatar_palette() -> void:
	var role_body_color: Color = hunter_body_color if is_infected else fugitive_body_color
	var role_glow_color: Color = hunter_emission_color if is_infected else fugitive_emission_color
	var role_glow_energy: float = hunter_emission_energy if is_infected else fugitive_emission_energy

	if avatar_body:
		avatar_body.material_override = _create_avatar_material(role_body_color, role_glow_color, role_glow_energy)
	if avatar_head:
		avatar_head.material_override = _create_avatar_material(role_body_color.lightened(0.14), role_glow_color, role_glow_energy * 0.85)
	if avatar_visor:
		avatar_visor.material_override = _create_avatar_material(Color(0.88, 0.96, 1.0, 1.0), role_glow_color, role_glow_energy * 1.2)

func _create_avatar_material(albedo: Color, emission_color: Color, emission_energy: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = albedo
	material.roughness = 0.2
	material.metallic = 0.16
	material.emission_enabled = true
	material.emission = emission_color
	material.emission_energy_multiplier = emission_energy
	return material

func _create_ring_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.71, 0.86, 1.0, 1.0)
	material.emission_enabled = true
	material.emission = Color(0.44, 0.72, 1.0, 1.0)
	material.emission_energy_multiplier = 0.42
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.no_depth_test = false
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material

func _create_shadow_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.0, 0.0, 0.0, 0.58)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material

func _create_beacon_material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 1.4
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.no_depth_test = true
	return material

func _ensure_speed_boost_vfx() -> void:
	if speed_boost_vfx != null:
		return

	var existing_vfx: GPUParticles3D = get_node_or_null("SpeedBoostVFX") as GPUParticles3D
	if existing_vfx != null:
		speed_boost_vfx = existing_vfx
		return

	var vfx: GPUParticles3D = GPUParticles3D.new()
	vfx.name = "SpeedBoostVFX"
	vfx.amount = 32
	vfx.lifetime = 0.38
	vfx.one_shot = false
	vfx.explosiveness = 0.0
	vfx.local_coords = true
	vfx.draw_pass_1 = _create_speed_boost_vfx_mesh()
	vfx.process_material = _create_speed_boost_vfx_process_material()
	vfx.position = Vector3(0.0, 1.0, 0.0)
	vfx.emitting = false
	add_child(vfx)
	speed_boost_vfx = vfx

func _create_speed_boost_vfx_mesh() -> QuadMesh:
	var mesh: QuadMesh = QuadMesh.new()
	mesh.size = Vector2(0.09, 0.26)

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(speed_boost_vfx_color.r, speed_boost_vfx_color.g, speed_boost_vfx_color.b, 0.88)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.emission_enabled = true
	material.emission = speed_boost_vfx_color
	material.emission_energy_multiplier = 0.75
	mesh.material = material
	return mesh

func _create_speed_boost_vfx_process_material() -> ParticleProcessMaterial:
	var material: ParticleProcessMaterial = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(0.35, 0.6, 0.35)
	material.direction = Vector3(0.0, 0.0, 1.0)
	material.spread = 180.0
	material.initial_velocity_min = 1.8
	material.initial_velocity_max = 3.4
	material.gravity = Vector3(0.0, 0.0, 0.0)
	material.scale_min = 0.5
	material.scale_max = 1.0
	return material

func _update_player_ring() -> void:
	if player_ring == null:
		return

	var pulse: float = (sin(visual_pulse_time * 6.0) + 1.0) * 0.5
	var material: StandardMaterial3D = player_ring.material_override as StandardMaterial3D
	if material == null:
		return

	if is_infected:
		player_ring.scale = Vector3(1.0 + pulse * 0.1, RING_THICKNESS_SCALE, 1.0 + pulse * 0.1)
		material.albedo_color = Color(0.976, 0.451, 0.086, 0.86)
		material.emission = hunter_emission_color
		material.emission_energy_multiplier = 0.75 + pulse * 0.55
	elif is_in_danger_visual:
		player_ring.scale = Vector3(1.0 + pulse * 0.14, RING_THICKNESS_SCALE, 1.0 + pulse * 0.14)
		material.albedo_color = Color(0.961, 0.62, 0.043, 0.86)
		material.emission = Color(0.961, 0.62, 0.043, 1.0)
		material.emission_energy_multiplier = 0.7 + pulse * 0.42
	else:
		player_ring.scale = Vector3(1.0 + pulse * 0.06, RING_THICKNESS_SCALE, 1.0 + pulse * 0.06)
		material.albedo_color = Color(0.898, 0.933, 0.973, 0.78)
		material.emission = Color(0.898, 0.933, 0.973, 1.0)
		material.emission_energy_multiplier = 0.45 + pulse * 0.18

func _update_token_presence(delta: float) -> void:
	var planar_speed: float = Vector2(velocity.x, velocity.z).length()
	var move_pulse: float = clamp(planar_speed / max(move_speed, 0.001), 0.0, 1.0)
	var danger_pulse: float = (sin(visual_pulse_time * 8.0) + 1.0) * 0.5
	var role_color: Color = hunter_emission_color if is_infected else fugitive_emission_color

	if pop_timer > 0.0:
		pop_timer = max(pop_timer - delta, 0.0)

	if player_shadow:
		var shadow_scale: float = 1.0 + move_pulse * 0.18
		player_shadow.scale = Vector3(1.18 * shadow_scale, 1.0, 0.68 * shadow_scale)

	if role_beacon:
		var beacon_material: StandardMaterial3D = role_beacon.material_override as StandardMaterial3D
		if beacon_material:
			beacon_material.albedo_color = role_color
			beacon_material.emission = role_color
			beacon_material.emission_energy_multiplier = 1.1 + danger_pulse * (0.9 if is_infected or is_in_danger_visual else 0.25)
		role_beacon.rotation_degrees.y += delta * (120.0 if is_infected else 70.0)
		role_beacon.scale = Vector3.ONE * (0.58 + danger_pulse * (0.08 if is_infected or is_in_danger_visual else 0.03))

	if avatar_body:
		avatar_body.rotation_degrees.z = sin(visual_pulse_time * 8.0) * 2.5 * move_pulse
	if avatar_head:
		avatar_head.position = Vector3(0.0, 2.02 + sin(visual_pulse_time * 7.0) * 0.018 * move_pulse, -0.02)
	if avatar_visor:
		avatar_visor.position = Vector3(0.0, 2.07 + sin(visual_pulse_time * 7.0) * 0.018 * move_pulse, -0.28)

	if character_visual:
		var pop_scale: float = 1.0 + (pop_timer / 0.32) * 0.3
		var bob: float = sin(visual_pulse_time * 9.0) * 0.035 * move_pulse
		var squash_xz: float = 1.0 + move_pulse * 0.035
		character_visual.scale = Vector3(
			squash_xz * pop_scale * visual_scale,
			(1.0 - move_pulse * 0.02) * pop_scale * visual_scale,
			squash_xz * pop_scale * visual_scale
		)
		character_visual.position = visual_base_position + Vector3(0.0, bob, 0.0)

func _flash_role_change() -> void:
	if player_ring == null:
		return

	pop_timer = 0.32
	player_ring.scale = Vector3(1.28, RING_THICKNESS_SCALE, 1.28)
