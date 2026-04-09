extends Node
## LightingStateController — manages dynamic lighting states within a zone.
## States: safe (default), danger (combat), story (cinematic), boss.
## Each state applies a multiplier to current preset values to dim/brighten
## without fully swapping presets.
##
## Add to project autoloads as "LightingStateController".

signal state_changed(new_state: StringName)

const TRANSITION_DURATION: float = 0.8

const STATE_MULTIPLIERS: Dictionary = {
	&"safe": {
		"sun_energy_mult": 1.0,
		"ambient_energy_mult": 1.0,
		"color_temp_shift": 0.0,  # warmer/cooler
		"saturation_mult": 1.0,
	},
	&"danger": {
		"sun_energy_mult": 0.7,
		"ambient_energy_mult": 0.8,
		"color_temp_shift": -0.3,  # cooler
		"saturation_mult": 0.85,
	},
	&"story": {
		"sun_energy_mult": 1.1,
		"ambient_energy_mult": 0.6,
		"color_temp_shift": 0.0,
		"saturation_mult": 1.05,
	},
	&"boss": {
		"sun_energy_mult": 1.5,
		"ambient_energy_mult": 0.5,
		"color_temp_shift": 0.4,  # warmer / dramatic
		"saturation_mult": 1.15,
	},
}

var current_state: StringName = &"safe"
var _tween: Tween


func _ready() -> void:
	_subscribe_to_events()


func _subscribe_to_events() -> void:
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("combat_started"):
			bus.combat_started.connect(func() -> void: set_state(&"danger"))
		if bus.has_signal("combat_ended"):
			bus.combat_ended.connect(func() -> void: set_state(&"safe"))
		if bus.has_signal("boss_intro"):
			bus.boss_intro.connect(func(_b: StringName) -> void: set_state(&"boss"))
		if bus.has_signal("boss_defeated"):
			bus.boss_defeated.connect(func(_b: StringName) -> void: set_state(&"safe"))
		if bus.has_signal("cinematic_started"):
			bus.cinematic_started.connect(func(_id: StringName) -> void: set_state(&"story"))
		if bus.has_signal("cinematic_finished"):
			bus.cinematic_finished.connect(func(_id: StringName) -> void: set_state(&"safe"))


func set_state(state: StringName) -> void:
	if not STATE_MULTIPLIERS.has(state):
		push_warning("LightingStateController: unknown state %s" % state)
		return
	current_state = state
	state_changed.emit(state)
	_apply_state_to_lights()


func _apply_state_to_lights() -> void:
	# Get the EnvironmentManager's sun light reference and apply multipliers
	if not has_node("/root/EnvironmentManager"):
		return
	var em: Node = get_node("/root/EnvironmentManager")
	if em.get("_sun_light") == null:
		return
	var sun: DirectionalLight3D = em.get("_sun_light")

	var multipliers: Dictionary = STATE_MULTIPLIERS[current_state]
	var energy_mult: float = multipliers.get("sun_energy_mult", 1.0)

	# Get the base energy from the current preset
	var preset: Dictionary = EnvironmentDatabase.get_preset(em.get("current_preset_id"))
	var base_energy: float = preset.get("sun_energy", 1.5)
	var target_energy: float = base_energy * energy_mult

	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(sun, "light_energy", target_energy, TRANSITION_DURATION)
