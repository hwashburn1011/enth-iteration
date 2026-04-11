"""Epic 12 — Town Modular Building Kit pipeline (tasks 1-50).

Builds the entire modular building kit + 20 assembled filler buildings
+ all prop sets in a single Blender CLI run.

Output structure:
  _art_source/buildings/kit/
    kit_master.blend          — kit definitions + 8 walls + 6 roofs + 4 doors + 6 windows + 8 trim
    fillers/
      filler_<id>.blend       — 10 assembled fillers + 5 ruined + 5 under_construction = 20 buildings
    props/
      props_master.blend      — fences, gates, lamps, signs, benches, planters, mailboxes, crates, etc

Run via:
    blender.exe --background --python _art_source/buildings/scripts/epic12_modular_kit_pipeline.py
"""
import bpy
import bmesh
import os
import sys
import math
import numpy as np
from mathutils import Vector, Matrix

SCRIPT_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/scripts"
if SCRIPT_DIR not in sys.path:
    sys.path.insert(0, SCRIPT_DIR)

from enemy_pipeline_utils import (
    make_pbr, create_mesh,
    build_joined_lod, build_high_poly, smart_uv_unwrap,
    bake_pbr_set, write_albedo, img_to_array, hash_noise,
)

OUT_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/buildings/kit"
FILLER_DIR = f"{OUT_DIR}/fillers"
PROPS_DIR = f"{OUT_DIR}/props"
TEX_DIR = "C:/Users/hwash/Documents/enth-iteration/assets/textures/buildings/kit"
os.makedirs(OUT_DIR, exist_ok=True)
os.makedirs(FILLER_DIR, exist_ok=True)
os.makedirs(PROPS_DIR, exist_ok=True)
os.makedirs(TEX_DIR, exist_ok=True)


def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.context.scene.unit_settings.system = 'METRIC'


# === SHARED MATERIALS ===
def make_kit_mats():
    return {
        "stone":   make_pbr("Kit_Stone",   (0.78, 0.72, 0.60), 0.0, 0.75),
        "brick":   make_pbr("Kit_Brick",   (0.55, 0.30, 0.20), 0.0, 0.85),
        "wood":    make_pbr("Kit_Wood",    (0.45, 0.28, 0.15), 0.0, 0.80),
        "metal":   make_pbr("Kit_Metal",   (0.45, 0.46, 0.50), 1.0, 0.40),
        "chrome":  make_pbr("Kit_Chrome",  (0.85, 0.86, 0.92), 1.0, 0.15),
        "glass":   make_pbr("Kit_Glass",   (0.55, 0.78, 0.85), 0.0, 0.05, (0.0, 0.85, 1.0), 1.5),
        "warm_window": make_pbr("Kit_WarmWindow", (1.0, 0.85, 0.45), 0.0, 0.10, (1.0, 0.75, 0.25), 4.0),
        "dark":    make_pbr("Kit_Dark",    (0.10, 0.10, 0.13), 0.4, 0.55),
        "roof_tile": make_pbr("Kit_RoofTile", (0.10, 0.20, 0.25), 0.0, 0.60),
        "rusted":  make_pbr("Kit_Rusted",  (0.35, 0.20, 0.10), 0.4, 0.85),
        "scaffold":make_pbr("Kit_Scaffold",(0.65, 0.50, 0.20), 0.4, 0.55),
        "accent":  make_pbr("Kit_Accent",  (0.0, 0.85, 1.0),   0.0, 0.10, (0.0, 0.85, 1.0), 4.0),
    }


def make_collection(name, parent_col=None):
    col = bpy.data.collections.get(name)
    if col is None:
        col = bpy.data.collections.new(name)
        if parent_col is None:
            parent_col = bpy.context.scene.collection
        parent_col.children.link(col)
    return col


def add_to_collection(obj, col):
    for c in obj.users_collection:
        c.objects.unlink(obj)
    col.objects.link(obj)


def create_simple_mesh(name, bm, location, material, parent=None):
    me = bpy.data.meshes.new(name + "_mesh")
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new(name, me)
    obj.location = location
    obj.data.materials.append(material)
    bpy.context.scene.collection.objects.link(obj)
    if parent is not None:
        obj.parent = parent
    for p in obj.data.polygons:
        p.use_smooth = True
    return obj


