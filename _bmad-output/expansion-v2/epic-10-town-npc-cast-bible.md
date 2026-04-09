---
name: Epic 10 — Town NPC Cast Bible
description: 12 town NPC briefs + concept silhouettes + per-NPC design knobs for the Town Cast hero asset epic
epic: 10
created: 2026-04-09
---

# Town NPC Cast Bible

## Why this matters

The town is the player's home base. They return after every dungeon
run, and the people there are the difference between "checkpoint hub"
and "place I want to come back to." 12 distinct NPCs each with their
own animation library, dialogue voice, and visual identity.

## Cast cohesion rules

All 12 NPCs share these traits so they look like one community:

1. **Same proportions** as Globbler's chunky humanoid baseline (1.5m
   adults, 1.2m children) — except elder Legacy who is slightly
   stooped and child Bit who is much smaller
2. **Same digital-cloth material story** — clothing has subtle
   structured-data overlays even when the colors are warm
3. **Same eye glow** — all NPCs have a faint cyan eye dot, the
   in-universe "this is a simulated being" tell
4. **Same hover offset of 0** — only the Sage hovers; townsfolk are
   grounded as the player can be
5. **Same animation library budget** — each NPC ships with
   idle + walk + work + 2 emotion reactions = 5 anims minimum

## The 12 NPCs

### NPC 1 — Pixel (Shopkeeper)
- **Role:** Runs the general store. Sells potions, materials, basic gear.
- **Personality:** Friendly, chatty, remembers your last purchase.
- **Look:** Round face, apron over warm-orange tunic, green visor cap.
- **Voice:** Quick, enthusiastic, says "good to see you again!" a lot.
- **Height:** 1.50m
- **Material zones:** Apron (cream), tunic (warm orange), visor (forest green), skin (warm flesh)
- **Work animation:** Restocking shelves / handing items over counter

### NPC 2 — Forge (Blacksmith)
- **Role:** Crafts weapons and armor. Upgrades your gear.
- **Personality:** Gruff, focused, big heart under the soot.
- **Look:** Bulky frame, leather apron over bare chest, soot-streaked face, leather wristbands.
- **Voice:** Slow, deliberate, ends sentences with "...mhm."
- **Height:** 1.65m (slightly taller than baseline)
- **Material zones:** Leather apron (dark brown), skin (tanned with soot), wristbands (dark leather)
- **Work animation:** Hammer striking anvil

### NPC 3 — Cache (Barkeep)
- **Role:** Runs the tavern, dispenses lore and drink.
- **Personality:** Knows everyone, hears everything, never repeats it.
- **Look:** Slim, sharp dressed, suspenders over white shirt, slick-back hair.
- **Voice:** Smooth, low, drops in "the regulars say..." a lot.
- **Height:** 1.55m
- **Material zones:** White shirt, dark vest with cyan pinstripe, dark trousers, slick brown hair
- **Work animation:** Pouring drinks behind the bar

### NPC 4 — Index (Librarian)
- **Role:** Keeps the town's records, teaches Globbler about lore.
- **Personality:** Quiet, precise, lights up when discussing history.
- **Look:** Tall and thin, robes with paper accents, round glasses, hair in a bun.
- **Voice:** Measured, uses long words, occasionally rambles about "page 147 of the third volume..."
- **Height:** 1.55m (slim)
- **Material zones:** Cream robes with paper-fold detail, dark hair, glasses with cyan tint
- **Work animation:** Reading a book + flipping pages

### NPC 5 — Harvest (Farmer)
- **Role:** Grows crops in the town fields, sells produce.
- **Personality:** Salt-of-the-earth, knows the seasons, hates wasted food.
- **Look:** Sturdy build, rolled-up sleeves, straw hat, worn boots.
- **Voice:** Warm and slow, talks about the weather a lot.
- **Height:** 1.55m
- **Material zones:** Faded blue shirt, brown trousers, straw hat, leather boots
- **Work animation:** Tending crops / hoeing soil

### NPC 6 — Bit (Child)
- **Role:** The youngest town resident, plays around the square.
- **Personality:** Curious, runs everywhere, asks endless questions.
- **Look:** Small, round, bright clothes, always running.
- **Voice:** High and excited, mid-sentence topic changes.
- **Height:** 1.20m (child proportions — bigger head relative to body)
- **Material zones:** Bright cyan shirt, yellow shorts, sneakers, messy hair
- **Work animation:** Playing / running in circles

### NPC 7 — Legacy (Elder)
- **Role:** The oldest townsperson, holds the deepest memories.
- **Personality:** Slow, wise, occasional bursts of unexpected humor.
- **Look:** Stooped, long grey braid, walking stick, layered robes.
- **Voice:** Soft and slow, takes long pauses.
- **Height:** 1.55m (slightly stooped — read as 1.50m)
- **Material zones:** Layered grey-and-burgundy robes, long grey braid, weathered walking stick
- **Work animation:** Sitting and storytelling / hand gestures

