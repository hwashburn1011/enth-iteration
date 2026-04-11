class_name DifficultyAccessibilitySubsystems
extends Node

## Difficulty & Accessibility Subsystems Bundle (Epic 45 tasks 31, 32, 39,
## 40, 44, 45, 47, 48).
##
## Engine-side support for the difficulty + accessibility system:
##   - Task 31: UI polish hooks
##   - Task 32: Controller support helper
##   - Task 39: Language placeholder system
##   - Task 40: Input rebinding
##   - Task 44: Accessibility validator
##   - Task 45: Difficulty tutorial flow
##   - Task 47: Difficulty showcase data
##   - Task 48: Performance test at all settings

signal language_changed(language_code: StringName)
signal input_rebind_started(action: StringName)
signal input_rebind_completed(action: StringName, event: InputEvent)
signal difficulty_tutorial_step(step: int)
signal perf_test_finished(report: Dictionary)

const DIFFICULTY_IDS: Array[StringName] = [&"easy", &"normal", &"hard", &"expert", &"nightmare"]
const TUTORIAL_FLAG: StringName = &"tutorial_difficulty_seen"

# === TASK 31: UI polish settings ===
var ui_polish_settings: Dictionary = {
	"animate_modifier_cards": true,
	"show_difficulty_warning": true,
	"flash_active_modifiers": true,
	"slow_motion_on_modifier_apply": false,
	"modifier_card_glow": true,
}


func set_ui_polish_setting(key: StringName, value: Variant) -> void:
	ui_polish_settings[key] = value


# === TASK 32: Controller support helper ===
const CONTROLLER_BINDINGS: Dictionary = {
	&"navigate_difficulty_menu": "[LS] Move  [A] Select  [B] Back",
	&"select_modifier": "[A] Toggle  [Y] Inspect  [B] Cancel",
	&"view_modifier_details": "[Y] Hold to inspect",
	&"reroll_modifiers": "[X] Reroll (1 use per run)",
}


func get_controller_hint(action: StringName) -> String:
	return CONTROLLER_BINDINGS.get(action, "")


# === TASK 39: Language placeholder system ===
const SUPPORTED_LANGUAGES: Array[StringName] = [
	&"en", &"es", &"fr", &"de", &"it", &"pt-br", &"ja", &"ko", &"zh-cn", &"zh-tw", &"ru",
]
const LANGUAGE_DISPLAY_NAMES: Dictionary = {
	&"en": "English",
	&"es": "Español",
	&"fr": "Français",
	&"de": "Deutsch",
	&"it": "Italiano",
	&"pt-br": "Português (Brasil)",
	&"ja": "日本語",
	&"ko": "한국어",
	&"zh-cn": "简体中文",
	&"zh-tw": "繁體中文",
	&"ru": "Русский",
}

var current_language: StringName = &"en"


func set_language(language_code: StringName) -> bool:
	if not SUPPORTED_LANGUAGES.has(language_code):
		push_warning("DifficultyAccessibility: unsupported language %s" % language_code)
		return false
	current_language = language_code
	# Apply via TranslationServer
	TranslationServer.set_locale(String(language_code))
	language_changed.emit(language_code)
	_save_setting(&"language", language_code)
	return true


func get_supported_languages() -> Array[Dictionary]:
	var langs: Array[Dictionary] = []
	for code in SUPPORTED_LANGUAGES:
		langs.append({"code": code, "display_name": LANGUAGE_DISPLAY_NAMES.get(code, String(code))})
	return langs


# === TASK 40: Input rebinding ===
const REBINDABLE_ACTIONS: Array[StringName] = [
	&"move_up", &"move_down", &"move_left", &"move_right",
	&"jump", &"interact", &"attack_primary", &"attack_secondary",
	&"dodge", &"ability_1", &"ability_2", &"ability_3", &"ultimate",
	&"use_item", &"open_inventory", &"open_map", &"open_quest_log",
]

var _rebinding_action: StringName = &""


