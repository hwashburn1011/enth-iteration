class_name AffinitySubsystems
extends Node

## Affinity & Relationship Subsystems Bundle (Epic 37 tasks 7, 8, 12, 16,
## 17, 18, 22, 31, 32, 33, 43, 44, 45, 46, 48, 49).
##
## Engine-side support for the NPC affinity & relationships system:
##   - Task 7: Gift reaction animation router (per-NPC, per-tier)
##   - Task 8: Gift dialogue variant database
##   - Task 12: Affinity progression sound hook
##   - Task 16: Relationship cinematic for max affinity (db-driven)
##   - Task 17: NPC visit player home interaction
##   - Task 18: Player visit NPC home interaction
##   - Task 22: Gift-giving etiquette tutorial
##   - Task 31: Per-NPC affinity hint dialogue
##   - Task 32: Gift wrap visual on giving (instantiates wrap mesh on hand bone)
##   - Task 33: Reactive NPC poses for affinity levels
##   - Task 43: UX validator with all 12 NPCs maxed
##   - Task 44: Gift inventory management test
##   - Task 45: Affinity gain rate tuning helpers
##   - Task 46: UX hints for missed gifts (NPCs whose birthday/loved gift
##     opportunity is approaching)
##   - Task 48: Affinity history log (timeline of changes)
##   - Task 49: Validate against story flags

signal gift_reaction_played(npc_id: StringName, reaction: StringName)
signal cinematic_triggered(cinematic_id: StringName, npc_id: StringName)
signal home_visit_started(host_id: StringName, guest_id: StringName)
signal hint_emitted(hint_text: String, urgency: int)
signal history_entry_added(entry: Dictionary)

const REACTION_TIERS: Array[StringName] = [&"hated", &"disliked", &"neutral", &"liked", &"loved"]

# === TASK 7: Gift reaction animation router ===
const REACTION_ANIM_BY_TIER: Dictionary = {
	&"hated": &"npc_react_disgust",
	&"disliked": &"npc_react_frown",
	&"neutral": &"npc_react_nod",
	&"liked": &"npc_react_smile",
	&"loved": &"npc_react_joy",
}


func play_gift_reaction(npc_id: StringName, gift_id: StringName) -> StringName:
	var tier: StringName = _gift_tier_for_npc(npc_id, gift_id)
	var anim: StringName = REACTION_ANIM_BY_TIER.get(tier, &"npc_react_nod")
	# Push to NPCAnimationManager if present
	if has_node("/root/NPCAnimationManager"):
		var nm: Node = get_node("/root/NPCAnimationManager")
		if nm.has_method("play_animation"):
			nm.call("play_animation", npc_id, anim)
	# Play sting
	_play_progression_sound(tier)
	gift_reaction_played.emit(npc_id, tier)
	return tier


func _gift_tier_for_npc(npc_id: StringName, gift_id: StringName) -> StringName:
	# Loved/liked/neutral/disliked/hated lookup against gift preference DB
	if has_node("/root/GiftPreferenceDatabase"):
		var db: Node = get_node("/root/GiftPreferenceDatabase")
		if db.has_method("get_tier_for_gift"):
			return db.call("get_tier_for_gift", npc_id, gift_id)
	return &"neutral"


# === TASK 8: Gift dialogue variant database ===
const GIFT_DIALOGUE_VARIANTS: Dictionary = {
	&"hated": [
		"Why would you give me this?",
		"...thanks. I guess.",
		"This isn't really my style.",
		"I... appreciate the thought.",
	],
	&"disliked": [
		"Oh. Well, thank you.",
		"That's... nice.",
		"I'll find a use for it.",
	],
	&"neutral": [
		"Thanks for thinking of me.",
		"Appreciated.",
		"That's kind of you.",
	],
	&"liked": [
		"Oh, I love it!",
		"How did you know I needed this?",
		"This is wonderful, thank you!",
	],
	&"loved": [
		"This is exactly what I wanted! Thank you so much!",
		"You remembered! I can't believe it.",
		"I'll treasure this forever.",
	],
}


