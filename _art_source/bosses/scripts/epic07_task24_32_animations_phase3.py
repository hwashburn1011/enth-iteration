"""Epic 07 tasks 24-32 — P2→P3 transition + P3 idle + 3 P3 attacks + ultimate + hit/stagger/death.

Authors 9 actions on Armature_Compiler covering the full Phase 3 + reactions:

  24. compiler_p2_to_p3_transition  — debris collapses inward + chest tears open
  25. compiler_p3_idle              — massive breathing imposing
  26. compiler_p3_arena_aoe         — all 8 arms raise + arena floor pulse
  27. compiler_p3_chase_laser       — energy arm locks + slow track
  28. compiler_p3_gravity_well      — both upper arms gesture + sphere spawn
  29. compiler_p3_ultimate          — 8 arms slow synchronized + heart bulge
  30. compiler_hit_react            — generic hit reaction (any phase)
  31. compiler_stagger              — stunned when broken
  32. compiler_death                — 8-second cinematic collapse

Run via:
    blender.exe --background _art_source/bosses/compiler_boss_master.blend --python _art_source/bosses/scripts/epic07_task24_32_animations_phase3.py
"""
import bpy
import math
from mathutils import Vector, Euler

arm = bpy.data.objects.get("Armature_Compiler")
bpy.context.view_layer.objects.active = arm
bpy.ops.object.mode_set(mode='POSE')


def new_action(name):
    if bpy.data.actions.get(name):
        bpy.data.actions.remove(bpy.data.actions[name])
    return bpy.data.actions.new(name)


def rot(bone, exyz, frame):
    pb = arm.pose.bones.get(bone)
    if pb is None:
        return
    pb.rotation_mode = 'XYZ'
    pb.rotation_euler = Euler([math.radians(a) for a in exyz], 'XYZ')
    pb.keyframe_insert(data_path="rotation_euler", frame=frame)


def loc(bone, l, frame):
    pb = arm.pose.bones.get(bone)
    if pb is None:
        return
    pb.location = Vector(l)
    pb.keyframe_insert(data_path="location", frame=frame)


def scl(bone, s, frame):
    pb = arm.pose.bones.get(bone)
    if pb is None:
        return
    pb.scale = Vector(s)
    pb.keyframe_insert(data_path="scale", frame=frame)


arm.animation_data_create()


# === 24. compiler_p2_to_p3_transition (5s, debris collapses inward + chest opens) ===
act = new_action("compiler_p2_to_p3_transition")
arm.animation_data.action = act
# Frame 0: P2 settled state
scl("spine_lower", (1.10, 1.08, 1.10), 0)
scl("spine_mid",   (1.12, 1.10, 1.12), 0)
scl("spine_upper", (1.15, 1.08, 1.15), 0)
scl("core", (2.0, 2.0, 2.0), 0)
# Frames 0-40: P3 GROWTH BURST — body expands to massive
scl("spine_lower", (1.40, 1.30, 1.40), 40)
scl("spine_mid",   (1.45, 1.40, 1.45), 40)
scl("spine_upper", (1.50, 1.30, 1.50), 40)
scl("core", (3.5, 3.5, 3.5), 40)
rot("head", (-15, 0, 0), 40)
# Energy arms emerge from torso
for label in ("UR", "UL", "LR", "LL"):
    rot(f"p3_energy_{label}_pivot", (-30, 0, 0), 40)
    scl(f"p3_energy_{label}_pivot", (0.3, 0.3, 0.3), 0)
    scl(f"p3_energy_{label}_pivot", (1.0, 1.0, 1.0), 40)
# Frames 40-70: ROAR PEAK
scl("core", (5.0, 5.0, 5.0), 70)
rot("head", (-30, 0, 0), 70)
# Frames 70-120: SETTLE INTO P3
scl("spine_lower", (1.30, 1.25, 1.30), 120)
scl("spine_mid",   (1.35, 1.30, 1.35), 120)
scl("spine_upper", (1.40, 1.25, 1.40), 120)
scl("core", (3.0, 3.0, 3.0), 120)
rot("head", (-10, 0, 0), 120)
act.use_fake_user = True


