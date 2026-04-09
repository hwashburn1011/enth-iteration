class_name BossRush
extends Node

## Boss rush mode controller. Plays all 6 bosses (Corrupted Compiler + 5 new)
## back-to-back with no breaks. Tracks time, leaderboard, restart on death.

signal boss_rush_started
signal boss_rush_completed(total_time_seconds: int)
signal boss_rush_failed
signal next_boss_loaded(boss_id: StringName)

const BOSS_ORDER: PackedStringArray = [
	"corrupted_compiler",
	"memory_warden",
	"root_heart",
	"sentinel_prime",
	"iteration_phantom",
	"compiler_reborn",
]

var current_boss_index: int = -1
var rush_active: bool = false
var rush_start_time: int = -1
var deaths: int = 0


func can_start(boss_component: BossComponent) -> bool:
	return boss_component != null and boss_component.is_boss_rush_unlocked()


func start(boss_component: BossComponent) -> bool:
	if not can_start(boss_component):
		return false
	rush_active = true
	current_boss_index = 0
	rush_start_time = Time.get_unix_time_from_system()
	deaths = 0
	boss_rush_started.emit()
	_load_next_boss(boss_component)
	return true


func _load_next_boss(boss_component: BossComponent) -> void:
	if current_boss_index >= BOSS_ORDER.size():
		_complete(boss_component)
		return
	var boss_id: StringName = StringName(BOSS_ORDER[current_boss_index])
	boss_component.start_fight(boss_id)
	next_boss_loaded.emit(boss_id)


func on_boss_defeated(boss_component: BossComponent) -> void:
	if not rush_active:
		return
	current_boss_index += 1
	if current_boss_index >= BOSS_ORDER.size():
		_complete(boss_component)
	else:
		_load_next_boss(boss_component)


func on_player_died() -> void:
	if not rush_active:
		return
	deaths += 1
	rush_active = false
	current_boss_index = -1
	boss_rush_failed.emit()


func _complete(boss_component: BossComponent) -> void:
	var total_time: int = Time.get_unix_time_from_system() - rush_start_time
	rush_active = false
	boss_component.record_boss_rush_completion(total_time)
	boss_rush_completed.emit(total_time)


func get_progress() -> float:
	if not rush_active:
		return 0.0
	return float(current_boss_index) / float(BOSS_ORDER.size())


func get_current_boss_id() -> StringName:
	if current_boss_index < 0 or current_boss_index >= BOSS_ORDER.size():
		return &""
	return StringName(BOSS_ORDER[current_boss_index])
