class_name QuestTrackerHUD
extends CanvasLayer

## Quest Tracker HUD Widget (Epic 38 task 4 + 31 + 32 + 33 + 34).
##
## Compact left-side HUD showing the currently tracked quest:
##   - Quest title
##   - Up to 3 active objectives with checkbox state
##   - Distance/direction arrow to nearest objective marker
##   - Sound sting hooks on objective complete
##
## Auto-shows when a quest is being tracked. Hides during cutscenes.

signal objective_marker_pinged(quest_id: StringName, objective_index: int, world_position: Vector3)
signal quest_sting_played(sting: StringName)

const MAX_VISIBLE_OBJECTIVES: int = 3
const MARKER_PING_INTERVAL: float = 1.5

@export var auto_show_when_tracked: bool = true

var _root: Control
var _panel: Panel
var _title_label: Label
var _objective_labels: Array[Label] = []
var _direction_label: Label
var _tracked_quest: Dictionary = {}
var _objective_world_positions: Array = []  # parallel to objectives
var _player_node: Node3D
var _ping_timer: float = 0.0


func _ready() -> void:
	layer = 25
	_build_ui()
	visible = false
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("quest_objective_completed"):
			bus.connect("quest_objective_completed", _on_objective_completed)
		if bus.has_signal("quest_started"):
			bus.connect("quest_started", _on_quest_started)


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_panel = Panel.new()
	_panel.size = Vector2(320, 160)
	_panel.anchor_left = 0.0
	_panel.anchor_top = 0.0
	_panel.offset_left = 20
	_panel.offset_top = 200
	_root.add_child(_panel)

	_title_label = Label.new()
	_title_label.position = Vector2(12, 8)
	_title_label.size = Vector2(296, 26)
	_title_label.add_theme_font_size_override("font_size", 16)
	_title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	_panel.add_child(_title_label)

	for i in range(MAX_VISIBLE_OBJECTIVES):
		var lbl := Label.new()
		lbl.position = Vector2(12, 36 + i * 24)
		lbl.size = Vector2(296, 22)
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
		_panel.add_child(lbl)
		_objective_labels.append(lbl)

	_direction_label = Label.new()
	_direction_label.position = Vector2(12, 124)
	_direction_label.size = Vector2(296, 22)
	_direction_label.add_theme_font_size_override("font_size", 12)
	_direction_label.add_theme_color_override("font_color", Color(0.6, 0.78, 0.92))
	_panel.add_child(_direction_label)


func track_quest(quest: Dictionary, objective_world_positions: Array = []) -> void:
	_tracked_quest = quest
	_objective_world_positions = objective_world_positions
	_refresh_display()
	if auto_show_when_tracked:
		visible = true


func untrack() -> void:
	_tracked_quest = {}
	_objective_world_positions = []
	visible = false


func set_player_reference(player: Node3D) -> void:
	_player_node = player


func _refresh_display() -> void:
	if _tracked_quest.is_empty():
		visible = false
		return
	_title_label.text = _tracked_quest.get("title", "")
	var objectives: Array = _tracked_quest.get("objectives", [])
	for i in range(MAX_VISIBLE_OBJECTIVES):
		if i < objectives.size():
			var obj: Dictionary = objectives[i]
			var done: bool = obj.get("done", false)
			var marker: String = "✓" if done else "○"
			_objective_labels[i].text = "%s %s" % [marker, _objective_text(obj)]
			_objective_labels[i].add_theme_color_override("font_color",
				Color(0.55, 0.95, 0.55) if done else Color(0.85, 0.92, 1.0))
		else:
			_objective_labels[i].text = ""


func _objective_text(obj: Dictionary) -> String:
	var kind: StringName = obj.get("kind", &"?")
	match kind:
		&"collect":
			var have: int = int(obj.get("current", 0))
			var need: int = int(obj.get("qty", 1))
			return "Collect %s (%d/%d)" % [obj.get("item", "?"), have, need]
		&"kill":
			var have: int = int(obj.get("current", 0))
			var need: int = int(obj.get("qty", 1))
			return "Defeat %s (%d/%d)" % [obj.get("enemy", "?"), have, need]
		&"deliver":
			return "Deliver to %s" % obj.get("to", "?")
		&"explore":
			return "Explore %s" % obj.get("area", "?")
		&"escort":
			return "Escort %s" % obj.get("target", "?")
		&"interact":
			return "Interact with %s" % obj.get("target", "?")
		&"find":
			return "Find %s" % obj.get("item", obj.get("target", "?"))
	return str(kind).capitalize()


func _process(delta: float) -> void:
	if not visible or _tracked_quest.is_empty() or _player_node == null:
		return
	# Update direction to nearest active objective
	var objectives: Array = _tracked_quest.get("objectives", [])
	var best_dist: float = INF
	var best_idx: int = -1
	for i in range(min(objectives.size(), _objective_world_positions.size())):
		var obj: Dictionary = objectives[i]
		if obj.get("done", false):
			continue
		var pos: Vector3 = _objective_world_positions[i]
		var d: float = _player_node.global_position.distance_to(pos)
		if d < best_dist:
			best_dist = d
			best_idx = i
	if best_idx >= 0:
		var pos: Vector3 = _objective_world_positions[best_idx]
		var dir: Vector3 = pos - _player_node.global_position
		var dist: float = dir.length()
		var compass: String = _compass_direction_for(dir)
		_direction_label.text = "%s — %.0fm" % [compass, dist]
		# Periodic ping
		_ping_timer += delta
		if _ping_timer >= MARKER_PING_INTERVAL:
			_ping_timer = 0.0
			objective_marker_pinged.emit(_tracked_quest.get("id", &""), best_idx, pos)
	else:
		_direction_label.text = ""


func _compass_direction_for(dir: Vector3) -> String:
	var angle: float = atan2(dir.x, dir.z)
	var deg: float = rad_to_deg(angle)
	if deg < 0: deg += 360
	if deg < 22.5 or deg >= 337.5: return "N"
	if deg < 67.5: return "NE"
	if deg < 112.5: return "E"
	if deg < 157.5: return "SE"
	if deg < 202.5: return "S"
	if deg < 247.5: return "SW"
	if deg < 292.5: return "W"
	return "NW"


func _on_objective_completed(quest_id: StringName, objective_index: int) -> void:
	if _tracked_quest.get("id", &"") == quest_id:
		var objectives: Array = _tracked_quest.get("objectives", [])
		if objective_index < objectives.size():
			objectives[objective_index]["done"] = true
		_refresh_display()
		if has_node("/root/AudioManager"):
			var am: Node = get_node("/root/AudioManager")
			if am.has_method("play_sfx"):
				am.call("play_sfx", &"sfx_quest_objective_complete")
		quest_sting_played.emit(&"sfx_quest_objective_complete")


func _on_quest_started(quest_data: Dictionary) -> void:
	if has_node("/root/AudioManager"):
		var am: Node = get_node("/root/AudioManager")
		if am.has_method("play_sfx"):
			am.call("play_sfx", &"sfx_quest_started")
	quest_sting_played.emit(&"sfx_quest_started")
