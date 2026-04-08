class_name NPCBase
extends CharacterBody3D
## Reusable NPC base with interaction area and dialogue integration.

@export var npc_id: String = ""
@export var npc_name: String = ""
@export var dialogue_resource: Resource
@export var portrait_default: Texture2D
@export var portraits: Dictionary = {}  # expression name -> Texture2D

var has_been_talked_to: bool = false
var _player_in_range: bool = false

@onready var _interaction_area: Area3D = %InteractionArea
@onready var _name_label: Label3D = %NameLabel
@onready var _prompt_label: Label3D = %PromptLabel
@onready var _model: Node3D = %Model


func _ready() -> void:
	_name_label.text = npc_name
	_prompt_label.visible = false
	_interaction_area.body_entered.connect(_on_body_entered)
	_interaction_area.body_exited.connect(_on_body_exited)
	_build_npc_visual()


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range:
		return
	if event.is_action_pressed(&"interact"):
		_start_conversation()


var _interact_indicator: Label3D = null
var _indicator_base_y: float = 0.0


func _process(_delta: float) -> void:
	# Pulse the interaction indicator
	if _interact_indicator and _interact_indicator.visible:
		_interact_indicator.position.y = _indicator_base_y + sin(Time.get_ticks_msec() * 0.005) * 0.1
	# Idle breathing animation on model
	if _model:
		var t: float = Time.get_ticks_msec() * 0.002
		_model.position.y = sin(t) * 0.03  # Gentle vertical bob
		_model.rotation.y = sin(t * 0.7) * 0.02  # Subtle sway


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = true
		_prompt_label.text = "[E] Talk"
		_prompt_label.visible = true
		if _interact_indicator:
			_interact_indicator.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false
		_prompt_label.visible = false
		if _interact_indicator:
			_interact_indicator.visible = false


func _start_conversation() -> void:
	if dialogue_resource == null or dialogue_resource.lines.is_empty():
		return

	has_been_talked_to = true
	EventBus.npc_talked.emit(StringName(npc_id))

	# Find or create DialoguePanel
	var panel: Node = _find_dialogue_panel()
	if panel:
		panel.speaker_portraits = portraits
		panel.speaker_npc_id = npc_id
		panel.start_dialogue(dialogue_resource.lines)


func _find_dialogue_panel() -> Node:
	# Search for existing panel in scene tree
	for node: Node in get_tree().root.get_children():
		if node.has_method(&"start_dialogue"):
			return node as Node
	# Instantiate one
	var scene: PackedScene = load("res://scenes/ui/dialogue/DialoguePanel.tscn") as PackedScene
	if scene:
		var panel: Node = scene.instantiate() as Node
		get_tree().root.add_child(panel)
		return panel
	return null


