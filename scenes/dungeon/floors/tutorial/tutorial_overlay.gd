class_name TutorialOverlay
extends CanvasLayer
## Shows tutorial instruction text, hides when action is completed.

@export var instruction_text: String = ""

var _label: Label = null


func _ready() -> void:
	layer = 50
	_label = Label.new()
	_label.text = instruction_text
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override(&"font_size", 28)
	_label.anchors_preset = Control.PRESET_CENTER_TOP
	_label.offset_top = 40.0
	_label.offset_left = -300.0
	_label.offset_right = 300.0
	_label.offset_bottom = 100.0
	add_child(_label)


func dismiss() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_label, "modulate:a", 0.0, 0.5)
	await tween.finished
	queue_free()
