class_name BossAttackTelegraph
extends Node3D

## Attack telegraph VFX system for the Compiler boss (Epic 07 task 34).
## Spawns floor-projected attack zone indicators that pulse from white →
## red over the boss's windup duration so the player has clear advance
## warning of every incoming attack.
##
## Telegraph types:
##   CIRCLE       — ground slam (single 4m circle directly in front)
##   CONE         — sweep beam (180deg cone fanning from boss)
##   SCATTERED    — multi-projectile barrage (3-6 small zones at random)
##   LINE         — chase laser (long thin rectangle along beam path)
##   FULL_ARENA   — phase 3 ultimate (concentric circles, only safe spots
##                  are marked in green)
##
## Behavior:
##   1) On show_telegraph(type, params, duration), spawns the matching
##      decal projector(s) at the right position
##   2) Animates the decal modulate from white→yellow→red over the
##      windup duration (final 0.3s pulses brighter to communicate
##      imminent fire)
##   3) On done() or after duration, fades out and frees
##
## Required scene shape:
##   BossAttackTelegraph (Node3D + this script)
##     [decals spawned dynamically per call]
##
## Hookup from boss attack state:
##   var tele: BossAttackTelegraph = preload("res://scenes/effects/boss_attack_telegraph.tscn").instantiate()
##   add_child(tele)
##   tele.show_circle(impact_world_pos, radius_m=4.0, windup_s=4.0)
##
## All telegraph decals are spawned as children so when this node is
## freed, every active telegraph dies with it (good for boss death).

enum TelegraphType {
	CIRCLE,
	CONE,
	SCATTERED,
	LINE,
	FULL_ARENA,
}

@export var telegraph_height_m: float = 0.05
@export var safe_zone_color: Color = Color(0.05, 0.95, 0.10, 0.85)

const TELEGRAPH_TEXTURE_CIRCLE: String = "res://assets/textures/vfx/telegraph_circle.png"
const TELEGRAPH_TEXTURE_CONE: String = "res://assets/textures/vfx/telegraph_cone.png"
const TELEGRAPH_TEXTURE_LINE: String = "res://assets/textures/vfx/telegraph_line.png"

var _active_decals: Array[Decal] = []


func show_circle(world_pos: Vector3, radius_m: float, windup_s: float) -> void:
	var d: Decal = _make_decal(world_pos, radius_m * 2.0, radius_m * 2.0, TELEGRAPH_TEXTURE_CIRCLE)
	_animate_telegraph(d, windup_s)


func show_cone(boss_world_pos: Vector3, facing: Vector3, length_m: float, half_angle_deg: float, windup_s: float) -> void:
	# Position the cone decal so it extends from the boss outward
	var center: Vector3 = boss_world_pos + facing.normalized() * (length_m * 0.5)
	var width: float = 2.0 * length_m * tan(deg_to_rad(half_angle_deg))
	var d: Decal = _make_decal(center, width, length_m, TELEGRAPH_TEXTURE_CONE)
	# Orient the decal to face the boss's forward
	var look_dir: Vector3 = facing.normalized()
	d.look_at(d.global_position + look_dir, Vector3.UP)
	d.rotate_object_local(Vector3.RIGHT, deg_to_rad(90.0))
	_animate_telegraph(d, windup_s)


func show_scattered(zones: Array, radius_m: float, windup_s: float) -> void:
	## zones: Array[Vector3] of world positions
	for pos in zones:
		var d: Decal = _make_decal(pos, radius_m * 2.0, radius_m * 2.0, TELEGRAPH_TEXTURE_CIRCLE)
		_animate_telegraph(d, windup_s)


func show_line(start_world: Vector3, end_world: Vector3, width_m: float, windup_s: float) -> void:
	var center: Vector3 = (start_world + end_world) * 0.5
	var length: float = start_world.distance_to(end_world)
	var d: Decal = _make_decal(center, width_m, length, TELEGRAPH_TEXTURE_LINE)
	# Orient along start→end
	var direction: Vector3 = (end_world - start_world).normalized()
	d.look_at(d.global_position + direction, Vector3.UP)
	d.rotate_object_local(Vector3.RIGHT, deg_to_rad(90.0))
	_animate_telegraph(d, windup_s)


func show_full_arena_safe_zones(safe_positions: Array, safe_radius_m: float, windup_s: float) -> void:
	## Phase 3 ultimate — only the safe spots are marked. The rest of the
	## arena is implicitly damage. Inverted color: green safe zones.
	for pos in safe_positions:
		var d: Decal = _make_decal(pos, safe_radius_m * 2.0, safe_radius_m * 2.0, TELEGRAPH_TEXTURE_CIRCLE)
		d.modulate = safe_zone_color
		_animate_safe_zone(d, windup_s)


func clear_all() -> void:
	for d in _active_decals:
		if is_instance_valid(d):
			d.queue_free()
	_active_decals.clear()


func _make_decal(world_pos: Vector3, size_x: float, size_z: float, tex_path: String) -> Decal:
	var d: Decal = Decal.new()
	d.size = Vector3(size_x, 4.0, size_z)
	d.upper_fade = 0.4
	d.lower_fade = 0.4
	d.modulate = Color(1, 1, 1, 0.0)
	d.albedo_mix = 1.0
	if ResourceLoader.exists(tex_path):
		d.texture_albedo = load(tex_path)
	add_child(d)
	d.global_position = Vector3(world_pos.x, world_pos.y + telegraph_height_m, world_pos.z)
	_active_decals.append(d)
	return d


func _animate_telegraph(d: Decal, windup_s: float) -> void:
	# Fade in (0.2s) → hold yellow → ramp red (final 30%) → bright pulse (final 0.3s) → free
	var tw: Tween = create_tween()
	tw.tween_property(d, "modulate", Color(1, 1, 1, 0.65), 0.2)
	var hold_dur: float = max(0.0, windup_s * 0.50 - 0.2)
	tw.tween_interval(hold_dur)
	tw.tween_property(d, "modulate", Color(1, 0.85, 0.15, 0.80), windup_s * 0.20)
	tw.tween_property(d, "modulate", Color(1, 0.20, 0.10, 0.95), windup_s * 0.30)
	# Final pulse: brighten then go
	tw.tween_property(d, "modulate", Color(1, 0.05, 0.05, 1.0), 0.15)
	tw.tween_property(d, "modulate", Color(1, 0.05, 0.05, 0.0), 0.20)
	tw.tween_callback(d.queue_free)


func _animate_safe_zone(d: Decal, windup_s: float) -> void:
	# Safe zones stay green, gentle pulse
	var tw: Tween = create_tween().set_loops(int(windup_s / 0.6))
	tw.tween_property(d, "modulate:a", 0.95, 0.3)
	tw.tween_property(d, "modulate:a", 0.55, 0.3)
	# Final fade out
	var fade_tw: Tween = create_tween()
	fade_tw.tween_interval(windup_s)
	fade_tw.tween_property(d, "modulate:a", 0.0, 0.3)
	fade_tw.tween_callback(d.queue_free)