func _build_npc_visual() -> void:
	if _model == null:
		return
	# Remove the default capsule mesh
	for child: Node in _model.get_children():
		child.queue_free()

	# Try Blender model based on NPC ID
	var model_path: String = ""
	match npc_id:
		"ai_sage":
			model_path = "res://assets/models/characters/npc_ai_sage_v2.glb"
		"cache_sprite":
			model_path = "res://assets/models/characters/npc_cache_sprite_v2.glb"
	if not model_path.is_empty():
		var glb: PackedScene = load(model_path) as PackedScene
		if glb:
			var instance: Node3D = glb.instantiate() as Node3D
			_model.add_child(instance)
			return

	# Fallback: Colors based on NPC ID
	var body_color: Color = Color(0.6, 0.6, 0.65)
	var head_color: Color = Color(0.7, 0.7, 0.75)
	var glow_color: Color = Color(0.5, 0.5, 0.6)
	match npc_id:
		"ai_sage":
			body_color = Color(0.35, 0.25, 0.55)  # Purple robe
			head_color = Color(0.45, 0.35, 0.65)
			glow_color = Color(0.5, 0.3, 0.8)
		"cache_sprite":
			body_color = Color(0.2, 0.7, 0.5)  # Teal
			head_color = Color(0.3, 0.8, 0.6)
			glow_color = Color(0.2, 0.9, 0.6)

	# Body — rounded
	var body_mesh: MeshInstance3D = MeshInstance3D.new()
	var body_sphere: SphereMesh = SphereMesh.new()
	body_sphere.radius = 0.5
	body_sphere.height = 1.0
	body_sphere.radial_segments = 12
	body_sphere.rings = 6
	body_mesh.mesh = body_sphere
	body_mesh.position = Vector3(0, 0.5, 0)
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = body_color
	body_mat.roughness = 0.75
	body_mesh.material_override = body_mat
	_model.add_child(body_mesh)

	# Head
	var head_mesh: MeshInstance3D = MeshInstance3D.new()
	var head_sphere: SphereMesh = SphereMesh.new()
	head_sphere.radius = 0.35
	head_sphere.height = 0.7
	head_sphere.radial_segments = 12
	head_sphere.rings = 6
	head_mesh.mesh = head_sphere
	head_mesh.position = Vector3(0, 1.15, 0)
	var head_mat: StandardMaterial3D = StandardMaterial3D.new()
	head_mat.albedo_color = head_color
	head_mat.roughness = 0.65
	head_mat.emission_enabled = true
	head_mat.emission = glow_color
	head_mat.emission_energy_multiplier = 0.3
	head_mesh.material_override = head_mat
	_model.add_child(head_mesh)

	# Eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.95, 0.95, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.9, 0.95, 1.0)
	eye_mat.emission_energy_multiplier = 1.2
	for side: float in [-0.1, 0.1]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var eye_sphere: SphereMesh = SphereMesh.new()
		eye_sphere.radius = 0.06
		eye_sphere.height = 0.12
		eye.mesh = eye_sphere
		eye.position = Vector3(side, 1.2, -0.28)
		eye.material_override = eye_mat
		_model.add_child(eye)

	# Unique NPC features
	match npc_id:
		"ai_sage":
			# Floating orb above head (wisdom indicator)
			var orb: MeshInstance3D = MeshInstance3D.new()
			var orb_sphere: SphereMesh = SphereMesh.new()
			orb_sphere.radius = 0.12
			orb_sphere.height = 0.24
			orb.mesh = orb_sphere
			orb.position = Vector3(0, 1.7, 0)
			var orb_mat: StandardMaterial3D = StandardMaterial3D.new()
			orb_mat.albedo_color = Color(0.8, 0.6, 1.0)
			orb_mat.emission_enabled = true
			orb_mat.emission = Color(0.7, 0.4, 1.0)
			orb_mat.emission_energy_multiplier = 2.5
			orb.material_override = orb_mat
			_model.add_child(orb)
			# Staff
			var staff: MeshInstance3D = MeshInstance3D.new()
			var staff_mesh: CylinderMesh = CylinderMesh.new()
			staff_mesh.top_radius = 0.03
			staff_mesh.bottom_radius = 0.04
			staff_mesh.height = 1.8
			staff.mesh = staff_mesh
			staff.position = Vector3(0.45, 0.9, 0)
			var staff_mat: StandardMaterial3D = StandardMaterial3D.new()
			staff_mat.albedo_color = Color(0.4, 0.3, 0.2)
			staff.material_override = staff_mat
			_model.add_child(staff)

	# Interaction indicator (floating !) — hidden by default
	_interact_indicator = Label3D.new()
	_interact_indicator.text = "!"
	_interact_indicator.font_size = 42
	_interact_indicator.modulate = Color(1.0, 0.9, 0.2)
	_interact_indicator.outline_modulate = Color(0, 0, 0)
	_interact_indicator.outline_size = 6
	_interact_indicator.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_interact_indicator.position = Vector3(0, 2.2, 0)
	_indicator_base_y = 2.2
	_interact_indicator.visible = false
	add_child(_interact_indicator)
