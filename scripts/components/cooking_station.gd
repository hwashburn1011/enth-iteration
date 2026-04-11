class_name CookingStation
extends Area3D

## Cache's kitchen interactable. Player walks into range, presses
## interact, and a small cooking UI opens showing the recipes they
## currently know AND can craft (have all ingredients for).
##
## On first interaction, Cache hands the player the starter recipe
## book — the 5 tier-1 recipes from CookingRecipeDatabase. Other
## recipes are learned via story flags or specific events.
##
## Required scene shape:
##   CookingStation (Area3D + this script)
##     CollisionShape3D (BoxShape3D, kitchen island range)
##     [optional] PotPivot (Node3D — wobble animation on cook)
##     [optional] SteamParticles (GPUParticles3D — burst on cook)

signal cook_started(recipe_id: StringName)
signal cook_completed(recipe_id: StringName, meal_id: StringName)
signal cook_failed(reason: StringName)
signal recipes_known_changed(recipe_ids: Array)
signal first_interaction
signal interaction_blocked(reason: StringName)

const COOK_DURATION_S: float = 2.5

var _player_in_range: bool = false
var _player_node: Node3D
var _has_received_starter_book: bool = false
var _known_recipes: Array[StringName] = []
var _is_cooking: bool = false


func _ready() -> void:
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)
	collision_layer = 0
	collision_mask = 1 << 0
	monitorable = false
	# Listen for recipe-unlock-eligible events
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("rare_fish_caught"):
			bus.rare_fish_caught.connect(_on_rare_fish_caught)
		if bus.has_signal("lounge_drink_consumed"):
			bus.lounge_drink_consumed.connect(_on_lounge_drink)
		if bus.has_signal("achievement_progress"):
			pass  # could observe sync_tipped milestones if achievement system exposes it


# === INTERACTION ===

func can_interact() -> bool:
	if not _player_in_range or _is_cooking:
		return false
	return true


func interact() -> bool:
	if not can_interact():
		interaction_blocked.emit(&"not_in_range" if not _player_in_range else &"already_cooking")
		return false

	# First interaction: Cache hands over the starter book
	if not _has_received_starter_book:
		_grant_starter_book()
		first_interaction.emit()
		# Cache speaks her welcome line
		if has_node("/root/DialogueManager"):
			var dm: Node = get_node("/root/DialogueManager")
			if dm.has_method("show_line"):
				dm.show_line("Cache", "First time? Take the book. The recipes are easy. The harder ones you'll find on your own.", &"voice_cache")
		return true

	# Otherwise, request the cooking UI to open with the cookable list
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("cooking_ui_open_requested"):
			bus.emit_signal("cooking_ui_open_requested", get_cookable_recipes())
	return true


# === RECIPE LEARNING ===

func _grant_starter_book() -> void:
	_has_received_starter_book = true
	for recipe_id in CookingRecipeDatabase.get_starter_recipe_ids():
		learn_recipe(recipe_id)


func learn_recipe(recipe_id: StringName) -> bool:
	if _known_recipes.has(recipe_id):
		return false
	if CookingRecipeDatabase.get_recipe(recipe_id).is_empty():
		return false
	_known_recipes.append(recipe_id)
	recipes_known_changed.emit(_known_recipes.duplicate())
	return true


func is_recipe_known(recipe_id: StringName) -> bool:
	return _known_recipes.has(recipe_id)


func get_known_recipes() -> Array[StringName]:
	return _known_recipes.duplicate()


# === COOKING ===

func get_cookable_recipes() -> Array[Dictionary]:
	## Returns the recipes the player knows AND has all ingredients for.
	var result: Array[Dictionary] = []
	for recipe_id in _known_recipes:
		var entry: Dictionary = CookingRecipeDatabase.get_recipe(recipe_id)
		if entry.is_empty():
			continue
		if _player_has_all_ingredients(entry):
			result.append(entry)
	return result


func _player_has_all_ingredients(recipe: Dictionary) -> bool:
	if _player_node == null:
		return false
	var inv: Node = _player_node.get_node_or_null("InventoryComponent")
	if inv == null:
		return false
	for ing in recipe.get("ingredients", []):
		var item_id: StringName = ing.get("item_id", &"")
		var count: int = int(ing.get("count", 1))
		if not inv.has_method("count_item_id"):
			# Fallback: just check has_item_id at all
			if not inv.has_method("has_item_id") or not inv.has_item_id(String(item_id)):
				return false
			continue
		if inv.count_item_id(String(item_id)) < count:
			return false
	return true


