class_name FarmPlot
extends Node3D

## A single farm plot. State machine: untilled → tilled → planted → watered →
## mature → harvested → untilled. Auto-progresses based on day/night cycle
## ticks via signal from the global day/night system.

signal state_changed(plot: FarmPlot, new_state: int)
signal harvested(plot: FarmPlot, crop_id: StringName, count: int, quality: int)
signal withered(plot: FarmPlot)

enum State {
	UNTILLED,
	TILLED,
	PLANTED,
	WATERED,
	MATURE,
	WITHERED,
}

@export var plot_id: int = 0
var state: int = State.UNTILLED
var crop_id: StringName = &""
var growth_progress: float = 0.0  ## 0-1 toward mature
var watered_until_day: int = -1
var planted_at_day: int = -1
var fertilizer_applied: StringName = &""  ## "", "basic", "quality", "glitch"
var quality_tier: int = 0  ## 0=Standard, 1=Silver, 2=Gold

@onready var _model_holder: Node3D = $ModelHolder if has_node("ModelHolder") else null


func _ready() -> void:
	add_to_group(&"interactable")
	add_to_group(&"farm_plot")
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("day_advanced"):
			bus.day_advanced.connect(_on_day_advanced)


func interact(player: Node) -> void:
	## Context-sensitive interaction based on current state.
	match state:
		State.UNTILLED, State.WITHERED:
			till(player)
		State.TILLED:
			# Need a seed to plant — handled by UI
			if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
				var bus: Node = get_node("/root/EventBus")
				if bus.has_signal("seed_picker_requested"):
					bus.seed_picker_requested.emit(self, player)
		State.PLANTED:
			water(player)
		State.MATURE:
			harvest(player)


func till(player: Node) -> bool:
	if state != State.UNTILLED and state != State.WITHERED:
		return false
	state = State.TILLED
	state_changed.emit(self, state)
	_grant_xp(player, 1)
	return true


func plant(player: Node, new_crop_id: StringName) -> bool:
	if state != State.TILLED:
		return false
	var crop: Dictionary = CropDatabase.get_crop(new_crop_id)
	if crop.is_empty():
		return false
	# Consume seed from inventory
	var inv: Node = player.get_node_or_null("InventoryComponent")
	if inv == null or not inv.has_method("remove_item_by_id"):
		return false
	if not inv.remove_item_by_id("seed_" + String(new_crop_id), 1):
		return false
	crop_id = new_crop_id
	state = State.PLANTED
	growth_progress = 0.0
	planted_at_day = _get_current_day()
	state_changed.emit(self, state)
	_grant_xp(player, 1)
	return true


func water(player: Node) -> bool:
	if state != State.PLANTED:
		return false
	state = State.WATERED
	watered_until_day = _get_current_day() + 1
	state_changed.emit(self, state)
	_grant_xp(player, 1)
	return true


func apply_fertilizer(player: Node, fert_type: StringName) -> bool:
	if state != State.TILLED and state != State.PLANTED and state != State.WATERED:
		return false
	if fertilizer_applied != &"":
		return false  # already fertilized
	var inv: Node = player.get_node_or_null("InventoryComponent")
	if inv == null:
		return false
	if not inv.remove_item_by_id("fertilizer_" + String(fert_type), 1):
		return false
	fertilizer_applied = fert_type
	# Quality fertilizer rolls a tier bump now
	if fert_type == &"quality":
		var roll: float = randf()
		if roll < 0.4:
			quality_tier = 1  # Silver
		elif roll < 0.7:
			quality_tier = 2  # Gold
	return true


func harvest(player: Node) -> bool:
	if state != State.MATURE:
		return false
	var crop: Dictionary = CropDatabase.get_crop(crop_id)
	if crop.is_empty():
		return false

	# Compute output count: base 1, +1 if watered, +1 if glitch fertilizer
	var output_count: int = 1
	if fertilizer_applied == &"glitch":
		output_count = 2

	# Material drops
	var inv: Node = player.get_node_or_null("InventoryComponent")
	if inv != null:
		var drops: Dictionary = crop.get("drops", {})
		var quality_mult: float = [1.0, 1.5, 2.0][quality_tier]
		for material_id: StringName in drops.keys():
			var n: int = int(ceil(drops[material_id] * output_count * quality_mult))
			if inv.has_method("add_item_by_id"):
				inv.add_item_by_id(String(material_id), n)
		# Crop item itself
		if inv.has_method("add_item_by_id"):
			inv.add_item_by_id("crop_" + String(crop_id), output_count)

	harvested.emit(self, crop_id, output_count, quality_tier)
	_grant_xp(player, 5 * (1 + quality_tier))

	# Reset plot
	state = State.UNTILLED
	crop_id = &""
	growth_progress = 0.0
	watered_until_day = -1
	planted_at_day = -1
	fertilizer_applied = &""
	quality_tier = 0
	state_changed.emit(self, state)
	return true


func _on_day_advanced(new_day: int) -> void:
	## Called by the global day/night system once per in-game day.
	if state == State.PLANTED or state == State.WATERED:
		var crop: Dictionary = CropDatabase.get_crop(crop_id)
		if crop.is_empty():
			return
		var growth_per_day: float = 1.0 / float(crop.get("days", 1))
		# Watered crops grow 30% faster
		if state == State.WATERED:
			growth_per_day *= 1.3
		# Basic/quality fertilizer reduces total growth time
		if fertilizer_applied == &"basic" or fertilizer_applied == &"quality":
			growth_per_day *= 1.3
		growth_progress += growth_per_day

		if growth_progress >= 1.0:
			state = State.MATURE
			state_changed.emit(self, state)
		elif state == State.WATERED and new_day > watered_until_day:
			# Water expired, return to planted
			state = State.PLANTED
			state_changed.emit(self, state)
	elif state == State.PLANTED:
		# Check for withering — 3 days without water
		if new_day - planted_at_day >= 3 and watered_until_day < planted_at_day:
			state = State.WITHERED
			withered.emit(self)
			state_changed.emit(self, state)


func _get_current_day() -> int:
	if Engine.has_singleton("IterationManager") or has_node("/root/IterationManager"):
		var im: Node = get_node("/root/IterationManager")
		if im.has_method("get_current_day"):
			return im.get_current_day()
	return 0


func _grant_xp(player: Node, amount: int) -> void:
	var farming: Node = player.get_node_or_null("FarmingComponent")
	if farming != null and farming.has_method("grant_xp"):
		farming.grant_xp(amount)


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"plot_id": plot_id,
		"state": state,
		"crop_id": String(crop_id),
		"growth_progress": growth_progress,
		"watered_until_day": watered_until_day,
		"planted_at_day": planted_at_day,
		"fertilizer_applied": String(fertilizer_applied),
		"quality_tier": quality_tier,
	}


func from_save_data(data: Dictionary) -> void:
	plot_id = data.get("plot_id", 0)
	state = data.get("state", State.UNTILLED)
	crop_id = StringName(data.get("crop_id", ""))
	growth_progress = data.get("growth_progress", 0.0)
	watered_until_day = data.get("watered_until_day", -1)
	planted_at_day = data.get("planted_at_day", -1)
	fertilizer_applied = StringName(data.get("fertilizer_applied", ""))
	quality_tier = data.get("quality_tier", 0)
	state_changed.emit(self, state)
