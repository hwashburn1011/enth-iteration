class_name HudIntegration
extends RefCounted
## R8 Epic AK — HUD integration helpers for wiring remaining UI elements.
##
## These are the final "plug in" calls that scene scripts invoke to connect
## the helper systems from Rounds 4-7 into the actual runtime HUD.

## AK11: Create heartbeat vignette and wire per-frame update.
static func create_heartbeat_vignette(hud_canvas: CanvasLayer) -> ColorRect:
	var vignette: ColorRect = ColorRect.new()
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.color = Color(0, 0, 0, 0)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.visible = false
	hud_canvas.add_child(vignette)
	return vignette


## AK14: Check achievements and show popup for newly unlocked.
static func check_and_show_achievements(scene_root: Node) -> void:
	var newly: Array[String] = AchievementSystem.check_all()
	for ach_id: String in newly:
		for ach: Dictionary in AchievementSystem.ACHIEVEMENTS:
			if str(ach.get("id", "")) == ach_id:
				_show_achievement_popup(scene_root, str(ach.get("name", "")), str(ach.get("desc", "")))
				break


static func _show_achievement_popup(scene_root: Node, name: String, desc: String) -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 95
	var holder: Control = Control.new()
	holder.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	holder.offset_left = -350
	holder.offset_right = -10
	holder.offset_top = 60
	holder.offset_bottom = 120
	holder.modulate.a = 0.0
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(holder)

	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.08, 0.08, 0.15, 0.9)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(bg)

	var title: Label = Label.new()
	title.text = "ACHIEVEMENT UNLOCKED"
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 5
	title.offset_bottom = 22
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override(&"font_size", 12)
	title.add_theme_color_override(&"font_color", Color(0.9, 0.8, 0.2))
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(title)

	var name_label: Label = Label.new()
	name_label.text = name
	name_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	name_label.offset_top = 24
	name_label.offset_bottom = 44
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override(&"font_size", 18)
	name_label.add_theme_color_override(&"font_color", Color(1.0, 1.0, 1.0))
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(name_label)

	var desc_label: Label = Label.new()
	desc_label.text = desc
	desc_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	desc_label.offset_top = 44
	desc_label.offset_bottom = 58
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.add_theme_font_size_override(&"font_size", 12)
	desc_label.add_theme_color_override(&"font_color", Color(0.6, 0.65, 0.7))
	desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(desc_label)

	scene_root.add_child(canvas)

	var tween: Tween = holder.create_tween()
	tween.tween_property(holder, "modulate:a", 1.0, 0.4)
	tween.tween_interval(3.0)
	tween.tween_property(holder, "modulate:a", 0.0, 0.6)
	tween.tween_callback(canvas.queue_free)
