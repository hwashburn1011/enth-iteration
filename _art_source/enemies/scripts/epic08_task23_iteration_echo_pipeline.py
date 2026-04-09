"""Epic 08 task 23 — Iteration Echo full pipeline.

Per the bible: 1.5m perfect Globbler silhouette with inverted monochrome
features, pure black with cyan rim, scrolling code rivulets where Globbler's
accent stripes are. Uses player skeleton.

For the Echo we approximate the Globbler silhouette with a procedural
humanoid (head + torso + arms + legs) that's deliberately stylized as
"Globbler from the negative" — same proportions but inverted material.

Run via:
    blender.exe --background --python _art_source/enemies/scripts/epic08_task23_iteration_echo_pipeline.py
"""
import bpy
import bmesh
import os
import sys
import math
import numpy as np
from mathutils import Vector, Matrix, Euler

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

OUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/enemy_iteration_echo.blend"
TEX_DIR = "C:/Users/hwash/Documents/enth-iteration/assets/textures/enemies"
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)


# === MATERIALS ===
mat_void   = make_pbr("Echo_Void",   (0.005, 0.005, 0.008), 0.05, 0.55)
mat_cyan_rim = make_pbr("Echo_CyanRim",(0.0, 0.30, 0.40), 0.0, 0.20, (0.0, 0.95, 1.0), 5.0)
mat_eye    = make_pbr("Echo_Eye",    (0.0, 0.30, 0.40), 0.0, 0.05, (0.0, 0.95, 1.0), 12.0)

root = bpy.data.objects.new("IterationEcho_Root", None)
bpy.context.scene.collection.objects.link(root)


# === GEOMETRY (Globbler-shaped humanoid 1.5m tall) ===
# Globbler proportions: chunky humanoid, big head, short body, sturdy limbs

# Head (big)
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=24, v_segments=14, radius=0.22)
for v in bm.verts:
    v.co.y *= 0.95
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
head = create_mesh("echo_head", bm, (0, 0, 1.30), mat_void, root)
mod = head.modifiers.new("Subsurf", 'SUBSURF')
mod.levels = 1
mod.render_levels = 2

# Single cyan eye (the "you, but inverted" tell)
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=8, radius=0.05)
for v in bm.verts:
    v.co.y *= 0.5
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("echo_eye", bm, (0, -0.18, 1.32), mat_eye, root)

# Torso
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=20, v_segments=12, radius=0.25)
for v in bm.verts:
    v.co.y *= 0.65
    v.co.z *= 0.85
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
torso = create_mesh("echo_torso", bm, (0, 0, 0.90), mat_void, root)
mod = torso.modifiers.new("Subsurf", 'SUBSURF')
mod.levels = 1

# Hips
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=18, v_segments=10, radius=0.20)
for v in bm.verts:
    v.co.y *= 0.65
    v.co.z *= 0.65
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("echo_hips", bm, (0, 0, 0.65), mat_void, root)

# 3 cyan accent stripes (where Globbler's accent stripes are — across torso)
for i, z in enumerate([0.85, 0.95, 1.05]):
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, segments=22, radius=0.27 - i * 0.008, cap_ends=False)
    rot = Matrix.Rotation(math.radians(90), 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    # Extrude into ring
    inner = [v.co.copy() for v in bm.verts]
    for vco in inner:
        bm.verts.new(vco * 0.96)
    bm.verts.ensure_lookup_table()
    n = len(inner)
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
    create_mesh(f"echo_stripe_{i+1}", bm, (0, 0, z), mat_cyan_rim, root)

# Arms — upper arm + forearm + hand
for sx, label in [( 1, "R"), (-1, "L")]:
    # Shoulder
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=8, radius=0.10)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"echo_shoulder_{label}", bm, (0.27 * sx, 0, 1.05), mat_void, root)
    # Upper arm
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=0.08, radius2=0.07, depth=0.30, cap_ends=True)
    rot_180 = Matrix.Rotation(math.radians(180), 4, 'X')
    for v in bm.verts:
        v.co = rot_180 @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"echo_upper_arm_{label}", bm, (0.30 * sx, 0, 0.90), mat_void, root)
    # Forearm
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=0.07, radius2=0.06, depth=0.28, cap_ends=True)
    for v in bm.verts:
        v.co = rot_180 @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"echo_forearm_{label}", bm, (0.32 * sx, 0, 0.62), mat_void, root)
    # Hand
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.06)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"echo_hand_{label}", bm, (0.33 * sx, 0, 0.45), mat_void, root)

