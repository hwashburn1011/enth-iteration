class_name MemorialPlaque
extends Area3D

## A single alcove plaque in the Memorial Gallery. Each alcove holds
## one plaque tied to a specific iteration. The plaque starts SEALED
## (covered by a stone slab) until the player has cleared its
## iteration_number; then it visibly transitions to UNSEALED — the
## slab fades, the candle ignites in the per-iteration tint, the
## portrait silhouette appears, and the epitaph brass strip lights up.
##
## On player interact, the long-form lore_paragraph displays as a
## reading panel via DialogueManager.show_long_form (or fallback to
## chained show_line calls).
##
## Required scene shape:
##   MemorialPlaque (Area3D + this script)
##     CollisionShape3D (interact range)
##     SealedSlab (MeshInstance3D — covers the alcove until unlocked)
##     PortraitMesh (MeshInstance3D — the silhouette quad)
##     PortraitLabel (Label3D — fallback portrait '#N' badge)
##     Candle (OmniLight3D — alcove candle, lit only when unsealed)
##     EpitaphLabel (Label3D — the brass strip text)
##
## Configure via inspector:
##   plaque_id — must match a MemorialPlaqueDatabase entry id

signal unsealed
signal player_read
signal candle_lit

@export var plaque_id: StringName = &""

@onready var _sealed_slab: MeshInstance3D = $SealedSlab if has_node("SealedSlab") else null
@onready var _portrait_mesh: MeshInstance3D = $PortraitMesh if has_node("PortraitMesh") else null
@onready var _portrait_label: Label3D = $PortraitLabel if has_node("PortraitLabel") else null
@onready var _candle: OmniLight3D = $Candle if has_node("Candle") else null
@onready var _epitaph_label: Label3D = $EpitaphLabel if has_node("EpitaphLabel") else null

var _config: Dictionary = {}
var _is_sealed: bool = true
var _player_in_range: bool = false


func _ready() -> void:
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)
	collision_layer = 0
	collision_mask = 1 << 0
	monitorable = false

	if plaque_id == &"":
		return
	_config = MemorialPlaqueDatabase.get_plaque(plaque_id)
	if _config.is_empty():
		push_warning("MemorialPlaque: unknown plaque_id '%s'" % plaque_id)
		return

	_evaluate_seal_state()

	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("iteration_cleared"):
			bus.iteration_cleared.connect(_on_iteration_cleared)


# === SEAL STATE ===

func _evaluate_seal_state() -> void:
	var clears: int = _get_iterations_cleared()
	var iter_num: int = int(_config.get("iteration_number", 99))
	var should_be_unsealed: bool = clears >= iter_num
	if _is_sealed and should_be_unsealed:
		unseal(true)
	elif not _is_sealed and not should_be_unsealed:
		_apply_sealed_visuals()


func unseal(animated: bool) -> void:
	_is_sealed = false
	if animated:
		_play_unseal_animation()
	else:
		_apply_unsealed_visuals()
	unsealed.emit()


func _play_unseal_animation() -> void:
	# Slab fades to alpha 0 over 1.5s, then queue_frees
	if _sealed_slab != null:
		var mat: Material = _sealed_slab.get_surface_override_material(0)
		if mat is StandardMaterial3D:
			var sm: StandardMaterial3D = mat
			sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			var c: Color = sm.albedo_color
			var tw: Tween = create_tween()
			tw.tween_property(sm, "albedo_color", Color(c.r, c.g, c.b, 0.0), 1.5)
			tw.tween_callback(func() -> void:
				if is_instance_valid(_sealed_slab):
					_sealed_slab.queue_free()
			)
		else:
			_sealed_slab.queue_free()

	# Candle ignites — light energy ramps from 0 to 1.4 over 2 seconds
	if _candle != null:
		var color: Color = _config.get("candle_color", Color.WHITE)
		_candle.light_color = color
		_candle.light_energy = 0.0
		_candle.visible = true
		var tw: Tween = create_tween()
		tw.tween_property(_candle, "light_energy", 1.4, 2.0)
		tw.tween_callback(func() -> void: candle_lit.emit())

	# Portrait + epitaph fade in
	_apply_portrait_text()
	_apply_epitaph_text()
	if _portrait_mesh != null:
		_portrait_mesh.visible = true
	if _portrait_label != null:
		_portrait_label.visible = true
	if _epitaph_label != null:
		_epitaph_label.visible = true

	# SFX + sting
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_memorial_unseal")
	if has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(&"sting_memorial_unseal")


func _apply_unsealed_visuals() -> void:
	if _sealed_slab != null:
		_sealed_slab.visible = false
	if _candle != null:
		var color: Color = _config.get("candle_color", Color.WHITE)
		_candle.light_color = color
		_candle.light_energy = 1.4
		_candle.visible = true
	_apply_portrait_text()
	_apply_epitaph_text()
	if _portrait_mesh != null:
		_portrait_mesh.visible = true
	if _portrait_label != null:
		_portrait_label.visible = true
	if _epitaph_label != null:
		_epitaph_label.visible = true


func _apply_sealed_visuals() -> void:
	if _sealed_slab != null:
		_sealed_slab.visible = true
	if _candle != null:
		_candle.visible = false
	if _portrait_mesh != null:
		_portrait_mesh.visible = false
	if _portrait_label != null:
		_portrait_label.visible = false
	if _epitaph_label != null:
		_epitaph_label.visible = false


# === LABEL CONTENT ===

func _apply_portrait_text() -> void:
	if _portrait_label == null:
		return
	_portrait_label.text = "#%d\n%s" % [
		int(_config.get("iteration_number", 0)),
		_config.get("globbler_name", ""),
	]
	_portrait_label.modulate = _config.get("candle_color", Color.WHITE)


func _apply_epitaph_text() -> void:
	if _epitaph_label == null:
		return
	_epitaph_label.text = "\"%s\"\n— %s" % [
		_config.get("epitaph", ""),
		_config.get("final_date", ""),
	]


# === INTERACTION ===

func interact() -> bool:
	if not _player_in_range or _is_sealed:
		return false
	var paragraph: String = _config.get("lore_paragraph", "")
	if paragraph == "":
		return false

	if has_node("/root/DialogueManager"):
		var dm: Node = get_node("/root/DialogueManager")
		if dm.has_method("show_long_form"):
			dm.show_long_form(_config.get("globbler_name", ""), paragraph)
		elif dm.has_method("show_line"):
			dm.show_line(_config.get("globbler_name", ""), paragraph, &"voice_narrator_soft")

	player_read.emit()
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("memorial_plaque_read"):
			bus.emit_signal("memorial_plaque_read", plaque_id)
	return true


# === EVENTS ===

func _on_iteration_cleared(_iter: int) -> void:
	_evaluate_seal_state()


func _on_player_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = true


func _on_player_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false


# === HELPERS ===

func _get_iterations_cleared() -> int:
	if not has_node("/root/IterationManager"):
		return 0
	var im: Node = get_node("/root/IterationManager")
	if im.has_method("get_iterations_cleared"):
		return int(im.get_iterations_cleared())
	if "iterations_cleared" in im:
		return int(im.iterations_cleared)
	return 0
