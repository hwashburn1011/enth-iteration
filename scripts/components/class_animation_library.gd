class_name ClassAnimationLibrary
extends Node

## Class Animation Library (Epic 31 tasks 23, 24, 25, 37).
##
## Procedurally generates class signature, ultimate, death, and polish-VFX
## animations and injects them into the player's AnimationPlayer at runtime.
##
## Each clip animates the player root transform (position + rotation + scale)
## so it works regardless of skeleton — same approach as NPCBedtimeAnimator.
##
## Generated clips per class:
##   - <class>_signature   (1.4s — windup → strike → recover)
##   - <class>_ultimate    (3.6s — charge → release → settle)
##   - <class>_death       (1.8s — stagger → fall → rest)
##   - <class>_levelup_vfx (1.2s — pulse + slow rise)
##
## Each class gets uniquely-tuned curves: Compiler is precise & balanced,
## Daemon is fast & sharp, Kernel is slow & weighty.
##
## Hook:
##   var lib := ClassAnimationLibrary.new()
##   add_child(lib)
##   lib.install_class(&"daemon", player_root, anim_player)

const LIBRARY_NAME: StringName = &"class_anims"


func install_class(class_id: StringName, player_root: Node3D, anim_player: AnimationPlayer) -> void:
	if anim_player == null or player_root == null:
		push_warning("ClassAnimationLibrary.install_class: missing args for %s" % class_id)
		return
	var library: AnimationLibrary = _ensure_library(anim_player)
	library.add_animation(StringName("%s_signature" % class_id), _build_signature(class_id, player_root))
	library.add_animation(StringName("%s_ultimate" % class_id), _build_ultimate(class_id, player_root))
	library.add_animation(StringName("%s_death" % class_id), _build_death(class_id, player_root))
	library.add_animation(StringName("%s_levelup_vfx" % class_id), _build_levelup(class_id, player_root))


func _ensure_library(anim_player: AnimationPlayer) -> AnimationLibrary:
	if anim_player.has_animation_library(LIBRARY_NAME):
		return anim_player.get_animation_library(LIBRARY_NAME)
	var lib := AnimationLibrary.new()
	anim_player.add_animation_library(LIBRARY_NAME, lib)
	return lib


# === Class style profiles ===
func _profile(class_id: StringName) -> Dictionary:
	match class_id:
		&"compiler":
			return {
				"sig_speed": 1.0, "sig_lunge": 0.8, "sig_recover": 0.4,
				"ult_charge": 1.4, "ult_release_amp": 1.2,
				"death_fall_speed": 1.0, "death_lean": 25.0,
				"vfx_pulse": 1.1,
			}
		&"daemon":
			return {
				"sig_speed": 0.8, "sig_lunge": 1.4, "sig_recover": 0.3,
				"ult_charge": 1.0, "ult_release_amp": 1.6,
				"death_fall_speed": 0.7, "death_lean": 35.0,
				"vfx_pulse": 1.4,
			}
		&"kernel":
			return {
				"sig_speed": 1.4, "sig_lunge": 0.4, "sig_recover": 0.6,
				"ult_charge": 1.8, "ult_release_amp": 0.9,
				"death_fall_speed": 1.5, "death_lean": 18.0,
				"vfx_pulse": 0.9,
			}
	return {
		"sig_speed": 1.0, "sig_lunge": 1.0, "sig_recover": 0.5,
		"ult_charge": 1.5, "ult_release_amp": 1.2,
		"death_fall_speed": 1.0, "death_lean": 25.0,
		"vfx_pulse": 1.0,
	}


# === Signature: windup → strike → recover ===
func _build_signature(class_id: StringName, root: Node3D) -> Animation:
	var p: Dictionary = _profile(class_id)
	var anim := Animation.new()
	anim.length = 1.4 * p["sig_speed"]
	anim.loop_mode = Animation.LOOP_NONE
	anim.step = 1.0 / 60.0

	var base_pos: Vector3 = root.position
	var base_rot: Quaternion = root.quaternion

	var pt := anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(pt, NodePath("."))
	var rt := anim.add_track(Animation.TYPE_ROTATION_3D)
	anim.track_set_path(rt, NodePath("."))

	# Windup (lean back)
	anim.position_track_insert_key(pt, 0.0, base_pos)
	anim.rotation_track_insert_key(rt, 0.0, base_rot)
	anim.position_track_insert_key(pt, 0.35 * p["sig_speed"], base_pos + Vector3(0, 0, -0.15))
	anim.rotation_track_insert_key(rt, 0.35 * p["sig_speed"],
		base_rot * Quaternion(Vector3.RIGHT, deg_to_rad(-12)))

	# Strike (lunge forward)
	anim.position_track_insert_key(pt, 0.7 * p["sig_speed"],
		base_pos + Vector3(0, -0.4 * p["sig_lunge"], 0.0))
	anim.rotation_track_insert_key(rt, 0.7 * p["sig_speed"],
		base_rot * Quaternion(Vector3.RIGHT, deg_to_rad(15)))

	# Recover (return)
	anim.position_track_insert_key(pt, 1.4 * p["sig_speed"], base_pos)
	anim.rotation_track_insert_key(rt, 1.4 * p["sig_speed"], base_rot)

	for i in range(anim.track_get_key_count(pt)):
		anim.track_set_key_transition(pt, i, 0.5)
	for i in range(anim.track_get_key_count(rt)):
		anim.track_set_key_transition(rt, i, 0.5)
	return anim


