class_name PetInfoCardUI
extends CanvasLayer

## Pet Info Card UI (Epic 41 task 43 + 47).
##
## Compact info card panel showing a pet's:
##   - Portrait (loaded from rendered PNG)
##   - Name + species
##   - Level + happiness + bond
##   - Stats (HP, ATK, DEF, SPD)
##   - Active passive ability
##   - Lore description
##   - Ambient SFX preview button
##
## Also hosts the ambient SFX hooks for each pet.

signal card_opened(pet_id: StringName)
signal card_closed
signal pet_renamed(pet_id: StringName, new_name: String)
signal sfx_previewed(pet_id: StringName)

const PORTRAIT_PATHS: Dictionary = {
	&"data_sprite": "res://_art_source/pets/renders/pet_data_sprite_portrait.png",
	&"patch_dog": "res://_art_source/pets/renders/pet_patch_dog_portrait.png",
	&"bit_cat": "res://_art_source/pets/renders/pet_bit_cat_portrait.png",
	&"bug_buddy": "res://_art_source/pets/renders/pet_bug_buddy_portrait.png",
	&"memory_owl": "res://_art_source/pets/renders/pet_memory_owl_portrait.png",
	&"cache_mouse": "res://_art_source/pets/renders/pet_cache_mouse_portrait.png",
	&"echo_bird": "res://_art_source/pets/renders/pet_echo_bird_portrait.png",
	&"crystal_fox": "res://_art_source/pets/renders/pet_crystal_fox_portrait.png",
}

# === TASK 47: Per-pet ambient SFX hooks ===
const PET_AMBIENT_SFX: Dictionary = {
	&"data_sprite": &"sfx_pet_sprite_chime",
	&"patch_dog": &"sfx_pet_dog_pant",
	&"bit_cat": &"sfx_pet_cat_purr",
	&"bug_buddy": &"sfx_pet_bug_buzz",
	&"memory_owl": &"sfx_pet_owl_hoot",
	&"cache_mouse": &"sfx_pet_mouse_squeak",
	&"echo_bird": &"sfx_pet_bird_chirp",
	&"crystal_fox": &"sfx_pet_fox_yip",
}

const PET_LORE: Dictionary = {
	&"data_sprite": "Born from a forgotten variable in iteration 1, the Data Sprite is the oldest known pet. It hums in binary and never quite stops glowing.",
	&"patch_dog": "A loyal companion stitched together from broken patches of older code. Its tail wags in 60Hz.",
	&"bit_cat": "Sleek as a single-bit op, the Bit Cat appears and vanishes between frames. Its fur reacts to compiled emotion.",
	&"bug_buddy": "What looks like an infestation is actually a friend. Bug Buddies thrive in corrupted memory and sing through their carapaces.",
	&"memory_owl": "An ancient archive in feathered form. Its crystal eye contains a fragment of every iteration that ever was.",
	&"cache_mouse": "Industrious and pocket-sized. The Cache Mouse hides things and brings them back days later, sometimes years.",
	&"echo_bird": "Sings in waveforms instead of notes. Each call leaves three trails behind it that fade exactly 1.2 seconds later.",
	&"crystal_fox": "Rare and elusive. The Crystal Fox grows new crystals when it sleeps near the player. Some say it chooses its owner, not the other way around.",
}

@export var pet_subsystems_path: NodePath

var _root: Control
var _bg_dim: ColorRect
var _panel: Panel
var _portrait: TextureRect
var _name_label: Label
var _level_label: Label
var _stats_panel: VBoxContainer
var _passive_label: Label
var _lore_label: Label
var _name_edit: LineEdit
var _sfx_button: Button
var _current_pet_id: StringName = &""


