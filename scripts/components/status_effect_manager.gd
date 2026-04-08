class_name StatusEffectManager
extends Node
## Manages active status effects on the parent entity. Ticks effects in _process.

signal effect_applied(effect_name: String)
signal effect_removed(effect_name: String)

var active_effects: Array[Dictionary] = []
var _label: Label3D = null


func _ready() -> void:
	# Create overhead status label — outlined so it reads against any backdrop
	_label = Label3D.new()
	_label.position = Vector3(0, 2.2, 0)
	_label.font_size = 22
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.modulate = Color(0.95, 0.6, 0.3)
	_label.outline_modulate = Color(0, 0, 0, 0.95)
	_label.outline_size = 5
	_label.no_depth_test = true
	_label.fixed_size = true
	_label.pixel_size = 0.0035
	_label.visible = false
	get_parent().add_child.call_deferred(_label)


func _process(delta: float) -> void:
	var owner_entity: Node = get_parent()
	var to_remove: Array[int] = []

	for i: int in active_effects.size():
		var entry: Dictionary = active_effects[i]
		var effect: Resource = entry["effect"] as Resource
		entry["remaining_duration"] -= delta
		entry["tick_timer"] -= delta

		if entry["tick_timer"] <= 0.0:
			entry["tick_timer"] += effect.tick_rate
			_apply_tick(effect, owner_entity)

		if entry["remaining_duration"] <= 0.0:
			to_remove.append(i)

	# Remove expired (reverse order)
	for i: int in range(to_remove.size() - 1, -1, -1):
		var entry: Dictionary = active_effects[to_remove[i]]
		var effect: Resource = entry["effect"] as Resource
		_on_effect_expire(effect, owner_entity)
		active_effects.remove_at(to_remove[i])
		effect_removed.emit(effect.effect_name)

	_update_label()


func apply_effect(effect: Resource) -> void:
	var owner_entity: Node = get_parent()
	# Refresh if same effect already active
	for entry: Dictionary in active_effects:
		var existing: Resource = entry["effect"] as Resource
		if existing.effect_name == effect.effect_name:
			entry["remaining_duration"] = effect.duration
			return

	var entry: Dictionary = {
		"effect": effect,
		"remaining_duration": effect.duration,
		"tick_timer": effect.tick_rate,
	}
	active_effects.append(entry)
	_on_effect_start(effect, owner_entity)
	effect_applied.emit(effect.effect_name)
	_update_label()


func remove_effect(effect_name: String) -> void:
	var owner_entity: Node = get_parent()
	for i: int in active_effects.size():
		var entry: Dictionary = active_effects[i]
		var effect: Resource = entry["effect"] as Resource
		if effect.effect_name == effect_name:
			_on_effect_expire(effect, owner_entity)
			active_effects.remove_at(i)
			effect_removed.emit(effect_name)
			_update_label()
			return


func has_effect(effect_name: String) -> bool:
	for entry: Dictionary in active_effects:
		var effect: Resource = entry["effect"] as Resource
		if effect.effect_name == effect_name:
			return true
	return false


func _apply_tick(effect: Resource, owner_entity: Node) -> void:
	match effect.effect_type:
		"corrupted":
			# DOT — deal potency damage per tick
			var health: Node = owner_entity.get_node_or_null("HealthComponent") as Node
			if health:
				health.take_damage(effect.potency)
		"overclocked":
			# Self-damage per tick
			var health: Node = owner_entity.get_node_or_null("HealthComponent") as Node
			if health:
				health.take_damage(effect.potency * 0.5)
		_:
			pass  # fragmented, throttled, segfault are passive flags


func _on_effect_start(effect: Resource, owner_entity: Node) -> void:
	match effect.effect_type:
		"fragmented":
			owner_entity.set_meta(&"status_fragmented", effect.potency)
		"throttled":
			owner_entity.set_meta(&"status_throttled", effect.potency)
		"overclocked":
			owner_entity.set_meta(&"status_overclocked", effect.potency)
		"segfault":
			owner_entity.set_meta(&"status_segfault", true)


func _on_effect_expire(effect: Resource, owner_entity: Node) -> void:
	match effect.effect_type:
		"fragmented":
			owner_entity.remove_meta(&"status_fragmented")
		"throttled":
			owner_entity.remove_meta(&"status_throttled")
		"overclocked":
			owner_entity.remove_meta(&"status_overclocked")
		"segfault":
			owner_entity.remove_meta(&"status_segfault")


func _update_label() -> void:
	if _label == null:
		return
	if active_effects.is_empty():
		_label.visible = false
		return
	var names: PackedStringArray = PackedStringArray()
	for entry: Dictionary in active_effects:
		var effect: Resource = entry["effect"] as Resource
		names.append(effect.effect_name)
	_label.text = " | ".join(names)
	_label.visible = true
