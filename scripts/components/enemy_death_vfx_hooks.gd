class_name EnemyDeathVfxHooks
extends Node

## Per-enemy death VFX + hit SFX hook component (Epic 08 tasks 37-38).
## Drives unique death effects + per-hit SFX for each of the 8 Epic 08
## enemies. Reads the enemy_id from a parent EnemyTuning resource
## (or an inspector override) and routes the matching VFX/SFX combo
## from a single static table.
##
## Per-enemy death effects:
##   crash_daemon    — coiled-spring shockwave + ember fountain
##   null_pointer    — cyan implosion + void shadow fade
##   stack_overflow  — cube collapse pancake + LED short circuit
##   race_condition  — chromatic burst + glitch shards
##   deadlock        — chains snap + crimson sparks
##   buffer_overflow — already explodes via AI explode signal (no extra)
##   phantom_cache   — gold dust burst + chest spray (handled by AI)
##   iteration_echo  — code rivulet dissolve + ghost fade
##
## Per-enemy hit SFX (StringName ID into SfxManager):
##   crash_daemon    — &"crash_daemon_hit_metal"
##   null_pointer    — &"null_pointer_hit_void"
##   stack_overflow  — &"stack_overflow_hit_chrome"
##   race_condition  — &"race_condition_hit_glitch"
##   deadlock        — &"deadlock_hit_chain"
##   buffer_overflow — &"buffer_overflow_hit_squish"
##   phantom_cache   — &"phantom_cache_hit_chime"
##   iteration_echo  — &"iteration_echo_hit_glass"
##
## Required scene shape:
##   AnyEnemyRoot (Node3D)
##     EnemyDeathVfxHooks (Node + this script)
##     HealthComponent (with damage_taken / died signals)

const DEATH_VFX_TABLE: Dictionary = {
	&"crash_daemon": "res://scenes/effects/death_vfx_crash_daemon.tscn",
	&"null_pointer": "res://scenes/effects/death_vfx_null_pointer.tscn",
	&"stack_overflow": "res://scenes/effects/death_vfx_stack_overflow.tscn",
	&"race_condition": "res://scenes/effects/death_vfx_race_condition.tscn",
	&"deadlock": "res://scenes/effects/death_vfx_deadlock.tscn",
	&"buffer_overflow": "",  # AI handles its own explosion
	&"phantom_cache": "res://scenes/effects/death_vfx_phantom_cache.tscn",
	&"iteration_echo": "res://scenes/effects/death_vfx_iteration_echo.tscn",
}

const HIT_SFX_TABLE: Dictionary = {
	&"crash_daemon": &"crash_daemon_hit_metal",
	&"null_pointer": &"null_pointer_hit_void",
	&"stack_overflow": &"stack_overflow_hit_chrome",
	&"race_condition": &"race_condition_hit_glitch",
	&"deadlock": &"deadlock_hit_chain",
	&"buffer_overflow": &"buffer_overflow_hit_squish",
	&"phantom_cache": &"phantom_cache_hit_chime",
	&"iteration_echo": &"iteration_echo_hit_glass",
}

const DEATH_SFX_TABLE: Dictionary = {
	&"crash_daemon": &"crash_daemon_death_engine_pop",
	&"null_pointer": &"null_pointer_death_void_implode",
	&"stack_overflow": &"stack_overflow_death_collapse",
	&"race_condition": &"race_condition_death_chromatic_burst",
	&"deadlock": &"deadlock_death_chains_snap",
	&"buffer_overflow": &"buffer_overflow_death_explode",
	&"phantom_cache": &"phantom_cache_death_chime_burst",
	&"iteration_echo": &"iteration_echo_death_glass_shatter",
}

@export var enemy_id: StringName = &""
@export var tuning: EnemyTuning
@export var health_component_path: NodePath

var _hc: Node
var _resolved_id: StringName


func _ready() -> void:
	_resolved_id = enemy_id
	if _resolved_id == &"" and tuning != null:
		_resolved_id = tuning.enemy_id
	_resolve_health_component()


func _resolve_health_component() -> void:
	_hc = get_node_or_null(health_component_path)
	if _hc == null:
		var parent: Node = get_parent()
		if parent != null:
			for child: Node in parent.get_children():
				if child.has_signal("damage_taken") and child.has_signal("died"):
					_hc = child
					break
	if _hc != null:
		if _hc.has_signal("damage_taken"):
			_hc.damage_taken.connect(_on_damage_taken)
		if _hc.has_signal("died"):
			_hc.died.connect(_on_died)


func _on_damage_taken(_amount: float) -> void:
	_play_hit_sfx()


func _on_died() -> void:
	_play_death_sfx()
	_spawn_death_vfx()


func _play_hit_sfx() -> void:
	if not HIT_SFX_TABLE.has(_resolved_id):
		return
	var sfx_id: StringName = HIT_SFX_TABLE[_resolved_id]
	_play_sfx(sfx_id)


func _play_death_sfx() -> void:
	if not DEATH_SFX_TABLE.has(_resolved_id):
		return
	var sfx_id: StringName = DEATH_SFX_TABLE[_resolved_id]
	_play_sfx(sfx_id)


func _play_sfx(sfx_id: StringName) -> void:
	if sfx_id == &"":
		return
	var sfx: Node = get_node_or_null("/root/SfxManager")
	if sfx != null and sfx.has_method("play"):
		var origin: Vector3 = (
			(get_parent() as Node3D).global_position
			if get_parent() is Node3D
			else Vector3.ZERO
		)
		sfx.play(sfx_id, origin)


func _spawn_death_vfx() -> void:
	if not DEATH_VFX_TABLE.has(_resolved_id):
		return
	var scene_path: String = DEATH_VFX_TABLE[_resolved_id]
	if scene_path == "" or not ResourceLoader.exists(scene_path):
		return
	var packed: PackedScene = load(scene_path) as PackedScene
	if packed == null:
		return
	var vfx: Node3D = packed.instantiate() as Node3D
	get_tree().current_scene.add_child(vfx)
	if get_parent() is Node3D:
		vfx.global_position = (get_parent() as Node3D).global_position
