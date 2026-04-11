---
epic: 22
title: "NPC Interaction Polish"
phase: 4
status: TODO
priority: medium
estimated_hours: 45
dependencies: [1, 2, 4, 19, 20, 21]
---

# Epic 22: NPC Interaction Polish

## Overview

Polish all NPC interaction animations to create warm, responsive, and characterful encounters in Enth: Iteration's town hub. This epic adds the animation layers that make NPCs feel alive during player interactions: approach turn animations, greeting waves, conversation idle poses, gift reactions, recruitment celebrations, farewell gestures, and visual affinity indicators. These animations work alongside the expression system (Epic 21) to create NPCs that feel like living characters, not static dialogue dispensers.

**Design Philosophy:** Every NPC interaction should feel like a micro-cutscene. When the player approaches an NPC, the NPC notices and turns to face them. When dialogue begins, the NPC greets the player. During conversation, the NPC shifts poses naturally. When the player leaves, the NPC waves goodbye. These small touches create emotional connection between the player and the digital community they are building.

**Quality Target:** Interaction animations should match the personality of each NPC: the AI Sage is deliberate and graceful, the Cache Sprite is enthusiastic and bouncy. Every animation should feel hand-crafted and full of character.

## Success Criteria

- [ ] NPCs turn to face the approaching player naturally
- [ ] Greeting animations match NPC personality
- [ ] Conversation idle poses vary and feel natural
- [ ] Gift reactions are expressive and rewarding
- [ ] Recruitment celebration is a memorable moment
- [ ] Farewell gestures provide closure to interactions
- [ ] Affinity levels have visible indicators
- [ ] All interactions feel warm and characterful

---

## Tasks

### Task 22.1: Approach Detection and Turn System
**Status:** TODO
**Description:** Implement a system that detects when the player approaches an NPC and smoothly turns the NPC to face them. Create an `NPCInteractionController` script attached to NPC scenes. The controller uses an Area3D trigger (2m radius) to detect player entry. When the player enters the approach zone: (1) Calculate the direction from NPC to player. (2) Smoothly rotate the NPC to face the player over 0.5 seconds using a rotation tween (ease-in-out). (3) If the NPC has a head bone, orient the head toward the player slightly faster than the body (head leads, body follows -- 0.3s for head, 0.5s for body). (4) The NPC should track the player's position if they move within the zone (slow continuous rotation). (5) When the player leaves the zone, the NPC returns to its default facing over 1 second. The turn should feel natural, not robotic -- add a slight anticipation (body weight shift before turn).
**Acceptance Criteria:**
- 2m approach zone detection via Area3D
- Smooth 0.5s body rotation toward player
- Head leads body rotation (0.3s head, 0.5s body)
- Continuous tracking while player is in zone
- Return to default facing on zone exit (1s)
- Weight shift anticipation before turn
- Works for all NPC types regardless of base idle animation

### Task 22.2: AI Sage Approach Turn Animation
**Status:** TODO
**Description:** Create the AI Sage's specific approach turn animation layer. When the player approaches, in addition to the rotation system (Task 22.1), the sage performs a subtle acknowledgment: (1) Staff tilts slightly toward the player (welcoming gesture), (2) Crystal glow brightens 20% (the sage's attention energizes the crystal), (3) Wisdom particles shift their orbit to favor the player's side (more particles drift toward the player, fewer away), (4) Hood tilts 5 degrees toward the player direction (beyond the basic head turn), (5) The idle float bob slows slightly (0.7x amplitude -- the sage becomes "still" with attention). These are additive animation layers blended on top of the idle, controlled by a blend parameter that tweens from 0 (not noticed) to 1 (fully engaged) over 0.5 seconds.
**Acceptance Criteria:**
- Staff tilt toward player
- Crystal brightens 20% on approach
- Wisdom particles shift orbit toward player
- Hood tilts toward player
- Idle bob amplitude reduces (focused attention)
- All changes driven by single blend parameter (0 to 1)
- Blends smoothly on top of idle animation

