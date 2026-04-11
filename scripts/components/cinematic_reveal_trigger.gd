class_name CinematicRevealTrigger
extends Area3D

## Place at a wilderness reveal trigger position. On player overlap,
## asks CinematicRevealManager.try_play(reveal_id) and self-frees on
## success.
##
## Required scene shape:
##   CinematicRevealTrigger (Area3D + this script)
##     CollisionShape3D (SphereShape3D matching trigger_radius)

@export var reveal_id: StringName = &""

var _attempted: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	collision_layer = 0
	collision_mask = 1 << 0
	monitorable = false


func _on_body_entered(body: Node3D) -> void:
	if _attempted:
		return
	if not body.is_in_group(&"player"):
		return
	if reveal_id == &"":
		push_warning("CinematicRevealTrigger: empty reveal_id at %s" % get_path())
		return
	if not has_node("/root/CinematicRevealManager"):
		return
	var crm: Node = get_node("/root/CinematicRevealManager")
	# If already played, don't re-play
	if crm.has_method("is_played") and crm.is_played(reveal_id):
		_attempted = true
		queue_free()
		return
	var ok: bool = crm.try_play(reveal_id)
	if ok:
		_attempted = true
		queue_free()
