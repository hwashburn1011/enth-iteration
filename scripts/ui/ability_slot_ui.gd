class_name AbilitySlotUI
extends Control
## Single ability slot display with icon, key label, and cooldown overlay.

@onready var _icon_bg: ColorRect = %IconBG
@onready var _key_label: Label = %KeyLabel
@onready var _cooldown_overlay: ColorRect = %CooldownOverlay
@onready var _name_label: Label = %NameLabel

var _cooldown_duration: float = 0.0
var _cooldown_remaining: float = 0.0
var _on_cooldown: bool = false


func _process(delta: float) -> void:
	if not _on_cooldown:
		return
	_cooldown_remaining -= delta
	if _cooldown_remaining <= 0.0:
		set_ready()
		return
	var ratio: float = _cooldown_remaining / _cooldown_duration
	_cooldown_overlay.anchor_top = 1.0 - ratio
	_cooldown_overlay.visible = true


func set_module(module: Resource, key_number: int) -> void:
	_key_label.text = str(key_number)
	_name_label.text = module.ability_name
	_icon_bg.color = Color(0.3, 0.4, 0.6, 1.0)
	_cooldown_overlay.visible = false
	_on_cooldown = false


func set_empty(key_number: int) -> void:
	_key_label.text = str(key_number)
	_name_label.text = ""
	_icon_bg.color = Color(0.2, 0.2, 0.2, 0.5)
	_cooldown_overlay.visible = false
	_on_cooldown = false


func start_cooldown(duration: float) -> void:
	_cooldown_duration = duration
	_cooldown_remaining = duration
	_on_cooldown = true
	_cooldown_overlay.visible = true
	_cooldown_overlay.anchor_top = 0.0


func set_ready() -> void:
	_on_cooldown = false
	_cooldown_overlay.visible = false
	# Brief flash
	var tween: Tween = create_tween()
	tween.tween_property(_icon_bg, "color", Color(0.6, 0.8, 1.0), 0.1)
	tween.tween_property(_icon_bg, "color", Color(0.3, 0.4, 0.6), 0.2)
