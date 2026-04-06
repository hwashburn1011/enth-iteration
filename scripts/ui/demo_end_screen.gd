extends Control
## Demo end screen — shows stats summary and thank-you message.

@onready var _time_label: Label = %TimeLabel
@onready var _enemies_label: Label = %EnemiesLabel
@onready var _deaths_label: Label = %DeathsLabel
@onready var _level_label: Label = %LevelLabel
@onready var _items_label: Label = %ItemsLabel
@onready var _npcs_label: Label = %NPCsLabel


func _ready() -> void:
	GameManager.set_state(GameManager.GameState.MAIN_MENU)
	EventBus.demo_completed.emit()
	modulate.a = 0.0
	_populate_stats()
	# Fade in
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)


func _populate_stats() -> void:
	# Time played
	var total_sec: int = int(GameManager.play_time_seconds)
	var minutes: int = total_sec / 60
	var seconds: int = total_sec % 60
	_time_label.text = "Time Played: %d:%02d" % [minutes, seconds]

	_enemies_label.text = "Enemies Defeated: %d" % GameManager.total_enemies_defeated
	_deaths_label.text = "Deaths: %d" % GameManager.total_deaths

	# Level — find from player or save data
	var level: int = 1
	var players: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if players.size() > 0:
		var player: Player = players[0] as Player
		if player and player.level_component:
			level = player.level_component.current_level
	_level_label.text = "Highest Level Reached: %d" % level

	_items_label.text = "Items Found: %d" % GameManager.total_items_found
	_npcs_label.text = "NPCs Recruited: %d / 2" % GameManager.recruited_npcs.size()


func _on_return_pressed() -> void:
	GameManager.change_scene_to("res://scenes/town/Town.tscn")


func _on_quit_pressed() -> void:
	SaveManager.save_game()
	get_tree().quit()
