class_name FarmPlotInteractable
extends Area3D

## Player-facing interaction wrapper for a FarmPlot. Place at every
## plot position in the farm scene. Detects when the player walks into
## range, listens to the wrapped FarmPlot's state, and routes the
## player's interact press to the right method:
##
##   UNTILLED → till() (no seed needed)
##   TILLED   → opens seed selection UI, then plant(crop_id)
##   PLANTED  → water()  (requires watering can equipped)
##   WATERED  → no action; wait for growth
##   MATURE   → harvest() (returns crop + drops)
##   WITHERED → till() to clear and restart
##
## Required scene shape:
##   FarmPlotInteractable (Area3D + this script)
##     CollisionShape3D (BoxShape3D, plot tile size)
##     Plot (FarmPlot child node) ← the actual data
##     [optional] StateVisuals (Node3D — children per state for visuals)
##     [optional] PromptAnchor (Marker3D — where the interact prompt floats)

signal player_in_range(plot: FarmPlot)
signal player_left_range(plot: FarmPlot)
signal interaction_requested(plot: FarmPlot, action: StringName)
signal seed_selection_requested(plot: FarmPlot, available_seeds: Array)

@export var plot_path: NodePath = ^"Plot"

@onready var _plot: FarmPlot = get_node_or_null(plot_path) as FarmPlot
@onready var _state_visuals: Node3D = $StateVisuals if has_node("StateVisuals") else null

var _player_in_range: bool = false
var _player_node: Node3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	collision_layer = 0
	collision_mask = 1 << 0
	monitorable = false
	if _plot != null and _plot.has_signal("state_changed"):
		_plot.state_changed.connect(_on_plot_state_changed)
		_apply_state_visuals(_plot.state)


# === INTERACTION ===

func get_current_action() -> StringName:
	## Returns the action the player would trigger if they pressed
	## interact right now. Used by the HUD prompt to show the right verb.
	if _plot == null:
		return &""
	match _plot.state:
		FarmPlot.State.UNTILLED:
			return &"till"
		FarmPlot.State.TILLED:
			return &"plant"
		FarmPlot.State.PLANTED:
			return &"water"
		FarmPlot.State.WATERED:
			return &""  # no action; growing
		FarmPlot.State.MATURE:
			return &"harvest"
		FarmPlot.State.WITHERED:
			return &"clear"
	return &""


func interact() -> bool:
	if not _player_in_range or _plot == null or _player_node == null:
		return false

	var action: StringName = get_current_action()
	interaction_requested.emit(_plot, action)

	match action:
		&"till":
			return _do_till()
		&"plant":
			return _do_open_seed_picker()
		&"water":
			return _do_water()
		&"harvest":
			return _do_harvest()
		&"clear":
			return _do_till()  # withered → till to clear
	return false


func plant_with_seed(crop_id: StringName) -> bool:
	## Called by the seed picker UI after the player chose a seed.
	if _plot == null or _player_node == null:
		return false
	if _plot.state != FarmPlot.State.TILLED:
		return false
	var ok: bool = _plot.plant(_player_node, crop_id)
	if ok:
		_play_action_sfx(&"sfx_farm_plant")
	return ok


# === ACTIONS ===

func _do_till() -> bool:
	if _plot == null or _player_node == null:
		return false
	# Tilling requires hands or a hoe — be permissive here, the existing
	# till() method handles its own validation
	if _plot.has_method("till"):
		var ok: bool = _plot.till(_player_node)
		if ok:
			_play_action_sfx(&"sfx_farm_till")
		return ok
	return false


func _do_open_seed_picker() -> bool:
	# Build the available-seeds list from the player's inventory
	var inv: Node = _player_node.get_node_or_null("InventoryComponent")
	if inv == null:
		return false
	var seeds: Array = []
	for crop in CropDatabase.CROPS:
		var seed_id: String = "seed_" + String(crop.get("id", &""))
		if inv.has_method("has_item_id") and inv.has_item_id(seed_id):
			seeds.append(crop)
	if seeds.is_empty():
		return false
	seed_selection_requested.emit(_plot, seeds)
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("seed_picker_requested"):
			bus.emit_signal("seed_picker_requested", _plot, seeds)
	return true


func _do_water() -> bool:
	if _plot == null or _player_node == null:
		return false
	if _plot.has_method("water"):
		var ok: bool = _plot.water(_player_node)
		if ok:
			_play_action_sfx(&"sfx_farm_water")
		return ok
	return false


func _do_harvest() -> bool:
	if _plot == null or _player_node == null:
		return false
	if _plot.has_method("harvest"):
		var ok: bool = _plot.harvest(_player_node)
		if ok:
			_play_action_sfx(&"sfx_farm_harvest")
			# Light music sting on a successful harvest of a rare crop
			var crop: Dictionary = CropDatabase.get_crop(_plot.crop_id) if _plot.crop_id != &"" else {}
			if not crop.is_empty() and int(crop.get("rarity", 0)) >= 2:
				if has_node("/root/MusicManager"):
					var mm: Node = get_node("/root/MusicManager")
					if mm.has_method("play_sting"):
						mm.play_sting(&"sting_rare_harvest")
		return ok
	return false


# === VISUALS ===

func _on_plot_state_changed(_plot: FarmPlot, new_state: int) -> void:
	_apply_state_visuals(new_state)


func _apply_state_visuals(state_value: int) -> void:
	if _state_visuals == null:
		return
	# Hide all child visuals first
	for child in _state_visuals.get_children():
		if child is Node3D:
			(child as Node3D).visible = false
	# Show the one matching the state name
	var state_name: String = _state_name_from_value(state_value)
	var target: Node3D = _state_visuals.get_node_or_null(state_name) as Node3D
	if target != null:
		target.visible = true


func _state_name_from_value(v: int) -> String:
	match v:
		FarmPlot.State.UNTILLED: return "Untilled"
		FarmPlot.State.TILLED:   return "Tilled"
		FarmPlot.State.PLANTED:  return "Planted"
		FarmPlot.State.WATERED:  return "Watered"
		FarmPlot.State.MATURE:   return "Mature"
		FarmPlot.State.WITHERED: return "Withered"
	return "Untilled"


# === HELPERS ===

func _play_action_sfx(sfx_id: StringName) -> void:
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(sfx_id)


# === EVENTS ===

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group(&"player"):
		return
	_player_in_range = true
	_player_node = body
	if _plot != null:
		player_in_range.emit(_plot)


func _on_body_exited(body: Node3D) -> void:
	if not body.is_in_group(&"player"):
		return
	_player_in_range = false
	if _plot != null:
		player_left_range.emit(_plot)
	_player_node = null
