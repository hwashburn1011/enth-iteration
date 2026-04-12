class_name HUD
extends CanvasLayer
## Gameplay HUD — health bar, compute bar. Hides during dialogue.

const TWEEN_DURATION: float = 0.2

@onready var health_bar: ProgressBar = %HealthBar
@onready var health_label: Label = %HealthLabel
@onready var compute_bar: ProgressBar = %ComputeBar
@onready var compute_label: Label = %ComputeLabel
@onready var _container: Control = %HUDContainer
@onready var _ability_slots_container: HBoxContainer = %AbilitySlots
@onready var _prompt_icon: ColorRect = %PromptIcon
@onready var _prompt_quantity: Label = %PromptQuantity
@onready var _xp_bar: ProgressBar = %XPBar
@onready var _level_label: Label = %LevelLabel

var _health_tween: Tween = null
var _compute_tween: Tween = null
var _ability_slot_uis: Array[AbilitySlotUI] = []
var _room_label: Label = null
var _kill_streak: int = 0
var _kill_streak_timer: float = 0.0
var _streak_label: Label = null
const STREAK_TIMEOUT: float = 3.0
var _low_health_vignette: ColorRect = null
var _low_health_time: float = 0.0
var _boss_panel: PanelContainer = null
var _boss_bar: ProgressBar = null
var _boss_name_label: Label = null
var _boss_ref: Node = null
var _controls_hint: PanelContainer = null
var _prompt_indicator_root: Control = null
var _room_panel: PanelContainer = null
var _iteration_panel: PanelContainer = null
var _iteration_label: Label = null
## Per-NPC tier cache for affinity tier-up detection. Built lazily as
## affinity_changed signals fire so we don't bake state into the HUD ctor.
var _last_affinity_tier: Dictionary = {}
## Phase 4 #35 — active quest HUD widget, top-right corner.
var _quest_panel: PanelContainer = null
var _quest_title_label: Label = null
var _quest_obj_label: Label = null
## R2 F3 — gold display label.
var _gold_label: Label = null

# Phase 3 #23 — debuff icon strip. Anchored top-left under the
# health/compute bars; child chips are PanelContainers keyed by
# effect name in _debuff_chips so we can refresh remaining-time
# labels every frame without rebuilding the row on each tick.
var _debuff_strip: HBoxContainer = null
var _debuff_chips: Dictionary = {}  # effect_name (String) -> Dictionary{panel, label, manager_ref}
var _player_status_manager: Node = null


func _ready() -> void:
	layer = 10
	add_to_group(&"hud")
	_apply_sci_fi_theme()
	# Connect to player signals after a frame (player may not exist yet)
	_connect_player.call_deferred()
	EventBus.dialogue_started.connect(_on_dialogue_started)
	EventBus.dialogue_ended.connect(_on_dialogue_ended)
	EventBus.enemy_defeated.connect(_on_enemy_killed_streak)
	EventBus.scene_changed.connect(_refresh_iteration_chip)
	# game_loaded fires AFTER IterationManager.from_save_data restores the
	# iteration value, so the chip needs to re-read on load. Without this
	# the chip shows the pre-load iteration whenever the player loads a save
	# without triggering a scene change. Also makes game_loaded a real
	# listener instead of a dead signal.
	EventBus.game_loaded.connect(_refresh_iteration_chip_no_arg)
	EventBus.affinity_changed.connect(_on_affinity_changed)
	_create_room_indicator()
	_create_iteration_chip()
	_create_controls_hint()
	_create_debuff_strip()
	_create_quest_widget()
	EventBus.quest_updated.connect(_on_quest_updated)
	_create_gold_display()
	EventBus.enemy_defeated.connect(_on_enemy_defeated_gold)


func _process(delta: float) -> void:
	_process_streak(delta)
	_process_low_health(delta)
	_process_debuff_timers()


func show_boss_bar(boss: Node, boss_display_name: String) -> void:
	## Called by boss enemy on spawn to create a dramatic HUD health bar
	if _boss_panel and is_instance_valid(_boss_panel):
		_boss_panel.queue_free()
	_boss_ref = boss
	_boss_panel = PanelContainer.new()
	# Bottom-center: doesn't collide with top-left HP bars or top-center tutorial banner
	_boss_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_boss_panel.offset_left = -300.0
	_boss_panel.offset_top = -150.0
	_boss_panel.offset_right = 300.0
	_boss_panel.offset_bottom = -90.0
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.03, 0.03, 0.92)
	panel_style.border_color = Color(0.85, 0.18, 0.12, 0.95)
	panel_style.set_border_width_all(2)
	panel_style.border_width_top = 4
	panel_style.set_corner_radius_all(5)
	panel_style.set_content_margin_all(12)
	_boss_panel.add_theme_stylebox_override(&"panel", panel_style)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 6)

	_boss_name_label = Label.new()
	_boss_name_label.text = boss_display_name
	_boss_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_name_label.add_theme_color_override(&"font_color", Color(0.98, 0.32, 0.22))
	_boss_name_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.85))
	_boss_name_label.add_theme_constant_override(&"outline_size", 4)
	_boss_name_label.add_theme_font_size_override(&"font_size", 22)
	vbox.add_child(_boss_name_label)

	_boss_bar = ProgressBar.new()
	_boss_bar.custom_minimum_size = Vector2(0, 22)
	_boss_bar.show_percentage = false
	var bar_bg: StyleBoxFlat = StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.15, 0.05, 0.05, 0.95)
	bar_bg.set_border_width_all(1)
	bar_bg.border_color = Color(0.5, 0.1, 0.05, 0.9)
	bar_bg.set_corner_radius_all(3)
	_boss_bar.add_theme_stylebox_override(&"background", bar_bg)
	var bar_fill: StyleBoxFlat = StyleBoxFlat.new()
	bar_fill.bg_color = Color(0.9, 0.18, 0.12)
	bar_fill.set_corner_radius_all(3)
	_boss_bar.add_theme_stylebox_override(&"fill", bar_fill)
	vbox.add_child(_boss_bar)

	_boss_panel.add_child(vbox)
	_container.add_child(_boss_panel)

	# Connect to boss health
	var health: Node = boss.get_node_or_null("HealthComponent")
	if health:
		_boss_bar.max_value = health.max_health
		_boss_bar.value = health.current_health
		health.health_changed.connect(_on_boss_health_changed)
		health.died.connect(_hide_boss_bar)

	# Fade in animation
	_boss_panel.modulate.a = 0.0
	var tween: Tween = _boss_panel.create_tween()
	tween.tween_property(_boss_panel, "modulate:a", 1.0, 0.5)


