class_name DungeonEntranceReflectionProbe
extends Node3D

## Wraps a Godot ReflectionProbe sized and positioned for a dungeon
## entrance. The probe captures the surrounding cliff face + portal
## glow + banners + lighting rig so any reflective material at the
## entrance (banner cloth gloss, wet decals, polished metal monuments)
## reflects the *correct* environment for the portal it's standing at.
##
## Behavior:
##   - Probe captures once on _ready and re-captures on weather + phase
##     changes (the lighting + particles vary, so the captured cubemap
##     would otherwise drift out of date)
##   - Box-shaped capture volume sized for the cliff approach pocket
##   - intensity per-entrance to bias the biome accent into reflections
##
## Required scene shape:
##   DungeonEntranceReflectionProbe (Node3D + this script)
##     [no children needed; ReflectionProbe added at runtime]
##
## Configure via inspector:
##   entrance_id  — drives box size + intensity profile
##   probe_extents — override the default per-entrance box extents

const PROFILES: Dictionary = {
	&"server_room": {
		"extents":   Vector3(14, 8, 14),
		"intensity": 1.10,
		"max_distance": 80.0,
		"ambient_color": Color(0.55, 0.78, 1.00),
		"ambient_energy": 0.40,
	},
	&"memory_vaults": {
		"extents":   Vector3(14, 8, 14),
		"intensity": 1.20,
		"max_distance": 80.0,
		"ambient_color": Color(1.00, 0.88, 0.55),
		"ambient_energy": 0.50,
	},
	&"corrupted_wilds": {
		"extents":   Vector3(15, 9, 15),
		"intensity": 1.30,  # Wilds are most reflective — wet organic surfaces
		"max_distance": 80.0,
		"ambient_color": Color(0.55, 1.00, 0.60),
		"ambient_energy": 0.55,
	},
	&"final_vault": {
		"extents":   Vector3(14, 9, 14),
		"intensity": 1.45,  # the vault's metal seals throw the brightest reflections
		"max_distance": 90.0,
		"ambient_color": Color(0.92, 0.90, 1.00),
		"ambient_energy": 0.60,
	},
}

@export var entrance_id: StringName = &""
@export var probe_extents_override: Vector3 = Vector3.ZERO  # ZERO = use profile default

var _probe: ReflectionProbe
var _profile: Dictionary = {}


func _ready() -> void:
	_profile = PROFILES.get(entrance_id, {})
	if _profile.is_empty():
		push_warning("DungeonEntranceReflectionProbe: unknown entrance_id '%s'" % entrance_id)
		return
	_build_probe()
	if has_node("/root/WeatherController"):
		var wc: Node = get_node("/root/WeatherController")
		if wc.has_signal("weather_changed"):
			wc.weather_changed.connect(_on_world_changed)
	if has_node("/root/DayNightController"):
		var dnc: Node = get_node("/root/DayNightController")
		if dnc.has_signal("phase_changed"):
			dnc.phase_changed.connect(_on_world_changed)
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("dungeon_entrance_unlocked"):
			bus.dungeon_entrance_unlocked.connect(_on_entrance_unlocked)


# === BUILD ===

func _build_probe() -> void:
	_probe = ReflectionProbe.new()
	_probe.name = "EntranceReflectionProbe"

	var extents: Vector3 = probe_extents_override if probe_extents_override != Vector3.ZERO else _profile.get("extents", Vector3(12, 8, 12))
	_probe.size = extents * 2.0  # Godot ReflectionProbe.size is full extent, not half
	_probe.intensity = float(_profile.get("intensity", 1.0))
	_probe.max_distance = float(_profile.get("max_distance", 80.0))
	_probe.ambient_mode = ReflectionProbe.AMBIENT_COLOR
	_probe.ambient_color = _profile.get("ambient_color", Color.WHITE)
	_probe.ambient_color_energy = float(_profile.get("ambient_energy", 0.5))
	_probe.update_mode = ReflectionProbe.UPDATE_ONCE
	_probe.cull_mask = 0xFFFFFFFF
	_probe.interior = false
	_probe.box_projection = true

	add_child(_probe)
	_probe.position = Vector3.ZERO

	# Defer the first capture so spawned siblings (lighting rig, banners,
	# particle bed) are present in the scene when the probe samples them.
	call_deferred("_request_recapture")


# === RECAPTURE ===

func _request_recapture() -> void:
	if _probe == null:
		return
	# In Godot 4.x, switching update_mode forces a re-capture pass
	_probe.update_mode = ReflectionProbe.UPDATE_ALWAYS
	# Drop back to ONCE next frame so we don't re-bake every frame after
	get_tree().create_timer(0.1).timeout.connect(func() -> void:
		if is_instance_valid(_probe):
			_probe.update_mode = ReflectionProbe.UPDATE_ONCE
	)


func _on_world_changed(_arg = null) -> void:
	_request_recapture()


func _on_entrance_unlocked(unlocked_id: StringName) -> void:
	if unlocked_id != entrance_id:
		return
	# The unlock changes lighting + particles, so re-bake
	_request_recapture()


# === QUERY ===

func get_probe() -> ReflectionProbe:
	return _probe
