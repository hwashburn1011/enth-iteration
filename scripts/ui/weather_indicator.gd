class_name WeatherIndicator
extends Control

## Small HUD widget showing the current weather + forecast hint.
## Hover for next likely weather change.

@onready var _icon: TextureRect = %WeatherIcon
@onready var _label: Label = %WeatherLabel
@onready var _tooltip: Label = %ForecastTooltip


func _ready() -> void:
	if has_node("/root/WeatherController"):
		var wc: Node = get_node("/root/WeatherController")
		wc.weather_changed.connect(_on_weather_changed)
	_refresh()


func _refresh() -> void:
	if not has_node("/root/WeatherController"):
		return
	var wc: Node = get_node("/root/WeatherController")
	var weather_id: StringName = wc.current_weather_id
	var weather: Dictionary = WeatherDatabase.get_weather(weather_id)
	if _label != null:
		_label.text = weather.get("display_name", "Unknown")
	if _icon != null:
		_icon.modulate = _color_for_weather(weather_id)


func _color_for_weather(weather_id: StringName) -> Color:
	match weather_id:
		&"clear":         return Color(1.0, 0.95, 0.65)
		&"cloudy":        return Color(0.85, 0.85, 0.90)
		&"rain":          return Color(0.55, 0.65, 0.85)
		&"storm":         return Color(0.40, 0.45, 0.65)
		&"fog":           return Color(0.75, 0.75, 0.80)
		&"glitch_storm":  return Color(0.85, 0.30, 0.85)
	return Color.WHITE


func _on_weather_changed(_w: StringName) -> void:
	_refresh()
