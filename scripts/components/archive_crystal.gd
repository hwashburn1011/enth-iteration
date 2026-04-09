class_name ArchiveCrystal
extends Area3D

## The floating crystal at the back of Sage's Library. Player walks
## within range, presses interact, and the ArchiveCrystalUI panel
## opens. The crystal itself just floats, hums, and gates the
## interaction. The actual content is in ArchiveCrystalDatabase and
## the external LoreManager / CutsceneController.
##
## Required scene shape:
##   ArchiveCrystal (Area3D + this script)
##     CollisionShape3D (sphere, interact range)
##     CrystalMesh (MeshInstance3D — the floating crystal model)
##     CrystalLight (OmniLight3D — pulsing pale-blue glow)
##     [optional] HumLoop (AudioStreamPlayer3D)
##
## Configure via inspector:
##   bob_amplitude — meters of vertical bob
##   bob_period_s  — bob period
##   pulse_period_s — light pulse period

signal opened
signal closed
signal interaction_blocked(reason: StringName)

@export var bob_amplitude: float = 0.15
@export var bob_period_s: float = 4.0
@export var pulse_period_s: float = 3.0

@onready var _crystal_mesh: Node3D = $CrystalMesh if has_node("CrystalMesh") else null
@onready var _crystal_light: OmniLight3D = $CrystalLight if has_node("CrystalLight") else null

var _player_in_range: bool = false
var _is_open: bool = false
var _light_base_energy: float = 0.0
var _crystal_base_y: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)
	collision_layer = 0
	collision_mask = 1 << 0
	monitorable = false
	if _crystal_light != null:
		_light_base_energy = _crystal_light.light_energy
	if _crystal_mesh != null:
		_crystal_base_y = _crystal_mesh.position.y


func _process(_delta: float) -> void:
	var t: float = Time.get_ticks_msec() / 1000.0
	# Bob
	if _crystal_mesh != null:
		_crystal_mesh.position.y = _crystal_base_y + sin(t * (TAU / bob_period_s)) * bob_amplitude
	# Pulse
	if _crystal_light != null:
		var pulse: float = sin(t * (TAU / pulse_period_s)) * 0.30
		_crystal_light.light_energy = _light_base_energy * (1.0 + pulse)


# === INTERACTION ===

func can_open() -> bool:
	return _player_in_range and not _is_open


func open() -> bool:
	if not can_open():
		interaction_blocked.emit(&"not_in_range" if not _player_in_range else &"already_open")
		return false
	_is_open = true
	opened.emit()
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("archive_crystal_opened"):
			bus.emit_signal("archive_crystal_opened")
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_archive_crystal_open")
	return true


func close() -> void:
	if not _is_open:
		return
	_is_open = false
	closed.emit()
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("archive_crystal_closed"):
			bus.emit_signal("archive_crystal_closed")


# === SECTION QUERIES (UI calls these) ===

func get_sections() -> Array[Dictionary]:
	return ArchiveCrystalDatabase.get_sections()


func get_lore_tablets_unlocked() -> Array:
	if has_node("/root/LoreManager"):
		var lm: Node = get_node("/root/LoreManager")
		if lm.has_method("get_collected"):
			return lm.get_collected()
	return []


func get_cinematics_unlocked() -> Array:
	if has_node("/root/CutsceneController"):
		var cc: Node = get_node("/root/CutsceneController")
		if cc.has_method("get_played_history"):
			return cc.get_played_history()
	return []


func get_sage_journal_unlocked() -> Array[Dictionary]:
	var iter: int = _current_iteration()
	var tier: StringName = _get_sage_affinity_tier()
	var flags: Array = _get_set_flags()
	return ArchiveCrystalDatabase.get_sage_journal_unlocked(iter, tier, flags)


func get_forgotten_index_unlocked() -> Array[Dictionary]:
	var clears: int = _get_iterations_cleared()
	return ArchiveCrystalDatabase.get_forgotten_index_unlocked(clears)


func replay_cinematic(cinematic_id: StringName) -> bool:
	if not has_node("/root/CutsceneController"):
		return false
	var cc: Node = get_node("/root/CutsceneController")
	if cc.has_method("replay_by_id"):
		return cc.replay_by_id(cinematic_id)
	return false


# === HELPERS ===

func _current_iteration() -> int:
	if not has_node("/root/IterationManager"):
		return 1
	var im: Node = get_node("/root/IterationManager")
	if im.has_method("get_current_iteration"):
		return int(im.get_current_iteration())
	return 1


func _get_iterations_cleared() -> int:
	if not has_node("/root/IterationManager"):
		return 0
	var im: Node = get_node("/root/IterationManager")
	if im.has_method("get_iterations_cleared"):
		return int(im.get_iterations_cleared())
	if "iterations_cleared" in im:
		return int(im.iterations_cleared)
	return 0


func _get_sage_affinity_tier() -> StringName:
	if not has_node("/root/AffinityManager"):
		return &"acquaintance"
	var am: Node = get_node("/root/AffinityManager")
	if am.has_method("get_tier"):
		return am.get_tier(&"sage")
	return &"acquaintance"


func _get_set_flags() -> Array:
	if has_node("/root/WildernessStoryManager"):
		var sm: Node = get_node("/root/WildernessStoryManager")
		if "story_flags" in sm:
			return (sm.story_flags as Array).duplicate()
	return []


# === EVENTS ===

func _on_player_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = true


func _on_player_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false
		if _is_open:
			close()
