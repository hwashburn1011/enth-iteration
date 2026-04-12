class_name StatusEffectLibrary
extends RefCounted
## Phase 3 #22 — central factory for the V1 status effect roster.
##
## The StatusEffectManager + StatusEffect resource pair has existed
## since gameplay/T22 (long before Phase 3) but no system actually
## constructed the effect resources or routed apply calls. Authoring
## .tres files for each effect was the original plan, but they're
## awkward to keep in sync with the consumer code in damage_calculator
## (which reads `status_fragmented` / `status_overclocked` metas) and
## with the player walk state (which reads `status_throttled`).
##
## Instead, this library exposes one builder per effect. Builders
## return a fresh StatusEffect Resource on every call so multiple
## active instances on different targets stay independent. Tuning
## numbers (potency, duration, tick_rate) live in the consts here so
## a single edit retunes the whole roster — the consumers should NOT
## hard-code these values.
##
## V1 roster (3 effects covering DoT, slow, and amp):
##
##   · CORRUPTED   — DoT, 1.5/s for 4s. Memory Leak signature.
##   · THROTTLED   — 50% movement slow for 2.5s. Glitch Bug signature.
##   · FRAGMENTED  — +30% damage taken for 3s. Rogue Process signature
##                   AND the player's combo finisher (T24 step 3).

const CORRUPTED_TICK_DAMAGE: float = 1.5
const CORRUPTED_DURATION: float = 4.0
const CORRUPTED_TICK_RATE: float = 1.0

const THROTTLED_SLOW_FRAC: float = 0.50  # consumed by player_walk_state
const THROTTLED_DURATION: float = 2.5

const FRAGMENTED_DAMAGE_BONUS: float = 0.30  # consumed by damage_calculator
const FRAGMENTED_DURATION: float = 3.0


static func make_corrupted() -> Resource:
	var s: Resource = load("res://scripts/combat/status_effect.gd").new()
	s.effect_name = "Corrupted"
	s.effect_type = "corrupted"
	s.duration = CORRUPTED_DURATION
	s.tick_rate = CORRUPTED_TICK_RATE
	s.potency = CORRUPTED_TICK_DAMAGE
	return s


static func make_throttled() -> Resource:
	var s: Resource = load("res://scripts/combat/status_effect.gd").new()
	s.effect_name = "Throttled"
	s.effect_type = "throttled"
	s.duration = THROTTLED_DURATION
	s.tick_rate = 1.0  # passive flag, no tick action
	s.potency = THROTTLED_SLOW_FRAC
	return s


static func make_fragmented() -> Resource:
	var s: Resource = load("res://scripts/combat/status_effect.gd").new()
	s.effect_name = "Fragmented"
	s.effect_type = "fragmented"
	s.duration = FRAGMENTED_DURATION
	s.tick_rate = 1.0  # passive flag
	s.potency = FRAGMENTED_DAMAGE_BONUS
	return s


## Resolve a status name (e.g. from a hitbox `apply_status` meta) to
## a fresh StatusEffect resource. Returns null for unknown names so
## callers can no-op silently — this is the routing point the
## hurtbox uses on every confirmed hit.
static func make_by_name(name: StringName) -> Resource:
	match String(name):
		"corrupted":
			return make_corrupted()
		"throttled":
			return make_throttled()
		"fragmented":
			return make_fragmented()
		_:
			return null
