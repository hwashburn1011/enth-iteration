class_name GoldDrops
extends RefCounted
## Post-V1 Epic A #3 — gold currency drop table.
##
## Called by GameManager on enemy_defeated to award gold based on enemy
## type and current iteration. Container gold is a flat bonus.

## Base gold per enemy type. Boss rewards are much higher.
const GOLD_BY_TYPE: Dictionary = {
	"glitch_bug": 3,
	"memory_leak": 4,
	"rogue_process": 5,
	"corrupted_compiler": 50,
}

## Iteration multiplier — gold rewards grow so the economy stays meaningful.
const ITER_MULT: Array[float] = [1.0, 1.0, 1.3, 1.6, 2.0, 2.4, 2.9, 3.5, 4.2]

## Container gold range (min, max).
const CONTAINER_GOLD_MIN: int = 2
const CONTAINER_GOLD_MAX: int = 8


## Returns gold for defeating an enemy at the given iteration.
static func gold_for_enemy(enemy_type: String, iteration: int) -> int:
	var base: int = GOLD_BY_TYPE.get(enemy_type, 3) as int
	var mult: float = ITER_MULT[clampi(iteration, 0, ITER_MULT.size() - 1)]
	return int(ceil(base * mult))


## Returns a random gold amount from a container.
static func gold_for_container() -> int:
	return randi_range(CONTAINER_GOLD_MIN, CONTAINER_GOLD_MAX)
