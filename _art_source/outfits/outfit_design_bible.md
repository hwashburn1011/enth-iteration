# Globbler Outfit Sets — Design Bible

8 outfit sets across rarity tiers. Each set contains 6 pieces:
- **head_piece** — sits on top of head, doesn't cover visor
- **chest_piece** — armor over the torso
- **glove_R / glove_L** — replace the default hand visuals
- **boot_R / boot_L** — replace the default feet visuals

All sets must read at gameplay distance (~50m isometric camera). Detail hierarchy:
1. **Silhouette** — set is identifiable from pose alone
2. **Color block** — primary color defines the rarity feel
3. **Material accents** — gold/emissive details signal tier
4. **Surface detail** — only visible in inventory close-up

---

## Set 1 — Initiate (Common, Tier 0)

**Theme:** Starter gear. Functional, neutral, unremarkable but not cheap-looking.

**Concept:** Industrial worker uniform. Everyone in the simulation gets one of these on day one. The kind of gear you outgrow quickly but feel nostalgic about.

**Color palette:**
- Primary: warm gray `#A69E8C`
- Secondary: dark gray `#807B6B`
- Accent: light gray `#BFB9A6`
- Metallic: 0.20, Roughness: 0.65

**Silhouette notes:**
- Helmet is a low-profile cap with a single visor strip
- Chest plate is a simple rectangular vest with shoulder straps
- Gloves and boots are matte rubber-like with stitched seams

**Lore tag:** "Standard issue. Property of the System."

---

## Set 2 — Patcher (Uncommon, Tier 1)

**Theme:** Repair / utility. Pockets, tool loops, scuff marks. Looks like it has been used.

**Concept:** A digital handyman's kit. The kind of gear you'd see on someone who fixes broken bots for a living.

**Color palette:**
- Primary: mustard `#8C8050`
- Secondary: dark olive `#595233`
- Accent: amber `#CCA64D`
- Metallic: 0.40, Roughness: 0.55

**Silhouette notes:**
- Helmet has a side-mounted lamp (small bump on R side)
- Chest plate has visible tool loops on hip line
- Gloves have reinforced knuckle plates
- Boots have higher tops with strap detail

**Lore tag:** "Patched 47 times. Still holding."

---

## Set 3 — Compiler (Rare, Tier 2)

**Theme:** Ornate, geometric. Soft inner glow. The first set that feels "magical."

**Concept:** A scholar-mage hybrid. Geometric patterns suggest mathematical elegance. Subtle blue emissive runs through panel seams.

**Color palette:**
- Primary: deep blue `#33509A`
- Secondary: navy `#1A2D80`
- Accent: silver-white `#E5E5F2`
- Emission: cyan-blue `#4D80FF` at strength 1.5
- Metallic: 0.60, Roughness: 0.30

