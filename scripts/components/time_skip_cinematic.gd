class_name TimeSkipCinematic
extends CanvasLayer

## Time-of-Day Skip Cinematic (Epic 26 task 35).
##
## Hero flourish that plays whenever the player invokes sleep_till_morning
## or sleep_till_night on DayNightController. Composed of:
##   1. 0.4s radial darken fade (iris-in)
##   2. 2.0s sun/moon arc sweep across a full-screen sky gradient
##   3. Animated clock face with hands spinning accelerated
##   4. "Day N" / "Dawn / Dusk / Night" title card crossfade
##   5. 0.6s iris-out to gameplay
##
## Total duration: ~3.0s. Designed to feel like a cinematic chapter break
## rather than a loading screen. Uses draw_arc + Polygon2D gradients so it
## needs no external textures — ships as one script.
##
## Hook:
##   var cine := TimeSkipCinematic.new()
##   get_tree().root.add_child(cine)
##   cine.play_skip_to(TimeSkipCinematic.Target.DAWN)
##
## Called from DayNightController.sleep_till_morning / sleep_till_night
## via EventBus signal "request_time_skip_cinematic" so we stay decoupled.

signal cinematic_started
signal cinematic_finished

enum Target { DAWN, DUSK, NIGHT, NOON }

const FADE_IN_DURATION: float = 0.4
const SWEEP_DURATION: float = 2.0
const FADE_OUT_DURATION: float = 0.6
const TOTAL_DURATION: float = FADE_IN_DURATION + SWEEP_DURATION + FADE_OUT_DURATION

@export var default_target: Target = Target.DAWN

var _root_control: Control
var _sky_gradient: ColorRect
var _clock_panel: Control
var _title_label: Label
var _subtitle_label: Label
var _iris_rect: ColorRect
var _is_playing: bool = false
var _target: Target = Target.DAWN
var _elapsed: float = 0.0
var _target_hour: float = 0.0


func _ready() -> void:
	layer = 100
	_build_ui()
	_hide_all()


func _build_ui() -> void:
	_root_control = Control.new()
	_root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root_control)

	# Sky gradient background (full-screen ColorRect; we'll update its color)
	_sky_gradient = ColorRect.new()
	_sky_gradient.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_sky_gradient.color = Color(0.04, 0.06, 0.12, 0.0)
	_sky_gradient.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root_control.add_child(_sky_gradient)

	# Clock panel holding the animated clock face
	_clock_panel = Control.new()
	_clock_panel.anchor_left = 0.5
	_clock_panel.anchor_top = 0.38
	_clock_panel.anchor_right = 0.5
	_clock_panel.anchor_bottom = 0.38
	_clock_panel.offset_left = -140
	_clock_panel.offset_top = -140
	_clock_panel.offset_right = 140
	_clock_panel.offset_bottom = 140
	_clock_panel.modulate.a = 0.0
	_clock_panel.draw.connect(_draw_clock)
	_root_control.add_child(_clock_panel)

	# Title label
	_title_label = Label.new()
	_title_label.anchor_left = 0.0
	_title_label.anchor_right = 1.0
	_title_label.anchor_top = 0.68
	_title_label.anchor_bottom = 0.68
	_title_label.offset_top = -40
	_title_label.offset_bottom = 40
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 54)
	_title_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.85))
	_title_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	_title_label.add_theme_constant_override("outline_size", 6)
	_title_label.modulate.a = 0.0
	_root_control.add_child(_title_label)

	# Subtitle (the hour)
	_subtitle_label = Label.new()
	_subtitle_label.anchor_left = 0.0
	_subtitle_label.anchor_right = 1.0
	_subtitle_label.anchor_top = 0.78
	_subtitle_label.anchor_bottom = 0.78
	_subtitle_label.offset_top = -20
	_subtitle_label.offset_bottom = 20
	_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_subtitle_label.add_theme_font_size_override("font_size", 26)
	_subtitle_label.add_theme_color_override("font_color", Color(0.8, 0.85, 1.0))
	_subtitle_label.modulate.a = 0.0
	_root_control.add_child(_subtitle_label)

	# Iris rect (fullscreen black overlay for fade in/out)
	_iris_rect = ColorRect.new()
	_iris_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_iris_rect.color = Color(0, 0, 0, 0)
	_iris_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root_control.add_child(_iris_rect)


func _hide_all() -> void:
	_sky_gradient.color.a = 0.0
	_clock_panel.modulate.a = 0.0
	_title_label.modulate.a = 0.0
	_subtitle_label.modulate.a = 0.0
	_iris_rect.color.a = 0.0


func play_skip_to(target: Target) -> void:
	if _is_playing:
		return
	_is_playing = true
	_target = target
	_elapsed = 0.0
	match target:
		Target.DAWN:
			_target_hour = 6.0
			_title_label.text = "DAWN"
			_subtitle_label.text = "06:00"
		Target.NOON:
			_target_hour = 12.0
			_title_label.text = "NOON"
			_subtitle_label.text = "12:00"
		Target.DUSK:
			_target_hour = 19.0
			_title_label.text = "DUSK"
			_subtitle_label.text = "19:00"
		Target.NIGHT:
			_target_hour = 21.0
			_title_label.text = "NIGHT"
			_subtitle_label.text = "21:00"
	_hide_all()
	cinematic_started.emit()
	set_process(true)


