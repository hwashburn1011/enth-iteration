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


func _ready() -> void:
	EventBus.npc_recruited.connect(_on_npc_recruited)


func _on_npc_recruited(npc_id: StringName) -> void:
	set_meta(StringName("npc_recruited_" + String(npc_id)), true)


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
