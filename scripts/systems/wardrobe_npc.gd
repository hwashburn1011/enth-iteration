class_name WardrobeNPC
extends Node3D

## Town NPC that lets the player preview and equip outfits without committing
## stat changes. Opens a wardrobe UI on interact.
##
## Stocks the player's owned outfits + a few preview-only display sets.

signal wardrobe_opened
signal wardrobe_closed

@export var npc_name: String = "Render"
@export var dialogue_greeting: String = "Looking sharp, friend. Care to try something on?"
@export var interaction_radius: float = 2.0
@export var preview_outfits: Array[OutfitItem] = []  ## Display-only sets

var _player_in_range: bool = false
var _opened: bool = false


func _ready() -> void:
	add_to_group(&"interactable")
	add_to_group(&"npc")


func interact(player: Node) -> void:
	if _opened:
		return
	_opened = true
	wardrobe_opened.emit()

	# Push the wardrobe UI through the EventBus so the HUD can show it
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("wardrobe_requested"):
			bus.wardrobe_requested.emit(self, player)
		elif bus.has_signal("dialogue_requested"):
			bus.dialogue_requested.emit(npc_name, dialogue_greeting)


func close_wardrobe() -> void:
	if not _opened:
		return
	_opened = false
	wardrobe_closed.emit()


func get_available_outfits(player_inventory: Node) -> Array[OutfitItem]:
	var result: Array[OutfitItem] = []
	# Add preview-only display outfits first
	for outfit in preview_outfits:
		if outfit != null:
			result.append(outfit)
	# Then add player-owned outfits from inventory
	if player_inventory != null and player_inventory.has_method("get_items_of_type"):
		var owned: Array = player_inventory.get_items_of_type(&"outfit")
		for item in owned:
			if item is OutfitItem:
				result.append(item)
	return result
