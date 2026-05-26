extends Node3D

enum RoundState {
	COUNTDOWN,
	PLAYING,
	FUGITIVE_WIN,
	POLICE_WIN,
	MATCH_OVER,
}

enum PostRoundAdvanceStep {
	NONE,
	RESULT_SCREEN,
	POINTS_SCREEN,
}

const MapDaylightLightingScript: Script = preload("res://scripts/game/map_daylight_lighting.gd")
const MENU_SCENE_PATH: String = "res://scenes/ui/main_menu.tscn"
const ROUND_MUSIC_PATH: String = "res://assets/music/round.mpeg"
const PLAYER_CONTROL_COLORS: Array[Color] = [
	Color(0.95, 0.24, 0.2, 1.0),
	Color(0.22, 0.86, 0.42, 1.0),
	Color(0.25, 0.67, 1.0, 1.0),
	Color(1.0, 0.82, 0.21, 1.0),
]

@export var match_rounds: int = 4
@export var round_duration: float = 120.0
@export var round_intro_duration: float = 1.4
@export var post_round_result_duration: float = 2.0
@export var pre_round_countdown: float = 3.0
@export var final_score_lock_seconds: float = 10.0
@export var extraction_window_seconds: float = 12.0
@export var test_extractions_visible_from_start: bool = true
@export var capture_hitbox_radius: float = 0.48
@export var danger_distance: float = 6.0
@export var low_time_threshold: float = 12.0
@export var fugitive_speed: float = 11.0
@export var fugitive_acceleration: float = 13.5
@export var police_speed: float = 11.9
@export var police_acceleration: float = 9.2
@export var infected_hunter_speed: float = 10.8
@export var infected_hunter_acceleration: float = 8.6
@export var hunter_speed_loss_per_capture: float = 0.75
@export var minimum_hunter_speed: float = 9.0
@export var fugitive_speed_gain_per_capture: float = 0.55
@export var maximum_fugitive_speed: float = 12.6
@export var fugitive_spawn: Vector3 = Vector3(0.0, 2.0, 0.0)
@export var second_fugitive_spawn: Vector3 = Vector3(-12.0, 2.0, -4.0)
@export var third_fugitive_spawn: Vector3 = Vector3(-2.0, 2.0, -12.0)
@export var police_spawn: Vector3 = Vector3(7.0, 2.0, 0.0)

@onready var fugitive: FugitivePlayer = $PERSONAGEM
@onready var second_fugitive: FugitivePlayer = $FUGITIVO_2
@onready var third_fugitive: FugitivePlayer = $FUGITIVO_3
@onready var police: PolicePlayer = $POLICIAL
@onready var hud: RoundHud = $HUD
@onready var fugitive_spawn_marker: Node3D = get_node_or_null("FUGITIVE_SPAWN")
@onready var second_fugitive_spawn_marker: Node3D = get_node_or_null("FUGITIVE_2_SPAWN")
@onready var third_fugitive_spawn_marker: Node3D = get_node_or_null("FUGITIVE_3_SPAWN")
@onready var police_spawn_marker: Node3D = get_node_or_null("POLICE_SPAWN")
@onready var helipad_extraction: ExtractionPoint = get_node_or_null("HELIPAD_EXTRACTION") as ExtractionPoint
@onready var right_stairs_extraction: ExtractionPoint = get_node_or_null("RIGHT_STAIRS_EXTRACTION") as ExtractionPoint
@onready var left_door_extraction: ExtractionPoint = get_node_or_null("LEFT_DOOR_EXTRACTION") as ExtractionPoint

var current_state: int = RoundState.COUNTDOWN
var remaining_time: float = 0.0
var round_intro_remaining: float = 0.0
var countdown_remaining: float = 0.0
var police_character_name: String = "Policial"
var current_round_index: int = 0
var match_player_devices: Array[int] = []
var police_rotation_order: Array[int] = []
var player_scores: Dictionary = {}
var player_capture_totals: Dictionary = {}
var player_extraction_totals: Dictionary = {}
var current_police_device: int = -1
var current_round_captures: int = 0
var current_round_extractions: Array[int] = []
var current_round_survivors: Array[int] = []
var current_round_points: Dictionary = {}
var extraction_points_active: bool = false
var post_round_advance_step: int = PostRoundAdvanceStep.NONE
var final_score_time_left: float = 0.0
var final_score_return_unlocked: bool = false
var final_score_displayed_seconds: int = -1
var input_manager_ref: Node = null
var fugitive_slots: Array[FugitivePlayer] = []
var extraction_points: Array[ExtractionPoint] = []
var active_fugitives_cache: Array[FugitivePlayer] = []
var hunters_cache: Array[CharacterBody3D] = []
var danger_distance_squared: float = 0.0
var hud_update_accumulator: float = 0.0
var hunter_capture_areas: Dictionary = {}
var post_round_result_sequence: int = 0
const HUD_UPDATE_INTERVAL: float = 0.1
var round_music_player: AudioStreamPlayer = null

func _ready() -> void:
	_setup_round_music()
	input_manager_ref = get_node_or_null("/root/InputManager")
	fugitive_slots.clear()
	fugitive_slots.append(fugitive)
	fugitive_slots.append(second_fugitive)
	fugitive_slots.append(third_fugitive)
	_attach_map_daylight_lighting()
	_setup_extraction_points()
	_setup_hunter_capture_areas()
	danger_distance_squared = danger_distance * danger_distance
	_initialize_match_state()
	start_round()

