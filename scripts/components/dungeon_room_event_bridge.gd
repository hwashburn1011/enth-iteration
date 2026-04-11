class_name DungeonRoomEventBridge
extends Node

## Dungeon Room Enter/Exit Trigger Bridge (Epic 29 tasks 36 & 37).
##
## Wires every generated dungeon room to broadcast room enter/exit events
## through EventBus so subsystems (music, lighting, AI, quest tracking) can
## react without coupling directly to the room scene.
##
## Each room gets an Area3D collider sized to the room's floor polygon
## (extruded 6m up). When the player overlaps it for the first time, the
## bridge:
##   1. Emits EventBus.dungeon_room_entered(room_id, tag, biome)
##   2. Marks the room as "entered" so re-entries don't re-fire intro logic
##   3. Triggers a soft transition fade if the room tag is "story"/"boss"
##
## On exit it emits dungeon_room_exited.
##
## Hook (after generation):
##   for room in generated_rooms:
##       var bridge := DungeonRoomEventBridge.new()
##       bridge.bind_room(room)
##       room.node.add_child(bridge)

signal room_entered(room_id: StringName, tag: StringName, biome: StringName)
signal room_exited(room_id: StringName)

const PLAYER_GROUP: StringName = &"player"
const FADE_DURATION_BY_TAG: Dictionary = {
	&"story": 0.6,
	&"boss": 0.8,
	&"secret": 0.5,
}

var _room_id: StringName
var _room_tag: StringName
var _room_biome: StringName
var _has_been_entered: bool = false
var _area: Area3D
var _floor_polygon: PackedVector2Array


func bind_room(room: Dictionary) -> void:
	_room_id = room.get("id", &"")
	_room_tag = room.get("tag", &"combat")
	_room_biome = room.get("biome", &"unknown")
	_floor_polygon = room.get("floor_polygon", PackedVector2Array())


func _ready() -> void:
	if _room_id == &"":
		push_warning("DungeonRoomEventBridge: bind_room() not called before _ready")
		return
	_build_collider()


func _build_collider() -> void:
	_area = Area3D.new()
	_area.monitoring = true
	_area.collision_layer = 0
	_area.collision_mask = 1  # player layer
	add_child(_area)

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()

	# Compute bounds from floor polygon
	if _floor_polygon.size() > 0:
		var min_v := Vector2(INF, INF)
		var max_v := Vector2(-INF, -INF)
		for p in _floor_polygon:
			min_v.x = min(min_v.x, p.x)
			min_v.y = min(min_v.y, p.y)
			max_v.x = max(max_v.x, p.x)
			max_v.y = max(max_v.y, p.y)
		var size_v: Vector2 = max_v - min_v
		var center: Vector2 = (min_v + max_v) * 0.5
		box.size = Vector3(max(size_v.x, 1.0), 6.0, max(size_v.y, 1.0))
		_area.position = Vector3(center.x, 3.0, center.y)
	else:
		box.size = Vector3(12, 6, 12)
		_area.position = Vector3(0, 3, 0)

	shape.shape = box
	_area.add_child(shape)

	_area.body_entered.connect(_on_body_entered)
	_area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group(PLAYER_GROUP):
		return
	if not _has_been_entered:
		_has_been_entered = true
	room_entered.emit(_room_id, _room_tag, _room_biome)
	_emit_eventbus_room_entered()
	if FADE_DURATION_BY_TAG.has(_room_tag):
		_request_room_fade_in(FADE_DURATION_BY_TAG[_room_tag])


func _on_body_exited(body: Node3D) -> void:
	if not body.is_in_group(PLAYER_GROUP):
		return
	room_exited.emit(_room_id)
	_emit_eventbus_room_exited()


func _emit_eventbus_room_entered() -> void:
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("dungeon_room_entered"):
			bus.emit_signal("dungeon_room_entered", _room_id, _room_tag, _room_biome)


func _emit_eventbus_room_exited() -> void:
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("dungeon_room_exited"):
			bus.emit_signal("dungeon_room_exited", _room_id)


func _request_room_fade_in(duration: float) -> void:
	if has_node("/root/CutsceneController"):
		var cc: Node = get_node("/root/CutsceneController")
		if cc.has_method("play_room_fade"):
			cc.call("play_room_fade", duration)
