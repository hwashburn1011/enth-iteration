class_name ReleaseUI
extends RefCounted
## R6 Epic Z — Release UI helpers for main menu, quit confirmation, etc.

## Z5: Main menu background particle config.
const MENU_PARTICLE_COLOR: Color = Color(0.3, 0.85, 0.8, 0.3)
const MENU_PARTICLE_COUNT: int = 40

## Z6: Version label text. Updated per release.
const VERSION_STRING: String = "v1.4.0"


## Z7: Show quit confirmation dialog.
static func show_quit_dialog(parent: Control) -> void:
	var dialog: AcceptDialog = AcceptDialog.new()
	dialog.title = "Quit Game"
	dialog.dialog_text = "Are you sure you want to quit?"
	dialog.ok_button_text = "Quit"
	dialog.confirmed.connect(func() -> void:
		SaveManager.save_game()
		parent.get_tree().quit()
	)
	parent.add_child(dialog)
	dialog.popup_centered()


## Z8: Return to main menu from pause with save.
static func return_to_main_menu() -> void:
	SaveManager.save_game()
	GameManager.change_scene_to("res://scenes/main/MainMenu.tscn")


## Z9: New game confirmation (warns about overwrite).
static func show_new_game_dialog(parent: Control, on_confirm: Callable) -> void:
	if not SaveManager.has_method(&"has_save") or not SaveManager.has_save():
		on_confirm.call()
		return
	var dialog: AcceptDialog = AcceptDialog.new()
	dialog.title = "New Game"
	dialog.dialog_text = "This will overwrite your existing save. Continue?"
	dialog.ok_button_text = "New Game"
	dialog.confirmed.connect(on_confirm)
	parent.add_child(dialog)
	dialog.popup_centered()


## Z10: Check if a save file exists (for Continue button state).
static func has_existing_save() -> bool:
	if SaveManager.has_method(&"has_save"):
		return SaveManager.has_save()
	return FileAccess.file_exists("user://savegame.json")
