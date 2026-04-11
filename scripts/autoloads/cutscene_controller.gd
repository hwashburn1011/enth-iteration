extends Node
## CutsceneController — global in-engine cinematic playback. Manages
## cinematic camera takeover, timeline event processing, letterbox bars,
## subtitle overlay, skip handling, and save state.
##
## Add to project autoloads as "CutsceneController".

signal cinematic_started(cinematic_id: StringName)
signal cinematic_finished(cinematic_id: StringName)
signal cinematic_skipped(cinematic_id: StringName)

enum PlaybackState { READY, PLAYING, PAUSED, COMPLETE }

const SKIP_KEY: int = KEY_ESCAPE
const DEFAULT_LETTERBOX_DURATION: float = 0.6
const DEFAULT_LETTERBOX_HEIGHT_PCT: float = 0.12

var current_cinematic_id: StringName = &""
var playback_state: PlaybackState = PlaybackState.READY
var seen_cinematics: Array[StringName] = []

# Runtime nodes (created on first play)
var cutscene_camera: Camera3D
var letterbox_top: ColorRect
var letterbox_bottom: ColorRect
var subtitle_overlay: Label
var fade_overlay: ColorRect
var ui_layer: CanvasLayer

# Timeline event processing
var _current_timeline: Array = []
var _current_event_index: int = 0
var _previous_camera: Camera3D
var _wait_remaining: float = 0.0
var _waiting: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_ui_layer()


func _setup_ui_layer() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.name = "CutsceneUI"
	ui_layer.layer = 100
	ui_layer.visible = false
	add_child(ui_layer)

	# Letterbox bars
	letterbox_top = ColorRect.new()
	letterbox_top.color = Color.BLACK
	letterbox_top.anchor_right = 1.0
	letterbox_top.anchor_bottom = 0.0
	letterbox_top.offset_bottom = 0.0
	ui_layer.add_child(letterbox_top)

	letterbox_bottom = ColorRect.new()
	letterbox_bottom.color = Color.BLACK
	letterbox_bottom.anchor_top = 1.0
	letterbox_bottom.anchor_right = 1.0
	letterbox_bottom.anchor_bottom = 1.0
	letterbox_bottom.offset_top = 0.0
	ui_layer.add_child(letterbox_bottom)

	# Subtitle overlay
	subtitle_overlay = Label.new()
	subtitle_overlay.anchor_top = 1.0
	subtitle_overlay.anchor_bottom = 1.0
	subtitle_overlay.anchor_left = 0.1
	subtitle_overlay.anchor_right = 0.9
	subtitle_overlay.offset_top = -120
	subtitle_overlay.offset_bottom = -60
	subtitle_overlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_overlay.add_theme_font_size_override(&"font_size", 28)
	subtitle_overlay.add_theme_color_override(&"font_color", Color.WHITE)
	subtitle_overlay.add_theme_color_override(&"font_outline_color", Color.BLACK)
	subtitle_overlay.add_theme_constant_override(&"outline_size", 4)
	ui_layer.add_child(subtitle_overlay)

	# Fade overlay
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color(0, 0, 0, 0)
	fade_overlay.anchor_right = 1.0
	fade_overlay.anchor_bottom = 1.0
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(fade_overlay)


# === PLAYBACK ===

func play_cinematic(cinematic_id: StringName, timeline: Array) -> void:
	if playback_state == PlaybackState.PLAYING:
		push_warning("CutsceneController: already playing %s" % current_cinematic_id)
		return
	current_cinematic_id = cinematic_id
	_current_timeline = timeline
	_current_event_index = 0
	playback_state = PlaybackState.PLAYING
	ui_layer.visible = true
	get_tree().paused = true
	set_process(true)
	cinematic_started.emit(cinematic_id)
	_take_over_camera()


func _take_over_camera() -> void:
	# Save the previous camera and create a cinematic one
	_previous_camera = get_viewport().get_camera_3d()
	if cutscene_camera == null:
		cutscene_camera = Camera3D.new()
		cutscene_camera.name = "CutsceneCamera"
		add_child(cutscene_camera)
	cutscene_camera.current = true


func _release_camera() -> void:
	if cutscene_camera != null:
		cutscene_camera.current = false
	if _previous_camera != null and is_instance_valid(_previous_camera):
		_previous_camera.current = true


func _process(delta: float) -> void:
	if playback_state != PlaybackState.PLAYING:
		return
	if _waiting:
		_wait_remaining -= delta
		if _wait_remaining <= 0:
			_waiting = false
			_advance_event()
		return
	# Process current event
	if _current_event_index >= _current_timeline.size():
		_complete_cinematic()
		return
	# Events that take time set _waiting; instant events advance immediately


func _advance_event() -> void:
	_current_event_index += 1
	if _current_event_index >= _current_timeline.size():
		_complete_cinematic()
		return
	_process_event(_current_timeline[_current_event_index])


func _process_event(event: Dictionary) -> void:
	var event_type: StringName = event.get("type", &"")
	match event_type:
		&"wait":
			_waiting = true
			_wait_remaining = event.get("duration", 1.0)
		&"camera_move":
			_camera_move(event)
		&"camera_shake":
			_camera_shake(event)
		&"play_animation":
			_play_animation(event)
			_advance_event()
		&"play_dialogue":
			_play_dialogue(event)
		&"play_music":
			_play_music(event)
			_advance_event()
		&"play_sfx":
			_play_sfx(event)
			_advance_event()
		&"set_letterbox":
			_set_letterbox(event)
		&"fade":
			_fade(event)
		&"signal":
			_emit_signal_event(event)
			_advance_event()
		_:
			_advance_event()


