class_name HiddenTreasureChest
extends Area3D

## The chest at the back of the Hidden Treasure Room behind the
## bookshelf puzzle. Granted contents per the bible:
##
##   1. The Inheritor outfit head slot piece
##   2. A lore tablet that reveals what the previous Globbler was hiding
##   3. A small key that unlocks one more vault inside the Memorial Gallery
##
## The chest is locked-by-default. It only becomes openable once the
## player has solved the BookshelfPuzzle (bookshelf_treasure_opened
## flag is set). Opening is a one-shot per save file: opens the lid,
## fires a ceremony cinematic, grants all 3 items, and stays open.
##
## Required scene shape:
##   HiddenTreasureChest (Area3D + this script)
##     CollisionShape3D (interact range)
##     LidPivot (Node3D — pivot for the lid open animation)
##     ChestBody (MeshInstance3D — the chest itself)
##     CandleFlicker (OmniLight3D — warm point light, off until opened)
##     [optional] AnimationPlayer with 'open' animation

signal opened
signal contents_granted(rewards: Array)
signal interaction_blocked(reason: StringName)

const GATE_FLAG: StringName = &"bookshelf_treasure_opened"
const OPENED_FLAG: StringName = &"hidden_treasure_chest_opened"

# Per-bible rewards
const REWARDS: Array[Dictionary] = [
	{
		"type": &"outfit_piece",
		"set": &"the_inheritor",
		"slot": &"head",
		"item_id": &"outfit_inheritor_head",
	},
	{
		"type": &"lore_tablet",
		"id": &"lore_previous_globbler_secret",
	},
	{
		"type": &"key",
		"id": &"memorial_vault_key",
		"unlocks": &"memorial_secret_vault",
	},
]

@onready var _lid_pivot: Node3D = $LidPivot if has_node("LidPivot") else null
@onready var _candle: OmniLight3D = $CandleFlicker if has_node("CandleFlicker") else null

var _player_in_range: bool = false
var _player_node: Node3D
var _is_opened: bool = false


func _ready() -> void:
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)
	collision_layer = 0
	collision_mask = 1 << 0
	monitorable = false
	_load_state()


# === INTERACTION ===

func can_open() -> bool:
	if _is_opened:
		return false
	if not _player_in_range:
		return false
	# Gate on the bookshelf puzzle solved flag
	if not _has_flag(GATE_FLAG):
		return false
	return true


func interact() -> bool:
	if _is_opened:
		_show_already_opened_dialog()
		return false
	if not _player_in_range:
		interaction_blocked.emit(&"not_in_range")
		return false
	if not _has_flag(GATE_FLAG):
		interaction_blocked.emit(&"locked")
		_show_locked_dialog()
		return false
	return _open_chest()


# === OPEN ===

func _open_chest() -> bool:
	_is_opened = true
	opened.emit()

	_play_open_animation()
	_grant_all_rewards()
	_play_open_cinematic()

	# Set the canonical flag so the open state persists
	if has_node("/root/WildernessStoryManager"):
		var sm: Node = get_node("/root/WildernessStoryManager")
		if sm.has_method("set_flag"):
			sm.set_flag(OPENED_FLAG)

	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("hidden_treasure_chest_opened"):
			bus.emit_signal("hidden_treasure_chest_opened")

	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_hidden_chest_open")
	if has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(&"sting_inheritor_unlock")

	return true


func _grant_all_rewards() -> void:
	var granted: Array = []
	for reward in REWARDS:
		_grant_one(reward)
		granted.append(reward)
	contents_granted.emit(granted)
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("reward_granted"):
			for r in granted:
				bus.emit_signal("reward_granted", r)


