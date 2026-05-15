class_name FugitivePlayer
extends CharacterBody3D

const DEFAULT_STUN: float = 2.0

@export var use_keyboard_input: bool = true
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
@export var visual_scale: float = 2.15
@export var fall_limit_y: float = -5.0

@onready var animator: AnimationPlayer = find_child("AnimationPlayer", true, false) as AnimationPlayer
@onready var character_visual: Node3D = find_child("boneco", true, false) as Node3D
@onready var view: Node3D = get_node_or_null(camera_path)

var movement_velocity: Vector3 = Vector3.ZERO
var gravity: float = 0.0
var rotation_direction: float = 0.0
var is_stunned: bool = false
var stun_timer: float = 0.0
var input_enabled: bool = true
var is_captured: bool = false
var is_infected: bool = false
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

func _ready() -> void:
	if character_visual:
		visual_base_position = character_visual.position
	_ensure_player_shadow()
	_ensure_player_ring()
	_ensure_role_beacon()
	_ensure_presentation_avatar()
	_apply_current_palette()

func _physics_process(delta: float) -> void:
	if not is_participating:
		return

	visual_pulse_time += delta
	_update_player_ring()
	_update_token_presence(delta)

	if global_position.y < fall_limit_y:
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

	movement_velocity = input.normalized() * move_speed if input.length() > 0.0 else Vector3.ZERO

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
	for animation_name: String in animator.get_animation_list():
		if animation_name.ends_with("/" + suffix) or animation_name == suffix:
			animator.play(animation_name, 0.3)
			return

func set_input_enabled(enabled: bool) -> void:
	input_enabled = enabled
	if not enabled:
		velocity = Vector3.ZERO
		movement_velocity = Vector3.ZERO

func configure_movement(speed: float, new_acceleration: float) -> void:
	move_speed = speed
	acceleration = new_acceleration

func capture() -> void:
	infect()

func infect() -> void:
	is_captured = true
	is_infected = true
	is_in_danger_visual = false
	is_stunned = false
	stun_timer = 0.0
	input_enabled = true
	_apply_current_palette()
	_flash_role_change()

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
	is_in_danger_visual = false
	_apply_current_palette()
	_update_player_ring()

func deactivate_slot() -> void:
	is_participating = false
	visible = false
	input_enabled = false
	is_captured = true
	is_infected = false
	is_in_danger_visual = false
	is_stunned = false
	stun_timer = 0.0
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
	if use_keyboard_input:
		return _get_keyboard_direction()

	if device_id < 0:
		return Vector3.ZERO

	var input_manager: Node = _get_input_manager()
	if input_manager != null and input_manager.has_method("get_movement"):
		var movement_result: Variant = input_manager.call("get_movement", device_id)
		if movement_result is Vector3:
			return movement_result

	return Vector3.ZERO

func _get_keyboard_direction() -> Vector3:
	var input: Vector3 = Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_foward", "move_backwards")
	return input

func _get_input_manager() -> Node:
	return get_node_or_null("/root/InputManager")

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

func set_danger_visual(enabled: bool) -> void:
	is_in_danger_visual = enabled

func _ensure_player_ring() -> void:
	var existing_ring: MeshInstance3D = get_node_or_null("PlayerReadabilityRing") as MeshInstance3D
	if existing_ring:
		player_ring = existing_ring
		if player_ring.material_override == null:
			player_ring.material_override = _create_ring_material()
		return

	var ring: MeshInstance3D = MeshInstance3D.new()
	ring.name = "PlayerReadabilityRing"
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = 0.72
	mesh.bottom_radius = 0.72
	mesh.height = 0.045
	mesh.radial_segments = 48
	ring.mesh = mesh
	ring.position = Vector3(0.0, 0.075, 0.0)
	ring.material_override = _create_ring_material()
	add_child(ring)
	player_ring = ring

