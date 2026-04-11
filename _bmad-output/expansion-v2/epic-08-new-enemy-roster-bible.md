---
name: Epic 08 — New Enemy Roster Bible (8 enemies)
description: Per-enemy design + concept silhouette + AI behavior brief for the 8 new Epic 08 enemies (Crash Daemon, Null Pointer, Stack Overflow, Race Condition, Deadlock, Buffer Overflow, Phantom Cache, Iteration Echo)
epic: 08
created: 2026-04-09
---

# Epic 08 — New Enemy Roster

## Why this epic exists

The current bestiary is 3 enemies (GlitchBug, MemoryLeak, RogueProcess) plus
the Compiler boss. That's not enough variety for a 5+ hour playthrough — by
floor 2 the player has seen everything. Epic 08 doubles the bestiary to
**8 new enemy types** (11 total enemies), each occupying a different combat
role so the player has to relearn dodge timings constantly.

## Combat role distribution

| Enemy | Range | Speed | Threat | Combat role |
|---|---|---|---|---|
| Crash Daemon | melee | very fast | low-mid | Pressure / charger |
| Null Pointer | ranged | medium | mid | Spike / teleport sniper |
| Stack Overflow | ranged | slow | mid | Area denial column |
| Race Condition | melee | fast | mid | Multiplier (splits) |
| Deadlock | ranged | none | mid-high | Turret / chain anchor |
| Buffer Overflow | melee | medium | high (death) | Suicide bomb |
| Phantom Cache | ranged | medium | low | Loot puzzle |
| Iteration Echo | melee/ranged | matches player | high | Mirror match |

The mix is deliberately unbalanced toward melee threats (4) since the player's
toolkit favors ranged combat — melee enemies force the player to back-pedal
and re-engage instead of camping at distance.

---

## 1. Crash Daemon

### Silhouette
- **Height:** 1.2m (small, low-slung)
- **Body:** Quadruped with a hunched back, low to the ground. Long thin
  forelimbs and even longer rear limbs giving it a coiled-spring profile.
- **Head:** Wide flat skull with a single horizontal LED slit eye that
  glows red when aggroed.
- **Material:** Charred black metal + crimson cracks pulsing in time with
  its breathing. Hot orange "engine vents" along the spine.
- **Distinguishing tell:** It LEANS BACKWARD before each charge — coils
  like a spring. The 0.3-second wind-up before the dash IS the player's
  dodge window.

### AI behavior brief
**Pressure/charger.** Maintains a 6m circling distance until it has a clear
line on the player, then locks into a coiled wind-up pose for 0.3s and
dashes 8m in a straight line. If it hits the player it deals 25 damage +
brief stagger; if it misses it skids past and takes 1.0s to reorient
(exposed window). Cooldown 1.5s between charges.

Multi-Daemon packs are dangerous because they coordinate their charges
from different angles to corner the player. Standard pack size: 3.

### Concept silhouette notes
At 64x64 the Daemon should read as: low coiled body + visible engine vent
glow on the spine + the single red eye slit. Quadruped low-stance is the
species defining trait — never bipedal.

---

## 2. Null Pointer

### Silhouette
- **Height:** 1.6m (humanoid-ish but shifting)
- **Body:** Translucent ghostly figure that's only 50% visible at any
  given moment. Body parts FADE IN AND OUT — the head might be visible
  while the torso is fully transparent.
- **Material:** Pure void black with cyan rim light. The visible parts
  emit cold cyan light from inside.
- **Distinguishing tell:** Just before teleporting, a faint cyan flash
  appears at the destination 0.2s in advance. The player can use that
  flash to guess where it'll appear.

### AI behavior brief
**Spike teleport sniper.** Stays at 12-15m range. Every 4 seconds:
1. Picks a position 8-10m from the player at a random angle
2. Plays the 0.2s cyan flash telegraph at that destination
3. Teleports there
4. Charges a 1.5s ranged shot dealing 35 damage

Counter-play: shoot it during the charge — it can't dodge while charging.
Or close to melee range and break its concentration. Standard solo encounter.

### Concept silhouette notes
At 64x64: humanoid outline with VISIBLE GAPS in the body where parts have
faded. The gap pattern should change between hits so it doesn't read as a
texture decision.

