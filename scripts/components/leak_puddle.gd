class_name LeakPuddle
extends Node3D

## A spreading ground puddle anchored under the MemoryLeak (or any "leaking"
## enemy). Distinct from InfestedDecal (which scans clusters and grows with
## headcount): this one is per-enemy, grows over TIME while the enemy is
## stationary, and shrinks when the enemy moves.
##
## Visual: a Decal projector with the variant's puddle color. Grows from
## min_radius to max_radius over grow_time_s when the parent doesn't move,
## and shrinks back to min_radius over shrink_time_s when the parent does
## move (the puddle "drags" with the body).
##
## When the parent dies, the puddle PERSISTS at full size for hazard_lifetime_s
## as a damaging hazard (per Epic 05 task 40), then fades. The hazard layer
## is implemented via the optional `damage_radius_m` and `damage_per_tick`
## fields — when set, the puddle pings nearby actors in the player group
## with damage at tick_interval_s intervals.
##
## Required scene shape:
##   LeakPuddle (Node3D + this script)
##     [Decal added at runtime]
##
## Configure via inspector:
##   parent_path           — the leaking enemy (defaults to get_parent())
##   movement_threshold_m  — distance the parent must move per frame to count
##                            as "moving" (default 0.05)
##   grow_time_s           — time to grow from min to max radius (default 6s)
##   shrink_time_s         — time to shrink from max to min when moving (default 2s)
##   min_radius_m / max_radius_m
##   puddle_color          — base modulate (default sickly green for MemoryLeak)
##   hazard_lifetime_s     — how long the death hazard persists
##   damage_per_tick / tick_interval_s — damage hazard tunables (0 = visual only)

@export var parent_path: NodePath
@export_range(0.0, 1.0) var movement_threshold_m: float = 0.05
@export_range(0.5, 30.0) var grow_time_s: float = 6.0
@export_range(0.5, 10.0) var shrink_time_s: float = 2.0
@export_range(0.1, 4.0) var min_radius_m: float = 0.4
@export_range(0.5, 8.0) var max_radius_m: float = 2.4
@export var puddle_color: Color = Color(0.20, 0.55, 0.10, 1.0)
@export_range(0.0, 60.0) var hazard_lifetime_s: float = 12.0
@export_range(0.0, 100.0) var damage_per_tick: float = 0.0
@export_range(0.05, 2.0) var tick_interval_s: float = 0.5
@export_range(0.0, 8.0) var damage_radius_m: float = 0.0
@export var damage_target_group: StringName = &"player"
@export var puddle_texture_path: String = ""

var _decal: Decal
var _parent: Node3D
var _current_radius: float = 0.0
var _last_parent_pos: Vector3
var _is_moving: bool = false
var _enemy_dead: bool = false
var _hazard_active: bool = false
var _hazard_timer: float = 0.0
var _tick_accum: float = 0.0


func _ready() -> void:
	_parent = get_node_or_null(parent_path) as Node3D
	if _parent == null:
		_parent = get_parent() as Node3D
	if _parent != null:
		_last_parent_pos = _parent.global_position

	_build_decal()

	# Listen for the parent's death so we know when to convert into a hazard
	if _parent != null:
		# Look for any HealthComponent sibling
		for child: Node in _parent.get_children():
			if child.has_signal("died"):
				child.died.connect(_on_parent_died)
				break

	_current_radius = min_radius_m
	_apply_to_decal()


func _build_decal() -> void:
	_decal = Decal.new()
	_decal.name = "LeakPuddleDecal"
	var diameter: float = min_radius_m * 2.0
	_decal.size = Vector3(diameter, 2.0, diameter)
	_decal.modulate = Color(puddle_color.r, puddle_color.g, puddle_color.b, 0.7)
	_decal.emission_energy = 0.4
	_decal.albedo_mix = 0.85

	if puddle_texture_path != "" and ResourceLoader.exists(puddle_texture_path):
		var tex: Texture2D = load(puddle_texture_path) as Texture2D
		if tex != null:
			_decal.texture_albedo = tex
			_decal.texture_emission = tex

	add_child(_decal)


func _process(delta: float) -> void:
	if _enemy_dead:
		_process_hazard(delta)
		return

	if _parent == null or not is_instance_valid(_parent):
		return

	# Track the puddle to the parent's position so it stays under the body
	global_position = Vector3(_parent.global_position.x, global_position.y, _parent.global_position.z)

	# Detect movement by comparing to last frame's position
	var moved: float = _last_parent_pos.distance_to(_parent.global_position)
	_is_moving = moved >= movement_threshold_m
	_last_parent_pos = _parent.global_position

	# Grow when stationary, shrink when moving
	if _is_moving:
		var shrink_step: float = (max_radius_m - min_radius_m) / shrink_time_s
		_current_radius = maxf(_current_radius - shrink_step * delta, min_radius_m)
	else:
		var grow_step: float = (max_radius_m - min_radius_m) / grow_time_s
		_current_radius = minf(_current_radius + grow_step * delta, max_radius_m)

	_apply_to_decal()


func _process_hazard(delta: float) -> void:
	# After death the puddle stays at max size, slowly fading over hazard_lifetime_s
	_hazard_timer += delta
	var t: float = clampf(_hazard_timer / hazard_lifetime_s, 0.0, 1.0)

	# Hold full opacity for the first 60% of lifetime, then fade
	var alpha: float = 1.0
	if t > 0.6:
		alpha = 1.0 - ((t - 0.6) / 0.4)

	_decal.modulate = Color(puddle_color.r, puddle_color.g, puddle_color.b, alpha * 0.85)
	_decal.emission_energy = alpha * 0.6

	# Damage tick on actors in range
	if damage_per_tick > 0.0 and damage_radius_m > 0.0:
		_tick_accum += delta
		if _tick_accum >= tick_interval_s:
			_tick_accum = 0.0
			_damage_actors_in_range()

	if _hazard_timer >= hazard_lifetime_s:
		queue_free()


func _damage_actors_in_range() -> void:
	var tree: SceneTree = get_tree()
	if tree == null:
		return
	var origin: Vector3 = global_position
	for actor: Node in tree.get_nodes_in_group(damage_target_group):
		if not (actor is Node3D):
			continue
		var actor3d: Node3D = actor as Node3D
		if origin.distance_to(actor3d.global_position) <= damage_radius_m:
			# Look for a HealthComponent on the actor and apply damage
			for child: Node in actor.get_children():
				if child.has_method("take_damage"):
					child.call("take_damage", damage_per_tick, &"hazard_leak")
					break


func _on_parent_died() -> void:
	_enemy_dead = true
	# Snap to max radius for the death hazard moment
	_current_radius = max_radius_m
	_apply_to_decal()
	# Reparent to the world so the puddle survives the parent's queue_free
	# This must happen via call_deferred so we don't reparent during signal emit
	call_deferred("_reparent_to_world")


func _reparent_to_world() -> void:
	if not is_inside_tree():
		return
	var world: Node = get_tree().current_scene
	if world == null:
		return
	var world_pos: Vector3 = global_position
	if get_parent() != null:
		get_parent().remove_child(self)
	world.add_child(self)
	global_position = world_pos


func _apply_to_decal() -> void:
	if _decal == null:
		return
	var diameter: float = _current_radius * 2.0
	_decal.size = Vector3(diameter, _decal.size.y, diameter)
