class_name PolicePlayer
extends CharacterBody3D

const POLICE_VISUAL_SCENE: PackedScene = preload("res://assets/models/PERSONAGENS/policef1.tscn")

@export var device_id: int = 0
@export var move_speed: float = 11.0
@export var acceleration: float = 9.5
@export var rotation_lerp_speed: float = 9.0
@export var body_color: Color = Color(0.015, 0.105, 0.32, 1.0)
@export var emission_color: Color = Color(0.22, 0.74, 0.97, 1.0)
@export var emission_energy: float = 2.85
@export var visual_scale: float = 1.25
@export var fall_limit_y: float = -5.0
@export var fall_reset_margin: float = 18.0

@onready var animator: AnimationPlayer = find_child("AnimationPlayer", true, false) as AnimationPlayer
@onready var character_visual: Node3D = find_child("boneco", true, false) as Node3D

var gravity: float = 0.0
var base_move_speed: float = 11.0
var disruption_speed_multiplier: float = 1.0
var disruption_slow_timer: float = 0.0
var disruption_stun_timer: float = 0.0
var input_enabled: bool = true
var rotation_direction: float = 0.0
var respawn_position: Vector3 = Vector3.ZERO
var visual_pulse_time: float = 0.0
var player_ring: MeshInstance3D = null
var player_shadow: MeshInstance3D = null
var role_beacon: MeshInstance3D = null
var avatar_body: MeshInstance3D = null
var avatar_head: MeshInstance3D = null
var avatar_visor: MeshInstance3D = null
var visual_base_position: Vector3 = Vector3.ZERO
var idle_animation_name: String = ""
var run_animation_name: String = ""
var input_manager_ref: Node = null
var uses_imported_character_visual: bool = false
var player_identity_color: Color = Color(0.976, 0.451, 0.086, 1.0)
const RING_FLOOR_Y: float = 0.09
const RING_THICKNESS_SCALE: float = 0.11

func _ready() -> void:
	base_move_speed = move_speed
	input_manager_ref = get_node_or_null("/root/InputManager")
	_use_imported_police_visual()
	_cache_animation_names()
	if character_visual:
		visual_base_position = character_visual.position
		character_visual.scale = Vector3.ONE * visual_scale
	_ensure_player_shadow()
	_ensure_player_ring()
	_ensure_role_beacon()
	if character_visual == null:
		_ensure_presentation_avatar()
	_apply_visual_palette()

func _physics_process(delta: float) -> void:
	visual_pulse_time += delta
	_update_player_ring()
	_update_token_presence(delta)
	_update_disruption(delta)

	if global_position.y < _get_current_fall_limit():
		_restore_to_spawn()
		return

	if disruption_stun_timer > 0.0:
		velocity = Vector3.ZERO
	elif input_enabled:
		var direction: Vector3 = _get_move_direction()
		var target_velocity: Vector3 = Vector3(direction.x, 0.0, direction.z) * _get_effective_move_speed()
		var applied_velocity: Vector3 = velocity.lerp(target_velocity, delta * acceleration)
		applied_velocity.y = _get_vertical_velocity(delta)
		velocity = applied_velocity
	else:
		velocity = Vector3.ZERO

	move_and_slide()

	if Vector2(velocity.z, velocity.x).length() > 0.1:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * rotation_lerp_speed)
	_handle_animation()

func _get_vertical_velocity(delta: float) -> float:
	if not is_on_floor():
		gravity += 25.0 * delta
	else:
		gravity = 0.0
	return -gravity

func set_input_enabled(enabled: bool) -> void:
	input_enabled = enabled
	if not enabled:
		velocity = Vector3.ZERO

func reset_state(spawn_position: Vector3) -> void:
	respawn_position = spawn_position
	disruption_speed_multiplier = 1.0
	disruption_slow_timer = 0.0
	disruption_stun_timer = 0.0
	if character_visual:
		character_visual.scale = Vector3.ONE * visual_scale
	_restore_to_spawn()
	input_enabled = true

func configure_movement(speed: float, new_acceleration: float) -> void:
	base_move_speed = speed
	move_speed = _get_effective_move_speed()
	acceleration = new_acceleration

