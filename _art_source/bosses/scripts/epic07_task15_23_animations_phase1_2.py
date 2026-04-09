"""Epic 07 tasks 15-23 — P1 idle + 3 P1 attacks + P1→P2 transition + P2 idle + 3 P2 attacks.

Authors 9 actions on Armature_Compiler covering the full Phase 1 and Phase 2
behavior arc:

  15. compiler_p1_idle           — imposing breathing pose
  16. compiler_p1_slam            — single arm slam (close range, 4s windup)
  17. compiler_p1_sweep_beam      — core charges + horizontal beam sweep
  18. compiler_p1_summon_adds     — both upper arms raise + chest panels open
  19. compiler_p1_to_p2_transition — cracks open + roar + body grows
  20. compiler_p2_idle            — twitchy glitching pose
  21. compiler_p2_multi_projectile — 6 arms fire spread barrage
  22. compiler_p2_teleport_strike — disappear + reappear + slam
  23. compiler_p2_hazard_spawn    — both upper arms raise + arena hazard pulse

Run via:
    blender.exe --background _art_source/bosses/compiler_boss_master.blend --python _art_source/bosses/scripts/epic07_task15_23_animations_phase1_2.py
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


def all_arms_neutral(frame):
    """Reset all 4 P1 arms to T-pose neutral."""
    for label in ("UR", "UL", "LR", "LL"):
        for seg in range(1, 5):
            rot(f"arm_{label}_seg{seg}", (0, 0, 0), frame)


# === 15. compiler_p1_idle (90-frame loop, slow imposing breathing) ===
act = new_action("compiler_p1_idle")
arm.animation_data_create()
arm.animation_data.action = act
total = 90
for f in range(0, total + 1, 6):
    t = f / float(total) * math.tau
    # Slow breathing scale on spine_mid
    breath = 1.0 + 0.012 * math.sin(t)
    scl("spine_mid", (breath, breath, breath), f)
    # Subtle head sway
    rot("head", (1.0 * math.sin(t * 0.5), 0, 2.0 * math.sin(t * 0.3)), f)
    # Core pulses with breath
    scl("core", (1.0 + 0.05 * math.sin(t), 1.0 + 0.05 * math.sin(t), 1.0 + 0.05 * math.sin(t)), f)
    # All 4 arms slight sway
    for label in ("UR", "UL", "LR", "LL"):
        rot(f"arm_{label}_seg1", (1.5 * math.sin(t * 0.4), 0, 0), f)
act.use_fake_user = True


# === 16. compiler_p1_slam (close range, 4s windup, 12-frame strike, recover) ===
act = new_action("compiler_p1_slam")
arm.animation_data.action = act
# Frame 0: combat ready
rot("arm_UR_seg1", (0, 0, 0), 0)
rot("arm_UR_seg2", (0, 0, 0), 0)
rot("spine_upper", (0, 0, 0), 0)
# Frames 0-30: WIND-UP — UR arm raises slowly to overhead
rot("spine_upper", (-15, 0, 0), 30)
rot("arm_UR_seg1", (-110, 0, -20), 30)
rot("arm_UR_seg2", (-30, 0, 0), 30)
rot("arm_UR_seg3", (-15, 0, 0), 30)
rot("arm_UR_seg4", (-10, 0, 0), 30)
rot("head", (-12, 0, 0), 30)
# Frames 30-42: HOLD at peak
rot("spine_upper", (-15, 0, 0), 42)
rot("arm_UR_seg1", (-110, 0, -20), 42)
# Frames 42-50: STRIKE — slam down
rot("spine_upper", (-25, 0, 0), 50)
rot("arm_UR_seg1", (60, 0, 30), 50)
rot("arm_UR_seg2", (50, 0, 0), 50)
rot("arm_UR_seg3", (30, 0, 0), 50)
rot("arm_UR_seg4", (20, 0, 0), 50)
rot("head", (-30, 0, 0), 50)
# Frames 50-60: HOLD impact pose
rot("arm_UR_seg1", (60, 0, 30), 60)
# Frames 60-90: RECOVER to neutral
rot("spine_upper", (0, 0, 0), 90)
rot("arm_UR_seg1", (0, 0, 0), 90)
rot("arm_UR_seg2", (0, 0, 0), 90)
rot("arm_UR_seg3", (0, 0, 0), 90)
rot("arm_UR_seg4", (0, 0, 0), 90)
rot("head", (0, 0, 0), 90)
act.use_fake_user = True


# === 17. compiler_p1_sweep_beam (core charges, head locks forward, beam sweeps) ===
act = new_action("compiler_p1_sweep_beam")
arm.animation_data.action = act
# Frame 0: neutral
rot("head", (0, 0, 0), 0)
scl("core", (1, 1, 1), 0)
# Frames 0-25: CHARGE — core grows brighter (scale up)
scl("core", (1.5, 1.5, 1.5), 25)
rot("head", (-8, 0, 0), 25)
# Frames 25-30: HOLD ready
scl("core", (1.6, 1.6, 1.6), 30)
# Frames 30-66: BEAM SWEEP — head pans -90 → +90 over 36 frames
for i in range(7):
    f = 30 + i * 6
    yaw = -90 + i * 30
    rot("head", (-8, 0, yaw), f)
    rot("spine_upper", (0, 0, yaw * 0.3), f)
    scl("core", (1.7, 1.7, 1.7), f)
# Frames 66-90: SETTLE
rot("head", (0, 0, 0), 90)
rot("spine_upper", (0, 0, 0), 90)
scl("core", (1, 1, 1), 90)
act.use_fake_user = True


# === 18. compiler_p1_summon_adds (both upper arms raise + chest panels open + core flares) ===
act = new_action("compiler_p1_summon_adds")
arm.animation_data.action = act
# Frame 0: neutral
all_arms_neutral(0)
scl("core", (1, 1, 1), 0)
# Frames 0-30: arms raise wide outward — UR + UL
rot("arm_UR_seg1", (-30, 0, -85), 30)
rot("arm_UL_seg1", (-30, 0,  85), 30)
rot("arm_UR_seg2", (-15, 0, 0), 30)
rot("arm_UL_seg2", (-15, 0, 0), 30)
rot("spine_upper", (-12, 0, 0), 30)
rot("head", (-15, 0, 0), 30)
scl("core", (2.0, 2.0, 2.0), 30)
# Frames 30-50: HOLD + core flares
scl("core", (2.5, 2.5, 2.5), 50)
# Frames 50-90: arms return to neutral
rot("arm_UR_seg1", (0, 0, 0), 90)
rot("arm_UL_seg1", (0, 0, 0), 90)
rot("arm_UR_seg2", (0, 0, 0), 90)
rot("arm_UL_seg2", (0, 0, 0), 90)
rot("spine_upper", (0, 0, 0), 90)
rot("head", (0, 0, 0), 90)
scl("core", (1, 1, 1), 90)
act.use_fake_user = True


# === 19. compiler_p1_to_p2_transition (4s, body grows, cracks open, roar) ===
act = new_action("compiler_p1_to_p2_transition")
arm.animation_data.action = act
# Frame 0: P1 neutral
scl("spine_lower", (1, 1, 1), 0)
scl("spine_mid", (1, 1, 1), 0)
scl("spine_upper", (1, 1, 1), 0)
scl("core", (1, 1, 1), 0)
# Frames 0-40: BUILD — body grows + arms tense up
scl("spine_lower", (1.10, 1.05, 1.10), 40)
scl("spine_mid",   (1.10, 1.10, 1.10), 40)
scl("spine_upper", (1.15, 1.05, 1.15), 40)
scl("core", (1.5, 1.5, 1.5), 40)
rot("head", (-15, 0, 0), 40)
for label in ("UR", "UL", "LR", "LL"):
    rot(f"arm_{label}_seg1", (-25, 0, 0), 40)
# Frames 40-60: ROAR PEAK — core MAX + body shudders
scl("core", (3.0, 3.0, 3.0), 60)
rot("head", (-30, 0, 0), 60)
scl("spine_lower", (1.20, 1.10, 1.20), 60)
scl("spine_upper", (1.25, 1.10, 1.25), 60)
# Frames 60-100: SETTLE INTO P2 size (slightly larger than P1)
scl("spine_lower", (1.10, 1.08, 1.10), 100)
scl("spine_mid",   (1.12, 1.10, 1.12), 100)
scl("spine_upper", (1.15, 1.08, 1.15), 100)
scl("core", (2.0, 2.0, 2.0), 100)
rot("head", (-8, 0, 0), 100)
for label in ("UR", "UL", "LR", "LL"):
    rot(f"arm_{label}_seg1", (-10, 0, 0), 100)
act.use_fake_user = True


# === 20. compiler_p2_idle (twitchy glitching, 60-frame loop) ===
act = new_action("compiler_p2_idle")
arm.animation_data.action = act
total = 60
for f in range(0, total + 1, 4):
    t = f / float(total) * math.tau
    # Sharp jitter on spine_mid
    jitter = 1.0 + 0.02 * math.sin(t * 4.0)
    scl("spine_mid", (jitter, jitter, jitter), f)
    # Twitchy head
    rot("head", (3.0 * math.sin(t * 5.0), 0, 5.0 * math.sin(t * 3.0)), f)
    # Core flickers
    core_flicker = 1.8 + 0.15 * math.sin(t * 6.0)
    scl("core", (core_flicker, core_flicker, core_flicker), f)
    # P2 fragmented arms wiggle
    for label in ("BR", "BL"):
        rot(f"p2_arm_{label}_anchor", (5.0 * math.sin(t * 2.5), 0, 0), f)
        for seg in range(1, 4):
            rot(f"p2_arm_{label}_seg{seg}", (3.0 * math.sin(t * 3.0 + seg), 0, 0), f)
act.use_fake_user = True


# === 21. compiler_p2_multi_projectile (6 arms fire spread barrage) ===
act = new_action("compiler_p2_multi_projectile")
arm.animation_data.action = act
# Frame 0: P2 idle pose baseline
all_arms_neutral(0)
# Frames 0-15: WIND-UP — all 6 arms (4 P1 + 2 P2) raise to fire ready
for label in ("UR", "UL", "LR", "LL"):
    rot(f"arm_{label}_seg1", (-50, 0, -20 if label[1] == "R" else 20), 15)
    rot(f"arm_{label}_seg2", (-25, 0, 0), 15)
for label in ("BR", "BL"):
    rot(f"p2_arm_{label}_seg1", (-40, 0, 0), 15)
# Frames 15-22: FIRE BURST — all arms snap forward
for label in ("UR", "UL", "LR", "LL"):
    rot(f"arm_{label}_seg1", (-30, 0, -10 if label[1] == "R" else 10), 22)
    rot(f"arm_{label}_seg2", (-10, 0, 0), 22)
for label in ("BR", "BL"):
    rot(f"p2_arm_{label}_seg1", (-20, 0, 0), 22)
# Frames 22-50: SETTLE
for label in ("UR", "UL", "LR", "LL"):
    rot(f"arm_{label}_seg1", (0, 0, 0), 50)
    rot(f"arm_{label}_seg2", (0, 0, 0), 50)
for label in ("BR", "BL"):
    rot(f"p2_arm_{label}_seg1", (0, 0, 0), 50)
act.use_fake_user = True


# === 22. compiler_p2_teleport_strike (vanish + reappear + slam) ===
act = new_action("compiler_p2_teleport_strike")
arm.animation_data.action = act
# Frame 0: neutral
scl("spine_lower", (1.10, 1.08, 1.10), 0)
scl("spine_mid", (1.12, 1.10, 1.12), 0)
# Frames 0-8: COMPRESS for teleport
scl("spine_lower", (0.6, 1.4, 0.6), 8)
scl("spine_mid", (0.6, 1.4, 0.6), 8)
scl("spine_upper", (0.6, 1.4, 0.6), 8)
# Frames 8-12: VANISH (small + invisible-like)
scl("spine_lower", (0.2, 0.4, 0.2), 12)
scl("spine_mid", (0.2, 0.4, 0.2), 12)
scl("spine_upper", (0.2, 0.4, 0.2), 12)
# Frames 12-16: REAPPEAR at full size with one arm raised for slam
scl("spine_lower", (1.10, 1.08, 1.10), 16)
scl("spine_mid", (1.12, 1.10, 1.12), 16)
scl("spine_upper", (1.15, 1.08, 1.15), 16)
rot("arm_UR_seg1", (-100, 0, -15), 16)
rot("arm_UR_seg2", (-50, 0, 0), 16)
# Frames 16-22: SLAM
rot("arm_UR_seg1", (45, 0, 25), 22)
rot("arm_UR_seg2", (20, 0, 0), 22)
rot("arm_UR_seg3", (10, 0, 0), 22)
rot("spine_upper", (-20, 0, 0), 22)
# Frames 22-40: settle
rot("arm_UR_seg1", (0, 0, 0), 40)
rot("arm_UR_seg2", (0, 0, 0), 40)
rot("arm_UR_seg3", (0, 0, 0), 40)
rot("spine_upper", (0, 0, 0), 40)
act.use_fake_user = True


# === 23. compiler_p2_hazard_spawn (both upper arms raise + arena hazard) ===
act = new_action("compiler_p2_hazard_spawn")
arm.animation_data.action = act
# Frame 0: neutral
all_arms_neutral(0)
scl("core", (2.0, 2.0, 2.0), 0)
# Frames 0-30: arms raise + spread wide
rot("arm_UR_seg1", (-50, 0, -90), 30)
rot("arm_UL_seg1", (-50, 0,  90), 30)
rot("arm_UR_seg2", (-20, 0, 0), 30)
rot("arm_UL_seg2", (-20, 0, 0), 30)
rot("spine_upper", (-20, 0, 0), 30)
rot("head", (-25, 0, 0), 30)
scl("core", (3.5, 3.5, 3.5), 30)
# Frames 30-50: HOLD
scl("core", (3.5, 3.5, 3.5), 50)
# Frames 50-80: arms return + core dims
rot("arm_UR_seg1", (0, 0, 0), 80)
rot("arm_UL_seg1", (0, 0, 0), 80)
rot("arm_UR_seg2", (0, 0, 0), 80)
rot("arm_UL_seg2", (0, 0, 0), 80)
rot("spine_upper", (0, 0, 0), 80)
rot("head", (0, 0, 0), 80)
scl("core", (2.0, 2.0, 2.0), 80)
act.use_fake_user = True


bpy.ops.object.mode_set(mode='OBJECT')
anim_count = len([a for a in bpy.data.actions if a.name.startswith("compiler_")])
print(f"Total compiler animations: {anim_count}")
print("Tasks 15-23 actions created:")
for name in sorted([a.name for a in bpy.data.actions if a.name.startswith("compiler_")]):
    print(f"  {name}")

bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