# ============================================================
# === KIT MASTER FILE (Tasks 1-8) ===
# ============================================================
def build_kit_master():
    """Builds the kit definitions: 8 walls + 6 roofs + 4 doors + 6 windows + 8 trim."""
    print("\n=== Building kit_master.blend ===")
    reset_scene()
    mats = make_kit_mats()

    walls_col = make_collection("Kit_Walls")
    roofs_col = make_collection("Kit_Roofs")
    doors_col = make_collection("Kit_Doors")
    windows_col = make_collection("Kit_Windows")
    trim_col = make_collection("Kit_Trim")

    # Standard wall: 4m wide × 3m tall × 0.30m deep — the snap unit
    WALL_W, WALL_H, WALL_D = 4.0, 3.0, 0.30

    # === 8 WALL VARIANTS ===
    def wall_box():
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= WALL_W * 0.5
            v.co.y *= WALL_D * 0.5
            v.co.z *= WALL_H * 0.5
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        return bm

    # Wall 1: plain stone
    obj = create_simple_mesh("wall_plain_stone", wall_box(), (0, 0, WALL_H * 0.5), mats["stone"])
    add_to_collection(obj, walls_col)
    # Wall 2: plain brick
    obj = create_simple_mesh("wall_plain_brick", wall_box(), (0, 0, WALL_H * 0.5), mats["brick"])
    add_to_collection(obj, walls_col)
    # Wall 3: windowed (stone wall + window cutout cube + glass plate)
    parent_obj = bpy.data.objects.new("wall_windowed", None)
    bpy.context.scene.collection.objects.link(parent_obj)
    obj = create_simple_mesh("wall_windowed_body", wall_box(), (0, 0, WALL_H * 0.5), mats["stone"], parent_obj)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 0.50
        v.co.y *= 0.04
        v.co.z *= 0.50
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj_w = create_simple_mesh("wall_windowed_glass", bm, (0, -WALL_D * 0.5 - 0.02, WALL_H * 0.5), mats["warm_window"], parent_obj)
    add_to_collection(parent_obj, walls_col)
    add_to_collection(obj, walls_col)
    add_to_collection(obj_w, walls_col)
    # Wall 4: doored
    parent_obj = bpy.data.objects.new("wall_doored", None)
    bpy.context.scene.collection.objects.link(parent_obj)
    obj = create_simple_mesh("wall_doored_body", wall_box(), (0, 0, WALL_H * 0.5), mats["stone"], parent_obj)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 0.50
        v.co.y *= 0.05
        v.co.z *= 1.0
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    door_obj = create_simple_mesh("wall_doored_door", bm, (0, -WALL_D * 0.5 - 0.05, 1.0), mats["wood"], parent_obj)
    add_to_collection(parent_obj, walls_col)
    add_to_collection(obj, walls_col)
    add_to_collection(door_obj, walls_col)
    # Wall 5: vented (slatted)
    parent_obj = bpy.data.objects.new("wall_vented", None)
    bpy.context.scene.collection.objects.link(parent_obj)
    obj = create_simple_mesh("wall_vented_body", wall_box(), (0, 0, WALL_H * 0.5), mats["stone"], parent_obj)
    for i in range(4):
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= WALL_W * 0.40
            v.co.y *= 0.04
            v.co.z *= 0.06
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        v_obj = create_simple_mesh(f"wall_vented_slat_{i}", bm,
                                   (0, -WALL_D * 0.5 - 0.05, 0.8 + i * 0.4), mats["dark"], parent_obj)
        add_to_collection(v_obj, walls_col)
    add_to_collection(parent_obj, walls_col)
    add_to_collection(obj, walls_col)
    # Wall 6: bricked
    obj = create_simple_mesh("wall_bricked", wall_box(), (0, 0, WALL_H * 0.5), mats["brick"])
    add_to_collection(obj, walls_col)
    # Wall 7: plated metal
    obj = create_simple_mesh("wall_plated_metal", wall_box(), (0, 0, WALL_H * 0.5), mats["metal"])
    add_to_collection(obj, walls_col)
    # Wall 8: accent (cyan emission strip)
    parent_obj = bpy.data.objects.new("wall_accent", None)
    bpy.context.scene.collection.objects.link(parent_obj)
    obj = create_simple_mesh("wall_accent_body", wall_box(), (0, 0, WALL_H * 0.5), mats["stone"], parent_obj)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= WALL_W * 0.45
        v.co.y *= 0.04
        v.co.z *= 0.04
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    a_obj = create_simple_mesh("wall_accent_strip", bm, (0, -WALL_D * 0.5 - 0.05, 2.5), mats["accent"], parent_obj)
    add_to_collection(parent_obj, walls_col)
    add_to_collection(obj, walls_col)
    add_to_collection(a_obj, walls_col)

    # === 6 ROOF VARIANTS ===
    # Roof 1: flat
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= WALL_W * 0.5
        v.co.y *= WALL_D * 0.5 + 0.5
        v.co.z *= 0.10
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_simple_mesh("roof_flat", bm, (0, 0, 3.10), mats["dark"])
    add_to_collection(obj, roofs_col)
    # Roof 2: peaked
    bm = bmesh.new()
    v1 = bm.verts.new((-WALL_W * 0.55, -1.0, 0))
    v2 = bm.verts.new(( WALL_W * 0.55, -1.0, 0))
    v3 = bm.verts.new(( WALL_W * 0.55,  1.0, 0))
    v4 = bm.verts.new((-WALL_W * 0.55,  1.0, 0))
    v5 = bm.verts.new(( 0, -1.0, 1.5))
    v6 = bm.verts.new(( 0,  1.0, 1.5))
    bm.faces.new([v1, v2, v3, v4])
    bm.faces.new([v1, v5, v2])
    bm.faces.new([v4, v3, v6])
    bm.faces.new([v1, v4, v6, v5])
    bm.faces.new([v2, v5, v6, v3])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_simple_mesh("roof_peaked", bm, (0, 0, 3.0), mats["roof_tile"])
    add_to_collection(obj, roofs_col)
    # Roof 3: domed
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=20, v_segments=12, radius=WALL_W * 0.5)
    for v in bm.verts:
        if v.co.z < 0:
            v.co.z = 0
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_simple_mesh("roof_domed", bm, (0, 0, 3.0), mats["chrome"])
    add_to_collection(obj, roofs_col)
    # Roof 4: terraced (2 stepped boxes)
    parent_obj = bpy.data.objects.new("roof_terraced", None)
    bpy.context.scene.collection.objects.link(parent_obj)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= WALL_W * 0.5
        v.co.y *= WALL_D * 0.5 + 0.5
        v.co.z *= 0.20
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj1 = create_simple_mesh("roof_terraced_lower", bm, (0, 0, 3.10), mats["roof_tile"], parent_obj)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= WALL_W * 0.35
        v.co.y *= WALL_D * 0.5
        v.co.z *= 0.20
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj2 = create_simple_mesh("roof_terraced_upper", bm, (0, 0, 3.50), mats["roof_tile"], parent_obj)
    add_to_collection(parent_obj, roofs_col)
    add_to_collection(obj1, roofs_col)
    add_to_collection(obj2, roofs_col)
    # Roof 5: antenna
    parent_obj = bpy.data.objects.new("roof_antenna", None)
    bpy.context.scene.collection.objects.link(parent_obj)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= WALL_W * 0.5
        v.co.y *= WALL_D * 0.5 + 0.5
        v.co.z *= 0.10
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj1 = create_simple_mesh("roof_antenna_base", bm, (0, 0, 3.10), mats["dark"], parent_obj)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=8, radius1=0.05, radius2=0.01, depth=1.5, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj2 = create_simple_mesh("roof_antenna_pole", bm, (0, 0, 3.95), mats["chrome"], parent_obj)
    add_to_collection(parent_obj, roofs_col)
    add_to_collection(obj1, roofs_col)
    add_to_collection(obj2, roofs_col)
    # Roof 6: garden (flat + planter accent)
    parent_obj = bpy.data.objects.new("roof_garden", None)
    bpy.context.scene.collection.objects.link(parent_obj)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= WALL_W * 0.5
        v.co.y *= WALL_D * 0.5 + 0.5
        v.co.z *= 0.10
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj1 = create_simple_mesh("roof_garden_base", bm, (0, 0, 3.10), mats["dark"], parent_obj)
    plant_mat = make_pbr("Kit_Plant", (0.20, 0.55, 0.15), 0.0, 0.75)
    for px in (-1.0, 0.0, 1.0):
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=6, radius=0.20)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        p_obj = create_simple_mesh(f"roof_garden_plant_{int(px)}", bm, (px, 0, 3.30), plant_mat, parent_obj)
        add_to_collection(p_obj, roofs_col)
    add_to_collection(parent_obj, roofs_col)
    add_to_collection(obj1, roofs_col)

    # === 4 DOOR VARIANTS ===
    def door_basic(name, w, h, mat, kit_col):
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= w * 0.5
            v.co.y *= 0.04
            v.co.z *= h * 0.5
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj = create_simple_mesh(name, bm, (0, 0, h * 0.5), mat)
        add_to_collection(obj, kit_col)

    door_basic("door_single", 1.0, 2.0, mats["wood"], doors_col)
    door_basic("door_double", 2.0, 2.0, mats["wood"], doors_col)
    door_basic("door_sliding", 1.6, 2.0, mats["chrome"], doors_col)
    # Archway: arch shape (cube + half-cylinder top)
    parent_obj = bpy.data.objects.new("door_archway", None)
    bpy.context.scene.collection.objects.link(parent_obj)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 0.6
        v.co.y *= 0.04
        v.co.z *= 1.0
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj1 = create_simple_mesh("door_archway_body", bm, (0, 0, 1.0), mats["wood"], parent_obj)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=18, radius1=0.6, radius2=0.6, depth=0.04, cap_ends=False)
    rot = Matrix.Rotation(math.radians(90), 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj2 = create_simple_mesh("door_archway_arch", bm, (0, 0, 2.0), mats["wood"], parent_obj)
    add_to_collection(parent_obj, doors_col)
    add_to_collection(obj1, doors_col)
    add_to_collection(obj2, doors_col)

    # === 6 WINDOW VARIANTS ===
    def window_basic(name, w, h, mat, kit_col):
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= w * 0.5
            v.co.y *= 0.04
            v.co.z *= h * 0.5
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj = create_simple_mesh(name, bm, (0, 0, h * 0.5 + 1.0), mat)
        add_to_collection(obj, kit_col)

    window_basic("window_square", 0.9, 0.9, mats["glass"], windows_col)
    # Round window
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=18, v_segments=10, radius=0.45)
    for v in bm.verts:
        v.co.y *= 0.08
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_simple_mesh("window_round", bm, (0, 0, 1.5), mats["glass"])
    add_to_collection(obj, windows_col)
    window_basic("window_bay", 1.4, 1.0, mats["glass"], windows_col)
    # Slatted (multiple thin horizontal slats)
    parent_obj = bpy.data.objects.new("window_slatted", None)
    bpy.context.scene.collection.objects.link(parent_obj)
    for i in range(5):
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= 0.45
            v.co.y *= 0.04
            v.co.z *= 0.05
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        s_obj = create_simple_mesh(f"window_slatted_slat_{i}", bm, (0, 0, 1.2 + i * 0.18), mats["glass"], parent_obj)
        add_to_collection(s_obj, windows_col)
    add_to_collection(parent_obj, windows_col)
    # Holographic (cyan)
    window_basic("window_holo", 0.9, 0.9, mats["accent"], windows_col)
    # Dark (boarded up — no glow)
    window_basic("window_dark", 0.9, 0.9, mats["dark"], windows_col)

    # === 8 TRIM PIECES ===
    def trim_strip(name, w, h, d, mat, kit_col):
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= w * 0.5
            v.co.y *= d * 0.5
            v.co.z *= h * 0.5
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj = create_simple_mesh(name, bm, (0, 0, 0), mat)
        add_to_collection(obj, kit_col)

    trim_strip("trim_cornice", 4.0, 0.10, 0.20, mats["chrome"], trim_col)
    trim_strip("trim_gutter", 4.0, 0.08, 0.08, mats["metal"], trim_col)
    trim_strip("trim_vent_horiz", 0.40, 0.20, 0.04, mats["dark"], trim_col)
    trim_strip("trim_vent_vert", 0.04, 0.40, 0.20, mats["dark"], trim_col)
    trim_strip("trim_sign_mount", 0.50, 0.04, 0.06, mats["chrome"], trim_col)
    trim_strip("trim_baseboard", 4.0, 0.08, 0.10, mats["dark"], trim_col)
    trim_strip("trim_corner_pillar", 0.20, 0.20, 3.0, mats["chrome"], trim_col)
    trim_strip("trim_accent_band", 4.0, 0.04, 0.05, mats["accent"], trim_col)

    bpy.ops.wm.save_as_mainfile(filepath=f"{OUT_DIR}/kit_master.blend")
    counts = {
        "walls": len(walls_col.objects),
        "roofs": len(roofs_col.objects),
        "doors": len(doors_col.objects),
        "windows": len(windows_col.objects),
        "trim": len(trim_col.objects),
    }
    print(f"  Kit master saved. Object counts per collection: {counts}")
    return counts


