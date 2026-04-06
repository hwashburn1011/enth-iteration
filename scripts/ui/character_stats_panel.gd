class_name CharacterStatsPanel
extends PanelContainer
## Shows character stat breakdown: base + equipment + level = total with descriptions.

const STAT_DESCRIPTIONS: Dictionary = {
	"processing": "Increases damage output",
	"bandwidth": "Increases movement speed",
	"memory": "Increases compute pool",
	"integrity": "Increases health and defense",
}

const STATS: Array[String] = ["processing", "bandwidth", "memory", "integrity"]


func populate(player: Player) -> void:
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.theme_override_constants_separation = 6

	var title: Label = Label.new()
	title.text = "Character Stats"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sep: HSeparator = HSeparator.new()
	vbox.add_child(sep)

	var stats_comp: StatsComponent = player.stats_component
	var equip_bonuses: Dictionary = stats_comp.equipment_bonuses

	for stat_name: String in STATS:
		var base_val: float = 0.0
		match stat_name:
			"processing": base_val = stats_comp.base_processing
			"bandwidth": base_val = stats_comp.base_bandwidth
			"memory": base_val = stats_comp.base_memory
			"integrity": base_val = stats_comp.base_integrity

		var level_bonus: float = float(stats_comp.level_points.get(stat_name, 0))
		var equip_bonus: float = float(equip_bonuses.get(stat_name, 0.0))
		var total: float = stats_comp.get_stat(stat_name)

		var hbox: HBoxContainer = HBoxContainer.new()
		var name_lbl: Label = Label.new()
		name_lbl.text = stat_name.capitalize()
		name_lbl.custom_minimum_size = Vector2(100, 0)
		hbox.add_child(name_lbl)

		var breakdown: RichTextLabel = RichTextLabel.new()
		breakdown.bbcode_enabled = true
		breakdown.fit_content = true
		breakdown.custom_minimum_size = Vector2(200, 20)
		breakdown.text = "%d + [color=green]%d[/color] + [color=cyan]%d[/color] = [b]%d[/b]" % [
			int(base_val), int(equip_bonus), int(level_bonus), int(total)
		]
		hbox.add_child(breakdown)
		vbox.add_child(hbox)

		var desc: Label = Label.new()
		desc.text = "  " + STAT_DESCRIPTIONS.get(stat_name, "")
		desc.add_theme_font_size_override(&"font_size", 12)
		desc.modulate = Color(0.7, 0.7, 0.7)
		vbox.add_child(desc)

	# Derived stats
	var sep2: HSeparator = HSeparator.new()
	vbox.add_child(sep2)

	var derived_title: Label = Label.new()
	derived_title.text = "Derived Stats"
	derived_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(derived_title)

	var integrity: float = stats_comp.get_stat("integrity")
	var processing: float = stats_comp.get_stat("processing")
	var memory: float = stats_comp.get_stat("memory")
	var bandwidth: float = stats_comp.get_stat("bandwidth")

	var derived: Array[Array] = [
		["Max Health", "%d" % int(player.health_component.max_health)],
		["Max Compute", "%d" % int(player.compute_component.max_compute)],
		["Move Speed", "%.1f" % player.move_speed],
		["Damage Bonus", "+%.0f%%" % (processing * 10.0)],
		["Defense", "%.1f" % (integrity * 0.5)],
		["Crit Chance", "%.1f%%" % (5.0 + processing * 0.5)],
	]
	for entry: Array in derived:
		var hbox: HBoxContainer = HBoxContainer.new()
		var n: Label = Label.new()
		n.text = entry[0] as String
		n.custom_minimum_size = Vector2(120, 0)
		hbox.add_child(n)
		var v: Label = Label.new()
		v.text = entry[1] as String
		v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		hbox.add_child(v)
		vbox.add_child(hbox)

	add_child(vbox)
