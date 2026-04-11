"""Epic 21 — Town Districts pipeline (tasks 6-14, 26-32, 35-36, 43-44).

Single Blender CLI script that builds the 5 town district layouts:
- Residential (homes + gardens)
- Market (shops + stalls)
- Commons (tavern + archive + plaza)
- Workshop (forge + lab on a hill)
- Docks (water + boats + fishing)

Plus: connecting paths, district archways, central town hall plaza,
fountains/statues/monuments, bridges between districts.

Output:
  _art_source/world/town_districts.blend  — single master file
"""
import bpy
import bmesh
import os
import sys
import math
import random
from mathutils import Vector, Matrix

SCRIPT_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/scripts"
if SCRIPT_DIR not in sys.path:
    sys.path.insert(0, SCRIPT_DIR)

from enemy_pipeline_utils import make_pbr

random.seed(21)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.scene.unit_settings.system = 'METRIC'

OUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/town_districts.blend"
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)


# === MATERIALS (shared cream-stone-teal palette from Epic 11/12) ===
mat_path_stone   = make_pbr("Town_PathStone",   (0.55, 0.50, 0.42), 0.0, 0.85)
mat_grass        = make_pbr("Town_Grass",       (0.30, 0.55, 0.18), 0.0, 0.80)
mat_dirt         = make_pbr("Town_Dirt",        (0.40, 0.30, 0.20), 0.0, 0.90)
mat_water        = make_pbr("Town_Water",       (0.10, 0.30, 0.50), 0.0, 0.05, (0.20, 0.55, 0.85), 0.5)
mat_wood_dock    = make_pbr("Town_WoodDock",    (0.45, 0.28, 0.15), 0.0, 0.80)
mat_chrome       = make_pbr("Town_Chrome",      (0.85, 0.86, 0.92), 1.0, 0.10)
mat_arch         = make_pbr("Town_Arch",        (0.78, 0.72, 0.60), 0.0, 0.75)
mat_arch_accent  = make_pbr("Town_ArchAccent",  (0.0, 0.85, 1.0),   0.0, 0.10, (0.0, 0.85, 1.0), 5.0)
mat_fountain     = make_pbr("Town_Fountain",    (0.65, 0.62, 0.55), 0.0, 0.65)
mat_statue       = make_pbr("Town_Statue",      (0.55, 0.50, 0.45), 0.0, 0.75)
mat_garden       = make_pbr("Town_Garden",      (0.20, 0.45, 0.15), 0.0, 0.85)
mat_stall_canvas = make_pbr("Town_StallCanvas", (0.85, 0.30, 0.20), 0.0, 0.85)
mat_forge_glow   = make_pbr("Town_ForgeGlow",   (0.40, 0.10, 0.0),  0.0, 0.30, (1.0, 0.45, 0.05), 6.0)
mat_dark         = make_pbr("Town_Dark",        (0.10, 0.10, 0.13), 0.4, 0.55)


# === COLLECTIONS ===
def make_col(name):
    col = bpy.data.collections.get(name)
    if col is None:
        col = bpy.data.collections.new(name)
        bpy.context.scene.collection.children.link(col)
    return col


col_residential = make_col("Town_Residential")
col_market      = make_col("Town_Market")
col_commons     = make_col("Town_Commons")
col_workshop    = make_col("Town_Workshop")
col_docks       = make_col("Town_Docks")
col_paths       = make_col("Town_Paths")
col_archways    = make_col("Town_Archways")
col_central     = make_col("Town_Central")


def add_to(obj, col):
    for c in obj.users_collection:
        c.objects.unlink(obj)
    col.objects.link(obj)


def cube_mesh(w, d, h):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= w * 0.5
        v.co.y *= d * 0.5
        v.co.z *= h * 0.5
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return bm


def create_mesh(name, bm, location, material, smooth=True):
    me = bpy.data.meshes.new(name + "_mesh")
    bm.to_mesh(me)
    bm.free()
    obj = bpy.data.objects.new(name, me)
    obj.location = location
    obj.data.materials.append(material)
    bpy.context.scene.collection.objects.link(obj)
    if smooth:
        for p in obj.data.polygons:
            p.use_smooth = True
    return obj


# Town layout: each district 80×80m at the cardinal positions, central plaza at origin
DISTRICT_RADIUS = 60.0  # distance from center to district anchor
DISTRICT_SIZE = 80.0