# ============================================================
# === FILLER BUILDINGS (Tasks 10-21) ===
# ============================================================
def build_filler_building(filler_id, display_name, footprint_w, footprint_d, num_stories, has_door, roof_type, variant_state):
    """Build an assembled filler building from kit pieces.
    variant_state: 'normal' / 'ruined' / 'under_construction'
    """
    print(f"\n=== Filler: {display_name} ({variant_state}) ===")
    reset_scene()
    mats = make_kit_mats()
    parent = bpy.data.objects.new(f"{filler_id}_root", None)
    bpy.context.scene.collection.objects.link(parent)

    WALL_H = 3.0
    WALL_D = 0.30

    # Ruined: tilt walls + use rusted material
    use_mat = mats["rusted"] if variant_state == "ruined" else mats["stone"]
    wall_tilt = 8.0 if variant_state == "ruined" else 0.0

    # Build N stories of 4-wall enclosures
    for story in range(num_stories):
        z_base = story * WALL_H
        # 4 walls
        for wall_idx, (x, y, rot_z) in enumerate([
            (0, -footprint_d * 0.5, 0),       # front
            (0,  footprint_d * 0.5, 180),     # back
            (-footprint_w * 0.5, 0, 90),      # left
            ( footprint_w * 0.5, 0, -90),     # right
        ]):
            bm = bmesh.new()
            bmesh.ops.create_cube(bm, size=1.0)
            wall_w = footprint_w if wall_idx < 2 else footprint_d
            for v in bm.verts:
                v.co.x *= wall_w * 0.5
                v.co.y *= WALL_D * 0.5
                v.co.z *= WALL_H * 0.5
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
            obj = create_simple_mesh(f"{filler_id}_wall_s{story}_{wall_idx}", bm, (x, y, z_base + WALL_H * 0.5), use_mat, parent)
            obj.rotation_euler = (math.radians(wall_tilt if variant_state == "ruined" else 0), 0, math.radians(rot_z))
        # Windows on the upper stories
        if story > 0:
            for wx in (-footprint_w * 0.25, footprint_w * 0.25):
                bm = bmesh.new()
                bmesh.ops.create_cube(bm, size=1.0)
                for v in bm.verts:
                    v.co.x *= 0.45
                    v.co.y *= 0.04
                    v.co.z *= 0.45
                bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
                window_mat = mats["dark"] if variant_state == "ruined" else mats["warm_window"]
                create_simple_mesh(f"{filler_id}_window_s{story}_{wx}", bm, (wx, -footprint_d * 0.5 - 0.04, z_base + WALL_H * 0.5), window_mat, parent)

    # Door at ground level if has_door
    if has_door:
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= 0.50
            v.co.y *= 0.05
            v.co.z *= 1.0
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        door_mat = mats["dark"] if variant_state == "ruined" else mats["wood"]
        create_simple_mesh(f"{filler_id}_door", bm, (0, -footprint_d * 0.5 - 0.05, 1.0), door_mat, parent)

    # Roof
    total_h = num_stories * WALL_H
    if variant_state == "ruined":
        # Collapsed roof — partial debris
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= footprint_w * 0.4
            v.co.y *= footprint_d * 0.4
            v.co.z *= 0.10
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        roof = create_simple_mesh(f"{filler_id}_roof_debris", bm, (0.3, 0.2, total_h - 0.20), mats["rusted"], parent)
        roof.rotation_euler = (math.radians(15), math.radians(-8), 0)
    elif variant_state == "under_construction":
        # No roof, scaffolding instead
        for sx in (-footprint_w * 0.5, footprint_w * 0.5):
            bm = bmesh.new()
            bmesh.ops.create_cone(bm, segments=8, radius1=0.05, radius2=0.05, depth=total_h + 0.5, cap_ends=True)
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
            create_simple_mesh(f"{filler_id}_scaffold_pole_{sx}", bm, (sx, -footprint_d * 0.5 - 0.10, (total_h + 0.5) * 0.5), mats["scaffold"], parent)
            bm = bmesh.new()
            bmesh.ops.create_cone(bm, segments=8, radius1=0.05, radius2=0.05, depth=total_h + 0.5, cap_ends=True)
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
            create_simple_mesh(f"{filler_id}_scaffold_pole_back_{sx}", bm, (sx, footprint_d * 0.5 + 0.10, (total_h + 0.5) * 0.5), mats["scaffold"], parent)
        for level in range(num_stories + 1):
            bm = bmesh.new()
            bmesh.ops.create_cube(bm, size=1.0)
            for v in bm.verts:
                v.co.x *= footprint_w * 0.55
                v.co.y *= 0.03
                v.co.z *= 0.04
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
            create_simple_mesh(f"{filler_id}_scaffold_plank_{level}", bm, (0, -footprint_d * 0.5 - 0.10, level * WALL_H), mats["scaffold"], parent)
    else:
        # Normal roof per type
        if roof_type == "flat":
            bm = bmesh.new()
            bmesh.ops.create_cube(bm, size=1.0)
            for v in bm.verts:
                v.co.x *= footprint_w * 0.55
                v.co.y *= footprint_d * 0.55
                v.co.z *= 0.10
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
            create_simple_mesh(f"{filler_id}_roof", bm, (0, 0, total_h + 0.10), mats["roof_tile"], parent)
        elif roof_type == "peaked":
            bm = bmesh.new()
            v1 = bm.verts.new((-footprint_w * 0.55, -footprint_d * 0.55, 0))
            v2 = bm.verts.new(( footprint_w * 0.55, -footprint_d * 0.55, 0))
            v3 = bm.verts.new(( footprint_w * 0.55,  footprint_d * 0.55, 0))
            v4 = bm.verts.new((-footprint_w * 0.55,  footprint_d * 0.55, 0))
            v5 = bm.verts.new(( 0, -footprint_d * 0.55, 1.2))
            v6 = bm.verts.new(( 0,  footprint_d * 0.55, 1.2))
            bm.faces.new([v1, v2, v3, v4])
            bm.faces.new([v1, v5, v2])
            bm.faces.new([v4, v3, v6])
            bm.faces.new([v1, v4, v6, v5])
            bm.faces.new([v2, v5, v6, v3])
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
            create_simple_mesh(f"{filler_id}_roof_peaked", bm, (0, 0, total_h), mats["roof_tile"], parent)
        elif roof_type == "domed":
            bm = bmesh.new()
            bmesh.ops.create_uvsphere(bm, u_segments=18, v_segments=12, radius=footprint_w * 0.45)
            for v in bm.verts:
                if v.co.z < 0:
                    v.co.z = 0
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
            create_simple_mesh(f"{filler_id}_roof_domed", bm, (0, 0, total_h), mats["chrome"], parent)

    # Save
    out_blend = f"{FILLER_DIR}/filler_{filler_id}.blend"
    bpy.ops.wm.save_as_mainfile(filepath=out_blend)
    poly_count = sum(len(o.data.polygons) for o in bpy.data.objects if o.type == 'MESH')
    print(f"  Saved {out_blend} ({poly_count} polys)")