func set_player_identity_color(color: Color) -> void:
	player_identity_color = color
	_update_player_ring()

func apply_hunter_disruption(stun_seconds: float, slow_multiplier: float, slow_seconds: float) -> void:
	if stun_seconds > 0.0:
		disruption_stun_timer = maxf(disruption_stun_timer, stun_seconds)
	if slow_seconds > 0.0:
		disruption_speed_multiplier = clampf(slow_multiplier, 0.0, 1.0)
		disruption_slow_timer = maxf(disruption_slow_timer, slow_seconds)
	move_speed = _get_effective_move_speed()

func is_controller_connected() -> bool:
	var input_manager: Node = _get_input_manager()
	if input_manager == null or not input_manager.has_method("has_device"):
		return false
	return bool(input_manager.call("has_device", device_id))

func _get_move_direction() -> Vector3:
	var input_manager: Node = _get_input_manager()
	if input_manager != null and input_manager.has_method("get_movement"):
		var movement_result: Variant = input_manager.call("get_movement", device_id)
		if movement_result is Vector3:
			return movement_result

	return Vector3.ZERO

func _get_input_manager() -> Node:
	return input_manager_ref

func _update_disruption(delta: float) -> void:
	if disruption_stun_timer > 0.0:
		disruption_stun_timer = maxf(disruption_stun_timer - delta, 0.0)

	if disruption_slow_timer <= 0.0:
		return

	disruption_slow_timer = maxf(disruption_slow_timer - delta, 0.0)
	if disruption_slow_timer <= 0.0:
		disruption_speed_multiplier = 1.0
		move_speed = _get_effective_move_speed()

func _get_effective_move_speed() -> float:
	return base_move_speed * disruption_speed_multiplier

func _handle_animation() -> void:
	if not animator or not is_on_floor():
		return

	if not input_enabled or (abs(velocity.x) <= 1.0 and abs(velocity.z) <= 1.0):
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

func _apply_visual_palette() -> void:
	var palette_material: StandardMaterial3D = StandardMaterial3D.new()
	palette_material.albedo_color = body_color
	palette_material.roughness = 0.22
	palette_material.metallic = 0.08
	palette_material.emission_enabled = emission_energy > 0.0
	palette_material.emission = emission_color
	palette_material.emission_energy_multiplier = emission_energy
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
	gravity = 0.0

func _get_current_fall_limit() -> float:
	return maxf(fall_limit_y, respawn_position.y - fall_reset_margin)

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
	mesh.inner_radius = 0.64
	mesh.outer_radius = 0.82
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
	mesh.top_radius = 0.62
	mesh.bottom_radius = 0.62
	mesh.height = 0.028
	mesh.radial_segments = 24
	shadow.mesh = mesh
	shadow.scale = Vector3(1.22, 1.0, 0.7)
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
	mesh.bottom_radius = 0.22
	mesh.top_radius = 0.0
	mesh.height = 0.48
	mesh.radial_segments = 4
	beacon.mesh = mesh
	beacon.position = Vector3(0.0, 2.65, 0.0)
	beacon.rotation_degrees.y = 45.0
	beacon.material_override = _create_beacon_material(emission_color)
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
		body_mesh.radius = 0.36
		body_mesh.height = 1.5
		body_mesh.radial_segments = 16
		body_mesh.rings = 6
		avatar_body.mesh = body_mesh
		avatar_body.position = Vector3(0.0, 1.26, 0.0)
		add_child(avatar_body)

	if avatar_head == null:
		avatar_head = MeshInstance3D.new()
		avatar_head.name = "HeistAvatarHead"
		var head_mesh: SphereMesh = SphereMesh.new()
		head_mesh.radius = 0.34
		head_mesh.height = 0.5
		head_mesh.radial_segments = 16
		head_mesh.rings = 8
		avatar_head.mesh = head_mesh
		avatar_head.position = Vector3(0.0, 2.12, -0.02)
		add_child(avatar_head)

	if avatar_visor == null:
		avatar_visor = MeshInstance3D.new()
		avatar_visor.name = "HeistAvatarVisor"
		var visor_mesh: BoxMesh = BoxMesh.new()
		visor_mesh.size = Vector3(0.56, 0.1, 0.08)
		avatar_visor.mesh = visor_mesh
		avatar_visor.position = Vector3(0.0, 2.17, -0.3)
		add_child(avatar_visor)

	_update_presentation_avatar_palette()

