class_name VariantBodyUpgrade
extends Node

## Applies BODY-side variant transformations to a parent enemy from an
## EnemyVariant Resource. Distinct from VariantAuraAttachment (which
## composes the surrounding particle/aura signature) — this one
## modifies the enemy's own mesh and material parameters.
##
## Specifically targets the queen/elite visual upgrades from
## epic-04-glitchbug-variant-bible.md knobs 2, 4, and 5:
##   - Knob 2 (body_scale): uniform armature/root scale
##   - Knob 4 (mandible_scale): mandible bone-only scale
##   - Knob 5 (pattern_overlay): spawns the gold trim mesh, etched
##     symbol, frost crystal, etc decoration meshes
##
## Also drives the carapace shader uniforms with the variant's color
## palette so the iridescence + crack pulse + crawling glitch all
## use the variant's identity hues:
##   - crack_color (cyan default → variant.crack_color_a)
##   - crawl_color (magenta default → variant.crack_color_b)
##   - iridescence_color_a/b/c (3-color triangle, defaults work but
##     can be overridden per-variant)
##
## Required scene shape:
##   VariantBodyUpgrade (Node + this script)
##     export variant: EnemyVariant resource
##     export body_root_path: NodePath to the Node3D that should
##       receive the body_scale (typically the armature root)
##     export carapace_mesh_paths: array of MeshInstance3D paths
##       whose ShaderMaterial should receive the variant colors
##     export mandible_bone_names: bones to scale by mandible_scale
##
## Hookup:
##   var body: VariantBodyUpgrade = VariantBodyUpgrade.new()
##   body.variant = preload("res://data/enemies/variants/glitchbug_queen.tres")
##   body.body_root_path = NodePath("Armature_GlitchBug_v2")
##   enemy_root.add_child(body)

@export var variant: EnemyVariant
@export var body_root_path: NodePath
@export var carapace_mesh_paths: Array[NodePath] = []
@export var mandible_bone_names: PackedStringArray = PackedStringArray(["mandible.R", "mandible.L"])
@export var auto_apply_on_ready: bool = true

# Pattern overlay decoration scenes (loaded lazily)
const PATTERN_SCENE_PATHS: Dictionary = {
	&"plate_gold": "res://scenes/effects/decorations/plate_gold_trim.tscn",
	&"symbol":     "res://scenes/effects/decorations/etched_symbol.tscn",
	&"frost":      "res://scenes/effects/decorations/frost_crystals.tscn",
	&"vein":       "res://scenes/effects/decorations/glow_veins.tscn",
	&"stripe":     "res://scenes/effects/decorations/dorsal_stripes.tscn",
	&"spot":       "res://scenes/effects/decorations/dorsal_spots.tscn",
}

var _spawned_decoration: Node
var _original_body_scale: Vector3 = Vector3.ONE


func _ready() -> void:
	if auto_apply_on_ready:
		apply_variant()


func apply_variant() -> void:
	if variant == null:
		push_warning("VariantBodyUpgrade: no variant assigned, skipping")
		return

	_apply_body_scale()
	_apply_mandible_scale()
	_apply_carapace_shader_uniforms()
	_apply_pattern_overlay()


func _apply_body_scale() -> void:
	if variant.body_scale == 1.0:
		return
	var body_root: Node3D = get_node_or_null(body_root_path) as Node3D
	if body_root == null:
		# Auto-find: parent's first Node3D child or the parent itself
		var parent: Node = get_parent()
		if parent is Node3D:
			body_root = parent
	if body_root == null:
		push_warning("VariantBodyUpgrade: no body_root found for scale")
		return
	_original_body_scale = body_root.scale
	body_root.scale = _original_body_scale * variant.body_scale


func _apply_mandible_scale() -> void:
	if variant.mandible_scale == 1.0:
		return
	# Find the armature on the parent or under body_root
	var armature: Skeleton3D = _find_skeleton()
	if armature == null:
		return
	for bone_name: String in mandible_bone_names:
		var bone_idx: int = armature.find_bone(bone_name)
		if bone_idx < 0:
			continue
		# Apply scale to the rest pose offset — this scales the bone
		# without affecting its parent transform chain
		var rest: Transform3D = armature.get_bone_rest(bone_idx)
		var scaled_rest: Transform3D = Transform3D(
			rest.basis.scaled(Vector3.ONE * variant.mandible_scale),
			rest.origin
		)
		# Use bone pose scale instead of rest mutation so it can be
		# reverted cleanly
		armature.set_bone_pose_scale(bone_idx, Vector3.ONE * variant.mandible_scale)