**Silhouette notes:**
- Helmet has a raised back-fin (like a scholar's hood)
- Chest plate has hexagonal panel pattern
- Gloves have geometric trim on the wrist
- Boots have angled forward profile

**Lore tag:** "Pattern recognized. Welcome, friend."

---

## Set 4 — Kernel (Epic, Tier 3)

**Theme:** Sleek warrior. Dark base, gold accents, animated purple glow.

**Concept:** Battle-tested. The set you wear when you're hunting bosses. Looks dangerous.

**Color palette:**
- Primary: dark indigo `#261A4D`
- Secondary: near-black purple `#1A1530`
- Accent: bright gold `#E6BF33`
- Emission: violet `#9966FF` at strength 2.5
- Metallic: 0.85, Roughness: 0.20

**Silhouette notes:**
- Helmet is sharper, with two pointed cheek guards
- Chest plate has a central gemstone slot
- Gloves are gauntlets with finger-segment plating
- Boots have armored greaves

**Lore tag:** "The kernel does not negotiate."

---

## Set 5 — Architect (Legendary, Tier 4)

**Theme:** Heroic, ivory + gold. Cape (when physics work). Looks like the chosen one.

**Concept:** The set the prophecies talked about. Ceremonial, but still combat-ready. Bright warm gold suggests mastery.

**Color palette:**
- Primary: cream `#D9CCA6`
- Secondary: warm tan `#B3A680`
- Accent: bright gold `#F2CC4D`
- Emission: warm gold `#FFD966` at strength 3.5
- Metallic: 0.70, Roughness: 0.25

**Silhouette notes:**
- Helmet has a decorative crest along the top
- Chest plate has filigree pattern + central sigil
- Gloves have winged cuff details
- Boots have ornate kneeplate extensions
- **Optional cape** attached to back slot (cloth physics)

**Lore tag:** "The first to wake. The last to fall."

---

## Set 6 — Glitch (Cursed/Unique, Tier ???)

**Theme:** Corrupted. Crimson + toxic green. Shader distortion. Looks broken on purpose.

**Concept:** Drops from Glitch enemies. Powerful but visually unsettling. The set to wear when you're embracing the chaos.

**Color palette:**
- Primary: blood crimson `#660D33`
- Secondary: dark blood `#33081A`
- Accent: toxic green `#1AF280`
- Emission: poison green `#33FF4D` at strength 4.0
- Metallic: 0.50, Roughness: 0.40

**Silhouette notes:**
- Helmet is asymmetric, "broken" looking with chips missing
- Chest plate has visible cracks with green light bleeding through
- Gloves have torn fabric look on wrists
- Boots are mismatched (subtly different shapes L vs R)
- **Shader effect:** subtle UV distortion that pulses

**Lore tag:** "ERROR: integrity check skipped"

---

## Set 7 — Cozy (Town/Social, Tier 0 alternate)

**Theme:** Non-combat. Warm browns. Knitted/woven look. The set you wear in town.

**Concept:** A cardigan and slacks. Unironically charming. No metal, no glow, just soft materials and warm colors.

**Color palette:**
- Primary: warm brown `#735233`
- Secondary: dark cocoa `#4D3326`
- Accent: tan `#CCB38C`
- Metallic: 0.0, Roughness: 0.85

**Silhouette notes:**
- Helmet is replaced with a soft beanie/cap
- Chest is a vest with visible stitching
- Gloves have rolled cuffs
- Boots are slipper-like, no armor

**Lore tag:** "Off-duty mode engaged."

---

## Set 8 — Boss Reward (Iconic, drops from Corrupted Compiler)

**Theme:** Legendary trophy. Dark red + bronze + bright gold. Glowing seams. The set you earn through suffering.

**Concept:** Forged from boss remains. The most ornate, the most dramatic. Each piece radiates heat from inside.

**Color palette:**
- Primary: oxblood `#400D0D`
- Secondary: bronze `#806E0D`
- Accent: solar gold `#FFD94D`
- Emission: ember orange `#FF6619` at strength 5.0
- Metallic: 0.95, Roughness: 0.15

**Silhouette notes:**
- Helmet has 3 small spikes radiating up (corruption of the antenna theme)
- Chest plate has a central glowing core (matches Globbler's data core but red)
- Gloves have backs that look like the boss's claws
- Boots have armored toes that drag heat trails when worn

**Lore tag:** "The Compiler's gift. Bear it well."

---

## Mix-and-Match Rules

- Any helmet can be worn with any chest
- Set bonuses only activate when ALL 6 pieces match
- Set bonus visual: subtle outer glow in the set's accent color
- Transmog (visual override) is unlocked at iteration 3

## Dye System

- Each piece has 16 dye color variants
- Dye replaces the **primary** color slot only
- Secondary and accent stay set-defined for identity preservation
- Dyes are unlocked through: shop purchase, quest rewards, achievement unlocks

## Wear / Dirt System

- Each piece has a wear/dirt slider 0-1
- Wear increases when player takes damage while wearing the piece
- Visual: roughness map shifts higher, color desaturates ~10% per 0.5 wear
- Repair via crafting station in town
- Aesthetic-only — no stat impact