func get_gift_dialogue(tier: StringName) -> String:
	var variants: Array = GIFT_DIALOGUE_VARIANTS.get(tier, [])
	if variants.is_empty():
		return "Thank you."
	return variants[randi() % variants.size()]


# === TASK 12: Affinity progression sound ===
func _play_progression_sound(tier: StringName) -> void:
	if not has_node("/root/AudioManager"):
		return
	var am: Node = get_node("/root/AudioManager")
	if not am.has_method("play_sfx"):
		return
	var sfx: StringName = &"sfx_gift_neutral"
	match tier:
		&"loved": sfx = &"sfx_gift_loved_chime"
		&"liked": sfx = &"sfx_gift_liked_warm"
		&"neutral": sfx = &"sfx_gift_neutral_nod"
		&"disliked": sfx = &"sfx_gift_disliked_low"
		&"hated": sfx = &"sfx_gift_hated_thud"
	am.call("play_sfx", sfx)


# === TASK 16: Relationship cinematic database ===
const MAX_AFFINITY_CINEMATICS: Dictionary = {
	&"pixel": &"cinematic_pixel_max_affinity",
	&"forge": &"cinematic_forge_max_affinity",
	&"cache": &"cinematic_cache_max_affinity",
	&"index": &"cinematic_index_max_affinity",
	&"harvest": &"cinematic_harvest_max_affinity",
	&"bit": &"cinematic_bit_max_affinity",
	&"legacy": &"cinematic_legacy_max_affinity",
	&"trade": &"cinematic_trade_max_affinity",
	&"lab": &"cinematic_lab_max_affinity",
	&"render": &"cinematic_render_max_affinity",
	&"sync": &"cinematic_sync_max_affinity",
	&"sentinel": &"cinematic_sentinel_max_affinity",
}


func trigger_max_affinity_cinematic(npc_id: StringName) -> bool:
	var cinematic_id: StringName = MAX_AFFINITY_CINEMATICS.get(npc_id, &"")
	if cinematic_id == &"":
		return false
	cinematic_triggered.emit(cinematic_id, npc_id)
	if has_node("/root/CinematicRevealManager"):
		var crm: Node = get_node("/root/CinematicRevealManager")
		if crm.has_method("try_play"):
			return bool(crm.call("try_play", cinematic_id))
	return true


# === TASK 17 + 18: Home visit interactions ===
func start_npc_visits_player_home(npc_id: StringName) -> void:
	home_visit_started.emit(&"player", npc_id)
	# Schedule the NPC's path to the player's home
	if has_node("/root/NPCScheduleSystem"):
		var ns: Node = get_node("/root/NPCScheduleSystem")
		if ns.has_method("schedule_visit"):
			ns.call("schedule_visit", npc_id, &"player_home")


func start_player_visits_npc_home(npc_id: StringName) -> void:
	home_visit_started.emit(npc_id, &"player")
	# Open NPC's home scene
	if has_node("/root/SceneManager"):
		var sm: Node = get_node("/root/SceneManager")
		if sm.has_method("load_npc_home"):
			sm.call("load_npc_home", npc_id)


# === TASK 22: Gift etiquette tutorial ===
const GIFT_TUTORIAL_FLAG: StringName = &"tutorial_gift_etiquette"
const GIFT_TUTORIAL_STEPS: Array[Dictionary] = [
	{"id": &"intro", "title": "Giving Gifts", "body": "Press [G] near an NPC to give them a gift from your inventory."},
	{"id": &"prefs", "title": "Gift Preferences", "body": "Each NPC loves, likes, or dislikes specific items. Their reactions tell you what to bring."},
	{"id": &"daily", "title": "Daily Cap", "body": "You can only give one gift per NPC per day. Birthday gifts count double."},
	{"id": &"birthday", "title": "Birthdays", "body": "Each NPC has a birthday once per in-game month. Loved gifts on birthdays grant a huge bonus."},
	{"id": &"loved", "title": "Loved Gifts", "body": "Loved gifts grant +80 affinity. Hated gifts cost -40. Choose wisely."},
]


