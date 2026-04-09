class_name SkillTreePresets
extends RefCounted

## 3 preset builds per class — beginner-friendly templates that allocate
## skill points along a recommended path. Players click "Apply Preset" in
## the skill tree UI to fill in the suggested allocation.

const PRESETS: Dictionary = {
	&"compiler": [
		{
			"name": "Pattern Master",
			"description": "Lockdown specialist. Pattern Lock cycles + Recompile + sustain.",
			"nodes": [&"comp_root", &"comp_order_1", &"comp_order_3", &"comp_order_2", &"comp_order_4", &"comp_order_7", &"comp_sys_1"],
		},
		{
			"name": "Glass Engineer",
			"description": "Pure DPS. Logic Bomb path + crits.",
			"nodes": [&"comp_root", &"comp_logic_1", &"comp_logic_2", &"comp_logic_3", &"comp_logic_5", &"comp_logic_6", &"comp_logic_8"],
		},
		{
			"name": "Self-Sustaining",
			"description": "Endless Loop build. Resource regen + economy.",
			"nodes": [&"comp_root", &"comp_sys_1", &"comp_sys_2", &"comp_sys_3", &"comp_sys_5", &"comp_sys_8"],
		},
	],
	&"daemon": [
		{
			"name": "Wind Reaper",
			"description": "Speed + dash spam. Phantom Step keystone.",
			"nodes": [&"daem_root", &"daem_speed_1", &"daem_speed_2", &"daem_speed_5", &"daem_speed_4", &"daem_speed_6"],
		},
		{
			"name": "Critical Mass",
			"description": "Crit + bleed stacking. Massacre Protocol payoff.",
			"nodes": [&"daem_root", &"daem_leth_1", &"daem_leth_2", &"daem_leth_3", &"daem_leth_4", &"daem_leth_5", &"daem_leth_6"],
		},
		{
			"name": "From the Shadows",
			"description": "Stealth + first-strike crits. Vanish keystone.",
			"nodes": [&"daem_root", &"daem_stl_1", &"daem_stl_4", &"daem_stl_2", &"daem_stl_3", &"daem_stl_5"],
		},
	],
	&"kernel": [
		{
			"name": "Living Wall",
			"description": "Pure tank. Bulwark + Aegis + Last Stand.",
			"nodes": [&"kern_root", &"kern_fort_1", &"kern_fort_3", &"kern_fort_2", &"kern_fort_4", &"kern_fort_6"],
		},
		{
			"name": "Hammer of the Kernel",
			"description": "Heavy DPS. Thunder Strike + Overclock Reactor.",
			"nodes": [&"kern_root", &"kern_pow_1", &"kern_pow_2", &"kern_pow_3", &"kern_pow_4", &"kern_pow_5"],
		},
		{
			"name": "Earth Shaker",
			"description": "Control / area denial. Gravity Well + Ground Pound.",
			"nodes": [&"kern_root", &"kern_ctrl_1", &"kern_ctrl_2", &"kern_ctrl_3", &"kern_ctrl_4"],
		},
	],
}


static func get_presets_for_class(class_id: StringName) -> Array:
	return PRESETS.get(class_id, [])


static func apply_preset(component: SkillTreeComponent, class_id: StringName, preset_index: int) -> bool:
	var presets: Array = get_presets_for_class(class_id)
	if preset_index < 0 or preset_index >= presets.size():
		return false
	component.reset_allocation()
	var preset: Dictionary = presets[preset_index]
	var nodes: Array = preset.get("nodes", [])
	for node_id: StringName in nodes:
		# Try to allocate, even if we fail (cost gating, prereq), we continue
		component.allocate(node_id)
	return true
