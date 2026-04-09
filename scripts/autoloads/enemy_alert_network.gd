extends Node
## EnemyAlertNetwork — global broadcast/receive system for wilderness
## enemy alerts. When one enemy spots the player, this manager finds
## nearby enemies of the same faction/type and forwards the alert to
## them — controlled by each enemy's social profile so loners stay
## solo, swarmers always join, and socials propagate to one neighbor.
##
## Subscribers:
##   - Wilderness enemies register themselves on _ready()
##   - call broadcast_alert(source, target_node, level) when the enemy
##     detects the player
##   - The network walks the registered list, distance-tests, applies
##     the social profile, and calls receive_alert() on matches
##
## Add to project autoloads as "EnemyAlertNetwork".

signal alert_broadcast(source: Node, target: Node, level: int)
signal alert_received(receiver: Node, source: Node)

# Social profile id → behavior dict
const SOCIAL_PROFILES: Dictionary = {
	&"loner": {
		"propagate_radius": 0.0,    # never alerts neighbors
		"max_recipients": 0,
		"chain_factor": 0.0,        # no chain re-broadcast
		"alert_decay_s": 4.0,
	},
	&"social": {
		"propagate_radius": 18.0,   # tells one nearby kin
		"max_recipients": 1,
		"chain_factor": 0.5,        # 50% chance the alerted one re-alerts
		"alert_decay_s": 6.0,
	},
	&"pack": {
		"propagate_radius": 22.0,
		"max_recipients": 4,
		"chain_factor": 0.3,
		"alert_decay_s": 8.0,
	},
	&"swarm": {
		"propagate_radius": 30.0,   # entire local swarm joins
		"max_recipients": 999,
		"chain_factor": 1.0,
		"alert_decay_s": 10.0,
	},
}

# Enemy id → social profile id (mirrors WildernessEnemyDatabase ids)
const ENEMY_SOCIAL: Dictionary = {
	&"glitch_eel":             &"loner",      # solo ambushers
	&"bit_beetle":             &"swarm",      # always joins their kin
	&"stack_overflow_spider":  &"social",     # one nearby drops with you
	&"null_pointer_wisp":      &"pack",       # cluster behavior
	&"crash_daemon":           &"pack",       # emerge in groups
	&"memory_leak":            &"loner",      # drift solo
}

var _registered: Array[Dictionary] = []  # [{node, enemy_id, profile_id, last_alerted_at}]
var _alert_count_total: int = 0


func _ready() -> void:
	pass


# === REGISTRATION ===

func register_enemy(node: Node3D, enemy_id: StringName) -> void:
	if node == null:
		return
	var profile_id: StringName = ENEMY_SOCIAL.get(enemy_id, &"loner")
	_registered.append({
		"node": node,
		"enemy_id": enemy_id,
		"profile_id": profile_id,
		"last_alerted_at": -1.0,
	})
	if node.has_signal("tree_exited"):
		node.tree_exited.connect(_on_node_exited.bind(node))


func _on_node_exited(node: Node) -> void:
	for i in range(_registered.size() - 1, -1, -1):
		if _registered[i]["node"] == node:
			_registered.remove_at(i)


# === BROADCAST ===

func broadcast_alert(source: Node3D, target: Node3D, level: int = 1, allow_chain: bool = true) -> int:
	## Returns the number of recipients that received the alert.
	if source == null or target == null:
		return 0
	_alert_count_total += 1
	alert_broadcast.emit(source, target, level)

	# Find this source in the registry
	var source_entry: Dictionary = _entry_for_node(source)
	if source_entry.is_empty():
		return 0

	var profile_id: StringName = source_entry.get("profile_id", &"loner")
	var profile: Dictionary = SOCIAL_PROFILES.get(profile_id, SOCIAL_PROFILES[&"loner"])
	var radius: float = float(profile.get("propagate_radius", 0.0))
	if radius <= 0.0:
		return 0

	var max_recipients: int = int(profile.get("max_recipients", 0))
	var enemy_id: StringName = source_entry.get("enemy_id", &"")

	# Distance + same-type filter
	var candidates: Array[Dictionary] = []
	for entry in _registered:
		if entry["node"] == source:
			continue
		if entry.get("enemy_id", &"") != enemy_id:
			continue
		var node: Node3D = entry["node"]
		if not is_instance_valid(node):
			continue
		var dist: float = (node.global_position - source.global_position).length()
		if dist <= radius:
			entry["_dist"] = dist
			candidates.append(entry)

	# Closest first, capped at max_recipients
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("_dist", 0.0)) < float(b.get("_dist", 0.0))
	)
	if candidates.size() > max_recipients:
		candidates = candidates.slice(0, max_recipients)

	var notified: int = 0
	for entry in candidates:
		var node: Node3D = entry["node"]
		_deliver_alert_to(node, source, target, level)
		entry["last_alerted_at"] = Time.get_ticks_msec() / 1000.0
		notified += 1

	# Chain re-broadcast: each new recipient may rebroadcast (lower level)
	if allow_chain and level > 0:
		var chain_factor: float = float(profile.get("chain_factor", 0.0))
		for entry in candidates:
			if randf() <= chain_factor:
				var node: Node3D = entry["node"]
				broadcast_alert(node, target, level - 1, false)

	return notified


func _deliver_alert_to(receiver: Node3D, source: Node3D, target: Node3D, level: int) -> void:
	if receiver.has_method("receive_alert"):
		receiver.receive_alert(source, target, level)
	elif receiver.has_method("on_alert"):
		receiver.on_alert(source, target)
	# Fallback: set a metadata flag the receiver's state machine can poll
	receiver.set_meta(&"alert_target", target)
	receiver.set_meta(&"alert_received_at", Time.get_ticks_msec() / 1000.0)
	alert_received.emit(receiver, source)


# === HELPERS ===

func _entry_for_node(node: Node) -> Dictionary:
	for entry in _registered:
		if entry["node"] == node:
			return entry
	return {}


func get_registered_count() -> int:
	return _registered.size()


func get_alert_count_total() -> int:
	return _alert_count_total


func clear_all() -> void:
	_registered.clear()
