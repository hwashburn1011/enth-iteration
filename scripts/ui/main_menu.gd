extends Control
## Main menu UI — title screen with New Game, Continue, and Quit buttons.

@onready var _new_game_button: Button = %NewGameButton
@onready var _continue_button: Button = %ContinueButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	GameManager.set_state(GameManager.GameState.MAIN_MENU)
	_new_game_button.pressed.connect(_on_new_game_pressed)
	_continue_button.pressed.connect(_on_continue_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)

	# Show/hide continue based on save existence
	_continue_button.visible = SaveManager.has_valid_save()

	if _continue_button.visible:
		_continue_button.grab_focus()
	else:
		_new_game_button.grab_focus()


func _on_new_game_pressed() -> void:
	SaveManager.new_game()


func _on_continue_pressed() -> void:
	if SaveManager.load_game():
		var scene_path: String = SaveManager.current_data.get("player", {}).get("current_scene", "res://scenes/town/Town.tscn") as String
		GameManager.change_scene_to(scene_path)
	else:
		push_warning("MainMenu: failed to load save, starting new game")
		SaveManager.new_game()


func _on_quit_pressed() -> void:
	get_tree().quit()
