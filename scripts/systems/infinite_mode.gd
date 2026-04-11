class_name InfiniteMode
extends Node

## Procedurally generated endless dungeon. Each room is randomly generated
## with escalating difficulty. Tracks rooms cleared, kills, currency earned.

signal room_started(room_number: int, room_data: Dictionary)
signal room_cleared(room_number: int)
signal infinite_run_failed(rooms_cleared: int)
signal shop_opened(rooms_cleared: int)

const SHOP_INTERVAL: int = 5  ## shop every N rooms

var current_room: int = 0
var run_active: bool = false
var run_seed: int = 0
var infinity_crystals: int = 0
var run_kills: int = 0
var run_streak: int = 0  ## consecutive room clears

# Persistent stats
var best_run_rooms: int = 0
var best_run_streak: int = 0
var total_runs: int = 0
var total_kills: int = 0
var total_crystals_earned: int = 0


func is_unlocked(quest_component: Node) -> bool:
	if quest_component == null:
		return false
	return quest_component.completed_quests.has(StringName("main_15_compaction3"))


func start_run() -> void:
	current_room = 0
	run_active = true
	run_seed = Time.get_unix_time_from_system()
	run_kills = 0
	run_streak = 0
	total_runs += 1
	_advance_to_next_room()


func _advance_to_next_room() -> void:
	current_room += 1
	# Check shop interval
	if current_room > 1 and (current_room - 1) % SHOP_INTERVAL == 0:
		shop_opened.emit(current_room - 1)
	var room_data: Dictionary = _generate_room(current_room, run_seed)
	room_started.emit(current_room, room_data)


func _generate_room(room_number: int, seed: int) -> Dictionary:
	## Procedurally generates a room. Difficulty scales +5% HP/damage per room.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed * 1000 + room_number

	var difficulty_mult: float = 1.0 + (room_number - 1) * 0.05
	var enemy_count: int = 3 + int(room_number / 10.0)
	var enemy_pool: PackedStringArray = ["glitchbug", "memoryleak", "rogueprocess"]
	if room_number > 20:
		enemy_pool.append("crash_daemon")
	if room_number > 50:
		enemy_pool.append("null_pointer")
	if room_number > 100:
		enemy_pool.append("iteration_echo")

	var enemies: Array = []
	for i in enemy_count:
		enemies.append(enemy_pool[rng.randi() % enemy_pool.size()])

	return {
		"room_number": room_number,
		"difficulty_mult": difficulty_mult,
		"enemy_count": enemy_count,
		"enemies": enemies,
		"reward_crystals": 5 + int(room_number / 5.0),
	}


func clear_current_room() -> void:
	if not run_active:
		return
	room_cleared.emit(current_room)
	run_streak += 1
	if run_streak > best_run_streak:
		best_run_streak = run_streak
	# Award crystals
	var room_data: Dictionary = _generate_room(current_room, run_seed)
	var crystals: int = room_data.get("reward_crystals", 5)
	infinity_crystals += crystals
	total_crystals_earned += crystals
	_advance_to_next_room()


func record_kill() -> void:
	run_kills += 1
	total_kills += 1


func fail_run() -> void:
	if not run_active:
		return
	run_active = false
	if current_room - 1 > best_run_rooms:
		best_run_rooms = current_room - 1
	infinite_run_failed.emit(current_room - 1)


func spend_crystals(amount: int) -> bool:
	if infinity_crystals < amount:
		return false
	infinity_crystals -= amount
	return true


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"infinity_crystals": infinity_crystals,
		"best_run_rooms": best_run_rooms,
		"best_run_streak": best_run_streak,
		"total_runs": total_runs,
		"total_kills": total_kills,
		"total_crystals_earned": total_crystals_earned,
	}


func from_save_data(data: Dictionary) -> void:
	infinity_crystals = data.get("infinity_crystals", 0)
	best_run_rooms = data.get("best_run_rooms", 0)
	best_run_streak = data.get("best_run_streak", 0)
	total_runs = data.get("total_runs", 0)
	total_kills = data.get("total_kills", 0)
	total_crystals_earned = data.get("total_crystals_earned", 0)