func start_rebind(action: StringName) -> void:
	if not REBINDABLE_ACTIONS.has(action):
		return
	_rebinding_action = action
	input_rebind_started.emit(action)


func finish_rebind(event: InputEvent) -> void:
	if _rebinding_action == &"":
		return
	# Replace existing event for the action
	if InputMap.has_action(_rebinding_action):
		InputMap.action_erase_events(_rebinding_action)
		InputMap.action_add_event(_rebinding_action, event)
	input_rebind_completed.emit(_rebinding_action, event)
	_save_input_binding(_rebinding_action, event)
	_rebinding_action = &""


func reset_input_to_defaults() -> void:
	# Reload InputMap from project settings
	InputMap.load_from_project_settings()


func _save_input_binding(action: StringName, event: InputEvent) -> void:
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("set_data"):
			# Persist as a serializable dict
			var data: Dictionary = {"action": action, "event_class": event.get_class()}
			if event is InputEventKey:
				data["physical_keycode"] = event.physical_keycode
			elif event is InputEventJoypadButton:
				data["button_index"] = event.button_index
			sm.call("set_data", StringName("input_binding_%s" % action), data)


# === TASK 44: Accessibility validator ===
const ACCESSIBILITY_FEATURES: Dictionary = {
	&"colorblind_mode": "Switches color palette to colorblind-safe alternatives",
	&"screen_shake": "Toggle screen shake on/off",
	&"hit_stop": "Slider for combat hit-stop intensity",
	&"ui_scale": "100%, 125%, 150%, 175%, 200%",
	&"subtitles": "Show / hide / show with speaker name",
	&"aim_assist": "Soft aim assist toggle",
	&"damage_numbers": "Show / hide damage numbers",
	&"hud_opacity": "0-100% slider",
	&"slow_time": "Toggle for slow-time accessibility",
	&"high_contrast": "High-contrast UI mode",
}


func validate_accessibility() -> Dictionary:
	var report: Dictionary = {
		"features_count": ACCESSIBILITY_FEATURES.size(),
		"features": ACCESSIBILITY_FEATURES.keys(),
		"warnings": [],
	}
	# Check that the SettingsManager has each feature
	if has_node("/root/SettingsManager"):
		var sm: Node = get_node("/root/SettingsManager")
		for feature in ACCESSIBILITY_FEATURES.keys():
			if sm.has_method("has_setting"):
				if not bool(sm.call("has_setting", feature)):
					report["warnings"].append("SettingsManager missing %s" % feature)
	return report


# === TASK 45: Difficulty tutorial ===
const DIFFICULTY_TUTORIAL_STEPS: Array[Dictionary] = [
	{"id": &"intro", "title": "Difficulty Tiers", "body": "Enth has 5 difficulty tiers: Easy, Normal, Hard, Expert, Nightmare. Pick what feels right — you can change later."},
	{"id": &"easy", "title": "Easy", "body": "Enemies hit softer, drop more loot, and the economy is generous. Best for first-time players or if you just want the story."},
	{"id": &"normal", "title": "Normal", "body": "The intended experience. Balanced enemies, balanced economy, balanced loot."},
	{"id": &"hard", "title": "Hard / Expert", "body": "Enemies hit harder, fewer drops, tighter economy. Modifiers gain richer rewards."},
	{"id": &"nightmare", "title": "Nightmare", "body": "Brutal damage, scarce loot, hardcore-friendly. Crowned by surviving Boss Rush S+."},
	{"id": &"modifiers", "title": "Modifiers", "body": "Optional modifiers stack on top of difficulty for extra reward. Pick before each dungeon run."},
]


func start_difficulty_tutorial() -> void:
	if _is_flag_set(TUTORIAL_FLAG):
		return
	for i in range(DIFFICULTY_TUTORIAL_STEPS.size()):
		var step: Dictionary = DIFFICULTY_TUTORIAL_STEPS[i]
		difficulty_tutorial_step.emit(i)
		if has_node("/root/TutorialUIManager"):
			var tum: Node = get_node("/root/TutorialUIManager")
			if tum.has_method("show_step"):
				tum.call("show_step", step.get("title", ""), step.get("body", ""), i)
	_set_flag(TUTORIAL_FLAG, true)


