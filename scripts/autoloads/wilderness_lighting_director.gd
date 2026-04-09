extends Node
## WildernessLightingDirector — picks an EnvironmentDatabase preset based
## on (current wilderness region × current day-night phase) and asks
## EnvironmentManager to apply it. Crossfades follow whatever transition
## EnvironmentManager already does so the wilderness sky shifts smoothly
## from dawn-river to day-river without snapping.
##
## Add to project autoloads as "WildernessLightingDirector".

const REGION_PHASE_PRESETS: Dictionary = {
	&"wild_plateau": {
		&"dawn":  &"wild_plateau_dawn",
		&"day":   &"wild_plateau_day",
		&"dusk":  &"wild_plateau_dusk",
		&"night": &"wild_plateau_night",
	},
	&"wild_river": {
		&"dawn":  &"wild_river_dawn",
		&"day":   &"wild_river_day",
		&"dusk":  &"wild_river_dusk",
		&"night": &"wild_river_night",
	},
	&"wild_forest": {
		&"dawn":  &"wild_forest_dawn",
		&"day":   &"wild_forest_day",
		&"dusk":  &"wild_forest_dusk",
		&"night": &"wild_forest_night",
	},
	&"wild_ruins": {
		&"dawn":  &"wild_ruins_dawn",
		&"day":   &"wild_ruins_day",
		&"dusk":  &"wild_ruins_dusk",
		&"night": &"wild_ruins_night",
	},
	&"wild_cliffs": {
		&"dawn":  &"wild_cliffs_dawn",
		&"day":   &"wild_cliffs_day",
		&"dusk":  &"wild_cliffs_dusk",
		&"night": &"wild_cliffs_night",
	},
	&"wild_pasture": {
		&"dawn":  &"wild_pasture_dawn",
		&"day":   &"wild_pasture_day",
		&"dusk":  &"wild_pasture_dusk",
		&"night": &"wild_pasture_night",
	},
}

var _current_region: StringName = &""
var _current_phase: StringName = &"day"


func _ready() -> void:
	_subscribe_to_events()


func _subscribe_to_events() -> void:
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("region_entered"):
			bus.region_entered.connect(_on_region_entered)
	if has_node("/root/DayNightController"):
		var dnc: Node = get_node("/root/DayNightController")
		if dnc.has_signal("phase_changed"):
			dnc.phase_changed.connect(_on_phase_changed)
		if "current_phase" in dnc:
			_current_phase = StringName(dnc.current_phase)


func _on_region_entered(region_id: StringName, _meta: Dictionary) -> void:
	_current_region = region_id
	_apply_preset()


func _on_phase_changed(phase: StringName) -> void:
	_current_phase = phase
	if REGION_PHASE_PRESETS.has(_current_region):
		_apply_preset()


func _apply_preset() -> void:
	var phase_map: Dictionary = REGION_PHASE_PRESETS.get(_current_region, {})
	if phase_map.is_empty():
		return
	var preset_id: StringName = phase_map.get(_current_phase, &"")
	if preset_id == &"":
		return
	if has_node("/root/EnvironmentManager"):
		var em: Node = get_node("/root/EnvironmentManager")
		if em.has_method("apply_preset"):
			em.apply_preset(preset_id, true)