func _setup_round_music() -> void:
	if round_music_player == null:
		round_music_player = get_node_or_null("RoundMusicPlayer") as AudioStreamPlayer
	if round_music_player == null:
		round_music_player = AudioStreamPlayer.new()
		round_music_player.name = "RoundMusicPlayer"
		add_child(round_music_player)
		move_child(round_music_player, 0)

	var music_stream: AudioStream = _load_music_stream(ROUND_MUSIC_PATH)
	if music_stream == null:
		push_warning("Nao foi possivel carregar a musica da partida em %s" % ROUND_MUSIC_PATH)
		return

	if music_stream is AudioStreamMP3:
		(music_stream as AudioStreamMP3).loop = true
	elif music_stream is AudioStreamOggVorbis:
		(music_stream as AudioStreamOggVorbis).loop = true
	elif music_stream is AudioStreamWAV:
		(music_stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD

	round_music_player.bus = "Master"
	round_music_player.volume_db = -9.0
	round_music_player.stream = music_stream
	if not round_music_player.playing:
		round_music_player.play()

func _load_music_stream(path: String) -> AudioStream:
	if path.get_extension().to_lower() != "mpeg":
		var stream: AudioStream = load(path) as AudioStream
		if stream != null:
			return stream
	if not FileAccess.file_exists(path):
		return null
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var mp3_stream: AudioStreamMP3 = AudioStreamMP3.new()
	mp3_stream.data = file.get_buffer(file.get_length())
	return mp3_stream

func _attach_map_daylight_lighting() -> void:
	var map_root: Node = get_node_or_null("MAPADEFINITIVO")
	if map_root == null:
		return
	if map_root.get_node_or_null("MapDaylightLighting") != null:
		return

	var lighting: Node = MapDaylightLightingScript.new()
	lighting.name = "MapDaylightLighting"
	map_root.add_child(lighting)

func _process(delta: float) -> void:
	if current_state == RoundState.MATCH_OVER:
		_process_match_over(delta)
		return

	if current_state != RoundState.PLAYING and current_state != RoundState.COUNTDOWN:
		_process_round_advance_input()

	if current_state == RoundState.COUNTDOWN:
		_process_countdown(delta)
		return

	if current_state != RoundState.PLAYING:
		return

	remaining_time = max(remaining_time - delta, 0.0)
	_update_extraction_window()
	hud_update_accumulator += delta
	_refresh_runtime_lists()
	_update_fugitive_visual_alerts()
	if hud_update_accumulator >= HUD_UPDATE_INTERVAL or remaining_time <= 0.0:
		hud_update_accumulator = 0.0
		_update_hud(_get_playing_status_message())

	if remaining_time <= 0.0:
		_finish_round(_get_timeout_result(), true)

func _process_match_over(delta: float) -> void:
	if final_score_return_unlocked:
		_process_round_advance_input()
		return

	if input_manager_ref != null and input_manager_ref.has_method("consume_match_advance_pressed"):
		input_manager_ref.call("consume_match_advance_pressed")

	final_score_time_left = max(final_score_time_left - delta, 0.0)
	var seconds_left: int = int(ceil(final_score_time_left))
	if seconds_left != final_score_displayed_seconds:
		final_score_displayed_seconds = seconds_left
		_update_match_result_text()

	if final_score_time_left > 0.0:
		return

	final_score_return_unlocked = true
	if input_manager_ref != null and input_manager_ref.has_method("clear_pressed_buttons"):
		input_manager_ref.call("clear_pressed_buttons")
	_update_match_result_text()

func _process_round_advance_input() -> void:
	if (current_state == RoundState.POLICE_WIN or current_state == RoundState.FUGITIVE_WIN) and post_round_advance_step == PostRoundAdvanceStep.RESULT_SCREEN:
		return

	if input_manager_ref == null or not input_manager_ref.has_method("consume_match_advance_pressed"):
		return
	if not bool(input_manager_ref.call("consume_match_advance_pressed")):
		return

	if current_state == RoundState.MATCH_OVER:
		get_tree().change_scene_to_file(MENU_SCENE_PATH)
		return

	if current_state == RoundState.POLICE_WIN or current_state == RoundState.FUGITIVE_WIN:
		_handle_post_round_advance_input()
		return

	_advance_to_next_round()

func start_round() -> void:
	if input_manager_ref != null and input_manager_ref.has_method("clear_pressed_buttons"):
		input_manager_ref.call("clear_pressed_buttons")
	current_round_captures = 0
	current_round_extractions.clear()
	current_round_survivors.clear()
	current_round_points.clear()
	post_round_advance_step = PostRoundAdvanceStep.NONE
	post_round_result_sequence += 1
	_set_capture_areas_enabled(false)
	_set_extraction_points_active(test_extractions_visible_from_start)
	hud_update_accumulator = 0.0
	_configure_players_for_current_round()
	current_state = RoundState.COUNTDOWN
	remaining_time = round_duration
	round_intro_remaining = round_intro_duration
	countdown_remaining = pre_round_countdown
	if fugitive.is_participating:
		fugitive.reset_state(_get_fugitive_spawn_position())
	if second_fugitive.is_participating:
		second_fugitive.reset_state(_get_second_fugitive_spawn_position())
	if third_fugitive.is_participating:
		third_fugitive.reset_state(_get_third_fugitive_spawn_position())
	police.reset_state(_get_police_spawn_position())
	_apply_speed_balance()
	if hud:
		hud.hide_round_result()
		hud.hide_round_points_breakdown()
		hud.hide_round_start_countdown()
	if fugitive.is_participating:
		fugitive.set_input_enabled(false)
	if second_fugitive.is_participating:
		second_fugitive.set_input_enabled(false)
	if third_fugitive.is_participating:
		third_fugitive.set_input_enabled(false)
	police.set_input_enabled(false)
	_refresh_runtime_lists()
	_update_hud(_get_countdown_message())

func _finish_round(result: int, ended_by_timeout: bool = false) -> void:
	if current_state != RoundState.PLAYING:
		return

	current_state = result
	if fugitive.is_participating:
		fugitive.set_input_enabled(false)
	if second_fugitive.is_participating:
		second_fugitive.set_input_enabled(false)
	if third_fugitive.is_participating:
		third_fugitive.set_input_enabled(false)
	police.set_input_enabled(false)
	_set_capture_areas_enabled(false)
	_set_extraction_points_active(false)
	_clear_fugitive_visual_alerts()
	post_round_advance_step = PostRoundAdvanceStep.RESULT_SCREEN
	post_round_result_sequence += 1
	if hud:
		hud.hide_round_start_countdown()
	_award_round_points(ended_by_timeout)

	if _is_last_round():
		current_state = RoundState.MATCH_OVER
		final_score_time_left = max(final_score_lock_seconds, 0.0)
		final_score_return_unlocked = final_score_time_left <= 0.0
		final_score_displayed_seconds = int(ceil(final_score_time_left))
		if hud:
			hud.show_match_result(
				"Partida finalizada",
				_get_final_summary_text(),
				_build_final_ranking_entries(),
				_get_match_winner_text(),
				_get_match_action_text(),
				result == RoundState.FUGITIVE_WIN
			)
		_update_hud("Fim da partida! Vencedor: %s" % _get_match_winner_text())
		return

	if result == RoundState.POLICE_WIN:
		if hud:
			hud.show_round_banner("POLICIAL VENCEU", post_round_result_duration, true)
		_schedule_post_round_points_screen(post_round_result_sequence)
		_update_hud("Policial venceu a rodada! Proxima rodada liberada")
		return

	remaining_time = 0.0
	if hud:
		hud.show_round_banner("FUGITIVOS ESCAPARAM", post_round_result_duration, true)
	_schedule_post_round_points_screen(post_round_result_sequence)
	_update_hud("Extracao concluida! Proxima rodada liberada")

func _update_match_result_text() -> void:
	if hud:
		hud.update_match_result_prompt(_get_match_action_text())

func _get_match_action_text() -> String:
	if not final_score_return_unlocked:
		return "AGUARDE %dS PARA VOLTAR AO MENU" % maxi(final_score_displayed_seconds, 0)
	return "START / A - VOLTAR AO MENU"

func _update_hud(status_message: String) -> void:
	if not hud:
		return

	_refresh_runtime_lists()
	var active_fugitives: int = active_fugitives_cache.size()
	var participating_fugitives: int = _get_participating_fugitive_count()
	var hunter_count: int = hunters_cache.size()
	var timer_warning: bool = current_state == RoundState.PLAYING and remaining_time <= low_time_threshold
	hud.update_timer(remaining_time, timer_warning)
	hud.update_round_counts(active_fugitives, participating_fugitives, hunter_count)
	hud.update_match_info(current_round_index + 1, match_rounds, police_character_name)
	hud.update_scoreboard("PLACAR  %s" % _get_scoreboard_text())
	hud.update_skill_status(_get_skill_status_text())
	hud.update_player_skill_blocks(_build_skill_hud_blocks())
	hud.set_status(status_message, _get_status_color())
	hud.set_controls_hint(_get_controls_hint())

func _process_countdown(delta: float) -> void:
	if round_intro_remaining > 0.0:
		round_intro_remaining = max(round_intro_remaining - delta, 0.0)
		_update_hud("Rodada %d/%d" % [current_round_index + 1, match_rounds])
		if hud:
			hud.show_round_start_countdown(current_round_index + 1, int(ceil(countdown_remaining)), true)
		return

	countdown_remaining = max(countdown_remaining - delta, 0.0)
	_update_hud(_get_countdown_message())
	if hud:
		hud.show_round_start_countdown(current_round_index + 1, int(ceil(countdown_remaining)), false)

	if countdown_remaining > 0.0:
		return

	if hud:
		hud.hide_round_start_countdown()
	current_state = RoundState.PLAYING
	if input_manager_ref != null and input_manager_ref.has_method("clear_pressed_buttons"):
		input_manager_ref.call("clear_pressed_buttons")
	if fugitive.is_participating:
		fugitive.set_input_enabled(true)
	if second_fugitive.is_participating:
		second_fugitive.set_input_enabled(true)
	if third_fugitive.is_participating:
		third_fugitive.set_input_enabled(true)
	police.set_input_enabled(true)
	if _get_participating_fugitive_count() <= 0:
		_finish_round(RoundState.POLICE_WIN)
		return
	_sync_capture_areas_for_hunters()
	_update_hud("Valendo! Fugitivos precisam sobreviver ate o tempo acabar")

func _get_countdown_message() -> String:
	if countdown_remaining > 0.0:
		return "Rodada %d/%d | %s e o policial | Comeca em %d" % [current_round_index + 1, match_rounds, police_character_name, int(ceil(countdown_remaining))]
	return "Cofre aberto!"

func _get_playing_status_message() -> String:
	if extraction_points_active:
		return "Extracoes liberadas! Alcance uma saida"

	if _get_active_fugitives().size() == 1:
		return "Ultimo fugitivo livre no banco"

	if _is_any_fugitive_in_danger():
		return "Alerta! Policial perto dos fugitivos"

	if remaining_time <= low_time_threshold:
		return "Ultimos segundos para fugir do banco"

	return "Fugitivos precisam segurar ate o timer zerar"

func _get_status_color() -> Color:
	if current_state == RoundState.COUNTDOWN:
		return RoundHud.COLOR_INFO

	if current_state == RoundState.POLICE_WIN:
		return RoundHud.COLOR_DANGER

	if current_state == RoundState.FUGITIVE_WIN:
		return RoundHud.COLOR_SUCCESS

	if _is_any_fugitive_in_danger():
		return RoundHud.COLOR_DANGER

	if remaining_time <= low_time_threshold:
		return RoundHud.COLOR_WARNING

	return RoundHud.COLOR_DEFAULT

func _get_controls_hint() -> String:
	if current_state == RoundState.MATCH_OVER or current_state == RoundState.POLICE_WIN or current_state == RoundState.FUGITIVE_WIN:
		return ""
	if current_state == RoundState.COUNTDOWN:
		return "Mover e habilidade dos fugitivos"
	return ""

func _initialize_match_state() -> void:
	match_rounds = maxi(match_rounds, 1)
	match_player_devices.clear()
	police_rotation_order.clear()
	player_scores.clear()
	player_capture_totals.clear()
	player_extraction_totals.clear()

	if input_manager_ref == null or not input_manager_ref.has_method("get_joined_devices"):
		return

	var joined_result: Variant = input_manager_ref.call("get_joined_devices")
	if not (joined_result is Array):
		return

	var joined_devices: Array = joined_result as Array
	for joined_device: Variant in joined_devices:
		var device_id: int = int(joined_device)
		match_player_devices.append(device_id)
		player_scores[device_id] = 0
		player_capture_totals[device_id] = 0
		player_extraction_totals[device_id] = 0

	if match_player_devices.is_empty():
		return

	var first_police_device: int = -1
	if input_manager_ref.has_method("get_police_device"):
		first_police_device = int(input_manager_ref.call("get_police_device"))

	if first_police_device != -1 and first_police_device in match_player_devices:
		police_rotation_order.append(first_police_device)

	for device_id: int in match_player_devices:
		if device_id not in police_rotation_order:
			police_rotation_order.append(device_id)

func _configure_players_for_current_round() -> void:
	if police_rotation_order.is_empty():
		_configure_players_from_lobby()
		current_police_device = police.device_id
		_apply_player_identification_colors()
		return

	current_police_device = police_rotation_order[current_round_index % police_rotation_order.size()]
	police.device_id = current_police_device
	if input_manager_ref != null and input_manager_ref.has_method("set_police_device"):
		input_manager_ref.call("set_police_device", current_police_device)
	police_character_name = _get_player_display_name(current_police_device)

	var fugitive_devices: Array[int] = []
	for device_id: int in match_player_devices:
		if device_id != current_police_device:
			fugitive_devices.append(device_id)

	_assign_fugitive_from_device_list(fugitive, fugitive_devices, 0, input_manager_ref)
	_assign_fugitive_from_device_list(second_fugitive, fugitive_devices, 1, input_manager_ref)
	_assign_fugitive_from_device_list(third_fugitive, fugitive_devices, 2, input_manager_ref)
	_apply_player_identification_colors()

func _setup_extraction_points() -> void:
	extraction_points.clear()
	var configured_points: Array[ExtractionPoint] = []
	configured_points.append(helipad_extraction)
	configured_points.append(right_stairs_extraction)
	configured_points.append(left_door_extraction)
	for point: ExtractionPoint in configured_points:
		if point == null:
			continue
		extraction_points.append(point)
		if not point.fugitive_entered.is_connected(_on_extraction_point_entered):
			point.fugitive_entered.connect(_on_extraction_point_entered)
		point.set_extraction_active(false)

func _setup_hunter_capture_areas() -> void:
	hunter_capture_areas.clear()
	_add_hunter_capture_area(police)
	for player: FugitivePlayer in fugitive_slots:
		_add_hunter_capture_area(player)

func _add_hunter_capture_area(hunter: CharacterBody3D) -> void:
	if hunter == null:
		return

	var area: Area3D = Area3D.new()
	area.name = "CaptureContactArea"
	area.collision_layer = 0
	area.collision_mask = 1
	area.monitorable = false
	area.monitoring = false

	var shape_node: CollisionShape3D = CollisionShape3D.new()
	var shape: CylinderShape3D = CylinderShape3D.new()
	shape.radius = capture_hitbox_radius
	shape.height = 2.25
	shape_node.position = Vector3(0.0, 1.15, 0.0)
	shape_node.shape = shape
	area.add_child(shape_node)
	hunter.add_child(area)
	area.body_entered.connect(_on_hunter_capture_body_entered.bind(hunter))
	hunter_capture_areas[hunter] = area

func _set_capture_areas_enabled(enabled: bool) -> void:
	for hunter: Variant in hunter_capture_areas.keys():
		var area: Area3D = hunter_capture_areas[hunter] as Area3D
		if area != null:
			area.set_deferred("monitoring", enabled)

func _sync_capture_areas_for_hunters() -> void:
	for hunter_variant: Variant in hunter_capture_areas.keys():
		var hunter: CharacterBody3D = hunter_variant as CharacterBody3D
		var area: Area3D = hunter_capture_areas[hunter_variant] as Area3D
		if hunter == null or area == null:
			continue
		area.set_deferred("monitoring", current_state == RoundState.PLAYING and hunter in hunters_cache)

func _on_hunter_capture_body_entered(body: Node3D, hunter: CharacterBody3D) -> void:
	if current_state != RoundState.PLAYING or body == hunter:
		return
	if not (body is FugitivePlayer):
		return

	var target: FugitivePlayer = body as FugitivePlayer
	if not target.is_participating or target.is_infected or target.is_captured or target.is_extracted:
		return
	_infect_fugitive(target)

func _advance_to_next_round() -> void:
	current_round_index += 1
	if current_round_index >= match_rounds:
		get_tree().reload_current_scene()
		return

	start_round()

func _handle_post_round_advance_input() -> void:
	if post_round_advance_step == PostRoundAdvanceStep.RESULT_SCREEN:
		_show_post_round_points_screen()
		return

	if post_round_advance_step == PostRoundAdvanceStep.POINTS_SCREEN:
		if hud:
			hud.hide_round_points_breakdown()
		post_round_advance_step = PostRoundAdvanceStep.NONE
		_advance_to_next_round()

func _show_post_round_points_screen() -> void:
	if post_round_advance_step != PostRoundAdvanceStep.RESULT_SCREEN:
		return
	post_round_advance_step = PostRoundAdvanceStep.POINTS_SCREEN
	if hud:
		hud.hide_round_result()
		hud.show_round_points_breakdown(_build_round_points_breakdown())
	_update_hud("")

func _schedule_post_round_points_screen(sequence_id: int) -> void:
	var delay: float = maxf(post_round_result_duration, 0.0)
	if delay <= 0.0:
		_on_post_round_points_delay_timeout(sequence_id)
		return
	var timer: SceneTreeTimer = get_tree().create_timer(delay)
	timer.timeout.connect(_on_post_round_points_delay_timeout.bind(sequence_id))

func _on_post_round_points_delay_timeout(sequence_id: int) -> void:
	if sequence_id != post_round_result_sequence:
		return
	if current_state != RoundState.POLICE_WIN and current_state != RoundState.FUGITIVE_WIN:
		return
	if post_round_advance_step != PostRoundAdvanceStep.RESULT_SCREEN:
		return
	_show_post_round_points_screen()

func _is_last_round() -> bool:
	return current_round_index >= match_rounds - 1

func _award_round_points(ended_by_timeout: bool) -> void:
	if current_police_device != -1:
		_add_round_score(current_police_device, current_round_captures)

	if not ended_by_timeout:
		return

	_refresh_runtime_lists()
	for player: FugitivePlayer in active_fugitives_cache:
		if player.device_id == -1 or player.device_id in current_round_extractions:
			continue
		current_round_survivors.append(player.device_id)
		_add_round_score(player.device_id, 1)

func _add_round_score(device_id: int, points: int) -> void:
	if points <= 0:
		return
	_add_score(device_id, points)
	current_round_points[device_id] = int(current_round_points.get(device_id, 0)) + points

func _add_score(device_id: int, points: int) -> void:
	if points <= 0:
		return
	if not player_scores.has(device_id):
		player_scores[device_id] = 0
	player_scores[device_id] = int(player_scores[device_id]) + points

func _get_scoreboard_text() -> String:
	var score_parts: Array[String] = []
	for device_id: int in match_player_devices:
		score_parts.append("%s %d" % [_get_short_player_name(device_id), int(player_scores.get(device_id, 0))])

	if score_parts.is_empty():
		return "Sem placar"

	return " | ".join(score_parts)

func _get_round_points_text() -> String:
	var score_parts: Array[String] = []
	for device_id: int in match_player_devices:
		score_parts.append("%s +%d" % [_get_short_player_name(device_id), int(current_round_points.get(device_id, 0))])
	return " | ".join(score_parts) if not score_parts.is_empty() else "Sem pontos"

func _build_round_points_breakdown() -> Array[Dictionary]:
	var points_rows: Array[Dictionary] = []
	var max_rows: int = mini(match_player_devices.size(), 4)
	for row_index: int in range(max_rows):
		var device_id: int = match_player_devices[row_index]
		points_rows.append({
			"player_name": _get_player_display_name(device_id),
			"gained_points": int(current_round_points.get(device_id, 0)),
			"total_points": int(player_scores.get(device_id, 0)),
			"is_police": device_id == current_police_device,
		})
	return points_rows

func _get_final_ranking_text() -> String:
	var lines: Array[String] = []
	var ranked_devices: Array[int] = match_player_devices.duplicate()
	ranked_devices.sort_custom(_compare_score_devices)
	for index: int in range(ranked_devices.size()):
		var device_id: int = ranked_devices[index]
		lines.append("%d. %s - %d PTS" % [index + 1, _get_player_display_name(device_id).to_upper(), int(player_scores.get(device_id, 0))])
	return "\n".join(lines) if not lines.is_empty() else "SEM JOGADORES"

func _get_final_summary_text() -> String:
	var capture_total: int = 0
	var extraction_total: int = 0
	for device_id: int in match_player_devices:
		capture_total += int(player_capture_totals.get(device_id, 0))
		extraction_total += int(player_extraction_totals.get(device_id, 0))
	return "CAPTURAS: %d   EXTRAIDOS: %d   RODADAS: %d" % [capture_total, extraction_total, match_rounds]

func _build_final_ranking_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var ranked_devices: Array[int] = match_player_devices.duplicate()
	ranked_devices.sort_custom(_compare_score_devices)
	var best_score: int = int(player_scores.get(ranked_devices[0], 0)) if not ranked_devices.is_empty() else -1
	for index: int in range(ranked_devices.size()):
		var device_id: int = ranked_devices[index]
		entries.append({
			"rank": index + 1,
			"character_id": _get_player_character_id(device_id),
			"name": _get_player_display_name(device_id).to_upper(),
			"points": int(player_scores.get(device_id, 0)),
			"last_round_points": int(current_round_points.get(device_id, 0)),
			"captures": int(player_capture_totals.get(device_id, 0)),
			"extractions": int(player_extraction_totals.get(device_id, 0)),
			"is_winner": int(player_scores.get(device_id, 0)) == best_score,
		})
	return entries

func _compare_score_devices(first_device: int, second_device: int) -> bool:
	var first_score: int = int(player_scores.get(first_device, 0))
	var second_score: int = int(player_scores.get(second_device, 0))
	if first_score == second_score:
		return match_player_devices.find(first_device) < match_player_devices.find(second_device)
	return first_score > second_score

func _get_short_player_name(device_id: int) -> String:
	var display_name: String = _get_player_display_name(device_id).to_upper()
	if display_name.length() <= 4:
		return display_name
	return display_name.substr(0, 4)

func _get_match_winner_text() -> String:
	var best_score: int = -1
	var winner_names: Array[String] = []
	for device_id: int in match_player_devices:
		var score: int = int(player_scores.get(device_id, 0))
		if score > best_score:
			best_score = score
			winner_names.clear()
			winner_names.append(_get_player_display_name(device_id))
		elif score == best_score:
			winner_names.append(_get_player_display_name(device_id))

	if winner_names.is_empty():
		return "Sem vencedor"
	if winner_names.size() > 1:
		return "Empate: %s" % ", ".join(winner_names)
	return winner_names[0]

func _get_player_display_name(device_id: int) -> String:
	if input_manager_ref != null and input_manager_ref.has_method("get_character_name_for_device"):
		var character_name: String = str(input_manager_ref.call("get_character_name_for_device", device_id))
		if not character_name.is_empty():
			return character_name

	if input_manager_ref != null and input_manager_ref.has_method("get_keyboard_device_id"):
		var keyboard_device_id: int = int(input_manager_ref.call("get_keyboard_device_id"))
		if device_id == keyboard_device_id:
			return "Teclado"

	return "Controle %d" % device_id

func _get_player_character_id(device_id: int) -> String:
	if input_manager_ref != null and input_manager_ref.has_method("get_character_for_device"):
		return str(input_manager_ref.call("get_character_for_device", device_id))
	return ""

func show_skill_message(_player: FugitivePlayer, message: String) -> void:
	if hud:
		hud.show_round_banner(message)

func get_skill_hunters(_player: FugitivePlayer) -> Array[CharacterBody3D]:
	_refresh_runtime_lists()
	return hunters_cache

func _on_extraction_point_entered(player: FugitivePlayer, _point: ExtractionPoint) -> void:
	if current_state != RoundState.PLAYING or not extraction_points_active:
		return
	if player == null or player.device_id == -1:
		return
	if player.device_id in current_round_extractions:
		return
	if player.is_extracted or player.is_infected or not player.is_participating:
		return

	player.extract()
	current_round_extractions.append(player.device_id)
	_add_stat(player_extraction_totals, player.device_id)
	_add_round_score(player.device_id, 2)
	_refresh_runtime_lists()
	if hud:
		hud.show_capture_flash("%s escapou" % _get_player_display_name(player.device_id).to_upper())

	if active_fugitives_cache.is_empty():
		_finish_round(RoundState.FUGITIVE_WIN)
		return

	_update_hud("Extracao feita! Restantes precisam chegar a uma saida")

func _set_extraction_points_active(enabled: bool) -> void:
	extraction_points_active = enabled
	for point: ExtractionPoint in extraction_points:
		if point != null:
			point.set_extraction_active(enabled)

func _update_extraction_window() -> void:
	if extraction_points_active:
		return
	if remaining_time > extraction_window_seconds:
		return

	_set_extraction_points_active(true)
	if hud:
		hud.show_round_banner("EXTRACOES LIBERADAS")

func _get_timeout_result() -> int:
	if current_round_extractions.is_empty():
		return RoundState.POLICE_WIN
	return RoundState.FUGITIVE_WIN

func _get_round_summary_text() -> String:
	var summary_lines: Array[String] = [
		"Capturas: %d | Extraidos: %s" % [current_round_captures, _get_extracted_names_text()],
	]
	if not current_round_survivors.is_empty():
		summary_lines.append("Sobreviveram: %s" % _get_device_names_text(current_round_survivors))
	summary_lines.append("Pontos da rodada: %s" % _get_round_points_text())
	return "\n".join(summary_lines)

func _get_extracted_names_text() -> String:
	return _get_device_names_text(current_round_extractions)

func _get_device_names_text(device_ids: Array[int]) -> String:
	if device_ids.is_empty():
		return "nenhum"

	var names: Array[String] = []
	for device_id: int in device_ids:
		names.append(_get_player_display_name(device_id))
	return ", ".join(names)

func _get_fugitive_spawn_position() -> Vector3:
	if fugitive_spawn_marker:
		return fugitive_spawn_marker.global_position
	return fugitive_spawn

func _get_second_fugitive_spawn_position() -> Vector3:
	if second_fugitive_spawn_marker:
		return second_fugitive_spawn_marker.global_position
	return second_fugitive_spawn

func _get_third_fugitive_spawn_position() -> Vector3:
	if third_fugitive_spawn_marker:
		return third_fugitive_spawn_marker.global_position
	return third_fugitive_spawn

func _get_police_spawn_position() -> Vector3:
	if police_spawn_marker:
		return police_spawn_marker.global_position
	return police_spawn

func _get_active_fugitives() -> Array[FugitivePlayer]:
	_refresh_runtime_lists()
	return active_fugitives_cache

func _get_participating_fugitive_count() -> int:
	var total: int = 0
	for player: FugitivePlayer in fugitive_slots:
		if player.is_participating:
			total += 1
	return total

func _get_fugitive_slots() -> Array[FugitivePlayer]:
	return fugitive_slots

func _get_hunters() -> Array[CharacterBody3D]:
	_refresh_runtime_lists()
	return hunters_cache

func _refresh_runtime_lists() -> void:
	active_fugitives_cache.clear()
	hunters_cache.clear()
	if police:
		hunters_cache.append(police)

	for player: FugitivePlayer in fugitive_slots:
		if player == null:
			continue
		if player.is_infected:
			hunters_cache.append(player)
		elif player.is_participating and not player.is_captured and not player.is_extracted:
			active_fugitives_cache.append(player)

func _infect_fugitive(target: FugitivePlayer) -> void:
	if target == null or target.is_infected:
		return

	target.infect()
	current_round_captures += 1
	_add_stat(player_capture_totals, current_police_device)
	_apply_infected_hunter_balance()
	_refresh_runtime_lists()
	_sync_capture_areas_for_hunters()
	if hud:
		hud.show_capture_flash("Fugitivo interceptado")

	if active_fugitives_cache.is_empty():
		_finish_round(_get_timeout_result())
		return

	_update_hud("Alarme reforcado! Mais um pegador na perseguicao")

func _add_stat(stats: Dictionary, device_id: int) -> void:
	if device_id == -1:
		return
	stats[device_id] = int(stats.get(device_id, 0)) + 1

func _is_any_fugitive_in_danger() -> bool:
	for active_fugitive: FugitivePlayer in active_fugitives_cache:
		for hunter: CharacterBody3D in hunters_cache:
			if _get_planar_distance_squared(active_fugitive.global_position, hunter.global_position) <= danger_distance_squared:
				return true
	return false

func _update_fugitive_visual_alerts() -> void:
	for active_fugitive: FugitivePlayer in active_fugitives_cache:
		var is_in_danger: bool = false
		for hunter: CharacterBody3D in hunters_cache:
			if _get_planar_distance_squared(active_fugitive.global_position, hunter.global_position) <= danger_distance_squared:
				is_in_danger = true
				break
		active_fugitive.set_danger_visual(is_in_danger)

func _clear_fugitive_visual_alerts() -> void:
	for active_fugitive: FugitivePlayer in _get_active_fugitives():
		active_fugitive.set_danger_visual(false)

func _get_planar_distance_squared(point_a: Vector3, point_b: Vector3) -> float:
	var offset_x: float = point_a.x - point_b.x
	var offset_z: float = point_a.z - point_b.z
	return offset_x * offset_x + offset_z * offset_z

func _apply_infected_hunter_balance() -> void:
	_apply_speed_balance()

func _apply_speed_balance() -> void:
	var capture_count: int = _get_capture_count()
	var active_fugitive_speed: float = minf(
		fugitive_speed + float(capture_count) * fugitive_speed_gain_per_capture,
		maximum_fugitive_speed
	)
	var hunter_speed: float = maxf(
		police_speed - float(capture_count) * hunter_speed_loss_per_capture,
		minimum_hunter_speed
	)

	if capture_count > 0:
		hunter_speed = minf(hunter_speed, infected_hunter_speed)

	if police:
		police.configure_movement(hunter_speed, police_acceleration if capture_count == 0 else infected_hunter_acceleration)

	for active_fugitive: FugitivePlayer in _get_active_fugitives():
		active_fugitive.configure_movement(active_fugitive_speed, fugitive_acceleration)

	if fugitive and fugitive.is_infected:
		fugitive.configure_movement(hunter_speed, infected_hunter_acceleration)

	if second_fugitive and second_fugitive.is_infected:
		second_fugitive.configure_movement(hunter_speed, infected_hunter_acceleration)

	if third_fugitive and third_fugitive.is_infected:
		third_fugitive.configure_movement(hunter_speed, infected_hunter_acceleration)

func _get_capture_count() -> int:
	_refresh_runtime_lists()
	return _get_participating_fugitive_count() - active_fugitives_cache.size()

func _get_skill_status_text() -> String:
	var status_parts: Array[String] = []
	for player: FugitivePlayer in fugitive_slots:
		if not player.is_participating or player.is_infected:
			continue
		var skill_status: String = player.get_skill_status_text()
		if not skill_status.is_empty():
			status_parts.append(skill_status)

	if status_parts.is_empty():
		return ""

	return "SKILL  %s" % "  |  ".join(status_parts)

func _build_skill_hud_blocks() -> Array[Dictionary]:
	var blocks: Array[Dictionary] = []
	var max_blocks: int = mini(match_player_devices.size(), 4)
	for slot_index: int in range(max_blocks):
		var device_id: int = match_player_devices[slot_index]
		blocks.append(_build_skill_hud_block_for_device(device_id, slot_index))
	return blocks

func _build_skill_hud_block_for_device(device_id: int, slot_index: int) -> Dictionary:
	var player_color: Color = _get_player_control_color(device_id)
	if device_id == current_police_device:
		return {
			"slot_label": "P%d" % [slot_index + 1],
			"player_name": _get_player_display_name(device_id).to_upper(),
			"ability_name": "SEM HABILIDADE",
			"cooldown_fill_ratio": 1.0,
			"is_ready": false,
			"is_police": true,
			"is_active": true,
			"player_color": player_color,
		}

	var player: FugitivePlayer = _find_fugitive_by_device(device_id)
	if player == null or not player.is_participating:
		return {
			"slot_label": "P%d" % [slot_index + 1],
			"player_name": _get_player_display_name(device_id).to_upper(),
			"ability_name": "SEM HABILIDADE",
			"cooldown_fill_ratio": 0.0,
			"is_ready": false,
			"is_police": false,
			"is_active": false,
			"player_color": player_color,
		}

	var skill_data: Dictionary = player.get_skill_hud_data()
	return {
		"slot_label": "P%d" % [slot_index + 1],
		"player_name": _get_player_display_name(device_id).to_upper(),
		"ability_name": str(skill_data.get("ability_name", "SEM HABILIDADE")).to_upper(),
		"cooldown_fill_ratio": float(skill_data.get("cooldown_fill_ratio", 0.0)),
		"is_ready": bool(skill_data.get("is_ready", false)),
		"is_police": false,
		"is_active": player.is_participating and not player.is_infected and not player.is_extracted,
		"player_color": player_color,
	}

func _find_fugitive_by_device(device_id: int) -> FugitivePlayer:
	for player: FugitivePlayer in fugitive_slots:
		if player != null and player.device_id == device_id:
			return player
	return null

func _configure_players_from_lobby() -> void:
	var input_manager: Node = get_node_or_null("/root/InputManager")
	if input_manager == null or not input_manager.has_method("get_joined_devices"):
		return

	var joined_result: Variant = input_manager.call("get_joined_devices")
	if not (joined_result is Array):
		return

	var joined_devices: Array = joined_result as Array
	if joined_devices.is_empty():
		return

	if input_manager.has_method("get_police_device") and input_manager.has_method("get_fugitive_devices"):
		var chosen_police_device: int = int(input_manager.call("get_police_device"))
		if chosen_police_device != -1:
			police.device_id = chosen_police_device
			var police_name_result: Variant = input_manager.call("get_police_character_name")
			var selected_police_name: String = str(police_name_result)
			if not selected_police_name.is_empty():
				police_character_name = selected_police_name

			var fugitive_result: Variant = input_manager.call("get_fugitive_devices")
			if fugitive_result is Array:
				var fugitive_devices: Array = fugitive_result as Array
				_assign_fugitive_from_device_list(fugitive, fugitive_devices, 0, input_manager)
				_assign_fugitive_from_device_list(second_fugitive, fugitive_devices, 1, input_manager)
				_assign_fugitive_from_device_list(third_fugitive, fugitive_devices, 2, input_manager)
				return

	police.device_id = int(joined_devices[0])
	police_character_name = _get_player_display_name(police.device_id)

	_assign_fugitive_slot(fugitive, joined_devices, 1)
	_assign_fugitive_slot(second_fugitive, joined_devices, 2)
	_assign_fugitive_slot(third_fugitive, joined_devices, 3)

func _assign_fugitive_from_device_list(player: FugitivePlayer, fugitive_devices: Array, fugitive_index: int, input_manager: Node) -> void:
	if fugitive_devices.size() > fugitive_index:
		player.device_id = int(fugitive_devices[fugitive_index])
		player.is_participating = true
		player.visible = true
		var character_id: String = ""
		if input_manager != null and input_manager.has_method("get_character_for_device"):
			character_id = str(input_manager.call("get_character_for_device", player.device_id))
		player.configure_skill(character_id, self)
		return

	player.clear_skill()
	player.deactivate_slot()

func _assign_fugitive_slot(player: FugitivePlayer, joined_devices: Array, joined_index: int) -> void:
	if joined_devices.size() > joined_index:
		player.device_id = int(joined_devices[joined_index])
		player.is_participating = true
		player.visible = true
		player.clear_skill()
		return

	player.device_id = -1
	player.clear_skill()
	player.deactivate_slot()

func _apply_player_identification_colors() -> void:
	if police != null and police.has_method("set_player_identity_color"):
		police.call("set_player_identity_color", _get_player_control_color(police.device_id))
	for player: FugitivePlayer in fugitive_slots:
		if player == null:
			continue
		if player.has_method("set_player_identity_color"):
			player.call("set_player_identity_color", _get_player_control_color(player.device_id))

func _get_player_control_color(device_id: int) -> Color:
	var slot_index: int = match_player_devices.find(device_id)
	if slot_index >= 0 and slot_index < PLAYER_CONTROL_COLORS.size():
		return PLAYER_CONTROL_COLORS[slot_index]
	return Color(0.86, 0.9, 0.96, 1.0)
