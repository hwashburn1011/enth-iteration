class_name ClockDisplay
extends Control

## HUD clock widget showing in-game hour + day + sun/moon icon for the
## current phase. Subscribes to DayNightController for updates.

@onready var _hour_label: Label = %HourLabel
@onready var _day_label: Label = %DayLabel
@onready var _phase_icon: TextureRect = %PhaseIcon

@export var update_every_seconds: float = 1.0

var _update_timer: float = 0.0


func _ready() -> void:
	if has_node("/root/DayNightController"):
		var dnc: Node = get_node("/root/DayNightController")
		dnc.hour_changed.connect(_on_hour_changed)
		dnc.day_advanced.connect(_on_day_advanced)
		dnc.phase_changed.connect(_on_phase_changed)
	_refresh()


func _process(delta: float) -> void:
	_update_timer += delta
	if _update_timer >= update_every_seconds:
		_update_timer = 0.0
		_refresh()


func _refresh() -> void:
	if not has_node("/root/DayNightController"):
		return
	var dnc: Node = get_node("/root/DayNightController")
	var hour: int = dnc.get_current_hour()
	var minute: int = dnc.get_current_minute_of_hour()
	var day: int = dnc.current_day
	var phase: StringName = dnc.current_phase

	if _hour_label != null:
		_hour_label.text = "%02d:%02d" % [hour, minute]
	if _day_label != null:
		_day_label.text = "Day %d" % day
	if _phase_icon != null:
		_phase_icon.modulate = _color_for_phase(phase)


func _color_for_phase(phase: StringName) -> Color:
	match phase:
		&"dawn":  return Color(0.95, 0.75, 0.55)
		&"day":   return Color(1.0, 0.95, 0.65)
		&"dusk":  return Color(0.95, 0.55, 0.30)
		&"night": return Color(0.55, 0.65, 0.85)
	return Color.WHITE


func _on_hour_changed(_h: int) -> void:
	_refresh()


func _on_day_advanced(_d: int) -> void:
	_refresh()


func _on_phase_changed(_p: StringName) -> void:
	_refresh()
