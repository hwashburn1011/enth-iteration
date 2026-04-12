class_name HudWidgets
extends RefCounted
## R4 Epic Q — HUD widget implementations for QoL features.
##
## Q12: Damage log panel
## Q13: Statistics panel
## Q14: Auto-save indicator
## Q15: Inventory rarity borders
## Q16: Equipment comparison tooltip
## Q17: Respec confirmation dialog
## Q18: Set bonus HUD indicator
## Q19: Font size settings integration
## Q20: Skill tree button in pause menu


## Q12: Create a damage log panel and add it to the HUD.
## Returns the VBoxContainer so the caller can append entries.
static func create_damage_log(parent: Control) -> VBoxContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	panel.offset_left = 10
	panel.offset_right = 320
	panel.offset_top = -250
	panel.offset_bottom = -10
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.02, 0.06, 0.6)
	style.set_corner_radius_all(4)
	panel.add_theme_stylebox_override(&"panel", style)
	parent.add_child(panel)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)
	return vbox


## Add an entry to the damage log VBox.
static func add_damage_log_entry(vbox: VBoxContainer, text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override(&"font_size", 12)
	label.add_theme_color_override(&"font_color", Color(0.7, 0.75, 0.8))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(label)
	# Keep only last N entries
	while vbox.get_child_count() > QoLSystems.DAMAGE_LOG_MAX_ENTRIES:
		vbox.get_child(0).queue_free()


## Q13: Create statistics panel content for pause menu.
static func populate_stats_panel(parent: VBoxContainer) -> void:
	var stats: Array[Dictionary] = QoLRuntime.get_play_statistics()
	for stat: Dictionary in stats:
		var row: HBoxContainer = HBoxContainer.new()
		var lbl: Label = Label.new()
		lbl.text = str(stat.get("label", ""))
		lbl.add_theme_font_size_override(&"font_size", 16)
		lbl.add_theme_color_override(&"font_color", Color(0.6, 0.65, 0.7))
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)
		var val: Label = Label.new()
		val.text = str(stat.get("value", ""))
		val.add_theme_font_size_override(&"font_size", 16)
		val.add_theme_color_override(&"font_color", Color(0.9, 0.92, 0.95))
		val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(val)
		parent.add_child(row)


## Q14: Create auto-save indicator (floppy disk icon flash).
static func create_autosave_indicator(parent: CanvasLayer) -> Label:
	var icon: Label = Label.new()
	icon.text = "[SAVING]"
	icon.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	icon.offset_left = -120
	icon.offset_top = -30
	icon.offset_right = -10
	icon.offset_bottom = -5
	icon.add_theme_font_size_override(&"font_size", 14)
	icon.add_theme_color_override(&"font_color", QoLRuntime.AUTOSAVE_ICON_COLOR)
	icon.visible = false
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(icon)
	return icon


## Flash the auto-save indicator briefly.
static func flash_autosave(icon: Label) -> void:
	if icon == null or not icon.is_inside_tree():
		return
	icon.visible = true
	icon.modulate.a = 1.0
	var tween: Tween = icon.create_tween()
	tween.tween_interval(QoLRuntime.AUTOSAVE_ICON_DURATION * 0.6)
	tween.tween_property(icon, "modulate:a", 0.0, QoLRuntime.AUTOSAVE_ICON_DURATION * 0.4)
	tween.tween_callback(func() -> void: icon.visible = false)


## Q15: Apply rarity border color to an inventory slot ColorRect.
static func apply_rarity_border(slot_bg: ColorRect, rarity: int) -> void:
	var color: Color = QoLRuntime.RARITY_BORDER_COLORS.get(rarity, Color(0.4, 0.4, 0.4))
	# Create a StyleBoxFlat border effect by tinting the slot background edge
	slot_bg.color = color


## Q16: Create equipment comparison tooltip showing stat diffs.
static func create_comparison_tooltip(current: Dictionary, candidate: Dictionary) -> String:
	var diffs: Array[Dictionary] = QoLRuntime.compare_items(current, candidate)
	if diffs.is_empty():
		return ""
	var lines: PackedStringArray = PackedStringArray()
	for diff: Dictionary in diffs:
		var stat_name: String = str(diff.get("stat", ""))
		var delta: float = float(diff.get("diff", 0))
		var sign: String = "+" if delta > 0 else ""
		var color_tag: String = "[color=green]" if delta > 0 else "[color=red]"
		lines.append("%s %s%.0f %s" % [stat_name.capitalize(), sign, delta, color_tag])
	return "\n".join(lines)


## Q17: Create respec confirmation dialog.
static func create_respec_dialog(parent: Control, respec_type: String, cost: int, on_confirm: Callable) -> void:
	var dialog: AcceptDialog = AcceptDialog.new()
	dialog.title = "Confirm Respec"
	dialog.dialog_text = "Reset all %s for %dg?\nThis cannot be undone." % [respec_type, cost]
	dialog.ok_button_text = "Respec"
	dialog.confirmed.connect(on_confirm)
	parent.add_child(dialog)
	dialog.popup_centered()


## Q18: Create set bonus indicator strip.
static func create_set_bonus_strip(parent: Control, equipped_ids: Array[String]) -> void:
	var bonuses: Array[Dictionary] = ProgressionExpansion.get_active_bonuses(equipped_ids)
	if bonuses.is_empty():
		return
	for bonus: Dictionary in bonuses:
		var lbl: Label = Label.new()
		lbl.text = str(bonus.get("description", ""))
		lbl.add_theme_font_size_override(&"font_size", 12)
		lbl.add_theme_color_override(&"font_color", Color(0.9, 0.8, 0.2))
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(lbl)


## Q19: Apply font size preset to a Control tree.
static func apply_font_scale(root: Control, scale: float) -> void:
	for child: Node in root.get_children():
		if child is Label:
			var current_size: int = (child as Label).get_theme_font_size(&"font_size")
			if current_size > 0:
				(child as Label).add_theme_font_size_override(&"font_size", int(current_size * scale))
		if child is Control:
			apply_font_scale(child as Control, scale)
