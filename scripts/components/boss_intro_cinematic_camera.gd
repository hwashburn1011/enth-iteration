class_name BossIntroCinematicCamera
extends Node3D

## Boss intro cinematic camera move (Epic 07 task 36). Drives a 6.0
## second pre-fight cinematic that introduces the Compiler boss to the
## player. The camera flies through 4 keyframed positions then hands
## control back to the gameplay camera.
##
## Cinematic beats:
##   0.0s — establishing wide shot of the arena from the entrance
##   1.5s — push toward the boss base, dramatic upward angle revealing
##          the ground tethers
##   3.0s — slow pan up the boss body, framing the chest core at the
##          center of the screen
##   4.5s — pull back to a 3/4 boss-vs-Globbler shot showing scale
##   6.0s — hand off to gameplay camera, boss combat begins
##
## Behavior:
##   1) On play(), spawns a Camera3D, transforms current scene's active
##      camera to it, and Tweens through the 4 keyframes
##   2) Each beat eases with cubic_in_out so the moves feel cinematic,
##      not mechanical
##   3) Optional letterbox bars added via a CanvasLayer for the
##      cinematic look (16:9 → 21:9 framing)
##   4) Boss intro audio sting fired on beat 1 (when the boss is
##      revealed)
##   5) When done, the original gameplay camera is restored as the
##      active camera and a finished signal is emitted
##
## Required scene shape:
##   BossIntroCinematicCamera (Node3D + this script)
##     export boss_root_path: NodePath to the boss Node3D
##     export player_path: NodePath to Globbler
##     export gameplay_camera_path: NodePath to the normal player camera
##
## Hookup from boss spawn factory:
##   var intro: BossIntroCinematicCamera = preload(...).instantiate()
##   intro.boss_root_path = boss.get_path()
##   intro.player_path = globbler.get_path()
##   intro.gameplay_camera_path = camera.get_path()
##   add_child(intro)
##   intro.play()

signal cinematic_finished

@export var boss_root_path: NodePath
@export var player_path: NodePath
@export var gameplay_camera_path: NodePath
@export var beat_duration_s: float = 1.5
@export var enable_letterbox: bool = true
@export var letterbox_bar_height_pct: float = 0.12

var _cinematic_camera: Camera3D
var _gameplay_camera: Camera3D
var _boss: Node3D
var _player: Node3D
var _letterbox_layer: CanvasLayer
var _top_bar: ColorRect
var _bottom_bar: ColorRect


func _ready() -> void:
	_boss = get_node_or_null(boss_root_path) as Node3D
	_player = get_node_or_null(player_path) as Node3D
	_gameplay_camera = get_node_or_null(gameplay_camera_path) as Camera3D


func play() -> void:
	if _boss == null or _player == null:
		push_warning("BossIntroCinematicCamera: missing boss or player")
		cinematic_finished.emit()
		queue_free()
		return
	_spawn_cinematic_camera()
	if enable_letterbox:
		_spawn_letterbox()
	_run_cinematic()


func _spawn_cinematic_camera() -> void:
	_cinematic_camera = Camera3D.new()
	_cinematic_camera.name = "CinematicCamera"
	_cinematic_camera.fov = 50.0
	add_child(_cinematic_camera)
	_cinematic_camera.make_current()


func _spawn_letterbox() -> void:
	_letterbox_layer = CanvasLayer.new()
	_letterbox_layer.layer = 95
	add_child(_letterbox_layer)
	_top_bar = ColorRect.new()
	_top_bar.color = Color(0, 0, 0, 1)
	_top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_top_bar.anchor_bottom = letterbox_bar_height_pct
	_top_bar.modulate.a = 0.0
	_letterbox_layer.add_child(_top_bar)
	_bottom_bar = ColorRect.new()
	_bottom_bar.color = Color(0, 0, 0, 1)
	_bottom_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_bottom_bar.anchor_top = 1.0 - letterbox_bar_height_pct
	_bottom_bar.modulate.a = 0.0
	_letterbox_layer.add_child(_bottom_bar)
	# Fade in
	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_property(_top_bar, "modulate:a", 1.0, 0.4)
	tw.tween_property(_bottom_bar, "modulate:a", 1.0, 0.4)


