class_name FirstEquipCinematic
extends Node

## Plays a brief cinematic flash the first time the player equips a piece of
## gear. Reads "first_equip_seen" from save data so each unique item only
## triggers it once. Designed to feel rewarding without interrupting flow.
##
## Sequence (~1.2s total):
##   t=0.00  Hitstop ~80ms
##   t=0.08  Camera lean toward player + zoom-in 1.15x
##   t=0.10  White flash (full screen, 0.05 alpha → 0)
##   t=0.20  Item name banner slides in from below
##   t=0.30  Rarity-tinted radial burst at player position
##   t=0.50  Banner holds (item name + rarity tag)
##   t=1.00  Banner slides out, camera returns
##   t=1.20  Cinematic ends, gameplay resumes

@export var camera_path: NodePath
@export var hud_path: NodePath
@export var save_path: NodePath

const RARITY_TAGS: Array[String] = [
	"COMMON", "UNCOMMON", "RARE", "EPIC", "LEGENDARY", "CURSED",
]

const RARITY_COLORS: Array[Color] = [
	Color(0.85, 0.85, 0.85, 1),
	Color(0.40, 0.95, 0.40, 1),
	Color(0.40, 0.55, 0.95, 1),
	Color(0.85, 0.40, 0.95, 1),
	Color(0.95, 0.65, 0.20, 1),
	Color(0.95, 0.20, 0.20, 1),
]

var _seen_items: Dictionary = {}  ## item_id -> true
var _camera: Node3D
var _hud: CanvasLayer
var _running: bool = false


func _ready() -> void:
	_camera = get_node_or_null(camera_path) as Node3D
	_hud = get_node_or_null(hud_path) as CanvasLayer

	# Restore seen list from save data
	var save_node: Node = get_node_or_null(save_path)
	if save_node != null and save_node.has_method("get_data"):
		var saved: Variant = save_node.get_data("first_equip_seen")
		if saved is Dictionary:
			_seen_items = saved

	# Subscribe to equipment events
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("item_equipped"):
			bus.item_equipped.connect(_on_item_equipped)


func _on_item_equipped(item: Resource) -> void:
	if item == null or _running:
		return
	var item_id: String = String(item.get("item_id"))
	if item_id == "" or _seen_items.has(item_id):
		return

	_seen_items[item_id] = true
	_persist_seen()

	_running = true
	_play_cinematic(item)


func _play_cinematic(item: Resource) -> void:
	var rarity: int = clampi(int(item.get("rarity")), 0, RARITY_COLORS.size() - 1)
	var color: Color = RARITY_COLORS[rarity]
	var tag: String = RARITY_TAGS[rarity]
	var item_name: String = String(item.get("item_name"))

	# Hitstop
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("hitstop_requested"):
			bus.hitstop_requested.emit(0.08)

	await get_tree().create_timer(0.08).timeout

	# Camera zoom + lean
	if _camera != null and _camera.has_method("zoom_to_target"):
		_camera.zoom_to_target(1.15, 0.4)

	# White flash + radial burst + banner via HUD signals
	if _hud != null and _hud.has_method("flash_white"):
		_hud.flash_white(0.06, 0.4)
	if _hud != null and _hud.has_method("show_item_banner"):
		_hud.show_item_banner(item_name, tag, color, 1.0)

	await get_tree().create_timer(1.0).timeout

	if _camera != null and _camera.has_method("zoom_reset"):
		_camera.zoom_reset(0.2)

	_running = false


func _persist_seen() -> void:
	var save_node: Node = get_node_or_null(save_path)
	if save_node != null and save_node.has_method("set_data"):
		save_node.set_data("first_equip_seen", _seen_items)


func reset_seen() -> void:
	_seen_items.clear()
	_persist_seen()