# === CENTRAL TOWN HALL PLAZA (Task 43) ===
print("\n=== Central Town Hall Plaza ===")
# Large stone plaza
obj = create_mesh("plaza_floor", cube_mesh(40.0, 40.0, 0.10), (0, 0, 0.05), mat_path_stone)
add_to(obj, col_central)
# Town hall building (large cream stone with peaked roof)
obj = create_mesh("town_hall_body", cube_mesh(12.0, 10.0, 8.0), (0, 0, 4.0), mat_arch)
add_to(obj, col_central)
# Peaked roof
bm = bmesh.new()
v1 = bm.verts.new((-6.5, -5.5, 0))
v2 = bm.verts.new(( 6.5, -5.5, 0))
v3 = bm.verts.new(( 6.5,  5.5, 0))
v4 = bm.verts.new((-6.5,  5.5, 0))
v5 = bm.verts.new(( 0, -5.5, 2.5))
v6 = bm.verts.new(( 0,  5.5, 2.5))
bm.faces.new([v1, v2, v3, v4])
bm.faces.new([v1, v5, v2])
bm.faces.new([v4, v3, v6])
bm.faces.new([v1, v4, v6, v5])
bm.faces.new([v2, v5, v6, v3])
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("town_hall_roof", bm, (0, 0, 8.0), mat_dark)
add_to(obj, col_central)

# === CENTRAL FOUNTAIN (Task 44) ===
# Big circular fountain in front of the town hall
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=24, radius1=3.5, radius2=3.2, depth=0.80, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("fountain_basin", bm, (0, -10, 0.40), mat_fountain)
add_to(obj, col_central)
# Inner water surface
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=24, radius1=3.0, radius2=3.0, depth=0.04, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("fountain_water", bm, (0, -10, 0.78), mat_water)
add_to(obj, col_central)
# Central column with water spout
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=12, radius1=0.40, radius2=0.30, depth=2.0, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("fountain_column", bm, (0, -10, 1.80), mat_fountain)
add_to(obj, col_central)
# Top spout cap
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.20)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("fountain_spout", bm, (0, -10, 2.90), mat_chrome)
add_to(obj, col_central)

# Plaza statues (4 corners)
for i, (x, y) in enumerate([(-15, -15), (15, -15), (-15, 15), (15, 15)]):
    parent = bpy.data.objects.new(f"plaza_statue_{i+1}", None)
    bpy.context.scene.collection.objects.link(parent)
    add_to(parent, col_central)
    # Pedestal
    obj = create_mesh(f"statue_{i+1}_pedestal", cube_mesh(1.5, 1.5, 1.2), (x, y, 0.60), mat_chrome)
    obj.parent = parent
    add_to(obj, col_central)
    # Statue body (humanoid)
    obj = create_mesh(f"statue_{i+1}_body", cube_mesh(0.8, 0.50, 2.2), (x, y, 2.30), mat_statue)
    obj.parent = parent
    add_to(obj, col_central)
    # Head
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=10, radius=0.25)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"statue_{i+1}_head", bm, (x, y, 3.55), mat_statue)
    obj.parent = parent
    add_to(obj, col_central)


# === DISTRICT 1: RESIDENTIAL (Task 6, 26) ===
print("\n=== Residential District ===")
res_x = -DISTRICT_RADIUS
res_y = 0
# Floor / grass area
obj = create_mesh("res_grass", cube_mesh(DISTRICT_SIZE, DISTRICT_SIZE, 0.10), (res_x, res_y, 0.05), mat_grass)
add_to(obj, col_residential)
# 8 small home placeholder blocks (filler positions)
for i in range(8):
    angle = i * (math.tau / 8)
    px = res_x + math.cos(angle) * 25.0
    py = res_y + math.sin(angle) * 25.0
    obj = create_mesh(f"res_home_{i+1}", cube_mesh(6.0, 5.0, 4.0), (px, py, 2.0), mat_arch)
    add_to(obj, col_residential)
    # Peaked roof on each home
    bm = bmesh.new()
    v1 = bm.verts.new((-3.3, -2.8, 0))
    v2 = bm.verts.new(( 3.3, -2.8, 0))
    v3 = bm.verts.new(( 3.3,  2.8, 0))
    v4 = bm.verts.new((-3.3,  2.8, 0))
    v5 = bm.verts.new(( 0, -2.8, 1.5))
    v6 = bm.verts.new(( 0,  2.8, 1.5))
    bm.faces.new([v1, v2, v3, v4])
    bm.faces.new([v1, v5, v2])
    bm.faces.new([v4, v3, v6])
    bm.faces.new([v1, v4, v6, v5])
    bm.faces.new([v2, v5, v6, v3])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"res_home_{i+1}_roof", bm, (px, py, 4.0), mat_dark)
    add_to(obj, col_residential)