func _run_cinematic() -> void:
	var boss_pos: Vector3 = _boss.global_position
	var player_pos: Vector3 = _player.global_position
	# Boss-relative coords
	var to_player: Vector3 = (player_pos - boss_pos)
	to_player.y = 0
	var horiz_dir: Vector3 = to_player.normalized() if to_player.length() > 0.01 else Vector3(0, 0, 1)
	var side: Vector3 = horiz_dir.cross(Vector3.UP).normalized()

	# === BEAT 1: Establishing wide shot from arena entrance ===
	var beat1_pos: Vector3 = boss_pos + horiz_dir * 18.0 + Vector3(0, 5.5, 0)
	var beat1_look: Vector3 = boss_pos + Vector3(0, 4.0, 0)

	# === BEAT 2: Low push toward base, looking up ===
	var beat2_pos: Vector3 = boss_pos + horiz_dir * 8.0 + Vector3(0, 0.6, 0)
	var beat2_look: Vector3 = boss_pos + Vector3(0, 3.0, 0)

	# === BEAT 3: Pan up the body framing the chest core ===
	var beat3_pos: Vector3 = boss_pos + horiz_dir * 6.0 + side * 1.5 + Vector3(0, 1.95, 0)
	var beat3_look: Vector3 = boss_pos + Vector3(0, 1.95, 0)  # chest core height

	# === BEAT 4: Pull back to 3/4 with player in shot ===
	var beat4_pos: Vector3 = boss_pos + horiz_dir * 12.0 + side * 4.0 + Vector3(0, 3.0, 0)
	var beat4_look: Vector3 = (boss_pos + player_pos) * 0.5 + Vector3(0, 1.5, 0)

	# Apply beat 1 instantly
	_set_camera(beat1_pos, beat1_look)

	# Drive the cinematic with a Tween through the keyframes
	var tw: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tw.tween_method(_lerp_camera.bind(beat1_pos, beat1_look, beat2_pos, beat2_look),
					0.0, 1.0, beat_duration_s)
	tw.tween_method(_lerp_camera.bind(beat2_pos, beat2_look, beat3_pos, beat3_look),
					0.0, 1.0, beat_duration_s)
	tw.tween_method(_lerp_camera.bind(beat3_pos, beat3_look, beat4_pos, beat4_look),
					0.0, 1.0, beat_duration_s)
	# Hold beat 4 briefly then hand back
	tw.tween_interval(beat_duration_s)
	tw.tween_callback(_finish_cinematic)

	# Audio sting on beat 1 reveal
	_play_intro_sting()


func _set_camera(pos: Vector3, look_at: Vector3) -> void:
	_cinematic_camera.global_position = pos
	if (look_at - pos).length() > 0.01:
		_cinematic_camera.look_at(look_at, Vector3.UP)


func _lerp_camera(t: float, from_pos: Vector3, from_look: Vector3, to_pos: Vector3, to_look: Vector3) -> void:
	var pos: Vector3 = from_pos.lerp(to_pos, t)
	var look: Vector3 = from_look.lerp(to_look, t)
	_set_camera(pos, look)


func _play_intro_sting() -> void:
	var sfx: Node = get_node_or_null("/root/SfxManager")
	if sfx != null and sfx.has_method("play"):
		sfx.play(&"boss_intro_compiler_sting", _boss.global_position)


func _finish_cinematic() -> void:
	# Fade out letterbox
	if enable_letterbox and _top_bar != null:
		var tw: Tween = create_tween().set_parallel(true)
		tw.tween_property(_top_bar, "modulate:a", 0.0, 0.3)
		tw.tween_property(_bottom_bar, "modulate:a", 0.0, 0.3)
	# Restore the gameplay camera
	if _gameplay_camera != null:
		_gameplay_camera.make_current()
	cinematic_finished.emit()
	# Free after a short delay so the letterbox fade completes
	get_tree().create_timer(0.5).timeout.connect(queue_free)
