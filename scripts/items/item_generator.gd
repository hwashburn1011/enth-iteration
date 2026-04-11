class_name ItemGenerator
extends RefCounted
## Generates randomized items with rarity-based affixes.

const RARITY_WEIGHTS: Array[float] = [0.60, 0.25, 0.12, 0.03]  # Common, Uncommon, Rare, Legendary
const RARITY_MULTIPLIERS: Array[float] = [1.0, 1.2, 1.5, 2.0]
const AFFIX_COUNTS: Array[Vector2i] = [
	Vector2i(0, 1),  # Common: 0-1
	Vector2i(1, 2),  # Uncommon: 1-2
	Vector2i(2, 3),  # Rare: 2-3
	Vector2i(3, 4),  # Legendary: 3-4
]

static var _affix_db: Resource = null


static func generate_item(base_item: Resource, rarity_override: int = -1) -> Resource:
	# 1. Duplicate the base item
	var item: Resource = base_item.duplicate(true) as Resource

	# 2. Determine rarity
	if rarity_override >= 0 and rarity_override <= 3:
		item.rarity = rarity_override
	else:
		item.rarity = _roll_rarity()

	# 3. Load affix database
	_ensure_affix_db()

	# 4. Roll affixes
	if _affix_db:
		var affix_range: Vector2i = AFFIX_COUNTS[item.rarity]
		var affix_count: int = randi_range(affix_range.x, affix_range.y)
		var eligible: Array = _affix_db.get_eligible_affixes(item.rarity, item.item_type)

		# 5. Scale base stats by rarity multiplier BEFORE adding affixes
		var multiplier: float = RARITY_MULTIPLIERS[item.rarity]
		for stat_name: String in item.stat_modifiers:
			item.stat_modifiers[stat_name] = float(item.stat_modifiers[stat_name]) * multiplier

		var used_names: Array[String] = []
		var attempts: int = 0
		var applied: int = 0
		while applied < affix_count and attempts < affix_count * 3:
			attempts += 1
			if eligible.is_empty():
				break
			var affix: Resource = eligible[randi() % eligible.size()]
			# Prevent duplicate affixes
			if affix.affix_name in used_names:
				continue
			used_names.append(affix.affix_name)
			applied += 1
			var value: float = randf_range(affix.min_value, affix.max_value)
			var current: float = float(item.stat_modifiers.get(affix.stat_name, 0.0))
			item.stat_modifiers[affix.stat_name] = current + value

	# 6. Reset durability
	item.current_durability = item.max_durability

	return item


static func _roll_rarity() -> int:
	var roll: float = randf()
	var cumulative: float = 0.0
	for i: int in RARITY_WEIGHTS.size():
		cumulative += RARITY_WEIGHTS[i]
		if roll <= cumulative:
			return i
	return 0


static func _ensure_affix_db() -> void:
	if _affix_db == null:
		_affix_db = load("res://data/items/affix_database.tres") as Resource