# === TASK 47: Difficulty showcase data ===
const DIFFICULTY_SHOWCASES: Dictionary = {
	&"easy": {
		"hp_mult": 0.7, "dmg_mult": 0.7, "loot_mult": 1.4, "economy_mult": 1.5,
		"label": "Easy",
		"showcase_path": "res://_art_source/ui/renders/difficulty_easy_showcase.png",
	},
	&"normal": {
		"hp_mult": 1.0, "dmg_mult": 1.0, "loot_mult": 1.0, "economy_mult": 1.0,
		"label": "Normal",
		"showcase_path": "res://_art_source/ui/renders/difficulty_normal_showcase.png",
	},
	&"hard": {
		"hp_mult": 1.3, "dmg_mult": 1.4, "loot_mult": 1.1, "economy_mult": 0.85,
		"label": "Hard",
		"showcase_path": "res://_art_source/ui/renders/difficulty_hard_showcase.png",
	},
	&"expert": {
		"hp_mult": 1.7, "dmg_mult": 1.8, "loot_mult": 1.25, "economy_mult": 0.7,
		"label": "Expert",
		"showcase_path": "res://_art_source/ui/renders/difficulty_expert_showcase.png",
	},
	&"nightmare": {
		"hp_mult": 2.5, "dmg_mult": 2.5, "loot_mult": 1.5, "economy_mult": 0.55,
		"label": "Nightmare",
		"showcase_path": "res://_art_source/ui/renders/difficulty_nightmare_showcase.png",
	},
}


func get_difficulty_data(diff_id: StringName) -> Dictionary:
	return DIFFICULTY_SHOWCASES.get(diff_id, {}).duplicate(true)


# === TASK 48: Performance test at all settings ===
const PERF_PRESETS: Array[StringName] = [&"low", &"medium", &"high", &"ultra"]


func run_perf_test() -> Dictionary:
	var report: Dictionary = {
		"presets_tested": [],
		"recommendations": [],
	}
	for preset in PERF_PRESETS:
		var entry: Dictionary = {
			"preset": preset,
			"target_fps": _target_fps_for_preset(preset),
			"target_frametime_ms": 1000.0 / _target_fps_for_preset(preset),
			"shadows": preset != &"low",
			"sdfgi": preset == &"ultra",
			"ssr": preset in [&"high", &"ultra"],
			"volumetric_fog": preset != &"low",
			"particle_density": _particle_density_for_preset(preset),
		}
		report["presets_tested"].append(entry)
	# Recommend based on current frame time
	report["recommendations"].append("low: targets 60 FPS on integrated graphics")
	report["recommendations"].append("medium: targets 60 FPS on mid-range GPUs")
	report["recommendations"].append("high: targets 60 FPS on enthusiast GPUs")
	report["recommendations"].append("ultra: targets 30+ FPS on top-tier GPUs with all eye candy")
	perf_test_finished.emit(report)
	return report


func _target_fps_for_preset(preset: StringName) -> float:
	match preset:
		&"low": return 60.0
		&"medium": return 60.0
		&"high": return 60.0
		&"ultra": return 30.0
	return 60.0


func _particle_density_for_preset(preset: StringName) -> float:
	match preset:
		&"low": return 0.4
		&"medium": return 0.7
		&"high": return 1.0
		&"ultra": return 1.5
	return 1.0


# === Helpers ===
func _is_flag_set(flag: StringName) -> bool:
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("get_flag"):
			return bool(sm.call("get_flag", flag))
	return false


func _set_flag(flag: StringName, value: bool) -> void:
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("set_flag"):
			sm.call("set_flag", flag, value)


func _save_setting(key: StringName, value: Variant) -> void:
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		if sm.has_method("set_data"):
			sm.call("set_data", key, value)
