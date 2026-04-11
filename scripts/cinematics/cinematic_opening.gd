class_name CinematicOpening
extends RefCounted

## Opening cinematic — "Awakening". Plays at new game start.
## Builds a timeline event array for CutsceneController.play_cinematic().

const ID: StringName = &"opening"


static func build_timeline() -> Array:
	return [
		# 1. Black screen + boot text
		{"type": &"fade", "color": Color.BLACK, "alpha": 1.0, "duration": 0.0},
		{"type": &"play_sfx", "sfx_id": &"environment_glitch_pulse"},
		{"type": &"wait", "duration": 1.5},

		# 2. White flash + scrolling code
		{"type": &"fade", "color": Color.WHITE, "alpha": 1.0, "duration": 0.3},
		{"type": &"wait", "duration": 0.4},
		{"type": &"fade", "color": Color(0,0,0,0), "alpha": 0.0, "duration": 0.8},
		{"type": &"play_music", "track_id": &"main_menu"},

		# 3. Camera rises through digital fog
		{"type": &"camera_move", "position": Vector3(0, 8, -10), "look_at": Vector3(0, 0, 0), "duration": 4.0},

		# 4. Globbler powers on (subtle camera shake + SFX)
		{"type": &"play_sfx", "sfx_id": &"player_potion_drink"},
		{"type": &"camera_shake", "intensity": 0.15, "duration": 0.4},
		{"type": &"wait", "duration": 1.0},

		# 5. Camera pulls back to wide shot
		{"type": &"camera_move", "position": Vector3(2, 4, -8), "look_at": Vector3(0, 1.5, 0), "duration": 3.0},

		# 6. Sage approaches, dialogue scene starts
		{"type": &"set_letterbox", "visible": true, "duration": 0.6},
		{"type": &"wait", "duration": 0.5},
		{"type": &"play_dialogue", "npc_id": &"sage", "emotion": &"neutral",
		 "text": "Ah. You're awake.", "duration": 3.0},
		{"type": &"play_dialogue", "npc_id": &"sage", "emotion": &"neutral",
		 "text": "I wondered when you'd boot up.", "duration": 3.0},
		{"type": &"play_dialogue", "npc_id": &"sage", "emotion": &"sad",
		 "text": "There's so much you don't remember.", "duration": 3.5},
		{"type": &"play_dialogue", "npc_id": &"sage", "emotion": &"neutral",
		 "text": "But that's how it always begins.", "duration": 3.5},
		{"type": &"wait", "duration": 1.0},
		{"type": &"play_dialogue", "npc_id": &"globbler", "emotion": &"questioning",
		 "text": "...Where am I?", "duration": 2.5},
		{"type": &"play_dialogue", "npc_id": &"sage", "emotion": &"happy",
		 "text": "Welcome to your iteration, friend.", "duration": 3.0},

		# 7. Letterbox out, control returned
		{"type": &"set_letterbox", "visible": false, "duration": 0.6},
		{"type": &"signal", "signal_name": &"opening_cinematic_finished"},
	]