### NPC 8 — Trade (Merchant)
- **Role:** Traveling merchant, brings rare goods from "outside."
- **Personality:** Slick, deal-making, suspiciously well-traveled.
- **Look:** Long coat with many pockets, leather hat, scrolls in his belt.
- **Voice:** Fast-talking, "I have just the thing for you, friend!"
- **Height:** 1.55m
- **Material zones:** Long brown coat, leather hat, scarf, satchel
- **Work animation:** Counting coins / arranging wares

### NPC 9 — Lab (Scientist)
- **Role:** Studies the simulation, helps Globbler understand his nature.
- **Personality:** Distracted, brilliant, mid-sentence "AH I'VE GOT IT!" moments.
- **Look:** White lab coat over teal shirt, frizzy hair, goggles on forehead.
- **Voice:** Quick bursts of excitement, technical terms.
- **Height:** 1.55m
- **Material zones:** White lab coat, teal shirt, dark trousers, goggles with cyan lens
- **Work animation:** Manipulating glowing lab equipment

### NPC 10 — Render (Artist)
- **Role:** Paints portraits and scenes, captures the town's beauty.
- **Personality:** Dreamy, observant, sees Globbler differently than others.
- **Look:** Smock with paint stains, beret, brush behind ear.
- **Voice:** Soft and reflective, talks about "what I see in you."
- **Height:** 1.50m
- **Material zones:** Cream smock with multicolor paint splatters, magenta beret, dark trousers
- **Work animation:** Painting at an easel

### NPC 11 — Sync (Musician)
- **Role:** Plays music in the square, lifts the town's mood.
- **Personality:** Rhythmic, easygoing, hums mid-conversation.
- **Look:** Loose fit clothes, instrument across back, headphones around neck.
- **Voice:** Lilting, half-singing his lines.
- **Height:** 1.50m
- **Material zones:** Loose purple tunic, dark trousers, instrument (chrome lute), cyan headphones
- **Work animation:** Playing the chrome lute

### NPC 12 — Sentinel (Guard)
- **Role:** Watches the town gates, the silent protector.
- **Personality:** Stoic, formal, breaks character only for important news.
- **Look:** Heavy plate armor, polearm, full helm with cyan visor slit.
- **Voice:** Formal, terse, "All clear, citizen."
- **Height:** 1.65m (tall + bulky armor)
- **Material zones:** Dark steel plate, cyan visor slit, polearm with chrome head
- **Work animation:** Standing guard / slow patrol

## Per-NPC design knobs (parameterized for the pipeline)

| NPC | Height | Body width | Head scale | Primary color | Accent color | Hat/headgear |
|---|---|---|---|---|---|---|
| Pixel | 1.50m | 1.05x | 1.0x | warm orange | cream apron | green visor |
| Forge | 1.65m | 1.20x | 1.0x | dark brown leather | tanned skin | none |
| Cache | 1.55m | 0.95x | 1.0x | white shirt | dark vest cyan stripe | none (slick hair) |
| Index | 1.55m | 0.85x | 1.0x | cream robes | paper white | bun hair |
| Harvest | 1.55m | 1.10x | 1.0x | faded blue | brown trousers | straw hat |
| Bit | 1.20m | 0.90x | 1.30x | bright cyan | yellow shorts | none |
| Legacy | 1.50m | 0.95x | 1.0x | grey burgundy | grey hair | walking stick prop |
| Trade | 1.55m | 1.05x | 1.0x | long brown coat | leather hat | leather hat |
| Lab | 1.55m | 1.0x | 1.0x | white coat | teal shirt | goggles |
| Render | 1.50m | 1.0x | 1.0x | cream smock | magenta beret | beret |
| Sync | 1.50m | 1.0x | 1.0x | purple tunic | cyan headphones | headphones |
| Sentinel | 1.65m | 1.25x | 1.0x | dark steel plate | cyan visor slit | full helm |

## Cast portrait

When all 12 are placed in town, the camera should be able to pull
back and capture all of them in a "town life" wide shot showing:
- Pixel + Trade in the market square
- Forge at the anvil with Sentinel nearby
- Cache + Sync in the tavern
- Index + Lab in the library
- Harvest in the field
- Bit running between them all
- Legacy on the bench
- Render at the easel watching everyone

## Animation library budget

Each NPC ships with the same minimum 5 anims:
1. `<npc>_idle` — 60-frame loop, breathing + posture
2. `<npc>_walk` — 40-frame walk cycle
3. `<npc>_work` — character-specific occupation animation
4. `<npc>_react_happy` — 20-frame greet/wave reaction
5. `<npc>_react_sad` — 30-frame contemplative reaction

## Anti-patterns

- ❌ Reskins of the same body. Each NPC must have distinct proportions
  + clothing silhouette so the player recognizes them instantly.
- ❌ All-cyan eyes too bright. Eyes are a faint glow not a beacon.
- ❌ Hovering townsfolk. Only the Sage hovers — these are grounded.
- ❌ Combat poses. None of the 12 fight the player or each other.
- ❌ Identical idle animations. Each NPC has a unique idle hand gesture.