func _find_skeleton() -> Skeleton3D:
	var body_root: Node3D = get_node_or_null(body_root_path) as Node3D
	if body_root == null:
		body_root = get_parent() as Node3D
	if body_root == null:
		return null
	# Walk children for a Skeleton3D
	var stack: Array[Node] = [body_root]
	while stack.size() > 0:
		var node: Node = stack.pop_back()
		if node is Skeleton3D:
			return node
		for child: Node in node.get_children():
			stack.append(child)
	return null


func _apply_carapace_shader_uniforms() -> void:
	# For each carapace mesh, push the variant colors into its ShaderMaterial.
	# Detects shader type by checking which uniforms exist and routes to the
	# right uniform names — supports both enemy_carapace.gdshader (GlitchBug)
	# and gel_refraction.gdshader (MemoryLeak).
	for mesh_path: NodePath in carapace_mesh_paths:
		var mesh: MeshInstance3D = get_node_or_null(mesh_path) as MeshInstance3D
		if mesh == null:
			continue
		var mat: Material = mesh.material_override
		if mat == null and mesh.get_surface_override_material_count() > 0:
			mat = mesh.get_surface_override_material(0)
		if not (mat is ShaderMaterial):
			continue
		var sm: ShaderMaterial = mat as ShaderMaterial
		var shader: Shader = sm.shader
		if shader == null:
			continue
		var shader_path: String = shader.resource_path

		if shader_path.ends_with("enemy_carapace.gdshader"):
			# GlitchBug carapace shader (Epic 04 task 11-12)
			sm.set_shader_parameter("crack_color", variant.crack_color_a)
			sm.set_shader_parameter("crawl_color", variant.crack_color_b)
			if variant.has_pack_leader_aura:
				sm.set_shader_parameter("crack_emission", 4.0)
				sm.set_shader_parameter("crawl_emission_strength", 5.0)

		elif shader_path.ends_with("gel_refraction.gdshader"):
			# MemoryLeak gel shader (Epic 05 tasks 30, 11, 12, 13, 33, 46) —
			# the per-variant glow color set covers tint, internal data, sss,
			# and rim simultaneously so the variant identity is consistent
			# across every visual layer of the gel
			sm.set_shader_parameter("tint_color",
				Color(variant.crack_color_a.r, variant.crack_color_a.g,
					  variant.crack_color_a.b, 1.0))
			sm.set_shader_parameter("internal_data_color", variant.crack_color_b)
			sm.set_shader_parameter("rim_color",
				Vector3(variant.crack_color_b.r, variant.crack_color_b.g,
					    variant.crack_color_b.b))
			sm.set_shader_parameter("sss_color",
				Vector3(variant.crack_color_a.r * 1.4, variant.crack_color_a.g * 1.4,
					    variant.crack_color_a.b * 1.4))
			# Per-variant wobble amplitude override from Epic 05 task 24
			if variant.wobble_amplitude_override > 0.0:
				sm.set_shader_parameter("wobble_amplitude", variant.wobble_amplitude_override)
			# Boost emission for elites + bosses
			if variant.has_pack_leader_aura:
				sm.set_shader_parameter("fresnel_intensity", 2.4)
				sm.set_shader_parameter("internal_data_strength", 0.65)


func _apply_pattern_overlay() -> void:
	if variant.pattern_overlay == &"":
		return
	if not PATTERN_SCENE_PATHS.has(variant.pattern_overlay):
		return
	var scene_path: String = PATTERN_SCENE_PATHS[variant.pattern_overlay]
	# Silent fallback when the decoration scene doesn't exist yet —
	# the variant still works visually via the colors above
	if not ResourceLoader.exists(scene_path):
		return
	var packed: PackedScene = load(scene_path) as PackedScene
	if packed == null:
		return
	_spawned_decoration = packed.instantiate()
	var body_root: Node3D = get_node_or_null(body_root_path) as Node3D
	if body_root == null:
		body_root = get_parent() as Node3D
	if body_root != null:
		body_root.add_child(_spawned_decoration)
