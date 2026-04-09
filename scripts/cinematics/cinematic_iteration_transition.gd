class_name CinematicIterationTransition
extends RefCounted

## Generic iteration transition cinematic. Plays after defeating the
## iteration boss. Per-iteration dialogue is parameterized so all 8
## transitions reuse this template.

const ITERATION_LINES: Dictionary = {
	1: {
		"npc_id": &"sage",
		"emotion": &"surprised",
		"lines": [
			"You did it. Again.",
			"You don't remember the first time, do you?",
		],
	},
	2: {
		"npc_id": &"sage",
		"emotion": &"neutral",
		"lines": [
			"The Reflection has appeared. Use it.",
			"Choices await.",
		],
	},
	3: {
		"npc_id": &"sage",
		"emotion": &"sad",
		"lines": [
			"The corruption is spreading.",
			"Be careful what you fight.",
		],
	},
	4: {
		"npc_id": &"sage",
		"emotion": &"neutral",
		"lines": [
			"Some things are worth remembering.",
			"The Memorial holds them now.",
		],
	},
	5: {
		"npc_id": &"sage",
		"emotion": &"surprised",
		"lines": [
			"You've found the User's Mark.",
			"They know you exist now.",
		],
	},
	6: {
		"npc_id": &"sage",
		"emotion": &"questioning",
		"lines": [
			"The factions are watching you.",
			"Which side will you choose?",
		],
	},
	7: {
		"npc_id": &"sage",
		"emotion": &"sad",
		"lines": [
			"I haven't been honest with you.",
			"I am part of this loop too.",
		],
	},
	8: {
		"npc_id": &"sage",
		"emotion": &"neutral",
		"lines": [
			"This is the final iteration.",
			"What comes next is up to you.",
		],
	},
}


static func build_timeline(iteration: int) -> Array:
	var lines_data: Dictionary = ITERATION_LINES.get(iteration, {})
	var npc_id: StringName = lines_data.get("npc_id", &"sage")
	var emotion: StringName = lines_data.get("emotion", &"neutral")
	var lines: Array = lines_data.get("lines", [])

	var timeline: Array = [
		# 1. Freeze player + zoom to Globbler
		{"type": &"camera_move", "position": Vector3(0, 2, -3), "look_at": Vector3(0, 1, 0), "duration": 1.5},

		# 2. White flash + glitch sweep
		{"type": &"play_sfx", "sfx_id": &"environment_glitch_pulse"},
		{"type": &"camera_shake", "intensity": 0.3, "duration": 0.5},
		{"type": &"fade", "color": Color.WHITE, "alpha": 1.0, "duration": 0.3},
		{"type": &"wait", "duration": 0.5},
		{"type": &"fade", "color": Color(0,0,0,0), "alpha": 0.0, "duration": 0.8},

		# 3. Iteration X complete banner
		{"type": &"set_letterbox", "visible": true, "duration": 0.4},
		{"type": &"play_dialogue", "npc_id": &"sage", "emotion": &"neutral",
		 "text": "ITERATION %d COMPLETE" % iteration, "duration": 2.5},

		# 4. Iteration-specific reveal
		{"type": &"play_music", "track_id": &"iteration_reset"},
	]

	# Add per-iteration lines
	for line_text: String in lines:
		timeline.append({
			"type": &"play_dialogue",
			"npc_id": npc_id,
			"emotion": emotion,
			"text": line_text,
			"duration": 3.5,
		})

	# Final cleanup
	timeline.append_array([
		{"type": &"wait", "duration": 1.0},
		{"type": &"set_letterbox", "visible": false, "duration": 0.6},
		{"type": &"signal", "signal_name": &"iteration_transition_finished"},
	])

	return timeline


static func get_id_for_iteration(iteration: int) -> StringName:
	return StringName("iter_%d_to_%d" % [iteration, iteration + 1])
