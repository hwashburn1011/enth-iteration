class_name LightFlickerComponent
extends Node

## Attaches to a parent Light3D and adds candle/torch flicker behavior:
## - Random energy variation in [base × 0.85, base × 1.05]
## - Subtle warm <-> cool color tint shift
## - Configurable frequency
## - Optional "out" probability for momentary blackout

@export var enabled: bool = true
@export var base_energy: float = 1.0
@export var energy_variation: float = 0.15  ## ± from base
@export var color_warm: Color = Color(1.0, 0.85, 0.55)
@export var color_cool: Color = Color(0.95, 0.92, 0.85)
@export var color_tint_amount: float = 0.10
@export var frequency_hz: float = 12.0
@export var out_probability: float = 0.005
@export var out_recovery_time: float = 0.15

var _light: Light3D
var _time: float = 0.0
var _next_flicker_at: float = 0.0
var _is_out: bool = false
var _out_remaining: float = 0.0
var _saved_color: Color


func _ready() -> void:
	_light = get_parent() as Light3D
	if _light == null:
		push_warning("LightFlickerComponent: parent is not a Light3D")
		set_process(false)
		return
	if base_energy <= 0.0:
		base_energy = _light.light_energy
	_saved_color = _light.light_color


func _process(delta: float) -> void:
	if not enabled or _light == null:
		return
	_time += delta

	if _is_out:
		_out_remaining -= delta
		if _out_remaining <= 0.0:
			_is_out = false
			_light.light_energy = base_energy
		return

	if _time >= _next_flicker_at:
		_next_flicker_at = _time + (1.0 / frequency_hz) * randf_range(0.7, 1.3)
		# Random energy variation
		var variation: float = randf_range(-energy_variation, energy_variation)
		_light.light_energy = base_energy + base_energy * variation

		# Subtle color tint
		var tint_t: float = randf_range(-color_tint_amount, color_tint_amount)
		var target_color: Color = _saved_color.lerp(
			color_warm if tint_t > 0 else color_cool,
			abs(tint_t)
		)
		_light.light_color = target_color

		# Out probability
		if randf() < out_probability:
			_is_out = true
			_out_remaining = out_recovery_time
			_light.light_energy = base_energy * 0.1


func reset() -> void:
	if _light != null:
		_light.light_energy = base_energy
		_light.light_color = _saved_color
	_is_out = false
	_out_remaining = 0.0