func cook(recipe_id: StringName) -> bool:
	if _is_cooking:
		cook_failed.emit(&"already_cooking")
		return false
	if not _known_recipes.has(recipe_id):
		cook_failed.emit(&"recipe_not_known")
		return false
	var recipe: Dictionary = CookingRecipeDatabase.get_recipe(recipe_id)
	if recipe.is_empty():
		cook_failed.emit(&"unknown_recipe")
		return false
	if not _player_has_all_ingredients(recipe):
		cook_failed.emit(&"missing_ingredients")
		return false

	# Once-per-save guard for The Inheritor's Feast
	if recipe.get("once_per_save", false):
		if _has_been_cooked_once(recipe_id):
			cook_failed.emit(&"once_per_save_consumed")
			return false

	_is_cooking = true
	cook_started.emit(recipe_id)

	# Consume ingredients up front
	_consume_ingredients(recipe)

	# Cook animation + sting
	_play_cook_visuals()
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_cooking_pot_bubble")

	# Schedule completion
	var t: SceneTreeTimer = get_tree().create_timer(COOK_DURATION_S)
	t.timeout.connect(_complete_cook.bind(recipe))
	return true


func _complete_cook(recipe: Dictionary) -> void:
	_is_cooking = false
	var produces: Dictionary = recipe.get("produces", {})
	var meal_id: StringName = produces.get("item_id", &"")
	var meal_count: int = int(produces.get("count", 1))

	if _player_node != null and meal_id != &"":
		var inv: Node = _player_node.get_node_or_null("InventoryComponent")
		if inv != null and inv.has_method("add_item_by_id"):
			inv.add_item_by_id(String(meal_id), meal_count)

	# Grant cooking XP via FarmingComponent (which already tracks
	# gathering/cooking on the same level for now)
	if _player_node != null:
		var farm: Node = _player_node.get_node_or_null("FarmingComponent")
		if farm != null and farm.has_method("add_cooking_xp"):
			farm.add_cooking_xp(int(recipe.get("xp_reward", 4)))

	# Tier-3 sting
	if int(recipe.get("tier", 1)) >= 3 and has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(&"sting_signature_meal")

	# Once-per-save guard
	if recipe.get("once_per_save", false):
		_record_one_shot_cook(recipe.get("id", &""))

	cook_completed.emit(recipe.get("id", &""), meal_id)


func _consume_ingredients(recipe: Dictionary) -> void:
	if _player_node == null:
		return
	var inv: Node = _player_node.get_node_or_null("InventoryComponent")
	if inv == null:
		return
	for ing in recipe.get("ingredients", []):
		var item_id: StringName = ing.get("item_id", &"")
		var count: int = int(ing.get("count", 1))
		if inv.has_method("remove_item_by_id"):
			inv.remove_item_by_id(String(item_id), count)


func _play_cook_visuals() -> void:
	var pivot: Node3D = get_node_or_null(^"PotPivot") as Node3D
	if pivot != null:
		var tw: Tween = create_tween()
		tw.tween_property(pivot, "rotation_degrees:z", 6.0, 0.25)
		tw.tween_property(pivot, "rotation_degrees:z", -6.0, 0.5)
		tw.tween_property(pivot, "rotation_degrees:z", 0.0, 0.25)
	var steam: GPUParticles3D = get_node_or_null(^"SteamParticles") as GPUParticles3D
	if steam != null:
		steam.restart()


# === ONCE-PER-SAVE TRACKING ===

var _one_shot_cooked: Array[StringName] = []


func _has_been_cooked_once(recipe_id: StringName) -> bool:
	return _one_shot_cooked.has(recipe_id)


func _record_one_shot_cook(recipe_id: StringName) -> void:
	if not _one_shot_cooked.has(recipe_id):
		_one_shot_cooked.append(recipe_id)


# === EVENT HANDLERS (recipe unlocks via gameplay) ===

func _on_rare_fish_caught(fish_id: StringName) -> void:
	if fish_id == &"voidshark":
		learn_recipe(&"recipe_voidshark_steak")
	elif fish_id == &"compiled_tuna":
		learn_recipe(&"recipe_stage_banger")


func _on_lounge_drink(_drink_id: StringName) -> void:
	# Placeholder hook for future "drink-then-cook" recipe unlocks
	pass


# === EVENTS ===

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
	var k: Array = []
	for r in _known_recipes:
		k.append(String(r))
	var os: Array = []
	for r in _one_shot_cooked:
		os.append(String(r))
	return {
		"has_received_starter_book": _has_received_starter_book,
		"known_recipes": k,
		"one_shot_cooked": os,
	}


func from_save_data(data: Dictionary) -> void:
	_has_received_starter_book = data.get("has_received_starter_book", false)
	_known_recipes.clear()
	for s in data.get("known_recipes", []):
		_known_recipes.append(StringName(s))
	_one_shot_cooked.clear()
	for s in data.get("one_shot_cooked", []):
		_one_shot_cooked.append(StringName(s))
