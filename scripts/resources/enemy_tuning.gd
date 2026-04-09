class_name EnemyTuning
extends Resource

## Per-enemy tuning data: HP/damage curves across 5 floor tiers,
## drop table reference, aggro range, group composition presets.
## Covers Epic 08 tasks 35 (balance), 36 (drop tables), 45 (aggro tuning),
## 46 (composition presets) in a single data-driven Resource.
##
## Each enemy in the Epic 08 roster gets its own .tres file at
## res://data/enemies/tuning/<enemy_id>_tuning.tres
##
## The 5 floor tiers represent the difficulty curve as the player
## descends through dungeon depth. Tier 0 = first floor (introduction),
## tier 4 = late-game (deadly).

@export var enemy_id: StringName = &""
@export var display_name: String = ""

# === HP CURVE (5 floor tiers) ===
@export var base_hp_per_tier: PackedFloat32Array = PackedFloat32Array([60, 90, 130, 180, 250])

# === DAMAGE CURVE (5 floor tiers) ===
@export var base_damage_per_tier: PackedFloat32Array = PackedFloat32Array([8, 12, 17, 23, 32])

# === MOVEMENT ===
@export_range(0.0, 20.0) var move_speed_m_s: float = 4.0

# === AGGRO ===
@export_range(0.0, 50.0) var aggro_range_m: float = 12.0
@export_range(0.0, 50.0) var leash_range_m: float = 25.0

# === LOOT ===
@export var loot_table: Resource  # references LootTable resource
@export_range(0.0, 1.0) var rare_drop_chance: float = 0.05
@export var unique_drop_id: StringName = &""

# === XP ===
@export var xp_value_per_tier: PackedInt32Array = PackedInt32Array([10, 18, 28, 42, 60])

# === GROUP COMPOSITION ===
## When this enemy is selected for a spawn, what other enemies tend to
## appear with it? Used by the spawner to build coherent encounters.
## Each entry is {enemy_id: StringName, count: int, weight: float}
@export var group_composition_presets: Array[Dictionary] = []

# === FLOOR TIER UNLOCKS ===
## The earliest floor tier this enemy can appear on (0..4).
## Used by the spawner to gate enemies behind progression.
@export_range(0, 4) var min_floor_tier: int = 0
## The latest floor tier this enemy can appear on (post-this it stops
## spawning, replaced by tougher variants). -1 = never stops.
@export_range(-1, 4) var max_floor_tier: int = -1


func get_hp_for_tier(tier: int) -> float:
	tier = clamp(tier, 0, base_hp_per_tier.size() - 1)
	return base_hp_per_tier[tier]


func get_damage_for_tier(tier: int) -> float:
	tier = clamp(tier, 0, base_damage_per_tier.size() - 1)
	return base_damage_per_tier[tier]


func get_xp_for_tier(tier: int) -> int:
	tier = clamp(tier, 0, xp_value_per_tier.size() - 1)
	return xp_value_per_tier[tier]


func can_spawn_on_tier(tier: int) -> bool:
	if tier < min_floor_tier:
		return false
	if max_floor_tier >= 0 and tier > max_floor_tier:
		return false
	return true
