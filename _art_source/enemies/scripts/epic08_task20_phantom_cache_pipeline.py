"""Epic 08 task 20 — Phantom Cache full pipeline.

Per the bible: 1.4m floating treasure chest with 4 dangling spider legs,
gold rim with glowing cyan keyhole, translucent ghost shimmer.

Run via:
    blender.exe --background --python _art_source/enemies/scripts/epic08_task20_phantom_cache_pipeline.py
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

OUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/enemy_phantom_cache.blend"
TEX_DIR = "C:/Users/hwash/Documents/enth-iteration/assets/textures/enemies"
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)


# === MATERIALS ===
mat_wood    = make_pbr("Phantom_Wood",  (0.30, 0.18, 0.08), 0.0, 0.65)  # warm dark wood
mat_gold    = make_pbr("Phantom_Gold",  (0.95, 0.75, 0.20), 1.0, 0.15, (1.0, 0.85, 0.30), 1.5)
mat_keyhole = make_pbr("Phantom_Keyhole",(0.0, 0.30, 0.40), 0.0, 0.05, (0.0, 0.95, 1.0), 10.0)
mat_leg     = make_pbr("Phantom_Leg",   (0.05, 0.05, 0.08), 0.40, 0.45)

root = bpy.data.objects.new("PhantomCache_Root", None)
bpy.context.scene.collection.objects.link(root)


# === GEOMETRY ===
# Chest body — main box (0.6 x 0.45 x 0.40)
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
for v in bm.verts:
    v.co.x *= 0.30
    v.co.y *= 0.225
    v.co.z *= 0.20
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
bmesh.ops.bevel(bm, geom=list(bm.edges) + list(bm.verts), offset=0.018, segments=2, affect='EDGES')
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("phantom_chest_main", bm, (0, 0, 0.95), mat_wood, root)

# Chest lid (slightly larger, sits on top with a small gap)
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
for v in bm.verts:
    v.co.x *= 0.32
    v.co.y *= 0.235
    v.co.z *= 0.10
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
bmesh.ops.bevel(bm, geom=list(bm.edges) + list(bm.verts), offset=0.018, segments=2, affect='EDGES')
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("phantom_chest_lid", bm, (0, 0, 1.18), mat_wood, root)

# Gold trim — 4 horizontal bands wrapping the chest
for i, z in enumerate([0.78, 0.92, 1.08, 1.20]):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 0.32
        v.co.y *= 0.236
        v.co.z *= 0.018
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"phantom_gold_band_{i+1}", bm, (0, 0, z), mat_gold, root)

# Gold corner caps — 8 cubes at the chest corners
for sx in [-1, 1]:
    for sy in [-1, 1]:
        for sz_label, sz in [("bot", 0.78), ("top", 1.18)]:
            bm = bmesh.new()
            bmesh.ops.create_cube(bm, size=1.0)
            for v in bm.verts:
                v.co.x *= 0.045
                v.co.y *= 0.045
                v.co.z *= 0.045
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
            create_mesh(f"phantom_corner_{sx}_{sy}_{sz_label}", bm,
                        (0.30 * sx, 0.225 * sy, sz), mat_gold, root)

# Keyhole — front-facing cyan
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.04)
for v in bm.verts:
    v.co.y *= 0.4
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("phantom_keyhole", bm, (0, -0.235, 0.95), mat_keyhole, root)

# Keyhole "key slot" cube outline
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
for v in bm.verts:
    v.co.x *= 0.035
    v.co.y *= 0.005
    v.co.z *= 0.06
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("phantom_keyhole_slot", bm, (0, -0.232, 0.93), mat_keyhole, root)

# 4 dangling spider legs (the species tell)
leg_anchors = [
    ("FR", ( 0.22, -0.18, 0.78)),
    ("FL", (-0.22, -0.18, 0.78)),
    ("BR", ( 0.22,  0.18, 0.78)),
    ("BL", (-0.22,  0.18, 0.78)),
]
for label, base_pos in leg_anchors:
    pos = Vector(base_pos)
    direction = Vector((0, 0, -1.0)).normalized()  # straight down
    seg_lengths = [0.25, 0.30, 0.20]
    radii = [0.025, 0.020, 0.012]
    for seg_idx, (length, radius) in enumerate(zip(seg_lengths, radii)):
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=8, radius1=radius, radius2=radius * 0.85,
                              depth=length, cap_ends=True)
        rotate_to_dir(bm, direction)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"phantom_leg_{label}_seg{seg_idx+1}", bm,
                    tuple(pos + direction * (length * 0.5)), mat_leg, root)
        pos = pos + direction * length
        # Bend slightly outward
        outward = Vector((base_pos[0], base_pos[1], 0)).normalized()
        direction = (direction + outward * 0.15).normalized()


# === LOD0 + UV + BAKE + ALBEDO ===
def collect_visible_meshes():
    return [o for o in bpy.context.scene.objects if o.type == 'MESH']


lod0 = build_joined_lod("PhantomCache_LOD0", collect_visible_meshes(), 1900, "PhantomCache_")
smart_uv_unwrap(lod0)
hp = build_high_poly("PhantomCache_HP", collect_visible_meshes(), "PhantomCache_")
img_normal, img_ao, img_cavity, img_curv = bake_pbr_set(lod0, hp, "phantom_cache", TEX_DIR)


# === ALBEDO — wood + gold trim + cyan keyhole glow ===
W, H = 1024, 1024
ao_arr = img_to_array(img_ao)[:, :, 0]
curv_arr = img_to_array(img_curv)[:, :, 0]

y = np.linspace(0, 1, H, dtype=np.float32)[:, None]
x = np.linspace(0, 1, W, dtype=np.float32)[None, :]

cell_noise = hash_noise(x, y, 24.0)

# Warm wood base
out = np.zeros((H, W, 4), dtype=np.float32)
out[:, :, 0] = 0.32
out[:, :, 1] = 0.20
out[:, :, 2] = 0.10
out[:, :, 3] = 1.0
# Wood grain variation
out[:, :, :3] *= (0.85 + 0.30 * cell_noise[:, :, None])
# AO multiply
out[:, :, :3] *= (0.55 + 0.45 * ao_arr[:, :, None])
# Edge highlights → bright gold (the gold trim becomes brighter on edges)
edge_mask = np.clip((curv_arr - 0.55) / 0.45, 0.0, 1.0) ** 1.4
gold_color = np.array([0.98, 0.78, 0.22], dtype=np.float32)
for c in range(3):
    out[:, :, c] = out[:, :, c] * (1.0 - edge_mask * 0.65) + gold_color[c] * (edge_mask * 0.65)
# Cavity darkens slightly
cav_mask = np.clip((0.45 - curv_arr) / 0.20, 0.0, 1.0) ** 1.2
out[:, :, :3] *= (1.0 - cav_mask[:, :, None] * 0.30)
out = np.clip(out, 0.0, 1.0)
write_albedo("phantom_cache_albedo", out, TEX_DIR)


# === RIG (10 bones — root + chest + lid + 4 legs × 1 each (fake spider) + keyhole) ===
arm_data = bpy.data.armatures.new("PhantomCache_Armature")
arm_obj = bpy.data.objects.new("Armature_PhantomCache", arm_data)
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


root_b = add_bone("root", (0, 0, 0), (0, 0, 0.75))
chest_b = add_bone("chest", (0, 0, 0.75), (0, 0, 1.10), root_b, True)
lid_b = add_bone("lid", (0, 0, 1.10), (0, 0, 1.25), chest_b, True)
keyhole_b = add_bone("keyhole", (0, -0.20, 0.95), (0, -0.30, 0.95), chest_b)

for label, base_pos in leg_anchors:
    add_bone(f"leg_{label}", base_pos, (base_pos[0] * 1.4, base_pos[1] * 1.4, 0.05), root_b)

bpy.ops.object.mode_set(mode='OBJECT')
print(f"  PhantomCache rig: {len(arm_data.bones)} bones")

lod0.hide_set(False)
lod0.parent = arm_obj
mod = lod0.modifiers.new("Armature", 'ARMATURE')
mod.object = arm_obj
mod.use_bone_envelopes = True
mod.use_vertex_groups = False

for bone in arm_data.bones:
    bone.envelope_distance = 0.30
    bone.head_radius = 0.18
    bone.tail_radius = 0.18


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


# 1. phantom_cache_idle (60-frame loop, hover bob with leg sway)
act = new_action("phantom_cache_idle")
arm_obj.animation_data.action = act
total = 60
for f in range(0, total + 1, 5):
    t = f / float(total) * math.tau
    loc("root", (0, 0, 0.04 * math.sin(t)), f)
    rot("chest", (1.5 * math.sin(t * 0.5), 0, 2.0 * math.sin(t * 0.3)), f)
    # Legs sway slightly
    for label in ["FR", "FL", "BR", "BL"]:
        rot(f"leg_{label}", (3.0 * math.sin(t * 0.7), 0, 0), f)
    # Keyhole pulses
    scl("keyhole", (1.0 + 0.10 * math.sin(t * 1.5),) * 3, f)
act.use_fake_user = True

# 2. phantom_cache_flee (40-frame loop, fast runaway with frantic leg pump)
act = new_action("phantom_cache_flee")
arm_obj.animation_data.action = act
total = 40
for f in range(0, total + 1, 4):
    t = f / float(total) * math.tau
    loc("root", (0, 0.025 * math.sin(t * 3.0), 0.06 * math.sin(t * 4.0)), f)
    rot("chest", (-5 + 2.0 * math.sin(t * 3.0), 0, 0), f)
    # Frantic leg pump
    for i, label in enumerate(["FR", "FL", "BR", "BL"]):
        phase = (i % 2) * math.pi
        rot(f"leg_{label}", (15.0 * math.sin(t * 3.0 + phase), 0, 0), f)
act.use_fake_user = True

# 3. phantom_cache_lid_open (10 frames — quick reveal pose)
act = new_action("phantom_cache_lid_open")
arm_obj.animation_data.action = act
rot("lid", (0, 0, 0), 0)
rot("lid", (-45, 0, 0), 6)  # lid swings open
rot("lid", (-50, 0, 0), 10)
act.use_fake_user = True

# 4. phantom_cache_hit_react (10 frames)
act = new_action("phantom_cache_hit_react")
arm_obj.animation_data.action = act
loc("root", (0, 0, 0), 0)
loc("root", (0, 0.05, 0.03), 3)
rot("chest", (-8, 4, 0), 3)
loc("root", (0, 0, 0), 10)
rot("chest", (0, 0, 0), 10)
act.use_fake_user = True

# 5. phantom_cache_death (30 frames — chest opens with golden burst then collapses)
act = new_action("phantom_cache_death")
arm_obj.animation_data.action = act
rot("lid", (0, 0, 0), 0)
scl("keyhole", (1, 1, 1), 0)
# Frame 8: lid bursts open + keyhole flares
rot("lid", (-90, 0, 0), 8)
scl("keyhole", (3.0, 3.0, 3.0), 8)
loc("root", (0, 0, 0.10), 8)
# Frame 18: keyhole peaks + chest tilts
scl("keyhole", (2.5, 2.5, 2.5), 18)
rot("chest", (15, 0, 0), 18)
# Frame 30: chest drops to ground + legs splay
loc("root", (0, 0, -0.85), 30)
rot("chest", (25, 0, 0), 30)
scl("keyhole", (0.0, 0.0, 0.0), 30)
for label in ["FR", "FL", "BR", "BL"]:
    rot(f"leg_{label}", (40, 0, 20), 30)
act.use_fake_user = True


bpy.ops.object.mode_set(mode='OBJECT')
anim_count = len([a for a in bpy.data.actions if a.name.startswith("phantom_cache_")])
print(f"  PhantomCache animations: {anim_count}")

bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
print(f"\nSaved: {OUT_BLEND}")
print(f"Total objects: {len([o for o in bpy.context.scene.objects if o.type == 'MESH'])}")
print("Phantom Cache full pipeline complete")