# ============================================================
# === PROPS MASTER (Tasks 22-33) ===
# ============================================================
def build_props_master():
    """Build all the prop sets in one .blend file."""
    print("\n=== Building props_master.blend ===")
    reset_scene()
    mats = make_kit_mats()

    fences_col = make_collection("Props_Fences")
    gates_col = make_collection("Props_Gates")
    paths_col = make_collection("Props_Paths")
    lamps_col = make_collection("Props_Lamps")
    signs_col = make_collection("Props_Signs")
    laundry_col = make_collection("Props_Laundry")
    benches_col = make_collection("Props_Benches")
    planters_col = make_collection("Props_Planters")
    mailboxes_col = make_collection("Props_Mailboxes")
    crates_col = make_collection("Props_Crates")
    weather_col = make_collection("Props_Weather")
    scaffold_col = make_collection("Props_Scaffold")

    # Fences (3 variants)
    for i, (mat, name) in enumerate([(mats["wood"], "wood"), (mats["chrome"], "chrome"), (mats["dark"], "dark")]):
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= 1.5
            v.co.y *= 0.04
            v.co.z *= 0.45
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj = create_simple_mesh(f"fence_{name}_panel", bm, (i * 3, 0, 0.45), mat)
        add_to_collection(obj, fences_col)
    # Gates (2)
    for i, (mat, name) in enumerate([(mats["wood"], "wood"), (mats["chrome"], "chrome")]):
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= 1.0
            v.co.y *= 0.04
            v.co.z *= 0.90
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj = create_simple_mesh(f"gate_{name}", bm, (i * 3, -3, 0.90), mat)
        add_to_collection(obj, gates_col)
    # Paths (3 tile variants)
    for i in range(3):
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= 1.0
            v.co.y *= 1.0
            v.co.z *= 0.05
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj = create_simple_mesh(f"path_tile_{i+1}", bm, (i * 2, -6, 0.025), mats["stone"])
        add_to_collection(obj, paths_col)
    # Street lamps (3)
    for i in range(3):
        parent_obj = bpy.data.objects.new(f"lamp_{i+1}", None)
        bpy.context.scene.collection.objects.link(parent_obj)
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=8, radius1=0.06, radius2=0.05, depth=2.5, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj1 = create_simple_mesh(f"lamp_{i+1}_pole", bm, (i * 2 - 5, -9, 1.25), mats["chrome"], parent_obj)
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.20)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj2 = create_simple_mesh(f"lamp_{i+1}_bulb", bm, (i * 2 - 5, -9, 2.55), mats["warm_window"], parent_obj)
        add_to_collection(parent_obj, lamps_col)
        add_to_collection(obj1, lamps_col)
        add_to_collection(obj2, lamps_col)
    # Signs (3)
    for i in range(3):
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= 0.50
            v.co.y *= 0.03
            v.co.z *= 0.30
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj = create_simple_mesh(f"sign_{i+1}", bm, (i * 1.5 - 5, -12, 1.5), mats["wood"])
        add_to_collection(obj, signs_col)
    # Laundry line
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.01, radius2=0.01, depth=3.0, cap_ends=True)
    rot = Matrix.Rotation(math.radians(90), 4, 'Y')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_simple_mesh("laundry_line", bm, (0, -15, 2.0), mats["dark"])
    add_to_collection(obj, laundry_col)
    # Benches (2)
    for i, mat in enumerate([mats["wood"], mats["chrome"]]):
        parent_obj = bpy.data.objects.new(f"bench_{i+1}", None)
        bpy.context.scene.collection.objects.link(parent_obj)
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= 1.0
            v.co.y *= 0.20
            v.co.z *= 0.04
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj1 = create_simple_mesh(f"bench_{i+1}_seat", bm, (i * 2.5 - 5, -18, 0.4), mat, parent_obj)
        for sx in (-0.9, 0.9):
            bm = bmesh.new()
            bmesh.ops.create_cube(bm, size=1.0)
            for v in bm.verts:
                v.co.x *= 0.05
                v.co.y *= 0.20
                v.co.z *= 0.20
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
            l_obj = create_simple_mesh(f"bench_{i+1}_leg_{sx}", bm, (i * 2.5 - 5 + sx, -18, 0.20), mat, parent_obj)
            add_to_collection(l_obj, benches_col)
        add_to_collection(parent_obj, benches_col)
        add_to_collection(obj1, benches_col)
    # Planters (3)
    plant_mat = make_pbr("Props_Plant", (0.20, 0.55, 0.15), 0.0, 0.75)
    for i in range(3):
        parent_obj = bpy.data.objects.new(f"planter_{i+1}", None)
        bpy.context.scene.collection.objects.link(parent_obj)
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=12, radius1=0.30, radius2=0.25, depth=0.40, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj1 = create_simple_mesh(f"planter_{i+1}_pot", bm, (i * 1.5 - 5, -21, 0.20), mats["dark"], parent_obj)
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=6, radius=0.25)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj2 = create_simple_mesh(f"planter_{i+1}_plant", bm, (i * 1.5 - 5, -21, 0.50), plant_mat, parent_obj)
        add_to_collection(parent_obj, planters_col)
        add_to_collection(obj1, planters_col)
        add_to_collection(obj2, planters_col)
    # Mailboxes (2)
    for i in range(2):
        parent_obj = bpy.data.objects.new(f"mailbox_{i+1}", None)
        bpy.context.scene.collection.objects.link(parent_obj)
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=8, radius1=0.04, radius2=0.04, depth=1.0, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj1 = create_simple_mesh(f"mailbox_{i+1}_post", bm, (i * 1.5 - 5, -24, 0.5), mats["chrome"], parent_obj)
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= 0.20
            v.co.y *= 0.18
            v.co.z *= 0.15
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj2 = create_simple_mesh(f"mailbox_{i+1}_box", bm, (i * 1.5 - 5, -24, 1.10), mats["dark"], parent_obj)
        add_to_collection(parent_obj, mailboxes_col)
        add_to_collection(obj1, mailboxes_col)
        add_to_collection(obj2, mailboxes_col)
    # Crates + barrels (4)
    for i in range(2):
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co *= 0.40
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj = create_simple_mesh(f"crate_{i+1}", bm, (i * 1.0 - 5, -27, 0.40), mats["wood"])
        add_to_collection(obj, crates_col)
    for i in range(2):
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=12, radius1=0.30, radius2=0.30, depth=0.80, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj = create_simple_mesh(f"barrel_{i+1}", bm, (i * 1.0 - 2.5, -27, 0.40), mats["wood"])
        add_to_collection(obj, crates_col)
    # Weather vane
    parent_obj = bpy.data.objects.new("weather_vane", None)
    bpy.context.scene.collection.objects.link(parent_obj)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=8, radius1=0.04, radius2=0.04, depth=1.0, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj1 = create_simple_mesh("weather_vane_pole", bm, (-5, -30, 0.5), mats["chrome"], parent_obj)
    bm = bmesh.new()
    v1 = bm.verts.new((-0.35, 0, 0))
    v2 = bm.verts.new(( 0.35, 0, 0))
    v3 = bm.verts.new(( 0, 0, 0.20))
    bm.faces.new([v1, v2, v3])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj2 = create_simple_mesh("weather_vane_arrow", bm, (-5, -30, 1.10), mats["chrome"], parent_obj)
    add_to_collection(parent_obj, weather_col)
    add_to_collection(obj1, weather_col)
    add_to_collection(obj2, weather_col)
    # Scaffolding pieces (3 — pole, plank, frame)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=8, radius1=0.05, radius2=0.05, depth=3.0, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_simple_mesh("scaffold_pole", bm, (-5, -33, 1.5), mats["scaffold"])
    add_to_collection(obj, scaffold_col)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 1.5
        v.co.y *= 0.20
        v.co.z *= 0.04
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_simple_mesh("scaffold_plank", bm, (-3, -33, 1.5), mats["scaffold"])
    add_to_collection(obj, scaffold_col)

    bpy.ops.wm.save_as_mainfile(filepath=f"{OUT_DIR}/props_master.blend")
    print(f"  Props master saved.")


