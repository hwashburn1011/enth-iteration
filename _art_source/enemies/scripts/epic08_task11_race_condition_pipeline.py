"""Epic 08 task 11 — Race Condition full pipeline.

Per the bible: 1.0m sphere with 4 limbs at irregular angles, glitchy
magenta+cyan striping with chromatic aberration, splits at 50% HP into
2 copies. Max 4 generations.

Run via:
    blender.exe --background --python _art_source/enemies/scripts/epic08_task11_race_condition_pipeline.py
"""
import bpy
import bmesh
import os
import sys
import math
import numpy as np
from mathutils import Vector, Matrix, Euler

# Make the shared utils importable
SCRIPT_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/scripts"
if SCRIPT_DIR not in sys.path:
    sys.path.insert(0, SCRIPT_DIR)

from enemy_pipeline_utils import (
    make_pbr, create_mesh, rotate_to_dir,
    build_joined_lod, build_high_poly, smart_uv_unwrap,
    bake_pbr_set, write_albedo, img_to_array, hash_noise,
)

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.scene.unit_settings.system = 'METRIC'

OUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/enemy_race_condition.blend"
TEX_DIR = "C:/Users/hwash/Documents/enth-iteration/assets/textures/enemies"
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)
os.makedirs(TEX_DIR, exist_ok=True)


# === MATERIALS ===
mat_body    = make_pbr("Race_Body",    (0.04, 0.04, 0.05), 0.50, 0.40)
mat_magenta = make_pbr("Race_Magenta", (0.50, 0.0,  0.40), 0.20, 0.30, (1.0, 0.10, 0.85), 6.0)
mat_cyan    = make_pbr("Race_Cyan",    (0.0,  0.50, 0.50), 0.20, 0.30, (0.0, 0.95, 0.95), 6.0)
mat_eye     = make_pbr("Race_Eye",     (0.20, 0.0,  0.20), 0.0,  0.10, (1.0, 0.10, 0.85), 10.0)

root = bpy.data.objects.new("RaceCondition_Root", None)
bpy.context.scene.collection.objects.link(root)


# === GEOMETRY ===
# Spherical body — slightly flattened
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=24, v_segments=14, radius=0.32)
for v in bm.verts:
    v.co.z *= 0.85
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
body = create_mesh("race_body", bm, (0, 0, 0.50), mat_body, root)
mod = body.modifiers.new("Subsurf", 'SUBSURF')
mod.levels = 1
mod.render_levels = 2

# 3 magenta accent stripes wrapping the body horizontally
for i, z_off in enumerate([-0.15, 0.0, 0.15]):
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, segments=24, radius=0.34, cap_ends=False)
    rot = Matrix.Rotation(math.radians(90), 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    # Extrude into a thin ring band
    inner_verts = []
    for v in bm.verts:
        inner_verts.append(v.co.copy())
    for v_co in inner_verts:
        bm.verts.new(v_co * 0.97)
    bm.verts.ensure_lookup_table()
    n = len(inner_verts)
    for i_v in range(n):
        a = bm.verts[i_v]
        b = bm.verts[(i_v + 1) % n]
        c = bm.verts[n + (i_v + 1) % n]
        d = bm.verts[n + i_v]
        try:
            bm.faces.new([a, b, c, d])
        except ValueError:
            pass
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    mat = mat_magenta if i % 2 == 0 else mat_cyan
    create_mesh(f"race_stripe_{i+1}", bm, (0, 0, 0.50 + z_off), mat, root)

# Single eye — cyan + magenta dot
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=8, radius=0.05)
for v in bm.verts:
    v.co.y *= 0.5
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("race_eye", bm, (0, -0.30, 0.55), mat_eye, root)

# 4 limbs at IRREGULAR angles — that's the species tell
# Each limb: 2-segment chain ending in a small claw
limb_anchors = [
    ("FR", ( 0.20, -0.20,  0.50),  1.0,  -1.0,  0.0),  # front-right, angled outward
    ("FL", (-0.20, -0.10,  0.65), -1.0,  -0.7,  0.6),  # front-left, angled UP
    ("BR", ( 0.10,  0.25,  0.40),  0.6,   1.0, -0.5),  # back-right, angled DOWN
    ("BL", (-0.25,  0.05,  0.55), -1.0,   0.5,  0.3),  # back-left, angled outward+up
]

