class_name NPCBase
extends CharacterBody3D
## Reusable NPC base with interaction area and dialogue integration.

@export var npc_id: String = ""
@export var npc_name: String = ""
@export var dialogue_resource: Resource
@export var portrait_default: Texture2D
@export var portraits: Dictionary = {}  # expression name -> Texture2D
## R2 F1: if true, opens vendor shop after dialogue ends.
@export var is_vendor: bool = false

var has_been_talked_to: bool = false
var _player_in_range: bool = false

@onready var _interaction_area: Area3D = %InteractionArea
@onready var _name_label: Label3D = %NameLabel
@onready var _prompt_label: Label3D = %PromptLabel
@onready var _model: Node3D = %Model


func _ready() -> void:
	_name_label.text = npc_name
	_style_world_labels()
	_prompt_label.visible = false
	_interaction_area.body_entered.connect(_on_body_entered)
	_interaction_area.body_exited.connect(_on_body_exited)
	_build_npc_visual()
	# Phase 4 #36 — quest/dialogue marker above head
	_create_quest_marker()
	# T55: NPC collision body — player can't overlap NPCs. Uses layer 1
	# (world geometry) so NPCs act as solid obstacles, NOT layer 2 (enemies).
	_add_npc_collision()


func _style_world_labels() -> void:
	## Apply outlined modulate to the in-world Label3D nodes so they pop
	## against any background. Reposition so name and prompt don't overlap.
	if _name_label:
		_name_label.modulate = Color(0.85, 0.95, 1.0)
		_name_label.outline_modulate = Color(0, 0, 0, 0.9)
		_name_label.outline_size = 6
		_name_label.font_size = 28
		_name_label.no_depth_test = true
		_name_label.fixed_size = true
		_name_label.pixel_size = 0.004
		_name_label.position.y = 2.4
	if _prompt_label:
		_prompt_label.modulate = Color(0.4, 0.9, 0.9)
		_prompt_label.outline_modulate = Color(0, 0, 0, 0.9)
		_prompt_label.outline_size = 5
		_prompt_label.font_size = 22
		_prompt_label.no_depth_test = true
		_prompt_label.fixed_size = true
		_prompt_label.pixel_size = 0.004
		_prompt_label.position.y = 1.95


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range:
		return
	if event.is_action_pressed(&"interact"):
		_start_conversation()


var _interact_indicator: Label3D = null
var _indicator_base_y: float = 0.0
## Phase 4 #36 — quest/dialogue marker above the NPC's head.
var _quest_marker: Label3D = null


func _process(_delta: float) -> void:
	# Pulse the interaction indicator
	if _interact_indicator and _interact_indicator.visible:
		_interact_indicator.position.y = _indicator_base_y + sin(Time.get_ticks_msec() * 0.005) * 0.1
	# T98: Interact prompt scale pulse — gentle 1.0→1.1 over 0.5s loop
	if _prompt_label and _prompt_label.visible:
		var pulse: float = 1.0 + sin(Time.get_ticks_msec() * 0.006) * 0.05
		_prompt_label.scale = Vector3(pulse, pulse, pulse)
	# Phase 4 #36 — bob the quest marker gently
	if _quest_marker and _quest_marker.visible:
		_quest_marker.position.y = 2.9 + sin(Time.get_ticks_msec() * 0.004) * 0.12
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
		# R2 F1: open vendor shop after dialogue ends if this is a vendor NPC
		if is_vendor and not EventBus.dialogue_ended.is_connected(_on_vendor_dialogue_ended):
			EventBus.dialogue_ended.connect(_on_vendor_dialogue_ended, CONNECT_ONE_SHOT)
	# Phase 4 #36 — hide quest marker after talking (quest may have progressed)
	_update_quest_marker()


