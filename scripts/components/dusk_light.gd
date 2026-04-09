class_name DuskLight
extends Node3D

## Lights that turn on at dusk and turn off at dawn — covers both
## window-glow (with flicker) and street lamps (steady) from a single
## component, picked via the `flicker_mode` inspector toggle.
##
## Behavior:
##   - At DUSK: light energy ramps from 0 → target over 'fade_in_s'
##     (slightly randomized per instance so 12 windows on a street
##     don't all snap on at the exact same moment)
##   - At NIGHT: stays on at target energy
##   - At DAWN: ramps back to 0 over 'fade_out_s'
##   - At DAY: stays off
##
## Flicker modes:
##   FLICKER_NONE — solid steady (street lamps)
##   FLICKER_CANDLE — slow random energy wobble (windows, candles)
##   FLICKER_GAS_LANTERN — smaller faster wobble (gas lanterns)
##   FLICKER_GLITCH — sharp on/off pulses (glitched bulbs)
##
## Required scene shape:
##   DuskLight (Node3D + this script)
##     Light (Light3D — OmniLight3D, SpotLight3D, or any Light3D)
##     [optional] Mesh3D as a child for the light source visual
##
## Configure via inspector:
##   target_energy   — full-on energy at night
##   fade_in_s       — dusk ramp duration (jittered ±15% per instance)
##   fade_out_s      — dawn ramp duration
##   flicker_mode    — see enum
##   flicker_amplitude — 0..1 wobble intensity
##   target_color    — light tint at full-on

signal turned_on
signal turned_off

enum FlickerMode {
	NONE,
	CANDLE,
	GAS_LANTERN,
	GLITCH,
}

@export var target_energy: float = 1.6
@export var fade_in_s: float = 4.0
@export var fade_out_s: float = 6.0
@export var flicker_mode: FlickerMode = FlickerMode.NONE
@export var flicker_amplitude: float = 0.3
@export var target_color: Color = Color(1.00, 0.78, 0.45)
@export var random_jitter_pct: float = 0.15  # per-instance fade time variation

@onready var _light: Light3D = $Light if has_node("Light") else null

var _is_on: bool = false
var _base_energy: float = 0.0  # tweens to this; flicker wobbles around it
var _tween: Tween
var _flicker_phase: float
var _initial_jitter: float = 1.0  # per-instance fade time multiplier


func _ready() -> void:
	# Per-instance jitter so a street of 12 windows doesn't all
	# turn on simultaneously
	_initial_jitter = 1.0 + randf_range(-random_jitter_pct, random_jitter_pct)
	_flicker_phase = randf() * TAU

	if _light != null:
		_light.light_energy = 0.0
		_light.light_color = target_color

	# Subscribe + apply current phase
	if has_node("/root/DayNightController"):
		var dnc: Node = get_node("/root/DayNightController")
		if dnc.has_signal("phase_changed"):
			dnc.phase_changed.connect(_on_phase_changed)
		if "current_phase" in dnc:
			_apply_phase(StringName(dnc.current_phase), false)


func _process(delta: float) -> void:
	if _is_on and flicker_mode != FlickerMode.NONE:
		_apply_flicker(delta)


# === PHASE ===

func _apply_phase(phase: StringName, animate: bool) -> void:
	match phase:
		&"dusk":
			_turn_on(animate)
		&"night":
			# Make sure we're on (in case we joined the scene at night)
			_turn_on(animate)
		&"dawn":
			_turn_off(animate)
		&"day":
			# Make sure we're off
			_turn_off(animate)


func _turn_on(animate: bool) -> void:
	if _is_on and animate:
		return
	_is_on = true
	if _light == null:
		return
	if animate:
		_tween_energy(target_energy, fade_in_s * _initial_jitter)
	else:
		_base_energy = target_energy
		_light.light_energy = target_energy
	turned_on.emit()


func _turn_off(animate: bool) -> void:
	if not _is_on and animate:
		return
	_is_on = false
	if _light == null:
		return
	if animate:
		_tween_energy(0.0, fade_out_s * _initial_jitter)
	else:
		_base_energy = 0.0
		_light.light_energy = 0.0
	turned_off.emit()


func _tween_energy(target: float, duration: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_set_base_energy, _base_energy, target, duration)


func _set_base_energy(v: float) -> void:
	_base_energy = v
	if _light != null and flicker_mode == FlickerMode.NONE:
		_light.light_energy = v


# === FLICKER ===

func _apply_flicker(delta: float) -> void:
	if _light == null:
		return
	var t: float = Time.get_ticks_msec() / 1000.0 + _flicker_phase
	var wobble: float = 0.0
	match flicker_mode:
		FlickerMode.CANDLE:
			# Slow random wobble — sin + smaller higher-freq sin
			wobble = sin(t * 3.4) * 0.6 + sin(t * 7.1) * 0.4
		FlickerMode.GAS_LANTERN:
			# Faster, smaller — like a gas mantle
			wobble = sin(t * 8.0) * 0.7 + sin(t * 15.5) * 0.3
		FlickerMode.GLITCH:
			# Sharp on/off pulses with occasional dropouts
			wobble = (1.0 if sin(t * 14.0) > 0.4 else -0.7)
			if randf() < 0.005:
				wobble = -2.0  # full dropout
	_light.light_energy = max(0.0, _base_energy * (1.0 + wobble * flicker_amplitude))


# === EVENTS ===

func _on_phase_changed(phase: StringName) -> void:
	_apply_phase(phase, true)
