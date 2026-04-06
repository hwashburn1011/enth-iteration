class_name TutorialManagerClass
extends Node
## Tracks completed tutorials and shows contextual hints during Floor 1.

var completed_tutorials: Array[String] = []
var _active_hint: Control = null
var _canvas: CanvasLayer = null
var _movement_distance: float = 0.0
var _last_player_pos: Vector3 = Vector3.ZERO
var _tracking_movement: bool = false
var _all_complete_shown: bool = false


func _ready() -> void:
	_canvas = CanvasLayer.new()
	_canvas.layer = 45
	add_child(_canvas)
	# Connect signals for tutorial triggers
	EventBus.enemy_defeated.connect(_on_enemy_defeated)
	EventBus.item_collected.connect(_on_item_collected)


func _process(delta: float) -> void:
	if _tracking_movement:
		var player: Node = _find_player()
		if player:
			var dist: float = player.global_position.distance_to(_last_player_pos)
			if dist > 0.01:
				_movement_distance += dist
				_last_player_pos = player.global_position
			if _movement_distance >= 10.0:
				_tracking_movement = false
				complete_tutorial("movement")


func is_completed(tutorial_id: String) -> bool:
	return tutorial_id in completed_tutorials


func complete_tutorial(tutorial_id: String) -> void:
	if tutorial_id in completed_tutorials:
		return
	completed_tutorials.append(tutorial_id)
	_dismiss_hint()

	# Check if all 5 tutorials are done
	var all_done: Array[String] = ["movement", "basic_attack", "dash", "loot", "prompt"]
	var complete: bool = true
	for t: String in all_done:
		if t not in completed_tutorials:
			complete = false
			break
	if complete and not _all_complete_shown:
		_all_complete_shown = true
		show_hint("You're ready. Enter the Compaction Loop.", 3.0)


func show_hint(text: String, auto_dismiss_time: float = 0.0) -> void:
	_dismiss_hint()
	var wrapper: Control = Control.new()
	wrapper.set_anchors_preset(Control.PRESET_FULL_RECT)
	wrapper.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	panel.offset_left = -250.0
	panel.offset_top = 60.0
	panel.offset_right = 250.0
	panel.offset_bottom = 100.0

	var label: RichTextLabel = RichTextLabel.new()
	label.bbcode_enabled = true
	label.text = "[center]%s[/center]" % text
	label.fit_content = true
	label.custom_minimum_size = Vector2(480, 30)
	panel.add_child(label)
	wrapper.add_child(panel)

	_canvas.add_child(wrapper)
	_active_hint = wrapper

	if auto_dismiss_time > 0.0:
		await get_tree().create_timer(auto_dismiss_time).timeout
		_dismiss_hint()


func start_movement_tracking() -> void:
	if is_completed("movement"):
		return
	var player: Node = _find_player()
	if player:
		_last_player_pos = player.global_position
	_movement_distance = 0.0
	_tracking_movement = true
	show_hint("Use WASD to move")


func start_combat_hint() -> void:
	if is_completed("basic_attack"):
		return
	show_hint("Left Click to attack")


func start_dash_hint() -> void:
	if is_completed("dash"):
		return
	show_hint("Press Space to dash through danger")
	# Listen for dash
	if not EventBus.player_dashed.is_connected(_on_player_dashed):
		EventBus.player_dashed.connect(_on_player_dashed)


func start_loot_hint() -> void:
	if is_completed("loot"):
		return
	show_hint("Press E to interact")


func start_prompt_hint() -> void:
	if is_completed("prompt"):
		return
	show_hint("Press Q to use Health Prompt")
	# Connect to player's prompt_used signal
	var player: Node = _find_player()
	if player and player.inventory_component.has_signal(&"prompt_used"):
		if not player.inventory_component.prompt_used.is_connected(_on_prompt_used):
			player.inventory_component.prompt_used.connect(_on_prompt_used)


func _on_prompt_used(_type: String, _remaining: int) -> void:
	if not is_completed("prompt"):
		complete_tutorial("prompt")


func _on_enemy_defeated(_type: StringName, _pos: Vector3, _loot: Resource) -> void:
	if not is_completed("basic_attack"):
		complete_tutorial("basic_attack")


func _on_item_collected(_item: Resource) -> void:
	if not is_completed("loot"):
		complete_tutorial("loot")


func _on_player_dashed(_from: Vector3, _to: Vector3) -> void:
	if not is_completed("dash"):
		complete_tutorial("dash")
	if EventBus.player_dashed.is_connected(_on_player_dashed):
		EventBus.player_dashed.disconnect(_on_player_dashed)


func _dismiss_hint() -> void:
	if _active_hint and is_instance_valid(_active_hint):
		_active_hint.queue_free()
		_active_hint = null


func _find_player() -> Node:
	var nodes: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if nodes.size() > 0:
		return nodes[0]
	return null
