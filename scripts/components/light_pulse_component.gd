class_name LightPulseComponent
extends Node

## Attaches to a parent Light3D and adds sin-wave energy pulse:
## - Configurable amplitude + frequency
## - Used for: charging weapons, ability indicators, glowing crystals
## - Optional sync to a global beat signal for music-reactive lights

@export var enabled: bool = true
@export var base_energy: float = 1.0
@export var amplitude: float = 0.5  ## peak deviation from base
@export var frequency_hz: float = 1.5
@export var sync_to_beat: bool = false  ## hook to global beat signal if available

var _light: Light3D
var _time: float = 0.0
var _beat_offset: float = 0.0


func _ready() -> void:
	_light = get_parent() as Light3D
	if _light == null:
		push_warning("LightPulseComponent: parent is not a Light3D")
		set_process(false)
		return
	if base_energy <= 0.0:
		base_energy = _light.light_energy

	if sync_to_beat:
		if has_node("/root/EventBus"):
			var bus: Node = get_node("/root/EventBus")
			if bus.has_signal("music_beat"):
				bus.music_beat.connect(_on_beat)


func _process(delta: float) -> void:
	if not enabled or _light == null:
		return
	_time += delta
	var phase: float = _time * frequency_hz * TAU + _beat_offset
	var pulse: float = sin(phase) * 0.5 + 0.5  # 0..1
	_light.light_energy = base_energy + amplitude * pulse


func _on_beat() -> void:
	# Snap phase so the pulse aligns with the beat
	_beat_offset = -_time * frequency_hz * TAU


func set_base_energy(energy: float) -> void:
	base_energy = energy


func set_amplitude(amount: float) -> void:
	amplitude = amount
