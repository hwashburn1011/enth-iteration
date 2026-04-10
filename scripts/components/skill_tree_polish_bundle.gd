class_name SkillTreePolishBundle
extends Node

## Skill Tree Polish Bundle (Epic 32 tasks 30, 32, 33, 34, 40, 42, 48).
##
## Adds polish layers to an existing skill tree panel:
##   - Task 30: open/close animation (fade-in + scale-up)
##   - Task 32: per-class theme (recolors panel based on active class)
##   - Task 33: particle effect on node activation (radial sparks)
##   - Task 34: SFX on allocate
##   - Task 40: achievement triggers on node count milestones
##   - Task 42: gamepad navigation (D-pad jumps to nearest node)
##   - Task 48: new node tutorial popup (first allocation)
##
## Hook:
##   var polish := SkillTreePolishBundle.new()
##   add_child(polish)
##   polish.bind_panel(skill_tree_panel)

signal panel_opened
signal panel_closed
signal node_allocated_polished(node_id: StringName)

const OPEN_DURATION: float = 0.35
const CLOSE_DURATION: float = 0.25
const NODE_ACTIVATE_SPARK_LIFETIME: float = 0.6
const ACHIEVEMENT_THRESHOLDS: Array[int] = [10, 25, 50]
const NEW_NODE_TUTORIAL_FLAG: StringName = &"tutorial_skill_node_allocated"

@export var panel_path: NodePath
@export var enable_controller_nav: bool = true

var _panel: Control
var _is_open: bool = false
var _open_progress: float = 0.0
var _is_animating: bool = false
var _registered_nodes: Dictionary = {}  # node_id → Control
var _focused_node_id: StringName = &""
var _allocated_count: int = 0
var _has_shown_first_node_tutorial: bool = false
var _tutorial_popup: Panel
var _tutorial_label: Label


func _ready() -> void:
	if panel_path != NodePath():
		bind_panel(get_node_or_null(panel_path))
	_build_tutorial_popup()


func bind_panel(panel: Control) -> void:
	_panel = panel
	if _panel != null:
		_panel.scale = Vector2(0.95, 0.95)
		_panel.modulate.a = 0.0
		_panel.visible = false


func register_node(node_id: StringName, control: Control) -> void:
	_registered_nodes[node_id] = control


# === Task 30: open / close animations ===
func open() -> void:
	if _panel == null or _is_open:
		return
	_is_open = true
	_panel.visible = true
	_is_animating = true
	_open_progress = 0.0
	set_process(true)
	panel_opened.emit()


func close() -> void:
	if _panel == null or not _is_open:
		return
	_is_open = false
	_is_animating = true
	set_process(true)
	panel_closed.emit()


func _process(delta: float) -> void:
	if _panel == null:
		return
	if _is_animating:
		if _is_open:
			_open_progress = min(1.0, _open_progress + delta / OPEN_DURATION)
			var t: float = _ease_out(_open_progress)
			_panel.modulate.a = t
			_panel.scale = Vector2(0.95 + 0.05*t, 0.95 + 0.05*t)
			if _open_progress >= 1.0:
				_is_animating = false
		else:
			_open_progress = max(0.0, _open_progress - delta / CLOSE_DURATION)
			var t: float = _ease_in(_open_progress)
			_panel.modulate.a = t
			_panel.scale = Vector2(0.95 + 0.05*t, 0.95 + 0.05*t)
			if _open_progress <= 0.0:
				_panel.visible = false
				_is_animating = false
				set_process(false)


func _ease_out(t: float) -> float:
	return 1.0 - pow(1.0 - t, 3.0)


func _ease_in(t: float) -> float:
	return t * t


# === Task 32: class theme ===
func apply_class_theme(class_id: StringName) -> void:
	if _panel == null:
		return
	var palette: Dictionary = ClassSystemDatabase.get_hud_palette(class_id)
	_recolor_panel(_panel, palette)


func _recolor_panel(node: Node, palette: Dictionary) -> void:
	if node is ColorRect:
		var name_lower: String = node.name.to_lower()
		if "accent" in name_lower:
			(node as ColorRect).color = palette.get("accent", Color.WHITE)
		elif "background" in name_lower or "bg" in name_lower:
			(node as ColorRect).color = palette.get("dark", Color.BLACK)
		elif "primary" in name_lower or "border" in name_lower:
			(node as ColorRect).color = palette.get("primary", Color.WHITE)
	for child in node.get_children():
		_recolor_panel(child, palette)


