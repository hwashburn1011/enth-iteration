class_name NPCGifts
extends RefCounted
## Post-V1 Epic B #13 — NPC gift system.
##
## Give items to NPCs for affinity gain. Each NPC has preferred item types
## that grant bonus affinity. Non-preferred items still give a small amount.

## Preferred item types per NPC. Matching gives 2x affinity.
const PREFERENCES: Dictionary = {
	"ai_sage": ["module", "core"],
	"cache_sprite": ["chip", "prompt"],
	"villager_r3": ["prompt"],
}

const BASE_AFFINITY: int = 5
const PREFERRED_MULTIPLIER: int = 2
const RARITY_BONUS: Array[int] = [0, 2, 5, 10]  # common, uncommon, rare, legendary


## Give an item to an NPC. Returns the affinity gained (0 if invalid).
static func give_item(npc_id: String, item: Resource, player: Node) -> int:
	if item == null or npc_id.is_empty():
		return 0
	var inv: Node = player.get_node_or_null("InventoryComponent") as Node
	if inv == null:
		return 0

	# Determine item type
	var item_type: String = str(item.get(&"item_type")) if &"item_type" in item else ""
	var rarity: int = int(item.get(&"rarity")) if &"rarity" in item else 0

	# Calculate affinity
	var affinity: int = BASE_AFFINITY
	var prefs: Array = PREFERENCES.get(npc_id, []) as Array
	if item_type in prefs:
		affinity *= PREFERRED_MULTIPLIER
	affinity += RARITY_BONUS[clampi(rarity, 0, RARITY_BONUS.size() - 1)]

	# Remove item from inventory and grant affinity
	inv.remove_item(item)
	GameManager.increase_affinity(npc_id, affinity)
	return affinity