func _on_boss_health_changed(current: float, max_val: float) -> void:
	if _boss_bar == null or not is_instance_valid(_boss_bar):
		return
	_boss_bar.max_value = max_val
	var tween: Tween = create_tween()
	tween.tween_property(_boss_bar, "value", current, 0.3).set_ease(Tween.EASE_OUT)


func _hide_boss_bar() -> void:
	if _boss_panel == null or not is_instance_valid(_boss_panel):
		return
	var panel: PanelContainer = _boss_panel
	_boss_panel = null
	_boss_bar = null
	_boss_name_label = null
	_boss_ref = null
	var tween: Tween = panel.create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 0.8)
	tween.tween_callback(panel.queue_free)


func _process_low_health(delta: float) -> void:
	if _low_health_vignette == null or not is_instance_valid(_low_health_vignette):
		return
	_low_health_time += delta
	# Pulse between 0.1 and 0.25 alpha at 1.5Hz
	var pulse: float = 0.175 + sin(_low_health_time * 3.0) * 0.075
	_low_health_vignette.color.a = pulse


func _apply_sci_fi_theme() -> void:
	# Style the prompt display panel — currently a bare PanelContainer in HUD.tscn
	var prompt_display: PanelContainer = _container.get_node_or_null("PromptDisplay") as PanelContainer
	if prompt_display:
		var prompt_style: StyleBoxFlat = StyleBoxFlat.new()
		prompt_style.bg_color = Color(0.06, 0.08, 0.14, 0.92)
		prompt_style.border_color = Color(0.18, 0.45, 0.55, 0.85)
		prompt_style.set_border_width_all(2)
		prompt_style.border_width_left = 4
		prompt_style.set_corner_radius_all(5)
		prompt_style.set_content_margin_all(6)
		prompt_display.add_theme_stylebox_override(&"panel", prompt_style)
		_prompt_indicator_root = prompt_display
	# Style the prompt key label
	var prompt_key: Label = _container.get_node_or_null("PromptDisplay/HBox/VBox/PromptKey") as Label
	if prompt_key:
		prompt_key.add_theme_color_override(&"font_color", Color(0.65, 0.85, 0.9))
		prompt_key.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.7))
		prompt_key.add_theme_constant_override(&"outline_size", 2)
		prompt_key.add_theme_font_size_override(&"font_size", 14)
	if _prompt_quantity:
		_prompt_quantity.add_theme_color_override(&"font_color", Color(0.95, 0.85, 0.3))
		_prompt_quantity.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.7))
		_prompt_quantity.add_theme_constant_override(&"outline_size", 2)
		_prompt_quantity.add_theme_font_size_override(&"font_size", 16)
	# Health bar — red/green sci-fi
	var health_bg: StyleBoxFlat = StyleBoxFlat.new()
	health_bg.bg_color = Color(0.15, 0.08, 0.08, 0.9)
	health_bg.border_color = Color(0.5, 0.2, 0.2, 0.8)
	health_bg.set_border_width_all(1)
	health_bg.set_corner_radius_all(3)
	health_bar.add_theme_stylebox_override(&"background", health_bg)
	var health_fill: StyleBoxFlat = StyleBoxFlat.new()
	health_fill.bg_color = Color(0.2, 0.75, 0.3)
	health_fill.set_corner_radius_all(3)
	health_bar.add_theme_stylebox_override(&"fill", health_fill)

	# Compute bar — blue sci-fi
	var compute_bg: StyleBoxFlat = StyleBoxFlat.new()
	compute_bg.bg_color = Color(0.08, 0.08, 0.18, 0.9)
	compute_bg.border_color = Color(0.2, 0.2, 0.5, 0.8)
	compute_bg.set_border_width_all(1)
	compute_bg.set_corner_radius_all(3)
	compute_bar.add_theme_stylebox_override(&"background", compute_bg)
	var compute_fill: StyleBoxFlat = StyleBoxFlat.new()
	compute_fill.bg_color = Color(0.2, 0.4, 0.85)
	compute_fill.set_corner_radius_all(3)
	compute_bar.add_theme_stylebox_override(&"fill", compute_fill)

	# XP bar — gold
	var xp_bg: StyleBoxFlat = StyleBoxFlat.new()
	xp_bg.bg_color = Color(0.12, 0.10, 0.05, 0.9)
	xp_bg.border_color = Color(0.4, 0.35, 0.15, 0.8)
	xp_bg.set_border_width_all(1)
	xp_bg.set_corner_radius_all(2)
	_xp_bar.add_theme_stylebox_override(&"background", xp_bg)
	var xp_fill: StyleBoxFlat = StyleBoxFlat.new()
	xp_fill.bg_color = Color(0.85, 0.7, 0.2)
	xp_fill.set_corner_radius_all(2)
	_xp_bar.add_theme_stylebox_override(&"fill", xp_fill)

	# Labels — light color for dark backgrounds
	health_label.add_theme_color_override(&"font_color", Color(0.9, 0.9, 0.9))
	compute_label.add_theme_color_override(&"font_color", Color(0.9, 0.9, 0.9))
	_level_label.add_theme_color_override(&"font_color", Color(0.9, 0.85, 0.6))