func start_gift_tutorial() -> void:
	if _is_tutorial_seen(GIFT_TUTORIAL_FLAG):
		return
	for i in range(GIFT_TUTORIAL_STEPS.size()):
		var step: Dictionary = GIFT_TUTORIAL_STEPS[i]
		# Hand off to a tutorial UI manager
		if has_node("/root/TutorialUIManager"):
			var tum: Node = get_node("/root/TutorialUIManager")
			if tum.has_method("show_step"):
				tum.call("show_step", step.get("title", ""), step.get("body", ""), i)
	_set_flag(GIFT_TUTORIAL_FLAG, true)


# === TASK 31: Per-NPC affinity hint dialogue ===
const AFFINITY_HINT_LINES: Dictionary = {
	&"stranger": "I'm... still getting used to you.",
	&"friend": "It's nice to see you around.",
	&"confidant": "I trust you with this.",
	&"bond": "You're family to me now.",
	&"soul_linked": "Wherever you go, I'll be with you in spirit.",
}


func get_affinity_hint(level: StringName) -> String:
	return AFFINITY_HINT_LINES.get(level, "")


# === TASK 32: Gift wrap visual ===
func spawn_gift_wrap_on_hand(player_root: Node3D, wrap_variant: StringName = &"red") -> Node3D:
	# Build a quick gift wrap mesh in code (red box + gold ribbon)
	var box := MeshInstance3D.new()
	box.name = "GiftWrapBox"
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(0.30, 0.30, 0.30)
	box.mesh = box_mesh
	var box_color: Color = Color(0.85, 0.20, 0.25)
	match wrap_variant:
		&"blue": box_color = Color(0.20, 0.45, 0.85)
		&"violet": box_color = Color(0.55, 0.25, 0.85)
	var box_mat := StandardMaterial3D.new()
	box_mat.albedo_color = box_color
	box_mat.roughness = 0.5
	box.material_override = box_mat

	# Find right hand bone if present
	var skel: Skeleton3D = _find_skeleton(player_root)
	if skel != null:
		var bone_idx: int = skel.find_bone("hand_R")
		if bone_idx >= 0:
			var attach := BoneAttachment3D.new()
			attach.bone_idx = bone_idx
			attach.bone_name = "hand_R"
			skel.add_child(attach)
			attach.add_child(box)
			return box
	# Fallback: attach to player root
	box.position = Vector3(0.4, 1.0, 0.0)
	player_root.add_child(box)
	return box


func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node
	for child in node.get_children():
		var found: Skeleton3D = _find_skeleton(child)
		if found != null:
			return found
	return null


# === TASK 33: Reactive NPC poses for affinity levels ===
const NPC_POSE_BY_LEVEL: Dictionary = {
	&"stranger": &"npc_pose_arms_crossed",
	&"friend": &"npc_pose_relaxed",
	&"confidant": &"npc_pose_open_arms",
	&"bond": &"npc_pose_warm_smile",
	&"soul_linked": &"npc_pose_radiant",
}


func apply_pose_for_level(npc_id: StringName, level: StringName) -> void:
	var pose: StringName = NPC_POSE_BY_LEVEL.get(level, &"npc_pose_relaxed")
	if has_node("/root/NPCAnimationManager"):
		var nm: Node = get_node("/root/NPCAnimationManager")
		if nm.has_method("set_pose"):
			nm.call("set_pose", npc_id, pose)


# === TASK 43: UX validator with all 12 NPCs maxed ===
func validate_ux_all_maxed(npc_ids: Array[StringName]) -> Dictionary:
	var report: Dictionary = {
		"npc_count": npc_ids.size(),
		"warnings": [],
		"valid": true,
	}
	if npc_ids.size() != 12:
		report["warnings"].append("Expected 12 NPCs, got %d" % npc_ids.size())
	for npc_id in npc_ids:
		# Check that each has a max-affinity cinematic registered
		if not MAX_AFFINITY_CINEMATICS.has(npc_id):
			report["warnings"].append("Missing max-affinity cinematic for %s" % npc_id)
			report["valid"] = false
	return report


