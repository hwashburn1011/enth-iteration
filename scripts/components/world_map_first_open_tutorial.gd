class_name WorldMapFirstOpenTutorial
extends CanvasLayer

## First-Time World Map Tutorial (Epic 28 task 48).
##
## Shown exactly once — the first time the player opens the world map.
## Displays a non-modal tooltip sequence over the map UI pointing out
## the key controls: pan, zoom, fast-travel, markers, waypoint, filter.
##
## Each tooltip has an anchor Control node, an arrow pointer, and a body.
## Player advances with ui_accept, skips with ui_cancel. State persists via
## SaveManager.set_flag("tutorial_world_map_seen").
##
## Attach this as a child of the world map panel. Call start() once the
## map is open. Tutorial silently no-ops if the flag is already set.

signal tutorial_started
signal tutorial_step_shown(step_id: StringName)
signal tutorial_completed

const SAVE_FLAG: StringName = &"tutorial_world_map_seen"

@export var force_show: bool = false  # debug override

var _steps: Array[Dictionary] = []
var _current_step: int = -1
var _panel: Control
var _tooltip_body: Label
var _tooltip_title: Label
var _tooltip_frame: Panel
var _arrow: Polygon2D
var _dim_overlay: ColorRect
var _is_running: bool = false


func _ready() -> void:
	layer = 95
	_build_ui()
	_build_steps()


func _build_ui() -> void:
	_dim_overlay = ColorRect.new()
	_dim_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dim_overlay.color = Color(0, 0, 0, 0.5)
	_dim_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dim_overlay)

	_tooltip_frame = Panel.new()
	_tooltip_frame.size = Vector2(420, 130)
	_tooltip_frame.modulate = Color(1, 1, 1, 1)
	add_child(_tooltip_frame)

	_tooltip_title = Label.new()
	_tooltip_title.position = Vector2(18, 14)
	_tooltip_title.size = Vector2(384, 30)
	_tooltip_title.add_theme_font_size_override("font_size", 22)
	_tooltip_title.add_theme_color_override("font_color", Color(1, 0.92, 0.6))
	_tooltip_frame.add_child(_tooltip_title)

	_tooltip_body = Label.new()
	_tooltip_body.position = Vector2(18, 48)
	_tooltip_body.size = Vector2(384, 68)
	_tooltip_body.autowrap_mode = TextServer.AUTOWRAP_WORD
	_tooltip_body.add_theme_font_size_override("font_size", 15)
	_tooltip_body.add_theme_color_override("font_color", Color(0.92, 0.92, 0.95))
	_tooltip_frame.add_child(_tooltip_body)

	var hint_label := Label.new()
	hint_label.position = Vector2(18, 104)
	hint_label.size = Vector2(384, 20)
	hint_label.text = "[A] Next    [B] Skip"
	hint_label.add_theme_font_size_override("font_size", 13)
	hint_label.add_theme_color_override("font_color", Color(0.6, 0.7, 0.85))
	_tooltip_frame.add_child(hint_label)

	# Arrow pointer (simple triangle)
	_arrow = Polygon2D.new()
	_arrow.polygon = PackedVector2Array([Vector2(0, 0), Vector2(24, -12), Vector2(24, 12)])
	_arrow.color = Color(1, 0.92, 0.6)
	add_child(_arrow)

	_tooltip_frame.visible = false
	_arrow.visible = false
	_dim_overlay.visible = false