func _grant_one(reward: Dictionary) -> void:
	if _player_node == null:
		return
	var inv: Node = _player_node.get_node_or_null("InventoryComponent")
	if inv == null:
		return
	var reward_type: StringName = reward.get("type", &"")
	match reward_type:
		&"outfit_piece":
			var item_id: String = String(reward.get("item_id", &""))
			if inv.has_method("add_item_by_id"):
				inv.add_item_by_id(item_id, 1)
		&"lore_tablet":
			# Route through LoreManager if present
			var root: Node = get_tree().root
			var lm: Node = root.get_node_or_null("LoreManager")
			if lm != null and lm.has_method("collect"):
				lm.collect(reward.get("id", &""))
			else:
				# Fallback: drop it as an inventory item
				if inv.has_method("add_item_by_id"):
					inv.add_item_by_id("tablet_" + String(reward.get("id", &"")), 1)
		&"key":
			if inv.has_method("add_item_by_id"):
				inv.add_item_by_id(String(reward.get("id", &"")), 1)
			# Set a story flag so the memorial vault listens
			if has_node("/root/WildernessStoryManager"):
				var sm: Node = get_node("/root/WildernessStoryManager")
				if sm.has_method("set_flag"):
					sm.set_flag(StringName("key_" + String(reward.get("id", &""))))


# === ANIMATION ===

func _play_open_animation() -> void:
	# Try AnimationPlayer first
	var ap: AnimationPlayer = get_node_or_null("AnimationPlayer") as AnimationPlayer
	if ap != null and ap.has_animation(&"open"):
		ap.play(&"open")
	elif _lid_pivot != null:
		# Fallback: tween the lid pivot rotation
		var tw: Tween = create_tween()
		tw.tween_property(_lid_pivot, "rotation_degrees:x", -75.0, 1.2)

	# Candle ignites
	if _candle != null:
		_candle.visible = true
		_candle.light_color = Color(1.00, 0.85, 0.55)
		_candle.light_energy = 0.0
		var tw2: Tween = create_tween()
		tw2.tween_property(_candle, "light_energy", 1.6, 1.5)


func _play_open_cinematic() -> void:
	if not has_node("/root/CutsceneController"):
		return
	var cc: Node = get_node("/root/CutsceneController")
	if not cc.has_method("play_timeline"):
		return
	var timeline: Array = [
		{"event": &"set_letterbox", "enabled": true},
		{"event": &"camera_move", "target": global_position + Vector3(0, 1.6, 1.4), "look_at": global_position, "duration": 1.5, "fov": 50.0},
		{"event": &"play_dialogue", "speaker": &"narrator", "text": "The Inheritor's chest. Eight Globblers stood here before you and could not open it.", "duration": 4.0},
		{"event": &"wait", "duration": 0.6},
		{"event": &"play_dialogue", "speaker": &"narrator", "text": "You did.", "duration": 2.5},
		{"event": &"set_letterbox", "enabled": false},
	]
	cc.play_timeline(timeline)


# === DIALOG STUBS ===

func _show_locked_dialog() -> void:
	if has_node("/root/DialogueManager"):
		var dm: Node = get_node("/root/DialogueManager")
		if dm.has_method("show_line"):
			dm.show_line("narrator", "The chest is locked. The lock has no keyhole.", &"voice_narrator_soft")


func _show_already_opened_dialog() -> void:
	if has_node("/root/DialogueManager"):
		var dm: Node = get_node("/root/DialogueManager")
		if dm.has_method("show_line"):
			dm.show_line("narrator", "Already empty. The candle still burns.", &"voice_narrator_soft")


# === HELPERS ===

func _has_flag(flag: StringName) -> bool:
	if not has_node("/root/WildernessStoryManager"):
		return false
	var sm: Node = get_node("/root/WildernessStoryManager")
	if sm.has_method("has_flag"):
		return sm.has_flag(flag)
	return false


func _load_state() -> void:
	if _has_flag(OPENED_FLAG):
		_is_opened = true
		# Render lid as already-open without firing the cinematic
		if _lid_pivot != null:
			_lid_pivot.rotation_degrees.x = -75.0
		if _candle != null:
			_candle.visible = true
			_candle.light_color = Color(1.00, 0.85, 0.55)
			_candle.light_energy = 1.6


# === EVENTS ===

func _on_player_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = true
		_player_node = body


func _on_player_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false
		_player_node = null
