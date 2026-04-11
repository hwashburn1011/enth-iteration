class_name DungeonEntrance
extends Node3D
## Interactable dungeon entrance — shows confirmation UI before starting a run.

const DUNGEON_SCENE_PATH: String = "res://scenes/dungeon/Dungeon.tscn"

var _player_in_range: bool = false
var _confirm_ui: PanelContainer = null

@onready var _interaction_area: Area3D = %InteractionArea
@onready var _label: Label3D = %EntranceLabel


var _swirl_node: Node3D = null


func _ready() -> void:
	_interaction_area.body_entered.connect(_on_body_entered)
	_interaction_area.body_exited.connect(_on_body_exited)
	_label.visible = false
	_build_entrance_visual()
	# Portal swirl rotation tween
	_setup_swirl_rotation()


func _setup_swirl_rotation() -> void:
	# Create a swirl node holding rotating particles
	_swirl_node = Node3D.new()
	_swirl_node.position = Vector3(0, 1.5, 0)
	add_child(_swirl_node)
	# Create 8 small glowing dots in a circle
	for i: int in 8:
		var angle: float = i * TAU / 8.0
		var dot: MeshInstance3D = MeshInstance3D.new()
		var sphere: SphereMesh = SphereMesh.new()
		sphere.radius = 0.04
		sphere.height = 0.08
		dot.mesh = sphere
		dot.position = Vector3(cos(angle) * 0.6, 0, sin(angle) * 0.6)
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color(0.3, 0.6, 1.0, 0.9)
		mat.emission_enabled = true
		mat.emission = Color(0.25, 0.55, 0.95)
		mat.emission_energy_multiplier = 3.0
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		dot.material_override = mat
		_swirl_node.add_child(dot)


func _process(delta: float) -> void:
	if _prompt_cooldown > 0.0:
		pass
	if _swirl_node:
		_swirl_node.rotate_y(delta * 0.8)


var _prompt_cooldown: float = 0.0


func _build_entrance_visual() -> void:
	# R5 round-27 fix: hide the placeholder Archway MeshInstance3D from the
	# .tscn — there's also a portal_archway GLB loaded below, and the two
	# stack visually. The placeholder ships with no material (engine default
	# gray) which the round-27 health survey caught.
	var legacy_archway: MeshInstance3D = get_node_or_null("Archway") as MeshInstance3D
	if legacy_archway:
		legacy_archway.visible = false
	# Load portal archway model
	var archway_scene: PackedScene = load("res://assets/models/props/portal_archway.glb") as PackedScene
	if archway_scene:
		var archway: Node3D = archway_scene.instantiate() as Node3D
		add_child(archway)
		archway.position = Vector3.ZERO
		# Apply digital theme material to the GLB structural meshes
		_apply_archway_textures(archway)
	# Add portal particles (use position since global_position may not be set yet in _ready)
	VFXFactory.spawn_portal_particles(Vector3(0, 1.5, 0), self)
	# Glow light
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(0, 2, 0)
	light.light_color = Color(0.2, 0.4, 0.8)
	light.light_energy = 2.5
	light.omni_range = 8.0
	light.omni_attenuation = 1.5
	add_child(light)

	# Tall beacon pillar visible from spawn — makes entrance findable
	var beacon: MeshInstance3D = MeshInstance3D.new()
	var cyl: CylinderMesh = CylinderMesh.new()
	cyl.top_radius = 0.03
	cyl.bottom_radius = 0.15
	cyl.height = 8.0
	beacon.mesh = cyl
	beacon.position = Vector3(0, 4.0, 0)
	var beacon_mat: StandardMaterial3D = StandardMaterial3D.new()
	beacon_mat.albedo_color = Color(0.15, 0.4, 0.7, 0.3)
	beacon_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beacon_mat.emission_enabled = true
	beacon_mat.emission = Color(0.1, 0.35, 0.65)
	beacon_mat.emission_energy_multiplier = 1.5
	beacon_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beacon.material_override = beacon_mat
	add_child(beacon)

	# Beacon top orb
	var orb: MeshInstance3D = MeshInstance3D.new()
	var orb_mesh: SphereMesh = SphereMesh.new()
	orb_mesh.radius = 0.2
	orb_mesh.height = 0.4
	orb.mesh = orb_mesh
	orb.position = Vector3(0, 8.2, 0)
	var orb_mat: StandardMaterial3D = StandardMaterial3D.new()
	orb_mat.albedo_color = Color(0.2, 0.5, 0.9)
	orb_mat.emission_enabled = true
	orb_mat.emission = Color(0.15, 0.45, 0.85)
	orb_mat.emission_energy_multiplier = 3.0
	orb.material_override = orb_mat
	add_child(orb)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range or _confirm_ui != null:
		return
	if event.is_action_pressed(&"interact"):
		_show_confirmation()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = true
		_label.visible = true
		_play_proximity_burst()
		_pulse_label()