func _build_steps() -> void:
	_steps = [
		{
			"id": &"welcome",
			"title": "Welcome to the World",
			"body": "This map reveals as you explore. Undiscovered regions stay hidden in fog.",
			"anchor": Vector2(0.5, 0.5),
			"arrow_dir": Vector2(0, 1),
		},
		{
			"id": &"pan",
			"title": "Pan the Map",
			"body": "Drag with mouse — or right-stick on a controller — to scroll across the world.",
			"anchor": Vector2(0.5, 0.5),
			"arrow_dir": Vector2(0, 1),
		},
		{
			"id": &"zoom",
			"title": "Zoom In & Out",
			"body": "Scroll wheel / triggers to zoom. Close up reveals landmark names and NPC positions.",
			"anchor": Vector2(0.9, 0.92),
			"arrow_dir": Vector2(1, 0),
		},
		{
			"id": &"markers",
			"title": "Landmark Markers",
			"body": "Gold icons are discovered landmarks. Click or press A to fast-travel there.",
			"anchor": Vector2(0.35, 0.4),
			"arrow_dir": Vector2(-1, 0),
		},
		{
			"id": &"quests",
			"title": "Quest Objectives",
			"body": "Red exclamation marks are active quest targets. Your current waypoint shows a blue arrow.",
			"anchor": Vector2(0.65, 0.35),
			"arrow_dir": Vector2(1, 0),
		},
		{
			"id": &"waypoint",
			"title": "Custom Waypoints",
			"body": "Press X (or middle-click) to drop a waypoint anywhere. The compass will guide you there.",
			"anchor": Vector2(0.5, 0.6),
			"arrow_dir": Vector2(0, -1),
		},
		{
			"id": &"filter",
			"title": "Marker Filters",
			"body": "Press Y (or the filter button) to hide/show markers by category — NPCs, quests, lore, etc.",
			"anchor": Vector2(0.1, 0.1),
			"arrow_dir": Vector2(-1, -1),
		},
		{
			"id": &"notes",
			"title": "Player Notes",
			"body": "Long-press on any location to add a personal note. Notes save with your game.",
			"anchor": Vector2(0.5, 0.5),
			"arrow_dir": Vector2(0, 0),
		},
	]


func start() -> void:
	if not force_show and _get_flag(SAVE_FLAG):
		return
	_is_running = true
	_current_step = -1
	_dim_overlay.visible = true
	tutorial_started.emit()
	_advance()


func _advance() -> void:
	_current_step += 1
	if _current_step >= _steps.size():
		_finish()
		return
	_show_step(_steps[_current_step])


func _show_step(step: Dictionary) -> void:
	_tooltip_title.text = String(step.get("title", ""))
	_tooltip_body.text = String(step.get("body", ""))
	_tooltip_frame.visible = true
	_arrow.visible = true

	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var anchor_uv: Vector2 = step.get("anchor", Vector2(0.5, 0.5))
	var arrow_dir: Vector2 = step.get("arrow_dir", Vector2(0, 0))
	var anchor_pos: Vector2 = viewport_size * anchor_uv

	# Offset the tooltip so the arrow points at the anchor
	var tooltip_size: Vector2 = _tooltip_frame.size
	var offset_from_anchor: Vector2 = arrow_dir * 120.0
	var tooltip_pos: Vector2 = anchor_pos + offset_from_anchor - tooltip_size * 0.5
	# Clamp into screen
	tooltip_pos.x = clamp(tooltip_pos.x, 16, viewport_size.x - tooltip_size.x - 16)
	tooltip_pos.y = clamp(tooltip_pos.y, 16, viewport_size.y - tooltip_size.y - 16)
	_tooltip_frame.position = tooltip_pos

	# Arrow sits at the midpoint between the tooltip edge and the anchor
	_arrow.position = (tooltip_pos + tooltip_size * 0.5 + anchor_pos) * 0.5
	var arrow_angle: float = -arrow_dir.angle() + PI
	_arrow.rotation = arrow_angle

	tutorial_step_shown.emit(step.get("id", &""))


func _input(event: InputEvent) -> void:
	if not _is_running:
		return
	if event.is_action_pressed("ui_accept"):
		_advance()
	elif event.is_action_pressed("ui_cancel"):
		_finish()


func _finish() -> void:
	_is_running = false
	_tooltip_frame.visible = false
	_arrow.visible = false
	_dim_overlay.visible = false
	_set_flag(SAVE_FLAG, true)
	tutorial_completed.emit()


# --- Save flag helpers (SaveManager may or may not expose flags) ---
func _get_flag(flag: StringName) -> bool:
	if force_show:
		return false
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("get_flag"):
			return bool(sm.call("get_flag", flag))
	return false


func _set_flag(flag: StringName, value: bool) -> void:
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("set_flag"):
			sm.call("set_flag", flag, value)
