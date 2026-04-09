class_name NPCDatabase
extends RefCounted

## Static catalog of all 12 town NPCs with their gift preferences,
## birthdays, relationships. Built once at startup.

const NPCS: Array = [
	{"id": &"pixel",   "name": "Pixel",   "role": "Shopkeeper", "birthday": 5,
	 "loved":   [&"crop_pingberry", &"deco_bit_sculpture", &"prompt_dmg"],
	 "liked":   [&"crop_datacarrot", &"crop_cachepea", &"bit_fragment", &"cache_crystal"],
	 "disliked":[&"crop_iron_onion", &"voidsteel"],
	 "hated":   [&"glitch_core"],
	 "tint":    Color(0.95, 0.65, 0.30),
	 "friends": [&"trade", &"cache"],
	 "rivals":  [],
	 "personal_quests": [&"pixel_q1", &"pixel_q2", &"pixel_q3"]},

	{"id": &"forge",   "name": "Forge",   "role": "Blacksmith", "birthday": 12,
	 "loved":   [&"compiled_steel", &"deco_mini_forge", &"crop_iron_onion"],
	 "liked":   [&"wire", &"server_coil", &"quantum_shard"],
	 "disliked":[&"crop_pingberry", &"patch"],
	 "hated":   [&"sleeppoppy"],
	 "tint":    Color(0.85, 0.40, 0.20),
	 "friends": [&"sentinel", &"lab"],
	 "rivals":  [],
	 "personal_quests": [&"forge_q1", &"forge_q2", &"forge_q3"]},

	{"id": &"cache",   "name": "Cache",   "role": "Barkeep",    "birthday": 18,
	 "loved":   [&"crop_clockmint", &"crop_sleeppoppy", &"deco_jukebox"],
	 "liked":   [&"crop_pingberry", &"crop_quantum_bean", &"prompt_speed"],
	 "disliked":[&"voidsteel", &"glitch_core"],
	 "hated":   [],
	 "tint":    Color(0.85, 0.55, 0.30),
	 "friends": [&"pixel", &"sync"],
	 "rivals":  [],
	 "personal_quests": [&"cache_q1", &"cache_q2", &"cache_q3"]},

	{"id": &"index",   "name": "Index",   "role": "Librarian",  "birthday": 25,
	 "loved":   [&"memory_glass", &"deco_master_bookshelf", &"deco_code_scroll"],
	 "liked":   [&"crop_iteration_lily", &"sages_tear", &"pure_code"],
	 "disliked":[&"crop_pingberry", &"server_coil"],
	 "hated":   [&"glitch_core"],
	 "tint":    Color(0.40, 0.55, 0.95),
	 "friends": [&"sage", &"render"],
	 "rivals":  [],
	 "personal_quests": [&"index_q1", &"index_q2", &"index_q3"]},

	{"id": &"harvest", "name": "Harvest", "role": "Farmer",     "birthday": 32,
	 "loved":   [&"crop_pixel_pumpkin", &"deco_decor_plant", &"crop_heart_fruit"],
	 "liked":   [&"crop_datacarrot", &"crop_cachepea", &"crop_threadflax"],
	 "disliked":[&"compiled_steel", &"server_coil"],
	 "hated":   [&"voidsteel"],
	 "tint":    Color(0.40, 0.85, 0.40),
	 "friends": [&"bit"],
	 "rivals":  [],
	 "personal_quests": [&"harvest_q1", &"harvest_q2", &"harvest_q3"]},

	{"id": &"bit",     "name": "Bit",     "role": "Child",      "birthday": 38,
	 "loved":   [&"deco_glow_mushroom", &"deco_wind_chime", &"crop_pingberry"],
	 "liked":   [&"crop_cachepea", &"prompt_heal_s", &"deco_tiny_statue"],
	 "disliked":[&"voidsteel", &"compiled_steel"],
	 "hated":   [&"glitch_core"],
	 "tint":    Color(0.95, 0.85, 0.40),
	 "friends": [&"harvest", &"legacy"],
	 "rivals":  [],
	 "personal_quests": [&"bit_q1", &"bit_q2", &"bit_q3"]},

	{"id": &"legacy",  "name": "Legacy",  "role": "Elder",      "birthday": 45,
	 "loved":   [&"sages_tear", &"iteration_echo", &"deco_iteration_monument"],
	 "liked":   [&"crop_sages_mint", &"memory_glass", &"crop_clockmint"],
	 "disliked":[&"crop_pingberry"],
	 "hated":   [],
	 "tint":    Color(0.85, 0.85, 0.85),
	 "friends": [&"sage", &"bit"],
	 "rivals":  [],
	 "personal_quests": [&"legacy_q1", &"legacy_q2", &"legacy_q3"]},

	{"id": &"trade",   "name": "Trade",   "role": "Merchant",   "birthday": 52,
	 "loved":   [&"quantum_shard", &"compaction_heart", &"deco_throne"],
	 "liked":   [&"compiled_steel", &"dream_silk", &"sages_tear"],
	 "disliked":[&"crop_datacarrot", &"patch"],
	 "hated":   [&"bit_fragment"],
	 "tint":    Color(0.95, 0.75, 0.20),
	 "friends": [&"pixel"],
	 "rivals":  [&"forge"],
	 "personal_quests": [&"trade_q1", &"trade_q2", &"trade_q3"]},

	{"id": &"lab",     "name": "Lab",     "role": "Scientist",  "birthday": 58,
	 "loved":   [&"pure_code", &"algorithm_stone", &"deco_holo_globe"],
	 "liked":   [&"memory_glass", &"server_coil", &"quantum_shard"],
	 "disliked":[&"crop_pixel_pumpkin", &"crop_logleaf"],
	 "hated":   [],
	 "tint":    Color(0.55, 0.95, 0.85),
	 "friends": [&"forge", &"sage"],
	 "rivals":  [],
	 "personal_quests": [&"lab_q1", &"lab_q2", &"lab_q3"]},

	{"id": &"render",  "name": "Render",  "role": "Artist",     "birthday": 65,
	 "loved":   [&"dyed_thread", &"dream_silk", &"deco_holo_projector"],
	 "liked":   [&"crop_pixel_pumpkin", &"crop_threadflax", &"crop_glowmoss"],
	 "disliked":[&"compiled_steel", &"voidsteel"],
	 "hated":   [&"glitch_core"],
	 "tint":    Color(0.95, 0.40, 0.85),
	 "friends": [&"index", &"sync"],
	 "rivals":  [],
	 "personal_quests": [&"render_q1", &"render_q2", &"render_q3"]},

	{"id": &"sync",    "name": "Sync",    "role": "Musician",   "birthday": 72,
	 "loved":   [&"deco_piano", &"deco_jukebox", &"deco_music_player"],
	 "liked":   [&"crop_clockmint", &"dream_silk", &"server_coil"],
	 "disliked":[&"glitch_core"],
	 "hated":   [],
	 "tint":    Color(0.55, 0.40, 0.95),
	 "friends": [&"cache", &"render"],
	 "rivals":  [],
	 "personal_quests": [&"sync_q1", &"sync_q2", &"sync_q3"]},

	{"id": &"sentinel","name": "Sentinel","role": "Guard",      "birthday": 80,
	 "loved":   [&"compiled_steel", &"deco_training_dummy", &"crop_iron_onion"],
	 "liked":   [&"wire", &"voidsteel", &"server_coil"],
	 "disliked":[&"crop_pingberry", &"patch"],
	 "hated":   [&"crop_sleeppoppy"],
	 "tint":    Color(0.65, 0.65, 0.85),
	 "friends": [&"forge"],
	 "rivals":  [],
	 "personal_quests": [&"sentinel_q1", &"sentinel_q2", &"sentinel_q3"]},
]

static var _index: Dictionary = {}


static func get_all() -> Array:
	return NPCS


static func get_npc(id: StringName) -> Dictionary:
	if _index.is_empty():
		_build_index()
	return _index.get(id, {})


static func _build_index() -> void:
	for n in NPCS:
		_index[n["id"]] = n


static func get_gift_preference(npc_id: StringName, item_id: StringName) -> StringName:
	## Returns "loved" / "liked" / "neutral" / "disliked" / "hated"
	var npc: Dictionary = get_npc(npc_id)
	if npc.is_empty():
		return &"neutral"
	if item_id in npc.get("loved", []):
		return &"loved"
	if item_id in npc.get("liked", []):
		return &"liked"
	if item_id in npc.get("disliked", []):
		return &"disliked"
	if item_id in npc.get("hated", []):
		return &"hated"
	return &"neutral"


static func get_birthday(npc_id: StringName) -> int:
	var npc: Dictionary = get_npc(npc_id)
	return npc.get("birthday", 0)


static func count() -> int:
	return NPCS.size()
