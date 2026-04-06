class_name RogueProcess
extends EnemyBase
## Fast aggressive enemy — two attack patterns, enrages at low health.

const XP_REWARD: int = 20
const ENRAGE_THRESHOLD: float = 0.3
const ENRAGE_SPEED_MULT: float = 1.5
const ENRAGE_CD_MULT: float = 0.7

var is_enraged: bool = false
var _base_move_speed: float = 6.0


func _ready() -> void:
	super._ready()
	_base_move_speed = move_speed
	health_component.max_health = 25.0
	health_component.current_health = 25.0
	stats_component.base_processing = 7.0
	stats_component.base_bandwidth = 8.0
	stats_component.base_memory = 0.0
	stats_component.base_integrity = 3.0
	health_component.health_changed.connect(_on_health_changed)


func _on_health_changed(current: float, maximum: float) -> void:
	if not is_enraged and current / maximum <= ENRAGE_THRESHOLD and current > 0.0:
		is_enraged = true
		move_speed = _base_move_speed * ENRAGE_SPEED_MULT
		# Visual indicator — blue glow intensifies
		var mesh: MeshInstance3D = model.get_child(0) as MeshInstance3D
		if mesh:
			var mat: StandardMaterial3D = StandardMaterial3D.new()
			mat.albedo_color = Color(0.3, 0.3, 1.0)
			mat.emission_enabled = true
			mat.emission = Color(0.2, 0.2, 1.0)
			mat.emission_energy_multiplier = 2.0
			mesh.material_override = mat


func _on_died() -> void:
	EventBus.enemy_defeated.emit(
		&"rogue_process",
		global_position,
		null
	)
	var death_state: State = state_machine.get_node_or_null("EnemyDeathState") as State
	if death_state:
		state_machine.force_transition_to(death_state)
