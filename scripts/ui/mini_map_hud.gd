class_name MiniMapHUD
extends Control

## Top-right mini-map widget. Shows the player's current position, nearby
## markers, enemy radar, interactable highlights, and an arrow pointing to
## the active waypoint (if any).

@export var player_path: NodePath
@export var radius_meters: float = 50.0
@export var update_interval: float = 0.2

@onready var _player_marker: ColorRect = %PlayerMarker
@onready var _markers_layer: Control = %MarkersLayer
@onready var _waypoint_arrow: TextureRect = %WaypointArrow
@onready var _north_indicator: Label = %NorthIndicator

var _player: Node3D
var _update_timer: float = 0.0
var _enemy_dots: Array[ColorRect] = []
var _interactable_dots: Array[ColorRect] = []


func _ready() -> void:
	_player = get_node_or_null(player_path) as Node3D


func _process(delta: float) -> void:
	_update_timer += delta
	if _update_timer < update_interval:
		return
	_update_timer = 0.0
	_refresh()


func _refresh() -> void:
	if _player == null:
		return
	# Update enemy radar
	_update_enemy_radar()
	# Update interactables
	_update_interactables()
	# Update waypoint arrow
	_update_waypoint_arrow()


func _update_enemy_radar() -> void:
	# Clear existing dots
	for d in _enemy_dots:
		d.queue_free()
	_enemy_dots.clear()
	if _markers_layer == null:
		return
	# Find enemies in range
	var enemies: Array[Node] = get_tree().get_nodes_in_group(&"enemy") if get_tree() != null else []
	var center: Vector3 = _player.global_position
	for enemy in enemies:
		if not (enemy is Node3D):
			continue
		var dist: float = center.distance_to((enemy as Node3D).global_position)
		if dist > radius_meters:
			continue
		var dot: ColorRect = ColorRect.new()
		dot.color = Color(0.95, 0.20, 0.20, 0.85)
		dot.size = Vector2(4, 4)
		dot.position = _world_to_minimap(center, (enemy as Node3D).global_position)
		_markers_layer.add_child(dot)
		_enemy_dots.append(dot)


func _update_interactables() -> void:
	# Clear existing dots
	for d in _interactable_dots:
		d.queue_free()
	_interactable_dots.clear()
	if _markers_layer == null:
		return
	var inters: Array[Node] = get_tree().get_nodes_in_group(&"interactable") if get_tree() != null else []
	var center: Vector3 = _player.global_position
	for inter in inters:
		if not (inter is Node3D):
			continue
		var dist: float = center.distance_to((inter as Node3D).global_position)
		if dist > radius_meters:
			continue
		var dot: ColorRect = ColorRect.new()
		dot.color = Color(0.95, 0.85, 0.20, 0.75)
		dot.size = Vector2(3, 3)
		dot.position = _world_to_minimap(center, (inter as Node3D).global_position)
		_markers_layer.add_child(dot)
		_interactable_dots.append(dot)


func _update_waypoint_arrow() -> void:
	if _waypoint_arrow == null:
		return
	if not has_node("/root/WorldMapManager"):
		return
	var wmm: Node = get_node("/root/WorldMapManager")
	if not wmm.waypoint_active:
		_waypoint_arrow.visible = false
		return
	_waypoint_arrow.visible = true
	# Compute angle from player to waypoint
	var center: Vector2 = Vector2(_player.global_position.x, _player.global_position.z)
	var wp: Vector2 = wmm.waypoint_position
	var dir: Vector2 = (wp - center).normalized()
	_waypoint_arrow.rotation = dir.angle()


func _world_to_minimap(player_pos: Vector3, target_pos: Vector3) -> Vector2:
	var size: Vector2 = self.size
	var center: Vector2 = size * 0.5
	var dx: float = target_pos.x - player_pos.x
	var dz: float = target_pos.z - player_pos.z
	var scale: float = (size.x * 0.5) / radius_meters
	return center + Vector2(dx * scale, dz * scale) - Vector2(2, 2)
