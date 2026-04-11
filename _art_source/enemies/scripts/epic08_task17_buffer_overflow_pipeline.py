"""Epic 08 task 17 — Buffer Overflow full pipeline.

Per the bible: 1.8m starting growing to 3.5m bloated sphere with thin
spider legs, sickly green-yellow with magenta crack lines that grow
visibly. Walks slowly toward player while inflating. Explodes at full
inflation OR on death.

Run via:
    blender.exe --background --python _art_source/enemies/scripts/epic08_task17_buffer_overflow_pipeline.py
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

OUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/enemy_buffer_overflow.blend"
TEX_DIR = "C:/Users/hwash/Documents/enth-iteration/assets/textures/enemies"
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)


# === MATERIALS ===
mat_skin    = make_pbr("Buffer_Skin",   (0.30, 0.40, 0.10), 0.0, 0.65)  # sickly green-yellow
mat_crack   = make_pbr("Buffer_Crack",  (0.40, 0.0, 0.30),  0.0, 0.40, (1.0, 0.10, 0.85), 5.0)
mat_eye     = make_pbr("Buffer_Eye",    (0.40, 0.20, 0.0),  0.0, 0.05, (1.0, 0.55, 0.05), 8.0)
mat_leg     = make_pbr("Buffer_Leg",    (0.10, 0.12, 0.04), 0.40, 0.55)

root = bpy.data.objects.new("BufferOverflow_Root", None)
bpy.context.scene.collection.objects.link(root)


# === GEOMETRY ===
# Bloated sphere body — modeled at the BASELINE 1.8m size; runtime shader
# scales it. We're modeling the body at radius 0.45m.
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=28, v_segments=16, radius=0.45)
# Slight irregularity — bulges in random places
for v in bm.verts:
    bulge = 1.0 + 0.04 * math.sin(v.co.x * 8) * math.sin(v.co.y * 8) * math.sin(v.co.z * 6)
    v.co *= bulge
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
body = create_mesh("buffer_body", bm, (0, 0, 0.85), mat_skin, root)
mod = body.modifiers.new("Subsurf", 'SUBSURF')
mod.levels = 2
mod.render_levels = 2

# Single vertical eye (the "I'm about to pop" tell)
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=8, radius=0.06)
for v in bm.verts:
    v.co.x *= 0.4
    v.co.y *= 0.5
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("buffer_eye", bm, (0, -0.42, 0.95), mat_eye, root)

# 6 spider legs sprouting from the bottom hemisphere
# Each leg: 3 thin segments tapering down + outward
for i in range(6):
    angle = (i / 6.0) * math.tau
    # Anchor point on the lower body sphere
    anchor = Vector((math.cos(angle) * 0.40, math.sin(angle) * 0.40, 0.65))
    direction = Vector((math.cos(angle) * 0.6, math.sin(angle) * 0.6, -1.0)).normalized()
    pos = anchor.copy()
    seg_lengths = [0.30, 0.30, 0.20]
    radii = [0.035, 0.025, 0.015]
    for seg_idx, (length, radius) in enumerate(zip(seg_lengths, radii)):
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=8, radius1=radius, radius2=radius * 0.85,
                              depth=length, cap_ends=True)
        rotate_to_dir(bm, direction)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        seg_pos = pos + direction * (length * 0.5)
        create_mesh(f"buffer_leg_{i+1}_seg{seg_idx+1}", bm, tuple(seg_pos), mat_leg, root)
        pos = pos + direction * length
        # Bend each segment slightly more outward
        direction = Vector((direction.x * 1.05, direction.y * 1.05, direction.z * 0.85)).normalized()

# Crack ridges — 4 raised crack lines along the body (the warning tell)
for i in range(4):
    angle = (i / 4.0) * math.tau + math.pi / 8
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 0.04
        v.co.y *= 0.55
        v.co.z *= 0.025
    # Rotate around Z to face outward
    rot = Matrix.Rotation(angle, 4, 'Z')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    pos = (math.cos(angle) * 0.43, math.sin(angle) * 0.43, 0.85)
    create_mesh(f"buffer_crack_{i+1}", bm, pos, mat_crack, root)


# === LOD0 + UV + BAKE + ALBEDO ===
def collect_visible_meshes():
    return [o for o in bpy.context.scene.objects if o.type == 'MESH']


lod0 = build_joined_lod("BufferOverflow_LOD0", collect_visible_meshes(), 2200, "BufferOverflow_")
smart_uv_unwrap(lod0)
hp = build_high_poly("BufferOverflow_HP", collect_visible_meshes(), "BufferOverflow_")
img_normal, img_ao, img_cavity, img_curv = bake_pbr_set(lod0, hp, "buffer_overflow", TEX_DIR)


# === ALBEDO — sickly green-yellow with magenta crack lines ===
W, H = 1024, 1024
ao_arr = img_to_array(img_ao)[:, :, 0]
curv_arr = img_to_array(img_curv)[:, :, 0]
cav_arr = img_to_array(img_cavity)[:, :, 0]

y = np.linspace(0, 1, H, dtype=np.float32)[:, None]
x = np.linspace(0, 1, W, dtype=np.float32)[None, :]

cell_noise = hash_noise(x, y, 25.0)
fine_noise = hash_noise(x * 1.3, y * 0.95, 75.0)

# Sickly base — green-yellow flesh tones
out = np.zeros((H, W, 4), dtype=np.float32)
out[:, :, 0] = 0.32
out[:, :, 1] = 0.38
out[:, :, 2] = 0.10
out[:, :, 3] = 1.0
# Variation
out[:, :, :3] *= (0.85 + 0.30 * cell_noise[:, :, None])
# AO multiply
out[:, :, :3] *= (0.55 + 0.45 * ao_arr[:, :, None])
# Cavity tightening with magenta tint
cav_mask = np.clip((0.45 - curv_arr) / 0.20, 0.0, 1.0) ** 1.3
crack_color = np.array([0.85, 0.05, 0.55], dtype=np.float32)
for c in range(3):
    out[:, :, c] = out[:, :, c] * (1.0 - cav_mask * 0.65) + crack_color[c] * (cav_mask * 0.65)
# Edge highlight (the bulge tops)
edge_mask = np.clip((curv_arr - 0.55) / 0.45, 0.0, 1.0) ** 1.4
edge_color = np.array([0.55, 0.65, 0.20], dtype=np.float32)
for c in range(3):
    out[:, :, c] = out[:, :, c] * (1.0 - edge_mask * 0.45) + edge_color[c] * (edge_mask * 0.45)
# Sparse "pus" specks
spec = (fine_noise > 0.97).astype(np.float32) * 0.4
out[:, :, 0] += spec * 0.5
out[:, :, 1] += spec * 0.4
out[:, :, 2] += spec * 0.05
out = np.clip(out, 0.0, 1.0)
write_albedo("buffer_overflow_albedo", out, TEX_DIR)


# === RIG (8 bones — root + body + 6 leg roots) ===
arm_data = bpy.data.armatures.new("BufferOverflow_Armature")
arm_obj = bpy.data.objects.new("Armature_BufferOverflow", arm_data)
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
body_b = add_bone("body", (0, 0, 0.45), (0, 0, 1.25), root_b)

for i in range(6):
    angle = (i / 6.0) * math.tau
    base_pos = (math.cos(angle) * 0.40, math.sin(angle) * 0.40, 0.65)
    tip_pos = (math.cos(angle) * 1.0, math.sin(angle) * 1.0, 0.0)
    add_bone(f"leg_{i+1}", base_pos, tip_pos, body_b)

bpy.ops.object.mode_set(mode='OBJECT')
print(f"  BufferOverflow rig: {len(arm_data.bones)} bones")

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


# 1. buffer_overflow_idle (60-frame loop, slow breath)
act = new_action("buffer_overflow_idle")
arm_obj.animation_data.action = act
total = 60
for f in range(0, total + 1, 5):
    t = f / float(total) * math.tau
    breath = 1.0 + 0.020 * math.sin(t)
    scl("body", (breath, breath, breath), f)
    # Legs slight twitch
    for i in range(6):
        rot(f"leg_{i+1}", (2.0 * math.sin(t * 0.7 + i), 0, 0), f)
act.use_fake_user = True

# 2. buffer_overflow_walk (40-frame loop, slow shamble)
act = new_action("buffer_overflow_walk")
arm_obj.animation_data.action = act
total = 40
for f in range(0, total + 1, 4):
    t = f / float(total) * math.tau
    loc("root", (0, 0.005 * math.sin(t * 4.0), 0.02 * math.sin(t * 4.0)), f)
    rot("body", (3.0 * math.sin(t * 2.0), 0, 0), f)
    # Alternating leg pump (3 forward + 3 back at any moment)
    for i in range(6):
        phase = 0 if (i % 2 == 0) else math.pi
        rot(f"leg_{i+1}", (12.0 * math.sin(t * 2.0 + phase), 0, 0), f)
act.use_fake_user = True

# 3. buffer_overflow_inflate (60 frames — the warning, scales body 1.0 → 2.0)
# This is mostly handled by the runtime shader scaling _body_mesh, but we
# also keyframe a subtle pulse + leg strain on the bones.
act = new_action("buffer_overflow_inflate")
arm_obj.animation_data.action = act
scl("body", (1, 1, 1), 0)
for i in range(6):
    rot(f"leg_{i+1}", (0, 0, 0), 0)
# Frame 30: mid-inflation
scl("body", (1.4, 1.4, 1.4), 30)
for i in range(6):
    rot(f"leg_{i+1}", (-15, 0, 0), 30)  # legs splay outward as body grows
# Frame 60: peak (PRIMED)
scl("body", (2.0, 2.0, 2.0), 60)
for i in range(6):
    rot(f"leg_{i+1}", (-25, 0, 0), 60)
act.use_fake_user = True

# 4. buffer_overflow_explode (8 frames — peak pulse + scale 0)
act = new_action("buffer_overflow_explode")
arm_obj.animation_data.action = act
scl("body", (2.0, 2.0, 2.0), 0)
scl("body", (2.5, 2.5, 2.5), 4)  # peak bulge
scl("body", (0.0, 0.0, 0.0), 8)  # gone (the explosion VFX takes over)
for i in range(6):
    rot(f"leg_{i+1}", (45, 0, 0), 8)  # legs flung outward
act.use_fake_user = True

# 5. buffer_overflow_hit_react (10 frames)
act = new_action("buffer_overflow_hit_react")
arm_obj.animation_data.action = act
loc("root", (0, 0, 0), 0)
scl("body", (1, 1, 1), 0)
loc("root", (0, 0.04, 0.02), 3)
scl("body", (1.1, 0.9, 1.1), 3)  # squash sideways
loc("root", (0, 0, 0), 10)
scl("body", (1, 1, 1), 10)
act.use_fake_user = True

# 6. buffer_overflow_death (15 frames — same as explode but triggered early)
act = new_action("buffer_overflow_death")
arm_obj.animation_data.action = act
scl("body", (1, 1, 1), 0)
scl("body", (1.5, 1.5, 1.5), 5)  # quick pre-pop bulge
scl("body", (2.2, 2.2, 2.2), 8)
scl("body", (0.0, 0.0, 0.0), 15)
for i in range(6):
    rot(f"leg_{i+1}", (45, 0, 0), 15)
act.use_fake_user = True


bpy.ops.object.mode_set(mode='OBJECT')
anim_count = len([a for a in bpy.data.actions if a.name.startswith("buffer_overflow_")])
print(f"  BufferOverflow animations: {anim_count}")

bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
print(f"\nSaved: {OUT_BLEND}")
print(f"Total objects: {len([o for o in bpy.context.scene.objects if o.type == 'MESH'])}")
print("Buffer Overflow full pipeline complete")
