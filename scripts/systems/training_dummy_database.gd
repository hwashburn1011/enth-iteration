class_name TrainingDummyDatabase
extends RefCounted

## Catalog of training dummy archetypes for the training arena. Each
## dummy is a specialized practice target — stationary humanoid for
## raw melee, fast-moving humanoid for tracking, large slow tank for
## sustained DPS, floating sphere for projectile aim, multi-target
## cluster for AOE, boss tank with stagger meter for ultimate practice.
##
## Where the wilderness enemy database has hostile combat encounters,
## these are explicitly NON-hostile — they take damage and emit
## telemetry, but never die, never deal damage, and reset on lever pull.
##
## Each entry defines:
##   - id, display_name, description, archetype tag
##   - max_health, armor, dodge_chance (test what the player's build hits)
##   - movement_pattern (stationary / patrol / hover / cluster_orbit)
##   - movement_speed (m/s)
##   - has_stagger_meter (boss tank only)
##   - hit_radius (collision shape size)
##   - resistance_profile (test elemental builds)

const DUMMIES: Array[Dictionary] = [
	{
		"id": &"dummy_humanoid_stationary",
		"display_name": "Practice Dummy",
		"description": "Stationary humanoid. The first thing you hit. Read your basic damage numbers here.",
		"archetype": &"raw_melee",
		"max_health": 9999,
		"armor": 0,
		"dodge_chance": 0.0,
		"movement_pattern": &"stationary",
		"movement_speed": 0.0,
		"has_stagger_meter": false,
		"hit_radius": 0.6,
		"resistance_profile": {},
	},
	{
		"id": &"dummy_humanoid_patrol",
		"display_name": "Tracking Dummy",
		"description": "Small humanoid that walks a fixed patrol. Test your aim against a moving target.",
		"archetype": &"tracking",
		"max_health": 9999,
		"armor": 0,
		"dodge_chance": 0.0,
		"movement_pattern": &"patrol",
		"movement_speed": 4.5,
		"has_stagger_meter": false,
		"hit_radius": 0.5,
		"resistance_profile": {},
	},
	{
		"id": &"dummy_tank_large",
		"display_name": "Sustained DPS Tank",
		"description": "A large slow tank with armor 25. Use this to test how your build holds up over a 20-second window.",
		"archetype": &"sustained_dps",
		"max_health": 99999,
		"armor": 25,
		"dodge_chance": 0.0,
		"movement_pattern": &"stationary",
		"movement_speed": 0.0,
		"has_stagger_meter": false,
		"hit_radius": 1.4,
		"resistance_profile": {},
	},
	{
		"id": &"dummy_floating_sphere",
		"display_name": "Aim Sphere",
		"description": "A small floating sphere. Tests your projectile aim — every miss is visible.",
		"archetype": &"projectile_aim",
		"max_health": 9999,
		"armor": 0,
		"dodge_chance": 0.0,
		"movement_pattern": &"hover",
		"movement_speed": 1.5,
		"has_stagger_meter": false,
		"hit_radius": 0.4,
		"resistance_profile": {},
	},
	{
		"id": &"dummy_cluster",
		"display_name": "Multi-Target Cluster",
		"description": "Three small dummies in formation. Test your AOE abilities — does the third one really die?",
		"archetype": &"aoe_test",
		"max_health": 5000,
		"armor": 0,
		"dodge_chance": 0.0,
		"movement_pattern": &"cluster_orbit",
		"movement_speed": 0.5,
		"has_stagger_meter": false,
		"hit_radius": 0.5,
		"resistance_profile": {},
		"cluster_count": 3,
		"cluster_radius": 1.5,
	},
	{
		"id": &"dummy_boss_stagger",
		"display_name": "Boss Tank",
		"description": "Boss-sized armor tank with a stagger meter. Practice your ultimate windups here. Stagger triggers a 5-second window where damage is doubled — same as the real boss.",
		"archetype": &"ultimate_practice",
		"max_health": 999999,
		"armor": 50,
		"dodge_chance": 0.0,
		"movement_pattern": &"stationary",
		"movement_speed": 0.0,
		"has_stagger_meter": true,
		"stagger_threshold": 5000,
		"stagger_window_s": 5.0,
		"hit_radius": 2.2,
		"resistance_profile": {},
	},
]

static var _index: Dictionary = {}


static func _ensure_index() -> void:
	if not _index.is_empty():
		return
	for entry: Dictionary in DUMMIES:
		_index[entry["id"]] = entry


static func get_dummy(dummy_id: StringName) -> Dictionary:
	_ensure_index()
	return _index.get(dummy_id, {})


static func get_all() -> Array[Dictionary]:
	return DUMMIES.duplicate()


static func get_count() -> int:
	return DUMMIES.size()
