extends Control
## Demo end screen — thanks the player and offers main menu return.


func _ready() -> void:
	GameManager.set_state(GameManager.GameState.MAIN_MENU)


func _on_main_menu_pressed() -> void:
	GameManager.change_scene_to("res://scenes/main/MainMenu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