for label, base_pos, dx, dy, dz in limb_anchors:
    pos = Vector(base_pos)
    direction = Vector((dx, dy, dz)).normalized()
    # Segment 1
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=10, radius1=0.05, radius2=0.04, depth=0.30, cap_ends=True)
    rotate_to_dir(bm, direction)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"race_limb_{label}_seg1", bm, tuple(pos + direction * 0.15), mat_body, root)
    pos = pos + direction * 0.30
    # Segment 2 — slight bend
    direction2 = Vector((direction.x * 0.7, direction.y * 0.7, direction.z * 1.3)).normalized()
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=10, radius1=0.04, radius2=0.025, depth=0.25, cap_ends=True)
    rotate_to_dir(bm, direction2)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"race_limb_{label}_seg2", bm, tuple(pos + direction2 * 0.125), mat_body, root)
    pos = pos + direction2 * 0.25
    # Tip claw — small magenta tip for the chromatic accent
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=8, v_segments=6, radius=0.025)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"race_limb_{label}_tip", bm, tuple(pos), mat_magenta, root)


# === LOD0 + UV + BAKE + ALBEDO ===
def collect_visible_meshes():
    return [o for o in bpy.context.scene.objects if o.type == 'MESH']


lod0 = build_joined_lod("RaceCondition_LOD0", collect_visible_meshes(), 1800, "RaceCondition_")
smart_uv_unwrap(lod0)
hp = build_high_poly("RaceCondition_HP", collect_visible_meshes(), "RaceCondition_")
img_normal, img_ao, img_cavity, img_curv = bake_pbr_set(lod0, hp, "race_condition", TEX_DIR)


# === ALBEDO — glitchy magenta+cyan stripes ===
W, H = 1024, 1024
ao_arr = img_to_array(img_ao)[:, :, 0]
curv_arr = img_to_array(img_curv)[:, :, 0]

y = np.linspace(0, 1, H, dtype=np.float32)[:, None]
x = np.linspace(0, 1, W, dtype=np.float32)[None, :]

# Striped pattern: alternating magenta + cyan horizontal bands
stripe = np.sin(y * 18.0 * 2 * math.pi) * 0.5 + 0.5
mag = (stripe > 0.55).astype(np.float32)
cyn = (stripe < 0.45).astype(np.float32)

# Base dark body
out = np.zeros((H, W, 4), dtype=np.float32)
out[:, :, 0] = 0.04
out[:, :, 1] = 0.04
out[:, :, 2] = 0.05
out[:, :, 3] = 1.0
out[:, :, :3] *= (0.50 + 0.50 * ao_arr[:, :, None])

# Apply stripes
mag_color = np.array([0.85, 0.05, 0.55], dtype=np.float32)
cyn_color = np.array([0.0, 0.85, 0.85], dtype=np.float32)
for c in range(3):
    out[:, :, c] = (out[:, :, c] * (1.0 - mag * 0.75) + mag_color[c] * (mag * 0.75))
    out[:, :, c] = (out[:, :, c] * (1.0 - cyn * 0.75) + cyn_color[c] * (cyn * 0.75))

# Glitch noise overlay — random RGB shifts simulating chromatic aberration baked into albedo
fine_noise = hash_noise(x, y, 80.0)
glitch_band = (fine_noise > 0.95).astype(np.float32)
out[:, :, 0] += glitch_band * 0.4
out[:, :, 2] -= glitch_band * 0.2

# Edge highlight
edge_mask = np.clip((curv_arr - 0.55) / 0.45, 0.0, 1.0) ** 1.4
edge_color = np.array([1.0, 1.0, 1.0], dtype=np.float32)
for c in range(3):
    out[:, :, c] = out[:, :, c] * (1.0 - edge_mask * 0.30) + edge_color[c] * (edge_mask * 0.30)

