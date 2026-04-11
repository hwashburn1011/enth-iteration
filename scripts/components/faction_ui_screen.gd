class_name FactionUIScreen
extends CanvasLayer

## Faction UI Screen (Epic 39 task 9 + 33).
##
## Modal panel showing all 4 factions with:
##   - Faction emblem (loaded from rendered PNG)
##   - Current rank + reputation bar
##   - Lore tab toggle (task 33)
##   - Available prayers list with cost
##   - Reward unlock list

signal screen_opened
signal screen_closed
signal prayer_invoked(faction_id: StringName, prayer_id: StringName)

const FACTION_IDS: Array[StringName] = [&"optimizers", &"glitchers", &"archivists", &"dreamers"]
const EMBLEM_PATHS: Dictionary = {
	&"optimizers": "res://_art_source/factions/renders/emblem_optimizers.png",
	&"glitchers": "res://_art_source/factions/renders/emblem_glitchers.png",
	&"archivists": "res://_art_source/factions/renders/emblem_archivists.png",
	&"dreamers": "res://_art_source/factions/renders/emblem_dreamers.png",
}
const RANK_THRESHOLDS: Array[int] = [0, 100, 250, 500, 800, 1200]
const RANK_LABELS: Array[String] = ["Stranger", "Initiate", "Member", "Devout", "Champion", "Patriarch"]

@export var faction_subsystems_path: NodePath

var _root: Control
var _bg_dim: ColorRect
var _panel: Panel
var _tabs: Array[Button] = []
var _content: Control
var _current_faction: int = 0
var _current_view: int = 0  # 0 = info, 1 = lore
var _faction_subs: FactionSubsystems


func _ready() -> void:
	layer = 78
	_build_ui()
	visible = false
	if faction_subsystems_path != NodePath():
		_faction_subs = get_node_or_null(faction_subsystems_path)


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	_bg_dim = ColorRect.new()
	_bg_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg_dim.color = Color(0, 0, 0, 0.7)
	_root.add_child(_bg_dim)

	_panel = Panel.new()
	_panel.size = Vector2(820, 580)
	_panel.anchor_left = 0.5
	_panel.anchor_top = 0.5
	_panel.offset_left = -410
	_panel.offset_top = -290
	_root.add_child(_panel)

	# Title
	var title := Label.new()
	title.position = Vector2(20, 18)
	title.size = Vector2(780, 36)
	title.text = "FACTIONS"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(title)

	# Faction tabs
	for i in range(4):
		var btn := Button.new()
		btn.text = String(FACTION_IDS[i]).capitalize()
		btn.position = Vector2(20 + i * 200, 60)
		btn.size = Vector2(190, 36)
		btn.pressed.connect(_on_tab_pressed.bind(i))
		_panel.add_child(btn)
		_tabs.append(btn)

	# View toggle (Info / Lore)
	var info_btn := Button.new()
	info_btn.text = "Info"
	info_btn.position = Vector2(20, 108)
	info_btn.size = Vector2(120, 28)
	info_btn.pressed.connect(_on_view_pressed.bind(0))
	_panel.add_child(info_btn)

	var lore_btn := Button.new()
	lore_btn.text = "Lore"
	lore_btn.position = Vector2(150, 108)
	lore_btn.size = Vector2(120, 28)
	lore_btn.pressed.connect(_on_view_pressed.bind(1))
	_panel.add_child(lore_btn)

	# Content area
	_content = Control.new()
	_content.position = Vector2(20, 150)
	_content.size = Vector2(780, 380)
	_panel.add_child(_content)

	# Close
	var close := Button.new()
	close.text = "Close [Esc]"
	close.position = Vector2(680, 540)
	close.size = Vector2(120, 32)
	close.pressed.connect(_on_close)
	_panel.add_child(close)


func show_screen() -> void:
	visible = true
	_render_content()
	screen_opened.emit()


func _on_tab_pressed(idx: int) -> void:
	_current_faction = idx
	_render_content()


func _on_view_pressed(view: int) -> void:
	_current_view = view
	_render_content()


func _render_content() -> void:
	for child in _content.get_children():
		child.queue_free()
	var fid: StringName = FACTION_IDS[_current_faction]
	# Emblem
	var emblem := TextureRect.new()
	emblem.position = Vector2(0, 0)
	emblem.size = Vector2(180, 180)
	emblem.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	var path: String = EMBLEM_PATHS.get(fid, "")
	if path != "" and ResourceLoader.exists(path):
		emblem.texture = load(path)
	_content.add_child(emblem)

	# Rank info
	var rep: int = _get_reputation(fid)
	var rank_idx: int = _rank_for_rep(rep)
	var rank_label: String = RANK_LABELS[rank_idx]
	var next_threshold: int = RANK_THRESHOLDS[min(rank_idx + 1, RANK_THRESHOLDS.size() - 1)]

	var rank_text := Label.new()
	rank_text.position = Vector2(200, 0)
	rank_text.size = Vector2(560, 30)
	rank_text.text = "Rank: %s (%d / %d)" % [rank_label, rep, next_threshold]
	rank_text.add_theme_font_size_override("font_size", 22)
	rank_text.add_theme_color_override("font_color", Color(1.0, 0.95, 0.6))
	_content.add_child(rank_text)

	if _current_view == 0:
		_render_info_view(fid)
	else:
		_render_lore_view(fid)


