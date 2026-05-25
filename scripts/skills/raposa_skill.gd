extends SkillBase

const BOOST_MULTIPLIER: float = 1.1
const BOOST_DURATION: float = 5.0

var boost_remaining: float = 0.0

func _init() -> void:
	display_name = "Fuga improvisada"
	cooldown_duration = 20.0

func _process(delta: float) -> void:
	super._process(delta)
	if boost_remaining <= 0.0:
		return

	boost_remaining = maxf(boost_remaining - delta, 0.0)
	if boost_remaining <= 0.0 and owner_player:
		owner_player.set_skill_speed_multiplier(1.0)
		if owner_player.has_method("set_speed_boost_vfx_enabled"):
			owner_player.call("set_speed_boost_vfx_enabled", false)

func try_activate() -> void:
	if not can_activate() or boost_remaining > 0.0:
		return

	boost_remaining = BOOST_DURATION
	owner_player.set_skill_speed_multiplier(BOOST_MULTIPLIER)
	if owner_player.has_method("set_speed_boost_vfx_enabled"):
		owner_player.call("set_speed_boost_vfx_enabled", true)
	_start_cooldown()
	_show_message("Raposa acelerou")

func cancel() -> void:
	super.cancel()
	boost_remaining = 0.0
	if owner_player:
		owner_player.set_skill_speed_multiplier(1.0)
		if owner_player.has_method("set_speed_boost_vfx_enabled"):
			owner_player.call("set_speed_boost_vfx_enabled", false)

func get_status_text() -> String:
	if boost_remaining > 0.0:
		return "%s %.1fs" % [display_name, boost_remaining]
	return super.get_status_text()
