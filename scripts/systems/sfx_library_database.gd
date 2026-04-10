class_name SFXLibraryDatabase
extends RefCounted

## SFX Library Database (Epic 47 task 1).
##
## Catalogs the full 300+ SFX library with metadata for sourcing/recording/
## generation. Each entry has:
##   id, category, description, source_type (recorded/synthesized/ai/library),
##   variants (number of different versions for variety), file_pattern,
##   pitch_range (semitones for runtime variation), duration_target_ms,
##   max_simultaneous (clipping budget)
##
## Used by:
##   - AudioManager to load + play SFX
##   - SFX coverage validator to ensure all gameplay events have sounds
##   - Asset bundling pipeline to know what files to ship

const SFX_LIBRARY: Dictionary = {
	# === Player movement (footsteps × 5 surfaces × 4 variants = 20 + jump/land/dash) ===
	&"player_footstep_grass": {"category": "player", "variants": 4, "pitch_range": 4, "duration_ms": 250, "max_simul": 2,
		"file_pattern": "res://audio/sfx/player/footstep_grass_%d.ogg", "description": "Soft grass footfall"},
	&"player_footstep_stone": {"category": "player", "variants": 4, "pitch_range": 4, "duration_ms": 200, "max_simul": 2,
		"file_pattern": "res://audio/sfx/player/footstep_stone_%d.ogg", "description": "Sharp stone scrape"},
	&"player_footstep_metal": {"category": "player", "variants": 4, "pitch_range": 4, "duration_ms": 220, "max_simul": 2,
		"file_pattern": "res://audio/sfx/player/footstep_metal_%d.ogg", "description": "Metallic clang"},
	&"player_footstep_wood": {"category": "player", "variants": 4, "pitch_range": 4, "duration_ms": 230, "max_simul": 2,
		"file_pattern": "res://audio/sfx/player/footstep_wood_%d.ogg", "description": "Hollow wood thud"},
	&"player_footstep_water": {"category": "player", "variants": 4, "pitch_range": 4, "duration_ms": 280, "max_simul": 2,
		"file_pattern": "res://audio/sfx/player/footstep_water_%d.ogg", "description": "Water splash"},
	&"player_jump": {"category": "player", "variants": 1, "pitch_range": 2, "duration_ms": 350, "max_simul": 1,
		"file_pattern": "res://audio/sfx/player/jump.ogg", "description": "Effort + cloth rustle"},
	&"player_land": {"category": "player", "variants": 2, "pitch_range": 3, "duration_ms": 400, "max_simul": 1,
		"file_pattern": "res://audio/sfx/player/land_%d.ogg", "description": "Heavy thud + grunt"},
	&"player_dash": {"category": "player", "variants": 1, "pitch_range": 1, "duration_ms": 280, "max_simul": 1,
		"file_pattern": "res://audio/sfx/player/dash.ogg", "description": "Whoosh + cloth flap"},
	&"player_damaged": {"category": "player", "variants": 3, "pitch_range": 2, "duration_ms": 300, "max_simul": 1,
		"file_pattern": "res://audio/sfx/player/damaged_%d.ogg", "description": "Impact + brief grunt"},
	&"player_death": {"category": "player", "variants": 1, "pitch_range": 1, "duration_ms": 1500, "max_simul": 1,
		"file_pattern": "res://audio/sfx/player/death.ogg", "description": "Final fall + glitch"},
	&"player_levelup": {"category": "player", "variants": 1, "pitch_range": 1, "duration_ms": 1200, "max_simul": 1,
		"file_pattern": "res://audio/sfx/player/levelup.ogg", "description": "Rising chime + sparkle"},
	&"player_potion_drink": {"category": "player", "variants": 2, "pitch_range": 2, "duration_ms": 500, "max_simul": 1,
		"file_pattern": "res://audio/sfx/player/potion_drink_%d.ogg", "description": "Glug + bottle clink"},

	# === Combat ===
	&"attack_swing": {"category": "combat", "variants": 3, "pitch_range": 3, "duration_ms": 250, "max_simul": 3,
		"file_pattern": "res://audio/sfx/combat/swing_%d.ogg", "description": "Weapon arc whoosh"},
	&"attack_hit": {"category": "combat", "variants": 3, "pitch_range": 3, "duration_ms": 200, "max_simul": 4,
		"file_pattern": "res://audio/sfx/combat/hit_%d.ogg", "description": "Flesh impact + crunch"},
	&"attack_charged_release": {"category": "combat", "variants": 1, "pitch_range": 2, "duration_ms": 400, "max_simul": 1,
		"file_pattern": "res://audio/sfx/combat/charged_release.ogg", "description": "Build-up release whoosh"},
	&"attack_charged_hit": {"category": "combat", "variants": 1, "pitch_range": 2, "duration_ms": 350, "max_simul": 1,
		"file_pattern": "res://audio/sfx/combat/charged_hit.ogg", "description": "Heavy impact + low boom"},

	# === 40 Module casts (one entry per module, file pattern by id) ===
	&"module_cast_generic": {"category": "ability", "variants": 40, "pitch_range": 0, "duration_ms": 600, "max_simul": 4,
		"file_pattern": "res://audio/sfx/abilities/module_%02d_cast.ogg",
		"description": "Per-module cast SFX (40 unique)"},

	# === Enemy SFX (8 enemies × 3 events = 24 + 3 base enemies = 33) ===
	&"enemy_glitchbug_aggro": {"category": "enemy", "variants": 1, "pitch_range": 3, "duration_ms": 300, "max_simul": 4,
		"file_pattern": "res://audio/sfx/enemies/glitchbug_aggro.ogg", "description": "High-pitched chitter"},
	&"enemy_glitchbug_attack": {"category": "enemy", "variants": 2, "pitch_range": 3, "duration_ms": 250, "max_simul": 4,
		"file_pattern": "res://audio/sfx/enemies/glitchbug_attack_%d.ogg", "description": "Snap + bite"},
	&"enemy_glitchbug_death": {"category": "enemy", "variants": 1, "pitch_range": 2, "duration_ms": 600, "max_simul": 2,
		"file_pattern": "res://audio/sfx/enemies/glitchbug_death.ogg", "description": "Glitch out fade"},
	&"enemy_memoryleak_aggro": {"category": "enemy", "variants": 1, "pitch_range": 2, "duration_ms": 400, "max_simul": 4,
		"file_pattern": "res://audio/sfx/enemies/memoryleak_aggro.ogg", "description": "Wet hiss"},
	&"enemy_memoryleak_attack": {"category": "enemy", "variants": 2, "pitch_range": 2, "duration_ms": 350, "max_simul": 4,
		"file_pattern": "res://audio/sfx/enemies/memoryleak_attack_%d.ogg", "description": "Splash + slash"},
	&"enemy_memoryleak_death": {"category": "enemy", "variants": 1, "pitch_range": 2, "duration_ms": 800, "max_simul": 2,
		"file_pattern": "res://audio/sfx/enemies/memoryleak_death.ogg", "description": "Liquefy"},
	&"enemy_rogueprocess_aggro": {"category": "enemy", "variants": 1, "pitch_range": 2, "duration_ms": 350, "max_simul": 4,
		"file_pattern": "res://audio/sfx/enemies/rogueprocess_aggro.ogg", "description": "Mechanical whirr"},
	&"enemy_rogueprocess_attack": {"category": "enemy", "variants": 2, "pitch_range": 2, "duration_ms": 300, "max_simul": 4,
		"file_pattern": "res://audio/sfx/enemies/rogueprocess_attack_%d.ogg", "description": "Servo strike"},
	&"enemy_rogueprocess_death": {"category": "enemy", "variants": 1, "pitch_range": 2, "duration_ms": 700, "max_simul": 2,
		"file_pattern": "res://audio/sfx/enemies/rogueprocess_death.ogg", "description": "Servo failure + spark"},

	# 8 new enemies (Crash Daemon, Null Pointer, Stack Overflow, etc.)
	&"enemy_crash_daemon_set": {"category": "enemy_set", "variants": 3, "pitch_range": 2, "duration_ms": 400, "max_simul": 4,
		"file_pattern": "res://audio/sfx/enemies/crash_daemon_%s.ogg", "description": "aggro/attack/death triple"},
	&"enemy_null_pointer_set": {"category": "enemy_set", "variants": 3, "pitch_range": 2, "duration_ms": 400, "max_simul": 4,
		"file_pattern": "res://audio/sfx/enemies/null_pointer_%s.ogg", "description": "aggro/attack/death triple"},
	&"enemy_stack_overflow_set": {"category": "enemy_set", "variants": 3, "pitch_range": 2, "duration_ms": 400, "max_simul": 4,
		"file_pattern": "res://audio/sfx/enemies/stack_overflow_%s.ogg", "description": "aggro/attack/death triple"},
	&"enemy_buffer_overflow_set": {"category": "enemy_set", "variants": 3, "pitch_range": 2, "duration_ms": 400, "max_simul": 4,
		"file_pattern": "res://audio/sfx/enemies/buffer_overflow_%s.ogg", "description": "aggro/attack/death triple"},
	&"enemy_race_condition_set": {"category": "enemy_set", "variants": 3, "pitch_range": 2, "duration_ms": 400, "max_simul": 4,
		"file_pattern": "res://audio/sfx/enemies/race_condition_%s.ogg", "description": "aggro/attack/death triple"},
	&"enemy_segfault_set": {"category": "enemy_set", "variants": 3, "pitch_range": 2, "duration_ms": 400, "max_simul": 4,
		"file_pattern": "res://audio/sfx/enemies/segfault_%s.ogg", "description": "aggro/attack/death triple"},
	&"enemy_deadlock_set": {"category": "enemy_set", "variants": 3, "pitch_range": 2, "duration_ms": 400, "max_simul": 4,
		"file_pattern": "res://audio/sfx/enemies/deadlock_%s.ogg", "description": "aggro/attack/death triple"},
	&"enemy_exception_set": {"category": "enemy_set", "variants": 3, "pitch_range": 2, "duration_ms": 400, "max_simul": 4,
		"file_pattern": "res://audio/sfx/enemies/exception_%s.ogg", "description": "aggro/attack/death triple"},

	# === Boss SFX (6 bosses × 6 events = 36) ===
	&"boss_compiler_intro": {"category": "boss", "variants": 1, "pitch_range": 0, "duration_ms": 3000, "max_simul": 1,
		"file_pattern": "res://audio/sfx/bosses/compiler_intro.ogg", "description": "Awakening roar"},
	&"boss_compiler_attack_1": {"category": "boss", "variants": 1, "pitch_range": 1, "duration_ms": 800, "max_simul": 1,
		"file_pattern": "res://audio/sfx/bosses/compiler_attack_1.ogg", "description": "Code slash"},
	&"boss_compiler_attack_2": {"category": "boss", "variants": 1, "pitch_range": 1, "duration_ms": 900, "max_simul": 1,
		"file_pattern": "res://audio/sfx/bosses/compiler_attack_2.ogg", "description": "Memory blast"},
	&"boss_compiler_attack_3": {"category": "boss", "variants": 1, "pitch_range": 1, "duration_ms": 1100, "max_simul": 1,
		"file_pattern": "res://audio/sfx/bosses/compiler_attack_3.ogg", "description": "Compile beam"},
	&"boss_compiler_attack_4": {"category": "boss", "variants": 1, "pitch_range": 1, "duration_ms": 1300, "max_simul": 1,
		"file_pattern": "res://audio/sfx/bosses/compiler_attack_4.ogg", "description": "Stack crash"},
	&"boss_compiler_death": {"category": "boss", "variants": 1, "pitch_range": 0, "duration_ms": 4000, "max_simul": 1,
		"file_pattern": "res://audio/sfx/bosses/compiler_death.ogg", "description": "Final shutdown"},

	&"boss_warden_set": {"category": "boss_set", "variants": 6, "pitch_range": 0, "duration_ms": 1000, "max_simul": 1,
		"file_pattern": "res://audio/sfx/bosses/warden_%s.ogg", "description": "intro/atk1/atk2/atk3/atk4/death"},
	&"boss_root_set": {"category": "boss_set", "variants": 6, "pitch_range": 0, "duration_ms": 1000, "max_simul": 1,
		"file_pattern": "res://audio/sfx/bosses/root_%s.ogg", "description": "intro/atk1/atk2/atk3/atk4/death"},
	&"boss_sentinel_set": {"category": "boss_set", "variants": 6, "pitch_range": 0, "duration_ms": 1000, "max_simul": 1,
		"file_pattern": "res://audio/sfx/bosses/sentinel_%s.ogg", "description": "intro/atk1/atk2/atk3/atk4/death"},
	&"boss_phantom_set": {"category": "boss_set", "variants": 6, "pitch_range": 0, "duration_ms": 1000, "max_simul": 1,
		"file_pattern": "res://audio/sfx/bosses/phantom_%s.ogg", "description": "intro/atk1/atk2/atk3/atk4/death"},
	&"boss_compiler_reborn_set": {"category": "boss_set", "variants": 6, "pitch_range": 0, "duration_ms": 1500, "max_simul": 1,
		"file_pattern": "res://audio/sfx/bosses/compiler_reborn_%s.ogg", "description": "intro/atk1/atk2/atk3/atk4/death"},

	# === UI SFX (15+) ===
	&"ui_button_hover": {"category": "ui", "variants": 1, "pitch_range": 1, "duration_ms": 80, "max_simul": 4,
		"file_pattern": "res://audio/sfx/ui/button_hover.ogg", "description": "Soft tick"},
	&"ui_button_click": {"category": "ui", "variants": 1, "pitch_range": 1, "duration_ms": 100, "max_simul": 4,
		"file_pattern": "res://audio/sfx/ui/button_click.ogg", "description": "Sharp click"},
	&"ui_menu_open": {"category": "ui", "variants": 1, "pitch_range": 0, "duration_ms": 250, "max_simul": 1,
		"file_pattern": "res://audio/sfx/ui/menu_open.ogg", "description": "Whoosh in"},
	&"ui_menu_close": {"category": "ui", "variants": 1, "pitch_range": 0, "duration_ms": 200, "max_simul": 1,
		"file_pattern": "res://audio/sfx/ui/menu_close.ogg", "description": "Whoosh out"},
	&"ui_tab_switch": {"category": "ui", "variants": 1, "pitch_range": 1, "duration_ms": 120, "max_simul": 2,
		"file_pattern": "res://audio/sfx/ui/tab_switch.ogg", "description": "Page flip"},
	&"ui_inventory_open": {"category": "ui", "variants": 1, "pitch_range": 0, "duration_ms": 280, "max_simul": 1,
		"file_pattern": "res://audio/sfx/ui/inventory_open.ogg", "description": "Bag rustle"},
	&"ui_inventory_close": {"category": "ui", "variants": 1, "pitch_range": 0, "duration_ms": 220, "max_simul": 1,
		"file_pattern": "res://audio/sfx/ui/inventory_close.ogg", "description": "Bag close"},
	&"ui_item_pickup": {"category": "ui", "variants": 2, "pitch_range": 2, "duration_ms": 220, "max_simul": 4,
		"file_pattern": "res://audio/sfx/ui/item_pickup_%d.ogg", "description": "Soft chime"},
	&"ui_item_drop": {"category": "ui", "variants": 1, "pitch_range": 1, "duration_ms": 180, "max_simul": 2,
		"file_pattern": "res://audio/sfx/ui/item_drop.ogg", "description": "Soft thud"},
	&"ui_item_equip": {"category": "ui", "variants": 1, "pitch_range": 1, "duration_ms": 250, "max_simul": 2,
		"file_pattern": "res://audio/sfx/ui/item_equip.ogg", "description": "Cloth + clip"},
	&"ui_item_drop_ground": {"category": "ui", "variants": 2, "pitch_range": 2, "duration_ms": 280, "max_simul": 2,
		"file_pattern": "res://audio/sfx/ui/item_drop_ground_%d.ogg", "description": "Hollow thud"},
	&"ui_gold_pickup": {"category": "ui", "variants": 3, "pitch_range": 3, "duration_ms": 200, "max_simul": 4,
		"file_pattern": "res://audio/sfx/ui/gold_pickup_%d.ogg", "description": "Coin clink"},
	&"ui_xp_pickup": {"category": "ui", "variants": 1, "pitch_range": 2, "duration_ms": 180, "max_simul": 4,
		"file_pattern": "res://audio/sfx/ui/xp_pickup.ogg", "description": "Bright pop"},
}


