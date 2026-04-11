class_name DungeonEntrancePhaseTuner
extends Node3D

## Per-entrance phase-aware tuner. Sits next to a
## DungeonEntranceLighting + DungeonEntranceAmbience pair and applies
## per-phase multipliers to the lighting energies and particle amounts
## so each portal *looks different* across the day.
##
## The bible's intent: at dawn the portals are quietest (just emerging
## from night), at day they're at base intensity, at dusk they swell
## as the world dims, and at night they read as the only real light
## sources on the cliff face.
##
## Each entrance gets its own modulation curve so identity is preserved:
## the Final Vault dims even further at dawn (the Quiet One's hour)
## while the Wilds bloom largest at dusk and night.
##
## Required scene shape:
##   DungeonEntrancePhaseTuner (Node3D + this script)
##     [no children needed; references siblings via NodePath]
##
## Configure via inspector:
##   entrance_id   — must match a profile key
##   lighting_path — NodePath to the sibling DungeonEntranceLighting
##   ambience_path — NodePath to the sibling DungeonEntranceAmbience

const PROFILES: Dictionary = {
	&"server_room": {
		# server room is most active during day (the bookkeepers are awake)
		"key_mult":      {&"dawn": 0.85, &"day": 1.00, &"dusk": 1.10, &"night": 0.90},
		"rim_mult":      {&"dawn": 0.80, &"day": 1.00, &"dusk": 1.20, &"night": 1.30},
		"core_mult":     {&"dawn": 0.85, &"day": 1.00, &"dusk": 1.15, &"night": 1.10},
		"particle_mult": {&"dawn": 0.80, &"day": 1.00, &"dusk": 1.10, &"night": 1.20},
		"pulse_period_mult": {&"dawn": 1.20, &"day": 1.00, &"dusk": 0.90, &"night": 0.80},
	},
	&"memory_vaults": {
		# vaults swell at dawn (Quill's most awake hour) and dim at night
		"key_mult":      {&"dawn": 1.20, &"day": 1.00, &"dusk": 0.95, &"night": 0.55},
		"rim_mult":      {&"dawn": 1.30, &"day": 1.00, &"dusk": 1.00, &"night": 0.60},
		"core_mult":     {&"dawn": 1.15, &"day": 1.00, &"dusk": 0.95, &"night": 0.70},
		"particle_mult": {&"dawn": 1.30, &"day": 1.00, &"dusk": 0.85, &"night": 0.50},
		"pulse_period_mult": {&"dawn": 0.85, &"day": 1.00, &"dusk": 1.10, &"night": 1.30},
	},
	&"corrupted_wilds": {
		# the Wilds is nocturnal — dim at dawn, max at night
		"key_mult":      {&"dawn": 0.60, &"day": 0.85, &"dusk": 1.15, &"night": 1.40},
		"rim_mult":      {&"dawn": 0.70, &"day": 0.90, &"dusk": 1.25, &"night": 1.50},
		"core_mult":     {&"dawn": 0.65, &"day": 0.85, &"dusk": 1.20, &"night": 1.45},
		"particle_mult": {&"dawn": 0.55, &"day": 0.85, &"dusk": 1.30, &"night": 1.60},
		"pulse_period_mult": {&"dawn": 1.30, &"day": 1.10, &"dusk": 0.85, &"night": 0.70},
	},
	&"final_vault": {
		# the Final Vault is faintest at dawn (the Quiet One's hour),
		# loudest at night when the seals can be heard
		"key_mult":      {&"dawn": 0.50, &"day": 0.90, &"dusk": 1.10, &"night": 1.30},
		"rim_mult":      {&"dawn": 0.60, &"day": 0.95, &"dusk": 1.15, &"night": 1.35},
		"core_mult":     {&"dawn": 0.55, &"day": 0.90, &"dusk": 1.10, &"night": 1.40},
		"particle_mult": {&"dawn": 0.50, &"day": 0.85, &"dusk": 1.15, &"night": 1.45},
		"pulse_period_mult": {&"dawn": 1.30, &"day": 1.00, &"dusk": 0.95, &"night": 0.85},
	},
}

