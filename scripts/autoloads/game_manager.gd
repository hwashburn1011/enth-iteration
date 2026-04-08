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

# Demo stats
var play_time_seconds: float = 0.0
var total_enemies_defeated: int = 0
var total_deaths: int = 0
var total_items_found: int = 0

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
	EventBus.enemy_defeated.connect(_on_enemy_defeated_stat)
	EventBus.player_died.connect(_on_player_died_stat)
	EventBus.item_collected.connect(_on_item_collected_stat)


func _process(delta: float) -> void:
	if current_state == GameState.PLAYING:
		play_time_seconds += delta


func _on_enemy_defeated_stat(_type: StringName, _pos: Vector3, _loot: Resource) -> void:
	total_enemies_defeated += 1


func _on_player_died_stat(_pos: Vector3) -> void:
	total_deaths += 1


func _on_item_collected_stat(_item: Resource) -> void:
	total_items_found += 1


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


var _transition_overlay: CanvasLayer = null


func change_scene_to(path: String) -> void:
	EventBus.scene_changing.emit()

	# Fade to black
	await _fade_transition(true)

	var err: Error = ResourceLoader.load_threaded_request(path)
	if err != OK:
		push_error("GameManager: failed to request scene load for '%s' (error %d)" % [path, err])
		set_state(GameState.PLAYING)
		await _fade_transition(false)
		return
	var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(path)
	while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
		status = ResourceLoader.load_threaded_get_status(path)
	if status != ResourceLoader.THREAD_LOAD_LOADED:
		push_error("GameManager: scene load failed for '%s' (status %d)" % [path, status])
		set_state(GameState.PLAYING)
		await _fade_transition(false)
		return
	var scene: PackedScene = ResourceLoader.load_threaded_get(path)
	get_tree().change_scene_to_packed(scene)
	await get_tree().process_frame
	EventBus.scene_changed.emit(path)

	# Fade from black
	await _fade_transition(false)


func _fade_transition(to_black: bool) -> void:
	if _transition_overlay == null:
		_transition_overlay = CanvasLayer.new()
		_transition_overlay.layer = 110
		_transition_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
		var rect: ColorRect = ColorRect.new()
		rect.name = "FadeRect"
		rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		rect.color = Color(0.03, 0.03, 0.08, 0.0)
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_transition_overlay.add_child(rect)
		add_child(_transition_overlay)

	var rect: ColorRect = _transition_overlay.get_node("FadeRect") as ColorRect
	var target_alpha: float = 1.0 if to_black else 0.0
	var tween: Tween = create_tween()
	tween.tween_property(rect, "color:a", target_alpha, 0.4).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	await tween.finished


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
