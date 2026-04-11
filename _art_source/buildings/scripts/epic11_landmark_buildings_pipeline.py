"""Epic 11 — Town Hero Architecture pipeline (tasks 11-32, 38, 41).

Single parameterized pipeline that builds all 10 landmark buildings
end-to-end. For each building config, creates a fresh .blend file with:
- Per-shape geometry (tower / dome / cottage / brick / tall / greenhouse / etc)
- Cream-teal-chrome shared material palette + per-building accent
- 4 baked PBR maps via shared enemy_pipeline_utils
- Procedural albedo with stone variation + accent emission
- LOD chain for distance
- Saved to _art_source/buildings/<building_id>.blend

Run via:
    blender.exe --background --python _art_source/buildings/scripts/epic11_landmark_buildings_pipeline.py
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

OUT_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/buildings/landmarks"
TEX_DIR = "C:/Users/hwash/Documents/enth-iteration/assets/textures/buildings/landmarks"
os.makedirs(OUT_DIR, exist_ok=True)
os.makedirs(TEX_DIR, exist_ok=True)


# === BUILDING CONFIGS ===
# (id, display_name, shape, height, width, depth, accent_rgb, special)

BUILDING_CONFIGS = [
    ("compaction_tower",   "Compaction Tower",   "tower",      18.0, 4.0,  4.0,  (0.0, 0.95, 0.95), "rings_spire"),
    ("sages_sanctum",      "Sage's Sanctum",     "dome",        6.0, 5.0,  5.0,  (0.0, 0.85, 1.0),  "floating_chunks"),
    ("iteration_memorial", "Iteration Memorial",  "rectangle",   4.0, 6.0,  3.0,  (0.95, 0.95, 1.0), "stelae"),
    ("cache_tavern",       "Cache Tavern",       "cottage",     7.0, 8.0,  6.0,  (1.0, 0.75, 0.30), "chimney"),
    ("forge_foundry",      "Forge Foundry",      "brick",       8.0, 7.0,  7.0,  (1.0, 0.45, 0.05), "smokestack_arch"),
    ("index_archive",      "Index Archive",      "tall",        9.0, 6.0,  8.0,  (0.0, 0.85, 1.0),  "tall_windows"),
    ("harvest_greenhouse", "Harvest Greenhouse", "greenhouse",  5.0, 8.0,  12.0, (0.30, 0.85, 0.20),"glass_dome"),
    ("render_studio",      "Render Studio",      "rectangle",   6.0, 5.0,  5.0,  (1.0, 0.10, 0.85), "slanted_glass"),
    ("sync_amphitheater",  "Sync Amphitheater",  "circular",    4.0, 10.0, 10.0, (0.0, 0.95, 0.95), "curved_seats"),
    ("sentinel_watch",     "Sentinel Watch",     "tower",      12.0, 3.0,  3.0,  (0.0, 0.85, 1.0),  "gate_walls"),
]

# === SHARED MATERIALS (created once per build) ===
def make_shared_mats(building_id, accent_rgb):
    mats = {}
    mats["stone"]   = make_pbr(f"{building_id}_Stone",   (0.78, 0.72, 0.60), 0.0, 0.75)
    mats["roof"]    = make_pbr(f"{building_id}_Roof",    (0.10, 0.20, 0.25), 0.0, 0.60)
    mats["chrome"]  = make_pbr(f"{building_id}_Chrome",  (0.85, 0.86, 0.92), 1.0, 0.15)
    mats["accent"]  = make_pbr(f"{building_id}_Accent",  accent_rgb, 0.0, 0.10, accent_rgb, 5.0)
    mats["glass"]   = make_pbr(f"{building_id}_Glass",   (0.55, 0.78, 0.85), 0.0, 0.05, accent_rgb, 1.5)
    mats["dark"]    = make_pbr(f"{building_id}_Dark",    (0.10, 0.10, 0.13), 0.4, 0.55)
    mats["window_warm"] = make_pbr(f"{building_id}_WindowWarm", (1.0, 0.85, 0.45), 0.0, 0.10, (1.0, 0.75, 0.25), 4.0)
    return mats


def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.context.scene.unit_settings.system = 'METRIC'


def add_door(parent, mats, x, y, z):
    """Adds a 2.0m × 1.0m door at the front of the building (player scale anchor)."""
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 0.5
        v.co.y *= 0.05
        v.co.z *= 1.0
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh("door", bm, (x, y, z), mats["dark"], parent)
    # Door frame chrome trim
    for offset in (-0.55, 0.55):
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= 0.04
            v.co.y *= 0.06
            v.co.z *= 1.05
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh("door_frame", bm, (x + offset, y, z), mats["chrome"], parent)


def add_window(parent, mats, x, y, z, w=0.9, h=0.9):
    """Standard window 0.9m wide."""
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= w * 0.5
        v.co.y *= 0.04
        v.co.z *= h * 0.5
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh("window", bm, (x, y, z), mats["glass"], parent)


def add_emission_strip(parent, mats, x1, y1, z1, x2, y2, z2):
    """A thin glowing accent strip — runs along a roof edge or wall seam."""
    mid = ((x1 + x2) * 0.5, (y1 + y2) * 0.5, (z1 + z2) * 0.5)
    length = math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2 + (z2 - z1) ** 2)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= length * 0.5
        v.co.y *= 0.025
        v.co.z *= 0.025
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh("accent_strip", bm, mid, mats["accent"], parent)
    # Rotate to face along the line
    if abs(x2 - x1) < 0.01 and abs(y2 - y1) > 0.01:
        obj.rotation_euler = (0, 0, math.radians(90))


# === BUILD FUNCTIONS PER SHAPE ===

def build_tower(parent, mats, h, w, d, special):
    # Cylindrical body
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=24, radius1=w * 0.5, radius2=w * 0.4, depth=h, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh("body", bm, (0, 0, h * 0.5), mats["stone"], parent)
    # Front door
    add_door(parent, mats, 0, -w * 0.5 + 0.05, 1.0)
    # Windows on each level
    for level in range(1, int(h / 2)):
        for angle_deg in (0, 90, 180, 270):
            angle = math.radians(angle_deg)
            x = math.cos(angle) * (w * 0.5 + 0.04)
            y = math.sin(angle) * (w * 0.5 + 0.04)
            add_window(parent, mats, x, y, level * 2.0, 0.6, 0.8)
    # Specials
    if special == "rings_spire":
        # Observation rings at z=6, 12, 16
        for ring_z in (6.0, 12.0, 16.0):
            bm = bmesh.new()
            bmesh.ops.create_cone(bm, segments=24, radius1=w * 0.7, radius2=w * 0.7, depth=0.30, cap_ends=True)
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
            create_mesh(f"ring_{int(ring_z)}", bm, (0, 0, ring_z), mats["chrome"], parent)
        # Antenna spire at top
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=8, radius1=0.08, radius2=0.01, depth=2.0, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh("spire", bm, (0, 0, h + 1.0), mats["chrome"], parent)
        # Red blinking top light (modeled as red emissive sphere)
        red_mat = make_pbr("Status_Red", (0.85, 0.05, 0.05), 0.0, 0.10, (1.0, 0.10, 0.05), 8.0)
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.10)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh("status_light", bm, (0, 0, h + 2.05), red_mat, parent)
    elif special == "gate_walls":
        # Big arch gate at base
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= w * 0.6
            v.co.y *= 0.1
            v.co.z *= 1.5
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh("gate_arch", bm, (0, -w * 0.5, 1.5), mats["dark"], parent)
        # Wall extensions out the sides
        for sx in (-1, 1):
            bm = bmesh.new()
            bmesh.ops.create_cube(bm, size=1.0)
            for v in bm.verts:
                v.co.x *= 4.0
                v.co.y *= 0.5
                v.co.z *= 2.0
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
            create_mesh(f"wall_{sx}", bm, (w * 0.5 * sx + 4.0 * sx, 0, 2.0), mats["stone"], parent)
        # Battlements (small cubes around the top)
        for i in range(8):
            angle = math.radians(i * 45)
            bm = bmesh.new()
            bmesh.ops.create_cube(bm, size=1.0)
            for v in bm.verts:
                v.co.x *= 0.20
                v.co.y *= 0.20
                v.co.z *= 0.30
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
            create_mesh(f"battlement_{i}", bm, (math.cos(angle) * w * 0.5, math.sin(angle) * w * 0.5, h + 0.15), mats["stone"], parent)


def build_dome(parent, mats, h, w, d, special):
    # Hemisphere body
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=24, v_segments=14, radius=w * 0.5)
    for v in bm.verts:
        if v.co.z < 0:
            v.co.z *= 0.05  # cut off bottom
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh("dome", bm, (0, 0, 0.5), mats["stone"], parent)
    # Door
    add_door(parent, mats, 0, -w * 0.5 + 0.05, 1.0)
    # Floating chunks above
    if special == "floating_chunks":
        for i in range(5):
            angle = i * (math.tau / 5)
            r = w * 0.4
            bm = bmesh.new()
            bmesh.ops.create_cube(bm, size=1.0)
            for v in bm.verts:
                v.co.x *= 0.20 + (i % 3) * 0.05
                v.co.y *= 0.20 + (i % 3) * 0.05
                v.co.z *= 0.20 + (i % 3) * 0.05
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
            create_mesh(f"floating_chunk_{i}", bm,
                        (math.cos(angle) * r, math.sin(angle) * r, h + 0.5 + (i % 3) * 0.2),
                        mats["accent"], parent)


def build_rectangle(parent, mats, h, w, d, special):
    # Box body
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= w * 0.5
        v.co.y *= d * 0.5
        v.co.z *= h * 0.5
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh("body", bm, (0, 0, h * 0.5), mats["stone"], parent)
    # Roof slab
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= w * 0.55
        v.co.y *= d * 0.55
        v.co.z *= 0.15
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh("roof", bm, (0, 0, h + 0.10), mats["roof"], parent)
    # Door
    add_door(parent, mats, 0, -d * 0.5 - 0.02, 1.0)
    # Windows
    for fy in (-d * 0.5 - 0.02, d * 0.5 + 0.02):
        for fx in (-w * 0.3, w * 0.3):
            add_window(parent, mats, fx, fy, h * 0.5 + 0.5)
    # Accent emission strip along roof edge
    add_emission_strip(parent, mats,
                       -w * 0.5, -d * 0.5, h + 0.20,
                        w * 0.5, -d * 0.5, h + 0.20)
    # Specials
    if special == "stelae":
        # 9 vertical stelae across the front
        for i in range(9):
            x = -2.4 + i * 0.6
            bm = bmesh.new()
            bmesh.ops.create_cube(bm, size=1.0)
            for v in bm.verts:
                v.co.x *= 0.20
                v.co.y *= 0.18
                v.co.z *= 1.5
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
            create_mesh(f"stela_{i+1}", bm, (x, -d * 0.5 - 0.40, 1.5), mats["dark"], parent)
        # Central projection plinth
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=12, radius1=0.45, radius2=0.40, depth=0.40, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh("plinth", bm, (0, -d * 0.5 - 1.0, 0.20), mats["accent"], parent)
    elif special == "slanted_glass":
        # Slanted glass roof skylight
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= w * 0.45
            v.co.y *= d * 0.45
            v.co.z *= 0.05
        # Tilt the glass at 25 degrees
        rot = Matrix.Rotation(math.radians(25), 4, 'X')
        for v in bm.verts:
            v.co = rot @ v.co
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh("skylight_glass", bm, (0, 0, h + 0.5), mats["glass"], parent)


def build_cottage(parent, mats, h, w, d, special):
    # Cozy cottage with peaked roof
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= w * 0.5
        v.co.y *= d * 0.5
        v.co.z *= (h - 1.5) * 0.5
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh("body", bm, (0, 0, (h - 1.5) * 0.5), mats["stone"], parent)
    # Peaked roof — triangular prism
    bm = bmesh.new()
    v1 = bm.verts.new((-w * 0.55, -d * 0.55, 0))
    v2 = bm.verts.new(( w * 0.55, -d * 0.55, 0))
    v3 = bm.verts.new(( w * 0.55,  d * 0.55, 0))
    v4 = bm.verts.new((-w * 0.55,  d * 0.55, 0))
    v5 = bm.verts.new(( 0, -d * 0.55, 1.5))
    v6 = bm.verts.new(( 0,  d * 0.55, 1.5))
    bm.faces.new([v1, v2, v3, v4])  # bottom
    bm.faces.new([v1, v5, v2])      # front triangle
    bm.faces.new([v4, v3, v6])      # back triangle
    bm.faces.new([v1, v4, v6, v5])  # left slope
    bm.faces.new([v2, v5, v6, v3])  # right slope
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh("peaked_roof", bm, (0, 0, h - 1.5), mats["roof"], parent)
    # Door
    add_door(parent, mats, 0, -d * 0.5 - 0.02, 1.0)
    # Warm yellow windows (the cozy tavern look)
    for fy in (-d * 0.5 - 0.02, d * 0.5 + 0.02):
        for fx in (-w * 0.3, w * 0.3):
            bm = bmesh.new()
            bmesh.ops.create_cube(bm, size=1.0)
            for v in bm.verts:
                v.co.x *= 0.45
                v.co.y *= 0.04
                v.co.z *= 0.45
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
            create_mesh("window", bm, (fx, fy, h * 0.5), mats["window_warm"], parent)
    # Chimney
    if special == "chimney":
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= 0.35
            v.co.y *= 0.35
            v.co.z *= 1.20
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh("chimney", bm, (w * 0.30, 0, h - 0.30), mats["dark"], parent)


def build_brick(parent, mats, h, w, d, special):
    # Industrial brick building
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= w * 0.5
        v.co.y *= d * 0.5
        v.co.z *= h * 0.5
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    brick_mat = make_pbr("Brick_Wall", (0.55, 0.30, 0.20), 0.0, 0.85)
    create_mesh("body", bm, (0, 0, h * 0.5), brick_mat, parent)
    # Flat roof
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= w * 0.55
        v.co.y *= d * 0.55
        v.co.z *= 0.15
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh("roof", bm, (0, 0, h + 0.10), mats["dark"], parent)
    # Smokestack + open arch
    if special == "smokestack_arch":
        # Smokestack
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=12, radius1=0.55, radius2=0.50, depth=3.0, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh("smokestack", bm, (w * 0.25, 0, h + 1.5), mats["dark"], parent)
        # Open archway at front (cut a tall arch into the front face — represented as
        # a dark inset)
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= 1.5
            v.co.y *= 0.10
            v.co.z *= 1.7
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh("arch_inset", bm, (0, -d * 0.5 - 0.05, 1.7), mats["dark"], parent)
        # Glowing forge inside the arch (visible orange flame)
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=8, radius=0.45)
        for v in bm.verts:
            v.co.z *= 0.6
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh("forge_glow", bm, (0, -d * 0.5 - 0.20, 1.0), mats["accent"], parent)


def build_tall(parent, mats, h, w, d, special):
    # Tall narrow library
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= w * 0.5
        v.co.y *= d * 0.5
        v.co.z *= h * 0.5
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh("body", bm, (0, 0, h * 0.5), mats["stone"], parent)
    # Flat roof
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= w * 0.55
        v.co.y *= d * 0.55
        v.co.z *= 0.15
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh("roof", bm, (0, 0, h + 0.10), mats["roof"], parent)
    add_door(parent, mats, 0, -d * 0.5 - 0.02, 1.0)
    # Tall narrow windows (the crystal-filled bookshelf windows)
    if special == "tall_windows":
        for fx in (-w * 0.30, 0, w * 0.30):
            bm = bmesh.new()
            bmesh.ops.create_cube(bm, size=1.0)
            for v in bm.verts:
                v.co.x *= 0.35
                v.co.y *= 0.04
                v.co.z *= h * 0.40  # tall
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
            create_mesh("tall_window", bm, (fx, -d * 0.5 - 0.02, h * 0.55), mats["accent"], parent)


def build_greenhouse(parent, mats, h, w, d, special):
    # Long rectangular base
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= w * 0.5
        v.co.y *= d * 0.5
        v.co.z *= 1.0
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh("base", bm, (0, 0, 0.5), mats["stone"], parent)
    # Glass dome over the base
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=24, v_segments=14, radius=max(w, d) * 0.4)
    for v in bm.verts:
        if v.co.z < 0:
            v.co.z *= 0.05
        v.co.x *= w / max(w, d)
        v.co.y *= d / max(w, d)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh("glass_dome", bm, (0, 0, 1.0), mats["glass"], parent)
    # Chrome frame ribs
    for i in range(5):
        angle = (i / 4.0) * math.pi
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=max(w, d) * 0.41)
        for v in bm.verts:
            if v.co.z < 0:
                v.co.z *= 0.05
            v.co.x *= w / max(w, d)
            v.co.y *= d / max(w, d)
            # Keep only verts near the rib angle
            v_angle = math.atan2(v.co.y, v.co.x)
            if abs(v_angle - angle) > 0.15 and abs(v_angle + math.pi - angle) > 0.15:
                v.co *= 0.0
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    add_door(parent, mats, 0, -d * 0.5 - 0.02, 1.0)
    # Plants visible inside (simple green spheres clusters)
    plant_mat = make_pbr("Plant_Green", (0.20, 0.55, 0.15), 0.0, 0.75)
    for i in range(6):
        x = -w * 0.3 + (i % 3) * w * 0.3
        y = -d * 0.3 + (i // 3) * d * 0.3
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=6, radius=0.25)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"plant_{i}", bm, (x, y, 1.30), plant_mat, parent)


def build_circular(parent, mats, h, w, d, special):
    # Circular amphitheater base
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=20, radius1=w * 0.5, radius2=w * 0.5, depth=0.40, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh("base", bm, (0, 0, 0.20), mats["stone"], parent)
    # Curved seating — semi-circle of 4 stepped rings
    if special == "curved_seats":
        for ring in range(4):
            radius = w * 0.45 - ring * 0.6
            bm = bmesh.new()
            bmesh.ops.create_cone(bm, segments=20, radius1=radius, radius2=radius, depth=0.30, cap_ends=True)
            # Cut to a semi-circle by removing the back half verts
            for v in bm.verts:
                if v.co.y > 0:
                    v.co.y = 0
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
            create_mesh(f"seat_ring_{ring}", bm, (0, 0, 0.40 + ring * 0.30), mats["stone"], parent)
    # Stage in the center
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=1.2, radius2=1.0, depth=0.30, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    create_mesh("stage", bm, (0, w * 0.30, 0.15), mats["chrome"], parent)
    # Stage lights (cyan accent)
    for sx in (-1.5, 0, 1.5):
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=6, radius=0.10)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        create_mesh(f"stage_light_{sx}", bm, (sx, w * 0.30, 1.5), mats["accent"], parent)


SHAPE_BUILDERS = {
    "tower": build_tower,
    "dome": build_dome,
    "rectangle": build_rectangle,
    "cottage": build_cottage,
    "brick": build_brick,
    "tall": build_tall,
    "greenhouse": build_greenhouse,
    "circular": build_circular,
}


def build_landmark(building_id, display_name, shape, height, width, depth,
                   accent_rgb, special):
    print(f"\n=== Building landmark: {display_name} ===")
    reset_scene()

    mats = make_shared_mats(building_id, accent_rgb)
    root = bpy.data.objects.new(f"{display_name.replace(chr(39), '').replace(' ', '_')}_Root", None)
    bpy.context.scene.collection.objects.link(root)

    builder = SHAPE_BUILDERS.get(shape)
    if builder is None:
        print(f"  ERROR: unknown shape {shape}")
        return
    builder(root, mats, height, width, depth, special)

    def collect_visible():
        return [o for o in bpy.context.scene.objects if o.type == 'MESH']

    lod_name = f"{building_id.title().replace('_', '')}_LOD0"
    lod0 = build_joined_lod(lod_name, collect_visible(), 4000, lod_name.split('_')[0])
    if lod0 is None:
        print(f"  ERROR: build_joined_lod returned None")
        return
    smart_uv_unwrap(lod0)
    hp = build_high_poly(f"{lod_name.replace('LOD0', 'HP')}", collect_visible(), lod_name.split('_')[0])
    img_normal, img_ao, img_cavity, img_curv = bake_pbr_set(lod0, hp, building_id, TEX_DIR)

    # === Albedo — cream stone with accent emission edges ===
    W, H = 1024, 1024
    ao_arr = img_to_array(img_ao)[:, :, 0]
    curv_arr = img_to_array(img_curv)[:, :, 0]

    y = np.linspace(0, 1, H, dtype=np.float32)[:, None]
    x = np.linspace(0, 1, W, dtype=np.float32)[None, :]
    cell_noise = hash_noise(x, y, 30.0)

    # Cream stone base
    out = np.zeros((H, W, 4), dtype=np.float32)
    out[:, :, 0] = 0.78
    out[:, :, 1] = 0.72
    out[:, :, 2] = 0.60
    out[:, :, 3] = 1.0
    out[:, :, :3] *= (0.85 + 0.30 * cell_noise[:, :, None])
    out[:, :, :3] *= (0.55 + 0.45 * ao_arr[:, :, None])
    # Edge highlight blends to accent color
    edge_mask = np.clip((curv_arr - 0.55) / 0.45, 0.0, 1.0) ** 1.4
    accent_arr = np.array(accent_rgb, dtype=np.float32)
    for c in range(3):
        out[:, :, c] = out[:, :, c] * (1.0 - edge_mask * 0.65) + accent_arr[c] * (edge_mask * 0.65)
    # Cavity darkening
    cav_mask = np.clip((0.45 - curv_arr) / 0.20, 0.0, 1.0) ** 1.2
    out[:, :, :3] *= (1.0 - cav_mask[:, :, None] * 0.35)
    out = np.clip(out, 0.0, 1.0)
    write_albedo(f"{building_id}_albedo", out, TEX_DIR)

    # === LOD chain ===
    def make_lod(target_name, target_tris):
        if bpy.data.objects.get(target_name):
            bpy.data.objects.remove(bpy.data.objects[target_name], do_unlink=True)
        new_obj = lod0.copy()
        new_obj.data = lod0.data.copy()
        new_obj.name = target_name
        new_obj.parent = None
        bpy.context.scene.collection.objects.link(new_obj)
        bm = bmesh.new()
        bm.from_mesh(new_obj.data)
        pre = len(bm.faces)
        bm.free()
        if pre > target_tris:
            ratio = target_tris / pre
            mod = new_obj.modifiers.new("Decimate", 'DECIMATE')
            mod.decimate_type = 'COLLAPSE'
            mod.ratio = ratio
            mod.use_collapse_triangulate = True
            bpy.context.view_layer.objects.active = new_obj
            bpy.ops.object.modifier_apply(modifier="Decimate")
        bm = bmesh.new()
        bm.from_mesh(new_obj.data)
        print(f"  {target_name}: {len(bm.faces)} polys")
        bm.free()
        new_obj.hide_set(True)
        new_obj.hide_render = True

    base_name = lod_name.replace("LOD0", "")
    make_lod(f"{base_name}LOD1", 1500)
    make_lod(f"{base_name}LOD2", 600)

    out_blend = f"{OUT_DIR}/landmark_{building_id}.blend"
    bpy.ops.wm.save_as_mainfile(filepath=out_blend)
    print(f"  Saved: {out_blend}")
    print(f"  LOD0: {len(lod0.data.polygons)} polys, height: {height}m")


for cfg in BUILDING_CONFIGS:
    build_landmark(*cfg)

print(f"\n=== All 10 landmark buildings built ===")