func _process(delta: float) -> void:
	if not _is_playing:
		return
	_elapsed += delta

	# Stage 1: iris-in fade (0.0 → 0.4)
	if _elapsed <= FADE_IN_DURATION:
		var t: float = _elapsed / FADE_IN_DURATION
		_iris_rect.color.a = lerp(0.0, 0.92, t)
		_sky_gradient.color = _target_sky_color() * Color(1, 1, 1, t * 0.55)
		_sky_gradient.color.a = t * 0.55

	# Stage 2: sweep + clock spin + title fade (0.4 → 2.4)
	elif _elapsed <= FADE_IN_DURATION + SWEEP_DURATION:
		var t: float = (_elapsed - FADE_IN_DURATION) / SWEEP_DURATION
		# Cross-fade sky from dark-blue to target
		var sky_target: Color = _target_sky_color()
		_sky_gradient.color = Color(0.04, 0.05, 0.12).lerp(sky_target, t)
		_sky_gradient.color.a = 0.92
		_iris_rect.color.a = 0.0
		_clock_panel.modulate.a = _ease_out(clamp(t * 2.0, 0.0, 1.0))
		_clock_panel.queue_redraw()
		# Title + subtitle fade in after clock
		var title_fade: float = _ease_out(clamp((t - 0.3) * 2.0, 0.0, 1.0))
		_title_label.modulate.a = title_fade
		_subtitle_label.modulate.a = title_fade

	# Stage 3: iris-out (2.4 → 3.0)
	elif _elapsed <= TOTAL_DURATION:
		var t: float = (_elapsed - FADE_IN_DURATION - SWEEP_DURATION) / FADE_OUT_DURATION
		var fade: float = 1.0 - t
		_sky_gradient.color.a = fade * 0.92
		_clock_panel.modulate.a = fade
		_title_label.modulate.a = fade
		_subtitle_label.modulate.a = fade
		_iris_rect.color.a = 0.0

	else:
		_is_playing = false
		set_process(false)
		_hide_all()
		cinematic_finished.emit()


func _ease_out(t: float) -> float:
	return 1.0 - pow(1.0 - t, 3.0)


func _target_sky_color() -> Color:
	match _target:
		Target.DAWN:
			return Color(1.0, 0.72, 0.48)  # warm amber
		Target.NOON:
			return Color(0.50, 0.72, 1.0)  # bright blue
		Target.DUSK:
			return Color(1.0, 0.45, 0.35)  # burnt orange
		Target.NIGHT:
			return Color(0.08, 0.10, 0.25)  # deep indigo
	return Color(0.5, 0.5, 0.5)


# ---------- Clock face drawing ----------
func _draw_clock() -> void:
	var size: Vector2 = _clock_panel.size
	var center: Vector2 = size * 0.5
	var radius: float = min(size.x, size.y) * 0.42

	# Outer ring
	_clock_panel.draw_arc(center, radius, 0.0, TAU, 64, Color(0.9, 0.9, 1.0), 4.0, true)
	_clock_panel.draw_arc(center, radius - 6, 0.0, TAU, 64, Color(0.6, 0.65, 0.85), 2.0, true)

	# Inner face
	_clock_panel.draw_circle(center, radius - 12, Color(0.08, 0.10, 0.18, 0.8))

	# 12 hour ticks
	for i in range(12):
		var ang: float = (i / 12.0) * TAU - PI / 2.0
		var p1: Vector2 = center + Vector2(cos(ang), sin(ang)) * (radius - 14)
		var p2: Vector2 = center + Vector2(cos(ang), sin(ang)) * (radius - 26)
		var w: float = 4.0 if (i % 3 == 0) else 2.0
		_clock_panel.draw_line(p1, p2, Color(0.9, 0.95, 1.0), w, true)

	# Animated hands — sweep from current hour toward target_hour proportional to progress
	var sweep_progress: float = 0.0
	if _elapsed > FADE_IN_DURATION:
		sweep_progress = clamp((_elapsed - FADE_IN_DURATION) / SWEEP_DURATION, 0.0, 1.0)
	var hour_display: float = lerp(0.0, _target_hour, _ease_out(sweep_progress))

	var minute_angle: float = fposmod(hour_display * TAU, TAU) - PI / 2.0  # minute hand spins fast
	var hour_angle: float = (hour_display / 12.0) * TAU - PI / 2.0

	# Minute hand (longer, thinner, white)
	var min_tip: Vector2 = center + Vector2(cos(minute_angle), sin(minute_angle)) * (radius - 20)
	_clock_panel.draw_line(center, min_tip, Color(0.95, 0.97, 1.0), 3.0, true)

	# Hour hand (shorter, thicker, warm)
	var hr_tip: Vector2 = center + Vector2(cos(hour_angle), sin(hour_angle)) * (radius * 0.55)
	_clock_panel.draw_line(center, hr_tip, Color(1.0, 0.85, 0.5), 5.0, true)

	# Center hub
	_clock_panel.draw_circle(center, 6.0, Color(1.0, 0.85, 0.5))
	_clock_panel.draw_circle(center, 3.0, Color(0.2, 0.2, 0.3))

	# Sun/moon arc overlay above the clock for atmospheric feel
	var arc_center: Vector2 = Vector2(center.x, center.y + radius + 10)
	var arc_radius: float = radius * 0.9
	var arc_t: float = _ease_out(sweep_progress)
	# Draw arc path
	_clock_panel.draw_arc(arc_center, arc_radius, PI, TAU, 32, Color(0.4, 0.5, 0.7, 0.6), 2.0, true)
	# Sun/moon token moving along arc
	var ang: float = PI + arc_t * PI
	var token_pos: Vector2 = arc_center + Vector2(cos(ang), sin(ang)) * arc_radius
	var token_color: Color = _target_sky_color()
	_clock_panel.draw_circle(token_pos, 10.0, token_color)
	_clock_panel.draw_circle(token_pos, 14.0, Color(token_color.r, token_color.g, token_color.b, 0.4))