### Task 22.3: Cache Sprite Approach Reaction
**Status:** TODO
**Description:** Create the Cache Sprite's enthusiastic approach reaction. The sprite should react with visible excitement when the player comes near: (1) A quick "perk up" -- body snaps upright from any current micro-tilt, antenna straightens, eyes widen slightly (shape key blend to "excited" at 30%). (2) A small bounce (0.03m upward hop over 0.2s). (3) Wing flutter speed increases to 14Hz (from 12Hz idle). (4) The sprite moves slightly toward the player (0.1m lateral drift in player direction). (5) A tiny sparkle particle (2-3 particles) pops from the antenna tip. (6) If the sprite was doing a personality idle variant (yawn, curious look), it immediately interrupts and snaps to the approach reaction. The reaction should feel like a puppy noticing its owner -- pure enthusiastic recognition.
**Acceptance Criteria:**
- Quick perk-up snap to attention
- Small upward bounce
- Wing flutter speed increase
- Lateral drift toward player
- Antenna sparkle particles
- Interrupts personality idle variants
- Feels enthusiastically welcoming

### Task 22.4: Greeting Wave -- AI Sage
**Status:** TODO
**Description:** Create the AI Sage's greeting animation (1 second, 24 frames, one-shot). This plays when the player initiates dialogue (presses interact). The sage performs a dignified greeting: (1) Left hand (gesture hand) raises slowly to chest height with open palm facing the player (frames 1-10). (2) The hand performs a slow, graceful wave -- not a back-and-forth wave, but a single sweeping gesture from left to right, palm forward (frames 10-18), suggesting "welcome, come closer." (3) Hand returns to rest position (frames 18-24). (4) Simultaneously, the head performs a slight bow (3-degree forward tilt, frames 5-15). (5) The staff crystal pulses brighter at the wave peak (frame 14). The greeting should feel dignified and warm, befitting a wise mentor figure.
**Acceptance Criteria:**
- Dignified single-sweep greeting gesture (not frantic waving)
- Slight head bow accompanies the gesture
- Crystal pulse at gesture peak
- Smooth transition from approach state to greeting
- 1-second duration does not delay dialogue too long
- Feels warm and wise, matching AI Sage personality
- Transitions smoothly into conversation idle

### Task 22.5: Greeting Wave -- Cache Sprite
**Status:** TODO
**Description:** Create the Cache Sprite's greeting animation (0.75 seconds, 18 frames, one-shot). The sprite's greeting should be energetic and cute: (1) Both arms shoot up overhead (frames 1-4, fast snap). (2) Rapid side-to-side wave with both arms (3 oscillations over frames 4-14, whole body tilts with each wave). (3) A spin (180 degrees and back, or a full 360 -- frames 5-10 overlapping with wave). (4) Final "ta-da" pose -- arms spread wide, body puffs up 5% (slight scale increase), enormous happy expression (shape key). (5) Wing flutter hits maximum speed (16Hz) during the greeting. (6) 4-6 sparkle particles burst from around the sprite. The greeting should be adorably over-the-top -- the Cache Sprite is always thrilled to see the player.
**Acceptance Criteria:**
- Arms shoot up quickly (energetic start)
- Rapid two-arm wave with body tilt
- Spin during wave adds dynamics
- "Ta-da" finishing pose with scale puff
- Maximum wing flutter speed
- Sparkle particle burst
- Adorably enthusiastic, matching Cache Sprite personality

### Task 22.6: Conversation Idle Poses -- Pose Set
**Status:** TODO
**Description:** Create a set of conversation idle poses that NPCs cycle through during extended dialogue. These prevent the NPC from looking frozen during long conversations. For the AI Sage, create 4 pose variants: (1) **Attentive listen**: head slightly tilted, hands folded at waist. (2) **Thoughtful**: one hand raised to chin area (pondering gesture). (3) **Open gesture**: both hands slightly apart at waist height, palms up (offering wisdom). (4) **Staff lean**: body weight shifts to staff side, subtle lean. For the Cache Sprite, create 4 variants: (1) **Rapt attention**: body leans forward, eyes wide. (2) **Nodding**: rhythmic head bobbing. (3) **Fidgeting**: hands play with each other, feet kick. (4) **Excited hover**: rises 0.05m higher than normal, body quivers. Each pose is a looping animation (3s) that blends from one to another every 6-10 seconds randomly.
**Acceptance Criteria:**
- 4 conversation idle variants per NPC (8 total)
- Each variant looping at 3 seconds
- Random cycling every 6-10 seconds
- Smooth blend transitions between variants
- Variants match NPC personality (sage = dignified, sprite = energetic)
- All variants blend with expression system
- NPCs never feel frozen during dialogue

