class_name DungeonEntrance
extends Node3D
## Interactable dungeon entrance — shows confirmation UI before starting a run.

const DUNGEON_SCENE_PATH: String = "res://scenes/dungeon/Dungeon.tscn"

var _player_in_range: bool = false
var _confirm_ui: PanelContainer = null

@onready var _interaction_area: Area3D = %InteractionArea
@onready var _label: Label3D = %EntranceLabel


func _ready() -> void:
	_interaction_area.body_entered.connect(_on_body_entered)
	_interaction_area.body_exited.connect(_on_body_exited)
	_label.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range or _confirm_ui != null:
		return
	if event.is_action_pressed(&"interact"):
		_show_confirmation()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = true
		_label.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false
		_label.visible = false


func _show_confirmation() -> void:
	GameManager.set_state(GameManager.GameState.DIALOGUE)

	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 50
	add_child(canvas)

	# Full-screen container so anchors work correctly
	var fullscreen: Control = Control.new()
	fullscreen.set_anchors_preset(Control.PRESET_FULL_RECT)
	fullscreen.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas.add_child(fullscreen)

	# Dim background
	var dim: ColorRect = ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.5)
	fullscreen.add_child(dim)

	_confirm_ui = PanelContainer.new()
	_confirm_ui.set_anchors_preset(Control.PRESET_CENTER)
	_confirm_ui.offset_left = -160
	_confirm_ui.offset_top = -70
	_confirm_ui.offset_right = 160
	_confirm_ui.offset_bottom = 70

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override(&"separation", 12)

	var label: Label = Label.new()
	label.text = "Enter the Compaction Loop?"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override(&"separation", 20)

	var yes_btn: Button = Button.new()
	yes_btn.text = "Yes"
	yes_btn.custom_minimum_size = Vector2(100, 36)
	yes_btn.pressed.connect(_on_yes_pressed.bind(canvas))
	hbox.add_child(yes_btn)

	var no_btn: Button = Button.new()
	no_btn.text = "No"
	no_btn.custom_minimum_size = Vector2(100, 36)
	no_btn.pressed.connect(_on_no_pressed.bind(canvas))
	hbox.add_child(no_btn)

	vbox.add_child(hbox)
	_confirm_ui.add_child(vbox)
	fullscreen.add_child(_confirm_ui)
	yes_btn.grab_focus()


func _on_yes_pressed(canvas: CanvasLayer) -> void:
	canvas.queue_free()
	_confirm_ui = null
	EventBus.dungeon_entered.emit()
	GameManager.change_scene_to(DUNGEON_SCENE_PATH)


func _on_no_pressed(canvas: CanvasLayer) -> void:
	canvas.queue_free()
	_confirm_ui = null
	GameManager.set_state(GameManager.GameState.PLAYING)
