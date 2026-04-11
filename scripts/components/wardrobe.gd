class_name Wardrobe
extends Node3D

## The wardrobe room interaction hub. Owns 4 distinct interaction
## stations from the bible:
##
##   1. MIRROR — full-length mirror at the back wall. Opens the
##      dressing UI (paper doll, EquipmentVisualizer preview).
##   2. MANNEQUINS — 8 display stands, each pre-loaded with a
##      full outfit set. Click one to equip that entire set in
##      a single action.
##   3. WARDROBE CHEST — browse + store outfit pieces the player
##      doesn't currently wear.
##   4. DYE STATION — apply a dye color to the currently-worn
##      outfit using OutfitItem.apply_dye + the existing 16-color
##      DYE_PALETTE.
##
## All four stations report through this same component so the
## wardrobe room scene can wire them up by setting the appropriate
## inspector path. The component listens for player presence on
## any of its 4 child Area3Ds.
##
## Required scene shape:
##   Wardrobe (Node3D + this script)
##     Mirror (Area3D + CollisionShape3D — interact range)
##     MannequinsParent (Node3D — child Area3D per mannequin, each
##                       carrying a 'set_id' StringName meta)
##     Chest (Area3D + CollisionShape3D — interact range)
##     DyeStation (Area3D + CollisionShape3D — interact range)
##
## Configure via inspector:
##   stored_set_ids — Array[StringName] of OutfitSet ids displayed
##                    on the 8 mannequins (in order)

signal mirror_opened
signal mirror_closed
signal set_equipped(set_id: StringName)
signal chest_opened
signal dye_applied(color_index: int)
signal interaction_blocked(reason: StringName)

@export var stored_set_ids: Array[StringName] = []

@onready var _mirror_area: Area3D = $Mirror if has_node("Mirror") else null
@onready var _mannequins_parent: Node3D = $MannequinsParent if has_node("MannequinsParent") else null
@onready var _chest_area: Area3D = $Chest if has_node("Chest") else null
@onready var _dye_area: Area3D = $DyeStation if has_node("DyeStation") else null

var _player_at_mirror: bool = false
var _player_at_chest: bool = false
var _player_at_dye: bool = false
var _player_at_mannequin: Area3D
var _player_node: Node3D


func _ready() -> void:
	if _mirror_area != null:
		_mirror_area.body_entered.connect(_on_mirror_entered)
		_mirror_area.body_exited.connect(_on_mirror_exited)
		_mirror_area.collision_layer = 0
		_mirror_area.collision_mask = 1 << 0
		_mirror_area.monitorable = false
	if _chest_area != null:
		_chest_area.body_entered.connect(_on_chest_entered)
		_chest_area.body_exited.connect(_on_chest_exited)
		_chest_area.collision_layer = 0
		_chest_area.collision_mask = 1 << 0
		_chest_area.monitorable = false
	if _dye_area != null:
		_dye_area.body_entered.connect(_on_dye_entered)
		_dye_area.body_exited.connect(_on_dye_exited)
		_dye_area.collision_layer = 0
		_dye_area.collision_mask = 1 << 0
		_dye_area.monitorable = false
	_setup_mannequins()


func _setup_mannequins() -> void:
	if _mannequins_parent == null:
		return
	var mannequins: Array = _mannequins_parent.get_children()
	for i in mannequins.size():
		var mannequin: Node = mannequins[i]
		if not (mannequin is Area3D):
			continue
		var area: Area3D = mannequin
		# Assign the set_id from the inspector list
		if i < stored_set_ids.size():
			area.set_meta(&"set_id", stored_set_ids[i])
		area.body_entered.connect(_on_mannequin_entered.bind(area))
		area.body_exited.connect(_on_mannequin_exited.bind(area))
		area.collision_layer = 0
		area.collision_mask = 1 << 0
		area.monitorable = false


# === MIRROR ===

func open_mirror() -> bool:
	if not _player_at_mirror or _player_node == null:
		interaction_blocked.emit(&"not_at_mirror")
		return false
	mirror_opened.emit()
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("dressing_ui_open_requested"):
			bus.emit_signal("dressing_ui_open_requested")
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_mirror_chime")
	return true


# === MANNEQUIN ===

func equip_mannequin_set() -> bool:
	if _player_at_mannequin == null or _player_node == null:
		interaction_blocked.emit(&"not_at_mannequin")
		return false
	var set_id: StringName = _player_at_mannequin.get_meta(&"set_id", &"")
	if set_id == &"":
		interaction_blocked.emit(&"empty_mannequin")
		return false
	if not _equip_outfit_set(set_id):
		return false
	set_equipped.emit(set_id)
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("outfit_set_equipped"):
			bus.emit_signal("outfit_set_equipped", set_id)
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_outfit_swap")
	if has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(&"sting_outfit_equipped")
	return true


func _equip_outfit_set(set_id: StringName) -> bool:
	# Route through EquipmentVisualizer / EquipmentComponent if present
	var equip: Node = _player_node.get_node_or_null("EquipmentComponent")
	if equip != null and equip.has_method("equip_set"):
		return equip.equip_set(set_id)
	# Fallback: walk OutfitDatabase if available
	if Engine.get_main_loop() != null:
		var root: Node = (Engine.get_main_loop() as SceneTree).root
		var em: Node = root.get_node_or_null("EquipmentManager")
		if em != null and em.has_method("equip_set"):
			return em.equip_set(set_id)
	return false


# === CHEST ===

func open_chest() -> bool:
	if not _player_at_chest:
		interaction_blocked.emit(&"not_at_chest")
		return false
	chest_opened.emit()
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("wardrobe_chest_open_requested"):
			bus.emit_signal("wardrobe_chest_open_requested")
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_chest_open")
	return true


# === DYE STATION ===

func apply_dye(color_index: int) -> bool:
	if not _player_at_dye or _player_node == null:
		interaction_blocked.emit(&"not_at_dye_station")
		return false
	# Dye the player's currently-equipped outfit pieces via OutfitItem.apply_dye
	var equip: Node = _player_node.get_node_or_null("EquipmentComponent")
	if equip == null:
		interaction_blocked.emit(&"no_equipment")
		return false
	if equip.has_method("apply_dye_to_equipped_set"):
		var ok: bool = equip.apply_dye_to_equipped_set(color_index)
		if ok:
			dye_applied.emit(color_index)
			if has_node("/root/SFXManager"):
				var sm: Node = get_node("/root/SFXManager")
				if sm.has_method("play"):
					sm.play(&"sfx_dye_apply")
		return ok
	return false


# === EVENT HANDLERS ===

func _on_mirror_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_at_mirror = true
		_player_node = body


func _on_mirror_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_at_mirror = false
		mirror_closed.emit()


func _on_chest_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_at_chest = true
		_player_node = body


func _on_chest_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_at_chest = false


func _on_dye_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_at_dye = true
		_player_node = body


func _on_dye_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_at_dye = false


func _on_mannequin_entered(body: Node3D, area: Area3D) -> void:
	if body.is_in_group(&"player"):
		_player_at_mannequin = area
		_player_node = body


func _on_mannequin_exited(body: Node3D, area: Area3D) -> void:
	if body.is_in_group(&"player") and _player_at_mannequin == area:
		_player_at_mannequin = null
