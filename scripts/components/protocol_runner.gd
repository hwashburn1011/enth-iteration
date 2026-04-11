class_name ProtocolRunner
extends Node
## Listens for trigger events (dash, kill, hit) and fires equipped protocol
## effects on the player. Without this runner, ProtocolItem.protocol_trigger
## is dead data — slots accept protocols, the inventory UI displays them, but
## nothing in the codebase reads the trigger field. The two existing
## protocols (Shockwave on dash, Siphon on kill) sit equipped and do
## nothing.
##
## Effects are dispatched by item_id rather than parsing the
## protocol_effect description string — keeps the runner small and
## type-safe instead of building a string-effect parser for two items.

## Shockwave Protocol — radius and damage of the post-dash AOE pulse.
const SHOCKWAVE_RADIUS: float = 4.0
const SHOCKWAVE_DAMAGE: float = 15.0
## Siphon Protocol — fraction of max HP healed on kill.
const SIPHON_HEAL_PCT: float = 0.05

var _player: CharacterBody3D = null
var _equipment: Node = null


func _ready() -> void:
	_player = get_parent() as CharacterBody3D
	if _player == null:
		push_warning("ProtocolRunner: parent is not a CharacterBody3D — disabled")
		return
	_equipment = _player.get_node_or_null("EquipmentComponent") as Node
	if _equipment == null:
		push_warning("ProtocolRunner: no EquipmentComponent on parent — disabled")
		return
	EventBus.player_dashed.connect(_on_player_dashed)
	EventBus.enemy_defeated.connect(_on_enemy_defeated)


func _on_player_dashed(_from: Vector3, to: Vector3) -> void:
	for protocol: Resource in _equipment.protocol_slots:
		if protocol == null:
			continue
		if protocol.protocol_trigger != "on_dash":
			continue
		_dispatch(protocol, to)


func _on_enemy_defeated(_enemy_type: StringName, position: Vector3, _loot_table: Resource) -> void:
	for protocol: Resource in _equipment.protocol_slots:
		if protocol == null:
			continue
		if protocol.protocol_trigger != "on_kill":
			continue
		_dispatch(protocol, position)


func _dispatch(protocol: Resource, position: Vector3) -> void:
	## Single fan-out point so future protocols only need a new branch here.
	match protocol.item_id:
		"protocol_dash_damage":
			_fire_shockwave(position)
		"protocol_on_kill_heal":
			_fire_siphon()
		_:
			pass  # Unknown protocol id — silently ignore until handler added.


func _fire_shockwave(origin: Vector3) -> void:
	## AOE pulse around the dash destination — hits everything in
	## SHOCKWAVE_RADIUS for SHOCKWAVE_DAMAGE.
	if not _player.is_inside_tree():
		return
	var tree: SceneTree = _player.get_tree()
	for enemy: Node in tree.get_nodes_in_group(&"enemies"):
		if not enemy is Node3D:
			continue
		var dist: float = (enemy as Node3D).global_position.distance_to(origin)
		if dist > SHOCKWAVE_RADIUS:
			continue
		var hp: Node = enemy.get_node_or_null("HealthComponent") as Node
		if hp and hp.has_method(&"take_damage"):
			hp.take_damage(SHOCKWAVE_DAMAGE)


func _fire_siphon() -> void:
	## Heal a fraction of player max HP whenever a nearby enemy dies. The
	## EventBus.enemy_defeated signal already fires from any death, so this
	## pulls automatically.
	var hp: Node = _player.get_node_or_null("HealthComponent") as Node
	if hp == null:
		return
	var amount: float = hp.max_health * SIPHON_HEAL_PCT
	hp.heal(amount)
