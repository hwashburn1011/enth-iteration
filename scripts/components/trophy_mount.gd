class_name TrophyMount
extends Area3D

## A single trophy mount point on the wall of the Trophy Display Hall.
## Each mount is pre-labeled with the trophy it CAN hold; it starts
## empty (the spotlight is dim, the mount plate shows the source label
## as a "wanted poster" tease) and lights up when the player has the
## matching trophy item in inventory and presses interact.
##
## Once mounted:
##   - Spotlight ignites at full energy in the category color
##   - Trophy mesh appears at the mount_pose_offset position/rotation
##   - Description plaque becomes interactable for the long-form text
##   - NPCs from npc_comment_pool eventually walk by and comment via
##     EventBus.npc_visit_requested signal
##
## Required scene shape:
##   TrophyMount (Area3D + this script)
##     CollisionShape3D (interact range)
##     Spotlight (SpotLight3D — wall spot, dim until mounted)
##     EmptyPlaque (Label3D — shown when empty, the wanted-poster tease)
##     FilledPlaque (Label3D — shown when mounted)
##     TrophyAnchor (Marker3D — where the trophy mesh attaches)
##     [optional] trophy_scene_overrides (Dictionary in inspector for
##                per-trophy mesh scenes)

signal mounted(mount_id: StringName, item_id: StringName)
signal interacted

@export var mount_id: StringName = &""
@export var trophy_scene_overrides: Dictionary = {}  # item_id → PackedScene

@onready var _spotlight: SpotLight3D = $Spotlight if has_node("Spotlight") else null
@onready var _empty_plaque: Label3D = $EmptyPlaque if has_node("EmptyPlaque") else null
@onready var _filled_plaque: Label3D = $FilledPlaque if has_node("FilledPlaque") else null
@onready var _trophy_anchor: Marker3D = $TrophyAnchor if has_node("TrophyAnchor") else null

const CATEGORY_COLORS: Dictionary = {
	&"boss":     Color(1.00, 0.55, 0.30),
	&"fish":     Color(0.45, 0.85, 1.00),
	&"treasure": Color(1.00, 0.85, 0.45),
}

var _config: Dictionary = {}
var _is_mounted: bool = false
var _trophy_node: Node3D
var _player_in_range: bool = false
var _player_node: Node3D


func _ready() -> void:
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)
	collision_layer = 0
	collision_mask = 1 << 0
	monitorable = false

	if mount_id == &"":
		return
	_config = TrophyMountDatabase.get_mount(mount_id)
	if _config.is_empty():
		push_warning("TrophyMount: unknown mount_id '%s'" % mount_id)
		return

	_apply_visuals()


# === STATE ===

func _apply_visuals() -> void:
	var category: StringName = _config.get("category", &"boss")
	var category_color: Color = CATEGORY_COLORS.get(category, Color.WHITE)

	if _spotlight != null:
		_spotlight.light_color = category_color
		_spotlight.light_energy = 2.4 if _is_mounted else 0.4

	if _empty_plaque != null:
		_empty_plaque.text = "[ EMPTY ]\n%s" % _config.get("source_label", "")
		_empty_plaque.modulate = Color(0.55, 0.55, 0.60)
		_empty_plaque.visible = not _is_mounted

	if _filled_plaque != null:
		_filled_plaque.text = "%s" % _trophy_display_name()
		_filled_plaque.modulate = category_color
		_filled_plaque.visible = _is_mounted


func _trophy_display_name() -> String:
	# Convert trophy_item_id (e.g., trophy_voidshark) into a display name
	var item_id: String = String(_config.get("trophy_item_id", &""))
	if item_id.begins_with("trophy_"):
		item_id = item_id.substr(7)
	return item_id.capitalize()


# === MOUNT ===

func can_mount() -> bool:
	if _is_mounted or not _player_in_range or _player_node == null:
		return false
	var item_id: StringName = _config.get("trophy_item_id", &"")
	if item_id == &"":
		return false
	return _player_has_item(item_id)


func attempt_mount() -> bool:
	if _is_mounted:
		_show_already_mounted_dialog()
		return false
	if not can_mount():
		return false

	var item_id: StringName = _config.get("trophy_item_id", &"")
	if not _consume_trophy_item(item_id):
		return false

	_is_mounted = true
	_spawn_trophy_mesh(item_id)
	_animate_spotlight_ignite()
	_apply_visuals()

	mounted.emit(mount_id, item_id)
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("trophy_mounted"):
			bus.emit_signal("trophy_mounted", mount_id, item_id)

	# Sting + SFX
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_trophy_mount")
	if has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(&"sting_trophy_mounted")

	# Schedule NPC visit commentary
	_schedule_npc_visits()
	return true


