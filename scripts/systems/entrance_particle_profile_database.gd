class_name EntranceParticleProfileDatabase
extends RefCounted

## Per-entrance ambient particle profiles. Each profile defines a code-
## buildable ParticleProcessMaterial config plus emission box, lifetime,
## and color so the DungeonEntranceAmbience component can spawn matching
## particle beds for each of the 4 dungeon entrances without authoring
## separate particle scenes by hand.
##
## Each profile is themed to its biome's identity:
##   server_room      → cold blue snow drifting downward
##   memory_vaults    → gold dust motes hanging in still air
##   corrupted_wilds  → organic green spores rising slowly with rotation
##   final_vault      → white-violet void shimmer with random burst pattern

const PROFILES: Dictionary = {
	&"server_room": {
		"display_name": "Server Frost",
		"amount": 220,
		"lifetime": 3.5,
		"emission_box_extents": Vector3(8, 0.5, 8),
		"emission_box_offset": Vector3(0, 6, 0),
		"gravity": Vector3(0.4, -2.5, 0.0),
		"initial_velocity_min": 0.2,
		"initial_velocity_max": 0.8,
		"scale_min": 0.05,
		"scale_max": 0.12,
		"color": Color(0.65, 0.85, 1.00, 0.75),
		"emission_color": Color(0.40, 0.70, 1.00, 1.00),
		"emission_energy": 0.6,
		"angular_velocity_min": -30.0,
		"angular_velocity_max": 30.0,
		"direction": Vector3(0, -1, 0),
		"spread": 12.0,
	},
	&"memory_vaults": {
		"display_name": "Vault Dust",
		"amount": 140,
		"lifetime": 6.0,
		"emission_box_extents": Vector3(6, 3, 6),
		"emission_box_offset": Vector3(0, 2, 0),
		"gravity": Vector3(0.0, -0.05, 0.0),
		"initial_velocity_min": 0.05,
		"initial_velocity_max": 0.25,
		"scale_min": 0.04,
		"scale_max": 0.10,
		"color": Color(1.00, 0.92, 0.65, 0.70),
		"emission_color": Color(1.00, 0.85, 0.40, 1.00),
		"emission_energy": 0.8,
		"angular_velocity_min": -10.0,
		"angular_velocity_max": 10.0,
		"direction": Vector3(0.3, 0.5, 0.2),
		"spread": 70.0,
	},
	&"corrupted_wilds": {
		"display_name": "Wilds Spores",
		"amount": 180,
		"lifetime": 4.5,
		"emission_box_extents": Vector3(7, 0.5, 7),
		"emission_box_offset": Vector3(0, 0.6, 0),
		"gravity": Vector3(0.0, 0.4, 0.0),  # rises
		"initial_velocity_min": 0.3,
		"initial_velocity_max": 0.9,
		"scale_min": 0.06,
		"scale_max": 0.18,
		"color": Color(0.55, 0.95, 0.55, 0.65),
		"emission_color": Color(0.40, 1.00, 0.50, 1.00),
		"emission_energy": 0.9,
		"angular_velocity_min": -90.0,
		"angular_velocity_max": 90.0,
		"direction": Vector3(0, 1, 0),
		"spread": 35.0,
	},
	&"final_vault": {
		"display_name": "Void Shimmer",
		"amount": 260,
		"lifetime": 2.8,
		"emission_box_extents": Vector3(5, 4, 5),
		"emission_box_offset": Vector3(0, 2, 0),
		"gravity": Vector3(0.0, 0.0, 0.0),
		"initial_velocity_min": 0.4,
		"initial_velocity_max": 1.4,
		"scale_min": 0.04,
		"scale_max": 0.14,
		"color": Color(0.95, 0.85, 1.00, 0.80),
		"emission_color": Color(0.85, 0.70, 1.00, 1.00),
		"emission_energy": 1.4,
		"angular_velocity_min": -180.0,
		"angular_velocity_max": 180.0,
		"direction": Vector3.ZERO,
		"spread": 180.0,
	},
}


static func get_profile(profile_id: StringName) -> Dictionary:
	return PROFILES.get(profile_id, {})


static func get_count() -> int:
	return PROFILES.size()