# === Ultimate: charge → release → settle ===
func _build_ultimate(class_id: StringName, root: Node3D) -> Animation:
	var p: Dictionary = _profile(class_id)
	var anim := Animation.new()
	anim.length = 3.6
	anim.loop_mode = Animation.LOOP_NONE
	anim.step = 1.0 / 60.0

	var base_pos: Vector3 = root.position
	var base_rot: Quaternion = root.quaternion

	var pt := anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(pt, NodePath("."))
	var rt := anim.add_track(Animation.TYPE_ROTATION_3D)
	anim.track_set_path(rt, NodePath("."))
	var st := anim.add_track(Animation.TYPE_SCALE_3D)
	anim.track_set_path(st, NodePath("."))

	# Charge (slowly rise + grow)
	anim.position_track_insert_key(pt, 0.0, base_pos)
	anim.rotation_track_insert_key(rt, 0.0, base_rot)
	anim.scale_track_insert_key(st, 0.0, Vector3.ONE)

	var charge_t: float = p["ult_charge"]
	anim.position_track_insert_key(pt, charge_t, base_pos + Vector3(0, 0, 0.3))
	anim.rotation_track_insert_key(rt, charge_t,
		base_rot * Quaternion(Vector3.UP, deg_to_rad(-90)))
	anim.scale_track_insert_key(st, charge_t, Vector3(1.05, 1.10, 1.05))

	# Release (rapid pulse + spin)
	var release_t: float = charge_t + 0.4
	var amp: float = p["ult_release_amp"]
	anim.position_track_insert_key(pt, release_t, base_pos + Vector3(0, 0, 0.5))
	anim.rotation_track_insert_key(rt, release_t,
		base_rot * Quaternion(Vector3.UP, deg_to_rad(180)))
	anim.scale_track_insert_key(st, release_t, Vector3(1.2 * amp, 1.3 * amp, 1.2 * amp))

	# Mid-release flash
	anim.position_track_insert_key(pt, release_t + 0.4, base_pos + Vector3(0, 0, 0.4))
	anim.rotation_track_insert_key(rt, release_t + 0.4,
		base_rot * Quaternion(Vector3.UP, deg_to_rad(360)))
	anim.scale_track_insert_key(st, release_t + 0.4, Vector3.ONE)

	# Settle
	anim.position_track_insert_key(pt, 3.6, base_pos)
	anim.rotation_track_insert_key(rt, 3.6, base_rot)
	anim.scale_track_insert_key(st, 3.6, Vector3.ONE)

	for i in range(anim.track_get_key_count(pt)):
		anim.track_set_key_transition(pt, i, 0.5)
	return anim


# === Death: stagger → fall → rest ===
func _build_death(class_id: StringName, root: Node3D) -> Animation:
	var p: Dictionary = _profile(class_id)
	var anim := Animation.new()
	anim.length = 1.8
	anim.loop_mode = Animation.LOOP_NONE
	anim.step = 1.0 / 60.0

	var base_pos: Vector3 = root.position
	var base_rot: Quaternion = root.quaternion

	var pt := anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(pt, NodePath("."))
	var rt := anim.add_track(Animation.TYPE_ROTATION_3D)
	anim.track_set_path(rt, NodePath("."))

	anim.position_track_insert_key(pt, 0.0, base_pos)
	anim.rotation_track_insert_key(rt, 0.0, base_rot)

	# Stagger
	anim.position_track_insert_key(pt, 0.25, base_pos + Vector3(0, 0, -0.05))
	anim.rotation_track_insert_key(rt, 0.25,
		base_rot * Quaternion(Vector3.RIGHT, deg_to_rad(p["death_lean"] * 0.3)))

	# Fall
	var fall_t: float = 1.0 * p["death_fall_speed"]
	anim.position_track_insert_key(pt, fall_t, base_pos + Vector3(0, -0.6, -0.6))
	anim.rotation_track_insert_key(rt, fall_t,
		base_rot * Quaternion(Vector3.RIGHT, deg_to_rad(p["death_lean"])) *
		Quaternion(Vector3.FORWARD, deg_to_rad(40)))

	# Rest
	anim.position_track_insert_key(pt, 1.8, base_pos + Vector3(0, -0.7, -0.7))
	anim.rotation_track_insert_key(rt, 1.8,
		base_rot * Quaternion(Vector3.FORWARD, deg_to_rad(85)))

	for i in range(anim.track_get_key_count(pt)):
		anim.track_set_key_transition(pt, i, 0.5)
	return anim


# === Level-up VFX flourish ===
func _build_levelup(class_id: StringName, root: Node3D) -> Animation:
	var p: Dictionary = _profile(class_id)
	var anim := Animation.new()
	anim.length = 1.2
	anim.loop_mode = Animation.LOOP_NONE
	anim.step = 1.0 / 60.0

	var base_pos: Vector3 = root.position
	var pt := anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(pt, NodePath("."))
	var st := anim.add_track(Animation.TYPE_SCALE_3D)
	anim.track_set_path(st, NodePath("."))

	# Pulse + rise
	for i in range(13):
		var t: float = (i / 12.0) * 1.2
		var phase: float = (i / 12.0) * TAU * p["vfx_pulse"]
		var rise: float = (i / 12.0) * 0.25
		var pulse: float = sin(phase) * 0.04
		anim.position_track_insert_key(pt, t, base_pos + Vector3(0, 0, rise))
		anim.scale_track_insert_key(st, t, Vector3.ONE * (1.0 + pulse))

	return anim