const TWEEN_DURATION: float = 4.0

@export var entrance_id: StringName = &""
@export var lighting_path: NodePath
@export var ambience_path: NodePath

var _lighting: Node3D
var _ambience: Node3D
var _profile: Dictionary = {}
var _key_base: float = 0.0
var _rim_base: float = 0.0
var _core_base: float = 0.0
var _particle_amount_base: int = 0
var _core_period_base: float = 0.0


func _ready() -> void:
	_profile = PROFILES.get(entrance_id, {})
	if _profile.is_empty():
		push_warning("DungeonEntrancePhaseTuner: unknown entrance_id '%s'" % entrance_id)
		return
	_lighting = get_node_or_null(lighting_path) as Node3D
	_ambience = get_node_or_null(ambience_path) as Node3D
	_capture_baselines()
	if has_node("/root/DayNightController"):
		var dnc: Node = get_node("/root/DayNightController")
		if dnc.has_signal("phase_changed"):
			dnc.phase_changed.connect(_on_phase_changed)
	# Apply current phase immediately
	_apply_phase(_current_phase(), false)


# === BASELINES ===

func _capture_baselines() -> void:
	if _lighting == null:
		return
	var key: SpotLight3D = _lighting.get_node_or_null("KeyLight") as SpotLight3D
	var rim: SpotLight3D = _lighting.get_node_or_null("RimLight") as SpotLight3D
	var core: OmniLight3D = _lighting.get_node_or_null("PortalCore") as OmniLight3D
	if key != null:
		_key_base = key.light_energy
	if rim != null:
		_rim_base = rim.light_energy
	if core != null:
		_core_base = core.light_energy
	if _ambience != null:
		var particles: GPUParticles3D = _ambience.get_node_or_null("EntranceParticles") as GPUParticles3D
		if particles != null:
			_particle_amount_base = particles.amount


# === APPLY ===

func _apply_phase(phase: StringName, animate: bool) -> void:
	if _profile.is_empty():
		return

	var key_mult: float    = float(_profile.get("key_mult", {}).get(phase, 1.0))
	var rim_mult: float    = float(_profile.get("rim_mult", {}).get(phase, 1.0))
	var core_mult: float   = float(_profile.get("core_mult", {}).get(phase, 1.0))
	var part_mult: float   = float(_profile.get("particle_mult", {}).get(phase, 1.0))

	if _lighting != null:
		var key: SpotLight3D = _lighting.get_node_or_null("KeyLight") as SpotLight3D
		var rim: SpotLight3D = _lighting.get_node_or_null("RimLight") as SpotLight3D
		var core: OmniLight3D = _lighting.get_node_or_null("PortalCore") as OmniLight3D
		if animate:
			if key != null: _tween_property(key, &"light_energy", _key_base * key_mult)
			if rim != null: _tween_property(rim, &"light_energy", _rim_base * rim_mult)
			if core != null: _tween_property(core, &"light_energy", _core_base * core_mult)
		else:
			if key != null: key.light_energy = _key_base * key_mult
			if rim != null: rim.light_energy = _rim_base * rim_mult
			if core != null: core.light_energy = _core_base * core_mult

	if _ambience != null:
		var particles: GPUParticles3D = _ambience.get_node_or_null("EntranceParticles") as GPUParticles3D
		if particles != null:
			particles.amount = int(_particle_amount_base * part_mult)


func _tween_property(target: Object, property: StringName, value: Variant) -> void:
	var tw: Tween = create_tween()
	tw.tween_property(target, property, value, TWEEN_DURATION)


# === EVENTS ===

func _on_phase_changed(phase: StringName) -> void:
	_apply_phase(phase, true)


# === HELPERS ===

func _current_phase() -> StringName:
	if not has_node("/root/DayNightController"):
		return &"day"
	var dnc: Node = get_node("/root/DayNightController")
	if "current_phase" in dnc:
		return StringName(dnc.current_phase)
	return &"day"