func _connect_player() -> void:
	# Gather ability slot UIs
	_ability_slot_uis.clear()
	for child: Node in _ability_slots_container.get_children():
		if child is AbilitySlotUI:
			_ability_slot_uis.append(child as AbilitySlotUI)
	# Initialize slots as empty
	for i: int in _ability_slot_uis.size():
		_ability_slot_uis[i].set_empty(i + 1)

	var nodes: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if nodes.is_empty():
		# Retry after a short delay — player may not be spawned yet
		await get_tree().create_timer(0.5).timeout
		nodes = get_tree().get_nodes_in_group(&"player")
		if nodes.is_empty():
			push_warning("HUD: no player found after retry")
			return
	var player: CharacterBody3D = nodes[0] as CharacterBody3D
	if player == null:
		return
	player.health_component.health_changed.connect(_on_health_changed)
	player.compute_component.compute_changed.connect(_on_compute_changed)
	_on_health_changed(player.health_component.current_health, player.health_component.max_health)
	_on_compute_changed(player.compute_component.current_compute, player.compute_component.max_compute)
	# Ability manager connections
	player.ability_manager.ability_used.connect(_on_ability_used)
	player.ability_manager.ability_ready.connect(_on_ability_ready)
	player.equipment_component.equipment_changed.connect(_on_equipment_changed.bind(player))
	_refresh_ability_icons(player)
	# Prompt hotbar connections
	player.inventory_component.prompt_used.connect(_on_prompt_used)
	player.inventory_component.inventory_changed.connect(_on_inventory_changed.bind(player))
	_update_prompt_display(player)
	# XP/Level connections
	player.level_component.xp_changed.connect(_on_xp_changed)
	player.level_component.leveled_up.connect(_on_leveled_up_hud)
	_update_xp_display(player.level_component)
	# Phase 3 #23 — wire the debuff strip to the player's
	# StatusEffectManager. The manager fires effect_applied /
	# effect_removed signals (added in T22 land), and the strip
	# rebuilds its chip dict on each event.
	_player_status_manager = player.get_node_or_null("StatusEffectManager")
	if _player_status_manager:
		if not _player_status_manager.effect_applied.is_connected(_on_status_effect_applied):
			_player_status_manager.effect_applied.connect(_on_status_effect_applied)
		if not _player_status_manager.effect_removed.is_connected(_on_status_effect_removed):
			_player_status_manager.effect_removed.connect(_on_status_effect_removed)
		# Repaint any pre-existing effects (e.g. mid-room HUD reload)
		_rebuild_debuff_strip()


func _create_controls_hint() -> void:
	var hint: PanelContainer = PanelContainer.new()
	hint.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	hint.offset_left = 16.0
	hint.offset_top = -120.0
	hint.offset_right = 200.0
	hint.offset_bottom = -16.0
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.05, 0.10, 0.7)
	style.border_color = Color(0.12, 0.3, 0.4, 0.4)
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(8)
	hint.add_theme_stylebox_override(&"panel", style)
	var label: RichTextLabel = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = "[color=#60C8C0]WASD[/color] Move  [color=#60C8C0]Space[/color] Dash\n[color=#60C8C0]LMB[/color] Attack  [color=#60C8C0]RMB[/color] Charge\n[color=#60C8C0]E[/color] Interact  [color=#60C8C0]Tab[/color] Inventory\n[color=#60C8C0]Q[/color] Prompt  [color=#60C8C0]Esc[/color] Pause"
	label.add_theme_font_size_override(&"normal_font_size", 12)
	hint.add_child(label)
	_container.add_child(hint)
	_controls_hint = hint
	# Fade out after 20 seconds
	var tween: Tween = hint.create_tween()
	tween.tween_interval(20.0)
	tween.tween_property(hint, "modulate:a", 0.0, 2.0)
	tween.tween_callback(func() -> void:
		if is_instance_valid(hint):
			hint.queue_free()
		if _controls_hint == hint:
			_controls_hint = null
	)


func set_combat_visible(combat: bool) -> void:
	## Hide combat-only HUD elements when in peaceful zones (e.g. town).
	## Top-left status (HP/CP/XP/Level) stays visible.
	if _ability_slots_container:
		_ability_slots_container.visible = combat
	if _prompt_indicator_root:
		_prompt_indicator_root.visible = combat
	if _room_panel:
		_room_panel.visible = combat and not _room_label.text.is_empty() if _room_label else combat
	if _controls_hint and is_instance_valid(_controls_hint):
		_controls_hint.visible = combat
	if _streak_label and is_instance_valid(_streak_label):
		_streak_label.visible = combat
	if _low_health_vignette and is_instance_valid(_low_health_vignette):
		_low_health_vignette.visible = combat


