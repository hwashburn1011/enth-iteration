class_name OutfitSetDefinitions
extends RefCounted

## Static catalog of all 8 outfit sets with their tuned PBR values.
## These metallic and roughness values are calibrated to read at gameplay
## distance under the 5 standard lighting environments.
##
## Used by:
##   - EquipmentVisualizer to apply correct material values when attaching
##   - OutfitSetGenerator to bake reference glb files
##   - Inventory tooltips to display set metadata

const SETS: Dictionary = {
	&"outfit_initiate": {
		"display_name": "Initiate",
		"rarity": 0,
		"primary":   Color(0.65, 0.62, 0.55),
		"secondary": Color(0.50, 0.48, 0.42),
		"accent":    Color(0.75, 0.72, 0.65),
		"metallic":  0.20,
		"roughness": 0.65,
		"emission":  Color(0, 0, 0),
		"em_strength": 0.0,
		"lore_tag": "Standard issue. Property of the System.",
	},
	&"outfit_patcher": {
		"display_name": "Patcher",
		"rarity": 1,
		"primary":   Color(0.55, 0.50, 0.30),
		"secondary": Color(0.35, 0.32, 0.20),
		"accent":    Color(0.80, 0.65, 0.30),
		"metallic":  0.40,
		"roughness": 0.55,
		"emission":  Color(0, 0, 0),
		"em_strength": 0.0,
		"lore_tag": "Patched 47 times. Still holding.",
	},
	&"outfit_compiler": {
		"display_name": "Compiler",
		"rarity": 2,
		"primary":   Color(0.20, 0.30, 0.70),
		"secondary": Color(0.10, 0.18, 0.50),
		"accent":    Color(0.90, 0.90, 0.95),
		"metallic":  0.60,
		"roughness": 0.30,
		"emission":  Color(0.30, 0.50, 1.00),
		"em_strength": 1.5,
		"lore_tag": "Pattern recognized. Welcome, friend.",
	},
	&"outfit_kernel": {
		"display_name": "Kernel",
		"rarity": 3,
		"primary":   Color(0.15, 0.10, 0.30),
		"secondary": Color(0.10, 0.08, 0.18),
		"accent":    Color(0.90, 0.75, 0.20),
		"metallic":  0.85,
		"roughness": 0.20,
		"emission":  Color(0.60, 0.30, 1.00),
		"em_strength": 2.5,
		"lore_tag": "The kernel does not negotiate.",
	},
	&"outfit_architect": {
		"display_name": "Architect",
		"rarity": 4,
		"primary":   Color(0.85, 0.80, 0.65),
		"secondary": Color(0.70, 0.65, 0.50),
		"accent":    Color(0.95, 0.80, 0.30),
		"metallic":  0.70,
		"roughness": 0.25,
		"emission":  Color(1.00, 0.85, 0.40),
		"em_strength": 3.5,
		"lore_tag": "The first to wake. The last to fall.",
	},
	&"outfit_glitch": {
		"display_name": "Glitch",
		"rarity": 5,
		"primary":   Color(0.40, 0.05, 0.20),
		"secondary": Color(0.20, 0.03, 0.10),
		"accent":    Color(0.10, 0.95, 0.50),
		"metallic":  0.50,
		"roughness": 0.40,
		"emission":  Color(0.20, 1.00, 0.30),
		"em_strength": 4.0,
		"lore_tag": "ERROR: integrity check skipped",
	},
	&"outfit_cozy": {
		"display_name": "Cozy",
		"rarity": 0,
		"primary":   Color(0.45, 0.30, 0.20),
		"secondary": Color(0.30, 0.20, 0.15),
		"accent":    Color(0.80, 0.70, 0.55),
		"metallic":  0.00,
		"roughness": 0.85,
		"emission":  Color(0, 0, 0),
		"em_strength": 0.0,
		"lore_tag": "Off-duty mode engaged.",
	},
	&"outfit_boss_reward": {
		"display_name": "Compiler's Gift",
		"rarity": 4,
		"primary":   Color(0.25, 0.05, 0.05),
		"secondary": Color(0.50, 0.40, 0.05),
		"accent":    Color(1.00, 0.85, 0.30),
		"metallic":  0.95,
		"roughness": 0.15,
		"emission":  Color(1.00, 0.40, 0.10),
		"em_strength": 5.0,
		"lore_tag": "The Compiler's gift. Bear it well.",
	},
}


static func get_set(set_id: StringName) -> Dictionary:
	return SETS.get(set_id, {})


static func get_all_set_ids() -> Array:
	return SETS.keys()


static func apply_to_material(material: StandardMaterial3D, set_id: StringName, slot_role: StringName = &"primary") -> void:
	var info: Dictionary = get_set(set_id)
	if info.is_empty():
		return
	var color_key: String = "primary"
	if slot_role == &"secondary":
		color_key = "secondary"
	elif slot_role == &"accent":
		color_key = "accent"

	material.albedo_color = info[color_key]
	material.metallic = info["metallic"]
	material.roughness = info["roughness"]
	if info["em_strength"] > 0.0:
		material.emission_enabled = true
		material.emission = info["emission"]
		material.emission_energy_multiplier = info["em_strength"]
	else:
		material.emission_enabled = false