# 4 garden patches
for i in range(4):
    angle = i * (math.tau / 4) + math.pi / 4
    gx = res_x + math.cos(angle) * 12.0
    gy = res_y + math.sin(angle) * 12.0
    obj = create_mesh(f"res_garden_{i+1}", cube_mesh(4.0, 4.0, 0.06), (gx, gy, 0.13), mat_garden)
    add_to(obj, col_residential)


# === DISTRICT 2: MARKET (Task 7, 27) ===
print("\n=== Market District ===")
mkt_x = DISTRICT_RADIUS
mkt_y = 0
obj = create_mesh("mkt_floor", cube_mesh(DISTRICT_SIZE, DISTRICT_SIZE, 0.10), (mkt_x, mkt_y, 0.05), mat_path_stone)
add_to(obj, col_market)
# 6 market stalls in 2 rows
for i in range(6):
    row = i // 3
    col = i % 3
    sx = mkt_x - 12 + col * 8
    sy = mkt_y - 6 + row * 12
    parent = bpy.data.objects.new(f"mkt_stall_{i+1}", None)
    bpy.context.scene.collection.objects.link(parent)
    add_to(parent, col_market)
    # Stall counter
    obj = create_mesh(f"stall_{i+1}_counter", cube_mesh(3.0, 1.5, 1.0), (sx, sy, 0.50), mat_wood_dock)
    obj.parent = parent
    add_to(obj, col_market)
    # 4 corner posts
    for sx_dir, sy_dir in [(-1, -1), (1, -1), (-1, 1), (1, 1)]:
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=6, radius1=0.06, radius2=0.06, depth=2.5, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj = create_mesh(f"stall_{i+1}_post_{sx_dir}_{sy_dir}", bm, (sx + sx_dir * 1.4, sy + sy_dir * 0.7, 1.25), mat_chrome)
        obj.parent = parent
        add_to(obj, col_market)
    # Canvas awning (red triangular roof)
    bm = bmesh.new()
    v1 = bm.verts.new((-1.5, -0.8, 0))
    v2 = bm.verts.new(( 1.5, -0.8, 0))
    v3 = bm.verts.new(( 1.5,  0.8, 0))
    v4 = bm.verts.new((-1.5,  0.8, 0))
    v5 = bm.verts.new(( 0, -0.8, 0.6))
    v6 = bm.verts.new(( 0,  0.8, 0.6))
    bm.faces.new([v1, v5, v2])
    bm.faces.new([v4, v3, v6])
    bm.faces.new([v1, v4, v6, v5])
    bm.faces.new([v2, v5, v6, v3])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"stall_{i+1}_awning", bm, (sx, sy, 2.55), mat_stall_canvas)
    obj.parent = parent
    add_to(obj, col_market)


# === DISTRICT 3: COMMONS (Task 8, 28) ===
print("\n=== Commons District ===")
com_x = 0
com_y = DISTRICT_RADIUS
obj = create_mesh("com_floor", cube_mesh(DISTRICT_SIZE, DISTRICT_SIZE, 0.10), (com_x, com_y, 0.05), mat_path_stone)
add_to(obj, col_commons)
# Central gathering plaza area (5x5m raised stone)
obj = create_mesh("com_gathering_plaza", cube_mesh(15.0, 15.0, 0.20), (com_x, com_y, 0.20), mat_arch)
add_to(obj, col_commons)
# 6 benches around the gathering plaza
for i in range(6):
    angle = i * (math.tau / 6)
    bx = com_x + math.cos(angle) * 6.0
    by = com_y + math.sin(angle) * 6.0
    parent = bpy.data.objects.new(f"com_bench_{i+1}", None)
    bpy.context.scene.collection.objects.link(parent)
    add_to(parent, col_commons)
    obj = create_mesh(f"bench_{i+1}_seat", cube_mesh(1.5, 0.40, 0.06), (bx, by, 0.45), mat_wood_dock)
    obj.parent = parent
    add_to(obj, col_commons)
    for sx in (-1, 1):
        obj = create_mesh(f"bench_{i+1}_leg_{sx}", cube_mesh(0.06, 0.40, 0.40), (bx + sx * 0.7, by, 0.20), mat_wood_dock)
        obj.parent = parent
        add_to(obj, col_commons)