# ============================================================
# === RUN THE PIPELINE ===
# ============================================================
build_kit_master()

# 10 normal filler buildings (tasks 10-19)
filler_configs = [
    # (id, name, w, d, stories, has_door, roof_type)
    ("small_home",     "Small Home",      4.0, 4.0, 1, True,  "peaked"),
    ("medium_shop",    "Medium Shop",     6.0, 5.0, 1, True,  "flat"),
    ("workshop",       "Workshop",        7.0, 6.0, 1, True,  "flat"),
    ("apartment",      "Apartment Block", 6.0, 6.0, 3, True,  "flat"),
    ("storage",        "Storage",         5.0, 5.0, 1, True,  "flat"),
    ("small_temple",   "Small Temple",    5.0, 5.0, 1, True,  "domed"),
    ("cottage",        "Cottage",         4.5, 4.0, 1, True,  "peaked"),
    ("kiosk",          "Kiosk",           2.5, 2.5, 1, True,  "peaked"),
    ("tower",          "Tower",           3.0, 3.0, 3, True,  "peaked"),
    ("annex",          "Annex",           3.5, 3.0, 1, True,  "flat"),
]
for cfg in filler_configs:
    build_filler_building(cfg[0], cfg[1], cfg[2], cfg[3], cfg[4], cfg[5], cfg[6], "normal")