func _camera_move(event: Dictionary) -> void:
	if cutscene_camera == null:
		_advance_event()
		return
	var target_pos: Vector3 = event.get("position", Vector3.ZERO)
	var look_at: Vector3 = event.get("look_at", target_pos + Vector3.FORWARD)
	var duration: float = event.get("duration", 2.0)
	var tween: Tween = create_tween()
	tween.tween_property(cutscene_camera, "global_position", target_pos, duration)
	tween.parallel().tween_method(
		func(t: float) -> void:
			if cutscene_camera != null:
				cutscene_camera.look_at(look_at, Vector3.UP),
		0.0, 1.0, duration
	)
	tween.tween_callback(_advance_event)


func _camera_shake(event: Dictionary) -> void:
	var intensity: float = event.get("intensity", 0.3)
	var duration: float = event.get("duration", 0.5)
	# Hand-rolled shake — would integrate with main camera shake autoload
	_waiting = true
	_wait_remaining = duration
	if cutscene_camera != null:
		var origin: Vector3 = cutscene_camera.global_position
		var shake_tween: Tween = create_tween()
		var steps: int = int(duration * 30.0)
		for i in steps:
			var t: float = float(i) / float(steps)
			var falloff: float = 1.0 - t
			var offset: Vector3 = Vector3(
				randf_range(-1, 1) * intensity * falloff,
				randf_range(-1, 1) * intensity * falloff,
				randf_range(-1, 1) * intensity * falloff
			)
			shake_tween.tween_property(cutscene_camera, "global_position", origin + offset, duration / steps)
		shake_tween.tween_property(cutscene_camera, "global_position", origin, 0.05)


func _play_animation(event: Dictionary) -> void:
	var entity_path: String = event.get("entity", "")
	var anim_name: StringName = event.get("anim", &"")
	var entity: Node = get_node_or_null(entity_path)
	if entity != null and entity.has_method("play_animation"):
		entity.play_animation(anim_name)


func _play_dialogue(event: Dictionary) -> void:
	var npc_id: StringName = event.get("npc_id", &"")
	var text: String = event.get("text", "")
	var emotion: StringName = event.get("emotion", &"neutral")
	var duration: float = event.get("duration", 3.0)

	if subtitle_overlay != null:
		subtitle_overlay.text = "%s: %s" % [_npc_display_name(npc_id), text]

	# Play voice grunt via VoiceManager if available
	if has_node("/root/VoiceManager"):
		var vm: Node = get_node("/root/VoiceManager")
		if vm.has_method("play_grunt"):
			vm.play_grunt(npc_id, emotion)

	_waiting = true
	_wait_remaining = duration


func _npc_display_name(npc_id: StringName) -> String:
	var voice: Dictionary = VoiceDatabase.get_npc_voice(npc_id)
	return voice.get("display_name", String(npc_id).capitalize())


func _play_music(event: Dictionary) -> void:
	var track_id: StringName = event.get("track_id", &"")
	if has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_zone_track"):
			mm.play_zone_track(track_id)


func _play_sfx(event: Dictionary) -> void:
	var sfx_id: StringName = event.get("sfx_id", &"")
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(sfx_id)


func _set_letterbox(event: Dictionary) -> void:
	var visible: bool = event.get("visible", true)
	var duration: float = event.get("duration", DEFAULT_LETTERBOX_DURATION)
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var bar_height: float = viewport_size.y * DEFAULT_LETTERBOX_HEIGHT_PCT
	var target: float = bar_height if visible else 0.0
	var tween: Tween = create_tween()
	tween.tween_property(letterbox_top, "offset_bottom", target, duration)
	tween.parallel().tween_property(letterbox_bottom, "offset_top", -target, duration)
	tween.tween_callback(_advance_event)


func _fade(event: Dictionary) -> void:
	var to_color: Color = event.get("color", Color.BLACK)
	var alpha: float = event.get("alpha", 1.0)
	var duration: float = event.get("duration", 1.0)
	to_color.a = alpha
	var tween: Tween = create_tween()
	tween.tween_property(fade_overlay, "color", to_color, duration)
	tween.tween_callback(_advance_event)


func _emit_signal_event(event: Dictionary) -> void:
	var signal_name: StringName = event.get("signal_name", &"")
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal(signal_name):
			bus.emit_signal(signal_name)


# === SKIP ===

func _input(event: InputEvent) -> void:
	if playback_state != PlaybackState.PLAYING:
		return
	if event is InputEventKey and event.pressed and event.keycode == SKIP_KEY:
		_skip_cinematic()


func _skip_cinematic() -> void:
	cinematic_skipped.emit(current_cinematic_id)
	_complete_cinematic()


func _complete_cinematic() -> void:
	playback_state = PlaybackState.COMPLETE
	if not seen_cinematics.has(current_cinematic_id):
		seen_cinematics.append(current_cinematic_id)
	_release_camera()
	ui_layer.visible = false
	get_tree().paused = false
	set_process(false)
	cinematic_finished.emit(current_cinematic_id)
	current_cinematic_id = &""
	_current_timeline.clear()
	_current_event_index = 0


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"seen_cinematics": seen_cinematics.map(func(s: StringName) -> String: return String(s)),
	}


func from_save_data(data: Dictionary) -> void:
	seen_cinematics.clear()
	for s in data.get("seen_cinematics", []):
		seen_cinematics.append(StringName(s))


func has_seen(cinematic_id: StringName) -> bool:
	return seen_cinematics.has(cinematic_id)
