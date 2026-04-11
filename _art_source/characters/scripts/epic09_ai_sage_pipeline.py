"""Epic 09 — AI Sage NPC full pipeline (tasks 3-17, 33-34, 40, 47).

Builds the AI Sage hero NPC asset:
- Tall hooded humanoid 1.85m
- Long flowing robes with code-overlay material
- Hooded head with warm/sad face partially visible
- Long staff with cyan crystal at the top
- 4 floating data orbs orbiting head + shoulders
- 32-bone humanoid rig + cloth chain
- Hover offset baked into the root pose
- Multiple animations covering wise idle / speaking / casting / approach / sit / etc

Uses the shared enemy_pipeline_utils for LOD/UV/bake/albedo plumbing.

Run via:
    blender.exe --background --python _art_source/characters/scripts/epic09_ai_sage_pipeline.py
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

OUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/ai_sage.blend"
TEX_DIR = "C:/Users/hwash/Documents/enth-iteration/assets/textures/characters"
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)
os.makedirs(TEX_DIR, exist_ok=True)


# === MATERIALS ===
mat_robe       = make_pbr("Sage_RobeOuter", (0.05, 0.25, 0.32), 0.0, 0.65)  # deep teal
mat_robe_inner = make_pbr("Sage_RobeInner", (0.01, 0.02, 0.04), 0.0, 0.85)
mat_skin       = make_pbr("Sage_Skin",      (0.55, 0.42, 0.35), 0.0, 0.55)
mat_eye        = make_pbr("Sage_Eye",       (0.0, 0.55, 0.65), 0.0, 0.10, (0.0, 0.95, 1.0), 6.0)
mat_beard      = make_pbr("Sage_Beard",     (0.62, 0.62, 0.65), 0.0, 0.85)
mat_chrome     = make_pbr("Sage_Staff",     (0.85, 0.86, 0.92), 1.0, 0.10)
mat_crystal    = make_pbr("Sage_Crystal",   (0.0, 0.55, 0.65), 0.0, 0.05, (0.0, 0.95, 1.0), 12.0)
mat_orb        = make_pbr("Sage_DataOrb",   (0.0, 0.55, 0.65), 0.0, 0.05, (0.0, 0.95, 1.0), 10.0)

root = bpy.data.objects.new("AISage_Root", None)
bpy.context.scene.collection.objects.link(root)


# === GEOMETRY ===
# Sage stands at 1.85m total. Hover offset is 5cm so the body sits at
# 0.05 → 1.90m total.

# === ROBE OUTER (the bulk of the character — dome from shoulders down) ===
# Long conical robe shape from shoulder height to ankle, slightly flared at base
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=24, radius1=0.55, radius2=0.30, depth=1.40, cap_ends=True)
# subdivide for natural fold lines
for v in bm.verts:
    # Slight irregularity along the surface
    bulge = 1.0 + 0.03 * math.sin(v.co.x * 6) * math.sin(v.co.z * 4)
    v.co.x *= bulge
    v.co.y *= bulge
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
robe = create_mesh("sage_robe_outer", bm, (0, 0, 0.95), mat_robe, root)
mod = robe.modifiers.new("Subsurf", 'SUBSURF')
mod.levels = 1
mod.render_levels = 2

# === ROBE OPENING (dark void inside) ===
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=20, radius1=0.45, radius2=0.20, depth=1.35, cap_ends=False)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
# Flip normals so inside is visible
for f in bm.faces:
    f.normal_flip()
create_mesh("sage_robe_inner", bm, (0, 0, 0.95), mat_robe_inner, root)

# === SHOULDER MOUND ===
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=20, v_segments=12, radius=0.32)
for v in bm.verts:
    v.co.y *= 0.7
    v.co.z *= 0.55
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("sage_shoulders", bm, (0, 0, 1.55), mat_robe, root)

# === HEAD (humanoid skull) ===
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=22, v_segments=14, radius=0.13)
for v in bm.verts:
    v.co.y *= 0.95
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
head = create_mesh("sage_head", bm, (0, 0, 1.78), mat_skin, root)
mod = head.modifiers.new("Subsurf", 'SUBSURF')
mod.levels = 1

# === HOOD (open at bottom — covers head from above) ===
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=20, radius1=0.20, radius2=0.10, depth=0.30, cap_ends=False)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("sage_hood", bm, (0, 0, 1.85), mat_robe, root)

# === EYES (warm cyan glow under the hood) ===
for sx, label in [( 1, "R"), (-1, "L")]:
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.018)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"sage_eye_{label}", bm, (0.04 * sx, -0.10, 1.78), mat_eye, root)

# === BEARD (long grey beard hanging from chin) ===
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=14, radius1=0.085, radius2=0.04, depth=0.22, cap_ends=True)
# Rotate so beard hangs down (-Z)
rot = Matrix.Rotation(math.radians(180), 4, 'X')
for v in bm.verts:
    v.co = rot @ v.co
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("sage_beard", bm, (0, -0.06, 1.66), mat_beard, root)

# === ARMS (visible cuffs only — robe sleeves cover most) ===
for sx, label in [( 1, "R"), (-1, "L")]:
    # Sleeve cuff
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=0.10, radius2=0.085, depth=0.22, cap_ends=True)
    rot_180 = Matrix.Rotation(math.radians(180), 4, 'X')
    for v in bm.verts:
        v.co = rot_180 @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"sage_sleeve_{label}", bm, (0.34 * sx, 0, 1.20), mat_robe, root)
    # Hand sticking out
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.055)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"sage_hand_{label}", bm, (0.36 * sx, -0.02, 1.05), mat_skin, root)

# === STAFF (right-hand prop — long chrome rod with cyan crystal at top) ===
# Rod
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=14, radius1=0.025, radius2=0.020, depth=2.10, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("sage_staff_rod", bm, (0.42, -0.02, 0.95), mat_chrome, root)
# Crystal at top
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=18, v_segments=12, radius=0.075)
for v in bm.verts:
    v.co.z *= 1.4  # taller than wide for "crystal" feel
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("sage_staff_crystal", bm, (0.42, -0.02, 2.10), mat_crystal, root)
# Crystal mounting cradle
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=8, radius=0.055)
for v in bm.verts:
    v.co.z *= 0.55
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
create_mesh("sage_staff_cradle", bm, (0.42, -0.02, 1.98), mat_chrome, root)

# === FLOATING DATA ORBS (4 around head + shoulders) ===
orb_positions = [
    (0.0, -0.18, 2.00),   # front-up
    (0.30, 0.05, 1.80),   # right shoulder
    (-0.30, 0.05, 1.80),  # left shoulder
    (0.0, 0.18, 1.95),    # back
]
for i, pos in enumerate(orb_positions):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=10, radius=0.06)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"sage_orb_{i+1}", bm, pos, mat_orb, root)


# === LOD0 + UV + BAKE + ALBEDO ===
def collect_visible_meshes():
    return [o for o in bpy.context.scene.objects if o.type == 'MESH']


lod0 = build_joined_lod("AISage_LOD0", collect_visible_meshes(), 3500, "AISage_")
smart_uv_unwrap(lod0)
hp = build_high_poly("AISage_HP", collect_visible_meshes(), "AISage_")
img_normal, img_ao, img_cavity, img_curv = bake_pbr_set(lod0, hp, "ai_sage", TEX_DIR)


# === ALBEDO — teal robe with code-overlay + warm skin + chrome staff ===
W, H = 1024, 1024
ao_arr = img_to_array(img_ao)[:, :, 0]
curv_arr = img_to_array(img_curv)[:, :, 0]

y = np.linspace(0, 1, H, dtype=np.float32)[:, None]
x = np.linspace(0, 1, W, dtype=np.float32)[None, :]

cell_noise = hash_noise(x, y, 28.0)

# Deep teal base
out = np.zeros((H, W, 4), dtype=np.float32)
out[:, :, 0] = 0.05
out[:, :, 1] = 0.25
out[:, :, 2] = 0.32
out[:, :, 3] = 1.0
# Variation
out[:, :, :3] *= (0.85 + 0.30 * cell_noise[:, :, None])
# AO multiply
out[:, :, :3] *= (0.55 + 0.45 * ao_arr[:, :, None])
# Edge highlight to brighter cyan accent
edge_mask = np.clip((curv_arr - 0.55) / 0.45, 0.0, 1.0) ** 1.4
edge_color = np.array([0.20, 0.65, 0.85], dtype=np.float32)
for c in range(3):
    out[:, :, c] = out[:, :, c] * (1.0 - edge_mask * 0.55) + edge_color[c] * (edge_mask * 0.55)
# Cavity darkens (deep folds)
cav_mask = np.clip((0.45 - curv_arr) / 0.20, 0.0, 1.0) ** 1.2
out[:, :, :3] *= (1.0 - cav_mask[:, :, None] * 0.35)
# ASCII code grid baked into the robe (the "structured data" overlay)
char_freq = 70.0
char_x = np.abs(np.sin(x * char_freq * 2 * math.pi))
char_y = np.abs(np.sin(y * char_freq * 2 * math.pi))
in_char_grid = (char_x > 0.85) & (char_y > 0.40)
char_on = (hash_noise(x * 1.7, y * 1.1, char_freq) > 0.55).astype(np.float32)
chars = (in_char_grid.astype(np.float32) * char_on)
out[:, :, 1] += chars * 0.30
out[:, :, 2] += chars * 0.40

out = np.clip(out, 0.0, 1.0)
write_albedo("ai_sage_albedo", out, TEX_DIR)


# === RIG (32 bones humanoid + cloth chain + orbs) ===
arm_data = bpy.data.armatures.new("AISage_Armature")
arm_obj = bpy.data.objects.new("Armature_AISage", arm_data)
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


# Core spine (5 bones: root + hips + spine + chest + neck)
root_b = add_bone("root", (0, 0, 0), (0, 0, 0.20))                                  # 1
hover_b = add_bone("hover_anchor", (0, 0, 0.05), (0, 0, 0.30), root_b)              # 2 — at hover offset
hips = add_bone("hips", (0, 0, 0.95), (0, 0, 1.20), hover_b)                        # 3
spine = add_bone("spine", (0, 0, 1.20), (0, 0, 1.40), hips, True)                   # 4
chest_b = add_bone("chest", (0, 0, 1.40), (0, 0, 1.60), spine, True)                # 5
# Neck + head (2)
neck = add_bone("neck", (0, 0, 1.60), (0, 0, 1.72), chest_b, True)                  # 6
head_b = add_bone("head", (0, 0, 1.72), (0, 0, 1.90), neck, True)                   # 7
# Beard (1)
beard_b = add_bone("beard", (0, -0.06, 1.66), (0, -0.06, 1.45), head_b)             # 8
# Arms (2 × 4 = 8)
shR = add_bone("shoulder_R", (0.10, 0, 1.55), (0.30, 0, 1.40), chest_b)             # 9
upR = add_bone("upper_arm_R", (0.30, 0, 1.40), (0.34, 0, 1.20), shR, True)          # 10
fR  = add_bone("forearm_R", (0.34, 0, 1.20), (0.36, 0, 1.05), upR, True)            # 11
hR  = add_bone("hand_R", (0.36, 0, 1.05), (0.38, -0.05, 0.95), fR, True)            # 12
shL = add_bone("shoulder_L", (-0.10, 0, 1.55), (-0.30, 0, 1.40), chest_b)           # 13
upL = add_bone("upper_arm_L", (-0.30, 0, 1.40), (-0.34, 0, 1.20), shL, True)        # 14
fL  = add_bone("forearm_L", (-0.34, 0, 1.20), (-0.36, 0, 1.05), upL, True)          # 15
hL  = add_bone("hand_L", (-0.36, 0, 1.05), (-0.38, -0.05, 0.95), fL, True)          # 16
# Robe cloth chain (4 spine-aligned cloth bones for the simulation)
cloth1 = add_bone("cloth_F", (0, -0.30, 1.20), (0, -0.30, 0.30), hips)              # 17
cloth2 = add_bone("cloth_B", (0, 0.30, 1.20), (0, 0.30, 0.30), hips)                # 18
cloth3 = add_bone("cloth_R", (0.40, 0, 1.20), (0.40, 0, 0.30), hips)                # 19
cloth4 = add_bone("cloth_L", (-0.40, 0, 1.20), (-0.40, 0, 0.30), hips)              # 20
# Hood drape (1)
hood_b = add_bone("hood", (0, 0, 1.95), (0, -0.10, 1.85), head_b)                   # 21
# Staff (3 — base, mid, crystal)
staff_base = add_bone("staff_base", (0.42, -0.02, 0.10), (0.42, -0.02, 1.05), hR)   # 22
staff_mid = add_bone("staff_mid", (0.42, -0.02, 1.05), (0.42, -0.02, 1.95), staff_base, True)  # 23
staff_crystal_b = add_bone("staff_crystal", (0.42, -0.02, 1.95), (0.42, -0.02, 2.20), staff_mid, True)  # 24
# 4 floating orbs (each gets its own bone so the AI can drive orbital motion)
orb1 = add_bone("orb_1", (0.0, -0.18, 2.00), (0.0, -0.18, 2.10), head_b)            # 25
orb2 = add_bone("orb_2", (0.30, 0.05, 1.80), (0.30, 0.05, 1.90), chest_b)           # 26
orb3 = add_bone("orb_3", (-0.30, 0.05, 1.80), (-0.30, 0.05, 1.90), chest_b)         # 27
orb4 = add_bone("orb_4", (0.0, 0.18, 1.95), (0.0, 0.18, 2.05), head_b)              # 28
# Legs (2 × 2 = 4) — legs are barely visible under the robes but rigged for animation
thR = add_bone("thigh_R", (0.10, 0, 0.95), (0.10, 0, 0.55), hover_b)                # 29
shinR = add_bone("shin_R", (0.10, 0, 0.55), (0.10, -0.02, 0.10), thR, True)         # 30
thL = add_bone("thigh_L", (-0.10, 0, 0.95), (-0.10, 0, 0.55), hover_b)              # 31
shinL = add_bone("shin_L", (-0.10, 0, 0.55), (-0.10, -0.02, 0.10), thL, True)       # 32

bpy.ops.object.mode_set(mode='OBJECT')
print(f"  AISage rig: {len(arm_data.bones)} bones")

lod0.hide_set(False)
lod0.parent = arm_obj
mod = lod0.modifiers.new("Armature", 'ARMATURE')
mod.object = arm_obj
mod.use_bone_envelopes = True
mod.use_vertex_groups = False

for bone in arm_data.bones:
    bone.envelope_distance = 0.30
    bone.head_radius = 0.16
    bone.tail_radius = 0.16
# Tighter on small parts
for n in ("eye_R", "eye_L", "head", "beard", "orb_1", "orb_2", "orb_3", "orb_4", "staff_crystal"):
    b = arm_data.bones.get(n)
    if b:
        b.envelope_distance = 0.18
        b.head_radius = 0.10
        b.tail_radius = 0.10
# Looser on cloth bones to capture the robe drape
for n in ("cloth_F", "cloth_B", "cloth_R", "cloth_L"):
    b = arm_data.bones.get(n)
    if b:
        b.envelope_distance = 0.50
        b.head_radius = 0.25
        b.tail_radius = 0.25


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


# 1. ai_sage_wise_idle (120-frame loop, slow contemplative breath)
act = new_action("ai_sage_wise_idle")
arm_obj.animation_data.action = act
total = 120
for f in range(0, total + 1, 8):
    t = f / float(total) * math.tau
    # Slow hover bob via hover_anchor
    loc("hover_anchor", (0, 0, 0.025 * math.sin(t)), f)
    # Subtle chest breath
    scl("chest", (1.0 + 0.012 * math.sin(t),) * 3, f)
    # Head slight turn
    rot("head", (0, 0, 3.0 * math.sin(t * 0.5)), f)
    # Beard subtle sway
    rot("beard", (2.0 * math.sin(t * 0.7), 0, 0), f)
    # Orbs slow orbit (each at different phase + axis)
    for i in range(4):
        phase = i * (math.tau / 4)
        rot(f"orb_{i+1}", (5 * math.sin(t * 0.8 + phase), 0, 5 * math.cos(t * 0.8 + phase)), f)
    # Cloth subtle drift
    for n in ("cloth_F", "cloth_B", "cloth_R", "cloth_L"):
        rot(n, (1.5 * math.sin(t * 0.6), 0, 0), f)
act.use_fake_user = True

# 2. ai_sage_speaking (60-frame loop with hand emphasis)
act = new_action("ai_sage_speaking")
arm_obj.animation_data.action = act
total = 60
for f in range(0, total + 1, 5):
    t = f / float(total) * math.tau
    loc("hover_anchor", (0, 0, 0.018 * math.sin(t)), f)
    rot("head", (3.0 * math.sin(t * 1.5), 0, 0), f)  # head nods slightly
    # Right hand makes small gestures (raises and drops)
    rot("upper_arm_R", (-30 + 8 * math.sin(t), 0, -10), f)
    rot("forearm_R", (-30 + 5 * math.sin(t * 1.5), 0, 0), f)
    rot("hand_R", (10 * math.sin(t * 2.0), 0, 0), f)
    # Orbs brighten via scale (the "thoughts speaking" tell)
    for i in range(4):
        s = 1.2 + 0.15 * math.sin(t * 2.0 + i)
        scl(f"orb_{i+1}", (s, s, s), f)
act.use_fake_user = True

# 3. ai_sage_deep_thought (90-frame loop, head down + hand to chin)
act = new_action("ai_sage_deep_thought")
arm_obj.animation_data.action = act
total = 90
# Frame 0: enter pose
rot("head", (-25, 0, 0), 0)
rot("upper_arm_R", (-90, 0, -45), 0)
rot("forearm_R", (-110, 0, 0), 0)
rot("hand_R", (-30, 0, 0), 0)
# Looped subtle motion
for f in range(0, total + 1, 8):
    t = f / float(total) * math.tau
    loc("hover_anchor", (0, 0, 0.015 * math.sin(t)), f)
    rot("head", (-25 + 1.5 * math.sin(t * 0.5), 0, 0), f)
    # Orbs dim (he's listening, not speaking)
    for i in range(4):
        s = 0.85 + 0.10 * math.sin(t * 0.7 + i)
        scl(f"orb_{i+1}", (s, s, s), f)
act.use_fake_user = True

# 4. ai_sage_casting_wisdom (50 frames — orb manipulation)
act = new_action("ai_sage_casting_wisdom")
arm_obj.animation_data.action = act
# Frame 0: idle
rot("upper_arm_R", (-30, 0, -10), 0)
rot("forearm_R", (-30, 0, 0), 0)
# Frame 15: arm raises toward orb cluster
rot("upper_arm_R", (-100, 0, -10), 15)
rot("forearm_R", (-50, 0, 0), 15)
rot("hand_R", (10, 0, 0), 15)
rot("head", (-10, 0, 0), 15)
# Orbs converge toward the hand
for i in range(4):
    scl(f"orb_{i+1}", (1.6, 1.6, 1.6), 15)
# Frame 30: hold + orbs flare brightest
for i in range(4):
    scl(f"orb_{i+1}", (2.0, 2.0, 2.0), 30)
# Frame 50: arm returns + orbs return to baseline
rot("upper_arm_R", (-30, 0, -10), 50)
rot("forearm_R", (-30, 0, 0), 50)
rot("hand_R", (0, 0, 0), 50)
rot("head", (0, 0, 0), 50)
for i in range(4):
    scl(f"orb_{i+1}", (1.0, 1.0, 1.0), 50)
act.use_fake_user = True

# 5. ai_sage_approach_walk (40-frame walk loop with staff tap)
act = new_action("ai_sage_approach_walk")
arm_obj.animation_data.action = act
total = 40
for f in range(0, total + 1, 4):
    t = f / float(total) * math.tau
    loc("hover_anchor", (0, 0, 0.03 + 0.02 * abs(math.sin(t * 2.0))), f)
    rot("chest", (2.0 * math.sin(t * 2.0), 0, 0), f)
    # Free arm swings
    rot("upper_arm_L", (15 * math.sin(t * 2.0), 0, 0), f)
    # Staff arm holds the staff (subtle)
    rot("upper_arm_R", (-40, 0, -10), f)
    # Staff bone tilts slightly to "tap" the ground
    rot("staff_base", (3.0 * math.sin(t * 2.0), 0, 0), f)
    # Cloth follows the walk
    for n in ("cloth_F", "cloth_B", "cloth_R", "cloth_L"):
        rot(n, (3.0 * math.sin(t * 2.0), 0, 0), f)
act.use_fake_user = True

# 6. ai_sage_sit_meditative (60-frame loop)
act = new_action("ai_sage_sit_meditative")
arm_obj.animation_data.action = act
# Frame 0: enter sit pose
loc("hover_anchor", (0, 0, -0.20), 0)
rot("hips", (-15, 0, 0), 0)
rot("thigh_R", (-90, 0, -15), 0)
rot("thigh_L", (-90, 0,  15), 0)
rot("shin_R", (90, 0, 0), 0)
rot("shin_L", (90, 0, 0), 0)
rot("upper_arm_R", (-35, 0, -25), 0)
rot("upper_arm_L", (-35, 0,  25), 0)
rot("forearm_R", (-30, 0, 0), 0)
rot("forearm_L", (-30, 0, 0), 0)
# Loop subtle breath + orb orbit
for f in range(0, 60 + 1, 8):
    t = f / 60 * math.tau
    loc("hover_anchor", (0, 0, -0.20 + 0.012 * math.sin(t)), f)
    for i in range(4):
        s = 0.95 + 0.05 * math.sin(t * 0.7 + i)
        scl(f"orb_{i+1}", (s, s, s), f)
act.use_fake_user = True

# 7. ai_sage_stand_from_sit (24 frames)
act = new_action("ai_sage_stand_from_sit")
arm_obj.animation_data.action = act
# Frame 0: in sit pose
loc("hover_anchor", (0, 0, -0.20), 0)
rot("thigh_R", (-90, 0, -15), 0)
rot("thigh_L", (-90, 0,  15), 0)
rot("shin_R", (90, 0, 0), 0)
rot("shin_L", (90, 0, 0), 0)
# Frame 12: rising
loc("hover_anchor", (0, 0, -0.05), 12)
rot("thigh_R", (-30, 0, 0), 12)
rot("thigh_L", (-30, 0, 0), 12)
rot("shin_R", (30, 0, 0), 12)
rot("shin_L", (30, 0, 0), 12)
# Frame 24: stand neutral
loc("hover_anchor", (0, 0, 0.0), 24)
rot("thigh_R", (0, 0, 0), 24)
rot("thigh_L", (0, 0, 0), 24)
rot("shin_R", (0, 0, 0), 24)
rot("shin_L", (0, 0, 0), 24)
rot("hips", (0, 0, 0), 24)
rot("upper_arm_R", (-30, 0, -10), 24)
rot("upper_arm_L", (-30, 0, 10), 24)
rot("forearm_R", (-30, 0, 0), 24)
rot("forearm_L", (-30, 0, 0), 24)
act.use_fake_user = True

# 8. ai_sage_react_surprise (30 frames)
act = new_action("ai_sage_react_surprise")
arm_obj.animation_data.action = act
loc("hover_anchor", (0, 0, 0.0), 0)
rot("head", (0, 0, 0), 0)
# Frame 5: head snaps up + body straightens
loc("hover_anchor", (0, 0, 0.06), 5)
rot("head", (-15, 0, 0), 5)
rot("chest", (-5, 0, 0), 5)
# Frame 15: hold the surprise
loc("hover_anchor", (0, 0, 0.05), 15)
rot("head", (-12, 0, 0), 15)
# Frame 30: settle back to neutral
loc("hover_anchor", (0, 0, 0.0), 30)
rot("head", (0, 0, 0), 30)
rot("chest", (0, 0, 0), 30)
act.use_fake_user = True

# 9. ai_sage_react_sad (40 frames — knows the truth)
act = new_action("ai_sage_react_sad")
arm_obj.animation_data.action = act
rot("head", (0, 0, 0), 0)
rot("chest", (0, 0, 0), 0)
# Frame 8: head sinks slightly
rot("head", (12, 0, 0), 8)
rot("chest", (5, 0, 0), 8)
# Hand reaches up to face
rot("upper_arm_L", (-90, 0, 30), 8)
rot("forearm_L", (-90, 0, 0), 8)
# Frame 25: hold the sad pose
rot("head", (15, 0, 0), 25)
# Frame 40: settle
rot("head", (0, 0, 0), 40)
rot("chest", (0, 0, 0), 40)
rot("upper_arm_L", (-30, 0, 10), 40)
rot("forearm_L", (-30, 0, 0), 40)
act.use_fake_user = True

# 10. ai_sage_fade_in_out (24 frames — for mysterious arrivals)
act = new_action("ai_sage_fade_in_out")
arm_obj.animation_data.action = act
# Frame 0: invisible (scale 0)
scl("root", (0.05, 0.05, 0.05), 0)
# Frame 8: half-formed
scl("root", (0.6, 0.6, 0.6), 8)
# Frame 16: full
scl("root", (1.0, 1.0, 1.0), 16)
# Optional: hold
scl("root", (1.0, 1.0, 1.0), 24)
act.use_fake_user = True


bpy.ops.object.mode_set(mode='OBJECT')
anim_count = len([a for a in bpy.data.actions if a.name.startswith("ai_sage_")])
print(f"  AISage animations: {anim_count}")

bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
print(f"\nSaved: {OUT_BLEND}")
print(f"Total objects: {len([o for o in bpy.context.scene.objects if o.type == 'MESH'])}")
print("AI Sage full pipeline complete")