# === 25. compiler_p3_idle (massive breathing imposing 100-frame loop) ===
act = new_action("compiler_p3_idle")
arm.animation_data.action = act
total = 100
for f in range(0, total + 1, 5):
    t = f / float(total) * math.tau
    # Slow heavy breath
    breath = 1.0 + 0.025 * math.sin(t)
    scl("spine_mid", (1.35 * breath, 1.30 * breath, 1.35 * breath), f)
    # Heart core throb (faster)
    heart = 3.0 + 0.4 * math.sin(t * 2.0)
    scl("core", (heart, heart, heart), f)
    # Subtle head menacing turn
    rot("head", (-10 + 1.5 * math.sin(t * 0.5), 0, 4.0 * math.sin(t * 0.3)), f)
    # P3 energy arms drift
    for label in ("UR", "UL", "LR", "LL"):
        rot(f"p3_energy_{label}_pivot", (3.0 * math.sin(t * 0.7), 0, 0), f)
        rot(f"p3_energy_{label}_tip", (2.0 * math.sin(t * 0.5), 0, 0), f)
act.use_fake_user = True


# === 26. compiler_p3_arena_aoe (5s windup, all 8 arms raise, arena pulse) ===
act = new_action("compiler_p3_arena_aoe")
arm.animation_data.action = act
# Frames 0-50: ALL 8 arms raise wide synchronized
for label in ("UR", "UL", "LR", "LL"):
    rot(f"arm_{label}_seg1", (-35, 0, -90 if label[1] == "R" else 90), 50)
    rot(f"arm_{label}_seg2", (-15, 0, 0), 50)
    rot(f"p3_energy_{label}_pivot", (-25, 0, -45 if label[1] == "R" else 45), 50)
rot("spine_upper", (-20, 0, 0), 50)
rot("head", (-25, 0, 0), 50)
scl("core", (5.0, 5.0, 5.0), 50)
# Frames 50-65: HOLD + core HOTTEST
scl("core", (6.5, 6.5, 6.5), 65)
# Frames 65-100: SETTLE
for label in ("UR", "UL", "LR", "LL"):
    rot(f"arm_{label}_seg1", (0, 0, 0), 100)
    rot(f"arm_{label}_seg2", (0, 0, 0), 100)
    rot(f"p3_energy_{label}_pivot", (0, 0, 0), 100)
rot("spine_upper", (0, 0, 0), 100)
rot("head", (-10, 0, 0), 100)
scl("core", (3.0, 3.0, 3.0), 100)
act.use_fake_user = True


# === 27. compiler_p3_chase_laser (energy arm locks + slow track) ===
act = new_action("compiler_p3_chase_laser")
arm.animation_data.action = act
# Use UR energy arm as the "tracking laser" arm
# Frame 0: neutral
rot("p3_energy_UR_pivot", (0, 0, 0), 0)
# Frames 0-15: ARM RAISES TO LOCK
rot("p3_energy_UR_pivot", (-45, 0, -30), 15)
rot("p3_energy_UR_tip", (-10, 0, 0), 15)
rot("head", (-15, 0, -20), 15)
# Frames 15-180: SLOW TRACK across arena (sweeping motion)
for i in range(8):
    f = 15 + i * 22
    yaw = -30 + i * 8  # slow sweep
    rot("p3_energy_UR_pivot", (-45, 0, yaw), f)
    rot("p3_energy_UR_tip", (-10, 0, 0), f)
    rot("head", (-15, 0, yaw * 0.8), f)
# Frames 180-200: settle
rot("p3_energy_UR_pivot", (0, 0, 0), 200)
rot("p3_energy_UR_tip", (0, 0, 0), 200)
rot("head", (-10, 0, 0), 200)
act.use_fake_user = True


