class_name SkillNode
extends Resource

## Single skill tree node. Lives inside a SkillTree resource alongside other
## nodes. Driven by data — adding a new node is just a new SkillNode entry.

@export var node_id: StringName = &""
@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D

## Position on the tree canvas (logical coordinates, not pixels). The UI
## layer scales these to the screen. Lets us treat the tree as a graph.
@export var grid_position: Vector2i = Vector2i.ZERO

## What other nodes must be allocated before this one becomes available.
## Empty array = root node (always available). All entries must be allocated.
@export var prerequisites: Array[StringName] = []

## Cost in skill points. Most nodes cost 1, keystones cost 3.
@export var cost: int = 1

## Maximum allocations. Most nodes are 1/1 (binary). Some are 5/5 (additive
## stat ramps).
@export var max_rank: int = 1

## Keystone flag — these are major nodes that change build identity.
## Tree UI renders them larger and with a glow halo.
@export var is_keystone: bool = false

## Effect specification — interpreted by SkillTree.apply_to_player().
## Format: { "type": StringName, "params": Dictionary }
##
## Supported types:
##   "stat_add"          — params: { stat: StringName, amount: float }
##   "stat_mult"         — params: { stat: StringName, multiplier: float }
##   "ability_unlock"    — params: { ability_id: StringName }
##   "ability_modifier"  — params: { ability_id, key, value }
##   "passive_unlock"    — params: { passive_id }
@export var effects: Array[Dictionary] = []

## Lore flavor for the tooltip footer
@export var lore: String = ""


func get_full_tooltip() -> String:
	var lines: PackedStringArray = []
	lines.append("[b]%s[/b]" % display_name)
	if is_keystone:
		lines.append("[color=#ffd96b]✦ KEYSTONE ✦[/color]")
	lines.append(description)
	lines.append("")
	for effect in effects:
		var t: StringName = effect.get("type", &"")
		var p: Dictionary = effect.get("params", {})
		match t:
			&"stat_add":
				var amt: float = p.get("amount", 0.0)
				var sign: String = "+" if amt >= 0 else ""
				lines.append("• %s %s%.1f" % [str(p.get("stat", "")).capitalize(), sign, amt])
			&"stat_mult":
				var m: float = p.get("multiplier", 1.0)
				var pct: float = (m - 1.0) * 100.0
				lines.append("• %s %s%.0f%%" % [str(p.get("stat", "")).capitalize(), "+" if pct >= 0 else "", pct])
			&"ability_unlock":
				lines.append("• Unlocks: %s" % p.get("ability_id", ""))
			&"ability_modifier":
				lines.append("• %s: %s = %s" % [p.get("ability_id", ""), p.get("key", ""), str(p.get("value", ""))])
			&"passive_unlock":
				lines.append("• Passive: %s" % p.get("passive_id", ""))
	if not lore.is_empty():
		lines.append("")
		lines.append("[i][color=#888]%s[/color][/i]" % lore)
	if cost > 1:
		lines.append("")
		lines.append("[color=#ffd96b]Cost: %d points[/color]" % cost)
	return "\n".join(lines)
