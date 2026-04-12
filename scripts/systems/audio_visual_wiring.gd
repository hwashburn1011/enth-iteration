class_name AudioVisualWiring
extends RefCounted
## R3 Epic O — Wires AudioVisualPolish config into runtime behavior.
##
## O41: Footstep SFX — per-frame movement check
## O42: Low health heartbeat — HUD reads HP ratio, pulses vignette
## O43: Victory fanfare — play on all_enemies_defeated
## O44: Dialogue typing SFX — keystroke every N characters
## O45: Item pickup flash — player mesh white flash on item_collected


## O41: Wire footstep SFX to a player node.
## Call from player _physics_process with the player's velocity magnitude.
## Returns true if a footstep sound should play this frame.
static func should_play_footstep(velocity_length: float, delta: float, timer_ref: Dictionary) -> bool:
	if velocity_length < 0.5:
		timer_ref["t"] = 0.0
		return false
	timer_ref["t"] = float(timer_ref.get("t", 0.0)) + delta
	if float(timer_ref["t"]) >= AudioVisualPolish.FOOTSTEP_INTERVAL:
		timer_ref["t"] = 0.0
		return true
	return false


## O42: Low health heartbeat — returns heartbeat intensity [0..1] based on HP ratio.
## Also returns whether the vignette should pulse.
static func get_heartbeat_state(current_hp: float, max_hp: float, delta: float, timer_ref: Dictionary) -> Dictionary:
	var ratio: float = current_hp / maxf(max_hp, 1.0)
	if ratio > AudioVisualPolish.LOW_HEALTH_THRESHOLD:
		return {"active": false, "intensity": 0.0, "should_beat": false}
	# Intensity scales from 0 at threshold to 1 at 0 HP
	var intensity: float = 1.0 - (ratio / AudioVisualPolish.LOW_HEALTH_THRESHOLD)
	timer_ref["t"] = float(timer_ref.get("t", 0.0)) + delta
	var should_beat: bool = false
	# Beat interval decreases with lower HP (faster heartbeat when dying)
	var interval: float = AudioVisualPolish.HEARTBEAT_INTERVAL * (0.5 + 0.5 * ratio / AudioVisualPolish.LOW_HEALTH_THRESHOLD)
	if float(timer_ref["t"]) >= interval:
		timer_ref["t"] = 0.0
		should_beat = true
	return {"active": true, "intensity": intensity, "should_beat": should_beat}


## O43: Victory fanfare — call when all enemies in a room are defeated.
## Plays the configured SFX through AudioManager.
static func play_victory_fanfare() -> void:
	if AudioManager.has_method(&"play_sfx"):
		AudioManager.play_sfx(AudioVisualPolish.VICTORY_SFX)


## O44: Dialogue typing SFX — returns true if a keystroke sound should play
## for the given character index in a dialogue line.
static func should_play_type_sfx(char_index: int) -> bool:
	return char_index > 0 and char_index % AudioVisualPolish.DIALOGUE_TYPE_INTERVAL == 0


## O45: Item pickup flash — creates a brief white flash tween on a mesh.
## Call with the player's model MeshInstance3D when an item is collected.
static func flash_pickup(mesh: Node3D) -> void:
	if mesh == null or not mesh.is_inside_tree():
		return
	var original_modulate: Color = mesh.modulate if "modulate" in mesh else Color(1, 1, 1, 1)
	var flash_color: Color = AudioVisualPolish.PICKUP_FLASH_COLOR
	var duration: float = AudioVisualPolish.PICKUP_FLASH_DURATION
	# Use a tween on the mesh's modulate to create a white flash
	var tween: Tween = mesh.create_tween()
	tween.tween_property(mesh, "modulate", Color(1.0 + flash_color.r, 1.0 + flash_color.g, 1.0 + flash_color.b, 1.0), duration * 0.3)
	tween.tween_property(mesh, "modulate", original_modulate, duration * 0.7)
