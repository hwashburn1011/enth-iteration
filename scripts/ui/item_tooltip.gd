class_name ItemTooltip
extends RefCounted
## Post-V1 Epic A #7 — item comparison tooltip helper.
##
## Static methods that generate comparison text between two items,
## showing stat +/- differences. Used by vendor shop and inventory.

## Returns a formatted comparison string showing stat differences.
## Positive differences are green "+X", negative are red "-X".
static func compare_items(new_item: Resource, equipped_item: Resource) -> String:
	if new_item == null:
		return ""
	var lines: Array[String] = []
	# Item name + rarity
	var name_text: String = str(new_item.get(&"item_name")) if &"item_name" in new_item else str(new_item.get(&"item_id", "???"))
	lines.append(name_text)

	# Stat modifiers comparison
	var new_mods: Dictionary = {}
	if &"stat_modifiers" in new_item:
		new_mods = new_item.get(&"stat_modifiers") as Dictionary
	var old_mods: Dictionary = {}
	if equipped_item != null and &"stat_modifiers" in equipped_item:
		old_mods = equipped_item.get(&"stat_modifiers") as Dictionary

	# Collect all stat keys
	var all_stats: Array[String] = []
	for k: String in new_mods:
		if k not in all_stats:
			all_stats.append(k)
	for k: String in old_mods:
		if k not in all_stats:
			all_stats.append(k)

	for stat: String in all_stats:
		var new_val: float = float(new_mods.get(stat, 0.0))
		var old_val: float = float(old_mods.get(stat, 0.0))
		var diff: float = new_val - old_val
		if absf(diff) < 0.01:
			lines.append("  %s: %.1f" % [stat, new_val])
		elif diff > 0:
			lines.append("  %s: %.1f [color=green](+%.1f)[/color]" % [stat, new_val, diff])
		else:
			lines.append("  %s: %.1f [color=red](%.1f)[/color]" % [stat, new_val, diff])

	return "\n".join(lines)


## Returns a simple stat summary for an item (no comparison).
static func item_summary(item: Resource) -> String:
	if item == null:
		return ""
	var lines: Array[String] = []
	var name_text: String = str(item.get(&"item_name")) if &"item_name" in item else str(item.get(&"item_id", "???"))
	lines.append(name_text)
	if &"stat_modifiers" in item:
		var mods: Dictionary = item.get(&"stat_modifiers") as Dictionary
		for k: String in mods:
			lines.append("  %s: +%.1f" % [k, float(mods[k])])
	return "\n".join(lines)
