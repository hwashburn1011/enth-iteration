class_name WildernessStoryTrigger
extends Area3D

## Place at the position of a wilderness story trigger entry. On player
## overlap, asks WildernessStoryManager.try_fire_trigger(trigger_id).
## Self-disables after firing successfully.
##
## Required scene shape:
##   WildernessStoryTrigger (Area3D + this script)
##     CollisionShape3D (SphereShape3D matching trigger_radius)
##
## Configure via the inspector:
##   trigger_id — must match a WildernessStoryTriggerDatabase entry id

@export var trigger_id: StringName = &""

var _attempted: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	collision_layer = 0
	collision_mask = 1 << 0  # Player layer
	monitorable = false


func _on_body_entered(body: Node3D) -> void:
	if _attempted:
		return
	if not body.is_in_group(&"player"):
		return
	if trigger_id == &"":
		push_warning("WildernessStoryTrigger: empty trigger_id at %s" % get_path())
		return
	if not has_node("/root/WildernessStoryManager"):
		return

	var wsm: Node = get_node("/root/WildernessStoryManager")
	# If the trigger has already been fired in a prior visit, give up early
	if wsm.has_method("is_fired") and wsm.is_fired(trigger_id):
		_attempted = true
		queue_free()
		return

	var fired: bool = wsm.try_fire_trigger(trigger_id)
	if fired:
		_attempted = true
		queue_free()
	# If gate failed (e.g., wrong iteration), leave _attempted false so we
	# can re-roll on next overlap. The gate may pass after a return visit.