# Legs — thigh + shin + foot
for sx, label in [( 1, "R"), (-1, "L")]:
    # Thigh
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=0.10, radius2=0.085, depth=0.32, cap_ends=True)
    rot_180 = Matrix.Rotation(math.radians(180), 4, 'X')
    for v in bm.verts:
        v.co = rot_180 @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"echo_thigh_{label}", bm, (0.10 * sx, 0, 0.50), mat_void, root)
    # Shin
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=0.085, radius2=0.07, depth=0.30, cap_ends=True)
    for v in bm.verts:
        v.co = rot_180 @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"echo_shin_{label}", bm, (0.10 * sx, 0, 0.20), mat_void, root)
    # Foot
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.075)
    for v in bm.verts:
        v.co.y *= 1.5
        v.co.z *= 0.5
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"echo_foot_{label}", bm, (0.10 * sx, -0.03, 0.05), mat_void, root)


# === LOD0 + UV + BAKE + ALBEDO ===
def collect_visible_meshes():
    return [o for o in bpy.context.scene.objects if o.type == 'MESH']


lod0 = build_joined_lod("IterationEcho_LOD0", collect_visible_meshes(), 2400, "IterationEcho_")
smart_uv_unwrap(lod0)
hp = build_high_poly("IterationEcho_HP", collect_visible_meshes(), "IterationEcho_")
img_normal, img_ao, img_cavity, img_curv = bake_pbr_set(lod0, hp, "iteration_echo", TEX_DIR)


# === ALBEDO — pure black void with cyan rim glow + scrolling code feel ===
W, H = 1024, 1024
ao_arr = img_to_array(img_ao)[:, :, 0]
curv_arr = img_to_array(img_curv)[:, :, 0]

y = np.linspace(0, 1, H, dtype=np.float32)[:, None]
x = np.linspace(0, 1, W, dtype=np.float32)[None, :]

# Pure void base
out = np.zeros((H, W, 4), dtype=np.float32)
out[:, :, 0] = 0.005
out[:, :, 1] = 0.005
out[:, :, 2] = 0.010
out[:, :, 3] = 1.0
# AO multiply
out[:, :, :3] *= (0.40 + 0.60 * ao_arr[:, :, None])
# Cyan rim glow on edges (curv > 0.55)
edge_mask = np.clip((curv_arr - 0.55) / 0.45, 0.0, 1.0) ** 1.4
rim_color = np.array([0.0, 0.85, 1.0], dtype=np.float32)
for c in range(3):
    out[:, :, c] += rim_color[c] * edge_mask * 0.85
# ASCII character grid baked into the albedo (the code rivulet hint)
char_freq = 50.0
char_x = np.abs(np.sin(x * char_freq * 2 * math.pi))
char_y = np.abs(np.sin(y * char_freq * 2 * math.pi))
in_char_grid = (char_x > 0.85) & (char_y > 0.40)
char_on = (hash_noise(x * 1.7, y * 1.1, char_freq) > 0.55).astype(np.float32)
chars = (in_char_grid.astype(np.float32) * char_on)
out[:, :, 1] += chars * 0.40
out[:, :, 2] += chars * 0.50
out = np.clip(out, 0.0, 1.0)
write_albedo("iteration_echo_albedo", out, TEX_DIR)