# === DISTRICT 4: WORKSHOP (Task 9, 29, 36) ===
print("\n=== Workshop District (on a hill) ===")
ws_x = 0
ws_y = -DISTRICT_RADIUS
# Hill base — slightly elevated terrain (Task 36)
obj = create_mesh("ws_hill_base", cube_mesh(DISTRICT_SIZE, DISTRICT_SIZE, 1.0), (ws_x, ws_y, 0.50), mat_dirt)
add_to(obj, col_workshop)
# Top stone plaza
obj = create_mesh("ws_floor", cube_mesh(40.0, 40.0, 0.10), (ws_x, ws_y, 1.05), mat_path_stone)
add_to(obj, col_workshop)
# Active forge with VFX anchor (Task 29)
parent = bpy.data.objects.new("ws_forge_active", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_workshop)
# Forge body
obj = create_mesh("forge_body", cube_mesh(4.0, 4.0, 2.5), (ws_x, ws_y - 5, 2.30), mat_dark)
obj.parent = parent
add_to(obj, col_workshop)
# Smokestack
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=12, radius1=0.55, radius2=0.50, depth=4.0, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("forge_smokestack", bm, (ws_x + 1.2, ws_y - 5, 5.55), mat_dark)
obj.parent = parent
add_to(obj, col_workshop)
# Forge open arch with glow (Task 29 — active flame VFX anchor)
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
for v in bm.verts:
    v.co.x *= 1.5
    v.co.y *= 0.10
    v.co.z *= 1.7
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("forge_arch_inset", bm, (ws_x, ws_y - 7.05, 1.85), mat_dark)
obj.parent = parent
add_to(obj, col_workshop)
# Glowing forge sphere
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=10, radius=0.50)
for v in bm.verts:
    v.co.z *= 0.7
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("forge_glow", bm, (ws_x, ws_y - 7.20, 1.50), mat_forge_glow)
obj.parent = parent
add_to(obj, col_workshop)
# 4 anvil props around the forge
for i, (x_off, y_off) in enumerate([(-3, 2), (3, 2), (-3, -2), (3, -2)]):
    obj = create_mesh(f"ws_anvil_{i+1}", cube_mesh(0.80, 0.40, 0.50), (ws_x + x_off, ws_y + y_off, 1.30), mat_chrome)
    add_to(obj, col_workshop)


# === DISTRICT 5: DOCKS (Task 10, 30, 31, 32) ===
print("\n=== Docks District (water + boats) ===")
# The docks district uses two zones — land platform and water zone
dk_x = DISTRICT_RADIUS * 0.7
dk_y = -DISTRICT_RADIUS * 0.7
# Stone wharf
obj = create_mesh("dk_wharf", cube_mesh(50.0, 30.0, 0.20), (dk_x, dk_y, 0.10), mat_path_stone)
add_to(obj, col_docks)
# Water zone (next to the wharf, extending outward)
obj = create_mesh("dk_water_zone", cube_mesh(60.0, 40.0, 0.10), (dk_x + 30, dk_y - 25, -0.20), mat_water)
add_to(obj, col_docks)
# 4 wooden dock platforms extending into water
for i in range(4):
    dock_y_off = -8 + i * 4
    obj = create_mesh(f"dk_dock_{i+1}", cube_mesh(2.5, 8.0, 0.20), (dk_x + 18, dk_y + dock_y_off, 0.10), mat_wood_dock)
    add_to(obj, col_docks)
    # Dock posts at the end
    for sx in (-1, 1):
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=8, radius1=0.10, radius2=0.10, depth=1.5, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj = create_mesh(f"dk_post_{i+1}_{sx}", bm, (dk_x + 18 + sx * 1.0, dk_y + dock_y_off - 3.5, 0.75), mat_wood_dock)
        add_to(obj, col_docks)
# 3 boats (boat = elongated cube + bow point)
for i in range(3):
    boat_y = dk_y - 6 + i * 6
    boat_x = dk_x + 22
    parent = bpy.data.objects.new(f"dk_boat_{i+1}", None)
    bpy.context.scene.collection.objects.link(parent)
    add_to(parent, col_docks)
    # Hull
    obj = create_mesh(f"boat_{i+1}_hull", cube_mesh(1.5, 4.0, 0.60), (boat_x, boat_y, 0.10), mat_wood_dock)
    obj.parent = parent
    add_to(obj, col_docks)
    # Bow point
    bm = bmesh.new()
    v1 = bm.verts.new((0, -2.0, -0.30))
    v2 = bm.verts.new((0,  2.0, -0.30))
    v3 = bm.verts.new((0,  2.0,  0.30))
    v4 = bm.verts.new((0, -2.0,  0.30))
    v5 = bm.verts.new((0.8, 0, 0))
    bm.faces.new([v1, v2, v5])
    bm.faces.new([v3, v4, v5])
    bm.faces.new([v1, v5, v4])
    bm.faces.new([v2, v3, v5])
    bm.faces.new([v1, v4, v3, v2])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"boat_{i+1}_bow", bm, (boat_x + 1.0, boat_y, 0.10), mat_wood_dock)
    obj.parent = parent
    add_to(obj, col_docks)
    # Mast
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=8, radius1=0.06, radius2=0.04, depth=2.5, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"boat_{i+1}_mast", bm, (boat_x, boat_y, 1.65), mat_wood_dock)
    obj.parent = parent
    add_to(obj, col_docks)


