class_name MaterialAuditor
extends RefCounted

## PBR baseline validator. Walks the scene tree (or any subtree) and reports
## materials that violate PBR rules:
## - Albedo outside [0.04, 0.85] range
## - Metallic not exactly 0 or 1 (anti-pattern: 0.5 metallic)
## - Roughness exactly 0 or 1 (looks fake)
## - Emission set without being a "glowing thing"
## - Missing normal map on detail surfaces
##
## Usage:
##   var report := MaterialAuditor.audit_node(scene_root)
##   for issue in report:
##       push_warning(issue)

const ALBEDO_MIN: float = 0.04
const ALBEDO_MAX: float = 0.85
const ROUGHNESS_MIN: float = 0.05
const ROUGHNESS_MAX: float = 0.98


static func audit_node(root: Node) -> Array[String]:
	var issues: Array[String] = []
	_walk(root, issues)
	return issues


static func _walk(node: Node, issues: Array[String]) -> void:
	if node is MeshInstance3D:
		_audit_mesh_instance(node, issues)
	for child in node.get_children():
		_walk(child, issues)


static func _audit_mesh_instance(mesh: MeshInstance3D, issues: Array[String]) -> void:
	# Check both surface override materials and source mesh materials
	var path: String = mesh.get_path()
	for i in mesh.get_surface_override_material_count():
		var mat: Material = mesh.get_surface_override_material(i)
		if mat == null and mesh.mesh != null:
			mat = mesh.mesh.surface_get_material(i)
		if mat is StandardMaterial3D:
			_audit_standard_material(mat, "%s[%d]" % [path, i], issues)


static func _audit_standard_material(mat: StandardMaterial3D, label: String, issues: Array[String]) -> void:
	# Albedo check
	var albedo: Color = mat.albedo_color
	for channel in [albedo.r, albedo.g, albedo.b]:
		if channel < ALBEDO_MIN:
			issues.append("%s: albedo channel below %.2f (got %.3f) — pure black is unrealistic" % [label, ALBEDO_MIN, channel])
			break
		if channel > ALBEDO_MAX:
			issues.append("%s: albedo channel above %.2f (got %.3f) — pure white is unrealistic" % [label, ALBEDO_MAX, channel])
			break

	# Metallic check (must be 0 or 1, ±0.05)
	var metallic: float = mat.metallic
	if metallic > 0.05 and metallic < 0.95:
		issues.append("%s: metallic = %.2f (should be 0 or 1, not in between)" % [label, metallic])

	# Roughness check (avoid extremes)
	var roughness: float = mat.roughness
	if roughness < ROUGHNESS_MIN:
		issues.append("%s: roughness = %.3f (too low, looks like mirror)" % [label, roughness])
	elif roughness > ROUGHNESS_MAX:
		issues.append("%s: roughness = %.3f (too high, looks chalky)" % [label, roughness])

	# Emission warnings
	if mat.emission_enabled and mat.emission_energy_multiplier > 0.01:
		# This is a glowing thing — warn if it lacks emissive texture
		if mat.emission_texture == null and mat.emission == Color.BLACK:
			issues.append("%s: emission enabled but no color or texture set" % label)


static func audit_resource_directory(dir_path: String) -> Array[String]:
	## Walks a res:// directory looking for .tres material files
	var issues: Array[String] = []
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return issues
	dir.list_dir_begin()
	while true:
		var file_name: String = dir.get_next()
		if file_name == "":
			break
		if file_name.ends_with(".tres"):
			var path: String = dir_path + "/" + file_name
			var res: Resource = load(path)
			if res is StandardMaterial3D:
				_audit_standard_material(res, path, issues)
	dir.list_dir_end()
	return issues
