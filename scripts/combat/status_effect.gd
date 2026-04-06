class_name StatusEffect
extends Resource
## Data definition for a timed status effect.

@export var effect_name: String = ""
@export var duration: float = 5.0
@export var tick_rate: float = 1.0
@export var effect_type: String = "corrupted"  # corrupted, fragmented, throttled, overclocked, segfault
@export var potency: float = 1.0