## R2 F1: after vendor dialogue ends, open the VendorShop UI.
func _on_vendor_dialogue_ended() -> void:
	var player_nodes: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if player_nodes.is_empty():
		return
	var player: Node = player_nodes[0]
	var stock_lib: Script = load("res://scripts/systems/vendor_stock.gd") as Script
	if stock_lib == null:
		return
	var iter: int = 1
	if has_node("/root/IterationManager"):
		var im: Node = get_node("/root/IterationManager")
		if im.has_method(&"get_current_iteration"):
			iter = int(im.get_current_iteration())
	var stock: Array[Dictionary] = stock_lib.get_stock_for_iteration(iter)
	var shop_script: GDScript = load("res://scripts/ui/vendor_shop.gd") as GDScript
	if shop_script == null:
		return
	var shop: CanvasLayer = CanvasLayer.new()
	shop.set_script(shop_script)
	get_tree().root.add_child(shop)
	shop.open(stock, player)


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


## Phase 4 #36 — create a floating quest/dialogue marker above the NPC.
## Shows "!" (yellow) if this NPC is referenced in an active quest objective,
## "?" (cyan) if the NPC has dialogue but hasn't been talked to yet.
## Updates after each conversation.
func _create_quest_marker() -> void:
	_quest_marker = Label3D.new()
	_quest_marker.font_size = 64
	_quest_marker.outline_size = 14
	_quest_marker.no_depth_test = true
	_quest_marker.fixed_size = true
	_quest_marker.pixel_size = 0.008
	_quest_marker.position = Vector3(0, 2.9, 0)
	_quest_marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(_quest_marker)
	_update_quest_marker()
	# Re-check when quests update
	if not EventBus.quest_updated.is_connected(_on_quest_updated_marker):
		EventBus.quest_updated.connect(_on_quest_updated_marker)


func _on_quest_updated_marker(_qid: StringName, _status: StringName) -> void:
	_update_quest_marker()


func _update_quest_marker() -> void:
	if _quest_marker == null:
		return
	# Check if any active quest has an objective referencing this NPC's id
	var is_quest_target: bool = false
	for quest: Resource in QuestManager.active_quests:
		if quest.is_completed:
			continue
		for obj: Variant in quest.objectives:
			if obj.current_count >= obj.target_count:
				continue
			# Quest objectives with event_filter matching our npc_id
			if obj.event_filter == npc_id and obj.event_name in [&"npc_talked", &"dialogue_started", &"npc_recruited"]:
				is_quest_target = true
				break
		if is_quest_target:
			break
	if is_quest_target:
		_quest_marker.text = "!"
		_quest_marker.modulate = Color(1.0, 0.85, 0.2)
		_quest_marker.outline_modulate = Color(0.3, 0.2, 0, 0.9)
		_quest_marker.visible = true
	elif dialogue_resource != null and not has_been_talked_to:
		_quest_marker.text = "?"
		_quest_marker.modulate = Color(0.3, 0.9, 0.85)
		_quest_marker.outline_modulate = Color(0, 0.15, 0.15, 0.9)
		_quest_marker.visible = true
	else:
		_quest_marker.visible = false


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
			# R5 fix: swap to R3 sculpted sage (sculpted hood + beard + 10-bone rig)
			model_path = "res://assets/models/characters/sage_r3.glb"
		"cache_sprite":
			model_path = "res://assets/models/characters/npc_cache_sprite_v2.glb"
		"villager_r3":
			# V3 Round 3 sculpted villager (carved face, baked PBR, rigged + idle anim)
			model_path = "res://assets/models/characters/villager_r3.glb"
	if not model_path.is_empty():
		var glb: PackedScene = load(model_path) as PackedScene
		if glb:
			var instance: Node3D = glb.instantiate() as Node3D
			# R5 fix: R3 hero meshes were built at hero render scale (sage
			# is ~5m tall in modeling space, villager ~3m). Game NPCs need
			# ~1.7m. Empirical per-asset scales:
			match npc_id:
				"ai_sage":
					instance.scale = Vector3(0.18, 0.18, 0.18)
				"villager_r3":
					# R5 round-2 fix: villager mesh AABB is only 1.6x1.48x1.2,
					# 0.30 made it 48cm — child-size. Bump to 0.6 → ~0.96m.
					instance.scale = Vector3(0.60, 0.60, 0.60)
				_:
					pass
			_model.add_child(instance)
			# R5 round-2 fix: R3 baked albedos are placeholder UV pads (solid
			# pale color, no character detail) so the sculpts render as
			# featureless blobs. Override material + add procedural eyes so
			# NPCs read as characters. Code polish on existing sculpts.
			_polish_r3_npc(instance, npc_id)
			# Spawn ambient particles + interact indicator (these used to be
			# skipped because of an early return when the model loaded)
			match npc_id:
				"ai_sage":
					_add_wisdom_particles()
				"cache_sprite":
					_add_sprite_sparkles()
			_create_interact_indicator()
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

	# NPC-specific ambient VFX
	match npc_id:
		"ai_sage":
			_add_wisdom_particles()
		"cache_sprite":
			_add_sprite_sparkles()

	_create_interact_indicator()