# 5 ruined variants (task 20)
ruined_configs = [
    ("ruined_home",     "Ruined Home",     4.0, 4.0, 1, False, "peaked"),
    ("ruined_apartment","Ruined Apartment",6.0, 6.0, 2, False, "flat"),
    ("ruined_workshop", "Ruined Workshop", 7.0, 6.0, 1, False, "flat"),
    ("ruined_temple",   "Ruined Temple",   5.0, 5.0, 1, False, "domed"),
    ("ruined_tower",    "Ruined Tower",    3.0, 3.0, 2, False, "peaked"),
]
for cfg in ruined_configs:
    build_filler_building(cfg[0], cfg[1], cfg[2], cfg[3], cfg[4], cfg[5], cfg[6], "ruined")

# 5 under construction variants (task 21)
construction_configs = [
    ("construction_home",     "Under Construction Home",      4.0, 4.0, 1, False, "flat"),
    ("construction_shop",     "Under Construction Shop",      6.0, 5.0, 1, False, "flat"),
    ("construction_apartment","Under Construction Apartment", 6.0, 6.0, 2, False, "flat"),
    ("construction_temple",   "Under Construction Temple",    5.0, 5.0, 1, False, "flat"),
    ("construction_tower",    "Under Construction Tower",     3.0, 3.0, 2, False, "flat"),
]
for cfg in construction_configs:
    build_filler_building(cfg[0], cfg[1], cfg[2], cfg[3], cfg[4], cfg[5], cfg[6], "under_construction")

# Props master (tasks 22-33)
build_props_master()

print(f"\n=== Epic 12 modular kit + 20 fillers + props master complete ===")
