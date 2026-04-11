class_name EnemyVariantSfx
extends Node

## Routes per-variant SFX through the SfxManager based on the parent
## enemy's variant Resource. Listens for the standard enemy lifecycle
## events (state machine state changes, damage_taken, died, footstep
## bone events, aggro entered) and dispatches the variant's SFX ID.
##
## Falls back gracefully when:
##   - the variant has an empty SFX field (no sound, lets the base enemy
##     handle it)
##   - the variant Resource isn't assigned (no-op, prints a warning once)
##   - the SfxManager autoload doesn't exist (no-op silently)
##
## Required scene shape:
##   AnyEnemyRoot (Node3D)
##     EnemyVariantSfx (Node + this script, with variant set externally)
##     HealthComponent (or compatible with damage_taken / died signals)
##     [optional] state_machine — emits state_entered(state_name)
##     [optional] AnimationPlayer — emits animation_started for footsteps
##
## Hooked from a spawn factory:
##   var sfx_node: EnemyVariantSfx = EnemyVariantSfx.new()
##   sfx_node.variant = preload("res://data/enemies/variants/glitchbug_venom.tres")
##   enemy_root.add_child(sfx_node)

@export var variant: EnemyVariant
@export var health_component_path: NodePath
@export var state_machine_path: NodePath
@export var animation_player_path: NodePath
@export var aura_loop_player_path: NodePath  ## optional AudioStreamPlayer3D for the looping aura hum

var _hc: Node
var _state_machine: Node
var _anim_player: AnimationPlayer
var _aura_loop_player: AudioStreamPlayer3D
var _aura_loop_active: bool = false


func _ready() -> void:
	if variant == null:
		push_warning("EnemyVariantSfx: variant Resource not set on %s" % name)
		return

	_hc = get_node_or_null(health_component_path)
	if _hc == null:
		# Auto-find on parent siblings
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

	_state_machine = get_node_or_null(state_machine_path)
	if _state_machine == null:
		var parent: Node = get_parent()
		if parent != null:
			var sm: Node = parent.get_node_or_null("state_machine")
			if sm != null:
				_state_machine = sm
	if _state_machine != null and _state_machine.has_signal("state_entered"):
		_state_machine.state_entered.connect(_on_state_entered)

	_anim_player = get_node_or_null(animation_player_path) as AnimationPlayer
	# Footstep sounds typically come from the AnimationPlayer's call tracks,
	# but we also expose a public footstep() method that the rig can call

	_aura_loop_player = get_node_or_null(aura_loop_player_path) as AudioStreamPlayer3D
	if variant.has_pack_leader_aura and variant.sfx_aura_loop != &"":
		_start_aura_loop()


func _on_state_entered(state_name: StringName) -> void:
	# State name → SFX hook mapping
	match state_name:
		&"idle":
			_play(variant.sfx_idle)
		&"aggro":
			_play(variant.sfx_aggro)
		&"attack_windup":
			_play(variant.sfx_attack_windup)
		&"attack_strike":
			_play(variant.sfx_attack_strike)
		&"summon":
			_play(variant.sfx_summon_call)
		_:
			pass  # other states don't have a hook


func _on_damage_taken(_amount: float) -> void:
	_play(variant.sfx_hit)


func _on_died() -> void:
	_play(variant.sfx_death)
	_stop_aura_loop()


# === Public API ===

func footstep() -> void:
	## Call from an AnimationPlayer call track at the frame the foot
	## hits the ground. Stub here so animation tracks can target it
	## even if the variant has no footstep SFX.
	_play(variant.sfx_footstep)


func attack_windup() -> void:
	_play(variant.sfx_attack_windup)


func attack_strike() -> void:
	_play(variant.sfx_attack_strike)


func summon_call() -> void:
	_play(variant.sfx_summon_call)


# === Internal ===

func _play(sfx_id: StringName) -> void:
	if sfx_id == &"" or variant == null:
		return
	var sfx: Node = get_node_or_null("/root/SfxManager")
	if sfx != null and sfx.has_method("play"):
		var origin: Vector3 = (
			(get_parent() as Node3D).global_position
			if get_parent() is Node3D
			else Vector3.INF
		)
		sfx.play(sfx_id, origin)


func _start_aura_loop() -> void:
	if _aura_loop_active or variant.sfx_aura_loop == &"":
		return
	# If a dedicated AudioStreamPlayer3D is provided, route the loop through
	# it; otherwise just trigger the SfxManager play and trust it has its
	# own loop handling for ambient SFX
	if _aura_loop_player != null:
		var path: String = "res://assets/audio/sfx/ambient/" + String(variant.sfx_aura_loop) + ".ogg"
		if ResourceLoader.exists(path):
			var stream: AudioStream = load(path) as AudioStream
			if stream is AudioStreamOggVorbis:
				(stream as AudioStreamOggVorbis).loop = true
			_aura_loop_player.stream = stream
			_aura_loop_player.play()
			_aura_loop_active = true
	else:
		_play(variant.sfx_aura_loop)
		_aura_loop_active = true


func _stop_aura_loop() -> void:
	if not _aura_loop_active:
		return
	if _aura_loop_player != null and _aura_loop_player.playing:
		_aura_loop_player.stop()
	_aura_loop_active = false