out = np.clip(out, 0.0, 1.0)
write_albedo("race_condition_albedo", out, TEX_DIR)


# === RIG (10 bones — body + 4 limbs × 2 segments) ===
arm_data = bpy.data.armatures.new("RaceCondition_Armature")
arm_obj = bpy.data.objects.new("Armature_RaceCondition", arm_data)
bpy.context.scene.collection.objects.link(arm_obj)
arm_obj.show_in_front = True
bpy.context.view_layer.objects.active = arm_obj
bpy.ops.object.mode_set(mode='EDIT')
eb = arm_data.edit_bones


def add_bone(name, head, tail, parent=None, connect=False):
    b = eb.new(name)
    b.head = Vector(head)
    b.tail = Vector(tail)
    if parent is not None:
        b.parent = parent
        b.use_connect = connect
    return b


root_b = add_bone("root", (0, 0, 0), (0, 0, 0.20))
body_b = add_bone("body", (0, 0, 0.50), (0, 0, 0.65), root_b)

# 4 limbs
for label, base_pos, dx, dy, dz in limb_anchors:
    seg1 = add_bone(f"limb_{label}_seg1", base_pos,
                    (base_pos[0] + dx * 0.30, base_pos[1] + dy * 0.30, base_pos[2] + dz * 0.30), body_b)
    add_bone(f"limb_{label}_seg2",
             (base_pos[0] + dx * 0.30, base_pos[1] + dy * 0.30, base_pos[2] + dz * 0.30),
             (base_pos[0] + dx * 0.50, base_pos[1] + dy * 0.50, base_pos[2] + dz * 0.50), seg1, True)

bpy.ops.object.mode_set(mode='OBJECT')
print(f"  RaceCondition rig: {len(arm_data.bones)} bones")

lod0.hide_set(False)
lod0.parent = arm_obj
mod = lod0.modifiers.new("Armature", 'ARMATURE')
mod.object = arm_obj
mod.use_bone_envelopes = True
mod.use_vertex_groups = False

for bone in arm_data.bones:
    bone.envelope_distance = 0.40
    bone.head_radius = 0.20
    bone.tail_radius = 0.20


# === ANIMATIONS ===
arm_obj.animation_data_create()
bpy.ops.object.mode_set(mode='POSE')


def new_action(name):
    if bpy.data.actions.get(name):
        bpy.data.actions.remove(bpy.data.actions[name])
    return bpy.data.actions.new(name)


def rot(bone, exyz, frame):
    pb = arm_obj.pose.bones.get(bone)
    if pb is None:
        return
    pb.rotation_mode = 'XYZ'
    pb.rotation_euler = Euler([math.radians(a) for a in exyz], 'XYZ')
    pb.keyframe_insert(data_path="rotation_euler", frame=frame)


def loc(bone, l, frame):
    pb = arm_obj.pose.bones.get(bone)
    if pb is None:
        return
    pb.location = Vector(l)
    pb.keyframe_insert(data_path="location", frame=frame)


def scl(bone, s, frame):
    pb = arm_obj.pose.bones.get(bone)
    if pb is None:
        return
    pb.scale = Vector(s)
    pb.keyframe_insert(data_path="scale", frame=frame)


# 1. race_condition_idle (60-frame loop, twitchy)
act = new_action("race_condition_idle")
arm_obj.animation_data.action = act
total = 60
for f in range(0, total + 1, 4):
    t = f / float(total) * math.tau
    # Sharp jitter on body
    jitter = 1.0 + 0.025 * math.sin(t * 4.0)
    scl("body", (jitter, jitter, jitter), f)
    # Limbs twitch out of phase
    for i, label in enumerate(["FR", "FL", "BR", "BL"]):
        phase = i * 1.5
        rot(f"limb_{label}_seg1", (3.0 * math.sin(t * 3.0 + phase), 0, 0), f)
act.use_fake_user = True