func _pulse_label() -> void:
	if _label == null:
		return
	# Scale pulse to draw attention
	_label.scale = Vector3(0.8, 0.8, 0.8)
	var tween: Tween = _label.create_tween().set_loops(3)
	tween.tween_property(_label, "scale", Vector3(1.1, 1.1, 1.1), 0.4).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_label, "scale", Vector3(0.95, 0.95, 0.95), 0.4).set_ease(Tween.EASE_IN_OUT)


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false
		_label.visible = false


func _show_confirmation() -> void:
	GameManager.set_state(GameManager.GameState.DIALOGUE)

	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 50
	add_child(canvas)

	# Full-screen container so anchors work correctly
	var fullscreen: Control = Control.new()
	fullscreen.set_anchors_preset(Control.PRESET_FULL_RECT)
	fullscreen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(fullscreen)

	# Dim background
	var dim: ColorRect = ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.02, 0.02, 0.06, 0.78)
	fullscreen.add_child(dim)

	_confirm_ui = PanelContainer.new()
	_confirm_ui.set_anchors_preset(Control.PRESET_CENTER)
	_confirm_ui.offset_left = -200
	_confirm_ui.offset_top = -90
	_confirm_ui.offset_right = 200
	_confirm_ui.offset_bottom = 90
	# Sci-fi panel styling
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.06, 0.12, 0.95)
	panel_style.border_color = Color(0.2, 0.55, 0.7, 0.85)
	panel_style.set_border_width_all(2)
	panel_style.border_width_top = 4
	panel_style.set_corner_radius_all(6)
	panel_style.set_content_margin_all(20)
	_confirm_ui.add_theme_stylebox_override(&"panel", panel_style)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override(&"separation", 16)

	var label: Label = Label.new()
	label.text = "Enter the Compaction Loop?"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override(&"font_color", Color(0.3, 0.85, 0.85))
	label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override(&"outline_size", 3)
	label.add_theme_font_size_override(&"font_size", 22)
	vbox.add_child(label)

	var subtitle: Label = Label.new()
	subtitle.text = "Run · Earn · Recompile"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override(&"font_color", Color(0.55, 0.7, 0.78))
	subtitle.add_theme_font_size_override(&"font_size", 13)
	vbox.add_child(subtitle)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override(&"separation", 20)

	var yes_btn: Button = Button.new()
	yes_btn.text = "Yes"
	yes_btn.custom_minimum_size = Vector2(100, 36)
	yes_btn.pressed.connect(_on_yes_pressed.bind(canvas))
	_style_confirm_button(yes_btn, true)
	hbox.add_child(yes_btn)

	var no_btn: Button = Button.new()
	no_btn.text = "No"
	no_btn.custom_minimum_size = Vector2(100, 36)
	no_btn.pressed.connect(_on_no_pressed.bind(canvas))
	_style_confirm_button(no_btn, false)
	hbox.add_child(no_btn)

	vbox.add_child(hbox)
	_confirm_ui.add_child(vbox)
	fullscreen.add_child(_confirm_ui)
	yes_btn.grab_focus()


func _on_yes_pressed(canvas: CanvasLayer) -> void:
	canvas.queue_free()
	_confirm_ui = null
	GameManager.set_state(GameManager.GameState.PLAYING)
	EventBus.dungeon_entered.emit()
	GameManager.change_scene_to(DUNGEON_SCENE_PATH)


func _on_no_pressed(canvas: CanvasLayer) -> void:
	canvas.queue_free()
	_confirm_ui = null
	GameManager.set_state(GameManager.GameState.PLAYING)


func _play_proximity_burst() -> void:
	## Bright burst when player enters portal interaction range
	if not is_inside_tree():
		return
	# Expanding ring on the ground
	var ring: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 0.3
	torus.outer_radius = 0.5
	torus.rings = 16
	torus.ring_segments = 16
	ring.mesh = torus
	ring.scale = Vector3(0.5, 0.5, 0.5)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.6, 1.0, 0.8)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.25, 0.55, 0.95)
	mat.emission_energy_multiplier = 4.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = mat
	get_tree().current_scene.add_child(ring)
	ring.global_position = global_position + Vector3(0, 0.05, 0)
	var tween: Tween = ring.create_tween()
	tween.tween_property(ring, "scale", Vector3(4.0, 1.0, 4.0), 0.6).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.7)
	tween.tween_callback(ring.queue_free)


