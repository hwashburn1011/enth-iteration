class_name CraftingStation
extends Area3D

## Workshop crafting station. The bible specified 3 stations in the
## crafting workshop hub:
##   - forge   (weapons, armor, modules — handled by RecipeDatabase
##              recipes with station == &"forge")
##   - bench   (modules, accessories — station == &"bench")
##   - shaper  (cosmetics, dye, transmog — station == &"shaper")
##
## All three use the same component; the inspector field selects the
## category. Each station also tracks its own iteration_upgrade_level
## (0..3), which the smith NPC bumps as the player progresses through
## iterations — higher levels reduce material cost (Tier 1 → 5%, Tier
## 2 → 10%, Tier 3 → 15%) and unlock the rare recipe filter so the
## station can show legendary recipes the player has otherwise found
## but can't normally see.
##
## Required scene shape:
##   CraftingStation (Area3D + this script)
##     CollisionShape3D (interact range)
##     [optional] AnvilPivot / BenchPivot / ShaperPivot — pivot for the
##                tool animation when crafting
##     [optional] CraftSparks (GPUParticles3D) — emit on craft

signal craft_started(recipe_id: StringName)
signal craft_completed(recipe_id: StringName, output_id: StringName, output_count: int)
signal craft_failed(reason: StringName)
signal upgrade_level_changed(new_level: int)
signal interaction_blocked(reason: StringName)

const CRAFT_DURATION_S: float = 2.0
const COST_REDUCTION_PER_LEVEL: Array[float] = [0.0, 0.05, 0.10, 0.15]

@export var station_type: StringName = &"forge"  # forge / bench / shaper
@export var max_upgrade_level: int = 3

var _player_in_range: bool = false
var _player_node: Node3D
var _is_crafting: bool = false
var _upgrade_level: int = 0


func _ready() -> void:
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)
	collision_layer = 0
	collision_mask = 1 << 0
	monitorable = false
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("iteration_changed"):
			bus.iteration_changed.connect(_on_iteration_changed)


# === INTERACTION ===

func can_interact() -> bool:
	if not _player_in_range or _is_crafting:
		return false
	return true


func interact() -> bool:
	if not can_interact():
		interaction_blocked.emit(&"not_in_range" if not _player_in_range else &"already_crafting")
		return false
	# Open the crafting UI populated with the player's known recipes
	# for this station
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("crafting_ui_open_requested"):
			bus.emit_signal("crafting_ui_open_requested", station_type, get_craftable_recipes())
	return true


# === RECIPE QUERY ===

func get_craftable_recipes() -> Array:
	## Returns recipes the player knows AND has materials for at this station.
	var known_recipes: Array = _get_player_known_recipes()
	var station_recipes: Array = RecipeDatabase.get_recipes_for_player(known_recipes, station_type)
	var result: Array = []
	for recipe in station_recipes:
		if _player_has_all_ingredients(recipe):
			result.append(recipe)
	return result


func _get_player_known_recipes() -> Array:
	if _player_node == null:
		return []
	var inv: Node = _player_node.get_node_or_null("InventoryComponent")
	if inv != null and inv.has_method("get_known_recipes"):
		return inv.get_known_recipes()
	# Fallback: pull from a CraftingComponent if present
	var craft: Node = _player_node.get_node_or_null("CraftingComponent")
	if craft != null and "known_recipes" in craft:
		return craft.known_recipes
	return []


func _player_has_all_ingredients(recipe: Dictionary) -> bool:
	if _player_node == null:
		return false
	var inv: Node = _player_node.get_node_or_null("InventoryComponent")
	if inv == null:
		return false
	var ing: Dictionary = recipe.get("ing", {})
	var reduction: float = COST_REDUCTION_PER_LEVEL[clampi(_upgrade_level, 0, COST_REDUCTION_PER_LEVEL.size() - 1)]
	for material_id in ing.keys():
		var raw_count: int = int(ing[material_id])
		var actual_count: int = max(1, int(ceil(raw_count * (1.0 - reduction))))
		if not inv.has_method("count_item_id"):
			# Fallback: just check has_item
			if not inv.has_method("has_item_id") or not inv.has_item_id(String(material_id)):
				return false
			continue
		if inv.count_item_id(String(material_id)) < actual_count:
			return false
	return true


# === CRAFTING ===