---

## 3. Stack Overflow

### Silhouette
- **Height:** 4.5m (towering — the only enemy that's not Globbler-scale)
- **Body:** A vertical stack of 6-8 cube modules getting progressively
  smaller toward the top. Each cube has a different color tint indicating
  what attack it'll fire next (color rotates over time).
- **Material:** Polished chrome cubes with cyan LED edges. Dark gunmetal
  base anchor.
- **Distinguishing tell:** The TALL columnar silhouette. The player can
  see it from anywhere in the room. The color of its top cube tells the
  player what to expect.

### AI behavior brief
**Area denial column.** Cannot move (rooted to its base). Fires DOWNWARD
attacks from its top cube every 3 seconds. The attack type rotates:
- Red top → AOE blast at player position (1.5s wind-up + circle telegraph)
- Cyan top → Slow-moving column of energy that the player must side-step
- Yellow top → 5 fast projectiles in a fan pattern

Damage 20 per hit. Has very high HP (300%) — meant to be a fixed danger
the player must work around. Killing it removes a major arena hazard.

### Concept silhouette notes
At 64x64: easily recognizable as a tall stack of decreasing-size cubes.
The current top-cube color must be visible.

---

## 4. Race Condition

### Silhouette
- **Height:** 1.0m (small)
- **Body:** Spherical with 4 limbs sprouting at irregular angles. Looks
  like a half-formed creature — limbs in mismatched positions so the
  body always looks "wrong."
- **Material:** Glitchy magenta-and-cyan striping that scrolls across
  the body (RGB channel split shader).
- **Distinguishing tell:** It SHIMMERS — chromatic aberration is visible
  on its outline at all times.

### AI behavior brief
**Multiplier.** When damaged below 50% HP, SPLITS into 2 smaller copies
(50% scale + 50% HP each). Those copies can split again at 25% HP. Final
generation copies can't split further. Maximum 4 simultaneous generations
in a single encounter.

The split moment has 0.5s of invulnerability for the new copies — the
player can't kill them mid-split.

Damage 12 melee, fast charge similar to Crash Daemon but no wind-up
telegraph. Dangerous in groups because killing them creates more.
Standard pack size: 2 (which can become 8).

### Concept silhouette notes
At 64x64: irregular limbs sprouting from a sphere + visible chromatic
aberration on the outline.

---

## 5. Deadlock

### Silhouette
- **Height:** 2.0m
- **Body:** A 4-armed spider-like turret rooted to the ground via heavy
  base. Each arm holds a different attack: 2 chain-launchers + 2
  shield-breakers. Cannot walk.
- **Material:** Dark steel with crimson chain attachments. The chains
  are visible attached to its 4 forearms even when not firing.
- **Distinguishing tell:** Always 4 arms in a wide spread, always
  rooted. The 4 chains hanging from the arms are the silhouette.

### AI behavior brief
**Turret / chain anchor.** Cannot move. Fires CHAIN attacks that lock
onto the player and pull them toward the Deadlock. Once locked, the
chain deals 5 damage/sec while the player drags backward. The chain
breaks when:
- The player runs perpendicular to the chain's direction for 1.5s, OR
- The player lands a melee hit on the Deadlock (which requires being
  within chain range — risky)

In a group, multiple Deadlocks can chain the player simultaneously,
making escape impossible. Standard encounter: solo or paired with
other range-restricted threats.

### Concept silhouette notes
At 64x64: 4-armed wide spider stance + visible chains hanging.

---

## 6. Buffer Overflow

### Silhouette
- **Height:** 1.8m starting → 3.5m at peak inflation
- **Body:** A round bloated sphere with thin spider legs. As it takes
  damage or gets close to the player, it INFLATES — the body grows
  larger with visible cracks expanding across the surface.
- **Material:** Sickly green-yellow with magenta crack lines.
- **Distinguishing tell:** It GROWS visibly. The player can see it
  inflating in real time.

### AI behavior brief
**Suicide bomb.** Walks slowly toward the player. As it approaches, it
inflates. When fully inflated (or killed) it EXPLODES dealing 60 damage
in a 5m radius. The explosion does NOT trigger an animation — the
player sees only the size + the cracks growing as the warning.

The 5m blast radius means the player must kill it from at least 6m
away OR run away from it before triggering the explosion. Counter-play:
shoot it from range until it pops at a safe distance.

### Concept silhouette notes
At 64x64: bloated sphere body + thin legs + visible cracks. The size
should clearly grow over its lifetime.

---

## 7. Phantom Cache

### Silhouette
- **Height:** 1.4m
- **Body:** A floating treasure chest with 4 thin spider legs dangling
  beneath. The chest has a gold rim and a glowing keyhole.
- **Material:** Polished gold + cyan glow from the keyhole. Translucent
  ghost shimmer over the body so it reads as "not fully here."
- **Distinguishing tell:** It LOOKS LIKE LOOT but moves on its own. The
  legs are the only "wrong" tell.

### AI behavior brief
**Loot puzzle.** Doesn't attack. RUNS AWAY from the player at 90% of
player speed. If killed within 8 seconds of first detection, drops
3x normal loot + a guaranteed rare item. If it escapes (outruns the
player off-screen) it disappears with the loot.

The "puzzle" is whether to chase it (and abandon other threats) or
focus on real combat. Cannot be slowed. Cannot be one-shot. Has
moderate HP so a 4-5 hit burst is needed.

### Concept silhouette notes
At 64x64: floating chest with dangling legs. Should look INVITING to
shoot at, not threatening — that's the trap (it leads players away
from the safer fight area).

