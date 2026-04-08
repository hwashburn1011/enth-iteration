# Enth: Iteration — Animation Pipeline

## Armature Standards

### Bone Naming (Rigify-Compatible)
```
root
└── spine
    └── spine.001
        └── spine.002 (chest)
            ├── neck
            │   └── head
            │       ├── eye.L
            │       └── eye.R
            ├── shoulder.L
            │   └── upper_arm.L
            │       └── forearm.L
            │           └── hand.L
            └── shoulder.R
                └── upper_arm.R
                    └── forearm.R
                        └── hand.R
    ├── thigh.L
    │   └── shin.L
    │       └── foot.L
    │           └── toe.L
    └── thigh.R
        └── shin.R
            └── foot.R
                └── toe.R
```

### IK Setup
- **Legs:** IK target at foot, pole target at knee (forward)
- **Arms:** IK target at hand (optional, FK default for stylized animation)
- **IK stiffness:** 0.3 for natural movement

### Weight Painting Rules
- Maximum 4 bone influences per vertex (Godot limit)
- Test deformation at extremes (arms up, legs spread, full crouch)
- Smooth gradients at joints, no hard weight boundaries

---

## Animation Standards

### Frame Rate: 30 FPS
All animations authored at 30fps in Blender. Godot plays them back at game framerate.

### Animation Action Names
| Action | Frames | Loop | Notes |
|--------|--------|------|-------|
| `idle` | 60 (2s) | Yes | Breathing + subtle look-around |
| `walk` | 20 (0.67s) | Yes | Bouncy gait, arm swing |
| `run` | 14 (0.47s) | Yes | Faster, more lean forward |
| `dash` | 8 (0.27s) | No | Squash-stretch blur |
| `attack_01` | 12 (0.4s) | No | Wind up → swing → follow through |
| `attack_charge` | 30 (1s) | No | Vibrate → release |
| `hurt` | 9 (0.3s) | No | Flinch back |
| `death` | 30 (1s) | No | Collapse + dissolve |
| `levelup` | 24 (0.8s) | No | Jump celebration |
| `interact` | 15 (0.5s) | No | Reach forward gesture |

### Timing Principles
- **Anticipation:** 2-3 frames before main action
- **Action:** Fast and snappy (3-5 frames for most actions)
- **Follow-Through:** 4-6 frames of settling
- **Hold:** 2-3 frames at extreme poses for readability

### Key Pose Method
1. Set key poses at extreme positions (contact, down, pass, up for walk)
2. Add in-betweens for smooth arcs
3. Offset timing for overlapping action (arms delay behind body)
4. Add squash/stretch on impacts (10-20% deformation)

---

## Export Settings

### Blender → Godot
- Export as .glb (binary glTF)
- Include armature
- Export all actions as separate animations
- Bone influence limit: 4
- Shape keys: include if facial expressions used
- Apply modifiers before export

### Godot AnimationTree Setup
```
AnimationTree
├── Root (StateMachine)
│   ├── Idle (Animation: idle)
│   ├── Walk (BlendSpace1D: idle→walk by speed)
│   ├── Attack (Animation: attack_01)
│   ├── Hurt (Animation: hurt)
│   └── Death (Animation: death)
└── Transitions
    ├── Idle ↔ Walk (auto, 0.1s blend)
    ├── Any → Attack (immediate)
    ├── Any → Hurt (immediate)
    └── Any → Death (immediate, no exit)
```

### Animation Events (Method Tracks)
- `attack_01` frame 4: `_on_attack_hitbox_active()` — enable hitbox
- `attack_01` frame 8: `_on_attack_hitbox_inactive()` — disable hitbox
- `walk` frame 5, 15: `_on_footstep()` — play footstep SFX + dust
- `death` frame 25: `_on_death_dissolve()` — start dissolve shader

---

## NLA Editor Workflow
1. Each animation is a separate Action in Blender
2. Use NLA strips to preview blends
3. Ensure all actions start at frame 0
4. Set frame ranges exactly (no extra frames)
5. Mark looping animations with "_loop" suffix or set Godot loop flag
