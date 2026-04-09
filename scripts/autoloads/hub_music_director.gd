extends Node
## HubMusicDirector — orchestrates the music for the 14 town hub
## spaces. Sister system to WildernessMusicDirector. Where the
## wilderness director runs a 4-layer stack (base wind drone +
## region track + combat layers + weather layer), the hub director
## is simpler — each hub space has its OWN dedicated zone track and
## the director just swaps it on region_entered.
##
## A few hub spaces have special behavior:
##   - Underground Lounge: zone track varies by phase
##     (hub_lounge_jukebox during the day, hub_lounge_live_set during
##     Sync's night shift — handled by LoungeStage directly via
##     MusicManager.play_zone_track, this director doesn't override)
##   - Memorial Gallery: zone track gets a special intro sting on
##     first entry per session
##   - Tower Top: phase-aware tracks (hub_tower_top_day vs night)
##
## Add to project autoloads as "HubMusicDirector".

const HUB_TRACKS_DAY: Dictionary = {
	&"hub_lounge":           &"hub_lounge_jukebox",
	&"hub_tower_top":        &"hub_tower_top_day",
	&"hub_sage_study":       &"hub_sage_study",
	&"hub_sage_library":     &"hub_sage_library",
	&"hub_training_arena":   &"hub_training_arena",
	&"hub_farm":             &"hub_farm_day",
	&"hub_fishing_dock":     &"hub_fishing_dock",
	&"hub_cooking":          &"hub_cooking",
	&"hub_workshop":         &"hub_workshop",
	&"hub_pet_hutch":        &"hub_pet_hutch",
	&"hub_memorial_gallery": &"hub_memorial_gallery",
	&"hub_trophy_hall":      &"hub_trophy_hall",
	&"hub_wardrobe":         &"hub_wardrobe",
	&"hub_hidden_treasure":  &"hub_hidden_treasure",
}

# Phase-variant tracks (only listed where they differ from day)
const HUB_TRACKS_NIGHT: Dictionary = {
	&"hub_tower_top":        &"hub_tower_top_night",
	&"hub_farm":             &"hub_farm_night",
	&"hub_memorial_gallery": &"hub_memorial_gallery_night",
}

const FIRST_ENTRY_STINGS: Dictionary = {
	&"hub_memorial_gallery": &"sting_memorial_first_entry",
	&"hub_hidden_treasure":  &"sting_treasure_first_entry",
	&"hub_tower_top":        &"sting_tower_first_entry",
}

var _current_region: StringName = &""
var _current_phase: StringName = &"day"
var _stings_played_this_session: Array[StringName] = []


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


# === REGION ===

func enter_region(region_id: StringName) -> void:
	# Only act on hub_* regions; let WildernessMusicDirector own wild_*
	if not String(region_id).begins_with("hub_"):
		return
	if region_id == _current_region:
		return
	_current_region = region_id
	_apply_track()
	_maybe_play_first_entry_sting(region_id)


func _apply_track() -> void:
	if _current_region == &"":
		return
	var track: StringName = _resolve_track(_current_region, _current_phase)
	if track == &"":
		return
	if has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_zone_track"):
			mm.play_zone_track(track)


func _resolve_track(region_id: StringName, phase: StringName) -> StringName:
	if phase == &"night" and HUB_TRACKS_NIGHT.has(region_id):
		return HUB_TRACKS_NIGHT[region_id]
	return HUB_TRACKS_DAY.get(region_id, &"")


# === FIRST-ENTRY STING ===

func _maybe_play_first_entry_sting(region_id: StringName) -> void:
	if not FIRST_ENTRY_STINGS.has(region_id):
		return
	var sting_id: StringName = FIRST_ENTRY_STINGS[region_id]
	if _stings_played_this_session.has(sting_id):
		return
	_stings_played_this_session.append(sting_id)
	if has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(sting_id)


# === EVENTS ===

func _on_region_entered(region_id: StringName, _meta: Dictionary) -> void:
	enter_region(region_id)


func _on_phase_changed(phase: StringName) -> void:
	_current_phase = phase
	# Re-apply track if we're in a phase-variant hub space
	if HUB_TRACKS_NIGHT.has(_current_region):
		_apply_track()


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"current_region": String(_current_region),
	}


func from_save_data(data: Dictionary) -> void:
	_current_region = StringName(data.get("current_region", ""))
	# Don't replay first-entry stings on load — those are session-only
	if _current_region != &"":
		_apply_track()
