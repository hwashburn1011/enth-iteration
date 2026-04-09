class_name BossHealthBarPhases
extends Control

## Boss HP bar with phase markers (Epic 07 task 45). Drives the on-screen
## boss bar UI with visible notch markers at the phase transition HP
## thresholds (66% and 33% for the Compiler boss) so the player can see
## "I'm about to break the boss into its next phase."
##
## Behavior:
##   1) Listens for the assigned HealthComponent's health_changed signal
##   2) Updates a TextureProgressBar with the current HP fill
##   3) Renders 2 vertical notch lines at the phase threshold positions
##      (drawn via _draw() so they sit ON the bar, not behind it)
##   4) Animates the notch with a brief flash + scale-up when the bar
##      crosses each threshold (so the player gets a clear "phase break"
##      moment)
##   5) Optional boss name + phase label that updates per phase
##
## Required scene shape:
##   BossHealthBarPhases (Control + this script)
##     ProgressBar (TextureProgressBar)
##     %BossNameLabel (Label, optional)
##     %PhaseLabel (Label, optional)
##
## Hookup from boss spawn:
##   var hud: BossHealthBarPhases = preload("res://scenes/ui/boss_health_bar.tscn").instantiate()
##   hud.boss_name = "Corrupted Compiler"
##   hud.phase_thresholds = [0.66, 0.33]
##   hud.phase_labels = ["I — Compiler at Work", "II — Glitching", "III — Corruption"]
##   hud.bind_health_component(boss.get_node("HealthComponent"))
##   ui_layer.add_child(hud)

@export var boss_name: String = ""
@export var phase_thresholds: Array[float] = [0.66, 0.33]
@export var phase_labels: Array[String] = []
@export var notch_color: Color = Color(1.0, 1.0, 1.0, 0.85)
@export var notch_width_px: float = 3.0
@export var notch_flash_color: Color = Color(1.0, 0.95, 0.20, 1.0)

var _hc: Node
var _max_hp: float = 1.0
var _current_hp: float = 1.0
var _current_phase: int = 0
var _notch_flash_intensity: Array[float] = []

@onready var _progress_bar: TextureProgressBar = $ProgressBar if has_node("ProgressBar") else null
@onready var _name_label: Label = get_node_or_null("%BossNameLabel")
@onready var _phase_label: Label = get_node_or_null("%PhaseLabel")


func _ready() -> void:
	# Initialize notch flash intensities
	_notch_flash_intensity.resize(phase_thresholds.size())
	for i in range(phase_thresholds.size()):
		_notch_flash_intensity[i] = 0.0
	if _name_label != null:
		_name_label.text = boss_name
	if _phase_label != null and phase_labels.size() > 0:
		_phase_label.text = phase_labels[0]


func bind_health_component(hc: Node) -> void:
	_hc = hc
	if _hc.has_signal("health_changed"):
		_hc.health_changed.connect(_on_health_changed)
	if _hc.has_method("get_max_hp"):
		_max_hp = _hc.get_max_hp()
	if _hc.has_method("get_current_hp"):
		_current_hp = _hc.get_current_hp()
	_apply_to_progress_bar()


func _on_health_changed(current: float, maximum: float) -> void:
	var prev_pct: float = _current_hp / _max_hp if _max_hp > 0.0 else 0.0
	_current_hp = current
	_max_hp = maximum
	var new_pct: float = _current_hp / _max_hp if _max_hp > 0.0 else 0.0
	_apply_to_progress_bar()
	# Detect threshold crossings (phase breaks)
	for i in range(phase_thresholds.size()):
		var t: float = phase_thresholds[i]
		if prev_pct > t and new_pct <= t:
			_trigger_phase_break(i)
	queue_redraw()


func _apply_to_progress_bar() -> void:
	if _progress_bar == null:
		return
	_progress_bar.max_value = _max_hp
	_progress_bar.value = _current_hp


func _trigger_phase_break(threshold_index: int) -> void:
	_current_phase = threshold_index + 1
	if _phase_label != null and phase_labels.size() > _current_phase:
		_phase_label.text = phase_labels[_current_phase]
	_notch_flash_intensity[threshold_index] = 1.0
	# Tween the flash intensity back to 0
	var tw: Tween = create_tween()
	tw.tween_method(_set_notch_flash.bind(threshold_index), 1.0, 0.0, 1.5)


func _set_notch_flash(value: float, idx: int) -> void:
	_notch_flash_intensity[idx] = value
	queue_redraw()


func _draw() -> void:
	if _progress_bar == null:
		return
	# Draw the notches at the threshold positions on the progress bar
	var bar_rect: Rect2 = _progress_bar.get_rect()
	for i in range(phase_thresholds.size()):
		var t: float = phase_thresholds[i]
		var x_pos: float = bar_rect.position.x + bar_rect.size.x * t
		var top: Vector2 = Vector2(x_pos, bar_rect.position.y - 4.0)
		var bottom: Vector2 = Vector2(x_pos, bar_rect.position.y + bar_rect.size.y + 4.0)
		var flash: float = _notch_flash_intensity[i]
		var color: Color = notch_color.lerp(notch_flash_color, flash)
		var width: float = notch_width_px + flash * 4.0
		draw_line(top, bottom, color, width)