# === 28. compiler_p3_gravity_well (both upper arms gesture + sphere spawn) ===
act = new_action("compiler_p3_gravity_well")
arm.animation_data.action = act
# Frame 0: neutral
# Frames 0-25: arms come together cup-shape in front of chest
rot("arm_UR_seg1", (-70, 0, -40), 25)
rot("arm_UL_seg1", (-70, 0,  40), 25)
rot("arm_UR_seg2", (-50, 0, -10), 25)
rot("arm_UL_seg2", (-50, 0,  10), 25)
rot("arm_UR_seg3", (-20, 0, 0), 25)
rot("arm_UL_seg3", (-20, 0, 0), 25)
rot("spine_upper", (-12, 0, 0), 25)
scl("core", (4.0, 4.0, 4.0), 25)
# Frames 25-45: HOLD with arms cupped (sphere spawning)
scl("core", (4.5, 4.5, 4.5), 45)
# Frames 45-70: arms snap APART (releasing the well)
rot("arm_UR_seg1", (-30, 0, -80), 70)
rot("arm_UL_seg1", (-30, 0,  80), 70)
rot("arm_UR_seg2", (-15, 0, 0), 70)
rot("arm_UL_seg2", (-15, 0, 0), 70)
# Frames 70-100: settle
rot("arm_UR_seg1", (0, 0, 0), 100)
rot("arm_UL_seg1", (0, 0, 0), 100)
rot("arm_UR_seg2", (0, 0, 0), 100)
rot("arm_UL_seg2", (0, 0, 0), 100)
rot("arm_UR_seg3", (0, 0, 0), 100)
rot("arm_UL_seg3", (0, 0, 0), 100)
rot("spine_upper", (0, 0, 0), 100)
scl("core", (3.0, 3.0, 3.0), 100)
act.use_fake_user = True


# === 29. compiler_p3_ultimate (10s windup, all 8 arms synchronized, heart bulge) ===
act = new_action("compiler_p3_ultimate")
arm.animation_data.action = act
# Frame 0: neutral
scl("core", (3.0, 3.0, 3.0), 0)
# Frames 0-60: ALL 8 arms slowly synchronously raise to overhead V
for label in ("UR", "UL", "LR", "LL"):
    rot(f"arm_{label}_seg1", (-160, 0, -10 if label[1] == "R" else 10), 60)
    rot(f"arm_{label}_seg2", (-30, 0, 0), 60)
    rot(f"p3_energy_{label}_pivot", (-100, 0, -10 if label[1] == "R" else 10), 60)
    rot(f"p3_energy_{label}_tip", (-30, 0, 0), 60)
rot("spine_upper", (-15, 0, 0), 60)
rot("head", (-30, 0, 0), 60)
# Heart bulges visibly
scl("core", (8.0, 8.0, 8.0), 60)
# Frames 60-180: HOLD with everything maxed (the long windup)
scl("core", (10.0, 10.0, 10.0), 180)
# Frames 180-210: PULSE RELEASE — arms snap down + core MAX
for label in ("UR", "UL", "LR", "LL"):
    rot(f"arm_{label}_seg1", (-30, 0, 0), 210)
    rot(f"arm_{label}_seg2", (0, 0, 0), 210)
    rot(f"p3_energy_{label}_pivot", (0, 0, 0), 210)
    rot(f"p3_energy_{label}_tip", (0, 0, 0), 210)
rot("spine_upper", (-25, 0, 0), 210)
scl("core", (12.0, 12.0, 12.0), 210)
# Frames 210-260: STAGGER (post-ultimate vulnerable window)
rot("spine_upper", (5, 0, 0), 260)
rot("head", (10, 0, 0), 260)
scl("core", (3.0, 3.0, 3.0), 260)
for label in ("UR", "UL", "LR", "LL"):
    rot(f"arm_{label}_seg1", (0, 0, 0), 260)
act.use_fake_user = True


# === 30. compiler_hit_react (generic, 18 frames) ===
act = new_action("compiler_hit_react")
arm.animation_data.action = act
rot("spine_upper", (0, 0, 0), 0)
rot("head", (0, 0, 0), 0)
# Frame 4: knockback peak
rot("spine_upper", (-12, -3, 0), 4)
rot("head", (-15, 4, 0), 4)
# Frame 10: bounce back
rot("spine_upper", (3, 1, 0), 10)
rot("head", (5, -2, 0), 10)
# Frame 18: settle
rot("spine_upper", (0, 0, 0), 18)
rot("head", (0, 0, 0), 18)
act.use_fake_user = True


