class_name SkillController
extends Node

const RAPOSA_SKILL: Script = preload("res://scripts/skills/raposa_skill.gd")
const TIGRE_SKILL: Script = preload("res://scripts/skills/tigre_skill.gd")
const SAGUI_SKILL: Script = preload("res://scripts/skills/sagui_skill.gd")
const COELHA_SKILL: Script = preload("res://scripts/skills/coelha_skill.gd")

var owner_player: FugitivePlayer = null
var round_manager: Node = null
var skill: SkillBase = null
var input_manager: Node = null

func setup(new_owner: FugitivePlayer, character_id: String, new_round_manager: Node) -> void:
	owner_player = new_owner
	round_manager = new_round_manager
	input_manager = get_node_or_null("/root/InputManager")
	var skill_script: Script = _get_skill_script(character_id)
	if skill_script == null:
		return

	skill = skill_script.new() as SkillBase
	if skill == null:
		return

	add_child(skill)
	skill.setup(owner_player, round_manager)

func _process(_delta: float) -> void:
	if skill == null or owner_player == null:
		return
	if owner_player.is_infected or not owner_player.input_enabled:
		return

	if input_manager == null or not input_manager.has_method("consume_ability_pressed"):
		return

	if bool(input_manager.call("consume_ability_pressed", owner_player.device_id)):
		skill.try_activate()

func get_status_text() -> String:
	if skill == null:
		return ""
	return skill.get_status_text()

func get_skill_display_name() -> String:
	if skill == null:
		return ""
	return skill.get_display_name()

func get_skill_cooldown_fill_ratio() -> float:
	if skill == null:
		return 1.0
	return skill.get_cooldown_fill_ratio()

func is_skill_ready() -> bool:
	if skill == null:
		return false
	return skill.is_ready()

func cancel() -> void:
	if skill:
		skill.cancel()

func _get_skill_script(character_id: String) -> Script:
	match character_id:
		"raposa":
			return RAPOSA_SKILL
		"tigre":
			return TIGRE_SKILL
		"sagui":
			return SAGUI_SKILL
		"coelha":
			return COELHA_SKILL
		_:
			return null
