class_name ModuleLoadoutPresets
extends RefCounted

## Recommended 4-module loadouts for each class. Players can apply these
## via the loadout UI for quick build setup.

const PRESETS: Dictionary = {
	&"compiler": [
		{
			"name": "Lockdown Engineer",
			"description": "Pattern Lock everything. Don't get hit. Don't run out of compute.",
			"modules": [&"pattern_lock", &"recompile", &"stack_trace", &"memory_allocate"],
		},
		{
			"name": "Glass Cannon",
			"description": "Logic Bomb on cooldown. Mend when you can. Pattern Lock to survive.",
			"modules": [&"logic_bomb", &"iterative_mend", &"pattern_lock", &"branch_predict"],
		},
		{
			"name": "Versatile",
			"description": "Equal parts offense and defense. Hard to counter, hard to master.",
			"modules": [&"recompile", &"pattern_lock", &"iterative_mend", &"healing_prompt"],
		},
	],
	&"daemon": [
		{
			"name": "Crit Maximizer",
			"description": "Hunter's Mark + Massacre Protocol. Mark, dash, kill, repeat.",
			"modules": [&"hunters_mark", &"massacre_protocol", &"phase_strike", &"smoke_veil"],
		},
		{
			"name": "Bleed Stack",
			"description": "DOT specialist. Stack bleeds and acid pools, run away.",
			"modules": [&"bleed_out", &"acid_splash", &"smoke_veil", &"backstep"],
		},
		{
			"name": "Shadow Master",
			"description": "Stealth + clones. Be everywhere at once.",
			"modules": [&"smoke_veil", &"shadow_clone", &"phase_strike", &"decoy_daemon"],
		},
	],
	&"kernel": [
		{
			"name": "Living Wall",
			"description": "Bulwark + Aegis + Iron Will. Be the wall.",
			"modules": [&"bulwark", &"aegis_protocol", &"iron_will", &"thorn_aegis"],
		},
		{
			"name": "Ground Shaker",
			"description": "AoE everywhere. Pull, slam, repeat.",
			"modules": [&"gravity_well", &"thunder_strike", &"earthquake", &"overclock_reactor"],
		},
		{
			"name": "Defensive Anchor",
			"description": "Provoke + defense. Make every enemy come to you.",
			"modules": [&"bulwark", &"provoke", &"thorn_aegis", &"healing_prompt"],
		},
	],
}


static func get_presets(class_id: StringName) -> Array:
	return PRESETS.get(class_id, [])


static func apply_preset(equipment: Node, class_id: StringName, preset_index: int) -> bool:
	var presets: Array = get_presets(class_id)
	if preset_index < 0 or preset_index >= presets.size():
		return false
	if equipment == null or not equipment.has_method("equip_module"):
		return false
	var preset: Dictionary = presets[preset_index]
	var modules: Array = preset.get("modules", [])
	for i in range(min(modules.size(), 4)):
		equipment.equip_module(i, modules[i])
	return true
