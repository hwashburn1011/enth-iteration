"""Epic 10 — Town NPC Cast pipeline (tasks 14-25, 26-39).

Single parameterized pipeline that builds all 12 town NPCs end-to-end.
For each NPC config, creates a fresh .blend file with:
- Humanoid sculpt scaled to per-NPC proportions
- 4 baked PBR maps via shared enemy_pipeline_utils
- Procedural albedo with primary + accent colors
- 14-bone humanoid rig
- 5 animations: idle, walk, work, react_happy, react_sad
- Saved to _art_source/characters/town_npcs/<npc_id>.blend

Run via:
    blender.exe --background --python _art_source/characters/scripts/epic10_npc_cast_pipeline.py
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

OUT_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/town_npcs"
TEX_DIR = "C:/Users/hwash/Documents/enth-iteration/assets/textures/characters/town_npcs"
os.makedirs(OUT_DIR, exist_ok=True)
os.makedirs(TEX_DIR, exist_ok=True)


# ==========  NPC CONFIG  ==========
# Per the bible: 12 NPCs with parameterized proportions + colors

NPC_CONFIGS = [
    # (id, display_name, height, body_width, head_scale, primary_rgb, accent_rgb, accessory)
    ("pixel",    "Pixel",    1.50, 1.05, 1.00, (0.95, 0.55, 0.10), (0.95, 0.85, 0.55), "visor"),
    ("forge",    "Forge",    1.65, 1.20, 1.00, (0.20, 0.10, 0.05), (0.55, 0.35, 0.20), None),
    ("cache",    "Cache",    1.55, 0.95, 1.00, (0.92, 0.92, 0.92), (0.05, 0.10, 0.18), None),
    ("index",    "Index",    1.55, 0.85, 1.00, (0.90, 0.85, 0.75), (0.20, 0.18, 0.15), "bun"),
    ("harvest",  "Harvest",  1.55, 1.10, 1.00, (0.20, 0.35, 0.55), (0.45, 0.30, 0.15), "straw_hat"),
    ("bit",      "Bit",      1.20, 0.90, 1.30, (0.0,  0.85, 0.95), (0.95, 0.85, 0.10), None),
    ("legacy",   "Legacy",   1.50, 0.95, 1.00, (0.40, 0.35, 0.40), (0.40, 0.10, 0.15), "stick"),
    ("trade",    "Trade",    1.55, 1.05, 1.00, (0.45, 0.25, 0.10), (0.30, 0.18, 0.08), "leather_hat"),
    ("lab",      "Lab",      1.55, 1.00, 1.00, (0.95, 0.95, 0.95), (0.10, 0.55, 0.55), "goggles"),
    ("render",   "Render",   1.50, 1.00, 1.00, (0.92, 0.88, 0.78), (0.85, 0.10, 0.55), "beret"),
    ("sync",     "Sync",     1.50, 1.00, 1.00, (0.45, 0.10, 0.65), (0.0,  0.85, 0.95), "headphones"),
    ("sentinel", "Sentinel", 1.65, 1.25, 1.00, (0.10, 0.10, 0.12), (0.0,  0.85, 0.95), "helm"),
]


def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.context.scene.unit_settings.system = 'METRIC'


def build_npc(npc_id, display_name, height, body_width, head_scale,
              primary_rgb, accent_rgb, accessory):
    """Build a single NPC end-to-end."""
    print(f"\n=== Building NPC: {display_name} ===")
    reset_scene()

    out_blend = f"{OUT_DIR}/npc_{npc_id}.blend"

    # === MATERIALS ===
    mat_primary = make_pbr(f"{npc_id.title()}_Primary", primary_rgb, 0.0, 0.65)
    mat_accent  = make_pbr(f"{npc_id.title()}_Accent",  accent_rgb,  0.0, 0.55)
    mat_skin    = make_pbr(f"{npc_id.title()}_Skin",    (0.62, 0.45, 0.38), 0.0, 0.55)
    mat_eye     = make_pbr(f"{npc_id.title()}_Eye",     (0.0, 0.40, 0.50), 0.0, 0.10, (0.0, 0.85, 1.0), 4.0)
    mat_hair    = make_pbr(f"{npc_id.title()}_Hair",    (0.18, 0.12, 0.08), 0.0, 0.85)
    mat_dark    = make_pbr(f"{npc_id.title()}_Dark",    (0.05, 0.05, 0.07), 0.0, 0.55)

    root = bpy.data.objects.new(f"{display_name}_Root", None)
    bpy.context.scene.collection.objects.link(root)

    # === GEOMETRY ===
    # Reference height = 1.50m baseline
    h = height
    bw = body_width
    hs = head_scale

    # Head (slightly bigger for child Bit)
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=22, v_segments=14, radius=0.18 * hs)
    for v in bm.verts:
        v.co.y *= 0.95
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    head_z = h - 0.20 * hs
    head = create_mesh(f"{npc_id}_head", bm, (0, 0, head_z), mat_skin, root)
    mod = head.modifiers.new("Subsurf", 'SUBSURF')
    mod.levels = 1

    # Eyes
    for sx, label in [(1, "R"), (-1, "L")]:
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.018)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"{npc_id}_eye_{label}", bm, (0.045 * sx * hs, -0.13 * hs, head_z), mat_eye, root)

    # Hair (basic skull cap unless replaced by an accessory)
    if accessory not in ("visor", "straw_hat", "leather_hat", "beret", "helm"):
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=18, v_segments=10, radius=0.19 * hs)
        for v in bm.verts:
            if v.co.z < 0:
                v.co.z *= 0.3  # cut off bottom half
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"{npc_id}_hair", bm, (0, 0.01, head_z + 0.01), mat_hair, root)

    # Torso
    torso_top = h - 0.40 * hs
    torso_bot = h - 0.85
    torso_mid = (torso_top + torso_bot) * 0.5
    torso_height = torso_top - torso_bot
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 0.30 * bw
        v.co.y *= 0.20 * bw
        v.co.z *= torso_height * 0.5
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bmesh.ops.bevel(bm, geom=list(bm.edges) + list(bm.verts), offset=0.025, segments=2, affect='EDGES')
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    torso = create_mesh(f"{npc_id}_torso", bm, (0, 0, torso_mid), mat_primary, root)
    mod = torso.modifiers.new("Subsurf", 'SUBSURF')
    mod.levels = 1

    # Accent stripe across the torso (the secondary color band)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 0.305 * bw
        v.co.y *= 0.205 * bw
        v.co.z *= 0.05
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"{npc_id}_accent_stripe", bm, (0, 0, torso_mid), mat_accent, root)

    # Hips
    hip_z = torso_bot - 0.05
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 0.27 * bw
        v.co.y *= 0.18 * bw
        v.co.z *= 0.10
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bmesh.ops.bevel(bm, geom=list(bm.edges) + list(bm.verts), offset=0.018, segments=2, affect='EDGES')
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh(f"{npc_id}_hips", bm, (0, 0, hip_z), mat_dark, root)

    # Arms
    for sx, label in [(1, "R"), (-1, "L")]:
        # Upper arm
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=10, radius1=0.07, radius2=0.06, depth=0.30, cap_ends=True)
        rot_180 = Matrix.Rotation(math.radians(180), 4, 'X')
        for v in bm.verts:
            v.co = rot_180 @ v.co
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"{npc_id}_upper_arm_{label}", bm, (0.32 * bw * sx, 0, torso_top - 0.15), mat_primary, root)
        # Forearm
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=10, radius1=0.06, radius2=0.05, depth=0.28, cap_ends=True)
        for v in bm.verts:
            v.co = rot_180 @ v.co
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"{npc_id}_forearm_{label}", bm, (0.34 * bw * sx, 0, torso_top - 0.42), mat_primary, root)
        # Hand
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.05)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"{npc_id}_hand_{label}", bm, (0.36 * bw * sx, 0, torso_top - 0.62), mat_skin, root)

    # Legs
    leg_top = hip_z - 0.05
    leg_mid_z = leg_top - 0.20
    for sx, label in [(1, "R"), (-1, "L")]:
        # Thigh
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=10, radius1=0.085, radius2=0.075, depth=0.30, cap_ends=True)
        rot_180 = Matrix.Rotation(math.radians(180), 4, 'X')
        for v in bm.verts:
            v.co = rot_180 @ v.co
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"{npc_id}_thigh_{label}", bm, (0.10 * bw * sx, 0, leg_top - 0.15), mat_dark, root)
        # Shin
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=10, radius1=0.075, radius2=0.06, depth=0.28, cap_ends=True)
        for v in bm.verts:
            v.co = rot_180 @ v.co
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"{npc_id}_shin_{label}", bm, (0.10 * bw * sx, 0, leg_top - 0.42), mat_dark, root)
        # Foot
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.07)
        for v in bm.verts:
            v.co.y *= 1.4
            v.co.z *= 0.5
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"{npc_id}_foot_{label}", bm, (0.10 * bw * sx, -0.03, 0.05), mat_dark, root)

    # Accessory
    if accessory == "visor":
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= 0.18 * hs
            v.co.y *= 0.025
            v.co.z *= 0.10 * hs
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"{npc_id}_visor", bm, (0, -0.16 * hs, head_z + 0.04), mat_accent, root)
    elif accessory == "straw_hat":
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=14, radius1=0.30 * hs, radius2=0.10 * hs, depth=0.10 * hs, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"{npc_id}_hat", bm, (0, 0, head_z + 0.20 * hs), mat_accent, root)
    elif accessory == "leather_hat":
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=14, radius1=0.22 * hs, radius2=0.16 * hs, depth=0.14 * hs, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"{npc_id}_hat", bm, (0, 0, head_z + 0.18 * hs), mat_dark, root)
    elif accessory == "beret":
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=8, radius=0.16 * hs)
        for v in bm.verts:
            if v.co.z < 0:
                v.co.z *= 0.2
            v.co.z *= 0.6
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"{npc_id}_beret", bm, (-0.04, 0.02, head_z + 0.18 * hs), mat_accent, root)
    elif accessory == "helm":
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=18, v_segments=12, radius=0.21 * hs)
        for v in bm.verts:
            if v.co.z < -0.05:
                v.co.z *= 0.5
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"{npc_id}_helm", bm, (0, 0, head_z + 0.02), mat_dark, root)
        # Cyan visor slit
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= 0.18 * hs
            v.co.y *= 0.025
            v.co.z *= 0.018
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"{npc_id}_visor_slit", bm, (0, -0.20 * hs, head_z), mat_eye, root)
    elif accessory == "goggles":
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= 0.20 * hs
            v.co.y *= 0.04
            v.co.z *= 0.05
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"{npc_id}_goggles", bm, (0, -0.16 * hs, head_z + 0.08), mat_accent, root)
    elif accessory == "headphones":
        # Headband across top of head
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=8, radius=0.20 * hs)
        for v in bm.verts:
            v.co.y *= 0.35
            if v.co.z < 0:
                v.co.z *= 0.05
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"{npc_id}_headphones_band", bm, (0, 0, head_z + 0.10), mat_accent, root)
        # 2 ear cups
        for sx in [1, -1]:
            bm = bmesh.new()
            bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=6, radius=0.05)
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
            create_mesh(f"{npc_id}_earcup_{'R' if sx > 0 else 'L'}", bm, (0.18 * sx * hs, 0, head_z), mat_accent, root)
    elif accessory == "stick":
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=10, radius1=0.025, radius2=0.022, depth=1.30, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"{npc_id}_walking_stick", bm, (0.35 * bw, 0.02, 0.65), mat_hair, root)
    elif accessory == "bun":
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.08 * hs)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"{npc_id}_bun", bm, (0, 0.10, head_z + 0.10 * hs), mat_hair, root)

    # === LOD0 + UV + BAKE + ALBEDO ===
    def collect_visible():
        return [o for o in bpy.context.scene.objects if o.type == 'MESH']

    lod0 = build_joined_lod(f"{display_name}_LOD0", collect_visible(), 2200, f"{display_name}_")
    smart_uv_unwrap(lod0)
    hp = build_high_poly(f"{display_name}_HP", collect_visible(), f"{display_name}_")
    img_normal, img_ao, img_cavity, img_curv = bake_pbr_set(lod0, hp, f"npc_{npc_id}", TEX_DIR)

    # Albedo: blend primary + accent + skin + edge highlight
    W, H = 1024, 1024
    ao_arr = img_to_array(img_ao)[:, :, 0]
    curv_arr = img_to_array(img_curv)[:, :, 0]
    cell_noise = hash_noise(np.linspace(0, 1, W, dtype=np.float32)[None, :],
                             np.linspace(0, 1, H, dtype=np.float32)[:, None], 30.0)

    out = np.zeros((H, W, 4), dtype=np.float32)
    out[:, :, 0] = primary_rgb[0]
    out[:, :, 1] = primary_rgb[1]
    out[:, :, 2] = primary_rgb[2]
    out[:, :, 3] = 1.0
    out[:, :, :3] *= (0.85 + 0.30 * cell_noise[:, :, None])
    out[:, :, :3] *= (0.55 + 0.45 * ao_arr[:, :, None])

    # Edge highlight blends to accent color
    edge_mask = np.clip((curv_arr - 0.55) / 0.45, 0.0, 1.0) ** 1.4
    accent_arr = np.array(accent_rgb, dtype=np.float32)
    for c in range(3):
        out[:, :, c] = out[:, :, c] * (1.0 - edge_mask * 0.50) + accent_arr[c] * (edge_mask * 0.50)

    out = np.clip(out, 0.0, 1.0)
    write_albedo(f"npc_{npc_id}_albedo", out, TEX_DIR)

    # === RIG (14-bone humanoid) ===
    arm_data = bpy.data.armatures.new(f"{display_name}_Armature")
    arm_obj = bpy.data.objects.new(f"Armature_{display_name}", arm_data)
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
    hips_b = add_bone("hips", (0, 0, hip_z), (0, 0, torso_bot), root_b)
    spine_b = add_bone("spine", (0, 0, torso_bot), (0, 0, torso_mid), hips_b, True)
    chest_b = add_bone("chest", (0, 0, torso_mid), (0, 0, torso_top), spine_b, True)
    neck_b = add_bone("neck", (0, 0, torso_top), (0, 0, head_z - 0.05), chest_b, True)
    head_b = add_bone("head", (0, 0, head_z - 0.05), (0, 0, head_z + 0.10), neck_b, True)
    # Arms
    shR = add_bone("shoulder_R", (0.10, 0, torso_top - 0.05), (0.32 * bw, 0, torso_top - 0.15), chest_b)
    upR = add_bone("upper_arm_R", (0.32 * bw, 0, torso_top - 0.15), (0.34 * bw, 0, torso_top - 0.42), shR, True)
    fR  = add_bone("forearm_R", (0.34 * bw, 0, torso_top - 0.42), (0.36 * bw, 0, torso_top - 0.62), upR, True)
    shL = add_bone("shoulder_L", (-0.10, 0, torso_top - 0.05), (-0.32 * bw, 0, torso_top - 0.15), chest_b)
    upL = add_bone("upper_arm_L", (-0.32 * bw, 0, torso_top - 0.15), (-0.34 * bw, 0, torso_top - 0.42), shL, True)
    fL  = add_bone("forearm_L", (-0.34 * bw, 0, torso_top - 0.42), (-0.36 * bw, 0, torso_top - 0.62), upL, True)
    # Legs
    thR = add_bone("thigh_R", (0.10 * bw, 0, leg_top), (0.10 * bw, 0, leg_top - 0.30), hips_b)
    shinR = add_bone("shin_R", (0.10 * bw, 0, leg_top - 0.30), (0.10 * bw, -0.02, 0.05), thR, True)
    thL = add_bone("thigh_L", (-0.10 * bw, 0, leg_top), (-0.10 * bw, 0, leg_top - 0.30), hips_b)
    shinL = add_bone("shin_L", (-0.10 * bw, 0, leg_top - 0.30), (-0.10 * bw, -0.02, 0.05), thL, True)

    bpy.ops.object.mode_set(mode='OBJECT')
    print(f"  {display_name} rig: {len(arm_data.bones)} bones")

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

    # 1. idle (60-frame loop, breath + sway)
    act = new_action(f"{npc_id}_idle")
    arm_obj.animation_data.action = act
    for f in range(0, 61, 5):
        t = f / 60.0 * math.tau
        loc("root", (0, 0, 0.012 * math.sin(t)), f)
        rot("chest", (1.5 * math.sin(t * 0.5), 0, 0), f)
        rot("head", (0, 0, 3.0 * math.sin(t * 0.3)), f)
    act.use_fake_user = True

    # 2. walk (40-frame walk cycle)
    act = new_action(f"{npc_id}_walk")
    arm_obj.animation_data.action = act
    for f in range(0, 41, 4):
        t = f / 40.0 * math.tau
        loc("root", (0, 0, 0.025 * abs(math.sin(t * 2.0))), f)
        rot("chest", (3.0 * math.sin(t * 2.0), 0, 0), f)
        rot("upper_arm_R", (15 * math.sin(t * 2.0), 0, 0), f)
        rot("upper_arm_L", (15 * math.sin(t * 2.0 + math.pi), 0, 0), f)
        rot("thigh_R", (15 * math.sin(t * 2.0 + math.pi), 0, 0), f)
        rot("thigh_L", (15 * math.sin(t * 2.0), 0, 0), f)
    act.use_fake_user = True

    # 3. work (per-NPC themed loop — but we use a generic gesture loop here)
    act = new_action(f"{npc_id}_work")
    arm_obj.animation_data.action = act
    for f in range(0, 50, 5):
        t = f / 50.0 * math.tau
        # Right arm makes a working gesture
        rot("upper_arm_R", (-50 + 8 * math.sin(t * 2.0), 0, -10), f)
        rot("forearm_R", (-30 + 12 * math.sin(t * 2.0), 0, 0), f)
        rot("hand_R", (5 * math.sin(t * 2.0), 0, 0), f)
        rot("chest", (-3 + 1.5 * math.sin(t * 2.0), 0, 0), f)
        rot("head", (-5, 0, 3 * math.sin(t * 1.5)), f)
    act.use_fake_user = True

    # 4. react_happy (20-frame greet wave)
    act = new_action(f"{npc_id}_react_happy")
    arm_obj.animation_data.action = act
    rot("upper_arm_R", (-30, 0, -10), 0)
    rot("upper_arm_R", (-130, 0, 20), 8)
    rot("forearm_R", (0, 0, 0), 8)
    rot("hand_R", (0, 0, -20), 8)
    rot("hand_R", (0, 0, 20), 12)
    rot("hand_R", (0, 0, -20), 16)
    rot("upper_arm_R", (-30, 0, -10), 20)
    rot("hand_R", (0, 0, 0), 20)
    rot("head", (0, 0, 5), 8)
    rot("head", (0, 0, 0), 20)
    act.use_fake_user = True

    # 5. react_sad (30-frame contemplative)
    act = new_action(f"{npc_id}_react_sad")
    arm_obj.animation_data.action = act
    rot("head", (0, 0, 0), 0)
    rot("head", (15, 0, 0), 10)
    rot("chest", (8, 0, 0), 10)
    rot("upper_arm_R", (-30, 0, -10), 0)
    rot("upper_arm_R", (-90, 0, 25), 10)
    rot("forearm_R", (-90, 0, 0), 10)
    rot("head", (15, 0, 0), 22)
    rot("head", (0, 0, 0), 30)
    rot("chest", (0, 0, 0), 30)
    rot("upper_arm_R", (-30, 0, -10), 30)
    rot("forearm_R", (-30, 0, 0), 30)
    act.use_fake_user = True

    bpy.ops.object.mode_set(mode='OBJECT')

    bpy.ops.wm.save_as_mainfile(filepath=out_blend)
    print(f"  Saved: {out_blend}")
    print(f"  LOD0: {len(lod0.data.polygons)} polys, animations: 5")


# Build all 12 NPCs
for cfg in NPC_CONFIGS:
    build_npc(*cfg)

print("\n=== All 12 town NPCs built ===")