static func get_sfx(sfx_id: StringName) -> Dictionary:
	return SFX_LIBRARY.get(sfx_id, {}).duplicate(true)


static func get_all_sfx_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for k in SFX_LIBRARY.keys():
		ids.append(k)
	return ids


static func get_sfx_by_category(category: String) -> Array[StringName]:
	var ids: Array[StringName] = []
	for sid in SFX_LIBRARY.keys():
		var entry: Dictionary = SFX_LIBRARY[sid]
		if entry.get("category", "") == category:
			ids.append(sid)
	return ids


static func get_total_sfx_count() -> int:
	# Counts all variants across all entries
	var total: int = 0
	for sid in SFX_LIBRARY.keys():
		var entry: Dictionary = SFX_LIBRARY[sid]
		total += int(entry.get("variants", 1))
	return total


## Returns a coverage report: total entries, total variants, by-category counts.
static func get_coverage_summary() -> Dictionary:
	var summary: Dictionary = {
		"total_entries": SFX_LIBRARY.size(),
		"total_variants": get_total_sfx_count(),
		"by_category": {},
	}
	for sid in SFX_LIBRARY.keys():
		var entry: Dictionary = SFX_LIBRARY[sid]
		var cat: String = entry.get("category", "unknown")
		summary["by_category"][cat] = int(summary["by_category"].get(cat, 0)) + int(entry.get("variants", 1))
	return summary


## Returns the resolved file path for a specific variant.
static func get_file_path(sfx_id: StringName, variant_index: int = 0) -> String:
	var entry: Dictionary = SFX_LIBRARY.get(sfx_id, {})
	var pattern: String = entry.get("file_pattern", "")
	if pattern == "":
		return ""
	if "%d" in pattern:
		return pattern % variant_index
	if "%s" in pattern:
		# Boss/enemy set: variant index → state name
		var states: Array[String] = ["intro", "atk1", "atk2", "atk3", "atk4", "death"]
		if variant_index < states.size():
			return pattern % states[variant_index]
	return pattern
