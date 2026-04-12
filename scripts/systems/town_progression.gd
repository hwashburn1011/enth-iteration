class_name TownProgression
extends RefCounted
## Post-V1 Epic B #15 — town visual progression per iteration.
##
## Small environment tweaks each iteration: new lanterns, repaired
## structures, additional particles. Called from town.gd on _ready.

## Visual changes keyed by minimum iteration.
const CHANGES: Array[Dictionary] = [
	{"min_iter": 2, "type": "lantern_color", "color": [0.4, 0.3, 0.8], "desc": "violet lanterns"},
	{"min_iter": 3, "type": "ground_tint", "color": [0.9, 0.8, 0.6], "desc": "amber ground tint"},
	{"min_iter": 4, "type": "sky_particles", "amount": 12, "desc": "data rain particles"},
]


## Returns the list of visual changes active at the given iteration.
static func get_active_changes(iteration: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for change: Dictionary in CHANGES:
		if iteration >= int(change.get("min_iter", 1)):
			result.append(change)
	return result
