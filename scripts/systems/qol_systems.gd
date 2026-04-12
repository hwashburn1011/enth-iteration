class_name QoLSystems
extends RefCounted
## Post-V1 Epic E — Systems & QoL config and helpers (items 41-50).
##
## E41: Minimap config
## E42: Damage log
## E43: Auto-pickup for gold
## E44: Item rarity filter
## E45: Screenshot mode
## E46: Accessibility font sizes
## E47: Colorblind mode palettes
## E48: Skip cinematic flag
## E49: Statistics panel data
## E50: Gamepad input map

## E41: Minimap config.
const MINIMAP_SIZE: Vector2 = Vector2(180, 180)
const MINIMAP_ZOOM: float = 0.15
const MINIMAP_PLAYER_COLOR: Color = Color(0.3, 0.9, 0.8)
const MINIMAP_EXIT_COLOR: Color = Color(0.9, 0.8, 0.2)
const MINIMAP_ENEMY_COLOR: Color = Color(0.9, 0.2, 0.2)

## E42: Damage log — last N events.
const DAMAGE_LOG_MAX_ENTRIES: int = 10

## E43: Auto-pickup gold radius (walk-over collection).
const GOLD_AUTOPICKUP_RADIUS: float = 2.0

## E44: Item rarity filter — auto-ignore below this rarity after iter 2.
const RARITY_FILTER_MIN_ITER: int = 2
const RARITY_FILTER_THRESHOLD: int = 1  # Ignore common (0) items

## E45: Screenshot mode toggle.
static func toggle_screenshot_mode(tree: SceneTree) -> bool:
	var huds: Array[Node] = tree.get_nodes_in_group(&"hud")
	var hidden: bool = false
	for hud: Node in huds:
		if hud is CanvasLayer:
			(hud as CanvasLayer).visible = not (hud as CanvasLayer).visible
			hidden = not (hud as CanvasLayer).visible
	return hidden

## E46: Font size presets.
const FONT_SIZE_PRESETS: Dictionary = {
	"small": 0.85,
	"medium": 1.0,
	"large": 1.25,
}

## E47: Colorblind mode palettes.
const COLORBLIND_PALETTES: Dictionary = {
	"normal": {
		"damage": Color(1.0, 0.35, 0.2),
		"heal": Color(0.2, 0.95, 0.4),
		"crit": Color(1.0, 0.9, 0.1),
		"status_bad": Color(0.9, 0.2, 0.3),
		"status_good": Color(0.2, 0.8, 0.4),
	},
	"deuteranopia": {
		"damage": Color(1.0, 0.5, 0.0),
		"heal": Color(0.3, 0.6, 1.0),
		"crit": Color(1.0, 1.0, 0.3),
		"status_bad": Color(0.9, 0.4, 0.0),
		"status_good": Color(0.3, 0.5, 1.0),
	},
	"protanopia": {
		"damage": Color(0.9, 0.6, 0.0),
		"heal": Color(0.2, 0.5, 1.0),
		"crit": Color(1.0, 0.95, 0.4),
		"status_bad": Color(0.85, 0.5, 0.0),
		"status_good": Color(0.2, 0.4, 1.0),
	},
}

## E48: Skip cinematic — tracks which cinematics have been seen.
static func has_seen_cinematic(cinematic_id: String) -> bool:
	return GameManager.has_meta(StringName("seen_cinematic_%s" % cinematic_id))

static func mark_cinematic_seen(cinematic_id: String) -> void:
	GameManager.set_meta(StringName("seen_cinematic_%s" % cinematic_id), true)

## E49: Statistics panel data keys.
const STAT_KEYS: Array[String] = [
	"play_time_seconds",
	"total_enemies_defeated",
	"total_deaths",
	"total_items_found",
	"player_gold",
]

## E50: Gamepad input action mapping (action -> joypad button/axis).
## These match the existing input actions in project.godot and document
## the intended gamepad layout for when controller support is wired.
const GAMEPAD_MAP: Dictionary = {
	"attack_primary": "JOY_BUTTON_X",
	"attack_secondary": "JOY_BUTTON_Y",
	"dash": "JOY_BUTTON_A",
	"block": "JOY_BUTTON_B",
	"interact": "JOY_BUTTON_RIGHT_SHOULDER",
	"use_prompt": "JOY_BUTTON_LEFT_SHOULDER",
	"ability_1": "JOY_BUTTON_DPAD_UP",
	"ability_2": "JOY_BUTTON_DPAD_RIGHT",
	"ability_3": "JOY_BUTTON_DPAD_DOWN",
	"ability_4": "JOY_BUTTON_DPAD_LEFT",
	"inventory": "JOY_BUTTON_BACK",
	"pause": "JOY_BUTTON_START",
	"move": "LEFT_STICK",
	"camera": "RIGHT_STICK",
}
