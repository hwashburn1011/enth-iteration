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

	_confirm_ui = PanelContainer.new()
	_confirm_ui.anchors_preset = Control.PRESET_CENTER
	_confirm_ui.offset_left = -150
	_confirm_ui.offset_top = -60
	_confirm_ui.offset_right = 150
	_confirm_ui.offset_bottom = 60

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER

	var label: Label = Label.new()
	label.text = "Enter the Compaction Loop?"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	var yes_btn: Button = Button.new()
	yes_btn.text = "Yes"
	yes_btn.custom_minimum_size = Vector2(80, 30)
	yes_btn.pressed.connect(_on_yes_pressed.bind(canvas))
	hbox.add_child(yes_btn)

	var gap: Control = Control.new()
	gap.custom_minimum_size = Vector2(20, 0)
	hbox.add_child(gap)

	var no_btn: Button = Button.new()
	no_btn.text = "No"
	no_btn.custom_minimum_size = Vector2(80, 30)
	no_btn.pressed.connect(_on_no_pressed.bind(canvas))
	hbox.add_child(no_btn)

	vbox.add_child(hbox)
	_confirm_ui.add_child(vbox)
	canvas.add_child(_confirm_ui)
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
