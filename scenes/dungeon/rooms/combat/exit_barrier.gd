class_name ExitBarrier
extends StaticBody3D
## Blocks exit until room is cleared, then disappears.

@onready var _mesh: MeshInstance3D = get_child(0) as MeshInstance3D


func open() -> void:
	visible = false
	collision_layer = 0
	collision_mask = 0
	set_physics_process(false)