func _use_imported_police_visual() -> void:
	var new_visual: Node3D = POLICE_VISUAL_SCENE.instantiate() as Node3D
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
	animator = find_child("AnimationPlayer", true, false) as AnimationPlayer

func _update_presentation_avatar_palette() -> void:
	if avatar_body:
		avatar_body.material_override = _create_avatar_material(body_color, emission_color, emission_energy)
	if avatar_head:
		avatar_head.material_override = _create_avatar_material(body_color.lightened(0.12), emission_color, emission_energy * 0.9)
	if avatar_visor:
		avatar_visor.material_override = _create_avatar_material(Color(0.88, 0.96, 1.0, 1.0), emission_color, emission_energy * 1.2)

func _create_avatar_material(albedo: Color, avatar_emission: Color, avatar_energy: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = albedo
	material.roughness = 0.18
	material.metallic = 0.18
	material.emission_enabled = true
	material.emission = avatar_emission
	material.emission_energy_multiplier = avatar_energy
	return material

func _create_ring_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(player_identity_color.r, player_identity_color.g, player_identity_color.b, 0.86)
	material.emission_enabled = true
	material.emission = player_identity_color
	material.emission_energy_multiplier = 0.22
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.no_depth_test = false
	return material

func _create_shadow_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.0, 0.0, 0.0, 0.62)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material

func _create_beacon_material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 1.65
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.no_depth_test = true
	return material

func _update_player_ring() -> void:
	if player_ring == null:
		return

	var material: StandardMaterial3D = player_ring.material_override as StandardMaterial3D
	if material == null:
		return

	var pulse: float = (sin(visual_pulse_time * 7.5) + 1.0) * 0.5
	player_ring.scale = Vector3(1.0 + pulse * 0.12, RING_THICKNESS_SCALE, 1.0 + pulse * 0.12)
	material.albedo_color = Color(player_identity_color.r, player_identity_color.g, player_identity_color.b, 0.9)
	material.emission = player_identity_color
	material.emission_energy_multiplier = 0.82 + pulse * 0.56

func _update_token_presence(delta: float) -> void:
	var planar_speed: float = Vector2(velocity.x, velocity.z).length()
	var move_pulse: float = clamp(planar_speed / max(move_speed, 0.001), 0.0, 1.0)
	var danger_pulse: float = (sin(visual_pulse_time * 9.0) + 1.0) * 0.5

	if player_shadow:
		var shadow_scale: float = 1.0 + move_pulse * 0.22
		player_shadow.scale = Vector3(1.22 * shadow_scale, 1.0, 0.7 * shadow_scale)

	if role_beacon:
		var beacon_material: StandardMaterial3D = role_beacon.material_override as StandardMaterial3D
		if beacon_material:
			beacon_material.emission_energy_multiplier = 1.35 + danger_pulse * 1.15
		role_beacon.rotation_degrees.y += 150.0 * delta
		role_beacon.scale = Vector3.ONE * (0.66 + danger_pulse * 0.1)

	if avatar_body:
		avatar_body.rotation_degrees.z = sin(visual_pulse_time * 9.0) * 3.0 * move_pulse
	if avatar_head:
		avatar_head.position = Vector3(0.0, 2.12 + sin(visual_pulse_time * 8.0) * 0.02 * move_pulse, -0.02)
	if avatar_visor:
		avatar_visor.position = Vector3(0.0, 2.17 + sin(visual_pulse_time * 8.0) * 0.02 * move_pulse, -0.3)

	if character_visual:
		var bob: float = sin(visual_pulse_time * 10.0) * 0.04 * move_pulse
		var squash_xz: float = 1.0 + move_pulse * 0.045
		character_visual.scale = Vector3(
			squash_xz * visual_scale,
			(1.0 - move_pulse * 0.025) * visual_scale,
			squash_xz * visual_scale
		)
		character_visual.position = visual_base_position + Vector3(0.0, bob, 0.0)