### Task 22.7: Conversation Idle -- Responsive Listening
**Status:** TODO
**Description:** Make NPCs respond visually to the player's dialogue choices. When the dialogue system advances (player clicks to continue or selects a choice): (1) NPC performs a micro-nod (2-3 degree head dip over 0.2 seconds, then back) -- this acknowledges that the NPC "heard" the player. (2) If the dialogue line is a question (ends with "?"), the NPC tilts head slightly to one side (curiosity). (3) If the dialogue line is an exclamation (ends with "!"), the NPC performs a small startle/surprise micro-reaction (0.1s). (4) Between long dialogue blocks, the NPC shifts conversation idle pose (cycling to the next variant). These responsive reactions make it feel like the NPC is actively listening and reacting to the conversation in real time.
**Acceptance Criteria:**
- Micro-nod on dialogue advance (2-3 degree head dip, 0.2s)
- Head tilt on question lines
- Micro-startle on exclamation lines
- Pose shift between long dialogue blocks
- Reactions are subtle and do not interrupt dialogue reading
- Creates feeling of active listening
- Works with both AI Sage and Cache Sprite

### Task 22.8: Gift Reaction -- Positive (Liked Gift)
**Status:** TODO
**Description:** Create the animation for when the player gives a gift that the NPC likes. This is a rewarding moment that reinforces the gift-giving mechanic. AI Sage reaction (1.5s): head tilts up (pleased), both hands clasp together at chest (grateful gesture), crystal glows brighter, wisdom particles swirl faster, then a slow appreciative nod. Cache Sprite reaction (1.5s): eyes go wide (surprised shape key), both hands reach out eagerly (grabbing gesture), quick spin with the gift, then hug-self pose (clutching the gift), followed by excited bounce. Both NPCs should trigger "happy" expression + sparkle particles (from Epic 21). The moment should feel warm and make the player want to give more gifts.
**Acceptance Criteria:**
- AI Sage: grateful clasped hands + appreciative nod
- Cache Sprite: eager grab + spin + hug-self + excited bounce
- Both trigger happy expression and sparkle particles
- 1.5-second animation feels complete and satisfying
- Reinforces gift-giving behavior (feels rewarding)
- Returns to conversation idle smoothly

### Task 22.9: Gift Reaction -- Negative (Disliked Gift)
**Status:** TODO
**Description:** Create the animation for when the player gives a disliked or neutral gift. This should be gentle disappointment, not punishing -- the player should feel "oh, they didn't love it" not "I messed up badly." AI Sage reaction (1s): slight head tilt down (mild disappointment), one hand raises with a gentle "well..." gesture (open palm, slight waver), then returns to neutral with a forgiving small nod. Cache Sprite reaction (1s): eyes droop slightly (sad shape key at 50% -- not full sad), mouth goes flat, body deflates slightly (2% scale decrease), then perks back up with a "it's okay!" expression (returning to happy at 30%). Both trigger "thinking" expression briefly. Subtle -- not dramatic.
**Acceptance Criteria:**
- AI Sage: mild disappointment gesture + forgiving nod
- Cache Sprite: brief deflate + quick recovery to mild happy
- Both are gentle, not punishing
- "Thinking" expression triggered briefly
- Less dramatic than positive reaction (subtle disappointment)
- Returns to conversation idle cleanly
- Player feels informed, not discouraged

### Task 22.10: Recruitment Celebration
**Status:** TODO
**Description:** Create the animation sequence when an NPC is successfully recruited to the town. This is a significant narrative moment and should feel like a celebration. Duration: 3 seconds. The NPC performs a joyful acceptance: AI Sage -- raises staff with both hands, crystal flares brilliantly (emission 5x for 1 second), wisdom particles explode outward in a burst (30 particles), then settles into a new "committed" pose (staff held more upright, posture more confident). Cache Sprite -- rapid spin sequence (3 full rotations), arms outstretched, maximum wing flutter, shower of sparkle and heart particles (20 particles), excited bouncing, then a final "thumbs up" pose (one arm raised with fist/mitten gesture). Both trigger a shared celebratory particle effect: golden confetti-like data particles (30-40) raining down around the NPC.
**Acceptance Criteria:**
- 3-second joyful celebration per NPC
- AI Sage: staff raise + crystal flare + particle burst
- Cache Sprite: spin + particle shower + thumbs up
- Shared golden confetti particle effect
- Feels like a milestone moment in the game
- New "committed" final pose signals the NPC has joined
- Memorable and rewarding for the player

