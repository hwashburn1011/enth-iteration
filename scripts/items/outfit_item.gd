class_name OutfitItem
extends ItemBase

## A wearable visual outfit piece. One per slot (head, chest, hand_R, hand_L,
## boot_R, boot_L). Carries the visual scene plus dye/wear state.

@export var slot: StringName = &""           ## slot_head, slot_chest, etc.
@export var set_id: StringName = &""         ## outfit_initiate, outfit_kernel, etc.
@export var visual_scene: PackedScene        ## the GLB scene to instance under the slot

## Dye system — overrides the primary color of the piece's material at runtime.
## When dye_index is -1, the piece uses its set-defined primary color.
@export var dye_index: int = -1
@export var dye_color: Color = Color.WHITE   ## populated from DYE_PALETTE

## Wear / dirt slider — 0.0 = pristine, 1.0 = max wear. Aesthetic only.
@export var wear: float = 0.0


const DYE_PALETTE: Array[Color] = [
	Color(0.85, 0.20, 0.20),  # crimson
	Color(0.95, 0.55, 0.10),  # orange
	Color(0.95, 0.85, 0.20),  # yellow
	Color(0.40, 0.85, 0.30),  # leaf green
	Color(0.20, 0.70, 0.55),  # teal
	Color(0.30, 0.55, 0.95),  # sky blue
	Color(0.20, 0.30, 0.85),  # royal blue
	Color(0.55, 0.30, 0.85),  # violet
	Color(0.85, 0.40, 0.85),  # magenta
	Color(0.95, 0.85, 0.75),  # ivory
	Color(0.65, 0.55, 0.40),  # tan
	Color(0.35, 0.25, 0.15),  # cocoa
	Color(0.20, 0.20, 0.20),  # charcoal
	Color(0.55, 0.55, 0.55),  # silver
	Color(0.85, 0.85, 0.95),  # white
	Color(0.10, 0.95, 0.85),  # cyan
]


func apply_dye(idx: int) -> void:
	if idx < -1 or idx >= DYE_PALETTE.size():
		push_warning("OutfitItem.apply_dye: invalid dye index %d" % idx)
		return
	dye_index = idx
	if idx == -1:
		dye_color = Color.WHITE
	else:
		dye_color = DYE_PALETTE[idx]


func add_wear(amount: float) -> void:
	wear = clampf(wear + amount, 0.0, 1.0)


func clean() -> void:
	wear = 0.0
