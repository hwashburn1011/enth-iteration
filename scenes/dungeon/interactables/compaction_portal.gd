class_name CompactionPortal
extends Area3D
## Warp portal that sends the player back to town after boss defeat.

const TOWN_SCENE_PATH: String = "res://scenes/town/Town.tscn"
const FLASH_DURATION: float = 0.5

var _player_in_range: bool = false

@onready var _mesh: MeshInstance3D = %PortalMesh
@onready var _label: Label3D = %PortalLabel


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_label.visible = false
	# Sharper "press E" prompt — the original .tscn label is the only
	# text the player ever sees explaining how to close the loop. Make
	# sure it actually says something even if the .tscn label.text drifts.
	if _label.text.strip_edges().is_empty():
		_label.text = "[E] Compact"
	_build_portal_visual()
	# T19: compaction portal spawn-in polish. The portal is the
	# moment-the-loop-closes event — it appears the instant the boss
	# dies. Ship it with a real entrance: shockwave ring, bright flash,
	# audible cue. See _bmad-output/v1-demo-backlog.md Phase 2 #19.
	call_deferred(&"_play_spawn_in_burst")


func _build_portal_visual() -> void:
	# Load the portal archway model
	var archway: PackedScene = load("res://assets/models/props/portal_archway.glb") as PackedScene
	if archway:
		var instance: Node3D = archway.instantiate() as Node3D
		add_child(instance)
		instance.position = Vector3.ZERO
	# Add portal particle swirl
	VFXFactory.spawn_portal_particles(global_position, self)
	# Add a point light for the portal glow
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(0, 1.5, 0)
	light.light_color = Color(0.2, 0.5, 0.8)
	light.light_energy = 2.0
	light.omni_range = 6.0
	add_child(light)


func _play_spawn_in_burst() -> void:
	## Big "the loop is closing" entrance. Expanding cyan shockwave ring,
	## bright flash light pulse, and a portal-activate audio sting cue
	## that survives the moment of spawn. Tween-cleaned, no orphans.
	if not is_inside_tree():
		return
	# Audible sting — reuse the existing portal_activate clip so we don't
	# need a new asset. The activation cue still plays via EventBus on
	# _activate_portal, just slightly later.
	AudioManager.play_sfx("portal_activate")
	var scene_root: Node = get_tree().current_scene
	if scene_root == null:
		return
	# Expanding cyan ring on the ground at the portal base
	var ring: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 0.6
	torus.outer_radius = 0.9
	torus.rings = 16
	torus.ring_segments = 20
	ring.mesh = torus
	ring.scale = Vector3(0.5, 0.5, 0.5)
	var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(0.30, 0.85, 1.0, 0.85)
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(0.35, 0.85, 1.0)
	ring_mat.emission_energy_multiplier = 4.0
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = ring_mat
	scene_root.add_child(ring)
	ring.global_position = global_position + Vector3(0, 0.15, 0)
	var ring_tween: Tween = ring.create_tween()
	ring_tween.tween_property(ring, "scale", Vector3(6.0, 1.0, 6.0), 0.9).set_ease(Tween.EASE_OUT)
	ring_tween.parallel().tween_property(ring_mat, "albedo_color:a", 0.0, 1.1)
	ring_tween.tween_callback(ring.queue_free)
	# Bright flash light that fades over ~1s — wraps the moment of spawn
	# in a wash of cyan so it reads even on a busy room background
	var flash: OmniLight3D = OmniLight3D.new()
	flash.position = Vector3(0, 1.5, 0)
	flash.light_color = Color(0.40, 0.85, 1.0)
	flash.light_energy = 6.0
	flash.omni_range = 12.0
	add_child(flash)
	var flash_tween: Tween = flash.create_tween()
	flash_tween.tween_property(flash, "light_energy", 0.0, 1.0).set_ease(Tween.EASE_IN)
	flash_tween.tween_callback(flash.queue_free)
	# Camera shake on the player camera so the moment registers physically
	var players: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if not players.is_empty():
		var camera: Camera3D = players[0].get_viewport().get_camera_3d()
		if camera and camera.has_method(&"shake"):
			camera.shake(0.18, 5.0)


func _process(delta: float) -> void:
	# Continuous spin and pulse
	if _mesh:
		_mesh.rotate_y(delta * 2.0)
		var pulse: float = 0.8 + sin(Time.get_ticks_msec() * 0.005) * 0.2
		if _mesh.material_override is StandardMaterial3D:
			(_mesh.material_override as StandardMaterial3D).emission_energy_multiplier = pulse


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range:
		return
	if event.is_action_pressed(&"interact"):
		_activate_portal()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = true
		_label.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false
		_label.visible = false


func _activate_portal() -> void:
	set_process_unhandled_input(false)
	EventBus.portal_used.emit()

	# Signal town to position player at return point and reset stats
	GameManager.set_meta(&"town_entry_type", "portal_return")

	# White flash warp effect via a CanvasLayer on the scene root (survives scene change)
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 100
	var overlay: ColorRect = ColorRect.new()
	overlay.color = Color(1, 1, 1, 0)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(overlay)
	get_tree().root.add_child(canvas)

	# Flash to white
	var tween: Tween = canvas.create_tween()
	tween.tween_property(overlay, "color:a", 1.0, FLASH_DURATION)
	await tween.finished

	# Emit returned_to_town BEFORE scene change so GameManager can update state
	EventBus.returned_to_town.emit()

	# Change scene — this frees the portal. Use await so the scene fully loads.
	await GameManager.change_scene_to(TOWN_SCENE_PATH)

	# Fade out the white overlay (canvas is on root, so it survived the scene change)
	if is_instance_valid(canvas):
		await canvas.get_tree().create_timer(0.3).timeout
		var tween2: Tween = canvas.create_tween()
		tween2.tween_property(overlay, "color:a", 0.0, FLASH_DURATION)
		await tween2.finished
		canvas.queue_free()