# 2. race_condition_pursue (40-frame loop, fast scuttle)
act = new_action("race_condition_pursue")
arm_obj.animation_data.action = act
total = 40
for f in range(0, total + 1, 5):
    t = f / float(total) * math.tau
    # Body bobs forward-back
    loc("root", (0, 0.02 * math.sin(t * 2.0), 0.015 * math.sin(t * 4.0)), f)
    rot("body", (3.0 * math.sin(t * 2.0), 0, 0), f)
    # All limbs alternating pump
    for i, label in enumerate(["FR", "FL", "BR", "BL"]):
        phase = (i % 2) * math.pi
        rot(f"limb_{label}_seg1", (15.0 * math.sin(t * 2.0 + phase), 0, 0), f)
        rot(f"limb_{label}_seg2", (12.0 * math.sin(t * 2.0 + phase + 0.5), 0, 0), f)
act.use_fake_user = True

# 3. race_condition_melee (16 frames — lunge attack)
act = new_action("race_condition_melee")
arm_obj.animation_data.action = act
loc("root", (0, 0, 0), 0)
for label in ["FR", "FL", "BR", "BL"]:
    rot(f"limb_{label}_seg1", (0, 0, 0), 0)
# Lunge forward
loc("root", (0, -0.15, 0.05), 8)
for label in ["FR", "FL"]:
    rot(f"limb_{label}_seg1", (-30, 0, 0), 8)
    rot(f"limb_{label}_seg2", (20, 0, 0), 8)
# Settle
loc("root", (0, 0, 0), 16)
for label in ["FR", "FL", "BR", "BL"]:
    rot(f"limb_{label}_seg1", (0, 0, 0), 16)
    rot(f"limb_{label}_seg2", (0, 0, 0), 16)
act.use_fake_user = True

# 4. race_condition_split (15-frame — the species moment)
# Body inflates, then visibly compresses, then "vanishes" (scale 0) at frame 15.
# The actual spawn-2-copies is handled by the AI after this animation finishes.
act = new_action("race_condition_split")
arm_obj.animation_data.action = act
scl("body", (1, 1, 1), 0)
# Frames 0-6: violent inflation
scl("body", (1.5, 1.5, 1.5), 6)
for label in ["FR", "FL", "BR", "BL"]:
    rot(f"limb_{label}_seg1", (-20, 0, 0), 6)
# Frame 10: peak inflation + body strain
scl("body", (1.7, 1.7, 1.7), 10)
# Frame 15: SPLIT (scale collapses to 0 — AI spawns copies on this frame)
scl("body", (0.05, 0.05, 0.05), 15)
for label in ["FR", "FL", "BR", "BL"]:
    rot(f"limb_{label}_seg1", (-40, 0, 0), 15)
act.use_fake_user = True

# 5. race_condition_hit_react (10 frames)
act = new_action("race_condition_hit_react")
arm_obj.animation_data.action = act
loc("root", (0, 0, 0), 0)
loc("root", (0, 0.04, 0.02), 3)
rot("body", (-8, 4, 0), 3)
loc("root", (0, 0, 0), 10)
rot("body", (0, 0, 0), 10)
act.use_fake_user = True

# 6. race_condition_death (25 frames — chromatic burst then collapse)
act = new_action("race_condition_death")
arm_obj.animation_data.action = act
scl("body", (1, 1, 1), 0)
# Frame 5: inflate
scl("body", (1.4, 1.4, 1.4), 5)
# Frame 12: chromatic burst (rapid scale jitter)
scl("body", (0.8, 1.2, 0.8), 12)
scl("body", (1.3, 0.8, 1.3), 16)
# Frame 25: deflate to nothing
scl("body", (0.05, 0.05, 0.05), 25)
for label in ["FR", "FL", "BR", "BL"]:
    rot(f"limb_{label}_seg1", (45, 0, 25), 25)
act.use_fake_user = True


bpy.ops.object.mode_set(mode='OBJECT')
anim_count = len([a for a in bpy.data.actions if a.name.startswith("race_condition_")])
print(f"  RaceCondition animations: {anim_count}")

bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
print(f"\nSaved: {OUT_BLEND}")
print(f"Total objects: {len([o for o in bpy.context.scene.objects if o.type == 'MESH'])}")
print("Race Condition full pipeline complete")
