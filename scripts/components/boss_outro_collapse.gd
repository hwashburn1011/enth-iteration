class_name BossOutroCollapse
extends Node3D

## Boss outro: collapse + chest spawn (Epic 07 task 37). Drives the
## 8-second cinematic that plays when the Compiler boss is defeated.
## Replaces the live boss with the death animation, spawns a loot chest
## at the boss's location once the body lands, and hands camera control
## back to gameplay.
##
## Cinematic beats (matches the death animation timeline from the
## phase form bible):
##
##   0.0s — boss takes killing blow, ALL emission flashes white
##   1.0s — chrome arms break off and fall (debris emitter)
##   2.5s — energy arms dissipate into particles (energy_arm_dissolve)
##   4.0s — heart core ruptures with a final pulse (full-screen flash)
##   5.5s — tethers snap audibly (snap_sfx + visible breakage)
##   7.0s — body hits floor with massive dust impact (BossSlamDustEmitter)
##   8.0s — final crackle, silence, loot chest spawns
##
## Required scene shape:
##   BossOutroCollapse (Node3D + this script)
##     export boss_root_path: NodePath
##     export loot_chest_scene: PackedScene to spawn at boss location
##     export gameplay_camera_path: NodePath for the cinematic camera
##                                  hand-back
##
## Hookup from boss death state:
##   var outro: BossOutroCollapse = preload("res://scenes/effects/boss_outro_collapse.tscn").instantiate()
##   outro.boss_root_path = boss.get_path()
##   outro.loot_chest_scene = preload("res://scenes/props/boss_loot_chest.tscn")
##   add_child(outro)
##   outro.play()

signal outro_finished
signal loot_chest_spawned(chest: Node3D)

@export var boss_root_path: NodePath
@export var loot_chest_scene: PackedScene
@export var gameplay_camera_path: NodePath
@export var enable_cinematic_camera: bool = true
@export var enable_screen_flash: bool = true

const BEAT_FLASH: float = 0.0
const BEAT_ARMS_FALL: float = 1.0
const BEAT_ENERGY_DISSOLVE: float = 2.5
const BEAT_HEART_RUPTURE: float = 4.0
const BEAT_TETHERS_SNAP: float = 5.5
const BEAT_BODY_LAND: float = 7.0
const BEAT_CHEST_SPAWN: float = 8.0

var _boss: Node3D
var _gameplay_camera: Camera3D
var _cinematic_camera: Camera3D


func _ready() -> void:
	_boss = get_node_or_null(boss_root_path) as Node3D
	_gameplay_camera = get_node_or_null(gameplay_camera_path) as Camera3D


func play() -> void:
	if _boss == null:
		push_warning("BossOutroCollapse: missing boss root")
		outro_finished.emit()
		queue_free()
		return
	if enable_cinematic_camera:
		_spawn_cinematic_camera()
	_schedule_beats()


func _spawn_cinematic_camera() -> void:
	_cinematic_camera = Camera3D.new()
	_cinematic_camera.name = "OutroCinematicCamera"
	_cinematic_camera.fov = 45.0
	add_child(_cinematic_camera)
	# Position 12m back, 3m up, looking at the boss chest core
	var boss_pos: Vector3 = _boss.global_position
	var back_dir: Vector3 = -_boss.global_transform.basis.z.normalized()
	_cinematic_camera.global_position = boss_pos + back_dir * 12.0 + Vector3(0, 3.5, 0)
	_cinematic_camera.look_at(boss_pos + Vector3(0, 2.0, 0), Vector3.UP)
	_cinematic_camera.make_current()


func _schedule_beats() -> void:
	# Beat 0: white flash + audio
	_play_killing_blow_flash()
	get_tree().create_timer(BEAT_ARMS_FALL).timeout.connect(_beat_arms_fall)
	get_tree().create_timer(BEAT_ENERGY_DISSOLVE).timeout.connect(_beat_energy_dissolve)
	get_tree().create_timer(BEAT_HEART_RUPTURE).timeout.connect(_beat_heart_rupture)
	get_tree().create_timer(BEAT_TETHERS_SNAP).timeout.connect(_beat_tethers_snap)
	get_tree().create_timer(BEAT_BODY_LAND).timeout.connect(_beat_body_land)
	get_tree().create_timer(BEAT_CHEST_SPAWN).timeout.connect(_beat_chest_spawn)


func _play_killing_blow_flash() -> void:
	if not enable_screen_flash:
		return
	# Re-use the BossPhaseTransitionFX flash class
	var FlashScript = load("res://scripts/components/boss_phase_transition_fx.gd")
	if FlashScript != null:
		var flash = Node.new()
		flash.set_script(FlashScript)
		get_tree().current_scene.add_child(flash)
		if flash.has_method("play_transition"):
			flash.call("play_transition", _boss.global_position)
	# Audio
	var sfx: Node = get_node_or_null("/root/SfxManager")
	if sfx != null and sfx.has_method("play"):
		sfx.play(&"boss_killing_blow", _boss.global_position)


func _beat_arms_fall() -> void:
	# TODO: Trigger an "arms fall off" particle burst on each arm bone
	# For now, fire a slam dust burst at each arm
	_emit_slam_dust(_boss.global_position + Vector3(1.55, 2.5, 0))
	_emit_slam_dust(_boss.global_position + Vector3(-1.55, 2.5, 0))
	var sfx: Node = get_node_or_null("/root/SfxManager")
	if sfx != null and sfx.has_method("play"):
		sfx.play(&"boss_arms_break_off", _boss.global_position)


func _beat_energy_dissolve() -> void:
	var sfx: Node = get_node_or_null("/root/SfxManager")
	if sfx != null and sfx.has_method("play"):
		sfx.play(&"boss_energy_arms_dissolve", _boss.global_position)


func _beat_heart_rupture() -> void:
	# Second white flash for the heart rupture
	_play_killing_blow_flash()


func _beat_tethers_snap() -> void:
	var sfx: Node = get_node_or_null("/root/SfxManager")
	if sfx != null and sfx.has_method("play"):
		sfx.play(&"boss_tethers_snap", _boss.global_position)


func _beat_body_land() -> void:
	# Massive dust impact when the body hits the floor
	_emit_slam_dust(_boss.global_position)
	var sfx: Node = get_node_or_null("/root/SfxManager")
	if sfx != null and sfx.has_method("play"):
		sfx.play(&"boss_body_land_impact", _boss.global_position)


func _beat_chest_spawn() -> void:
	if loot_chest_scene != null:
		var chest: Node3D = loot_chest_scene.instantiate() as Node3D
		get_tree().current_scene.add_child(chest)
		chest.global_position = _boss.global_position
		loot_chest_spawned.emit(chest)
	# Hand camera control back
	if _gameplay_camera != null:
		_gameplay_camera.make_current()
	outro_finished.emit()
	# Free self after a short delay
	get_tree().create_timer(1.0).timeout.connect(queue_free)


func _emit_slam_dust(pos: Vector3) -> void:
	var DustScript = load("res://scripts/components/boss_slam_dust_emitter.gd")
	if DustScript == null:
		return
	var dust := Node3D.new()
	dust.set_script(DustScript)
	get_tree().current_scene.add_child(dust)
	dust.global_position = pos
	if dust.has_method("emit"):
		dust.call("emit")
