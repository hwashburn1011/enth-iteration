class_name RespecNPC
extends Node3D

## "Reflection" NPC in the town Workshop district. Lets the player respec
## their class and skill tree allocation. Unlocked at iteration 3.

signal respec_completed(new_class_id: StringName)

@export var npc_name: String = "Reflection"
@export var unlock_iteration: int = 3
@export var compute_crystal_cost: int = 50

var _player_in_range: bool = false


func _ready() -> void:
	add_to_group(&"interactable")
	add_to_group(&"npc")


func interact(player: Node) -> void:
	if not _is_unlocked():
		_show_locked_dialogue()
		return
	if not _player_can_afford(player):
		_show_too_expensive_dialogue()
		return
	_open_respec_ui(player)


func _is_unlocked() -> bool:
	if Engine.has_singleton("IterationManager") or has_node("/root/IterationManager"):
		var im: Node = get_node("/root/IterationManager")
		if im.has_method("get_current_iteration"):
			return im.get_current_iteration() >= unlock_iteration
	return false


func _player_can_afford(player: Node) -> bool:
	var inv: Node = player.get_node_or_null("InventoryComponent")
	if inv == null or not inv.has_method("count_item_by_id"):
		return false
	return inv.count_item_by_id(&"compute_crystal") >= compute_crystal_cost


func _show_locked_dialogue() -> void:
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("dialogue_requested"):
			bus.dialogue_requested.emit(npc_name, "I can show you another way... but not yet. Come back after the third iteration.")


func _show_too_expensive_dialogue() -> void:
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("dialogue_requested"):
			bus.dialogue_requested.emit(npc_name, "Reflection costs %d compute crystals. You don't have enough yet." % compute_crystal_cost)


func _open_respec_ui(player: Node) -> void:
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("respec_ui_requested"):
			bus.respec_ui_requested.emit(self, player, compute_crystal_cost)


func confirm_respec(player: Node, new_class_id: StringName) -> bool:
	## Called by the respec UI after player confirms.
	var inv: Node = player.get_node_or_null("InventoryComponent")
	if inv == null or not inv.has_method("remove_item_by_id"):
		return false
	if not inv.remove_item_by_id(&"compute_crystal", compute_crystal_cost):
		return false

	# Apply the class change via the registry
	if not ClassRegistry.set_active_class(new_class_id):
		# Refund on failure
		inv.add_item_by_id(&"compute_crystal", compute_crystal_cost)
		return false

	# Reset skill tree allocation (Epic 32)
	var st: Node = player.get_node_or_null("SkillTreeComponent")
	if st != null and st.has_method("reset_allocation"):
		st.reset_allocation()

	respec_completed.emit(new_class_id)
	return true