func _create_room_indicator() -> void:
	# Styled chip panel in the top-right corner
	_room_panel = PanelContainer.new()
	_room_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_room_panel.offset_left = -300.0  # wider so longer floor names fit
	_room_panel.offset_top = 14.0
	_room_panel.offset_right = -14.0
	_room_panel.offset_bottom = 46.0
	var room_style: StyleBoxFlat = StyleBoxFlat.new()
	room_style.bg_color = Color(0.05, 0.07, 0.12, 0.85)
	room_style.border_color = Color(0.18, 0.45, 0.55, 0.7)
	room_style.set_border_width_all(1)
	room_style.border_width_left = 4
	room_style.set_corner_radius_all(4)
	room_style.set_content_margin_all(6)
	_room_panel.add_theme_stylebox_override(&"panel", room_style)
	_room_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_room_panel.visible = false  # hidden until set
	_room_label = Label.new()
	_room_label.text = ""
	_room_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_room_label.add_theme_color_override(&"font_color", Color(0.65, 0.85, 0.9))
	_room_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.7))
	_room_label.add_theme_constant_override(&"outline_size", 2)
	_room_label.add_theme_font_size_override(&"font_size", 14)
	_room_panel.add_child(_room_label)
	_container.add_child(_room_panel)
	# Connect to floor manager signals
	EventBus.floor_completed.connect(_on_floor_completed_hud)
	EventBus.scene_changed.connect(_on_scene_changed_hud)


func _create_iteration_chip() -> void:
	## Persistent compaction-iteration indicator. Sits just below the room
	## indicator chip in the top-right corner so the player can read both at
	## a glance. Hidden when IterationManager isn't present (defensive — the
	## autoload was missing for most of the project's life and the rest of
	## the codebase still feature-detects).
	_iteration_panel = PanelContainer.new()
	_iteration_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_iteration_panel.offset_left = -120.0
	_iteration_panel.offset_top = 50.0  # under the room indicator (ends at 46)
	_iteration_panel.offset_right = -14.0
	_iteration_panel.offset_bottom = 78.0
	var iter_style: StyleBoxFlat = StyleBoxFlat.new()
	iter_style.bg_color = Color(0.06, 0.05, 0.12, 0.88)
	iter_style.border_color = Color(0.55, 0.4, 0.85, 0.85)  # violet to match the COMPACTED banner
	iter_style.set_border_width_all(1)
	iter_style.border_width_left = 4
	iter_style.set_corner_radius_all(4)
	iter_style.set_content_margin_all(6)
	_iteration_panel.add_theme_stylebox_override(&"panel", iter_style)
	_iteration_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_iteration_label = Label.new()
	_iteration_label.text = ""
	_iteration_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_iteration_label.add_theme_color_override(&"font_color", Color(0.78, 0.62, 1.0))
	_iteration_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.7))
	_iteration_label.add_theme_constant_override(&"outline_size", 2)
	_iteration_label.add_theme_font_size_override(&"font_size", 13)
	_iteration_panel.add_child(_iteration_label)
	_container.add_child(_iteration_panel)
	# Initial value + listen for advances. iteration_advanced fires from
	# IterationManager.advance_iteration so the chip retitles immediately
	# when the dungeon clear branch (T21) lands.
	_refresh_iteration_chip()
	if has_node("/root/IterationManager"):
		var im: Node = get_node("/root/IterationManager")
		if im.has_signal(&"iteration_advanced") and not im.iteration_advanced.is_connected(_on_iteration_advanced):
			im.iteration_advanced.connect(_on_iteration_advanced)


func _refresh_iteration_chip_no_arg() -> void:
	## Adapter for zero-arg signals (game_loaded). Godot 4 signal bindings
	## require arity match, so we can't connect game_loaded directly to
	## _refresh_iteration_chip's String-arg signature.
	_refresh_iteration_chip()


func _refresh_iteration_chip(_path: String = "") -> void:
	if _iteration_panel == null or _iteration_label == null:
		return
	if not has_node("/root/IterationManager"):
		_iteration_panel.visible = false
		return
	var im: Node = get_node("/root/IterationManager")
	var iter: int = 1
	if im.has_method(&"get_current_iteration"):
		iter = int(im.get_current_iteration())
	elif "current_iteration" in im:
		iter = int(im.current_iteration)
	var final_iter: int = 9
	if "FINAL_ITERATION" in im:
		final_iter = int(im.FINAL_ITERATION)
	_iteration_label.text = "ITER %d/%d" % [iter, final_iter]
	_iteration_panel.visible = true


func _on_iteration_advanced(_new_iteration: int) -> void:
	_refresh_iteration_chip()


func update_room_indicator(room_index: int, total_rooms: int, floor_name: String) -> void:
	if _room_label:
		_room_label.text = "%s — Room %d/%d" % [floor_name, room_index + 1, total_rooms]
	if _room_panel:
		_room_panel.visible = true


func _on_floor_completed_hud(_floor_num: int) -> void:
	if _room_label:
		_room_label.text = "Floor Complete!"
	if _room_panel:
		_room_panel.visible = true


func _on_scene_changed_hud(_path: String) -> void:
	if _room_label:
		_room_label.text = ""
	if _room_panel:
		_room_panel.visible = false


var _last_health: float = -1.0


func _on_health_changed(current: float, max_val: float) -> void:
	health_bar.max_value = max_val
	if _health_tween and _health_tween.is_running():
		_health_tween.kill()
	_health_tween = create_tween()
	_health_tween.tween_property(health_bar, "value", current, TWEEN_DURATION).set_ease(Tween.EASE_OUT)
	health_label.text = "%d / %d" % [int(current), int(max_val)]
	# Flash health bar red on damage (not on heal or initial set)
	if _last_health > 0 and current < _last_health:
		_flash_health_bar_damage()
	_last_health = current
	# Low-health vignette
	var pct: float = current / max_val if max_val > 0 else 1.0
	if pct < 0.25 and current > 0:
		_ensure_low_health_vignette()
	elif pct >= 0.35:
		_remove_low_health_vignette()


