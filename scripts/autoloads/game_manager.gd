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

const AFFINITY_STRANGER: int = 0
const AFFINITY_ACQUAINTANCE: int = 10
const AFFINITY_ALLY: int = 25
const AFFINITY_TRUSTED: int = 50


func _ready() -> void:
	EventBus.npc_recruited.connect(_on_npc_recruited)
	EventBus.npc_talked.connect(_on_npc_talked)


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
