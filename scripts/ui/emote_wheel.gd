class_name EmoteWheel
extends Control

## Radial emote selection wheel — 12 slots arranged in a circle.
## Player holds the bind, mouse-direction selects, release fires the emote.
##
## Each slot exposes one of the Epic 03 emote animations as a player-
## triggerable action. The chosen animation is dispatched via EventBus
## so the player's AnimationTree (or whatever drives the rig) plays it.
##
## Required scene shape:
##   EmoteWheel (Control + this script)
##     CenterRing (TextureRect)         optional decorative center
##     SlotsContainer (Control)
##       Slot0..Slot11 (Control + Label/Icon)
##
## Configure via inspector:
##   slot_radius_px        — distance from center to slot icon
##   highlight_arc_degrees — how wide the selection arc is per slot
##                            (default 30° = 360 / 12)

signal emote_selected(emote_id: StringName)
signal opened
signal closed

const SLOT_COUNT: int = 12

## Default 12 emotes from Epic 03. Order = clockwise from top.
const DEFAULT_EMOTES: Array[Dictionary] = [
	{ "id": &"wave",          "label": "Wave",          "icon": "wave" },
	{ "id": &"thumbs_up",     "label": "Thumbs Up",     "icon": "thumbs_up" },
	{ "id": &"point",         "label": "Point",         "icon": "point" },
	{ "id": &"shrug",         "label": "Shrug",         "icon": "shrug" },
	{ "id": &"laugh",         "label": "Laugh",         "icon": "laugh" },
	{ "id": &"dance_cozy_bop","label": "Dance",         "icon": "dance" },
	{ "id": &"sit",           "label": "Sit",           "icon": "sit" },
	{ "id": &"sleep",         "label": "Sleep",         "icon": "sleep" },
	{ "id": &"thinking",      "label": "Thinking",      "icon": "thinking" },
	{ "id": &"salute",        "label": "Salute",        "icon": "salute" },
	{ "id": &"facepalm",      "label": "Facepalm",      "icon": "facepalm" },
	{ "id": &"high_five",     "label": "High Five",     "icon": "high_five" },
]

@export var slot_radius_px: float = 180.0
@export var highlight_arc_degrees: float = 30.0
@export var open_time_s: float = 0.15
@export var close_time_s: float = 0.10

var _slot_nodes: Array[Control] = []
var _emotes: Array[Dictionary] = DEFAULT_EMOTES
var _hovered_slot: int = -1
var _is_open: bool = false


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_slots()
	set_process_unhandled_input(true)


func _build_slots() -> void:
	var slots_container: Control = get_node_or_null("SlotsContainer")
	if slots_container == null:
		slots_container = Control.new()
		slots_container.name = "SlotsContainer"
		slots_container.set_anchors_preset(Control.PRESET_CENTER)
		add_child(slots_container)

	# Clear any pre-existing children
	for c: Node in slots_container.get_children():
		c.queue_free()
	_slot_nodes.clear()

	for i: int in SLOT_COUNT:
		var slot: PanelContainer = PanelContainer.new()
		slot.name = "Slot%d" % i
		slot.custom_minimum_size = Vector2(72, 72)
		slot.set_anchors_preset(Control.PRESET_CENTER)
		# Position around the circle (i=0 at top, going clockwise)
		var angle_deg: float = -90.0 + (360.0 / SLOT_COUNT) * i
		var angle_rad: float = deg_to_rad(angle_deg)
		var pos: Vector2 = Vector2(cos(angle_rad), sin(angle_rad)) * slot_radius_px
		slot.position = pos - slot.custom_minimum_size * 0.5

		var label: Label = Label.new()
		label.text = (_emotes[i] as Dictionary).get("label", "")
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 12)
		slot.add_child(label)

		slots_container.add_child(slot)
		_slot_nodes.append(slot)


func open() -> void:
	if _is_open:
		return
	_is_open = true
	visible = true
	modulate.a = 0.0
	scale = Vector2.ONE * 0.8
	var tw: Tween = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, open_time_s)
	tw.tween_property(self, "scale", Vector2.ONE, open_time_s) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	opened.emit()


func close(commit_emote: bool = false) -> void:
	if not _is_open:
		return
	_is_open = false
	if commit_emote and _hovered_slot >= 0:
		var emote_id: StringName = (_emotes[_hovered_slot] as Dictionary).get("id", &"")
		if emote_id != &"":
			emote_selected.emit(emote_id)
	var tw: Tween = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "modulate:a", 0.0, close_time_s)
	tw.tween_property(self, "scale", Vector2.ONE * 0.85, close_time_s)
	tw.chain().tween_callback(func(): visible = false)
	closed.emit()


func _process(_delta: float) -> void:
	if not _is_open:
		return
	_update_hover()


func _update_hover() -> void:
	# Pick the slot whose direction is closest to the mouse vector from center.
	var center: Vector2 = size * 0.5
	var mouse_local: Vector2 = get_local_mouse_position() - center
	if mouse_local.length() < 30.0:
		_set_hover(-1)
		return
	var angle_rad: float = mouse_local.angle()
	# Convert to "0 = top, going clockwise" angle and find slot
	var angle_from_top: float = rad_to_deg(angle_rad) + 90.0
	if angle_from_top < 0.0:
		angle_from_top += 360.0
	var slot_index: int = int(round(angle_from_top / (360.0 / SLOT_COUNT))) % SLOT_COUNT
	_set_hover(slot_index)


func _set_hover(index: int) -> void:
	if index == _hovered_slot:
		return
	if _hovered_slot >= 0 and _hovered_slot < _slot_nodes.size():
		_slot_nodes[_hovered_slot].modulate = Color.WHITE
	_hovered_slot = index
	if index >= 0 and index < _slot_nodes.size():
		_slot_nodes[index].modulate = Color(1.4, 1.3, 0.9, 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if not _is_open:
		return
	if event is InputEventKey:
		var k: InputEventKey = event as InputEventKey
		if k.keycode == KEY_ESCAPE and k.pressed:
			close(false)


func set_emotes(emotes: Array[Dictionary]) -> void:
	## Custom emote loadout — pass an array of {id, label, icon} dicts.
	## Use to expose ability-tree-unlocked emotes or season pass cosmetics.
	_emotes = emotes.slice(0, SLOT_COUNT)
	while _emotes.size() < SLOT_COUNT:
		_emotes.append(DEFAULT_EMOTES[_emotes.size()])
	_build_slots()