# === RIG (16-bone humanoid — root + spine + chest + neck + head + 6 arm + 6 leg) ===
arm_data = bpy.data.armatures.new("IterationEcho_Armature")
arm_obj = bpy.data.objects.new("Armature_IterationEcho", arm_data)
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
hips = add_bone("hips", (0, 0, 0.65), (0, 0, 0.85), root_b)
spine = add_bone("spine", (0, 0, 0.85), (0, 0, 1.05), hips, True)
chest_b = add_bone("chest", (0, 0, 1.05), (0, 0, 1.20), spine, True)
neck = add_bone("neck", (0, 0, 1.20), (0, 0, 1.30), chest_b, True)
head_b = add_bone("head", (0, 0, 1.30), (0, 0, 1.50), neck, True)
# Arms
shR = add_bone("shoulder_R", (0.10, 0, 1.10), (0.27, 0, 1.05), chest_b)
upR = add_bone("upper_arm_R", (0.27, 0, 1.05), (0.30, 0, 0.75), shR, True)
fR  = add_bone("forearm_R", (0.30, 0, 0.75), (0.32, 0, 0.50), upR, True)
hR  = add_bone("hand_R", (0.32, 0, 0.50), (0.33, 0, 0.40), fR, True)
shL = add_bone("shoulder_L", (-0.10, 0, 1.10), (-0.27, 0, 1.05), chest_b)
upL = add_bone("upper_arm_L", (-0.27, 0, 1.05), (-0.30, 0, 0.75), shL, True)
fL  = add_bone("forearm_L", (-0.30, 0, 0.75), (-0.32, 0, 0.50), upL, True)
hL  = add_bone("hand_L", (-0.32, 0, 0.50), (-0.33, 0, 0.40), fL, True)
# Legs
thR = add_bone("thigh_R", ( 0.10, 0, 0.65), ( 0.10, 0, 0.35), hips)
shinR = add_bone("shin_R", ( 0.10, 0, 0.35), ( 0.10, -0.02, 0.05), thR, True)
thL = add_bone("thigh_L", (-0.10, 0, 0.65), (-0.10, 0, 0.35), hips)
shinL = add_bone("shin_L", (-0.10, 0, 0.35), (-0.10, -0.02, 0.05), thL, True)

bpy.ops.object.mode_set(mode='OBJECT')
print(f"  IterationEcho rig: {len(arm_data.bones)} bones")

lod0.hide_set(False)
lod0.parent = arm_obj
mod = lod0.modifiers.new("Armature", 'ARMATURE')
mod.object = arm_obj
mod.use_bone_envelopes = True
mod.use_vertex_groups = False

for bone in arm_data.bones:
    bone.envelope_distance = 0.25
    bone.head_radius = 0.13
    bone.tail_radius = 0.13


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


# 1. iteration_echo_idle (60-frame loop, alive breath)
act = new_action("iteration_echo_idle")
arm_obj.animation_data.action = act
total = 60
for f in range(0, total + 1, 5):
    t = f / float(total) * math.tau
    loc("root", (0, 0, 0.012 * math.sin(t)), f)
    rot("chest", (1.0 * math.sin(t * 0.5), 0, 0), f)
    rot("head", (0, 0, 3.0 * math.sin(t * 0.3)), f)
act.use_fake_user = True

# 2. iteration_echo_walk (40-frame walk cycle — same step rate as Globbler)
act = new_action("iteration_echo_walk")
arm_obj.animation_data.action = act
total = 40
for f in range(0, total + 1, 4):
    t = f / float(total) * math.tau
    loc("root", (0, 0, 0.025 * abs(math.sin(t * 2.0))), f)
    rot("chest", (3.0 * math.sin(t * 2.0), 0, 0), f)
    # Arms swing opposite to legs
    rot("upper_arm_R", (15 * math.sin(t * 2.0), 0, 0), f)
    rot("upper_arm_L", (15 * math.sin(t * 2.0 + math.pi), 0, 0), f)
    rot("thigh_R", (15 * math.sin(t * 2.0 + math.pi), 0, 0), f)
    rot("thigh_L", (15 * math.sin(t * 2.0), 0, 0), f)
    rot("shin_R", (10 * abs(math.sin(t * 2.0 + math.pi)), 0, 0), f)
    rot("shin_L", (10 * abs(math.sin(t * 2.0)), 0, 0), f)
