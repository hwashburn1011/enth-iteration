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

var _health_tween: Tween = null
var _compute_tween: Tween = null
var _ability_slot_uis: Array[AbilitySlotUI] = []


func _ready() -> void:
	layer = 10
	# Connect to player signals after a frame (player may not exist yet)
	_connect_player.call_deferred()
	EventBus.dialogue_started.connect(_on_dialogue_started)
	EventBus.dialogue_ended.connect(_on_dialogue_ended)


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
		return
	var player: Player = nodes[0] as Player
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


func _on_ability_used(slot_index: int, module: ModuleItem) -> void:
	if slot_index >= 0 and slot_index < _ability_slot_uis.size():
		_ability_slot_uis[slot_index].start_cooldown(module.cooldown)


func _on_ability_ready(slot_index: int) -> void:
	if slot_index >= 0 and slot_index < _ability_slot_uis.size():
		_ability_slot_uis[slot_index].set_ready()


func _on_equipment_changed(player: Player) -> void:
	_refresh_ability_icons(player)


func _refresh_ability_icons(player: Player) -> void:
	for i: int in _ability_slot_uis.size():
		var module: ModuleItem = player.equipment_component.module_slots[i] if i < player.equipment_component.module_slots.size() else null
		if module:
			_ability_slot_uis[i].set_module(module, i + 1)
		else:
			_ability_slot_uis[i].set_empty(i + 1)


func _on_prompt_used(_prompt_type: String, _remaining: int) -> void:
	# Flash icon
	var tween: Tween = create_tween()
	tween.tween_property(_prompt_icon, "color", Color.WHITE, 0.1)
	tween.tween_callback(_refresh_prompt_from_tree)


func _on_inventory_changed(player: Player) -> void:
	_update_prompt_display(player)


func _update_prompt_display(player: Player) -> void:
	var active: Dictionary = player.inventory_component.get_active_prompt()
	if active.is_empty():
		_prompt_icon.color = Color(0.3, 0.3, 0.3, 0.5)
		_prompt_quantity.text = "x0"
		return
	var prompt: PromptItem = active["item"] as PromptItem
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
		_update_prompt_display(nodes[0] as Player)