func _flash_health_bar_damage() -> void:
	if health_bar == null:
		return
	var flash_fill: StyleBoxFlat = StyleBoxFlat.new()
	flash_fill.bg_color = Color(1.0, 0.95, 0.9)
	flash_fill.set_corner_radius_all(3)
	health_bar.add_theme_stylebox_override(&"fill", flash_fill)
	var tween: Tween = create_tween()
	tween.tween_interval(0.1)
	tween.tween_callback(func() -> void:
		var normal_fill: StyleBoxFlat = StyleBoxFlat.new()
		normal_fill.bg_color = Color(0.2, 0.75, 0.3)
		normal_fill.set_corner_radius_all(3)
		health_bar.add_theme_stylebox_override(&"fill", normal_fill)
	)


func _ensure_low_health_vignette() -> void:
	if _low_health_vignette and is_instance_valid(_low_health_vignette):
		return
	_low_health_vignette = ColorRect.new()
	_low_health_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	_low_health_vignette.color = Color(0.85, 0.08, 0.05, 0.0)
	_low_health_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_container.add_child(_low_health_vignette)


func _remove_low_health_vignette() -> void:
	if _low_health_vignette == null or not is_instance_valid(_low_health_vignette):
		_low_health_vignette = null
		return
	var vignette: ColorRect = _low_health_vignette
	_low_health_vignette = null
	var tween: Tween = vignette.create_tween()
	tween.tween_property(vignette, "color:a", 0.0, 0.3)
	tween.tween_callback(vignette.queue_free)


func _on_compute_changed(current: float, max_val: float) -> void:
	compute_bar.max_value = max_val
	if _compute_tween and _compute_tween.is_running():
		_compute_tween.kill()
	_compute_tween = create_tween()
	_compute_tween.tween_property(compute_bar, "value", current, TWEEN_DURATION).set_ease(Tween.EASE_OUT)
	compute_label.text = "%d / %d" % [int(current), int(max_val)]


func _on_dialogue_started(_npc_id: StringName) -> void:
	_container.visible = false


func _on_dialogue_ended() -> void:
	_container.visible = true


func _on_ability_used(slot_index: int, module: Resource) -> void:
	if slot_index >= 0 and slot_index < _ability_slot_uis.size():
		_ability_slot_uis[slot_index].start_cooldown(module.cooldown)


func _on_ability_ready(slot_index: int) -> void:
	if slot_index >= 0 and slot_index < _ability_slot_uis.size():
		_ability_slot_uis[slot_index].set_ready()


func _on_equipment_changed(player: CharacterBody3D) -> void:
	_refresh_ability_icons(player)


func _refresh_ability_icons(player: CharacterBody3D) -> void:
	for i: int in _ability_slot_uis.size():
		var module: Resource = player.equipment_component.module_slots[i] if i < player.equipment_component.module_slots.size() else null
		if module:
			_ability_slot_uis[i].set_module(module, i + 1)
		else:
			_ability_slot_uis[i].set_empty(i + 1)


func _on_prompt_used(_prompt_type: String, _remaining: int) -> void:
	# Flash icon
	var tween: Tween = create_tween()
	tween.tween_property(_prompt_icon, "color", Color.WHITE, 0.1)
	tween.tween_callback(_refresh_prompt_from_tree)


func _on_inventory_changed(player: CharacterBody3D) -> void:
	_update_prompt_display(player)