act.use_fake_user = True

# 3. iteration_echo_attack (20 frames — mirrored player attack)
act = new_action("iteration_echo_attack")
arm_obj.animation_data.action = act
# Frame 0: ready
rot("upper_arm_R", (0, 0, 0), 0)
rot("forearm_R", (0, 0, 0), 0)
# Frame 6: wind back
rot("upper_arm_R", (-30, 0, -45), 6)
rot("forearm_R", (-60, 0, 0), 6)
rot("chest", (0, 0, 15), 6)
# Frame 12: STRIKE
rot("upper_arm_R", (-90, 0, 30), 12)
rot("forearm_R", (-20, 0, 0), 12)
rot("chest", (0, 0, -15), 12)
# Frame 20: settle
rot("upper_arm_R", (0, 0, 0), 20)
rot("forearm_R", (0, 0, 0), 20)
rot("chest", (0, 0, 0), 20)
act.use_fake_user = True

# 4. iteration_echo_dodge (12 frames — mirrors player dodge)
act = new_action("iteration_echo_dodge")
arm_obj.animation_data.action = act
loc("root", (0, 0, 0), 0)
rot("chest", (0, 0, 0), 0)
loc("root", (0.30, 0, 0.10), 6)  # quick side step
rot("chest", (0, 25, 10), 6)
loc("root", (0, 0, 0), 12)
rot("chest", (0, 0, 0), 12)
act.use_fake_user = True

# 5. iteration_echo_hit_react (12 frames)
act = new_action("iteration_echo_hit_react")
arm_obj.animation_data.action = act
loc("root", (0, 0, 0), 0)
rot("chest", (0, 0, 0), 0)
loc("root", (0, 0.05, 0.02), 3)
rot("chest", (-10, 4, 0), 3)
rot("head", (-12, -3, 0), 3)
loc("root", (0, 0, 0), 12)
rot("chest", (0, 0, 0), 12)
rot("head", (0, 0, 0), 12)
act.use_fake_user = True

# 6. iteration_echo_death (35 frames — slow dissolve collapse)
act = new_action("iteration_echo_death")
arm_obj.animation_data.action = act
loc("root", (0, 0, 0), 0)
rot("chest", (0, 0, 0), 0)
# Frame 8: knees buckle
loc("root", (0, 0, -0.15), 8)
rot("chest", (15, 0, 0), 8)
rot("thigh_R", (-30, 0, 0), 8)
rot("thigh_L", (-30, 0, 0), 8)
rot("shin_R", (60, 0, 0), 8)
rot("shin_L", (60, 0, 0), 8)
# Frame 18: forward fall
loc("root", (0, -0.10, -0.30), 18)
rot("chest", (40, 0, 0), 18)
rot("upper_arm_R", (60, 0, 30), 18)
rot("upper_arm_L", (60, 0, -30), 18)
# Frame 35: face-down on ground
loc("root", (0, -0.20, -0.55), 35)
rot("chest", (75, 0, 0), 35)
rot("head", (40, 0, 0), 35)
act.use_fake_user = True


bpy.ops.object.mode_set(mode='OBJECT')
anim_count = len([a for a in bpy.data.actions if a.name.startswith("iteration_echo_")])
print(f"  IterationEcho animations: {anim_count}")

bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
print(f"\nSaved: {OUT_BLEND}")
print(f"Total objects: {len([o for o in bpy.context.scene.objects if o.type == 'MESH'])}")
print("Iteration Echo full pipeline complete")
