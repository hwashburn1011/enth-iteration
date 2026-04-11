class_name TrainingLeaderboard
extends Node3D

## Wall plaque next to the training arena reset lever. Tracks the
## player's all-time best DPS scores per dummy archetype across save
## file lifetime, plus the current run's tracked totals. Listens to
## TrainingDummy.dps_window_closed signals from every TrainingDummy
## in the same scene.
##
## Required scene shape:
##   TrainingLeaderboard (Node3D + this script)
##     PlaqueMesh (MeshInstance3D)
##     [optional] PlaqueLabel (Label3D — text rendering of the records)
##
## Configure via inspector:
##   dummy_root_path — NodePath to the parent of TrainingDummies
##                     (used at _ready to subscribe to all of them)

signal record_set(dummy_id: StringName, total: float, dps: float)
signal record_displayed(dummy_id: StringName, total: float, dps: float)

@export var dummy_root_path: NodePath

@onready var _label: Label3D = $PlaqueLabel if has_node("PlaqueLabel") else null

# Best record per dummy id: { dummy_id → { total, dps, date_iso } }
var _records: Dictionary = {}
var _current_run: Dictionary = {}  # dummy_id → { total, dps }


func _ready() -> void:
	_subscribe_to_dummies()
	_refresh_label()


func _subscribe_to_dummies() -> void:
	var root: Node = get_node_or_null(dummy_root_path)
	if root == null:
		root = get_tree().current_scene
	if root == null:
		return
	var dummies: Array[Node] = []
	_collect(root, dummies)
	for d in dummies:
		if d is TrainingDummy:
			(d as TrainingDummy).dps_window_closed.connect(_on_dummy_window_closed.bind(d.dummy_id))


func _collect(node: Node, out: Array[Node]) -> void:
	if node is TrainingDummy:
		out.append(node)
	for child in node.get_children():
		_collect(child, out)


# === RECORDING ===

func _on_dummy_window_closed(total: float, dps: float, dummy_id: StringName) -> void:
	# Track the current run regardless of record
	_current_run[dummy_id] = {"total": total, "dps": dps}

	# Compare against the all-time best
	var prev: Dictionary = _records.get(dummy_id, {})
	var prev_dps: float = float(prev.get("dps", 0.0))
	if dps > prev_dps:
		_records[dummy_id] = {
			"total": total,
			"dps": dps,
			"recorded_at": Time.get_unix_time_from_system(),
		}
		record_set.emit(dummy_id, total, dps)
		_play_record_celebration()
	_refresh_label()


func _play_record_celebration() -> void:
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_personal_best")
	if has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(&"sting_personal_best")


# === SNAPSHOT (called by reset lever) ===

func snapshot_current_run(_total: float, _dps: float, _sustain_dummy: Variant) -> void:
	# The reset lever calls this just before clearing all dummies.
	# We've already been collecting dps_window_closed signals throughout
	# the run, so this is a no-op except to clear the current_run cache
	# now that the run has officially ended.
	_current_run.clear()


# === DISPLAY ===

func _refresh_label() -> void:
	if _label == null:
		return
	var lines: Array[String] = ["— PERSONAL BESTS —", ""]
	for dummy_id in [
		&"dummy_humanoid_stationary",
		&"dummy_humanoid_patrol",
		&"dummy_tank_large",
		&"dummy_floating_sphere",
		&"dummy_cluster",
		&"dummy_boss_stagger",
	]:
		var entry: Dictionary = TrainingDummyDatabase.get_dummy(dummy_id)
		var name: String = entry.get("display_name", String(dummy_id))
		var record: Dictionary = _records.get(dummy_id, {})
		var dps: float = float(record.get("dps", 0.0))
		if dps > 0.0:
			lines.append("%s — %.0f DPS" % [name, dps])
		else:
			lines.append("%s — —" % name)
	_label.text = "\n".join(lines)


# === QUERY ===

func get_record(dummy_id: StringName) -> Dictionary:
	return _records.get(dummy_id, {})


func get_all_records() -> Dictionary:
	return _records.duplicate(true)


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	var serialized: Dictionary = {}
	for k in _records.keys():
		serialized[String(k)] = _records[k]
	return {"records": serialized}


func from_save_data(data: Dictionary) -> void:
	_records.clear()
	var loaded: Dictionary = data.get("records", {})
	for k in loaded.keys():
		_records[StringName(k)] = loaded[k]
	_refresh_label()
