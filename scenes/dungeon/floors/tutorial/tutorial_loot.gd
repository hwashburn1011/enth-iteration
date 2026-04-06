extends RoomBase
## Tutorial: open a container and pick up loot.

var _overlay: TutorialOverlay = null


func _ready() -> void:
	room_type = "loot"
	is_cleared = true
	super._ready()
	_overlay = TutorialOverlay.new()
	_overlay.instruction_text = "Press E to open containers and pick up loot"
	add_child(_overlay)

	EventBus.item_collected.connect(_on_item_collected)


func _on_item_collected(_item: Resource) -> void:
	if _overlay:
		_overlay.dismiss()
		_overlay = null
	EventBus.item_collected.disconnect(_on_item_collected)
