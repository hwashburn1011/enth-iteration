class_name FarmHarvestResultPopup
extends Node

## Listens to FarmPlot.harvested signals from every FarmPlot in its
## subtree and spawns a small floating world-space popup at the
## harvested plot's position. The popup shows:
##
##   - Crop name + output count
##   - Quality tier badge (Silver / Gold / Crown — colored ring)
##   - Material drops list
##   - XP gain
##   - Tier-2 (Crown) plays a music sting and a brief screen flash
##
## Each popup floats up ~1.2m over 2.5s, then self-fades and frees.
##
## Required scene shape:
##   FarmHarvestResultPopup (Node + this script)
##     [no children needed; popups spawn dynamically as Node3D]
##
## Configure via inspector:
##   plot_root_path  — NodePath under which all FarmPlot instances live
##                     (the farm scene root). Auto-subscribes at _ready
##   popup_lifetime  — seconds the popup is visible

const QUALITY_NAMES: Array[String] = ["Silver", "Gold", "Crown"]
const QUALITY_COLORS: Array[Color] = [
	Color(0.85, 0.86, 0.90),   # Silver — pale gray
	Color(1.00, 0.85, 0.40),   # Gold
	Color(0.95, 0.65, 1.00),   # Crown — purple-pink
]

@export var plot_root_path: NodePath
@export var popup_lifetime: float = 2.5
@export var float_distance: float = 1.2


func _ready() -> void:
	_subscribe_to_plots()


func _subscribe_to_plots() -> void:
	var root: Node = get_node_or_null(plot_root_path)
	if root == null:
		root = get_tree().current_scene
	if root == null:
		return
	var plots: Array[Node] = []
	_collect_plots(root, plots)
	for p in plots:
		if p is FarmPlot:
			(p as FarmPlot).harvested.connect(_on_plot_harvested)


func _collect_plots(node: Node, out: Array[Node]) -> void:
	if node is FarmPlot:
		out.append(node)
	for child in node.get_children():
		_collect_plots(child, out)


# === ON HARVEST ===

func _on_plot_harvested(plot: FarmPlot, crop_id: StringName, count: int, quality: int) -> void:
	if plot == null or not is_instance_valid(plot):
		return
	var crop: Dictionary = CropDatabase.get_crop(crop_id)
	if crop.is_empty():
		return

	var spawn_pos: Vector3 = plot.global_position + Vector3(0, 1.0, 0)
	_spawn_popup(spawn_pos, crop, count, quality)

	# Crown harvest celebration
	if quality >= 2:
		_celebrate_crown()


func _spawn_popup(world_pos: Vector3, crop: Dictionary, count: int, quality: int) -> void:
	var popup: Node3D = Node3D.new()
	popup.name = "HarvestPopup"
	get_tree().current_scene.add_child(popup)
	popup.global_position = world_pos

	# Crop name + count label
	var name_label: Label3D = Label3D.new()
	name_label.text = "+%d %s" % [count, crop.get("name", "Crop")]
	name_label.font_size = 64
	name_label.outline_size = 6
	name_label.modulate = QUALITY_COLORS[clampi(quality, 0, QUALITY_COLORS.size() - 1)]
	name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	name_label.position = Vector3(0, 0, 0)
	popup.add_child(name_label)

	# Quality tier label
	var quality_label: Label3D = Label3D.new()
	quality_label.text = QUALITY_NAMES[clampi(quality, 0, QUALITY_NAMES.size() - 1)]
	quality_label.font_size = 36
	quality_label.outline_size = 4
	quality_label.modulate = QUALITY_COLORS[clampi(quality, 0, QUALITY_COLORS.size() - 1)]
	quality_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	quality_label.position = Vector3(0, -0.4, 0)
	popup.add_child(quality_label)

	# Material drops list (one mini-label per drop)
	var drops: Dictionary = crop.get("drops", {})
	var drop_index: int = 0
	for material_id in drops.keys():
		var drop_label: Label3D = Label3D.new()
		drop_label.text = "+%s" % String(material_id)
		drop_label.font_size = 28
		drop_label.outline_size = 3
		drop_label.modulate = Color(0.85, 0.92, 1.00)
		drop_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		drop_label.position = Vector3(0, -0.7 - 0.3 * drop_index, 0)
		popup.add_child(drop_label)
		drop_index += 1

	# XP label
	var xp_label: Label3D = Label3D.new()
	var xp_amount: int = 5 * (1 + quality)
	xp_label.text = "+%d XP" % xp_amount
	xp_label.font_size = 28
	xp_label.outline_size = 3
	xp_label.modulate = Color(0.65, 1.00, 0.65)
	xp_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	xp_label.position = Vector3(0, -0.7 - 0.3 * drop_index, 0)
	popup.add_child(xp_label)

	# Animate float-up + fade-out
	_animate_popup(popup)

	# SFX
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play_at"):
			sm.play_at(&"sfx_harvest_pop", world_pos)
		elif sm.has_method("play"):
			sm.play(&"sfx_harvest_pop")


func _animate_popup(popup: Node3D) -> void:
	var tween: Tween = popup.create_tween()
	tween.set_parallel(true)

	# Float up
	tween.tween_property(
		popup,
		"position:y",
		popup.position.y + float_distance,
		popup_lifetime
	)

	# Fade out by tweening every Label3D's modulate alpha
	for child in popup.get_children():
		if child is Label3D:
			var label: Label3D = child
			var c: Color = label.modulate
			var target_color: Color = Color(c.r, c.g, c.b, 0.0)
			tween.tween_property(label, "modulate", target_color, popup_lifetime).set_delay(popup_lifetime * 0.4)

	# Free at end
	tween.chain().tween_callback(func() -> void:
		if is_instance_valid(popup):
			popup.queue_free()
	)


# === CROWN CELEBRATION ===

func _celebrate_crown() -> void:
	if has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(&"sting_crown_harvest")
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("screen_flash_requested"):
			bus.emit_signal("screen_flash_requested", Color(0.95, 0.65, 1.00, 0.35), 0.4)
		if bus.has_signal("achievement_progress"):
			bus.emit_signal("achievement_progress", &"crown_farmer", 1)
