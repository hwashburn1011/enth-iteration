class_name SaveShrine
extends Area3D
## Town Heart save shrine — explicit "rest" interactable that recovers
## the player's HP/compute and locks in an autosave between runs.
##
## Phase 2 #18: the shrine art was authored in Epic 10 T7 but it had no
## runtime consumer (the visual stack was a "dead-data wiring" case —
## see the project memory `dead_data_pattern`). This script is the
## consumer: it owns an interaction Area3D, a [E] Rest prompt label, the
## healing call, and the SaveManager.save_game() trigger, so the player
## actually has a between-run pit stop instead of relying on respawn to
## implicitly top them up.
##
## The shrine has a brief cooldown so a panicking player can't tap [E]
## three frames in a row and spam-save. The cooldown also prevents the
## restore VFX from stacking on itself.

const REST_COOLDOWN: float = 1.5

@export var prompt_text: String = "[E] Rest at the Shrine"

var _player_in_range: bool = false
var _player_ref: Node3D = null
var _on_cooldown: bool = false

@onready var _label: Label3D = $RestLabel as Label3D


func _ready() -> void:
	# Layer 0 / mask 1 mirrors compaction_portal: the area only listens
	# for player CharacterBody3D entries, never collides with anything.
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	monitorable = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if _label:
		_label.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range or _on_cooldown:
		return
	if event.is_action_pressed(&"interact"):
		_rest_at_shrine()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = true
		_player_ref = body
		if _label:
			_label.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false
		_player_ref = null
		if _label:
			_label.visible = false


func _rest_at_shrine() -> void:
	## Full restore + autosave. Heals/restores via the existing component
	## APIs so the heal/compute VFX play naturally; then forces a save so
	## the topped-up state survives a crash on the next run.
	if not is_instance_valid(_player_ref):
		return
	_on_cooldown = true
	# Heal HP
	var hp: Node = _player_ref.get_node_or_null("HealthComponent")
	if hp and hp is HealthComponent:
		var hpc: HealthComponent = hp as HealthComponent
		var missing_hp: float = hpc.max_health - hpc.current_health
		if missing_hp > 0.0:
			hpc.heal(missing_hp)
	# Restore compute
	var cp: Node = _player_ref.get_node_or_null("ComputeComponent")
	if cp and cp is ComputeComponent:
		var cpc: ComputeComponent = cp as ComputeComponent
		var missing_cp: float = cpc.max_compute - cpc.current_compute
		if missing_cp > 0.0:
			cpc.restore(missing_cp)
	# Lock in the autosave. SaveManager.save_game() handles the heavy
	# lifting (player snapshot, inventory, equipment, quest, iteration).
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method(&"save_game"):
			sm.save_game()
	# Audible cue — reuse the existing item pickup sting so we don't ship
	# a new asset. Falls through silently if AudioManager isn't loaded.
	if has_node("/root/AudioManager"):
		var am: Node = get_node("/root/AudioManager")
		if am.has_method(&"play_sfx"):
			am.play_sfx("item_pickup")
	# Brief label flip so the player knows the rest landed.
	if _label:
		var prior: String = _label.text
		_label.text = "Rested · Saved"
		await get_tree().create_timer(REST_COOLDOWN).timeout
		if is_instance_valid(_label):
			_label.text = prior
	else:
		await get_tree().create_timer(REST_COOLDOWN).timeout
	_on_cooldown = false
