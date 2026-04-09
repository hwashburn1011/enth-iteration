extends Node
## Watches assets/shaders/ for file changes and forces material reload on
## affected ShaderMaterials in active scenes. Lets the team iterate on shader
## code without restarting the game.
##
## Add as autoload (singleton) in project settings. Polls the shader directory
## every `poll_interval` seconds.

@export var shader_dir: String = "res://assets/shaders/"
@export var poll_interval: float = 1.0
@export var enabled: bool = true

var _file_mtimes: Dictionary = {}  ## path -> last_modified_time
var _timer: float = 0.0


func _ready() -> void:
	if not enabled:
		set_process(false)
		return
	_scan_initial()


func _process(delta: float) -> void:
	_timer += delta
	if _timer < poll_interval:
		return
	_timer = 0.0
	_scan_for_changes()


func _scan_initial() -> void:
	var dir: DirAccess = DirAccess.open(shader_dir)
	if dir == null:
		push_warning("ShaderHotReload: cannot open %s" % shader_dir)
		return
	dir.list_dir_begin()
	while true:
		var file_name: String = dir.get_next()
		if file_name == "":
			break
		if file_name.ends_with(".gdshader"):
			var path: String = shader_dir + file_name
			_file_mtimes[path] = FileAccess.get_modified_time(path)
	dir.list_dir_end()
	print("ShaderHotReload: watching %d shader files" % _file_mtimes.size())


func _scan_for_changes() -> void:
	for path: String in _file_mtimes.keys():
		var current_mtime: int = FileAccess.get_modified_time(path)
		if current_mtime != _file_mtimes[path]:
			_file_mtimes[path] = current_mtime
			_reload_shader(path)


func _reload_shader(path: String) -> void:
	# Force reload of the resource cache
	var shader: Shader = load(path) as Shader
	if shader == null:
		push_warning("ShaderHotReload: failed to reload %s" % path)
		return
	# Walk active scene tree and find ShaderMaterials using this shader
	var root: Node = get_tree().root
	var count: int = _refresh_materials_in_node(root, shader, path)
	print("ShaderHotReload: reloaded %s — refreshed %d materials" % [path.get_file(), count])


func _refresh_materials_in_node(node: Node, shader: Shader, path: String) -> int:
	var count: int = 0
	if node is MeshInstance3D:
		var mi: MeshInstance3D = node
		for i in mi.get_surface_override_material_count():
			var mat: Material = mi.get_surface_override_material(i)
			if mat is ShaderMaterial:
				var sm: ShaderMaterial = mat
				if sm.shader != null and sm.shader.resource_path == path:
					sm.shader = shader  # force re-bind
					count += 1
	for child in node.get_children():
		count += _refresh_materials_in_node(child, shader, path)
	return count