func _add_npc_collision() -> void:
	## T55: Add a StaticBody3D with CapsuleShape3D so the player bounces off
	## NPC bodies instead of overlapping them. Collision layer 1 = world.
	var body: StaticBody3D = StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var col_shape: CollisionShape3D = CollisionShape3D.new()
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.5
	col_shape.shape = capsule
	col_shape.position = Vector3(0, 0.75, 0)
	body.add_child(col_shape)
	add_child(body)


func _create_interact_indicator() -> void:
	## Interaction indicator (floating !) — sits ABOVE the name/prompt labels
	## so it doesn't crowd them; visible only when player is in range.
	_interact_indicator = Label3D.new()
	_interact_indicator.text = "!"
	_interact_indicator.font_size = 36
	_interact_indicator.modulate = Color(1.0, 0.9, 0.2)
	_interact_indicator.outline_modulate = Color(0, 0, 0, 0.95)
	_interact_indicator.outline_size = 8
	_interact_indicator.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_interact_indicator.no_depth_test = true
	_interact_indicator.fixed_size = true
	_interact_indicator.pixel_size = 0.0035
	_interact_indicator.position = Vector3(0, 2.95, 0)
	_indicator_base_y = 2.95
	_interact_indicator.visible = false
	add_child(_interact_indicator)