### Task 22.11: Farewell Wave
**Status:** TODO
**Description:** Create the farewell animation that plays when dialogue ends and the player walks away. This provides emotional closure to the interaction. AI Sage farewell (1s): a gracious send-off -- left hand raises to shoulder height with open palm, performs a slow single wave (similar to greeting but more gentle), head gives a slight nod, crystal dims 10% as attention shifts away, wisdom particles return to default orbit. Cache Sprite farewell (1s): one arm waves enthusiastically (rapid side-to-side, 4 oscillations), body leans in the player's departure direction (as if wanting to follow), then a visible "reluctant return" -- body settles back to idle position with a tiny sigh (slight deflation, "thinking" expression briefly). The farewell triggers when the player crosses outside the approach zone (2m).
**Acceptance Criteria:**
- AI Sage: gracious single wave + nod + crystal dim
- Cache Sprite: enthusiastic rapid wave + lean + reluctant return
- Farewell triggers on approach zone exit
- Smooth transition from conversation back to idle
- Crystal/particles return to default state
- Provides emotional closure to the interaction
- Farewell personality matches each NPC

### Task 22.12: Affinity Visual Indicator -- Heart Level Display
**Status:** TODO
**Description:** Create a visual system that communicates the player's affinity level with each NPC. The affinity indicator appears when the player is near the NPC (within approach zone). Design: small heart icons (using the same billboard system as reaction icons) that display the current affinity tier. Tier 1 (Stranger, 0-20%): no hearts shown. Tier 2 (Acquaintance, 20-40%): 1 small grey heart. Tier 3 (Friend, 40-60%): 2 small blue hearts. Tier 4 (Close Friend, 60-80%): 3 small gold hearts. Tier 5 (Bonded, 80-100%): 3 gold hearts with sparkle particles. Hearts are positioned in a horizontal row 0.1m above the NPC's reaction icon position. Hearts fade in when the player enters the zone and fade out when they leave. Each heart has a gentle pulse animation (scale 100%-105%).
**Acceptance Criteria:**
- 5 affinity tiers with distinct visual representations
- Heart icons as billboard sprites above NPC
- Color progression: none -> grey -> blue -> gold -> gold+sparkle
- Hearts fade in/out with approach zone
- Gentle pulse animation on each heart
- Positioned above reaction icons (no overlap)
- Affinity level reads from SaveManager/NPC data