---

## 8. Iteration Echo

### Silhouette
- **Height:** Matches Globbler exactly (1.5m)
- **Body:** A perfect outline of Globbler but with all features inverted
  to monochrome. Black where Globbler is colored, glowing cyan where
  Globbler is metallic. Same proportions, same posing — uses the player
  skeleton.
- **Material:** Pure black with cyan rim light. Code rivulets scroll
  across the body where Globbler's accent stripes are.
- **Distinguishing tell:** It IS Globbler's silhouette. There is no
  visual ambiguity; it's a deliberate mirror.

### AI behavior brief
**Mirror match.** Has access to the player's CURRENT loadout — copies
the player's main attack + dodge. Damage scaled to 60% of player damage.
HP scaled to 75% of player max HP. Uses the player's animation set
(re-targeted to its own skeleton).

Behavior: maintains optimal distance for whatever weapon it has, dodges
in the player's direction with 0.2s reaction delay (slightly slower than
a real player so it CAN be outplayed).

This is the boss-fight-feel encounter — the player has to fight their
own build. Damage scaling is critical: too low and it's trivial, too
high and it's frustrating.

### Concept silhouette notes
At 64x64: identical to Globbler's silhouette but in negative color. The
"oh god it's me" recognition is the species design moment.

---

## Cross-cutting design rules

1. **Each enemy occupies a unique combat role** (see role table above).
   No two enemies tier-up the same skill check.

2. **Each enemy has a single 0.3-1.5s telegraph** that the player can
   learn to dodge. No instant un-dodgeable damage.

3. **Each enemy has a counter-play** that's specific to its tell:
   - Crash Daemon: side-step the dash
   - Null Pointer: shoot during charge
   - Stack Overflow: stand outside its column
   - Race Condition: kill before it splits
   - Deadlock: run perpendicular OR melee it
   - Buffer Overflow: kill it at range OR get away
   - Phantom Cache: chase it within 8s
   - Iteration Echo: outplay your own build

4. **Each enemy has 3 elite variants** (Epic 08 task 25): color + scale
   + buff modifier. The variant Resource pattern from Epic 04-06 reused.

5. **Validation:** all 8 silhouettes must be readable side-by-side at 64x64
   without color cues — Epic 08 task 43.

## Anti-patterns

- **No reskins.** Each enemy must have a UNIQUE silhouette and a UNIQUE
  combat role. Don't ship "Crash Daemon but bigger" as a separate enemy.
- **No cheap one-shots.** Even Buffer Overflow's 60-damage explosion has
  a clear inflation telegraph the player can read.
- **No unwinnable fights.** Multiple Deadlock chains can kill, but the
  perpendicular-run counter is always available.
- **No "can't be melee'd" enemies.** Even Stack Overflow can be approached
  and meleed at its base — the player just has to commit.