func _polish_r3_npc(instance: Node3D, id: String) -> void:
	## Override material on the R3 sculpt's mesh + add eyes so the
	## placeholder-textured sphere reads as a character.
	var body_color: Color
	var emission: Color
	var eye_color: Color
	match id:
		"ai_sage":
			body_color = Color(0.42, 0.32, 0.65)  # purple robe
			emission = Color(0.45, 0.25, 0.7)
			eye_color = Color(0.95, 0.85, 0.4)  # golden gaze
		"villager_r3":
			body_color = Color(0.55, 0.42, 0.3)  # warm brown tunic
			emission = Color(0.3, 0.2, 0.12)
			eye_color = Color(0.9, 0.95, 1.0)
		_:
			body_color = Color(0.5, 0.5, 0.55)
			emission = Color(0.3, 0.3, 0.35)
			eye_color = Color(0.9, 0.9, 1.0)
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = body_color
	body_mat.emission_enabled = true
	body_mat.emission = emission
	body_mat.emission_energy_multiplier = 0.4
	body_mat.roughness = 0.6
	body_mat.metallic = 0.1
	var stack: Array = [instance]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D:
			(n as MeshInstance3D).material_override = body_mat
		for c in n.get_children():
			stack.append(c)
	# Procedural glowing eyes — position derived from the actual mesh AABB
	# so they land on the upper-front of whatever sculpt we're polishing.
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = eye_color
	eye_mat.emission_enabled = true
	eye_mat.emission = eye_color
	eye_mat.emission_energy_multiplier = 2.5
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Find the largest mesh and place eyes as children OF that mesh (so the
	# mesh's own transform offset gets applied automatically). Sculpts often
	# have their geometry offset inside the GLB rather than centered at the
	# instance origin (e.g. sage_hero_lp is at (3.0, 1.4, 0)).
	var biggest_mesh: MeshInstance3D = null
	var biggest_size: float = 0.0
	var stack2: Array = [instance]
	while not stack2.is_empty():
		var n: Node = stack2.pop_back()
		if n is MeshInstance3D and (n as MeshInstance3D).mesh:
			var a: AABB = (n as MeshInstance3D).mesh.get_aabb()
			var s: float = a.size.x * a.size.y * a.size.z
			if s > biggest_size:
				biggest_size = s
				biggest_mesh = n as MeshInstance3D
		for c in n.get_children():
			stack2.append(c)
	if biggest_mesh != null:
		var ab: AABB = biggest_mesh.mesh.get_aabb()
		var center_x: float = ab.position.x + ab.size.x * 0.5
		var top_y: float = ab.position.y + ab.size.y * 0.78
		var front_z: float = ab.position.z + ab.size.z * 0.05
		var x_off: float = ab.size.x * 0.18
		var eye_radius: float = max(ab.size.x, ab.size.y) * 0.07
		for side: float in [-x_off, x_off]:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var em: SphereMesh = SphereMesh.new()
			em.radius = eye_radius
			em.height = eye_radius * 2.0
			em.radial_segments = 12
			em.rings = 6
			eye.mesh = em
			eye.position = Vector3(center_x + side, top_y, front_z)
			eye.material_override = eye_mat
			biggest_mesh.add_child(eye)


func _add_wisdom_particles() -> void:
	## Golden wisdom data particles orbiting the AI Sage
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 12
	particles.lifetime = 3.0
	particles.position = Vector3(0, 1.2, 0)
	var mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 0.5, 0)
	mat.spread = 60.0
	mat.initial_velocity_min = 0.2
	mat.initial_velocity_max = 0.4
	mat.gravity = Vector3(0, 0.1, 0)
	mat.orbit_velocity_min = 0.3
	mat.orbit_velocity_max = 0.6
	mat.color = Color(1.0, 0.85, 0.3, 0.7)
	mat.scale_min = 0.4
	mat.scale_max = 1.0
	particles.process_material = mat
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.025
	mesh.height = 0.05
	particles.draw_pass_1 = mesh
	var vis: StandardMaterial3D = StandardMaterial3D.new()
	vis.albedo_color = Color(1.0, 0.85, 0.3, 0.7)
	vis.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	vis.emission_enabled = true
	vis.emission = Color(1.0, 0.8, 0.2)
	vis.emission_energy_multiplier = 2.5
	vis.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	particles.material_override = vis
	add_child(particles)


func _add_sprite_sparkles() -> void:
	## Teal sparkle trail for Cache Sprite
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 8
	particles.lifetime = 1.5
	particles.position = Vector3(0, 0.8, 0)
	var mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -0.5, 0)
	mat.spread = 90.0
	mat.initial_velocity_min = 0.1
	mat.initial_velocity_max = 0.3
	mat.gravity = Vector3(0, -0.5, 0)
	mat.color = Color(0.3, 0.9, 0.85, 0.5)
	mat.scale_min = 0.3
	mat.scale_max = 0.8
	particles.process_material = mat
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(0.02, 0.02, 0.02)
	particles.draw_pass_1 = mesh
	var vis: StandardMaterial3D = StandardMaterial3D.new()
	vis.albedo_color = Color(0.3, 0.9, 0.85, 0.5)
	vis.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	vis.emission_enabled = true
	vis.emission = Color(0.2, 0.8, 0.75)
	vis.emission_energy_multiplier = 2.0
	vis.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	particles.material_override = vis
	add_child(particles)
