class_name LeakTrail
extends Node

## Drops slick "footprints" along the parent enemy's movement path. Each
## footprint is a SlowZone Area3D that applies the slow effect when the
## player walks through it.
##
## Drop conditions:
##   - Parent must be a Node3D
##   - Parent has moved drop_distance_m since the last drop
##   - Or drop_interval_s has elapsed since the last drop (whichever first)
##
## When the parent dies, an optional final SlowZone is dropped at max
## radius to leave a death-puddle hazard (paired with LeakPuddle's hazard
## mode but for the trail finale).
##
## Required scene shape:
##   LeakTrail (Node + this script)
##     [SlowZone instances added to the world scene as the leak walks]
##
## Inspector configuration:
##   drop_distance_m   — minimum movement before a new drop
##   drop_interval_s   — fallback time-based drop cadence
##   slick_radius_m    — radius of each slick footprint
##   slick_lifetime_s  — how long each slick stays visible
##   slow_strength     — speed multiplier applied while standing in slick
##   slick_color       — visual color for the slicks (matches variant)
##   max_active_slicks — cap on simultaneous slicks (oldest is freed first)
##   parent_path       — Node3D to follow (default get_parent())
##   target_group      — actor group affected by the slow (default "player")

@export_range(0.1, 8.0) var drop_distance_m: float = 1.2
@export_range(0.1, 10.0) var drop_interval_s: float = 1.5
@export_range(0.3, 4.0) var slick_radius_m: float = 1.0
@export_range(0.5, 30.0) var slick_lifetime_s: float = 6.0
@export_range(0.05, 1.0) var slow_strength: float = 0.55
@export var slick_color: Color = Color(0.10, 0.45, 0.20, 0.85)
@export_range(2, 32) var max_active_slicks: int = 12
@export var parent_path: NodePath
@export var target_group: StringName = &"player"
@export var health_component_path: NodePath

var _parent: Node3D
var _last_drop_pos: Vector3
var _time_since_drop: float = 0.0
var _active_slicks: Array[SlowZone] = []
var _enabled: bool = true


func _ready() -> void:
	_parent = get_node_or_null(parent_path) as Node3D
	if _parent == null:
		_parent = get_parent() as Node3D
	if _parent != null:
		_last_drop_pos = _parent.global_position

	# Stop dropping when the leak dies (final drop is handled separately)
	var hc: Node = get_node_or_null(health_component_path)
	if hc == null and _parent != null:
		for child: Node in _parent.get_children():
			if child.has_signal("died"):
				hc = child
				break
	if hc != null and hc.has_signal("died"):
		hc.died.connect(_on_died)


func _process(delta: float) -> void:
	if not _enabled or _parent == null or not is_instance_valid(_parent):
		return

	_time_since_drop += delta
	var distance_moved: float = _last_drop_pos.distance_to(_parent.global_position)

	if distance_moved >= drop_distance_m or _time_since_drop >= drop_interval_s:
		# Don't drop if the parent hasn't moved at all — only time-based
		# drops after a real distance step
		if distance_moved >= 0.05:
			_drop_slick(_parent.global_position)
			_last_drop_pos = _parent.global_position
			_time_since_drop = 0.0


func _drop_slick(position: Vector3) -> void:
	# Cap the active slicks — free the oldest if we're at the limit
	if _active_slicks.size() >= max_active_slicks:
		var oldest: SlowZone = _active_slicks.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()

	var zone: SlowZone = SlowZone.new()
	zone.lifetime_s = slick_lifetime_s
	zone.slow_strength = slow_strength
	zone.radius_m = slick_radius_m
	zone.target_group = target_group
	zone.slick_color = slick_color
	# Slow zones live in world space, NOT under the moving parent, so they
	# stay on the ground when the parent walks away
	var world: Node = get_tree().current_scene
	if world == null:
		# Fallback — parent under the leak's grandparent
		world = get_parent().get_parent() if get_parent() != null else null
	if world == null:
		zone.queue_free()
		return
	world.add_child(zone)
	zone.global_position = position + Vector3(0, 0.05, 0)
	_active_slicks.append(zone)


func _on_died() -> void:
	_enabled = false
	# Drop one final, larger slick at the death location as the death-puddle
	# climax — the LeakPuddle component handles the visual scaling, but we
	# also drop a SlowZone here so the trail's slow continues at the death
	# spot until the puddle hazard fades
	if _parent != null:
		var final: SlowZone = SlowZone.new()
		final.lifetime_s = slick_lifetime_s * 1.5
		final.slow_strength = slow_strength
		final.radius_m = slick_radius_m * 1.6
		final.target_group = target_group
		final.slick_color = slick_color
		var world: Node = get_tree().current_scene
		if world != null:
			world.add_child(final)
			final.global_position = _parent.global_position + Vector3(0, 0.05, 0)
