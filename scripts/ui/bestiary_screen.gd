class_name BestiaryScreen
extends Control

## Bestiary UI screen (Epic 08 task 39).
## Shows the player's discovered enemies in a 2-column layout: a left
## sidebar listing every enemy the player has encountered + their
## tagline, and a right detail panel showing the hero render + tagline +
## encounter notes + lore flavor + designer one-liner. The detail panel
## also includes the floor tier unlock + tuning summary (HP/damage at
## each tier) so the player can plan around upgrades.
##
## Loads bestiary text from data/enemies/bestiary_text.json and tuning
## from data/enemies/tuning/<id>_tuning.tres.
##
## Required scene shape:
##   BestiaryScreen (Control + this script, anchor full rect)
##     %EntryList (ItemList) — left sidebar
##     %DetailContainer (VBoxContainer) — right panel
##       %HeroRender (TextureRect)
##       %DisplayName (Label)
##       %Tagline (Label)
##       %TuningSummary (Label)
##       %EncounterNotes (RichTextLabel)
##       %LoreFlavor (RichTextLabel)
##     %CloseButton (Button)
##
## Hookup from a UI manager:
##   var bestiary: BestiaryScreen = preload("res://scenes/ui/bestiary_screen.tscn").instantiate()
##   bestiary.discovered_enemies = save.discovered_enemies
##   ui_layer.add_child(bestiary)

const BESTIARY_TEXT_PATH: String = "res://data/enemies/bestiary_text.json"
const TUNING_DIR: String = "res://data/enemies/tuning/"
const HERO_RENDER_DIR: String = "res://assets/textures/bestiary/"

@export var discovered_enemies: Array[StringName] = []
@export var auto_load_on_ready: bool = true

@onready var _entry_list: ItemList = get_node_or_null("%EntryList")
@onready var _hero_render: TextureRect = get_node_or_null("%HeroRender")
@onready var _display_name: Label = get_node_or_null("%DisplayName")
@onready var _tagline: Label = get_node_or_null("%Tagline")
@onready var _tuning_summary: Label = get_node_or_null("%TuningSummary")
@onready var _encounter_notes: RichTextLabel = get_node_or_null("%EncounterNotes")
@onready var _lore_flavor: RichTextLabel = get_node_or_null("%LoreFlavor")
@onready var _close_button: Button = get_node_or_null("%CloseButton")

var _bestiary_data: Dictionary = {}
var _entry_ids: Array[StringName] = []


func _ready() -> void:
	if auto_load_on_ready:
		_load_bestiary_text()
		_populate_entry_list()
		if _entry_ids.size() > 0:
			_select_entry(0)
	if _entry_list != null:
		_entry_list.item_selected.connect(_select_entry)
	if _close_button != null:
		_close_button.pressed.connect(_on_close)


func _load_bestiary_text() -> void:
	if not FileAccess.file_exists(BESTIARY_TEXT_PATH):
		push_warning("BestiaryScreen: bestiary_text.json missing")
		return
	var f: FileAccess = FileAccess.open(BESTIARY_TEXT_PATH, FileAccess.READ)
	var content: String = f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(content)
	if parsed is Dictionary:
		_bestiary_data = parsed


func _populate_entry_list() -> void:
	if _entry_list == null:
		return
	_entry_list.clear()
	_entry_ids.clear()
	for key in _bestiary_data.keys():
		if key in ["version", "epic", "description"]:
			continue
		var entry: Dictionary = _bestiary_data[key]
		var enemy_id: StringName = StringName(key)
		var label: String = entry.get("display_name", String(key))
		# Lock undiscovered enemies (show as "???")
		if not _is_discovered(enemy_id):
			label = "??? — undiscovered"
		_entry_list.add_item(label)
		_entry_ids.append(enemy_id)


func _is_discovered(enemy_id: StringName) -> bool:
	if discovered_enemies.is_empty():
		# Treat all as discovered if the player loadout doesn't track it
		return true
	return discovered_enemies.has(enemy_id)


func _select_entry(index: int) -> void:
	if index < 0 or index >= _entry_ids.size():
		return
	var enemy_id: StringName = _entry_ids[index]
	if not _bestiary_data.has(String(enemy_id)):
		return
	var entry: Dictionary = _bestiary_data[String(enemy_id)]
	# Hide details for undiscovered
	if not _is_discovered(enemy_id):
		_show_undiscovered()
		return
	if _display_name != null:
		_display_name.text = entry.get("display_name", "")
	if _tagline != null:
		_tagline.text = entry.get("tagline", "")
	if _encounter_notes != null:
		_encounter_notes.text = entry.get("encounter_notes", "")
	if _lore_flavor != null:
		_lore_flavor.text = entry.get("lore_flavor", "")
	_load_hero_render(enemy_id)
	_load_tuning_summary(enemy_id)


func _show_undiscovered() -> void:
	if _display_name != null:
		_display_name.text = "???"
	if _tagline != null:
		_tagline.text = "Defeat this enemy to unlock its bestiary entry."
	if _encounter_notes != null:
		_encounter_notes.text = ""
	if _lore_flavor != null:
		_lore_flavor.text = ""
	if _hero_render != null:
		_hero_render.texture = null
	if _tuning_summary != null:
		_tuning_summary.text = ""


func _load_hero_render(enemy_id: StringName) -> void:
	if _hero_render == null:
		return
	var path: String = HERO_RENDER_DIR + String(enemy_id) + "_hero.png"
	if ResourceLoader.exists(path):
		_hero_render.texture = load(path)
	else:
		_hero_render.texture = null


func _load_tuning_summary(enemy_id: StringName) -> void:
	if _tuning_summary == null:
		return
	var path: String = TUNING_DIR + String(enemy_id) + "_tuning.tres"
	if not ResourceLoader.exists(path):
		_tuning_summary.text = ""
		return
	var tuning: EnemyTuning = load(path) as EnemyTuning
	if tuning == null:
		return
	var lines: Array[String] = []
	lines.append("[Floor tiers]")
	for tier in range(tuning.base_hp_per_tier.size()):
		var hp: float = tuning.get_hp_for_tier(tier)
		var dmg: float = tuning.get_damage_for_tier(tier)
		var xp: int = tuning.get_xp_for_tier(tier)
		lines.append("  T%d:  %d HP   %d DMG   %d XP" % [tier + 1, int(hp), int(dmg), xp])
	lines.append("")
	lines.append("Move speed: %.1f m/s" % tuning.move_speed_m_s)
	lines.append("Aggro range: %.0f m" % tuning.aggro_range_m)
	if tuning.unique_drop_id != &"":
		lines.append("Unique drop: %s (%.0f%%)" % [String(tuning.unique_drop_id), tuning.rare_drop_chance * 100.0])
	_tuning_summary.text = "\n".join(lines)


func _on_close() -> void:
	queue_free()