# === CONNECTING PATHS (Task 13) ===
print("\n=== Connecting paths ===")
# Path from center plaza to each district
districts = [
    ("residential", -DISTRICT_RADIUS, 0),
    ("market",       DISTRICT_RADIUS, 0),
    ("commons",      0,  DISTRICT_RADIUS),
    ("workshop",     0, -DISTRICT_RADIUS),
    ("docks",        DISTRICT_RADIUS * 0.7, -DISTRICT_RADIUS * 0.7),
]
for name, dx, dy in districts:
    # Compute path midpoint and length
    mid_x = dx * 0.5
    mid_y = dy * 0.5
    length = math.sqrt(dx**2 + dy**2)
    # Path orientation
    angle = math.atan2(dy, dx)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= length * 0.5
        v.co.y *= 1.5
        v.co.z *= 0.04
    rot = Matrix.Rotation(angle, 4, 'Z')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"path_to_{name}", bm, (mid_x, mid_y, 0.12), mat_path_stone)
    add_to(obj, col_paths)


# === DISTRICT ARCHWAY ENTRY MARKERS (Task 14) ===
print("\n=== District archways ===")
for name, dx, dy in districts:
    angle = math.atan2(dy, dx)
    arch_x = dx * 0.6
    arch_y = dy * 0.6
    parent = bpy.data.objects.new(f"archway_{name}", None)
    bpy.context.scene.collection.objects.link(parent)
    add_to(parent, col_archways)
    # 2 vertical pillars
    for sx in (-1, 1):
        offset_x = math.sin(angle) * 2.0 * sx
        offset_y = -math.cos(angle) * 2.0 * sx
        obj = create_mesh(f"arch_{name}_pillar_{sx}", cube_mesh(0.50, 0.50, 4.0), (arch_x + offset_x, arch_y + offset_y, 2.0), mat_arch)
        obj.parent = parent
        add_to(obj, col_archways)
    # Top beam
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 4.5
        v.co.y *= 0.50
        v.co.z *= 0.50
    rot = Matrix.Rotation(angle + math.pi / 2, 4, 'Z')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"arch_{name}_beam", bm, (arch_x, arch_y, 4.25), mat_arch)
    obj.parent = parent
    add_to(obj, col_archways)
    # Cyan accent strip on the beam
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 4.0
        v.co.y *= 0.06
        v.co.z *= 0.06
    rot = Matrix.Rotation(angle + math.pi / 2, 4, 'Z')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"arch_{name}_accent", bm, (arch_x, arch_y, 4.55), mat_arch_accent)
    obj.parent = parent
    add_to(obj, col_archways)


# === BRIDGES BETWEEN DISTRICTS (Task 35) ===
print("\n=== Bridges between adjacent districts ===")
# Bridge between Workshop hill and Docks (elevation difference)
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
for v in bm.verts:
    v.co.x *= 12.0
    v.co.y *= 2.0
    v.co.z *= 0.20
# Slight tilt for the elevation transition
rot = Matrix.Rotation(math.radians(-5), 4, 'X')
for v in bm.verts:
    v.co = rot @ v.co
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("bridge_workshop_to_docks", bm, (25, -45, 0.80), mat_wood_dock)
add_to(obj, col_paths)
# 2 bridge railings
for sy in (-1, 1):
    obj = create_mesh(f"bridge_workshop_railing_{sy}", cube_mesh(12.0, 0.06, 0.50), (25, -45 + sy * 1.0, 1.05), mat_chrome)
    add_to(obj, col_paths)


# === SAVE ===
bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
total = len([o for o in bpy.context.scene.objects if o.type == 'MESH'])
print(f"\nTown Districts complete. Total mesh objects: {total}")
print(f"Saved: {OUT_BLEND}")