# === TASK 44: Gift inventory management test ===
func test_gift_inventory_flow() -> Dictionary:
	var report: Dictionary = {
		"inventory_reachable": false,
		"can_filter_gifts": false,
		"can_select_target_npc": false,
	}
	if has_node("/root/InventoryManager"):
		report["inventory_reachable"] = true
		var im: Node = get_node("/root/InventoryManager")
		if im.has_method("filter_gifts"):
			report["can_filter_gifts"] = true
	if has_node("/root/NPCManager"):
		var nm: Node = get_node("/root/NPCManager")
		if nm.has_method("get_nearest_npc"):
			report["can_select_target_npc"] = true
	return report


# === TASK 45: Affinity gain rate tuning ===
const TUNING_PRESETS: Dictionary = {
	&"casual": {"gift_loved": 100, "gift_liked": 50, "gift_neutral": 20, "gift_disliked": -20, "gift_hated": -50, "decay_per_day": 0},
	&"normal": {"gift_loved": 80, "gift_liked": 40, "gift_neutral": 15, "gift_disliked": -25, "gift_hated": -60, "decay_per_day": 5},
	&"hardcore": {"gift_loved": 60, "gift_liked": 30, "gift_neutral": 10, "gift_disliked": -35, "gift_hated": -80, "decay_per_day": 10},
}


func apply_tuning_preset(preset_id: StringName) -> Dictionary:
	var preset: Dictionary = TUNING_PRESETS.get(preset_id, {})
	if preset.is_empty():
		push_warning("AffinitySubsystems: unknown tuning preset %s" % preset_id)
		return {}
	if has_node("/root/AffinityManager"):
		var am: Node = get_node("/root/AffinityManager")
		if am.has_method("apply_gain_table"):
			am.call("apply_gain_table", preset)
	return preset


# === TASK 46: UX hints for missed gifts ===
func emit_missed_gift_hint(npc_id: StringName, days_until_birthday: int, has_loved_gift: bool) -> void:
	var urgency: int = 0
	var hint_text: String = ""
	if days_until_birthday <= 1 and has_loved_gift:
		urgency = 3
		hint_text = "%s's birthday is tomorrow! You have a loved gift in your inventory." % String(npc_id).capitalize()
	elif days_until_birthday <= 3:
		urgency = 2
		hint_text = "%s's birthday is in %d days." % [String(npc_id).capitalize(), days_until_birthday]
	elif has_loved_gift:
		urgency = 1
		hint_text = "You're carrying a gift that %s would love." % String(npc_id).capitalize()
	if hint_text != "":
		hint_emitted.emit(hint_text, urgency)


# === TASK 48: Affinity history log ===
var _history: Array[Dictionary] = []
const MAX_HISTORY_ENTRIES: int = 200


func log_history_entry(npc_id: StringName, change: int, reason: String, new_total: int) -> void:
	var entry: Dictionary = {
		"npc_id": npc_id,
		"change": change,
		"reason": reason,
		"new_total": new_total,
		"timestamp": Time.get_ticks_msec(),
	}
	_history.append(entry)
	while _history.size() > MAX_HISTORY_ENTRIES:
		_history.pop_front()
	history_entry_added.emit(entry)


func get_history_for_npc(npc_id: StringName) -> Array[Dictionary]:
	var filtered: Array[Dictionary] = []
	for entry in _history:
		if entry.get("npc_id", &"") == npc_id:
			filtered.append(entry)
	return filtered


func get_full_history() -> Array[Dictionary]:
	return _history.duplicate()


# === TASK 49: Story flag validation ===
func validate_against_story_flags(required_flags: Array[StringName]) -> Dictionary:
	var report: Dictionary = {"missing": [], "satisfied": []}
	if not has_node("/root/SaveManager"):
		report["missing"] = required_flags
		return report
	var sm: Node = get_node("/root/SaveManager")
	for flag in required_flags:
		if sm.has_method("get_flag") and bool(sm.call("get_flag", flag)):
			report["satisfied"].append(flag)
		else:
			report["missing"].append(flag)
	return report


# === Helpers ===
func _is_tutorial_seen(flag: StringName) -> bool:
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("get_flag"):
			return bool(sm.call("get_flag", flag))
	return false


func _set_flag(flag: StringName, value: bool) -> void:
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("set_flag"):
			sm.call("set_flag", flag, value)