# === 31. compiler_stagger (when broken, 60 frames) ===
act = new_action("compiler_stagger")
arm.animation_data.action = act
# Frame 0: pre-stagger
rot("spine_lower", (0, 0, 0), 0)
rot("spine_mid", (0, 0, 0), 0)
rot("spine_upper", (0, 0, 0), 0)
rot("head", (0, 0, 0), 0)
# Frame 6: deep slump forward
rot("spine_lower", (10, 0, 0), 6)
rot("spine_mid", (15, 0, 0), 6)
rot("spine_upper", (20, 0, 0), 6)
rot("head", (25, 0, 0), 6)
# Frames 6-50: HOLD with subtle wobble
for f in range(10, 50, 6):
    wobble = 2 * math.sin(f * 0.5)
    rot("spine_upper", (20 + wobble, wobble, 0), f)
    rot("head", (25, 0, 0), f)
# Frame 60: recover to neutral
rot("spine_lower", (0, 0, 0), 60)
rot("spine_mid", (0, 0, 0), 60)
rot("spine_upper", (0, 0, 0), 60)
rot("head", (0, 0, 0), 60)
act.use_fake_user = True


# === 32. compiler_death (8-second cinematic, 240 frames at 30fps) ===
act = new_action("compiler_death")
arm.animation_data.action = act
# === Beat 0.0s (frame 0): killing blow ===
rot("spine_lower", (0, 0, 0), 0)
rot("spine_mid", (0, 0, 0), 0)
rot("spine_upper", (0, 0, 0), 0)
rot("head", (0, 0, 0), 0)
scl("core", (3.0, 3.0, 3.0), 0)
loc("root", (0, 0, 0), 0)
# === Beat 1.0s (frame 30): chrome arms break off + fall ===
for label in ("UR", "UL", "LR", "LL"):
    rot(f"arm_{label}_seg1", (60 if label[1] == "R" else -60, 0, 0), 30)
    rot(f"arm_{label}_seg2", (40, 0, 0), 30)
    rot(f"arm_{label}_seg3", (30, 0, 0), 30)
    rot(f"arm_{label}_seg4", (20, 0, 0), 30)
rot("head", (10, 0, 0), 30)
# === Beat 2.5s (frame 75): energy arms dissipate ===
for label in ("UR", "UL", "LR", "LL"):
    scl(f"p3_energy_{label}_pivot", (0.1, 0.1, 0.1), 75)
    scl(f"p3_energy_{label}_tip", (0.1, 0.1, 0.1), 75)
# === Beat 4.0s (frame 120): heart core ruptures with final pulse ===
scl("core", (15.0, 15.0, 15.0), 115)
scl("core", (0.5, 0.5, 0.5), 125)  # collapse
# === Beat 5.5s (frame 165): tethers snap audibly + body falls forward ===
rot("spine_lower", (15, 0, 0), 165)
rot("spine_mid", (20, 0, 0), 165)
rot("spine_upper", (25, 0, 0), 165)
rot("head", (35, 0, 0), 165)
loc("root", (0, -0.5, -0.3), 165)
# Tethers go slack
for i in range(4):
    rot(f"tether_{i+1}", (15, 0, 0), 165)
# === Beat 7.0s (frame 210): body hits floor with massive dust impact ===
rot("spine_lower", (-10, 0, 0), 210)  # arch backward as it lands
rot("spine_mid", (-15, 0, 0), 210)
rot("spine_upper", (-25, 0, 0), 210)
rot("head", (45, 0, 0), 210)
loc("root", (0, -0.8, -1.2), 210)
# === Beat 8.0s (frame 240): final settle + silence ===
rot("spine_lower", (-12, 0, 0), 240)
rot("spine_upper", (-30, 0, 0), 240)
rot("head", (50, 0, 5), 240)
loc("root", (0, -0.85, -1.25), 240)
scl("core", (0.0, 0.0, 0.0), 240)
act.use_fake_user = True


bpy.ops.object.mode_set(mode='OBJECT')
anim_count = len([a for a in bpy.data.actions if a.name.startswith("compiler_")])
print(f"Total compiler animations: {anim_count}")
print("Tasks 24-32 actions created:")
for name in sorted([a.name for a in bpy.data.actions if a.name.startswith("compiler_")]):
    print(f"  {name}")

bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
