"""Epic 08 task 14 — Deadlock full pipeline.

Per the bible: 2.0m 4-armed spider turret rooted to the ground via heavy
base. Each arm holds a different attack: 2 chain-launchers + 2
shield-breakers. Cannot walk. Dark steel + crimson chains.

Run via:
    blender.exe --background --python _art_source/enemies/scripts/epic08_task14_deadlock_pipeline.py
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

OUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/enemy_deadlock.blend"
TEX_DIR = "C:/Users/hwash/Documents/enth-iteration/assets/textures/enemies"
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)


# === MATERIALS ===
mat_steel    = make_pbr("Deadlock_Steel",   (0.06, 0.06, 0.07), 1.0, 0.40)
mat_chain    = make_pbr("Deadlock_Chain",   (0.20, 0.04, 0.04), 0.85, 0.55, (1.0, 0.10, 0.05), 4.0)
mat_eye      = make_pbr("Deadlock_Eye",     (0.20, 0.0, 0.0),   0.0,  0.05, (1.0, 0.10, 0.05), 10.0)
mat_dark     = make_pbr("Deadlock_DarkPlate",(0.04, 0.04, 0.05), 1.0, 0.30)

root = bpy.data.objects.new("Deadlock_Root", None)
bpy.context.scene.collection.objects.link(root)


# === GEOMETRY ===
# Heavy base — wide ground anchor (rooted)
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=20, radius1=0.85, radius2=0.75, depth=0.40, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("deadlock_base", bm, (0, 0, 0.20), mat_dark, root)

# 4 anchor brace bolts at the base perimeter
for i in range(4):
    angle = (i / 4.0) * math.tau + math.pi/4
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=10, radius1=0.10, radius2=0.10, depth=0.18, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"deadlock_anchor_{i+1}", bm,
                (math.cos(angle) * 0.78, math.sin(angle) * 0.78, 0.10), mat_steel, root)

# Central body — squat dome with the eye recess
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=22, v_segments=12, radius=0.45)
for v in bm.verts:
    v.co.z *= 0.75
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
body = create_mesh("deadlock_body", bm, (0, 0, 0.85), mat_steel, root)
mod = body.modifiers.new("Subsurf", 'SUBSURF')
mod.levels = 1
mod.render_levels = 2

# Single horizontal red eye slit on the front of the body
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
for v in bm.verts:
    v.co.x *= 0.30
    v.co.y *= 0.025
    v.co.z *= 0.04
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("deadlock_eye_slit", bm, (0, -0.42, 0.95), mat_eye, root)

# 4 arms protruding spider-style from the body
# Each arm: shoulder mount + 2 thin tapered segments + chain anchor
arm_anchors = [
    ("FR", ( 0.45, -0.25, 0.95),  1.0, -0.6, -0.2),  # front right
    ("FL", (-0.45, -0.25, 0.95), -1.0, -0.6, -0.2),  # front left
    ("BR", ( 0.45,  0.25, 0.95),  1.0,  0.6, -0.2),  # back right
    ("BL", (-0.45,  0.25, 0.95), -1.0,  0.6, -0.2),  # back left
]

for label, base_pos, dx, dy, dz in arm_anchors:
    pos = Vector(base_pos)
    direction = Vector((dx, dy, dz)).normalized()
    # Shoulder ball joint
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=8, radius=0.10)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"deadlock_arm_{label}_shoulder", bm, tuple(pos), mat_steel, root)
    # Segment 1
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=10, radius1=0.07, radius2=0.06, depth=0.45, cap_ends=True)
    rotate_to_dir(bm, direction)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"deadlock_arm_{label}_seg1", bm, tuple(pos + direction * 0.225), mat_steel, root)
    pos = pos + direction * 0.45
    # Segment 2 — bent slightly down toward ground
    direction2 = Vector((direction.x * 0.8, direction.y * 0.8, direction.z - 0.6)).normalized()
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=10, radius1=0.06, radius2=0.04, depth=0.40, cap_ends=True)
    rotate_to_dir(bm, direction2)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"deadlock_arm_{label}_seg2", bm, tuple(pos + direction2 * 0.20), mat_steel, root)
    pos = pos + direction2 * 0.40
    # Chain anchor / launcher tip
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=0.075, radius2=0.06, depth=0.10, cap_ends=True)
    rotate_to_dir(bm, direction2)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"deadlock_arm_{label}_launcher", bm, tuple(pos + direction2 * 0.05), mat_chain, root)

    # === VISIBLE HANGING CHAINS (the species silhouette tell) ===
    # 4 chain links hanging from each launcher tip
    chain_start = pos + direction2 * 0.10
    for link in range(4):
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=8, v_segments=6, radius=0.020)
        for v in bm.verts:
            v.co.z *= 0.6
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        link_pos = chain_start + Vector((0, 0, -0.06 * (link + 1)))
        create_mesh(f"deadlock_chain_{label}_{link+1}", bm, tuple(link_pos), mat_chain, root)


# === LOD0 + UV + BAKE + ALBEDO ===
def collect_visible_meshes():
    return [o for o in bpy.context.scene.objects if o.type == 'MESH']


lod0 = build_joined_lod("Deadlock_LOD0", collect_visible_meshes(), 2400, "Deadlock_")
smart_uv_unwrap(lod0)
hp = build_high_poly("Deadlock_HP", collect_visible_meshes(), "Deadlock_")
img_normal, img_ao, img_cavity, img_curv = bake_pbr_set(lod0, hp, "deadlock", TEX_DIR)


# === ALBEDO — dark steel + crimson chain accents ===
W, H = 1024, 1024
ao_arr = img_to_array(img_ao)[:, :, 0]
curv_arr = img_to_array(img_curv)[:, :, 0]
cav_arr = img_to_array(img_cavity)[:, :, 0]

y = np.linspace(0, 1, H, dtype=np.float32)[:, None]
x = np.linspace(0, 1, W, dtype=np.float32)[None, :]

cell_noise = hash_noise(x, y, 30.0)
fine_noise = hash_noise(x * 1.5, y * 1.1, 90.0)

# Dark steel base
out = np.zeros((H, W, 4), dtype=np.float32)
out[:, :, 0] = 0.06
out[:, :, 1] = 0.06
out[:, :, 2] = 0.07
out[:, :, 3] = 1.0
# Variation
out[:, :, :3] *= (0.85 + 0.30 * cell_noise[:, :, None])
# AO multiply
out[:, :, :3] *= (0.50 + 0.50 * ao_arr[:, :, None])
# Cavity tightening
out[:, :, :3] *= (0.65 + 0.35 * cav_arr[:, :, None])
# Crimson rust streaks via curvature concave detection
rust_mask = np.clip((0.45 - curv_arr) / 0.20, 0.0, 1.0) ** 1.4
rust_color = np.array([0.40, 0.05, 0.02], dtype=np.float32)
for c in range(3):
    out[:, :, c] = out[:, :, c] * (1.0 - rust_mask * 0.55) + rust_color[c] * (rust_mask * 0.55)
# Edge highlight
edge_mask = np.clip((curv_arr - 0.55) / 0.45, 0.0, 1.0) ** 1.5
edge_color = np.array([0.25, 0.22, 0.22], dtype=np.float32)
for c in range(3):
    out[:, :, c] = out[:, :, c] * (1.0 - edge_mask * 0.55) + edge_color[c] * (edge_mask * 0.55)
# Sparse rust specks
spec = (fine_noise > 0.96).astype(np.float32) * 0.5
out[:, :, 0] += spec * 0.4
out[:, :, 1] += spec * 0.05
out[:, :, 2] += spec * 0.02
out = np.clip(out, 0.0, 1.0)
write_albedo("deadlock_albedo", out, TEX_DIR)


# === RIG (14 bones — root + body + 4 arms × 3 segments) ===
arm_data = bpy.data.armatures.new("Deadlock_Armature")
arm_obj = bpy.data.objects.new("Armature_Deadlock", arm_data)
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


root_b = add_bone("root", (0, 0, 0), (0, 0, 0.40))
body_b = add_bone("body", (0, 0, 0.40), (0, 0, 0.95), root_b, True)

for label, base_pos, dx, dy, dz in arm_anchors:
    sh = add_bone(f"arm_{label}_shoulder", base_pos,
                  (base_pos[0] + dx * 0.22, base_pos[1] + dy * 0.22, base_pos[2] + dz * 0.22), body_b)
    seg1 = add_bone(f"arm_{label}_seg1",
                    (base_pos[0] + dx * 0.22, base_pos[1] + dy * 0.22, base_pos[2] + dz * 0.22),
                    (base_pos[0] + dx * 0.45, base_pos[1] + dy * 0.45, base_pos[2] + dz * 0.45 - 0.20), sh)
    add_bone(f"arm_{label}_seg2",
             (base_pos[0] + dx * 0.45, base_pos[1] + dy * 0.45, base_pos[2] + dz * 0.45 - 0.20),
             (base_pos[0] + dx * 0.65, base_pos[1] + dy * 0.65, base_pos[2] + dz * 0.65 - 0.50), seg1, True)

bpy.ops.object.mode_set(mode='OBJECT')
print(f"  Deadlock rig: {len(arm_data.bones)} bones")

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


# 1. deadlock_idle (60-frame loop, scanning)
act = new_action("deadlock_idle")
arm_obj.animation_data.action = act
total = 60
for f in range(0, total + 1, 5):
    t = f / float(total) * math.tau
    # Body rotates slowly scanning
    rot("body", (0, 0, 6.0 * math.sin(t * 0.5)), f)
    # Arms slight wiggle (chains sway)
    for label in ["FR", "FL", "BR", "BL"]:
        rot(f"arm_{label}_seg2", (2.0 * math.sin(t * 0.7), 0, 0), f)
act.use_fake_user = True

# 2. deadlock_aim (24 frames — body + arms align with target)
act = new_action("deadlock_aim")
arm_obj.animation_data.action = act
rot("body", (0, 0, 0), 0)
for label in ["FR", "FL"]:
    rot(f"arm_{label}_seg1", (0, 0, 0), 0)
# Frame 12: lock onto target
rot("body", (-5, 0, 0), 12)
for label in ["FR", "FL"]:
    rot(f"arm_{label}_seg1", (-15, 0, 0), 12)
    rot(f"arm_{label}_seg2", (-25, 0, 0), 12)
# Frame 24: hold aim
for label in ["FR", "FL"]:
    rot(f"arm_{label}_seg1", (-15, 0, 0), 24)
act.use_fake_user = True

# 3. deadlock_fire (10 frames — chain launches)
act = new_action("deadlock_fire")
arm_obj.animation_data.action = act
for label in ["FR", "FL"]:
    rot(f"arm_{label}_seg1", (-15, 0, 0), 0)
# Frame 4: arm snaps forward (recoil)
for label in ["FR", "FL"]:
    rot(f"arm_{label}_seg1", (-30, 0, 0), 4)
    rot(f"arm_{label}_seg2", (-40, 0, 0), 4)
rot("body", (-10, 0, 0), 4)
# Frame 10: settle
for label in ["FR", "FL"]:
    rot(f"arm_{label}_seg1", (-15, 0, 0), 10)
    rot(f"arm_{label}_seg2", (-25, 0, 0), 10)
rot("body", (-5, 0, 0), 10)
act.use_fake_user = True

# 4. deadlock_drag (40-frame loop — chains pulling, body straining)
act = new_action("deadlock_drag")
arm_obj.animation_data.action = act
total = 40
for f in range(0, total + 1, 5):
    t = f / float(total) * math.tau
    # Body strains backward (anchored to floor)
    rot("body", (-3 + 1.5 * math.sin(t * 2.0), 0, 0), f)
    # Arms tense pulling
    for label in ["FR", "FL"]:
        rot(f"arm_{label}_seg1", (-20 + 2.0 * math.sin(t * 2.0), 0, 0), f)
        rot(f"arm_{label}_seg2", (-30 + 1.5 * math.sin(t * 2.0), 0, 0), f)
act.use_fake_user = True

# 5. deadlock_hit_react (12 frames)
act = new_action("deadlock_hit_react")
arm_obj.animation_data.action = act
rot("body", (0, 0, 0), 0)
rot("body", (-12, 4, 0), 4)
for label in ["FR", "FL", "BR", "BL"]:
    rot(f"arm_{label}_seg1", (10, 0, 0), 4)
rot("body", (0, 0, 0), 12)
for label in ["FR", "FL", "BR", "BL"]:
    rot(f"arm_{label}_seg1", (0, 0, 0), 12)
act.use_fake_user = True

# 6. deadlock_death (45 frames — chains snap + body slumps + collapse)
act = new_action("deadlock_death")
arm_obj.animation_data.action = act
loc("root", (0, 0, 0), 0)
rot("body", (0, 0, 0), 0)
# Frame 6: arms go limp
for label in ["FR", "FL", "BR", "BL"]:
    rot(f"arm_{label}_seg1", (15, 0, 0), 6)
    rot(f"arm_{label}_seg2", (25, 0, 0), 6)
# Frame 18: body slumps forward
rot("body", (15, 0, 0), 18)
loc("root", (0, 0, -0.10), 18)
# Frame 30: arms splay outward (chains drag the limbs)
for label in ["FR", "FL"]:
    rot(f"arm_{label}_seg1", (25, 0, 15), 30)
    rot(f"arm_{label}_seg2", (35, 0, 0), 30)
for label in ["BR", "BL"]:
    rot(f"arm_{label}_seg1", (15, 0, -10), 30)
# Frame 45: final settle
loc("root", (0, 0, -0.20), 45)
rot("body", (20, 0, 5), 45)
act.use_fake_user = True


bpy.ops.object.mode_set(mode='OBJECT')
anim_count = len([a for a in bpy.data.actions if a.name.startswith("deadlock_")])
print(f"  Deadlock animations: {anim_count}")

bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
print(f"\nSaved: {OUT_BLEND}")
print(f"Total objects: {len([o for o in bpy.context.scene.objects if o.type == 'MESH'])}")
print("Deadlock full pipeline complete")