func _update_prompt_display(player: CharacterBody3D) -> void:
	var active: Dictionary = player.inventory_component.get_active_prompt()
	if active.is_empty():
		_prompt_icon.color = Color(0.3, 0.3, 0.3, 0.5)
		_prompt_quantity.text = "x0"
		_prompt_icon.scale = Vector2.ONE
		return
	var prompt: Resource = active["item"] as Resource
	var qty: int = int(active["quantity"])
	match prompt.prompt_type:
		"health":
			_prompt_icon.color = Color(0.9, 0.2, 0.2)
		"compute":
			_prompt_icon.color = Color(0.2, 0.4, 0.9)
		"buff":
			_prompt_icon.color = Color(0.9, 0.8, 0.2)
		_:
			_prompt_icon.color = Color(0.5, 0.5, 0.5)
	_prompt_quantity.text = "x%d" % qty
	# Brief pop animation when prompt loaded
	_prompt_icon.scale = Vector2(0.6, 0.6)
	var tween: Tween = create_tween()
	tween.tween_property(_prompt_icon, "scale", Vector2(1.15, 1.15), 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(_prompt_icon, "scale", Vector2(1.0, 1.0), 0.08)


func _refresh_prompt_from_tree() -> void:
	var nodes: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if nodes.size() > 0:
		_update_prompt_display(nodes[0] as CharacterBody3D)


func _on_xp_changed(current_xp: int, xp_to_next: int) -> void:
	_xp_bar.max_value = xp_to_next
	var tween: Tween = create_tween()
	tween.tween_property(_xp_bar, "value", float(current_xp), TWEEN_DURATION).set_ease(Tween.EASE_OUT)
	# Brief XP bar glow on gain
	_flash_xp_bar()


func _on_leveled_up_hud(new_level: int) -> void:
	_level_label.text = "Lv. %d" % new_level
	_xp_bar.value = 0
	# Level-up HUD notification
	_show_level_up_banner(new_level)


func _flash_xp_bar() -> void:
	if _xp_bar == null:
		return
	var flash_fill: StyleBoxFlat = StyleBoxFlat.new()
	flash_fill.bg_color = Color(0.9, 0.8, 0.2)
	flash_fill.set_corner_radius_all(3)
	_xp_bar.add_theme_stylebox_override(&"fill", flash_fill)
	var tween: Tween = create_tween()
	tween.tween_interval(0.15)
	tween.tween_callback(func() -> void:
		var normal_fill: StyleBoxFlat = StyleBoxFlat.new()
		normal_fill.bg_color = Color(0.2, 0.6, 0.85)
		normal_fill.set_corner_radius_all(3)
		_xp_bar.add_theme_stylebox_override(&"fill", normal_fill)
	)


func _show_level_up_banner(level: int) -> void:
	# Holder for unified fade + scale-pop
	var holder: Control = Control.new()
	holder.set_anchors_preset(Control.PRESET_CENTER_TOP)
	holder.offset_left = -260
	holder.offset_right = 260
	holder.offset_top = 220  # below location label and tutorial banner
	holder.offset_bottom = 320
	holder.pivot_offset = Vector2(260, 50)
	holder.modulate.a = 0.0
	holder.scale = Vector2(0.7, 0.7)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Subtitle
	var sub: Label = Label.new()
	sub.text = "LEVEL UP"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.set_anchors_preset(Control.PRESET_TOP_WIDE)
	sub.offset_top = 0
	sub.offset_bottom = 22
	sub.add_theme_font_size_override(&"font_size", 16)
	sub.add_theme_color_override(&"font_color", Color(0.7, 0.85, 0.95))
	sub.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.85))
	sub.add_theme_constant_override(&"outline_size", 4)
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(sub)
	# Big "Lv N" text
	var banner: Label = Label.new()
	banner.text = "Lv %d" % level
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.set_anchors_preset(Control.PRESET_TOP_WIDE)
	banner.offset_top = 24
	banner.offset_bottom = 90
	banner.add_theme_font_size_override(&"font_size", 56)
	banner.add_theme_color_override(&"font_color", Color(1.0, 0.85, 0.2))
	banner.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.9))
	banner.add_theme_constant_override(&"outline_size", 8)
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(banner)
	_container.add_child(holder)
	# Sequential cinematic tween
	var tween: Tween = holder.create_tween()
	tween.tween_property(holder, "modulate:a", 1.0, 0.25).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(holder, "scale", Vector2(1.08, 1.08), 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(holder, "scale", Vector2(1.0, 1.0), 0.12)
	tween.tween_interval(1.4)
	tween.tween_property(holder, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	tween.tween_callback(holder.queue_free)


func _update_xp_display(lc: Node) -> void:
	_level_label.text = "Lv. %d" % lc.current_level
	_xp_bar.max_value = lc.xp_to_next_level
	_xp_bar.value = lc.current_xp


# --- Affinity tier feedback ---
# Detects when an NPC crosses an affinity tier boundary and shows a small
# banner. Without this, EventBus.affinity_changed had no listeners — the
# whole tier system was invisible to the player.
func _on_affinity_changed(npc_id: StringName, _new_value: int) -> void:
	var id_str: String = String(npc_id)
	var new_tier: String = GameManager.get_affinity_tier(id_str)
	var old_tier: String = _last_affinity_tier.get(id_str, "Stranger")
	_last_affinity_tier[id_str] = new_tier
	if new_tier != old_tier and _tier_rank(new_tier) > _tier_rank(old_tier):
		_show_affinity_tier_banner(id_str, new_tier)


func _tier_rank(tier_name: String) -> int:
	match tier_name:
		"Trusted": return 3
		"Ally": return 2
		"Acquaintance": return 1
		_: return 0


func _show_affinity_tier_banner(npc_id: String, tier_name: String) -> void:
	var holder: Control = Control.new()
	holder.set_anchors_preset(Control.PRESET_CENTER_TOP)
	holder.offset_left = -260
	holder.offset_right = 260
	holder.offset_top = 320  # below the level-up banner slot
	holder.offset_bottom = 400
	holder.pivot_offset = Vector2(260, 40)
	holder.modulate.a = 0.0
	holder.scale = Vector2(0.7, 0.7)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var sub: Label = Label.new()
	sub.text = "BOND DEEPENED"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.set_anchors_preset(Control.PRESET_TOP_WIDE)
	sub.offset_top = 0
	sub.offset_bottom = 22
	sub.add_theme_font_size_override(&"font_size", 14)
	sub.add_theme_color_override(&"font_color", Color(0.7, 0.95, 0.85))
	sub.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.85))
	sub.add_theme_constant_override(&"outline_size", 4)
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(sub)

	var banner: Label = Label.new()
	banner.text = "%s — %s" % [npc_id.capitalize(), tier_name.to_upper()]
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.set_anchors_preset(Control.PRESET_TOP_WIDE)
	banner.offset_top = 24
	banner.offset_bottom = 70
	banner.add_theme_font_size_override(&"font_size", 28)
	banner.add_theme_color_override(&"font_color", Color(0.4, 1.0, 0.7))
	banner.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.9))
	banner.add_theme_constant_override(&"outline_size", 6)
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(banner)

	_container.add_child(holder)
	var tween: Tween = holder.create_tween()
	tween.tween_property(holder, "modulate:a", 1.0, 0.25).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(holder, "scale", Vector2(1.05, 1.05), 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(holder, "scale", Vector2(1.0, 1.0), 0.12)
	tween.tween_interval(1.6)
	tween.tween_property(holder, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	tween.tween_callback(holder.queue_free)


func _on_enemy_killed_streak(_type: StringName, _pos: Vector3, _loot: Resource) -> void:
	_kill_streak += 1
	_kill_streak_timer = STREAK_TIMEOUT
	if _kill_streak >= 2:
		_update_streak_display()
	# Screen shake intensity scales with streak
	if _kill_streak >= 3:
		var cam_nodes: Array[Node] = get_tree().get_nodes_in_group(&"player")
		if not cam_nodes.is_empty():
			var camera: Camera3D = cam_nodes[0].get_viewport().get_camera_3d()
			if camera and camera.has_method(&"shake"):
				camera.shake(0.05 + _kill_streak * 0.01, 6.0)


func _process_streak(delta: float) -> void:
	if _kill_streak_timer > 0.0:
		_kill_streak_timer -= delta
		if _kill_streak_timer <= 0.0:
			_kill_streak = 0
			if _streak_label and is_instance_valid(_streak_label):
				_streak_label.queue_free()
				_streak_label = null


func _update_streak_display() -> void:
	if _streak_label and is_instance_valid(_streak_label):
		_streak_label.queue_free()
	_streak_label = Label.new()
	var streak_text: String = "%d KILL STREAK" % _kill_streak
	if _kill_streak >= 5:
		streak_text = "RAMPAGE! x%d" % _kill_streak
	elif _kill_streak >= 3:
		streak_text = "MULTI-KILL x%d" % _kill_streak
	_streak_label.text = streak_text
	_streak_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Anchor on the right side, mid-screen — out of the way of top-center stack
	_streak_label.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	_streak_label.offset_left = -340
	_streak_label.offset_right = -16
	_streak_label.offset_top = -160
	_streak_label.offset_bottom = -120
	_streak_label.pivot_offset = Vector2(162, 20)
	var streak_color: Color = Color(1.0, 0.55, 0.1) if _kill_streak < 5 else Color(1.0, 0.22, 0.1)
	var font_size: int = 22 + mini(_kill_streak, 10) * 2
	_streak_label.add_theme_font_size_override(&"font_size", font_size)
	_streak_label.add_theme_color_override(&"font_color", streak_color)
	_streak_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.9))
	_streak_label.add_theme_constant_override(&"outline_size", 5)
	_streak_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_container.add_child(_streak_label)
	# Pop animation with proper pivot — sequential tween
	_streak_label.scale = Vector2(0.5, 0.5)
	var tween: Tween = _streak_label.create_tween()
	tween.tween_property(_streak_label, "scale", Vector2(1.18, 1.18), 0.09).set_ease(Tween.EASE_OUT)
	tween.tween_property(_streak_label, "scale", Vector2(1.0, 1.0), 0.08).set_ease(Tween.EASE_IN_OUT)


