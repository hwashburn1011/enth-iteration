class_name AttackTelegraph
extends RefCounted
## Creates visual attack telegraph indicators: ground circles, cones, and lines.
## All telegraphs auto-cleanup after their duration expires.


static func show_circle(position: Vector3, radius: float, duration: float, parent: Node) -> MeshInstance3D:
	## Expanding red circle indicator for AoE attacks.
	var indicator: MeshInstance3D = MeshInstance3D.new()
	var mesh: PlaneMesh = PlaneMesh.new()
	mesh.size = Vector2(radius * 2.0, radius * 2.0)
	indicator.mesh = mesh
	indicator.global_position = position + Vector3(0, 0.05, 0)
	indicator.rotation.x = 0  # Flat on ground

	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.13, 0.0, 0.0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.13, 0.0)
	mat.emission_energy_multiplier = 1.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	indicator.material_override = mat
	parent.add_child(indicator)

	# Animate: fade in while pulsing, then disappear
	indicator.scale = Vector3(0.1, 1.0, 0.1)
	var tween: Tween = indicator.create_tween()
	tween.tween_property(indicator, "scale", Vector3(1.0, 1.0, 1.0), duration * 0.8).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.3, duration * 0.3)
	# Pulse effect
	tween.parallel().tween_property(mat, "emission_energy_multiplier", 3.0, duration * 0.4).set_ease(Tween.EASE_IN)
	tween.tween_property(mat, "albedo_color:a", 0.0, duration * 0.2)
	tween.tween_callback(indicator.queue_free)

	return indicator


static func show_line(origin: Vector3, direction: Vector3, length: float, width: float, duration: float, parent: Node) -> MeshInstance3D:
	## Narrow line indicator for charge/lunge attacks.
	var indicator: MeshInstance3D = MeshInstance3D.new()
	var mesh: PlaneMesh = PlaneMesh.new()
	mesh.size = Vector2(width, length)
	indicator.mesh = mesh
	# Position at midpoint along direction
	var mid: Vector3 = origin + direction.normalized() * (length * 0.5)
	indicator.global_position = mid + Vector3(0, 0.05, 0)
	# Rotate to face direction
	var angle: float = atan2(direction.x, direction.z)
	indicator.rotation = Vector3(0, angle, 0)

	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.13, 0.0, 0.0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.2, 0.0)
	mat.emission_energy_multiplier = 1.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	indicator.material_override = mat
	parent.add_child(indicator)

	# Animate
	var tween: Tween = indicator.create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.3, duration * 0.3)
	tween.parallel().tween_property(mat, "emission_energy_multiplier", 3.0, duration * 0.7).set_ease(Tween.EASE_IN)
	tween.tween_property(mat, "albedo_color:a", 0.0, duration * 0.2)
	tween.tween_callback(indicator.queue_free)

	return indicator


static func show_cone(origin: Vector3, direction: Vector3, radius: float, _angle_deg: float, duration: float, parent: Node) -> MeshInstance3D:
	## Fan-shaped indicator for sweeping/cone attacks.
	## Uses a flattened cylinder segment approximation.
	var indicator: MeshInstance3D = MeshInstance3D.new()
	var mesh: PlaneMesh = PlaneMesh.new()
	mesh.size = Vector2(radius * 2.0, radius)
	indicator.mesh = mesh
	indicator.global_position = origin + direction.normalized() * (radius * 0.4) + Vector3(0, 0.05, 0)
	var face_angle: float = atan2(direction.x, direction.z)
	indicator.rotation = Vector3(0, face_angle, 0)

	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.4, 0.0, 0.0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.3, 0.0)
	mat.emission_energy_multiplier = 1.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	indicator.material_override = mat
	parent.add_child(indicator)

	indicator.scale = Vector3(0.1, 1.0, 0.1)
	var tween: Tween = indicator.create_tween()
	tween.tween_property(indicator, "scale", Vector3(1.0, 1.0, 1.0), duration * 0.6).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.25, duration * 0.3)
	tween.parallel().tween_property(mat, "emission_energy_multiplier", 3.0, duration * 0.7).set_ease(Tween.EASE_IN)
	tween.tween_property(mat, "albedo_color:a", 0.0, duration * 0.2)
	tween.tween_callback(indicator.queue_free)

	return indicator


static func show_charge_glow(mesh_instance: MeshInstance3D, duration: float, color: Color = Color(1.0, 0.13, 0.0)) -> void:
	## Applies a pulsing glow overlay to a mesh during attack wind-up.
	if mesh_instance == null or not is_instance_valid(mesh_instance):
		return
	var original_mat: Material = mesh_instance.material_override
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	if original_mat is StandardMaterial3D:
		glow_mat.albedo_color = (original_mat as StandardMaterial3D).albedo_color
	else:
		glow_mat.albedo_color = color
	glow_mat.emission_enabled = true
	glow_mat.emission = color
	glow_mat.emission_energy_multiplier = 0.0
	mesh_instance.material_override = glow_mat

	var tween: Tween = mesh_instance.create_tween()
	# Pulsing glow that intensifies
	tween.tween_property(glow_mat, "emission_energy_multiplier", 2.0, duration * 0.3)
	tween.tween_property(glow_mat, "emission_energy_multiplier", 1.0, duration * 0.1)
	tween.tween_property(glow_mat, "emission_energy_multiplier", 3.0, duration * 0.3)
	tween.tween_property(glow_mat, "emission_energy_multiplier", 1.5, duration * 0.1)
	tween.tween_property(glow_mat, "emission_energy_multiplier", 4.0, duration * 0.2)
	# Restore original material
	tween.tween_callback(func() -> void:
		if is_instance_valid(mesh_instance):
			mesh_instance.material_override = original_mat
	)
