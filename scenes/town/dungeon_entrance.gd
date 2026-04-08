class_name DungeonEntrance
extends Node3D
## Interactable dungeon entrance — shows confirmation UI before starting a run.

const DUNGEON_SCENE_PATH: String = "res://scenes/dungeon/Dungeon.tscn"

var _player_in_range: bool = false
var _confirm_ui: PanelContainer = null

@onready var _interaction_area: Area3D = %InteractionArea
@onready var _label: Label3D = %EntranceLabel


func _ready() -> void:
	_interaction_area.body_entered.connect(_on_body_entered)
	_interaction_area.body_exited.connect(_on_body_exited)
	_label.visible = false
	_build_entrance_visual()


func _build_entrance_visual() -> void:
	# Load portal archway model
	var archway_scene: PackedScene = load("res://assets/models/props/portal_archway.glb") as PackedScene
	if archway_scene:
		var archway: Node3D = archway_scene.instantiate() as Node3D
		add_child(archway)
		archway.position = Vector3.ZERO
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
	dim.color = Color(0, 0, 0, 0.5)
	fullscreen.add_child(dim)

	_confirm_ui = PanelContainer.new()
	_confirm_ui.set_anchors_preset(Control.PRESET_CENTER)
	_confirm_ui.offset_left = -160
	_confirm_ui.offset_top = -70
	_confirm_ui.offset_right = 160
	_confirm_ui.offset_bottom = 70

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override(&"separation", 12)

	var label: Label = Label.new()
	label.text = "Enter the Compaction Loop?"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)

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