# === Phase 3 #23 — debuff icon strip ===

const _DEBUFF_TINT_TABLE: Dictionary = {
	# Effect-name → fill tint. Mirrors the per-archetype palette so the
	# player learns "blue chip = slow, green chip = DoT, violet chip =
	# damage amp" without needing actual icon art.
	"Throttled": Color(0.35, 0.65, 1.00),    # Glitch Bug snare — cyan
	"Corrupted": Color(0.30, 0.85, 0.40),    # Memory Leak DoT — green
	"Fragmented": Color(0.85, 0.40, 1.00),   # Rogue Process amp — violet
}


func _create_debuff_strip() -> void:
	## Anchored top-left under the existing health/compute bars. Container
	## starts hidden — _on_status_effect_applied makes it visible when
	## the first chip lands and _on_status_effect_removed hides it again
	## when the last one drops.
	if _debuff_strip != null and is_instance_valid(_debuff_strip):
		return
	_debuff_strip = HBoxContainer.new()
	_debuff_strip.name = "DebuffStrip"
	_debuff_strip.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_debuff_strip.offset_left = 16.0
	_debuff_strip.offset_top = 110.0  # under the HP/compute/XP stack
	_debuff_strip.add_theme_constant_override(&"separation", 6)
	_debuff_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_debuff_strip.visible = false
	_container.add_child(_debuff_strip)


func _on_status_effect_applied(effect_name: String) -> void:
	## A new (or refreshed) effect landed. If we already have a chip
	## for this name, the StatusEffectManager has just refreshed the
	## remaining_duration — _process_debuff_timers will pick up the
	## new value next frame, no rebuild needed.
	if _debuff_chips.has(effect_name):
		return
	_add_debuff_chip(effect_name)


func _on_status_effect_removed(effect_name: String) -> void:
	if not _debuff_chips.has(effect_name):
		return
	var entry: Dictionary = _debuff_chips[effect_name] as Dictionary
	var panel: PanelContainer = entry.get("panel") as PanelContainer
	if panel and is_instance_valid(panel):
		panel.queue_free()
	_debuff_chips.erase(effect_name)
	if _debuff_chips.is_empty() and _debuff_strip:
		_debuff_strip.visible = false


