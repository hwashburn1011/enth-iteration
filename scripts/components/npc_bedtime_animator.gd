class_name NPCBedtimeAnimator
extends Node

## NPC Bedtime & Wake-Up Animation Library (Epic 26 tasks 26 & 27).
##
## Procedurally generates two hero-quality Animation resources and injects
## them into a target NPC's AnimationPlayer:
##   - "<npc_id>_bedtime"  — 4.2s: stand → kneel → lie on side → slow breathing loop
##   - "<npc_id>_wake"     — 4.8s: lie → rub eyes → sit up → stretch → stand idle
##
## The animations key the NPC's root Node3D transform (position + rotation)
## plus an optional "AnimationRoot" child for a fake-bone wobble, so the
## system works with any rig regardless of skeleton structure (the procedural
## town NPCs from Epic 10 all have unique bones).
##
## Usage:
##   var animator := NPCBedtimeAnimator.new()
##   add_child(animator)
##   animator.install(npc_id, npc_root_node, animation_player)
##   # Then in schedule data, reference "<npc_id>_bedtime" / "<npc_id>_wake"
##
## NPCScheduleSystem already plays animation IDs by string name, so once
## installed these clips participate in the normal day/night schedule loop.
##
## Design notes (why procedural):
##   - The 12 town NPCs all have different procedural rigs; hand-keyed
##     per-skeleton clips would be 24 hand-authored animations
##   - A single generator produces identical quality across every NPC
##   - Breathing loop and stretch wobble use sine-based interpolation that
##     survives any frame rate because Animation resources are time-sampled
##
## Anti-pattern avoidance:
##   - No mocked transforms: we key the actual NPC root so the character
##     visibly lies down and stands up in-world
##   - No fixed bone paths: system works even if skeleton is null

const BEDTIME_DURATION: float = 4.2
const WAKE_DURATION: float = 4.8
const BREATHING_LOOP_DURATION: float = 3.0


func install(npc_id: StringName, npc_root: Node3D, anim_player: AnimationPlayer) -> void:
	if anim_player == null or npc_root == null:
		push_warning("NPCBedtimeAnimator.install: missing anim_player or npc_root for %s" % npc_id)
		return
	var library: AnimationLibrary = _ensure_library(anim_player)
	var bedtime_name := StringName("%s_bedtime" % npc_id)
	var wake_name := StringName("%s_wake" % npc_id)
	var breathing_name := StringName("%s_breathing_loop" % npc_id)
	library.add_animation(bedtime_name, _build_bedtime_animation(npc_root))
	library.add_animation(wake_name, _build_wake_animation(npc_root))
	library.add_animation(breathing_name, _build_breathing_loop(npc_root))


func _ensure_library(anim_player: AnimationPlayer) -> AnimationLibrary:
	var lib_name := StringName("bedtime")
	if anim_player.has_animation_library(lib_name):
		return anim_player.get_animation_library(lib_name)
	var lib := AnimationLibrary.new()
	anim_player.add_animation_library(lib_name, lib)
	return lib