func craft(recipe_id: StringName) -> bool:
	if _is_crafting:
		craft_failed.emit(&"already_crafting")
		return false

	var recipe: Dictionary = RecipeDatabase.get_recipe(recipe_id)
	if recipe.is_empty():
		craft_failed.emit(&"unknown_recipe")
		return false

	# Station match
	if recipe.get("station", &"") != station_type:
		craft_failed.emit(&"wrong_station")
		return false

	# Player must know the recipe
	var known: Array = _get_player_known_recipes()
	if not known.has(recipe_id):
		craft_failed.emit(&"recipe_not_known")
		return false

	# Ingredient check
	if not _player_has_all_ingredients(recipe):
		craft_failed.emit(&"missing_ingredients")
		return false

	_is_crafting = true
	craft_started.emit(recipe_id)

	# Consume ingredients (cost-reduced)
	_consume_ingredients(recipe)

	# Animation + SFX
	_play_craft_visuals()
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(_sfx_for_station())

	var t: SceneTreeTimer = get_tree().create_timer(CRAFT_DURATION_S)
	t.timeout.connect(_complete_craft.bind(recipe))
	return true


func _complete_craft(recipe: Dictionary) -> void:
	_is_crafting = false
	var output_id: StringName = recipe.get("out", &"")
	var output_count: int = int(recipe.get("out_n", 1))

	if _player_node != null and output_id != &"":
		var inv: Node = _player_node.get_node_or_null("InventoryComponent")
		if inv != null and inv.has_method("add_item_by_id"):
			inv.add_item_by_id(String(output_id), output_count)

	# Sting for rarity ≥ 2 (legendary crafts)
	if int(recipe.get("rarity", 0)) >= 2 and has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(&"sting_legendary_craft")

	craft_completed.emit(recipe.get("id", &""), output_id, output_count)
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("crafting_completed"):
			bus.emit_signal("crafting_completed", recipe.get("id", &""), output_id, output_count)


func _consume_ingredients(recipe: Dictionary) -> void:
	if _player_node == null:
		return
	var inv: Node = _player_node.get_node_or_null("InventoryComponent")
	if inv == null:
		return
	var ing: Dictionary = recipe.get("ing", {})
	var reduction: float = COST_REDUCTION_PER_LEVEL[clampi(_upgrade_level, 0, COST_REDUCTION_PER_LEVEL.size() - 1)]
	for material_id in ing.keys():
		var raw_count: int = int(ing[material_id])
		var actual_count: int = max(1, int(ceil(raw_count * (1.0 - reduction))))
		if inv.has_method("remove_item_by_id"):
			inv.remove_item_by_id(String(material_id), actual_count)


func _play_craft_visuals() -> void:
	# Anvil/bench/shaper pivot wobbles in time with the work
	var pivot_name: String = "%sPivot" % String(station_type).capitalize()
	var pivot: Node3D = get_node_or_null(NodePath(pivot_name)) as Node3D
	if pivot != null:
		var tw: Tween = create_tween()
		tw.tween_property(pivot, "rotation_degrees:x", -8.0, 0.20)
		tw.tween_property(pivot, "rotation_degrees:x", 8.0, 0.30)
		tw.tween_property(pivot, "rotation_degrees:x", 0.0, 0.20)
	var sparks: GPUParticles3D = get_node_or_null(^"CraftSparks") as GPUParticles3D
	if sparks != null:
		sparks.restart()


func _sfx_for_station() -> StringName:
	match station_type:
		&"forge":  return &"sfx_forge_hammer"
		&"bench":  return &"sfx_bench_solder"
		&"shaper": return &"sfx_shaper_chisel"
	return &"sfx_craft_generic"


# === UPGRADE ===

func upgrade() -> bool:
	## Smith NPC calls this when the player progresses through iterations
	## or completes a quest.
	if _upgrade_level >= max_upgrade_level:
		return false
	_upgrade_level += 1
	upgrade_level_changed.emit(_upgrade_level)
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_station_upgrade")
	if has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(&"sting_station_upgrade")
	return true


func get_upgrade_level() -> int:
	return _upgrade_level


func get_cost_reduction() -> float:
	return COST_REDUCTION_PER_LEVEL[clampi(_upgrade_level, 0, COST_REDUCTION_PER_LEVEL.size() - 1)]


# === EVENTS ===

func _on_iteration_changed(new_iteration: int) -> void:
	# Smith bumps each station once every 3 iterations
	# (iteration 3 → upgrade 1, iteration 6 → upgrade 2, iteration 9 → upgrade 3)
	var target: int = clampi(new_iteration / 3, 0, max_upgrade_level)
	while _upgrade_level < target:
		upgrade()


func _on_player_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = true
		_player_node = body


func _on_player_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false
		_player_node = null


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"station_type": String(station_type),
		"upgrade_level": _upgrade_level,
	}


func from_save_data(data: Dictionary) -> void:
	_upgrade_level = int(data.get("upgrade_level", 0))