func _add_debuff_chip(effect_name: String) -> void:
	## Build a single PanelContainer chip and stash it in _debuff_chips
	## so _process_debuff_timers can refresh the remaining-time label
	## without rebuilding the row on every tick.
	if _debuff_strip == null:
		return
	var tint: Color = _DEBUFF_TINT_TABLE.get(effect_name, Color(0.85, 0.45, 0.30)) as Color
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(64, 38)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.07, 0.12, 0.92)
	style.border_color = tint
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(4)
	panel.add_theme_stylebox_override(&"panel", style)
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 1)
	var name_label: Label = Label.new()
	name_label.text = effect_name.to_upper()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override(&"font_size", 11)
	name_label.add_theme_color_override(&"font_color", tint)
	name_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.85))
	name_label.add_theme_constant_override(&"outline_size", 2)
	vbox.add_child(name_label)
	var time_label: Label = Label.new()
	time_label.text = "0.0s"
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_label.add_theme_font_size_override(&"font_size", 13)
	time_label.add_theme_color_override(&"font_color", Color(0.95, 0.95, 0.95))
	time_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.85))
	time_label.add_theme_constant_override(&"outline_size", 2)
	vbox.add_child(time_label)
	panel.add_child(vbox)
	_debuff_strip.add_child(panel)
	_debuff_chips[effect_name] = {"panel": panel, "label": time_label}
	_debuff_strip.visible = true


func _process_debuff_timers() -> void:
	## Refresh the per-chip remaining-time label by reading the
	## StatusEffectManager's active_effects array. Cheap O(N*M) where
	## N <= 3 (V1 roster) and M <= 3 (typical concurrent effects).
	if _player_status_manager == null or not is_instance_valid(_player_status_manager):
		return
	if _debuff_chips.is_empty():
		return
	var active: Array = _player_status_manager.active_effects as Array
	for entry: Variant in active:
		var d: Dictionary = entry as Dictionary
		var effect: Resource = d.get("effect") as Resource
		if effect == null:
			continue
		var name: String = effect.effect_name
		if not _debuff_chips.has(name):
			continue
		var chip: Dictionary = _debuff_chips[name] as Dictionary
		var label: Label = chip.get("label") as Label
		if label and is_instance_valid(label):
			var rem: float = float(d.get("remaining_duration", 0.0))
			label.text = "%.1fs" % maxf(0.0, rem)


func _rebuild_debuff_strip() -> void:
	## Tear down any existing chips and rebuild from the manager's
	## active_effects array. Used on connect when the manager already
	## has effects that landed before the HUD finished wiring up.
	for name: String in _debuff_chips.keys():
		var entry: Dictionary = _debuff_chips[name] as Dictionary
		var panel: PanelContainer = entry.get("panel") as PanelContainer
		if panel and is_instance_valid(panel):
			panel.queue_free()
	_debuff_chips.clear()
	if _player_status_manager == null:
		return
	var active: Array = _player_status_manager.active_effects as Array
	for d: Variant in active:
		var dd: Dictionary = d as Dictionary
		var effect: Resource = dd.get("effect") as Resource
		if effect != null:
			_add_debuff_chip(effect.effect_name)


## Phase 4 #35 — active quest HUD widget. Shows the first active quest's
## name and current objective in a small panel at the top-right corner.
func _create_quest_widget() -> void:
	_quest_panel = PanelContainer.new()
	_quest_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_quest_panel.offset_left = -280
	_quest_panel.offset_top = 16
	_quest_panel.offset_right = -16
	_quest_panel.offset_bottom = 80
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.05, 0.1, 0.75)
	style.border_color = Color(0.15, 0.45, 0.5, 0.5)
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(8)
	_quest_panel.add_theme_stylebox_override(&"panel", style)
	_quest_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_quest_panel.add_child(vbox)

	_quest_title_label = Label.new()
	_quest_title_label.add_theme_font_size_override(&"font_size", 14)
	_quest_title_label.add_theme_color_override(&"font_color", Color(0.3, 0.9, 0.8))
	_quest_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_quest_title_label)

	_quest_obj_label = Label.new()
	_quest_obj_label.add_theme_font_size_override(&"font_size", 12)
	_quest_obj_label.add_theme_color_override(&"font_color", Color(0.7, 0.8, 0.75))
	_quest_obj_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_quest_obj_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(_quest_obj_label)

	_container.add_child(_quest_panel)
	_refresh_quest_widget()


func _on_quest_updated(_quest_id: StringName, _status: StringName) -> void:
	_refresh_quest_widget()


func _refresh_quest_widget() -> void:
	if _quest_panel == null:
		return
	if QuestManager.active_quests.is_empty():
		_quest_panel.visible = false
		return
	_quest_panel.visible = true
	var quest: Resource = QuestManager.active_quests[0]
	_quest_title_label.text = quest.quest_name
	# Find the first incomplete objective
	var obj_text: String = ""
	for obj: Variant in quest.objectives:
		if obj.current_count < obj.target_count:
			if obj.target_count > 1:
				obj_text = "%s (%d/%d)" % [obj.objective_text, obj.current_count, obj.target_count]
			else:
				obj_text = obj.objective_text
			break
	if obj_text == "":
		obj_text = "Complete!"
	_quest_obj_label.text = obj_text


## R2 F3 — gold display below quest widget, top-right corner.
func _create_gold_display() -> void:
	_gold_label = Label.new()
	_gold_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_gold_label.offset_left = -140
	_gold_label.offset_top = 90
	_gold_label.offset_right = -16
	_gold_label.offset_bottom = 110
	_gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_gold_label.add_theme_font_size_override(&"font_size", 16)
	_gold_label.add_theme_color_override(&"font_color", Color(1.0, 0.85, 0.2))
	_gold_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.7))
	_gold_label.add_theme_constant_override(&"outline_size", 3)
	_gold_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_gold_label.text = "%d Gold" % GameManager.player_gold
	_container.add_child(_gold_label)


func _on_enemy_defeated_gold(_type: StringName, _pos: Vector3, _loot: Resource) -> void:
	if _gold_label:
		_gold_label.text = "%d Gold" % GameManager.player_gold
