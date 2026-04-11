class_name SkillTreeUI
extends Control

## Pan/zoom skill tree viewport. Renders nodes from the active SkillTree
## resource, draws connection lines between prerequisites, displays
## tooltip on hover, allocates on click.

signal node_allocated(node_id: StringName)
signal node_refunded(node_id: StringName)

@export var skill_tree_component_path: NodePath
@export var node_size: Vector2 = Vector2(72, 72)
@export var node_spacing: Vector2 = Vector2(110, 110)
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.5
@export var zoom_step: float = 0.15

@onready var _canvas: Control = %TreeCanvas
@onready var _line_drawer: Control = %LineDrawer
@onready var _tooltip_panel: PanelContainer = %TooltipPanel
@onready var _tooltip_label: RichTextLabel = %TooltipLabel
@onready var _points_label: Label = %PointsLabel

var _component: SkillTreeComponent
var _node_buttons: Dictionary = {}  ## node_id -> Button
var _zoom: float = 1.0
var _pan_offset: Vector2 = Vector2.ZERO
var _dragging: bool = false
var _drag_start: Vector2
var _drag_offset_start: Vector2
var _hovered_node_id: StringName = &""


func _ready() -> void:
	_component = get_node_or_null(skill_tree_component_path)
	if _component == null:
		push_warning("SkillTreeUI: component not found at %s" % skill_tree_component_path)
		return
	_component.skill_allocated.connect(_on_skill_changed)
	_component.skill_refunded.connect(_on_skill_changed)
	_component.skill_points_changed.connect(_on_points_changed)
	_component.tree_reset.connect(_rebuild)
	_rebuild()


func _rebuild() -> void:
	if _component == null or _component.current_tree == null:
		return
	if _canvas != null:
		for c in _canvas.get_children():
			c.queue_free()
		_node_buttons.clear()

	for node: SkillNode in _component.current_tree.nodes:
		_create_node_button(node)
	_refresh_states()
	if _line_drawer != null:
		_line_drawer.queue_redraw()


func _create_node_button(node: SkillNode) -> void:
	if _canvas == null:
		return
	var btn: TextureButton = TextureButton.new()
	btn.name = String(node.node_id)
	btn.custom_minimum_size = node_size
	btn.size = node_size
	btn.position = Vector2(node.grid_position) * node_spacing - node_size * 0.5
	btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	if node.icon != null:
		btn.texture_normal = node.icon
	if node.is_keystone:
		btn.scale = Vector2(1.4, 1.4)
	btn.mouse_entered.connect(_on_node_hover.bind(node.node_id))
	btn.mouse_exited.connect(_on_node_unhover)
	btn.gui_input.connect(_on_node_input.bind(node.node_id))
	_canvas.add_child(btn)
	_node_buttons[node.node_id] = btn


func _refresh_states() -> void:
	if _component == null or _component.current_tree == null:
		return
	for node_id: StringName in _node_buttons.keys():
		var btn: TextureButton = _node_buttons[node_id]
		var allocated: int = _component.allocation.get(node_id, 0)
		var node: SkillNode = _component.current_tree.get_node(node_id)
		var available: bool = _component.can_allocate(node_id)
		if allocated > 0:
			btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
			btn.self_modulate = _component.current_tree.theme_color
		elif available:
			btn.modulate = Color(0.85, 0.85, 0.85, 1.0)
		else:
			btn.modulate = Color(0.35, 0.35, 0.35, 0.6)


func _on_node_input(event: InputEvent, node_id: StringName) -> void:
	if not (event is InputEventMouseButton):
		return
	var mb: InputEventMouseButton = event
	if not mb.pressed:
		return
	if mb.button_index == MOUSE_BUTTON_LEFT:
		if _component.allocate(node_id):
			node_allocated.emit(node_id)
	elif mb.button_index == MOUSE_BUTTON_RIGHT:
		if _component.refund(node_id):
			node_refunded.emit(node_id)


func _on_node_hover(node_id: StringName) -> void:
	_hovered_node_id = node_id
	if _component == null:
		return
	var node: SkillNode = _component.current_tree.get_node(node_id)
	if node == null:
		return
	if _tooltip_label != null:
		_tooltip_label.text = node.get_full_tooltip()
	if _tooltip_panel != null:
		_tooltip_panel.visible = true


func _on_node_unhover() -> void:
	_hovered_node_id = &""
	if _tooltip_panel != null:
		_tooltip_panel.visible = false


func _on_skill_changed(_node_id: StringName, _rank_or_nothing = null) -> void:
	_refresh_states()
	if _line_drawer != null:
		_line_drawer.queue_redraw()


func _on_points_changed(available: int, _spent: int) -> void:
	if _points_label != null:
		_points_label.text = "Skill Points: %d" % available


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if mb.button_index == MOUSE_BUTTON_MIDDLE:
			_dragging = mb.pressed
			if _dragging:
				_drag_start = mb.position
				_drag_offset_start = _pan_offset
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			_zoom = clampf(_zoom + zoom_step, min_zoom, max_zoom)
			_apply_transform()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			_zoom = clampf(_zoom - zoom_step, min_zoom, max_zoom)
			_apply_transform()
	elif event is InputEventMouseMotion and _dragging:
		_pan_offset = _drag_offset_start + (event.position - _drag_start)
		_apply_transform()


func _apply_transform() -> void:
	if _canvas != null:
		_canvas.position = _pan_offset
		_canvas.scale = Vector2(_zoom, _zoom)
