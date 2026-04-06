extends RoomBase
## Tutorial: dash through a hazard zone.

var _overlay: TutorialOverlay = null


func _ready() -> void:
	room_type = "corridor"
	is_cleared = true  # Exit always available — just need to reach it
	super._ready()
	_overlay = TutorialOverlay.new()
	_overlay.instruction_text = "Press Space to dash through hazards"
	add_child(_overlay)

	var hazard: Area3D = get_node_or_null("HazardZone") as Area3D
	if hazard:
		hazard.body_entered.connect(_on_hazard_body_entered)


func _on_hazard_body_entered(body: Node3D) -> void:
	if body is Player:
		var p: Player = body as Player
		if not p.is_invulnerable:
			p.health_component.take_damage(5.0)
