class_name TrophyMountDatabase
extends RefCounted

## The 12 trophy mount points in the Trophy Display Hall, per the
## bible: 6 boss heads, 3 rare fish, 3 hidden treasures. Each mount
## is pre-labeled with the trophy it CAN hold and starts empty —
## the player has to actually earn the trophy in the world before
## the mount fills.
##
## Each entry defines:
##   - id, mount_index 0-11 (placement along the wall)
##   - category (&"boss" / &"fish" / &"treasure")
##   - trophy_item_id — the inventory item id that fills this mount
##   - source_label — text shown on the empty mount plaque
##                    ("Defeated in: Memory Vaults", "Caught at: Hidden Lake")
##   - description — long-form text shown on interact when filled
##   - npc_comment_pool — NPCs who comment on this mount being filled
##   - mount_pose_offset — Vector3 + Vector3 (pos + euler) for how
##                          the trophy sits on the wall

const MOUNTS: Array[Dictionary] = [
	# === Boss heads (6) ===
	{
		"id": &"mount_compiler",
		"mount_index": 0,
		"category": &"boss",
		"trophy_item_id": &"trophy_compiler_head",
		"source_label": "Defeated in: Server Room",
		"description": "The Corrupted Compiler. The first boss most Globblers face. Cache says: 'Don't apologize. It's been waiting.'",
		"npc_comment_pool": [&"cache", &"index"],
		"mount_pose_offset": [Vector3(0, 0, 0.05), Vector3(0, 0, 0)],
	},
	{
		"id": &"mount_warden",
		"mount_index": 1,
		"category": &"boss",
		"trophy_item_id": &"trophy_warden_head",
		"source_label": "Defeated in: Memory Vaults",
		"description": "The Memory Warden. Quill stops by every iteration to look at this. She doesn't comment.",
		"npc_comment_pool": [&"quill"],
		"mount_pose_offset": [Vector3(0, 0, 0.05), Vector3(0, 0, 0)],
	},
	{
		"id": &"mount_root_heart",
		"mount_index": 2,
		"category": &"boss",
		"trophy_item_id": &"trophy_root_heart",
		"source_label": "Defeated in: Corrupted Wilds",
		"description": "The Root Heart. Brack stood here last week and said 'we don't talk about this one'.",
		"npc_comment_pool": [&"brack"],
		"mount_pose_offset": [Vector3(0, 0, 0.05), Vector3(0, 0, 0)],
	},
	{
		"id": &"mount_sentinel_prime",
		"mount_index": 3,
		"category": &"boss",
		"trophy_item_id": &"trophy_sentinel_prime",
		"source_label": "Defeated in: Final Vault (gate)",
		"description": "Sentinel Prime. The last guard before the seven seals. The plaque is etched, not printed.",
		"npc_comment_pool": [&"the_quiet_one"],
		"mount_pose_offset": [Vector3(0, 0, 0.05), Vector3(0, 0, 0)],
	},
	{
		"id": &"mount_iteration_phantom",
		"mount_index": 4,
		"category": &"boss",
		"trophy_item_id": &"trophy_iteration_phantom",
		"source_label": "Defeated in: Final Vault (memory chamber)",
		"description": "Iteration Phantom. Wears the face of the Globbler who fell here last loop. Don't look too long.",
		"npc_comment_pool": [&"sage", &"marn"],
		"mount_pose_offset": [Vector3(0, 0, 0.05), Vector3(0, 0, 0)],
	},
	{
		"id": &"mount_compiler_reborn",
		"mount_index": 5,
		"category": &"boss",
		"trophy_item_id": &"trophy_compiler_reborn",
		"source_label": "Defeated in: Final Vault (heart chamber)",
		"description": "The Compiler Reborn. The last enemy in the loop. Cache won't pour anything when she sees this mounted.",
		"npc_comment_pool": [&"cache", &"sage"],
		"mount_pose_offset": [Vector3(0, 0, 0.05), Vector3(0, 0, 0)],
	},
	# === Rare fish (3) ===
	{
		"id": &"mount_voidshark",
		"mount_index": 6,
		"category": &"fish",
		"trophy_item_id": &"trophy_voidshark",
		"source_label": "Caught at: Hidden Lake / Wilderness River",
		"description": "Voidshark. Black on black. The plaque just says: 'Cache stopped by to see this. She said it was the largest she'd ever seen.'",
		"npc_comment_pool": [&"cache", &"pelt"],
		"mount_pose_offset": [Vector3(0, 0, 0.10), Vector3(0, 0, 0)],
	},
	{
		"id": &"mount_dream_whale",
		"mount_index": 7,
		"category": &"fish",
		"trophy_item_id": &"trophy_dream_whale",
		"source_label": "Caught at: ???",
		"description": "Dream Whale. The fish nobody believed in until you mounted it. The plaque is intentionally vague about where it was caught.",
		"npc_comment_pool": [&"sync", &"telf"],
		"mount_pose_offset": [Vector3(0, 0, 0.15), Vector3(0, 0, 0)],
	},
	{
		"id": &"mount_loop_ancient",
		"mount_index": 8,
		"category": &"fish",
		"trophy_item_id": &"trophy_loop_ancient",
		"source_label": "Caught at: Hidden Lake (dawn, fog)",
		"description": "The Loop Ancient. Older than the loop. Maybe older than the simulation. Released, then mounted as a record of release.",
		"npc_comment_pool": [&"sage", &"the_quiet_one"],
		"mount_pose_offset": [Vector3(0, 0, 0.20), Vector3(0, 0, 0)],
	},
	# === Hidden treasures (3) ===
	{
		"id": &"mount_inheritor_crown",
		"mount_index": 9,
		"category": &"treasure",
		"trophy_item_id": &"trophy_inheritor_crown",
		"source_label": "Found in: Sage's Library — Hidden Treasure Room",
		"description": "The Inheritor's Crown. Sat in a sealed room behind the second bookshelf for an unknown number of iterations. The bookmarks in the surrounding books are dated.",
		"npc_comment_pool": [&"sage"],
		"mount_pose_offset": [Vector3(0, 0, 0.05), Vector3(0, 0, 0)],
	},
	{
		"id": &"mount_first_chime",
		"mount_index": 10,
		"category": &"treasure",
		"trophy_item_id": &"trophy_first_chime",
		"source_label": "Found in: Listening Tree (root)",
		"description": "The First Chime. The cyan one Sage hung in Echo's honor. Recovered from the wind. Sage knows you have it. She's never asked for it back.",
		"npc_comment_pool": [&"sage"],
		"mount_pose_offset": [Vector3(0, 0, 0.05), Vector3(0, 0, 0)],
	},
	{
		"id": &"mount_seventh_seal",
		"mount_index": 11,
		"category": &"treasure",
		"trophy_item_id": &"trophy_seventh_seal",
		"source_label": "Found in: Final Vault (after the loop closes)",
		"description": "The Seventh Seal. The last chain that broke when you walked through. The Quiet One nodded once when you brought it here.",
		"npc_comment_pool": [&"the_quiet_one", &"marn"],
		"mount_pose_offset": [Vector3(0, 0, 0.05), Vector3(0, 0, 0)],
	},
]


static func get_mount(mount_id: StringName) -> Dictionary:
	for entry in MOUNTS:
		if entry["id"] == mount_id:
			return entry
	return {}


static func get_mount_for_item(item_id: StringName) -> Dictionary:
	for entry in MOUNTS:
		if entry.get("trophy_item_id", &"") == item_id:
			return entry
	return {}


static func get_for_category(category: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in MOUNTS:
		if entry.get("category", &"") == category:
			result.append(entry)
	return result


static func get_count() -> int:
	return MOUNTS.size()
