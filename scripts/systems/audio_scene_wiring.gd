class_name AudioSceneWiring
extends RefCounted
## R4 Epic S — Audio & Scene Polish wiring into runtime.
##
## S31: Placeholder SFX registration (registers names AudioManager can resolve)
## S32-S36: Wiring helpers that scenes call during _ready/_physics_process
## S37-S38: Per-iteration music wiring
## S39: Menu hover SFX
## S40: Scene transition fade overlay


## S31: Placeholder SFX IDs that AudioManager should recognize.
## These map to .wav/.ogg files in assets/audio/ once authored.
## Until the files exist, AudioManager silently skips them.
const PLACEHOLDER_SFX: Array[String] = [
	"footstep",
	"heartbeat",
	"victory_fanfare",
	"dialogue_type",
	"pickup_flash",
	"menu_hover",
]


## S32: Wire footstep SFX into player physics process.
## Call from Player._physics_process with velocity and delta.
## footstep_timer is a Dictionary with key "t" persisted across frames.
static func wire_footstep(velocity_length: float, delta: float, footstep_timer: Dictionary) -> void:
	if AudioVisualWiring.should_play_footstep(velocity_length, delta, footstep_timer):
		if AudioManager.has_method(&"play_sfx"):
			AudioManager.play_sfx(AudioVisualPolish.FOOTSTEP_SFX)


## S33: Wire heartbeat to HUD. Call from HUD._process.
## heartbeat_timer is a Dictionary with key "t" persisted across frames.
static func wire_heartbeat(current_hp: float, max_hp: float, delta: float, heartbeat_timer: Dictionary, vignette: ColorRect) -> void:
	var state: Dictionary = AudioVisualWiring.get_heartbeat_state(current_hp, max_hp, delta, heartbeat_timer)
	if not state["active"]:
		if vignette:
			vignette.visible = false
		return
	if vignette:
		vignette.visible = true
		vignette.color = Color(
			AudioVisualPolish.HEARTBEAT_VIGNETTE_COLOR.r,
			AudioVisualPolish.HEARTBEAT_VIGNETTE_COLOR.g,
			AudioVisualPolish.HEARTBEAT_VIGNETTE_COLOR.b,
			AudioVisualPolish.HEARTBEAT_VIGNETTE_COLOR.a * float(state["intensity"])
		)
	if state["should_beat"]:
		if AudioManager.has_method(&"play_sfx"):
			AudioManager.play_sfx(AudioVisualPolish.HEARTBEAT_SFX)


## S34: Wire victory fanfare — call when a room's enemies are all cleared.
static func wire_victory_fanfare() -> void:
	AudioVisualWiring.play_victory_fanfare()


## S35: Wire dialogue typing SFX — call per character during text reveal.
static func wire_dialogue_type(char_index: int) -> void:
	if AudioVisualWiring.should_play_type_sfx(char_index):
		if AudioManager.has_method(&"play_sfx"):
			AudioManager.play_sfx(AudioVisualPolish.DIALOGUE_TYPE_SFX)


## S36: Wire item pickup flash — call on EventBus.item_collected.
static func wire_pickup_flash(player_model: Node3D) -> void:
	AudioVisualWiring.flash_pickup(player_model)
	if AudioManager.has_method(&"play_sfx"):
		AudioManager.play_sfx("pickup_flash")


## S37: Wire per-iteration dungeon ambient music.
## Call from dungeon._ready() after determining the current iteration.
static func wire_dungeon_music(iteration: int) -> void:
	var track: String = AudioVisualPolish.DUNGEON_AMBIENT_BY_ITER.get(iteration, "dungeon_ambient") as String
	if AudioManager.has_method(&"play_music"):
		AudioManager.play_music(track)


## S38: Wire per-iteration town music.
## Call from town._ready() after determining the current iteration.
static func wire_town_music(iteration: int) -> void:
	var track: String = AudioVisualPolish.TOWN_MUSIC_BY_ITER.get(iteration, "town_ambient") as String
	if AudioManager.has_method(&"play_music"):
		AudioManager.play_music(track)


## S39: Wire menu hover SFX to a button.
## Call for each Button in a menu during _ready().
static func wire_menu_hover(button: Button) -> void:
	if button == null:
		return
	button.focus_entered.connect(func() -> void:
		if AudioManager.has_method(&"play_sfx"):
			AudioManager.play_sfx(AudioVisualPolish.MENU_HOVER_SFX)
	)


## S40: Scene transition fade overlay — creates a black fade out/in.
## Returns the CanvasLayer so the caller can queue_free it after transition.
static func create_scene_fade(tree: SceneTree, on_midpoint: Callable) -> CanvasLayer:
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 100
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.color = Color(0, 0, 0, 0)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(rect)
	tree.current_scene.add_child(canvas)

	var tween: Tween = rect.create_tween()
	# Fade to black
	tween.tween_property(rect, "color:a", 1.0, QoLRuntime.LOADING_FADE_IN_DURATION)
	# At midpoint, call the scene change
	tween.tween_callback(on_midpoint)
	# Brief hold
	tween.tween_interval(0.1)
	# Fade from black (the new scene handles its own fade-in via LoadingScreen)
	tween.tween_property(rect, "color:a", 0.0, QoLRuntime.LOADING_FADE_OUT_DURATION)
	tween.tween_callback(canvas.queue_free)
	return canvas
