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
@onready var _prompt_key: Label = %PromptKey
@onready var _xp_bar: ProgressBar = %XPBar
@onready var _level_label: Label = %LevelLabel

var _health_tween: Tween = null
var _compute_tween: Tween = null
var _ability_slot_uis: Array[AbilitySlotUI] = []
var _room_label: Label = null


func _ready() -> void:
	layer = 10
	_apply_sci_fi_theme()
	# Connect to player signals after a frame (player may not exist yet)
	_connect_player.call_deferred()
	EventBus.dialogue_started.connect(_on_dialogue_started)
	EventBus.dialogue_ended.connect(_on_dialogue_ended)
	_create_room_indicator()


func _apply_sci_fi_theme() -> void:
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


func _create_room_indicator() -> void:
	_room_label = Label.new()
	_room_label.text = ""
	_room_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_room_label.offset_left = -180.0
	_room_label.offset_top = 16.0
	_room_label.offset_right = -16.0
	_room_label.offset_bottom = 40.0
	_room_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_room_label.add_theme_color_override(&"font_color", Color(0.6, 0.7, 0.8))
	_room_label.add_theme_font_size_override(&"font_size", 14)
	_container.add_child(_room_label)
	# Connect to floor manager signals
	EventBus.floor_completed.connect(_on_floor_completed_hud)
	EventBus.scene_changed.connect(_on_scene_changed_hud)


func update_room_indicator(room_index: int, total_rooms: int, floor_name: String) -> void:
	if _room_label:
		_room_label.text = "%s — Room %d/%d" % [floor_name, room_index + 1, total_rooms]


func _on_floor_completed_hud(_floor_num: int) -> void:
	if _room_label:
		_room_label.text = "Floor Complete!"


func _on_scene_changed_hud(_path: String) -> void:
	if _room_label:
		_room_label.text = ""


func _on_health_changed(current: float, max_val: float) -> void:
	health_bar.max_value = max_val
	if _health_tween and _health_tween.is_running():
		_health_tween.kill()
	_health_tween = create_tween()
	_health_tween.tween_property(health_bar, "value", current, TWEEN_DURATION).set_ease(Tween.EASE_OUT)
	health_label.text = "%d / %d" % [int(current), int(max_val)]


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


func _refresh_prompt_from_tree() -> void:
	var nodes: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if nodes.size() > 0:
		_update_prompt_display(nodes[0] as CharacterBody3D)


func _on_xp_changed(current_xp: int, xp_to_next: int) -> void:
	_xp_bar.max_value = xp_to_next
	var tween: Tween = create_tween()
	tween.tween_property(_xp_bar, "value", float(current_xp), TWEEN_DURATION).set_ease(Tween.EASE_OUT)


func _on_leveled_up_hud(new_level: int) -> void:
	_level_label.text = "Lv. %d" % new_level
	_xp_bar.value = 0


func _update_xp_display(lc: Node) -> void:
	_level_label.text = "Lv. %d" % lc.current_level
	_xp_bar.max_value = lc.xp_to_next_level
	_xp_bar.value = lc.current_xp