func _style_confirm_button(btn: Button, is_confirm: bool) -> void:
	var accent: Color = Color(0.2, 0.6, 0.9) if is_confirm else Color(0.5, 0.4, 0.35)
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.1, 0.12, 0.2, 0.9)
	normal.border_color = Color(accent.r * 0.6, accent.g * 0.6, accent.b * 0.6, 0.6)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(4)
	normal.set_content_margin_all(8)
	var hover: StyleBoxFlat = StyleBoxFlat.new()
	hover.bg_color = Color(0.14, 0.16, 0.28, 0.95)
	hover.border_color = accent
	hover.set_border_width_all(2)
	hover.set_corner_radius_all(4)
	hover.set_content_margin_all(8)
	var focus: StyleBoxFlat = hover.duplicate() as StyleBoxFlat
	focus.set_border_width_all(3)
	btn.add_theme_stylebox_override(&"normal", normal)
	btn.add_theme_stylebox_override(&"hover", hover)
	btn.add_theme_stylebox_override(&"focus", focus)
	btn.add_theme_color_override(&"font_color", Color(0.8, 0.85, 0.9))
	btn.add_theme_color_override(&"font_hover_color", accent)
	btn.add_theme_font_size_override(&"font_size", 18)


func _apply_archway_textures(root: Node) -> void:
	## Walk the portal archway mesh tree and override structural meshes with a
	## bluish ancient-stone material. Skip meshes named PortalGlow / Rune* /
	## TopRune* — those are glowing decorative meshes that need to keep their
	## emissive transparent materials.
	var stone_mat: StandardMaterial3D = _make_archway_stone_material()
	var stack: Array = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D:
			var nm: String = n.name
			var is_decorative: bool = (
				nm.contains("Glow")
				or nm.begins_with("Rune")
				or nm.begins_with("TopRune")
			)
			if not is_decorative:
				(n as MeshInstance3D).material_override = stone_mat
		for c in n.get_children():
			stack.append(c)


static func _make_archway_stone_material() -> StandardMaterial3D:
	## Cool blue-gray ancient stone with cellular cracks and faint cyan glow.
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.42, 0.50, 0.62)
	# Albedo: cellular noise mapped to a cool stone gradient
	var stone_noise: FastNoiseLite = FastNoiseLite.new()
	stone_noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	stone_noise.frequency = 0.18
	stone_noise.cellular_distance_function = FastNoiseLite.DISTANCE_EUCLIDEAN
	stone_noise.cellular_return_type = FastNoiseLite.RETURN_DISTANCE
	stone_noise.cellular_jitter = 0.7
	var stone_tex: NoiseTexture2D = NoiseTexture2D.new()
	stone_tex.noise = stone_noise
	stone_tex.width = 512
	stone_tex.height = 512
	stone_tex.seamless = true
	var ramp: Gradient = Gradient.new()
	ramp.set_color(0, Color(0.18, 0.25, 0.35))
	ramp.set_color(1, Color(0.55, 0.65, 0.78))
	ramp.add_point(0.4, Color(0.30, 0.38, 0.50))
	ramp.add_point(0.75, Color(0.45, 0.55, 0.70))
	stone_tex.color_ramp = ramp
	mat.albedo_texture = stone_tex
	# Bumpy normal from chunkier cellular noise
	var bump_noise: FastNoiseLite = FastNoiseLite.new()
	bump_noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	bump_noise.frequency = 0.25
	bump_noise.cellular_distance_function = FastNoiseLite.DISTANCE_MANHATTAN
	bump_noise.cellular_return_type = FastNoiseLite.RETURN_DISTANCE
	bump_noise.cellular_jitter = 0.8
	var bump_tex: NoiseTexture2D = NoiseTexture2D.new()
	bump_tex.noise = bump_noise
	bump_tex.width = 512
	bump_tex.height = 512
	bump_tex.seamless = true
	bump_tex.as_normal_map = true
	bump_tex.bump_strength = 6.0
	mat.normal_enabled = true
	mat.normal_texture = bump_tex
	mat.normal_scale = 1.2
	mat.uv1_triplanar = true
	mat.uv1_scale = Vector3(0.6, 0.6, 0.6)
	mat.metallic = 0.15
	mat.metallic_specular = 0.5
	mat.roughness = 0.7
	# Faint cyan rim glow as if energy is bleeding out of the runes
	mat.emission_enabled = true
	mat.emission = Color(0.10, 0.22, 0.38)
	mat.emission_energy_multiplier = 0.18
	return mat