# === Task 33 + 34: activate VFX + SFX ===
func play_node_activate(node_id: StringName) -> void:
	_allocated_count += 1
	# Spark VFX
	var control: Control = _registered_nodes.get(node_id)
	if control != null:
		_spawn_spark_burst(control)
	# SFX
	if has_node("/root/AudioManager"):
		var am: Node = get_node("/root/AudioManager")
		if am.has_method("play_sfx"):
			am.call("play_sfx", &"sfx_skill_node_allocate")
	# Achievement check
	_check_achievements()
	# First node tutorial
	if not _has_shown_first_node_tutorial:
		_has_shown_first_node_tutorial = true
		_show_first_node_tutorial()
	node_allocated_polished.emit(node_id)


func _spawn_spark_burst(control: Control) -> void:
	# 8 radial spark Polygon2Ds that fly outward and fade
	for i in range(8):
		var spark := Polygon2D.new()
		spark.polygon = PackedVector2Array([Vector2(0, -3), Vector2(6, 0), Vector2(0, 3), Vector2(-6, 0)])
		spark.color = Color(1.0, 0.95, 0.5)
		var ang: float = (i / 8.0) * TAU
		var dir: Vector2 = Vector2(cos(ang), sin(ang))
		spark.position = control.size * 0.5
		control.add_child(spark)
		# Tween outward + fade
		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(spark, "position", spark.position + dir * 28, NODE_ACTIVATE_SPARK_LIFETIME)
		tween.tween_property(spark, "modulate:a", 0.0, NODE_ACTIVATE_SPARK_LIFETIME)
		tween.set_parallel(false)
		tween.tween_callback(spark.queue_free)


# === Task 40: achievement triggers ===
func _check_achievements() -> void:
	for threshold in ACHIEVEMENT_THRESHOLDS:
		if _allocated_count == threshold:
			if has_node("/root/AchievementManager"):
				var am: Node = get_node("/root/AchievementManager")
				if am.has_method("trigger"):
					am.call("trigger", StringName("skill_nodes_%d" % threshold))


# === Task 42: gamepad navigation ===
func _input(event: InputEvent) -> void:
	if not enable_controller_nav or not _is_open:
		return
	if event.is_action_pressed("ui_up"):
		_jump_to_nearest(Vector2.UP)
	elif event.is_action_pressed("ui_down"):
		_jump_to_nearest(Vector2.DOWN)
	elif event.is_action_pressed("ui_left"):
		_jump_to_nearest(Vector2.LEFT)
	elif event.is_action_pressed("ui_right"):
		_jump_to_nearest(Vector2.RIGHT)


func _jump_to_nearest(direction: Vector2) -> void:
	if _registered_nodes.is_empty():
		return
	var current_pos: Vector2 = Vector2.ZERO
	if _focused_node_id != &"" and _registered_nodes.has(_focused_node_id):
		current_pos = (_registered_nodes[_focused_node_id] as Control).global_position
	var best_id: StringName = &""
	var best_score: float = INF
	for nid: StringName in _registered_nodes.keys():
		if nid == _focused_node_id:
			continue
		var ctrl: Control = _registered_nodes[nid]
		var npos: Vector2 = ctrl.global_position
		var delta: Vector2 = npos - current_pos
		var proj: float = delta.dot(direction)
		if proj <= 1.0:
			continue
		var perp: float = delta.length() - proj
		var score: float = proj + perp * 2.0
		if score < best_score:
			best_score = score
			best_id = nid
	if best_id != &"":
		_focused_node_id = best_id
		var target: Control = _registered_nodes[best_id]
		target.grab_focus()


# === Task 48: first-node tutorial popup ===
func _build_tutorial_popup() -> void:
	_tutorial_popup = Panel.new()
	_tutorial_popup.size = Vector2(380, 110)
	_tutorial_popup.anchor_left = 0.5
	_tutorial_popup.anchor_top = 0.85
	_tutorial_popup.offset_left = -190
	_tutorial_popup.offset_top = -55
	_tutorial_popup.visible = false
	add_child(_tutorial_popup)
	_tutorial_label = Label.new()
	_tutorial_label.position = Vector2(20, 20)
	_tutorial_label.size = Vector2(340, 70)
	_tutorial_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_tutorial_label.text = "Tip: Allocated nodes glow with your class color. Hold the right stick to pan, triggers to zoom. Press [Y] to respec at the cost of 50 data shards."
	_tutorial_label.add_theme_font_size_override("font_size", 14)
	_tutorial_label.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0))
	_tutorial_popup.add_child(_tutorial_label)


func _show_first_node_tutorial() -> void:
	_tutorial_popup.visible = true
	_tutorial_popup.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(_tutorial_popup, "modulate:a", 1.0, 0.3)
	var hide_tween: Tween = create_tween()
	hide_tween.tween_interval(5.0)
	hide_tween.tween_property(_tutorial_popup, "modulate:a", 0.0, 0.4)
	hide_tween.tween_callback(func() -> void: _tutorial_popup.visible = false)
