extends Node3D

enum RoundState {
	COUNTDOWN,
	PLAYING,
	FUGITIVE_WIN,
	POLICE_WIN,
	MATCH_OVER,
}

const MapDaylightLightingScript: Script = preload("res://scripts/game/map_daylight_lighting.gd")

@export var match_rounds: int = 4
@export var round_duration: float = 120.0
@export var pre_round_countdown: float = 3.0
@export var extraction_window_seconds: float = 12.0
@export var capture_distance: float = 1.35
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
var countdown_remaining: float = 0.0
var police_character_name: String = "Policial"
var current_round_index: int = 0
var match_player_devices: Array[int] = []
var police_rotation_order: Array[int] = []
var player_scores: Dictionary = {}
var current_police_device: int = -1
var current_round_captures: int = 0
var current_round_extractions: Array[int] = []
var extraction_points_active: bool = false
var input_manager_ref: Node = null
var fugitive_slots: Array[FugitivePlayer] = []
var extraction_points: Array[ExtractionPoint] = []
var active_fugitives_cache: Array[FugitivePlayer] = []
var hunters_cache: Array[CharacterBody3D] = []
var capture_distance_squared: float = 0.0
var danger_distance_squared: float = 0.0
var hud_update_accumulator: float = 0.0
const HUD_UPDATE_INTERVAL: float = 0.1

func _ready() -> void:
	input_manager_ref = get_node_or_null("/root/InputManager")
	fugitive_slots.clear()
	fugitive_slots.append(fugitive)
	fugitive_slots.append(second_fugitive)
	fugitive_slots.append(third_fugitive)
	_attach_map_daylight_lighting()
	_setup_extraction_points()
	capture_distance_squared = capture_distance * capture_distance
	danger_distance_squared = danger_distance * danger_distance
	_initialize_match_state()
	start_round()

func _attach_map_daylight_lighting() -> void:
	var map_root: Node = get_node_or_null("MAPADEFINITIVO")
	if map_root == null:
		return
	if map_root.get_node_or_null("MapDaylightLighting") != null:
		return

	var lighting: Node = MapDaylightLightingScript.new()
	lighting.name = "MapDaylightLighting"
	map_root.add_child(lighting)

func _physics_process(_delta: float) -> void:
	if current_state != RoundState.PLAYING:
		return

	_refresh_runtime_lists()
	for active_fugitive: FugitivePlayer in active_fugitives_cache:
		for hunter: CharacterBody3D in hunters_cache:
			if _get_planar_distance_squared(active_fugitive.global_position, hunter.global_position) <= capture_distance_squared:
				_infect_fugitive(active_fugitive)
				return

func _process(delta: float) -> void:
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
		_finish_round(_get_timeout_result())

func _process_round_advance_input() -> void:
	if input_manager_ref == null or not input_manager_ref.has_method("consume_match_advance_pressed"):
		return
	if not bool(input_manager_ref.call("consume_match_advance_pressed")):
		return

	if current_state == RoundState.MATCH_OVER:
		get_tree().reload_current_scene()
		return
	_advance_to_next_round()

func start_round() -> void:
	if input_manager_ref != null and input_manager_ref.has_method("clear_pressed_buttons"):
		input_manager_ref.call("clear_pressed_buttons")
	current_round_captures = 0
	current_round_extractions.clear()
	_set_extraction_points_active(false)
	hud_update_accumulator = 0.0
	_configure_players_for_current_round()
	current_state = RoundState.COUNTDOWN
	remaining_time = round_duration
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
		hud.show_round_banner("Rodada %d/%d" % [current_round_index + 1, match_rounds])
	if fugitive.is_participating:
		fugitive.set_input_enabled(false)
	if second_fugitive.is_participating:
		second_fugitive.set_input_enabled(false)
	if third_fugitive.is_participating:
		third_fugitive.set_input_enabled(false)
	police.set_input_enabled(false)
	_refresh_runtime_lists()
	_update_hud(_get_countdown_message())

func _finish_round(result: int) -> void:
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
	_set_extraction_points_active(false)
	_clear_fugitive_visual_alerts()
	_award_round_points(result)

	var round_summary: String = _get_round_summary_text()
	if _is_last_round():
		current_state = RoundState.MATCH_OVER
		if hud:
			hud.show_round_result("Partida finalizada", "%s\nPlacar: %s\nVencedor: %s\nUse START ou confirmar para reiniciar" % [round_summary, _get_scoreboard_text(), _get_match_winner_text()], result == RoundState.FUGITIVE_WIN)
		_update_hud("Fim da partida! Vencedor: %s" % _get_match_winner_text())
		return

	if result == RoundState.POLICE_WIN:
		if hud:
			hud.show_round_result("Policial venceu", "Nenhum fugitivo conseguiu extrair.\n%s\nUse START ou confirmar para a proxima rodada" % round_summary, false)
		_update_hud("Policial venceu a rodada! Proxima rodada liberada")
		return

	remaining_time = 0.0
	if hud:
		hud.show_round_result("Fugitivos escaparam", "Extraidos: %s\n%s\nUse START ou confirmar para a proxima rodada" % [_get_extracted_names_text(), round_summary], true)
	_update_hud("Extracao concluida! Proxima rodada liberada")

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
	hud.set_status(status_message, _get_status_color())
	hud.set_controls_hint(_get_controls_hint())

func _process_countdown(delta: float) -> void:
	countdown_remaining = max(countdown_remaining - delta, 0.0)
	_update_hud(_get_countdown_message())

	if countdown_remaining > 0.0:
		return

	current_state = RoundState.PLAYING
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
	if current_state == RoundState.MATCH_OVER:
		return "Reiniciar partida"
	if current_state == RoundState.POLICE_WIN or current_state == RoundState.FUGITIVE_WIN:
		return "Proxima rodada"
	if current_state == RoundState.COUNTDOWN:
		return "Mover e habilidade dos fugitivos"
	return ""

func _initialize_match_state() -> void:
	match_rounds = maxi(match_rounds, 1)
	match_player_devices.clear()
	police_rotation_order.clear()
	player_scores.clear()

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

func _advance_to_next_round() -> void:
	current_round_index += 1
	if current_round_index >= match_rounds:
		get_tree().reload_current_scene()
		return

	start_round()

func _is_last_round() -> bool:
	return current_round_index >= match_rounds - 1

func _award_round_points(_result: int) -> void:
	if current_police_device != -1:
		_add_score(current_police_device, current_round_captures)

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

	return "Controle %d" % device_id

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
	_add_score(player.device_id, 1)
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
	return "Capturas: %d | Extraidos: %s" % [current_round_captures, _get_extracted_names_text()]

func _get_extracted_names_text() -> String:
	if current_round_extractions.is_empty():
		return "nenhum"

	var names: Array[String] = []
	for device_id: int in current_round_extractions:
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
	_apply_infected_hunter_balance()
	_refresh_runtime_lists()
	if hud:
		hud.show_capture_flash("Fugitivo interceptado")

	if active_fugitives_cache.is_empty():
		_finish_round(_get_timeout_result())
		return

	_update_hud("Alarme reforcado! Mais um pegador na perseguicao")

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
	police_character_name = "Controle %d" % police.device_id

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
