class_name AffinityRewards
extends RefCounted
## Post-V1 Epic B #11 — NPC affinity reward table.
##
## When an NPC reaches a new affinity tier, the player receives a
## gameplay reward. Rewards are applied once per NPC per tier and
## tracked via GameManager meta to prevent double-granting on load.

## Reward table: npc_id -> tier_name -> {type, amount, description}
const REWARDS: Dictionary = {
	"ai_sage": {
		"Acquaintance": {"type": "passive_stat", "stat": "memory", "amount": 2.0, "desc": "+2 Memory"},
		"Ally": {"type": "gold", "amount": 50, "desc": "+50 Gold"},
		"Trusted": {"type": "passive_stat", "stat": "integrity", "amount": 5.0, "desc": "+5 Integrity"},
	},
	"cache_sprite": {
		"Acquaintance": {"type": "passive_stat", "stat": "bandwidth", "amount": 2.0, "desc": "+2 Bandwidth"},
		"Ally": {"type": "gold", "amount": 50, "desc": "+50 Gold"},
		"Trusted": {"type": "passive_stat", "stat": "processing", "amount": 5.0, "desc": "+5 Processing"},
	},
	"villager_r3": {
		"Acquaintance": {"type": "gold", "amount": 25, "desc": "+25 Gold"},
		"Ally": {"type": "passive_stat", "stat": "integrity", "amount": 3.0, "desc": "+3 Integrity"},
		"Trusted": {"type": "gold", "amount": 100, "desc": "+100 Gold"},
	},
}


## Check and apply any newly reached tier reward. Called when affinity changes.
static func check_and_apply(npc_id: String, new_value: int) -> String:
	var tier: String = _get_tier_for_value(new_value)
	if tier == "Stranger":
		return ""
	var npc_rewards: Dictionary = REWARDS.get(npc_id, {}) as Dictionary
	if not npc_rewards.has(tier):
		return ""
	# Check if already granted
	var grant_key: String = "affinity_reward_%s_%s" % [npc_id, tier]
	if GameManager.has_meta(StringName(grant_key)):
		return ""
	# Grant the reward
	var reward: Dictionary = npc_rewards[tier] as Dictionary
	GameManager.set_meta(StringName(grant_key), true)
	_apply_reward(reward)
	return str(reward.get("desc", ""))


static func _get_tier_for_value(value: int) -> String:
	if value >= GameManager.AFFINITY_TRUSTED:
		return "Trusted"
	elif value >= GameManager.AFFINITY_ALLY:
		return "Ally"
	elif value >= GameManager.AFFINITY_ACQUAINTANCE:
		return "Acquaintance"
	return "Stranger"


static func _apply_reward(reward: Dictionary) -> void:
	var reward_type: String = str(reward.get("type", ""))
	match reward_type:
		"gold":
			GameManager.player_gold += int(reward.get("amount", 0))
		"passive_stat":
			# Find the player and apply via StatsComponent
			var players: Array[Node] = Engine.get_main_loop().root.get_tree().get_nodes_in_group(&"player")
			if players.size() > 0:
				var stats: Node = players[0].get_node_or_null("StatsComponent") as Node
				if stats and stats.has_method(&"add_passive_bonus"):
					stats.add_passive_bonus(str(reward.get("stat", "")), float(reward.get("amount", 0.0)))
