class_name BossHealthBar
extends CanvasLayer
## Top-of-screen boss health bar with name and phase markers.

var _bar: ProgressBar = null
var _name_label: Label = null
var _boss: CorruptedCompiler = null


func _ready() -> void:
	layer = 15

	var container: PanelContainer = PanelContainer.new()
	container.anchors_preset = Control.PRESET_CENTER_TOP
	container.offset_left = -250.0
	container.offset_top = 10.0
	container.offset_right = 250.0
	container.offset_bottom = 60.0

	var vbox: VBoxContainer = VBoxContainer.new()
	_name_label = Label.new()
	_name_label.text = "Corrupted Compiler"
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_name_label)

	_bar = ProgressBar.new()
	_bar.custom_minimum_size = Vector2(480, 20)
	_bar.max_value = 500.0
	_bar.value = 500.0
	_bar.show_percentage = false
	vbox.add_child(_bar)

	container.add_child(vbox)
	add_child(container)


func track_boss(boss: CorruptedCompiler) -> void:
	_boss = boss
	_bar.max_value = boss.health_component.max_health
	_bar.value = boss.health_component.current_health
	boss.health_component.health_changed.connect(_on_health_changed)
	boss.health_component.died.connect(_on_boss_died)


func _on_health_changed(current: float, max_val: float) -> void:
	_bar.max_value = max_val
	var tween: Tween = create_tween()
	tween.tween_property(_bar, "value", current, 0.2).set_ease(Tween.EASE_OUT)


func _on_boss_died() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_bar, "value", 0.0, 0.5)
	tween.tween_interval(1.0)
	tween.tween_callback(queue_free)
