class_name DungeonEntranceLighting
extends Node3D

## Per-entrance dedicated lighting rig. Spawns three lights at scene
## attach time to give each portal a hero-shot quality look:
##
##   1. KEY LIGHT — a cool/warm SpotLight3D pointed at the portal face
##      from a 30° elevation, color-themed to the biome
##   2. RIM LIGHT — a low-angle backlight from the cliff side that
##      separates the monument silhouette from the cliff wall
##   3. PORTAL CORE — a small, intense OmniLight3D at the portal mouth
##      itself that pulses with the biome accent
##
## Per-entrance built-in profiles. The rig honors the entrance's
## locked_visible / unlock_iteration so sealed entrances dim to 25%
## intensity until the unlock fires.
##
## Required scene shape:
##   DungeonEntranceLighting (Node3D + this script)
##     [no children needed; lights are added at runtime]
##
## Configure via inspector:
##   entrance_id    — must match a profile key
##   monument_height — used to size key/rim positions

const PROFILES: Dictionary = {
	&"server_room": {
		"key_color":    Color(0.55, 0.78, 1.00),
		"key_energy":   3.5,
		"key_angle_deg": 28.0,
		"rim_color":    Color(0.30, 0.55, 0.95),
		"rim_energy":   2.0,
		"core_color":   Color(0.65, 0.85, 1.00),
		"core_energy":  4.5,
		"core_pulse_period_s": 2.4,
		"core_pulse_amplitude": 0.35,
	},
	&"memory_vaults": {
		"key_color":    Color(1.00, 0.92, 0.70),
		"key_energy":   3.2,
		"key_angle_deg": 25.0,
		"rim_color":    Color(0.95, 0.78, 0.40),
		"rim_energy":   2.2,
		"core_color":   Color(1.00, 0.85, 0.45),
		"core_energy":  4.2,
		"core_pulse_period_s": 5.0,  # slow, contemplative
		"core_pulse_amplitude": 0.20,
	},
	&"corrupted_wilds": {
		"key_color":    Color(0.65, 0.95, 0.60),
		"key_energy":   3.0,
		"key_angle_deg": 30.0,
		"rim_color":    Color(0.85, 0.30, 1.00),
		"rim_energy":   2.4,
		"core_color":   Color(0.55, 1.00, 0.55),
		"core_energy":  4.5,
		"core_pulse_period_s": 1.6,  # fast, organic breathing
		"core_pulse_amplitude": 0.45,
	},
	&"final_vault": {
		"key_color":    Color(0.92, 0.92, 1.00),
		"key_energy":   3.8,
		"key_angle_deg": 22.0,
		"rim_color":    Color(0.70, 0.75, 1.00),
		"rim_energy":   2.6,
		"core_color":   Color(0.95, 0.90, 1.00),
		"core_energy":  5.5,
		"core_pulse_period_s": 8.0,  # near-eternal pulse
		"core_pulse_amplitude": 0.15,
	},
}

const SEALED_DIM_MULT: float = 0.25

@export var entrance_id: StringName = &""
@export var monument_height: float = 6.0

var _key_light: SpotLight3D
var _rim_light: SpotLight3D
var _core_light: OmniLight3D
var _is_sealed: bool = false
var _core_base_energy: float = 0.0
var _profile: Dictionary = {}


func _ready() -> void:
	_resolve_lock_state()
	_profile = PROFILES.get(entrance_id, {})
	if _profile.is_empty():
		push_warning("DungeonEntranceLighting: unknown entrance_id '%s'" % entrance_id)
		return
	_build_rig()
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("dungeon_entrance_unlocked"):
			bus.dungeon_entrance_unlocked.connect(_on_entrance_unlocked)


func _process(delta: float) -> void:
	if _core_light == null or _profile.is_empty():
		return
	_pulse_core()


# === BUILD ===

func _build_rig() -> void:
	var dim_mult: float = SEALED_DIM_MULT if _is_sealed else 1.0

	# Key light
	_key_light = SpotLight3D.new()
	_key_light.name = "KeyLight"
	_key_light.light_color = _profile.get("key_color", Color.WHITE)
	_key_light.light_energy = float(_profile.get("key_energy", 3.0)) * dim_mult
	_key_light.spot_range = 25.0
	_key_light.spot_angle = 35.0
	_key_light.spot_attenuation = 1.5
	_key_light.shadow_enabled = true
	add_child(_key_light)
	# Position: forward + up from the portal, looking at portal face
	var key_offset: Vector3 = Vector3(0, monument_height * 0.7, 6.0)
	_key_light.position = key_offset
	_key_light.look_at(global_position, Vector3.UP)

	# Rim light
	_rim_light = SpotLight3D.new()
	_rim_light.name = "RimLight"
	_rim_light.light_color = _profile.get("rim_color", Color.WHITE)
	_rim_light.light_energy = float(_profile.get("rim_energy", 2.0)) * dim_mult
	_rim_light.spot_range = 18.0
	_rim_light.spot_angle = 30.0
	_rim_light.spot_attenuation = 1.8
	_rim_light.shadow_enabled = false
	add_child(_rim_light)
	# Position: behind the monument, low angle
	var rim_offset: Vector3 = Vector3(0, monument_height * 0.4, -7.0)
	_rim_light.position = rim_offset
	_rim_light.look_at(global_position + Vector3(0, monument_height * 0.5, 0), Vector3.UP)

	# Portal core
	_core_light = OmniLight3D.new()
	_core_light.name = "PortalCore"
	_core_light.light_color = _profile.get("core_color", Color.WHITE)
	_core_base_energy = float(_profile.get("core_energy", 4.0)) * dim_mult
	_core_light.light_energy = _core_base_energy
	_core_light.omni_range = 8.0
	_core_light.shadow_enabled = false
	add_child(_core_light)
	_core_light.position = Vector3(0, monument_height * 0.5, 0)


# === PULSE ===

func _pulse_core() -> void:
	var period: float = float(_profile.get("core_pulse_period_s", 3.0))
	var amplitude: float = float(_profile.get("core_pulse_amplitude", 0.3))
	if period <= 0.0:
		return
	var t: float = Time.get_ticks_msec() / 1000.0
	var pulse: float = sin(t * (TAU / period)) * amplitude
	_core_light.light_energy = _core_base_energy * (1.0 + pulse)


# === LOCK STATE ===

func _resolve_lock_state() -> void:
	var entry: Dictionary = DungeonEntranceDatabase.get_entrance(entrance_id)
	if entry.is_empty():
		return
	var locked_visible: bool = bool(entry.get("locked_visible", false))
	var unlock_iter: int = int(entry.get("unlock_iteration", 0))
	var current_iter: int = _current_iteration()
	_is_sealed = locked_visible and current_iter < unlock_iter


func _on_entrance_unlocked(unlocked_id: StringName) -> void:
	if unlocked_id != entrance_id:
		return
	_is_sealed = false
	# Tween the rig back to full intensity
	if _key_light != null:
		create_tween().tween_property(_key_light, "light_energy", float(_profile.get("key_energy", 3.0)), 2.0)
	if _rim_light != null:
		create_tween().tween_property(_rim_light, "light_energy", float(_profile.get("rim_energy", 2.0)), 2.0)
	_core_base_energy = float(_profile.get("core_energy", 4.0))


# === HELPERS ===

func _current_iteration() -> int:
	if not has_node("/root/IterationManager"):
		return 1
	var im: Node = get_node("/root/IterationManager")
	if im.has_method("get_current_iteration"):
		return int(im.get_current_iteration())
	return 1
