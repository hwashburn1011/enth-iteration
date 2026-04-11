extends Node
## AmbientSoundscapeMixer — runtime mixer that applies layered ambient
## beds from `AmbientSoundscapeDatabase` per wilderness region. Crossfades
## slot-by-slot so wind tones blend into wind tones (rather than stopping
## one and starting another), preventing the "ambient pop" that breaks
## immersion.
##
## Hooks:
##   EventBus.region_entered      → swap base bed
##   DayNightController.phase_changed → apply phase overlay
##   WeatherController.weather_changed → apply weather overlay
##
## Add to project autoloads as "AmbientSoundscapeMixer".
##
## This is the mixer LAYER ABOVE SFXManager — it commands SFXManager to
## start/stop loops by id and to crossfade their bus volume. SFXManager
## remains the single source of truth for actual playback.

signal slot_changed(slot: StringName, sfx_id: StringName)

const DEFAULT_FADE_OUT_S: float = 1.5

var _active_slots: Dictionary = {}    # slot → {sfx_id, db, player_handle}
var _current_region: StringName = &""
var _current_phase: StringName = &""
var _current_weather: StringName = &""


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
	if has_node("/root/WeatherController"):
		var wc: Node = get_node("/root/WeatherController")
		if wc.has_signal("weather_changed"):
			wc.weather_changed.connect(_on_weather_changed)
		if "current_weather_id" in wc:
			_current_weather = StringName(wc.current_weather_id)


# === REGION CHANGE ===

func apply_region(region_id: StringName) -> void:
	if region_id == _current_region:
		return
	_current_region = region_id

	# Try the wilderness catalog first, then the hub catalog. Lets the
	# same mixer drive both wild_* regions and hub_* spaces with the
	# same slot-aware crossfade behavior.
	var soundscape: Dictionary = AmbientSoundscapeDatabase.get_soundscape(region_id)
	if soundscape.is_empty():
		soundscape = HubAmbientSoundscapeDatabase.get_soundscape(region_id)
	if soundscape.is_empty():
		_stop_all_non_weather_slots()
		return

	# Build the desired slot map for the new region
	var desired: Dictionary = {}  # slot → layer dict
	for layer in soundscape.get("layers", []):
		desired[layer["slot"]] = layer

	# Apply phase overlay on top
	var phase_overlay: Dictionary = soundscape.get("phase_overlays", {}).get(_current_phase, {})
	if not phase_overlay.is_empty():
		desired[phase_overlay["slot"]] = phase_overlay

	# Stop slots no longer in the desired set (non-weather only)
	for slot in _active_slots.keys():
		if String(slot).begins_with("wx_"):
			continue
		if not desired.has(slot):
			_stop_slot(slot, DEFAULT_FADE_OUT_S)

	# Start or crossfade desired slots
	for slot in desired.keys():
		_apply_slot(slot, desired[slot])

	# Re-apply weather overlay (preserved across region changes)
	_apply_weather_overlay(_current_weather)


# === PHASE CHANGE ===

func _apply_phase_overlay() -> void:
	var soundscape: Dictionary = AmbientSoundscapeDatabase.get_soundscape(_current_region)
	if soundscape.is_empty():
		soundscape = HubAmbientSoundscapeDatabase.get_soundscape(_current_region)
	if soundscape.is_empty():
		return
	var overlays: Dictionary = soundscape.get("phase_overlays", {})

	# First clear any active overlay slots that don't belong in this phase
	for phase in overlays.keys():
		if phase == _current_phase:
			continue
		var stale: Dictionary = overlays[phase]
		var stale_slot: StringName = stale.get("slot", &"")
		# Only clear if this slot was supplied by an overlay (not a base layer)
		if _active_slots.has(stale_slot) and not _is_base_layer_slot(stale_slot, soundscape):
			_stop_slot(stale_slot, DEFAULT_FADE_OUT_S)

	var current_overlay: Dictionary = overlays.get(_current_phase, {})
	if not current_overlay.is_empty():
		_apply_slot(current_overlay["slot"], current_overlay)


func _is_base_layer_slot(slot: StringName, soundscape: Dictionary) -> bool:
	for layer in soundscape.get("layers", []):
		if layer.get("slot", &"") == slot:
			return true
	return false


# === WEATHER OVERLAY ===

func _apply_weather_overlay(weather_id: StringName) -> void:
	# Stop any wx_ slots from the previous weather
	for slot in _active_slots.keys():
		if String(slot).begins_with("wx_"):
			_stop_slot(slot, 2.0)

	var overlay: Array = AmbientSoundscapeDatabase.get_weather_overlay(weather_id)
	for layer in overlay:
		_apply_slot(layer["slot"], layer)


# === SLOT MANAGEMENT ===

func _apply_slot(slot: StringName, layer: Dictionary) -> void:
	var sfx_id: StringName = layer.get("sfx_id", &"")
	var db: float = layer.get("db", -12.0)
	var fade_in: float = layer.get("fade_in_s", 1.5)

	if sfx_id == &"":
		return

	var current: Dictionary = _active_slots.get(slot, {})
	if current.get("sfx_id", &"") == sfx_id:
		# Already playing this exact loop — just adjust volume
		_set_slot_volume(slot, db, fade_in)
		return

	# Crossfade: stop old, start new
	if not current.is_empty():
		_stop_slot(slot, fade_in * 0.6)

	var handle: Variant = _start_loop(sfx_id, db, fade_in)
	_active_slots[slot] = {
		"sfx_id": sfx_id,
		"db": db,
		"handle": handle,
	}
	slot_changed.emit(slot, sfx_id)


func _stop_slot(slot: StringName, fade_out_s: float) -> void:
	var current: Dictionary = _active_slots.get(slot, {})
	if current.is_empty():
		return
	_stop_loop(current.get("handle", null), fade_out_s)
	_active_slots.erase(slot)


func _stop_all_non_weather_slots() -> void:
	for slot in _active_slots.keys():
		if String(slot).begins_with("wx_"):
			continue
		_stop_slot(slot, DEFAULT_FADE_OUT_S)


# === SFX MANAGER BRIDGE ===

func _start_loop(sfx_id: StringName, db: float, fade_in_s: float) -> Variant:
	if not has_node("/root/SFXManager"):
		return null
	var sm: Node = get_node("/root/SFXManager")
	if sm.has_method("play_loop"):
		return sm.play_loop(sfx_id, db, fade_in_s)
	if sm.has_method("play"):
		sm.play(sfx_id)
	return null


func _stop_loop(handle: Variant, fade_out_s: float) -> void:
	if handle == null:
		return
	if not has_node("/root/SFXManager"):
		return
	var sm: Node = get_node("/root/SFXManager")
	if sm.has_method("stop_loop"):
		sm.stop_loop(handle, fade_out_s)


func _set_slot_volume(slot: StringName, db: float, fade_s: float) -> void:
	var current: Dictionary = _active_slots.get(slot, {})
	if current.is_empty():
		return
	current["db"] = db
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("fade_loop_volume"):
			sm.fade_loop_volume(current.get("handle", null), db, fade_s)


# === EVENT HANDLERS ===

func _on_region_entered(region_id: StringName, _meta: Dictionary) -> void:
	apply_region(region_id)


func _on_phase_changed(phase: StringName) -> void:
	_current_phase = phase
	_apply_phase_overlay()


func _on_weather_changed(weather_id: StringName) -> void:
	_current_weather = weather_id
	_apply_weather_overlay(weather_id)


# === QUERIES ===

func get_active_slot(slot: StringName) -> Dictionary:
	return _active_slots.get(slot, {})


func get_active_slot_count() -> int:
	return _active_slots.size()
