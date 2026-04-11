class_name DungeonFloorSaveState
extends Node

## Dungeon Floor Save State (Epic 30 task 47).
##
## Persists per-floor state across save/load cycles. Each floor records:
##   - cleared_rooms: Array[StringName]
##   - looted_chests: Array[StringName]
##   - defeated_elites: Array[StringName]
##   - secrets_found: Array[StringName]
##   - lore_collected: Array[StringName]
##   - boss_defeated: bool (floor 5 only)
##   - first_visit_timestamp: int (in-game minute)
##   - run_count: int
##
## State is keyed by (iteration, floor_id) so each iteration's runs are
## isolated. SaveManager calls save_state()/load_state() during its standard
## checkpoint cycle.
##
## Hook:
##   var fss := DungeonFloorSaveState.new()
##   fss.iteration = 3
##   fss.floor_id = &"floor_4_boss_approach"
##   add_child(fss)
##   fss.mark_room_cleared(&"hall_03")

signal state_loaded(floor_id: StringName)
signal state_saved(floor_id: StringName)
signal floor_cleared(floor_id: StringName, total_rooms: int)
signal boss_defeated_signal(floor_id: StringName)

@export var iteration: int = 1
@export var floor_id: StringName = &""

var cleared_rooms: Array[StringName] = []
var looted_chests: Array[StringName] = []
var defeated_elites: Array[StringName] = []
var secrets_found: Array[StringName] = []
var lore_collected: Array[StringName] = []
var boss_defeated: bool = false
var first_visit_minute: int = -1
var run_count: int = 0
var total_rooms: int = 0

const STATE_KEY_PREFIX: String = "dungeon_floor_state"


func _ready() -> void:
	if floor_id == &"":
		push_warning("DungeonFloorSaveState: floor_id not set")
		return
	load_state()


# === Mutators ===
func mark_room_cleared(room_id: StringName) -> void:
	if not cleared_rooms.has(room_id):
		cleared_rooms.append(room_id)
		_check_clear_completion()


func mark_chest_looted(chest_id: StringName) -> void:
	if not looted_chests.has(chest_id):
		looted_chests.append(chest_id)


func mark_elite_defeated(elite_id: StringName) -> void:
	if not defeated_elites.has(elite_id):
		defeated_elites.append(elite_id)


func mark_secret_found(secret_id: StringName) -> void:
	if not secrets_found.has(secret_id):
		secrets_found.append(secret_id)


func mark_lore_collected(lore_id: StringName) -> void:
	if not lore_collected.has(lore_id):
		lore_collected.append(lore_id)


func mark_boss_defeated() -> void:
	if not boss_defeated:
		boss_defeated = true
		boss_defeated_signal.emit(floor_id)


func record_first_visit(in_game_minute: int) -> void:
	if first_visit_minute == -1:
		first_visit_minute = in_game_minute


func increment_run_count() -> void:
	run_count += 1


# === Save / Load ===
func save_state() -> void:
	var data: Dictionary = {
		"cleared_rooms": cleared_rooms,
		"looted_chests": looted_chests,
		"defeated_elites": defeated_elites,
		"secrets_found": secrets_found,
		"lore_collected": lore_collected,
		"boss_defeated": boss_defeated,
		"first_visit_minute": first_visit_minute,
		"run_count": run_count,
		"total_rooms": total_rooms,
	}
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("set_data"):
			sm.call("set_data", _state_key(), data)
	state_saved.emit(floor_id)


func load_state() -> void:
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("get_data"):
			var data: Dictionary = sm.call("get_data", _state_key())
			if not data.is_empty():
				cleared_rooms = data.get("cleared_rooms", [])
				looted_chests = data.get("looted_chests", [])
				defeated_elites = data.get("defeated_elites", [])
				secrets_found = data.get("secrets_found", [])
				lore_collected = data.get("lore_collected", [])
				boss_defeated = data.get("boss_defeated", false)
				first_visit_minute = data.get("first_visit_minute", -1)
				run_count = data.get("run_count", 0)
				total_rooms = data.get("total_rooms", 0)
	state_loaded.emit(floor_id)


func _state_key() -> String:
	return "%s_iter%d_%s" % [STATE_KEY_PREFIX, iteration, floor_id]


func _check_clear_completion() -> void:
	if total_rooms > 0 and cleared_rooms.size() >= total_rooms:
		floor_cleared.emit(floor_id, total_rooms)


# === Queries ===
func is_room_cleared(room_id: StringName) -> bool:
	return cleared_rooms.has(room_id)


func get_completion_percentage() -> float:
	if total_rooms <= 0:
		return 0.0
	return float(cleared_rooms.size()) / float(total_rooms)


func get_summary() -> Dictionary:
	return {
		"floor_id": floor_id,
		"iteration": iteration,
		"rooms_cleared": cleared_rooms.size(),
		"total_rooms": total_rooms,
		"chests_looted": looted_chests.size(),
		"elites_defeated": defeated_elites.size(),
		"secrets_found": secrets_found.size(),
		"lore_collected": lore_collected.size(),
		"boss_defeated": boss_defeated,
		"completion_pct": get_completion_percentage(),
		"run_count": run_count,
	}
