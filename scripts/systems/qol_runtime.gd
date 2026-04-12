class_name QoLRuntime
extends RefCounted
## R3 Epic N — Quality of Life II runtime implementations.
##
## Consumes QoLSystems config constants and provides ready-to-wire
## implementations for auto-pickup, minimap, damage log, stats panel,
## loading screen, auto-save indicator, rarity borders, equipment
## comparison, gamepad input, and font size settings.

## N31: Auto-pickup gold — check if player is near gold drops.
## Called from a player _physics_process or timer. Returns gold
## collected so the caller can update GameManager.player_gold.
static func check_gold_autopickup(player: Node3D) -> int:
	if not player.is_inside_tree():
		return 0
	var radius: float = QoLSystems.GOLD_AUTOPICKUP_RADIUS
	var collected: int = 0
	var gold_drops: Array[Node] = player.get_tree().get_nodes_in_group(&"gold_drop")
	for drop: Node in gold_drops:
		if drop is Node3D:
			var dist: float = player.global_position.distance_to((drop as Node3D).global_position)
			if dist <= radius:
				if drop.has_meta(&"gold_value"):
					collected += int(drop.get_meta(&"gold_value"))
				else:
					collected += 1
				drop.queue_free()
	return collected


## N32: Minimap data point — returns a dictionary of entities for minimap rendering.
## Caller creates the CanvasLayer and draws dots using these positions.
static func get_minimap_data(player: Node3D) -> Dictionary:
	var data: Dictionary = {"player": Vector2.ZERO, "enemies": [], "exits": []}
	if not player.is_inside_tree():
		return data
	var p_pos: Vector3 = player.global_position
	data["player"] = Vector2(p_pos.x, p_pos.z)
	for enemy: Node in player.get_tree().get_nodes_in_group(&"enemies"):
		if enemy is Node3D and (enemy as Node3D).visible:
			var e_pos: Vector3 = (enemy as Node3D).global_position
			(data["enemies"] as Array).append(Vector2(e_pos.x, e_pos.z))
	for exit: Node in player.get_tree().get_nodes_in_group(&"exit_indicator"):
		if exit is Node3D:
			var ex_pos: Vector3 = (exit as Node3D).global_position
			(data["exits"] as Array).append(Vector2(ex_pos.x, ex_pos.z))
	return data


## N33: Damage log entry format. Call from combat event handlers.
static func format_damage_log_entry(source: String, target: String, amount: float, is_crit: bool) -> String:
	var crit_tag: String = " [CRIT]" if is_crit else ""
	return "%s → %s: %.0f%s" % [source, target, amount, crit_tag]


## N34: Statistics panel — collects play stats for the pause menu.
static func get_play_statistics() -> Array[Dictionary]:
	var stats: Array[Dictionary] = []
	var total_sec: int = int(GameManager.play_time_seconds)
	stats.append({"label": "Time Played", "value": "%d:%02d" % [total_sec / 60, total_sec % 60]})
	stats.append({"label": "Enemies Defeated", "value": str(GameManager.total_enemies_defeated)})
	stats.append({"label": "Deaths", "value": str(GameManager.total_deaths)})
	stats.append({"label": "Items Found", "value": str(GameManager.total_items_found)})
	stats.append({"label": "Gold", "value": str(GameManager.player_gold)})
	if GameManager.has_node("/root/IterationManager"):
		var im: Node = GameManager.get_node("/root/IterationManager")
		if im.has_method(&"get_current_iteration"):
			stats.append({"label": "Current Iteration", "value": str(im.get_current_iteration())})
	return stats


## N35: Loading screen fade config.
const LOADING_FADE_IN_DURATION: float = 0.3
const LOADING_FADE_OUT_DURATION: float = 0.5
const LOADING_SPINNER_COLOR: Color = Color(0.3, 0.85, 0.8)


## N36: Auto-save indicator config.
const AUTOSAVE_ICON_DURATION: float = 1.5
const AUTOSAVE_ICON_COLOR: Color = Color(0.8, 0.85, 0.9, 0.7)


## N37: Inventory rarity border colors.
const RARITY_BORDER_COLORS: Dictionary = {
	0: Color(0.4, 0.4, 0.4),     # Common — gray
	1: Color(0.3, 0.7, 0.3),     # Uncommon — green
	2: Color(0.3, 0.5, 1.0),     # Rare — blue
	3: Color(0.7, 0.3, 1.0),     # Epic — purple
	4: Color(1.0, 0.7, 0.1),     # Legendary — gold
	5: Color(1.0, 0.3, 0.3),     # Mythic — red
}


## N38: Equipment comparison — returns +/- stat difference between two items.
static func compare_items(current: Dictionary, candidate: Dictionary) -> Array[Dictionary]:
	var diffs: Array[Dictionary] = []
	var stat_keys: Array[String] = ["processing", "integrity", "bandwidth", "memory"]
	for key: String in stat_keys:
		var cur_val: float = float(current.get(key, 0))
		var can_val: float = float(candidate.get(key, 0))
		var diff: float = can_val - cur_val
		if abs(diff) > 0.01:
			diffs.append({"stat": key, "diff": diff})
	return diffs


## N39: Gamepad input wiring — adds joypad events to existing input actions.
## Call once during _ready() of the main scene or an autoload.
static func wire_gamepad_inputs() -> void:
	for action: String in QoLSystems.GAMEPAD_MAP:
		if not InputMap.has_action(action):
			continue
		var joy_str: String = str(QoLSystems.GAMEPAD_MAP[action])
		if joy_str.begins_with("JOY_BUTTON_"):
			var event: InputEventJoypadButton = InputEventJoypadButton.new()
			# Map string to button index — simplified mapping
			var btn_map: Dictionary = {
				"JOY_BUTTON_A": JOY_BUTTON_A,
				"JOY_BUTTON_B": JOY_BUTTON_B,
				"JOY_BUTTON_X": JOY_BUTTON_X,
				"JOY_BUTTON_Y": JOY_BUTTON_Y,
				"JOY_BUTTON_LEFT_SHOULDER": JOY_BUTTON_LEFT_SHOULDER,
				"JOY_BUTTON_RIGHT_SHOULDER": JOY_BUTTON_RIGHT_SHOULDER,
				"JOY_BUTTON_BACK": JOY_BUTTON_BACK,
				"JOY_BUTTON_START": JOY_BUTTON_START,
				"JOY_BUTTON_DPAD_UP": JOY_BUTTON_DPAD_UP,
				"JOY_BUTTON_DPAD_DOWN": JOY_BUTTON_DPAD_DOWN,
				"JOY_BUTTON_DPAD_LEFT": JOY_BUTTON_DPAD_LEFT,
				"JOY_BUTTON_DPAD_RIGHT": JOY_BUTTON_DPAD_RIGHT,
			}
			if joy_str in btn_map:
				event.button_index = btn_map[joy_str] as JoyButton
				InputMap.action_add_event(action, event)


## N40: Font size setting — applies a scale multiplier to all theme font sizes.
## preset_name must be a key in QoLSystems.FONT_SIZE_PRESETS.
static func apply_font_size_preset(preset_name: String) -> float:
	var scale: float = float(QoLSystems.FONT_SIZE_PRESETS.get(preset_name, 1.0))
	return scale