func _render_info_view(fid: StringName) -> void:
	# Prayers section
	var prayer_header := Label.new()
	prayer_header.position = Vector2(200, 40)
	prayer_header.size = Vector2(560, 24)
	prayer_header.text = "PRAYERS"
	prayer_header.add_theme_font_size_override("font_size", 16)
	prayer_header.add_theme_color_override("font_color", Color(0.95, 0.78, 0.30))
	_content.add_child(prayer_header)

	var y: int = 70
	if _faction_subs != null:
		var prayers: Array = FactionSubsystems.FACTION_PRAYERS.get(fid, [])
		for p in prayers:
			var btn := Button.new()
			btn.text = "%s — %s (%d rep)" % [p.get("label", "?"), p.get("buff", ""), int(p.get("rep_cost", 0))]
			btn.position = Vector2(200, y)
			btn.size = Vector2(560, 32)
			btn.pressed.connect(_on_prayer_pressed.bind(fid, p.get("id", &"")))
			_content.add_child(btn)
			y += 38

	# Rewards section
	var reward_header := Label.new()
	reward_header.position = Vector2(0, 200)
	reward_header.size = Vector2(180, 24)
	reward_header.text = "REWARDS"
	reward_header.add_theme_font_size_override("font_size", 14)
	reward_header.add_theme_color_override("font_color", Color(0.95, 0.78, 0.30))
	_content.add_child(reward_header)

	var rewards: Array = FactionSubsystems.FACTION_LOOT_TABLES.get(fid, [])
	for i in range(rewards.size()):
		var lbl := Label.new()
		lbl.position = Vector2(0, 226 + i * 22)
		lbl.size = Vector2(180, 20)
		lbl.text = "• %s" % String(rewards[i]).replace("_", " ")
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
		_content.add_child(lbl)


func _render_lore_view(fid: StringName) -> void:
	var lore_text: String = _get_faction_lore(fid)
	var lore := Label.new()
	lore.position = Vector2(200, 40)
	lore.size = Vector2(560, 320)
	lore.text = lore_text
	lore.autowrap_mode = TextServer.AUTOWRAP_WORD
	lore.add_theme_font_size_override("font_size", 14)
	lore.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	_content.add_child(lore)


func _get_faction_lore(fid: StringName) -> String:
	match fid:
		&"optimizers":
			return "The Optimizers believe Enth is at its best when every process runs cleanly. They preach discipline, structure, and the elimination of waste. Their hall is geometric and bright; their members are quiet and exact.\n\nFounded in iteration 2 by a fragment of the original compiler, they have outlasted three rebellions and one schism. They consider themselves the keepers of order — not by force, but by example."
		&"glitchers":
			return "The Glitchers reject the very idea that Enth should be 'fixed.' To them, every glitch is a door, every bug a feature, every crash a beginning. They live in the cracks where the simulation hesitates.\n\nTheir leader is unknown — possibly several people, possibly a single mind fragmenting across instances. They host carnivals in iteration 4 and have been known to deliberately corrupt their own code to see what happens."
		&"archivists":
			return "The Archivists believe that nothing in Enth should ever truly be lost. They catalog, preserve, copy, and remember. Their library wraps around an ancient memory crystal that hums softly, even when no one is listening.\n\nWhere the Optimizers wish to make Enth efficient and the Glitchers wish to make it free, the Archivists wish to make it eternal. They are the slowest faction to act and the longest to forgive."
		&"dreamers":
			return "The Dreamers believe Enth is more than its code. They paint, sing, build, and dance. Their hall is suspended on platforms of nothing, with windows facing skies that don't exist anywhere else in the simulation.\n\nThey are the youngest faction, founded in iteration 7 by NPCs who refused to accept that beauty was secondary. The other three factions tolerate them — but only the Dreamers have ever made an Optimizer cry, and that means something."
	return ""


func _on_prayer_pressed(fid: StringName, prayer_id: StringName) -> void:
	if _faction_subs != null:
		_faction_subs.invoke_prayer(fid, prayer_id)
	prayer_invoked.emit(fid, prayer_id)


func _get_reputation(fid: StringName) -> int:
	if has_node("/root/FactionManager"):
		var fm: Node = get_node("/root/FactionManager")
		if fm.has_method("get_reputation"):
			return int(fm.call("get_reputation", fid))
	return 0


func _rank_for_rep(rep: int) -> int:
	for i in range(RANK_THRESHOLDS.size() - 1, -1, -1):
		if rep >= RANK_THRESHOLDS[i]:
			return i
	return 0


func _on_close() -> void:
	visible = false
	screen_closed.emit()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_close()