func _ready() -> void:
	layer = 79
	_build_ui()
	visible = false


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	_bg_dim = ColorRect.new()
	_bg_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg_dim.color = Color(0, 0, 0, 0.7)
	_root.add_child(_bg_dim)

	_panel = Panel.new()
	_panel.size = Vector2(640, 580)
	_panel.anchor_left = 0.5
	_panel.anchor_top = 0.5
	_panel.offset_left = -320
	_panel.offset_top = -290
	_root.add_child(_panel)

	# Portrait
	_portrait = TextureRect.new()
	_portrait.position = Vector2(20, 20)
	_portrait.size = Vector2(280, 280)
	_portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_panel.add_child(_portrait)

	# Name (editable)
	_name_label = Label.new()
	_name_label.position = Vector2(20, 310)
	_name_label.size = Vector2(280, 32)
	_name_label.add_theme_font_size_override("font_size", 24)
	_name_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.6))
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(_name_label)

	_name_edit = LineEdit.new()
	_name_edit.position = Vector2(20, 348)
	_name_edit.size = Vector2(280, 28)
	_name_edit.placeholder_text = "Rename..."
	_name_edit.text_submitted.connect(_on_name_submitted)
	_panel.add_child(_name_edit)

	# Level + happiness + bond
	_level_label = Label.new()
	_level_label.position = Vector2(20, 384)
	_level_label.size = Vector2(280, 22)
	_level_label.add_theme_font_size_override("font_size", 14)
	_level_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	_level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(_level_label)

	# SFX preview button
	_sfx_button = Button.new()
	_sfx_button.text = "Play Ambient SFX"
	_sfx_button.position = Vector2(50, 412)
	_sfx_button.size = Vector2(220, 32)
	_sfx_button.pressed.connect(_on_sfx_pressed)
	_panel.add_child(_sfx_button)

	# Stats (right side)
	var stats_header := Label.new()
	stats_header.position = Vector2(320, 20)
	stats_header.size = Vector2(300, 24)
	stats_header.text = "STATS"
	stats_header.add_theme_font_size_override("font_size", 16)
	stats_header.add_theme_color_override("font_color", Color(0.95, 0.78, 0.30))
	_panel.add_child(stats_header)

	_stats_panel = VBoxContainer.new()
	_stats_panel.position = Vector2(320, 48)
	_stats_panel.size = Vector2(300, 120)
	_panel.add_child(_stats_panel)

	# Passive
	var passive_header := Label.new()
	passive_header.position = Vector2(320, 180)
	passive_header.size = Vector2(300, 24)
	passive_header.text = "PASSIVE"
	passive_header.add_theme_font_size_override("font_size", 16)
	passive_header.add_theme_color_override("font_color", Color(0.95, 0.78, 0.30))
	_panel.add_child(passive_header)

	_passive_label = Label.new()
	_passive_label.position = Vector2(320, 208)
	_passive_label.size = Vector2(300, 60)
	_passive_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_passive_label.add_theme_font_size_override("font_size", 13)
	_passive_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	_panel.add_child(_passive_label)

	# Lore
	var lore_header := Label.new()
	lore_header.position = Vector2(20, 460)
	lore_header.size = Vector2(600, 24)
	lore_header.text = "LORE"
	lore_header.add_theme_font_size_override("font_size", 16)
	lore_header.add_theme_color_override("font_color", Color(0.95, 0.78, 0.30))
	_panel.add_child(lore_header)

	_lore_label = Label.new()
	_lore_label.position = Vector2(20, 488)
	_lore_label.size = Vector2(600, 60)
	_lore_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_lore_label.add_theme_font_size_override("font_size", 12)
	_lore_label.add_theme_color_override("font_color", Color(0.7, 0.78, 0.92))
	_panel.add_child(_lore_label)

	# Close button
	var close := Button.new()
	close.text = "Close [Esc]"
	close.position = Vector2(500, 540)
	close.size = Vector2(120, 32)
	close.pressed.connect(_on_close)
	_panel.add_child(close)


func show_card(pet_id: StringName, pet_data: Dictionary = {}) -> void:
	_current_pet_id = pet_id
	visible = true

	# Portrait
	var path: String = PORTRAIT_PATHS.get(pet_id, "")
	if path != "" and ResourceLoader.exists(path):
		_portrait.texture = load(path)

	# Name
	var pet_name: String = pet_data.get("name", String(pet_id).capitalize().replace("_", " "))
	_name_label.text = pet_name
	_name_edit.text = ""

	# Level + happiness + bond
	var level: int = int(pet_data.get("level", 1))
	var happiness: int = int(pet_data.get("happiness", 50))
	var bond: int = int(pet_data.get("bond", 0))
	_level_label.text = "Lv %d  ·  Happiness %d/100  ·  Bond %d" % [level, happiness, bond]

	# Stats
	_render_stats(pet_data.get("stats", {}))

	# Passive
	_passive_label.text = String(pet_data.get("passive", "No passive ability."))

	# Lore
	_lore_label.text = PET_LORE.get(pet_id, "")

	card_opened.emit(pet_id)


func _render_stats(stats: Dictionary) -> void:
	for child in _stats_panel.get_children():
		child.queue_free()
	for stat_id in ["hp", "atk", "def", "spd"]:
		var label := Label.new()
		var val: int = int(stats.get(stat_id, 0))
		label.text = "%s: %d" % [stat_id.to_upper(), val]
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
		_stats_panel.add_child(label)


func _on_name_submitted(new_name: String) -> void:
	if new_name.strip_edges() == "":
		return
	_name_label.text = new_name
	pet_renamed.emit(_current_pet_id, new_name)
	if has_node("/root/PetManager"):
		var pm: Node = get_node("/root/PetManager")
		if pm.has_method("rename_pet"):
			pm.call("rename_pet", _current_pet_id, new_name)


func _on_sfx_pressed() -> void:
	var sfx: StringName = PET_AMBIENT_SFX.get(_current_pet_id, &"")
	if sfx == &"":
		return
	if has_node("/root/AudioManager"):
		var am: Node = get_node("/root/AudioManager")
		if am.has_method("play_sfx"):
			am.call("play_sfx", sfx)
	sfx_previewed.emit(_current_pet_id)


func _on_close() -> void:
	visible = false
	card_closed.emit()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_close()