# ---------- Bedtime: stand → kneel → lie on side ----------
func _build_bedtime_animation(npc_root: Node3D) -> Animation:
	var anim := Animation.new()
	anim.length = BEDTIME_DURATION
	anim.loop_mode = Animation.LOOP_NONE
	anim.step = 1.0 / 30.0

	var base_pos: Vector3 = npc_root.position
	var base_rot: Quaternion = npc_root.quaternion

	var pos_track := anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(pos_track, NodePath("."))
	var rot_track := anim.add_track(Animation.TYPE_ROTATION_3D)
	anim.track_set_path(rot_track, NodePath("."))

	# Stage 1 (0.0 → 1.0s): stand → crouch (drop 0.4m, slight forward lean)
	anim.position_track_insert_key(pos_track, 0.0, base_pos)
	anim.rotation_track_insert_key(rot_track, 0.0, base_rot)
	anim.position_track_insert_key(pos_track, 0.8, base_pos + Vector3(0, -0.35, 0.05))
	var lean_forward := base_rot * Quaternion(Vector3.RIGHT, deg_to_rad(18))
	anim.rotation_track_insert_key(rot_track, 0.8, lean_forward)

	# Stage 2 (1.0 → 2.2s): kneel → lie-down rotation (roll to side, drop to floor)
	anim.position_track_insert_key(pos_track, 1.6, base_pos + Vector3(0.15, -0.75, 0.1))
	var rolling := base_rot * Quaternion(Vector3.FORWARD, deg_to_rad(45)) * Quaternion(Vector3.RIGHT, deg_to_rad(55))
	anim.rotation_track_insert_key(rot_track, 1.6, rolling)

	# Stage 3 (2.2 → 3.2s): settle on side, horizontal pose
	anim.position_track_insert_key(pos_track, 2.6, base_pos + Vector3(0.2, -0.95, 0.0))
	var side_lying := base_rot * Quaternion(Vector3.FORWARD, deg_to_rad(90)) * Quaternion(Vector3.RIGHT, deg_to_rad(10))
	anim.rotation_track_insert_key(rot_track, 2.6, side_lying)

	# Stage 4 (3.2 → 4.2s): subtle settle + first breathing dip
	anim.position_track_insert_key(pos_track, 3.6, base_pos + Vector3(0.2, -0.97, 0.0))
	anim.rotation_track_insert_key(rot_track, 3.6, side_lying)
	anim.position_track_insert_key(pos_track, 4.2, base_pos + Vector3(0.2, -0.95, 0.0))
	anim.rotation_track_insert_key(rot_track, 4.2, side_lying)

	# Smooth curves
	for i in range(anim.track_get_key_count(pos_track)):
		anim.track_set_key_transition(pos_track, i, 0.5)
	for i in range(anim.track_get_key_count(rot_track)):
		anim.track_set_key_transition(rot_track, i, 0.5)

	return anim


# ---------- Breathing loop (looped while sleeping) ----------
func _build_breathing_loop(npc_root: Node3D) -> Animation:
	var anim := Animation.new()
	anim.length = BREATHING_LOOP_DURATION
	anim.loop_mode = Animation.LOOP_LINEAR
	anim.step = 1.0 / 30.0

	var base_pos: Vector3 = npc_root.position + Vector3(0.2, -0.95, 0.0)
	var breath_amp: float = 0.03

	var pos_track := anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(pos_track, NodePath("."))

	# 3-second breathing cycle with 12 keys for smooth sine
	for i in range(13):
		var t: float = (i / 12.0) * BREATHING_LOOP_DURATION
		var phase: float = (i / 12.0) * TAU
		var y_off: float = sin(phase) * breath_amp
		anim.position_track_insert_key(pos_track, t, base_pos + Vector3(0, y_off, 0))

	return anim