func _spawn_trophy_mesh(item_id: StringName) -> void:
	if _trophy_anchor == null:
		return
	var scene: PackedScene = trophy_scene_overrides.get(item_id, null)
	if scene == null:
		# Fallback: small box as placeholder so the mount visibly fills
		var box: MeshInstance3D = MeshInstance3D.new()
		var box_mesh: BoxMesh = BoxMesh.new()
		box_mesh.size = Vector3(0.4, 0.4, 0.2)
		box.mesh = box_mesh
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = CATEGORY_COLORS.get(_config.get("category", &"boss"), Color.WHITE)
		mat.emission_enabled = true
		mat.emission = mat.albedo_color
		mat.emission_energy_multiplier = 0.4
		box.set_surface_override_material(0, mat)
		_trophy_anchor.add_child(box)
		_trophy_node = box
	else:
		var inst: Node3D = scene.instantiate() as Node3D
		if inst != null:
			_trophy_anchor.add_child(inst)
			_trophy_node = inst

	# Apply pose offset
	if _trophy_node != null:
		var offset: Array = _config.get("mount_pose_offset", [Vector3.ZERO, Vector3.ZERO])
		_trophy_node.position = offset[0]
		_trophy_node.rotation = offset[1]


func _animate_spotlight_ignite() -> void:
	if _spotlight == null:
		return
	_spotlight.light_energy = 0.4
	var tw: Tween = create_tween()
	tw.tween_property(_spotlight, "light_energy", 2.4, 1.2)


# === NPC VISITS ===

func _schedule_npc_visits() -> void:
	## NPCs from the comment pool walk by and comment over the next
	## few in-game days. Routes through EventBus so the broader NPC
	## scheduler can pick up the request.
	var pool: Array = _config.get("npc_comment_pool", [])
	if pool.is_empty() or not has_node("/root/EventBus"):
		return
	var bus: Node = get_node("/root/EventBus")
	if not bus.has_signal("npc_visit_requested"):
		return
	for i in pool.size():
		var npc_id: StringName = pool[i]
		# Stagger visits over the next few days
		bus.emit_signal("npc_visit_requested", npc_id, mount_id, i + 1)


# === INTERACTION (read description) ===

func interact() -> bool:
	if not _player_in_range:
		return false
	interacted.emit()

	if not _is_mounted:
		# If the player has the trophy in inventory, prompt to mount it
		if can_mount():
			return attempt_mount()
		# Otherwise, show the empty wanted-poster description
		if has_node("/root/DialogueManager"):
			var dm: Node = get_node("/root/DialogueManager")
			if dm.has_method("show_line"):
				dm.show_line("narrator", "%s — %s" % [_trophy_display_name(), _config.get("source_label", "")], &"voice_narrator_soft")
		return false

	# Mounted: show the long-form description
	var desc: String = _config.get("description", "")
	if desc != "" and has_node("/root/DialogueManager"):
		var dm: Node = get_node("/root/DialogueManager")
		if dm.has_method("show_long_form"):
			dm.show_long_form(_trophy_display_name(), desc)
		elif dm.has_method("show_line"):
			dm.show_line("narrator", desc, &"voice_narrator_soft")
	return true


func _show_already_mounted_dialog() -> void:
	if has_node("/root/DialogueManager"):
		var dm: Node = get_node("/root/DialogueManager")
		if dm.has_method("show_line"):
			dm.show_line("narrator", "Already mounted.", &"")


# === PLAYER ITEMS ===

func _player_has_item(item_id: StringName) -> bool:
	if _player_node == null:
		return false
	var inv: Node = _player_node.get_node_or_null("InventoryComponent")
	if inv == null:
		return false
	if inv.has_method("has_item_id"):
		return inv.has_item_id(String(item_id))
	return false


func _consume_trophy_item(item_id: StringName) -> bool:
	if _player_node == null:
		return false
	var inv: Node = _player_node.get_node_or_null("InventoryComponent")
	if inv == null:
		return false
	if inv.has_method("remove_item_by_id"):
		return inv.remove_item_by_id(String(item_id), 1)
	return false


# === EVENTS ===

func _on_player_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = true
		_player_node = body


func _on_player_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false
		_player_node = null


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"mount_id": String(mount_id),
		"is_mounted": _is_mounted,
	}


func from_save_data(data: Dictionary) -> void:
	_is_mounted = data.get("is_mounted", false)
	if _is_mounted and not _config.is_empty():
		_spawn_trophy_mesh(_config.get("trophy_item_id", &""))
		_apply_visuals()
