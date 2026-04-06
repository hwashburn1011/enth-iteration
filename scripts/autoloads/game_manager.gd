class_name GameManagerClass
extends Node
## Manages global game state, scene transitions, and pause handling.

enum GameState {
	MAIN_MENU,
	PLAYING,
	PAUSED,
	DIALOGUE,
	INVENTORY,
}

var current_state: GameState = GameState.MAIN_MENU
var recruited_npcs: Array[String] = []
var newly_recruited: Array[String] = []
var npc_affinity: Dictionary = {}  # npc_id -> int
var _talked_this_session: Dictionary = {}  # npc_id -> bool (per-session first-talk tracking)
var first_run: bool = true

# Narrative checkpoints
var first_sage_dialogue_complete: bool = false
var first_dungeon_entered: bool = false
var cache_sprite_recruited: bool = false
var boss_defeated: bool = false
var returned_from_first_run: bool = false
var demo_ended: bool = false

const AFFINITY_STRANGER: int = 0
const AFFINITY_ACQUAINTANCE: int = 10
const AFFINITY_ALLY: int = 25
const AFFINITY_TRUSTED: int = 50


func _ready() -> void:
	EventBus.npc_recruited.connect(_on_npc_recruited)
	EventBus.npc_talked.connect(_on_npc_talked)
	EventBus.dungeon_entered.connect(_on_dungeon_entered)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.returned_to_town.connect(_on_returned_to_town)
	EventBus.dialogue_ended.connect(_on_dialogue_ended_narrative)


func _on_npc_recruited(npc_id: StringName) -> void:
	var id: String = String(npc_id)
	if id not in recruited_npcs:
		recruited_npcs.append(id)
		newly_recruited.append(id)
		increase_affinity(id, 10)


func _on_npc_talked(npc_id: StringName) -> void:
	var id: String = String(npc_id)
	if not _talked_this_session.has(id):
		_talked_this_session[id] = true
		increase_affinity(id, 5)


func increase_affinity(npc_id: String, amount: int) -> void:
	var current: int = npc_affinity.get(npc_id, 0) as int
	npc_affinity[npc_id] = current + amount
	EventBus.affinity_changed.emit(StringName(npc_id), npc_affinity[npc_id] as int)


func get_affinity(npc_id: String) -> int:
	return npc_affinity.get(npc_id, 0) as int


func get_affinity_tier(npc_id: String) -> String:
	var value: int = get_affinity(npc_id)
	if value >= AFFINITY_TRUSTED:
		return "Trusted"
	elif value >= AFFINITY_ALLY:
		return "Ally"
	elif value >= AFFINITY_ACQUAINTANCE:
		return "Acquaintance"
	return "Stranger"


func is_npc_recruited(npc_id: String) -> bool:
	return npc_id in recruited_npcs


func is_npc_newly_arrived(npc_id: String) -> bool:
	return npc_id in newly_recruited


func acknowledge_npc_arrival(npc_id: String) -> void:
	newly_recruited.erase(npc_id)


func pause_game() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true
		EventBus.game_paused.emit()


func unpause_game() -> void:
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false
		EventBus.game_unpaused.emit()


func set_state(new_state: GameState) -> void:
	var old_state: GameState = current_state
	current_state = new_state
	EventBus.game_state_changed.emit(old_state, new_state)


func change_scene_to(path: String) -> void:
	EventBus.scene_changing.emit()
	ResourceLoader.load_threaded_request(path)
	while ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_LOADED:
		await get_tree().process_frame
	var scene: PackedScene = ResourceLoader.load_threaded_get(path)
	get_tree().change_scene_to_packed(scene)
	EventBus.scene_changed.emit(path)


# --- Narrative checkpoint handlers ---

func _on_dungeon_entered() -> void:
	first_dungeon_entered = true


func _on_boss_defeated(boss_id: StringName) -> void:
	if boss_id == &"corrupted_compiler":
		boss_defeated = true


func _on_returned_to_town() -> void:
	if boss_defeated and not returned_from_first_run:
		returned_from_first_run = true


func _on_dialogue_ended_narrative() -> void:
	# Check if AI Sage intro was just completed
	if not first_sage_dialogue_complete and is_npc_recruited("ai_sage") == false:
		# Sage is always present, so check if we talked to sage
		if _talked_this_session.has("ai_sage"):
			first_sage_dialogue_complete = true


func should_trigger_demo_end() -> bool:
	return returned_from_first_run and not demo_ended


func trigger_demo_end() -> void:
	demo_ended = true
	change_scene_to("res://scenes/main/DemoEndScreen.tscn")