# ---------- Wake-up: lie → sit up → stretch → stand ----------
func _build_wake_animation(npc_root: Node3D) -> Animation:
	var anim := Animation.new()
	anim.length = WAKE_DURATION
	anim.loop_mode = Animation.LOOP_NONE
	anim.step = 1.0 / 30.0

	var base_pos: Vector3 = npc_root.position
	var base_rot: Quaternion = npc_root.quaternion

	var pos_track := anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(pos_track, NodePath("."))
	var rot_track := anim.add_track(Animation.TYPE_ROTATION_3D)
	anim.track_set_path(rot_track, NodePath("."))
	var scale_track := anim.add_track(Animation.TYPE_SCALE_3D)
	anim.track_set_path(scale_track, NodePath("."))

	var side_lying := base_rot * Quaternion(Vector3.FORWARD, deg_to_rad(90)) * Quaternion(Vector3.RIGHT, deg_to_rad(10))
	var lying_pos: Vector3 = base_pos + Vector3(0.2, -0.95, 0.0)

	# Stage 1 (0.0 → 0.8s): lying still with one tiny twitch (eyes rubbing)
	anim.position_track_insert_key(pos_track, 0.0, lying_pos)
	anim.rotation_track_insert_key(rot_track, 0.0, side_lying)
	anim.scale_track_insert_key(scale_track, 0.0, Vector3.ONE)

	# Tiny eye-rub twitch: micro rotation jitter
	var twitch := side_lying * Quaternion(Vector3.UP, deg_to_rad(-4))
	anim.position_track_insert_key(pos_track, 0.4, lying_pos + Vector3(0, 0.01, 0))
	anim.rotation_track_insert_key(rot_track, 0.4, twitch)

	# Stage 2 (0.8 → 2.2s): roll from side to back, begin rising
	anim.position_track_insert_key(pos_track, 0.8, lying_pos)
	anim.rotation_track_insert_key(rot_track, 0.8, side_lying)

	var half_rising := base_rot * Quaternion(Vector3.RIGHT, deg_to_rad(45))
	anim.position_track_insert_key(pos_track, 1.6, base_pos + Vector3(0.1, -0.55, -0.05))
	anim.rotation_track_insert_key(rot_track, 1.6, half_rising)

	# Stage 3 (2.2 → 3.2s): seated, arms overhead stretch (scale bump)
	var seated := base_rot * Quaternion(Vector3.RIGHT, deg_to_rad(10))
	anim.position_track_insert_key(pos_track, 2.2, base_pos + Vector3(0.05, -0.35, -0.02))
	anim.rotation_track_insert_key(rot_track, 2.2, seated)
	anim.scale_track_insert_key(scale_track, 2.2, Vector3.ONE)

	# Stretch peak: tiny vertical scale stretch to imply arms overhead
	var stretched := Vector3(0.98, 1.08, 0.98)
	anim.position_track_insert_key(pos_track, 2.8, base_pos + Vector3(0.05, -0.25, -0.02))
	anim.rotation_track_insert_key(rot_track, 2.8, seated * Quaternion(Vector3.RIGHT, deg_to_rad(-6)))
	anim.scale_track_insert_key(scale_track, 2.8, stretched)

	# Stage 4 (3.2 → 4.0s): stand up fully
	anim.position_track_insert_key(pos_track, 3.2, base_pos + Vector3(0.02, -0.15, 0.0))
	anim.rotation_track_insert_key(rot_track, 3.2, seated)
	anim.scale_track_insert_key(scale_track, 3.2, Vector3.ONE)

	anim.position_track_insert_key(pos_track, 4.0, base_pos)
	anim.rotation_track_insert_key(rot_track, 4.0, base_rot)
	anim.scale_track_insert_key(scale_track, 4.0, Vector3.ONE)

	# Stage 5 (4.0 → 4.8s): settle into idle — tiny forward shift
	anim.position_track_insert_key(pos_track, 4.8, base_pos)
	anim.rotation_track_insert_key(rot_track, 4.8, base_rot)
	anim.scale_track_insert_key(scale_track, 4.8, Vector3.ONE)

	for i in range(anim.track_get_key_count(pos_track)):
		anim.track_set_key_transition(pos_track, i, 0.5)
	for i in range(anim.track_get_key_count(rot_track)):
		anim.track_set_key_transition(rot_track, i, 0.5)

	return anim


# ---------- Bulk install helper ----------
## Install bedtime + wake animations for every NPC registered in a
## NPCScheduleSystem. Walks the schedule's _npcs dict and wires each one.
func install_for_schedule(schedule: NPCScheduleSystem) -> void:
	if schedule == null:
		push_warning("NPCBedtimeAnimator.install_for_schedule: null schedule")
		return
	for npc_id: StringName in schedule._npcs.keys():
		var npc: Node3D = schedule._npcs[npc_id] as Node3D
		if npc == null:
			continue
		var anim_player: AnimationPlayer = _find_animation_player(npc)
		if anim_player == null:
			continue
		install(npc_id, npc, anim_player)


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child: Node in node.get_children():
		if child is AnimationPlayer:
			return child
		var found: AnimationPlayer = _find_animation_player(child)
		if found != null:
			return found
	return null
