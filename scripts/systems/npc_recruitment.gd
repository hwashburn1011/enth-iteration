class_name NPCRecruitment
extends RefCounted
## Post-V1 Epic B #12 — NPC recruitment chain requirements.
##
## Defines what quest/conditions must be met before an NPC appears in town.
## Cache Sprite requires talking to the sage; VillagerR3 requires clearing
## the first dungeon run. NPCs in ALWAYS_PRESENT (ai_sage, villager_r3)
## bypass this for V1 — this system activates post-V1 when more NPCs exist.

const RECRUITMENT_REQUIREMENTS: Dictionary = {
	"cache_sprite": {
		"type": "quest_complete",
		"quest_id": "clear_dungeon",
		"description": "Complete a dungeon run to recruit Cache Sprite",
	},
}


## Returns true if the NPC is eligible to appear in town.
static func is_recruitable(npc_id: String) -> bool:
	if not RECRUITMENT_REQUIREMENTS.has(npc_id):
		return true  # No requirement = always available
	var req: Dictionary = RECRUITMENT_REQUIREMENTS[npc_id]
	var req_type: String = str(req.get("type", ""))
	match req_type:
		"quest_complete":
			var quest_id: String = str(req.get("quest_id", ""))
			return quest_id in QuestManager.completed_quests
		"affinity_tier":
			var target_npc: String = str(req.get("npc_id", ""))
			var min_tier: String = str(req.get("tier", "Acquaintance"))
			var current_tier: String = GameManager.get_affinity_tier(target_npc)
			return _tier_value(current_tier) >= _tier_value(min_tier)
	return true


static func _tier_value(tier: String) -> int:
	match tier:
		"Stranger": return 0
		"Acquaintance": return 1
		"Ally": return 2
		"Trusted": return 3
	return 0
