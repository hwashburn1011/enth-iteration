extends Control
## Main menu UI — title screen with New Game and Quit buttons.

const GAME_SCENE_PATH: String = "res://scenes/town/Town.tscn"

@onready var _new_game_button: Button = %NewGameButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	GameManager.set_state(GameManager.GameState.MAIN_MENU)
	_new_game_button.pressed.connect(_on_new_game_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	_new_game_button.grab_focus()


func _on_new_game_pressed() -> void:
	GameManager.change_scene_to(GAME_SCENE_PATH)


func _on_quit_pressed() -> void:
	get_tree().quit()
