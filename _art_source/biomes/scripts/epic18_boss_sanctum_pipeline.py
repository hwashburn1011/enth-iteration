"""Epic 18 — Boss Sanctum / Final Vault biome pipeline (tasks 2-25, 36-49).

Single Blender CLI script that builds the entire Boss Sanctum:
- 25m radius circular arena
- Central altar where the boss spawns
- 8 unique perimeter pillars
- Throne backdrop wall
- 6 procession lining statues
- 4 floating light fixtures
- Trophy alcoves + chest pedestal + skybox backdrop

Output:
  _art_source/biomes/boss_sanctum.blend
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

random.seed(18)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.scene.unit_settings.system = 'METRIC'

OUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/biomes/boss_sanctum.blend"
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)


# === MATERIALS (cathedral-grade hero palette) ===
mat_floor       = make_pbr("BS_Floor",      (0.05, 0.06, 0.10), 0.4, 0.45)
mat_inlay       = make_pbr("BS_Inlay",      (0.0, 0.55, 0.65), 0.0, 0.10, (0.0, 0.95, 1.0), 6.0)
mat_pillar      = make_pbr("BS_Pillar",     (0.10, 0.12, 0.18), 0.3, 0.55)
mat_pillar_crown= make_pbr("BS_PillarCrown",(0.0, 0.45, 0.55), 0.0, 0.05, (0.0, 0.85, 1.0), 8.0)
mat_wall        = make_pbr("BS_Wall",       (0.06, 0.07, 0.10), 0.0, 0.65)
mat_ceiling     = make_pbr("BS_Ceiling",    (0.04, 0.05, 0.08), 0.0, 0.65)
mat_chrome      = make_pbr("BS_Chrome",     (0.85, 0.86, 0.92), 1.0, 0.10)
mat_dark        = make_pbr("BS_Dark",       (0.02, 0.02, 0.04), 0.4, 0.55)
mat_throne      = make_pbr("BS_Throne",     (0.10, 0.10, 0.15), 0.5, 0.45)
mat_god_ray     = make_pbr("BS_GodRay",     (0.20, 0.45, 0.65), 0.0, 0.10, (0.0, 0.85, 1.0), 4.0)
mat_statue      = make_pbr("BS_Statue",     (0.55, 0.50, 0.45), 0.0, 0.75)
mat_light_fixture = make_pbr("BS_Fixture",  (0.85, 0.86, 0.92), 1.0, 0.10, (0.0, 0.85, 1.0), 6.0)
mat_skybox      = make_pbr("BS_Skybox",     (0.10, 0.20, 0.40), 0.0, 0.85, (0.20, 0.45, 0.85), 1.5)
mat_throne_glow = make_pbr("BS_ThroneGlow", (0.20, 0.10, 0.30), 0.0, 0.10, (0.85, 0.30, 1.0), 6.0)


# === COLLECTIONS ===
def make_col(name):
    col = bpy.data.collections.get(name)
    if col is None:
        col = bpy.data.collections.new(name)
        bpy.context.scene.collection.children.link(col)
    return col


col_arena = make_col("BS_Arena")
col_pillars = make_col("BS_Pillars")
col_processional = make_col("BS_Processional")
col_throne = make_col("BS_Throne")
col_props = make_col("BS_Props")


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


# === ARENA FLOOR + INLAY ===
print("\n=== Arena floor ===")
# Main 25m radius circular dais
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=48, radius1=25.0, radius2=25.0, depth=0.30, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("arena_floor", bm, (0, 0, 0.15), mat_floor)
add_to(obj, col_arena)

# 3 concentric cyan inlay rings
for r in (8.0, 14.0, 20.0):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=48, radius1=r + 0.30, radius2=r + 0.30, depth=0.04, cap_ends=False)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"arena_inlay_ring_{int(r)}", bm, (0, 0, 0.32), mat_inlay)
    add_to(obj, col_arena)
# Cross pattern through center
for rot_z in (0, 90):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 24.0
        v.co.y *= 0.10
        v.co.z *= 0.04
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"arena_inlay_cross_{rot_z}", bm, (0, 0, 0.32), mat_inlay)
    obj.rotation_euler = (0, 0, math.radians(rot_z))
    add_to(obj, col_arena)

# === CENTRAL ALTAR (Task 3) ===
print("=== Central altar ===")
# Raised 4×4×0.5m platform
obj = create_mesh("altar_platform", cube_mesh(4.0, 4.0, 0.50), (0, 0, 0.55), mat_floor)
add_to(obj, col_arena)
# 4 corner crystals
for sx in (-1, 1):
    for sy in (-1, 1):
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=6, radius1=0.20, radius2=0.04, depth=0.60, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj = create_mesh(f"altar_crystal_{sx}_{sy}", bm, (sx * 1.6, sy * 1.6, 1.10), mat_inlay)
        add_to(obj, col_arena)
# Center sculpture (hovering chrome obelisk)
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=6, radius1=0.40, radius2=0.10, depth=2.0, cap_ends=True)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("altar_obelisk", bm, (0, 0, 1.80), mat_chrome)
add_to(obj, col_arena)
# Floating cyan ring around it
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=24, radius1=0.80, radius2=0.80, depth=0.06, cap_ends=False)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("altar_floating_ring", bm, (0, 0, 1.50), mat_pillar_crown)
add_to(obj, col_arena)


# === 8 UNIQUE PERIMETER PILLARS (Task 4) ===
print("=== 8 perimeter pillars ===")
PILLAR_RADIUS = 22.0
PILLAR_HEIGHT = 12.0
for i in range(8):
    angle = i * (math.tau / 8)
    x = math.cos(angle) * PILLAR_RADIUS
    y = math.sin(angle) * PILLAR_RADIUS
    parent = bpy.data.objects.new(f"pillar_{i+1}", None)
    bpy.context.scene.collection.objects.link(parent)
    add_to(parent, col_pillars)

    # Base — wide square
    obj = create_mesh(f"pillar_{i+1}_base", cube_mesh(1.6, 1.6, 0.60), (x, y, 0.30), mat_pillar)
    obj.parent = parent
    add_to(obj, col_pillars)

    # Shaft variants — each pillar has a different shape
    if i % 4 == 0:
        # Round column
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=18, radius1=0.55, radius2=0.50, depth=PILLAR_HEIGHT - 1.5, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    elif i % 4 == 1:
        # Hex column
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=6, radius1=0.55, radius2=0.50, depth=PILLAR_HEIGHT - 1.5, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    elif i % 4 == 2:
        # Square column
        bm = cube_mesh(1.0, 1.0, PILLAR_HEIGHT - 1.5)
    else:
        # Tapered column
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=12, radius1=0.65, radius2=0.30, depth=PILLAR_HEIGHT - 1.5, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"pillar_{i+1}_shaft", bm, (x, y, PILLAR_HEIGHT * 0.5), mat_pillar)
    obj.parent = parent
    add_to(obj, col_pillars)

    # Crown — cyan accent capital
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=10, radius=0.85)
    for v in bm.verts:
        v.co.z *= 0.30
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"pillar_{i+1}_crown", bm, (x, y, PILLAR_HEIGHT - 0.15), mat_pillar_crown)
    obj.parent = parent
    add_to(obj, col_pillars)

    # 3 vertical accent strips on the shaft (cyan emission)
    for j in range(3):
        a = j * (math.tau / 3)
        sx = math.cos(a) * 0.58
        sy = math.sin(a) * 0.58
        bm = cube_mesh(0.06, 0.06, PILLAR_HEIGHT - 2.0)
        obj = create_mesh(f"pillar_{i+1}_strip_{j+1}", bm, (x + sx, y + sy, PILLAR_HEIGHT * 0.5), mat_inlay)
        obj.parent = parent
        add_to(obj, col_pillars)


# === OUTER WALL + ARCHWAY OPENINGS ===
print("=== Outer ring wall + arches ===")
# 6 wall sections with 6 archway gaps between them
for i in range(6):
    angle = i * (math.tau / 6) + (math.pi / 12)  # offset so the gaps face cardinal directions
    x = math.cos(angle) * 25.0
    y = math.sin(angle) * 25.0
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 8.0   # arc length approximation
        v.co.y *= 0.50  # wall thickness
        v.co.z *= 12.0  # wall height
    # Tilt to face center
    rot_z = math.atan2(y, x) + math.pi / 2
    rot = Matrix.Rotation(rot_z, 4, 'Z')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"wall_section_{i+1}", bm, (x, y, 6.0), mat_wall)
    add_to(obj, col_arena)
    # Skybox backdrop visible through the gap on the opposite side
    backdrop_angle = angle + math.pi / 6
    bx = math.cos(backdrop_angle) * 30.0
    by = math.sin(backdrop_angle) * 30.0
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 6.0
        v.co.y *= 0.10
        v.co.z *= 8.0
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"skybox_backdrop_{i+1}", bm, (bx, by, 6.0), mat_skybox)
    add_to(obj, col_arena)


# === DOMED CEILING + 4 GOD RAY VENTS ===
print("=== Domed ceiling + god rays ===")
# Dome top — half UV sphere
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=32, v_segments=18, radius=26.0)
# Cut bottom half
for v in bm.verts:
    if v.co.z < 0:
        v.co.z = 0
# Flip normals so the inside is rendered
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
bmesh.ops.reverse_faces(bm, faces=bm.faces)
obj = create_mesh("ceiling_dome", bm, (0, 0, 12.0), mat_ceiling)
add_to(obj, col_arena)

# 4 god ray ceiling vents — large cyan emissive disks
for i in range(4):
    angle = i * (math.pi / 2) + math.pi / 4
    x = math.cos(angle) * 8.0
    y = math.sin(angle) * 8.0
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=18, radius1=2.0, radius2=2.0, depth=0.20, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"god_ray_vent_{i+1}", bm, (x, y, 14.5), mat_god_ray)
    add_to(obj, col_arena)


# === THRONE BACKDROP (Task 5) ===
print("=== Throne backdrop wall ===")
parent = bpy.data.objects.new("throne_backdrop_root", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_throne)
# Massive sculptural wall in the back semicircle (z=15-25, behind y > 8)
# Main wall (curved approximation via 3 segments)
for i, (x, y, rot_z) in enumerate([
    (-12, 18, math.radians(-30)),
    (0, 22, 0),
    (12, 18, math.radians(30)),
]):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 12.0
        v.co.y *= 0.80
        v.co.z *= 10.0
    rot = Matrix.Rotation(rot_z, 4, 'Z')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"throne_wall_{i+1}", bm, (x, y, 17.0), mat_throne)
    obj.parent = parent
    add_to(obj, col_throne)

# Floating chrome geometry forming abstract simulation imagery
for i in range(8):
    angle = i * (math.pi / 7) + math.pi / 14
    r = random.uniform(8, 14)
    x = math.cos(angle + math.pi / 2) * r
    y = 14 + math.sin(angle + math.pi / 2) * r * 0.5
    z = 12 + (i % 4) * 2.0
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 0.40 + (i % 3) * 0.20
        v.co.y *= 0.40 + (i % 3) * 0.20
        v.co.z *= 0.40 + (i % 3) * 0.20
    rot = Matrix.Rotation(math.radians(i * 15), 4, 'Z') @ Matrix.Rotation(math.radians(i * 23), 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"throne_floating_{i+1}", bm, (x, y, z), mat_chrome)
    obj.parent = parent
    add_to(obj, col_throne)

# Center violet glow seal on the throne
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=24, v_segments=14, radius=1.40)
for v in bm.verts:
    v.co.y *= 0.20
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("throne_center_seal", bm, (0, 19.5, 13.0), mat_throne_glow)
obj.parent = parent
add_to(obj, col_throne)


# === PROCESSIONAL ENTRY (Task 6) ===
print("=== Processional entry corridor + 6 lining statues ===")
parent = bpy.data.objects.new("processional_entry_root", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_processional)
# Entry corridor floor (extends from y=-25 inward toward arena)
obj = create_mesh("processional_floor", cube_mesh(8.0, 30.0, 0.20), (0, -40, 0.10), mat_floor)
obj.parent = parent
add_to(obj, col_processional)
# Cyan inlay strip down the center
obj = create_mesh("processional_inlay", cube_mesh(0.60, 28.0, 0.06), (0, -40, 0.22), mat_inlay)
obj.parent = parent
add_to(obj, col_processional)

# 6 lining statues (3 per side)
for i in range(6):
    side = -1 if i % 2 == 0 else 1
    y_pos = -50 + (i // 2) * 8
    x_pos = side * 3.0
    statue_parent = bpy.data.objects.new(f"lining_statue_{i+1}", None)
    bpy.context.scene.collection.objects.link(statue_parent)
    add_to(statue_parent, col_processional)
    # Pedestal
    obj = create_mesh(f"statue_{i+1}_pedestal", cube_mesh(1.2, 1.2, 0.60), (x_pos, y_pos, 0.30), mat_chrome)
    obj.parent = statue_parent
    add_to(obj, col_processional)
    # Statue body — vary the shape per index
    if i % 3 == 0:
        # Tall slim figure
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=10, radius1=0.40, radius2=0.30, depth=2.4, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj = create_mesh(f"statue_{i+1}_body", bm, (x_pos, y_pos, 1.80), mat_statue)
    elif i % 3 == 1:
        # Squat warrior figure
        bm = cube_mesh(0.80, 0.50, 2.0)
        obj = create_mesh(f"statue_{i+1}_body", bm, (x_pos, y_pos, 1.60), mat_statue)
    else:
        # Hooded figure (cone)
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=12, radius1=0.55, radius2=0.20, depth=2.2, cap_ends=True)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj = create_mesh(f"statue_{i+1}_body", bm, (x_pos, y_pos, 1.70), mat_statue)
    obj.parent = statue_parent
    add_to(obj, col_processional)
    # Head
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=10, radius=0.22)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"statue_{i+1}_head", bm, (x_pos, y_pos, 3.10), mat_statue)
    obj.parent = statue_parent
    add_to(obj, col_processional)


# === 4 FLOATING LIGHT FIXTURES (Task 9) ===
print("=== 4 floating light fixtures ===")
for i in range(4):
    angle = i * (math.pi / 2) + math.pi / 4
    x = math.cos(angle) * 6.0
    y = math.sin(angle) * 6.0
    parent = bpy.data.objects.new(f"floating_fixture_{i+1}", None)
    bpy.context.scene.collection.objects.link(parent)
    add_to(parent, col_props)
    # Outer chrome cage
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=0.45, radius2=0.30, depth=0.40, cap_ends=False)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"fixture_{i+1}_cage", bm, (x, y, 8.0), mat_chrome)
    obj.parent = parent
    add_to(obj, col_props)
    # Inner glowing orb
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.20)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"fixture_{i+1}_orb", bm, (x, y, 8.0), mat_light_fixture)
    obj.parent = parent
    add_to(obj, col_props)


# === TROPHY ALCOVES (Task 24) ===
print("=== Trophy alcoves ===")
for i in range(4):
    angle = i * (math.pi / 2) + math.pi / 8
    x = math.cos(angle) * 18.0
    y = math.sin(angle) * 18.0
    parent = bpy.data.objects.new(f"trophy_alcove_{i+1}", None)
    bpy.context.scene.collection.objects.link(parent)
    add_to(parent, col_props)
    # Niche frame
    obj = create_mesh(f"alcove_{i+1}_frame", cube_mesh(1.8, 0.40, 3.0), (x, y, 1.5), mat_dark)
    obj.parent = parent
    add_to(obj, col_props)
    # Trophy stand
    obj = create_mesh(f"alcove_{i+1}_stand", cube_mesh(0.50, 0.50, 1.0), (x, y, 0.50), mat_chrome)
    obj.parent = parent
    add_to(obj, col_props)
    # Trophy item (cyan crystal)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.20, radius2=0.04, depth=0.50, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"alcove_{i+1}_trophy", bm, (x, y, 1.30), mat_inlay)
    obj.parent = parent
    add_to(obj, col_props)


# === CHEST PEDESTAL (Task 37) ===
print("=== Chest pedestal ===")
parent = bpy.data.objects.new("chest_pedestal", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
# Pedestal — slightly off-center
obj = create_mesh("chest_pedestal_base", cube_mesh(1.6, 1.6, 0.40), (0, 8, 0.20), mat_chrome)
obj.parent = parent
add_to(obj, col_props)
# Top platform
obj = create_mesh("chest_pedestal_top", cube_mesh(1.4, 1.4, 0.10), (0, 8, 0.45), mat_inlay)
obj.parent = parent
add_to(obj, col_props)


# === SAVE ===
bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
total = len([o for o in bpy.context.scene.objects if o.type == 'MESH'])
print(f"\nBoss Sanctum complete. Total mesh objects: {total}")
print(f"Saved: {OUT_BLEND}")