### Task 22.13: Affinity Visual -- NPC Behavior Changes
**Status:** TODO
**Description:** Make NPC behavior visually different based on affinity level, beyond the heart indicator. Implement graduated behavioral changes: **Low affinity (Tier 1-2)**: NPC turns toward player slowly (0.7s instead of 0.5s), greeting is minimal (slight nod only, no full wave), conversation idle uses primarily "attentive listen" pose (formal). **Medium affinity (Tier 3)**: standard approach speed and greeting, full conversation idle variety, farewell wave. **High affinity (Tier 4-5)**: NPC turns quickly (0.3s), greeting is more enthusiastic (sage: crystal flares, sprite: extra bouncy), NPC moves 0.3m toward the player on approach (meeting them partway), conversation idle includes unique "friendship" poses (sage: companionable lean, sprite: perching on player's shoulder vicinity), farewell includes "miss you" expression.
**Acceptance Criteria:**
- Low affinity: slower, more formal interaction animations
- Medium affinity: standard animation set
- High affinity: faster, warmer, more enthusiastic animations
- NPC moves toward player at high affinity
- Unique friendship poses for high affinity
- Gradual progression feels natural (not sudden tier jumps)
- Affinity level read from game data

### Task 22.14: NPC Daily Routine Animations
**Status:** TODO
**Description:** Create ambient animations for NPCs performing "daily routine" activities when not interacting with the player. These make the town feel alive. AI Sage routines: (1) **Meditating**: floating slightly higher than normal, both hands on staff, no movement except extremely slow breathing (0.5x idle speed), crystal glows steadily. (2) **Reading**: one hand holds an invisible book (positioned as if holding something at eye level), head moves as if scanning text, crystal dims. (3) **Gazing**: standing at the town edge, looking outward, slight wind robe sway. Cache Sprite routines: (1) **Cataloging**: darting between two points rapidly, pausing to examine each spot, data burst particles occasionally. (2) **Napping**: resting on a surface, wings folded, gentle breathing scale, "Zzz" particles. (3) **Playing**: chasing a floating data mote in circles. Each routine is a 10-second looping animation.
**Acceptance Criteria:**
- 3 daily routines per NPC (6 total)
- Each routine is a 10-second looping animation
- Routines match NPC personality and role
- Sage routines are calm and contemplative
- Sprite routines are energetic or adorable
- Interrupted cleanly when player approaches (transition to approach)
- Make the town feel alive and inhabited

### Task 22.15: NPC Relationship Milestone Animations
**Status:** TODO
**Description:** Create special one-time animations for relationship milestones beyond recruitment. Milestones: (1) **First quest completed for NPC**: NPC performs a trust-building gesture -- sage extends hand (offering handshake/pact), sprite does a "best friends" fist bump. (2) **Max affinity reached**: special "bond" animation -- sage creates a golden thread of light between self and player (particle effect connecting the two), sprite performs an elaborate dance ending in a hug-like pose. (3) **NPC remembers across iterations** (narrative milestone): sage's eyes glow a different color momentarily (white instead of gold, suggesting awareness), sprite freezes mid-motion then looks directly at the player with knowing expression. These animations are rare and meaningful -- they should feel like genuine relationship developments.
**Acceptance Criteria:**
- 3 milestone animations per NPC (6 total)
- Each milestone is a one-time special moment
- First quest: trust-building gesture
- Max affinity: deep bond expression with special VFX
- Cross-iteration memory: eerie awareness moment
- Rare and meaningful (not diluted by frequency)
- Cross-iteration milestone ties into game narrative

### Task 22.16: Interaction Proximity Effects
**Status:** TODO
**Description:** Add ambient visual effects that activate when the player is near an NPC (within the approach zone). These effects create a warm "aura of interaction" around NPC spaces. Effects: (1) **Warm light increase**: when near the AI Sage, the crystal's OmniLight3D energy increases by 30%, casting more teal light on the player and surroundings (visual warmth). (2) **Ambient particles**: within 2m of the sage, 5-6 additional golden wisdom motes appear (more populated particle field near the sage). (3) **Cache Sprite proximity glow**: sprite's body emission increases 20%, data trail particles activate even while idle (subtle trail, lower density than follow behavior). (4) **Ground glow**: a subtle circular glow decal on the ground beneath each NPC (warm color, 1m radius) that brightens when the player is in the zone. These effects make NPC areas feel like warm, inviting spots in the town.
**Acceptance Criteria:**
- Crystal light increases near AI Sage
- Extra wisdom particles appear in sage proximity
- Cache Sprite glows brighter when player is near
- Ground glow decal beneath each NPC
- Effects activate/deactivate smoothly on zone enter/exit
- NPC areas feel inviting and warm
- Performance impact minimal (pre-allocated particles)

### Task 22.17: Dialogue Camera -- Cinematic Framing
**Status:** TODO
**Description:** When dialogue begins with an NPC, implement a subtle camera adjustment that improves cinematic framing. The camera does not need to dramatically change (this is not a cutscene), but should: (1) Smoothly zoom in 10% (reducing FOV or moving closer) to focus on the NPC-player pair. (2) Shift the camera center point to frame the NPC and player roughly at the rule-of-thirds intersection points. (3) Optionally reduce depth of field (if DOF is implemented) to slightly blur the background, focusing attention on the characters. (4) When dialogue ends, reverse the adjustments over 0.5 seconds. All adjustments should be subtle enough that the player does not feel "pulled" away from gameplay -- just a gentle focusing effect. Include a toggle option for players who prefer no camera adjustment during dialogue.
**Acceptance Criteria:**
- 10% zoom on dialogue start (subtle)
- Camera center reframes for NPC-player pair
- Optional DOF blur on background
- All adjustments smooth (0.5s transition in/out)
- Toggle option in settings for camera adjustment
- Subtle enough to feel natural, not intrusive
- Returns to gameplay camera smoothly on dialogue end

### Task 22.18: Multi-NPC Interaction -- Group Responses
**Status:** TODO
**Description:** When the player interacts with one NPC while others are nearby, the non-interacting NPCs should react subtly. Implement group awareness: (1) When the player starts dialogue with one NPC, nearby NPCs (within 5m) turn toward the conversation pair (using their approach turn system at 50% speed). (2) Nearby NPCs adopt a "spectating" conversation idle -- a unique pose variant where they appear to watch the dialogue from a distance (sage: turns staff to side and watches, sprite: hovers slightly higher for a better view). (3) When the dialogue ends, spectating NPCs return to their routines over 2 seconds. (4) If the player subsequently approaches a spectating NPC, that NPC's greeting is slightly different (faster, as if they were already paying attention). This creates a living town atmosphere.
**Acceptance Criteria:**
- Nearby NPCs turn toward active dialogue pair
- Spectating pose variant for non-interacting NPCs
- NPCs return to routines after dialogue ends (2s)
- Subsequent interaction acknowledges spectating (faster greeting)
- Creates living community atmosphere
- Only triggers for NPCs within 5m
- Does not distract from the active dialogue

### Task 22.19: Interaction Sound Integration Points
**Status:** TODO
**Description:** Define and implement all sound trigger points for NPC interaction animations (actual sounds are Epic 49, but trigger points must be defined here). Create signal emissions from the animation system at key moments: (1) Approach zone enter: `npc_player_approached` signal. (2) Greeting start: `npc_greeting` signal with NPC type. (3) Conversation idle pose change: `npc_idle_shift` signal. (4) Gift reaction: `npc_gift_reaction` signal with positive/negative. (5) Recruitment celebration: `npc_recruited` signal. (6) Farewell: `npc_farewell` signal. (7) Milestone reached: `npc_milestone` signal with milestone type. Each signal includes metadata (NPC type, position, reaction intensity) that AudioManager can use to select and play appropriate sound effects. Connect all signals to EventBus for system-wide access.
**Acceptance Criteria:**
- 7+ signal types for NPC interaction audio triggers
- Each signal includes NPC type, position, and intensity metadata
- Signals emit at exact animation frame of interest
- All signals connected to EventBus
- AudioManager can subscribe to these signals
- Signal timing matches visual moments precisely
- Documented for Epic 49 audio implementation

### Task 22.20: Full Interaction Polish Integration Test
**Status:** TODO
**Description:** Complete end-to-end test of all NPC interaction polish. Walk through the complete interaction flow with both the AI Sage and Cache Sprite: (1) Approach from various directions -- NPCs turn naturally. (2) Enter approach zone -- proximity effects activate. (3) Initiate dialogue -- greeting animation + camera adjustment. (4) Long dialogue sequence -- conversation idle cycles, responsive listening reactions, expression changes. (5) Give liked gift -- positive gift reaction with particles. (6) Give disliked gift -- gentle disappointment. (7) Complete quest -- appropriate reaction. (8) End dialogue -- farewell animation. (9) Walk away -- proximity effects deactivate. (10) Observe daily routines from a distance. Test with multiple NPCs simultaneously for group response behavior. Verify affinity indicators at different tiers. Test milestone animations if accessible. Verify performance with all interaction systems active. Take comparison screenshots showing NPCs before and after the interaction polish.
**Acceptance Criteria:**
- Full interaction flow works smoothly for both NPCs
- Approach, greeting, dialogue, gift, farewell all chain correctly
- Group response behavior functions with multiple NPCs
- Affinity indicators display correctly at all tiers
- Daily routines play when not interacting
- Performance stable with all interaction systems active
- Interactions feel warm, characterful, and polished
- Before/after screenshots demonstrate improvement

---

## Dependencies

- **Epic 1** (Art Pipeline Setup): Animation export settings
- **Epic 2** (Visual Style Guide): Character personality direction
- **Epic 4** (Animation Pipeline): Rig standards and additive animation approach
- **Epic 19** (AI Sage): Model, rig, and base animations
- **Epic 20** (Cache Sprite): Model, rig, and base animations
- **Epic 21** (NPC Expressions): Shape keys and expression system integration

## Notes

- Approach turn animation is the single most impactful NPC polish feature -- prioritize it
- Conversation idle variety prevents the "talking to a statue" feeling
- Gift reactions directly impact player engagement with the gift-giving system
- The recruitment celebration should be one of the most memorable moments in the early game
- Daily routines make the town feel alive even when the player is not interacting
- Sound trigger integration is essential for the full interaction experience (Epic 49)
- Consider adding NPC idle chitchat between NPCs (when multiple are nearby and player is not interacting)