func _ensure_player_shadow() -> void:
	var existing_shadow: MeshInstance3D = get_node_or_null("TokenGroundShadow") as MeshInstance3D
	if existing_shadow:
		player_shadow = existing_shadow
		return

	var shadow: MeshInstance3D = MeshInstance3D.new()
	shadow.name = "TokenGroundShadow"
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = 0.92
	mesh.bottom_radius = 0.92
	mesh.height = 0.028
	mesh.radial_segments = 48
	shadow.mesh = mesh
	shadow.scale = Vector3(1.28, 1.0, 0.72)
	shadow.position = Vector3(0.16, 0.035, 0.22)
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
	mesh.bottom_radius = 0.28
	mesh.top_radius = 0.0
	mesh.height = 0.62
	mesh.radial_segments = 4
	beacon.mesh = mesh
	beacon.position = Vector3(0.0, 4.25, 0.0)
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
		body_mesh.radius = 0.58
		body_mesh.height = 2.35
		body_mesh.radial_segments = 24
		body_mesh.rings = 8
		avatar_body.mesh = body_mesh
		avatar_body.position = Vector3(0.0, 2.02, 0.0)
		add_child(avatar_body)

	if avatar_head == null:
		avatar_head = MeshInstance3D.new()
		avatar_head.name = "HeistAvatarHead"
		var head_mesh: SphereMesh = SphereMesh.new()
		head_mesh.radius = 0.55
		head_mesh.height = 0.8
		head_mesh.radial_segments = 24
		head_mesh.rings = 12
		avatar_head.mesh = head_mesh
		avatar_head.position = Vector3(0.0, 3.35, -0.03)
		add_child(avatar_head)

	if avatar_visor == null:
		avatar_visor = MeshInstance3D.new()
		avatar_visor.name = "HeistAvatarVisor"
		var visor_mesh: BoxMesh = BoxMesh.new()
		visor_mesh.size = Vector3(0.86, 0.16, 0.12)
		avatar_visor.mesh = visor_mesh
		avatar_visor.position = Vector3(0.0, 3.43, -0.47)
		add_child(avatar_visor)

	_update_presentation_avatar_palette()

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
	material.albedo_color = Color(0.898, 0.933, 0.973, 0.78)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.emission_enabled = true
	material.emission = Color(0.898, 0.933, 0.973, 1.0)
	material.emission_energy_multiplier = 0.45
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.no_depth_test = true
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

func _update_player_ring() -> void:
	if player_ring == null:
		return

	var pulse: float = (sin(visual_pulse_time * 6.0) + 1.0) * 0.5
	var material: StandardMaterial3D = player_ring.material_override as StandardMaterial3D
	if material == null:
		return

	if is_infected:
		player_ring.scale = Vector3.ONE * (1.0 + pulse * 0.1)
		material.albedo_color = Color(0.976, 0.451, 0.086, 0.86)
		material.emission = hunter_emission_color
		material.emission_energy_multiplier = 0.75 + pulse * 0.55
	elif is_in_danger_visual:
		player_ring.scale = Vector3.ONE * (1.0 + pulse * 0.14)
		material.albedo_color = Color(0.961, 0.62, 0.043, 0.86)
		material.emission = Color(0.961, 0.62, 0.043, 1.0)
		material.emission_energy_multiplier = 0.7 + pulse * 0.42
	else:
		player_ring.scale = Vector3.ONE
		material.albedo_color = Color(0.898, 0.933, 0.973, 0.78)
		material.emission = Color(0.898, 0.933, 0.973, 1.0)
		material.emission_energy_multiplier = 0.45

func _update_token_presence(delta: float) -> void:
	var planar_speed: float = Vector2(velocity.x, velocity.z).length()
	var move_pulse: float = clamp(planar_speed / max(move_speed, 0.001), 0.0, 1.0)
	var danger_pulse: float = (sin(visual_pulse_time * 8.0) + 1.0) * 0.5
	var role_color: Color = hunter_emission_color if is_infected else fugitive_emission_color

	if pop_timer > 0.0:
		pop_timer = max(pop_timer - delta, 0.0)

	if player_shadow:
		var shadow_scale: float = 1.0 + move_pulse * 0.18
		player_shadow.scale = Vector3(1.28 * shadow_scale, 1.0, 0.72 * shadow_scale)

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
		avatar_head.position = Vector3(0.0, 3.35 + sin(visual_pulse_time * 7.0) * 0.025 * move_pulse, -0.03)
	if avatar_visor:
		avatar_visor.position = Vector3(0.0, 3.43 + sin(visual_pulse_time * 7.0) * 0.025 * move_pulse, -0.47)

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
	player_ring.scale = Vector3.ONE * 1.28
