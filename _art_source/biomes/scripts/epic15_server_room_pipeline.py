"""Epic 15 — Server Room Biome pipeline (tasks 2-18, 21-25, 32, 47).

Single Blender CLI script that builds the entire Server Room dungeon biome:
- 12 modular tileset pieces (floors, walls, ceilings, corners, junctions, doors)
- 6 server-rack hero prop variants
- 6 terminal/console prop variants
- Holographic display, cooling fan, floor grate, cable bundles, power conduit, steam vent
- 2 trap variants (electric floor, falling tile)
- 8 prebuilt room layouts assembled from the kit

Output:
  _art_source/biomes/server_room.blend  — single master file with all collections

Run via:
    blender.exe --background --python _art_source/biomes/scripts/epic15_server_room_pipeline.py
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

random.seed(15)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.scene.unit_settings.system = 'METRIC'

OUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/biomes/server_room.blend"
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)


# === MATERIALS (cold blue server room palette) ===
mat_floor      = make_pbr("SR_Floor",     (0.10, 0.10, 0.13), 0.6, 0.55)
mat_grate      = make_pbr("SR_Grate",     (0.05, 0.05, 0.07), 0.8, 0.65)
mat_wall_metal = make_pbr("SR_WallMetal", (0.12, 0.13, 0.18), 0.7, 0.50)
mat_wall_panel = make_pbr("SR_WallPanel", (0.18, 0.20, 0.25), 0.5, 0.45)
mat_ceiling    = make_pbr("SR_Ceiling",   (0.08, 0.08, 0.10), 0.6, 0.55)
mat_chrome     = make_pbr("SR_Chrome",    (0.85, 0.86, 0.92), 1.0, 0.10)
mat_pipe       = make_pbr("SR_Pipe",      (0.45, 0.46, 0.50), 1.0, 0.30)
mat_dark       = make_pbr("SR_Dark",      (0.04, 0.04, 0.05), 0.4, 0.55)
# LED colors per server-rack variant
mat_led_cyan   = make_pbr("SR_LED_Cyan",  (0.0, 0.30, 0.40),  0.0, 0.10, (0.0, 0.95, 1.0), 6.0)
mat_led_blue   = make_pbr("SR_LED_Blue",  (0.0, 0.10, 0.40),  0.0, 0.10, (0.20, 0.55, 1.0), 6.0)
mat_led_red    = make_pbr("SR_LED_Red",   (0.40, 0.0, 0.0),   0.0, 0.10, (1.0, 0.10, 0.05), 6.0)
mat_led_yellow = make_pbr("SR_LED_Yellow",(0.40, 0.30, 0.0),  0.0, 0.10, (1.0, 0.85, 0.10), 5.0)
mat_led_green  = make_pbr("SR_LED_Green", (0.05, 0.30, 0.05), 0.0, 0.10, (0.20, 1.0, 0.30), 5.0)
mat_led_white  = make_pbr("SR_LED_White", (0.40, 0.40, 0.40), 0.0, 0.10, (0.95, 0.95, 1.0), 5.0)
mat_screen     = make_pbr("SR_Screen",    (0.0, 0.20, 0.30),  0.0, 0.05, (0.0, 0.85, 1.0), 4.0)
mat_holo       = make_pbr("SR_Hologram",  (0.0, 0.45, 0.55),  0.0, 0.05, (0.0, 0.95, 1.0), 8.0)
mat_steam_anchor = make_pbr("SR_SteamAnchor", (0.10, 0.40, 0.55), 0.0, 0.30, (0.0, 0.85, 1.0), 2.0)
mat_trap_electric = make_pbr("SR_TrapElec",   (0.30, 0.30, 0.0),  0.0, 0.10, (1.0, 0.95, 0.10), 5.0)


# === COLLECTIONS ===
def make_col(name):
    col = bpy.data.collections.get(name)
    if col is None:
        col = bpy.data.collections.new(name)
        bpy.context.scene.collection.children.link(col)
    return col


col_tiles = make_col("SR_Tileset")
col_props = make_col("SR_Props")
col_traps = make_col("SR_Traps")
col_rooms = make_col("SR_Rooms")


def add_to(obj, col):
    for c in obj.users_collection:
        c.objects.unlink(obj)
    col.objects.link(obj)


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


# === TILESET MODULES (Tasks 2-5, 18) ===

def cube_mesh(w, d, h):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= w * 0.5
        v.co.y *= d * 0.5
        v.co.z *= h * 0.5
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return bm


# Floor with grate (4×4×0.10)
obj = create_mesh("tile_floor_grate", cube_mesh(4.0, 4.0, 0.10), (0, 0, 0.05), mat_grate)
add_to(obj, col_tiles)
# Add grate slits — 4 thin dark stripes
for i in range(4):
    obj = create_mesh(f"tile_floor_slit_{i+1}", cube_mesh(3.5, 0.05, 0.06), (0, -1.5 + i * 1.0, 0.10), mat_dark)
    add_to(obj, col_tiles)

# Wall server (4×3×0.30) — main wall with server-rack slots
obj = create_mesh("tile_wall_server", cube_mesh(4.0, 0.30, 3.0), (5, 0, 1.5), mat_wall_metal)
add_to(obj, col_tiles)
# Add 6 server-rack slot details
for i in range(6):
    z = 0.5 + i * 0.5
    obj = create_mesh(f"tile_wall_server_slot_{i+1}", cube_mesh(3.6, 0.04, 0.40), (5, -0.17, z), mat_dark)
    add_to(obj, col_tiles)
    # LED bar on each slot
    obj = create_mesh(f"tile_wall_server_led_{i+1}", cube_mesh(3.4, 0.02, 0.04), (5, -0.18, z), mat_led_cyan)
    add_to(obj, col_tiles)

# Wall pipe (4×3×0.30) — wall with vertical pipes
obj = create_mesh("tile_wall_pipe", cube_mesh(4.0, 0.30, 3.0), (10, 0, 1.5), mat_wall_panel)
add_to(obj, col_tiles)
# 5 vertical pipes
for i in range(5):
    x = -1.6 + i * 0.8
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=0.08, radius2=0.08, depth=2.6, cap_ends=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"tile_wall_pipe_{i+1}", bm, (10 + x, -0.20, 1.5), mat_pipe)
    add_to(obj, col_tiles)

# Wall blank (4×3×0.30)
obj = create_mesh("tile_wall_blank", cube_mesh(4.0, 0.30, 3.0), (15, 0, 1.5), mat_wall_panel)
add_to(obj, col_tiles)

# Ceiling cable (4×4×0.10) with cable tray
obj = create_mesh("tile_ceiling_cable", cube_mesh(4.0, 4.0, 0.10), (0, 5, 3.05), mat_ceiling)
add_to(obj, col_tiles)
# Cable tray
obj = create_mesh("tile_ceiling_cable_tray", cube_mesh(0.40, 3.5, 0.15), (0, 5, 2.95), mat_chrome)
add_to(obj, col_tiles)
# 5 cables in the tray
for i in range(5):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=8, radius1=0.025, radius2=0.025, depth=3.4, cap_ends=True)
    rot = Matrix.Rotation(math.radians(90), 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"tile_ceiling_cable_{i+1}", bm, (-0.10 + i * 0.05, 5, 2.92), mat_dark)
    add_to(obj, col_tiles)

# Ceiling pipe (4×4×0.10) with pipe network
obj = create_mesh("tile_ceiling_pipe", cube_mesh(4.0, 4.0, 0.10), (5, 5, 3.05), mat_ceiling)
add_to(obj, col_tiles)
for i in range(3):
    x_off = -1.0 + i * 1.0
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=10, radius1=0.10, radius2=0.10, depth=3.6, cap_ends=True)
    rot = Matrix.Rotation(math.radians(90), 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"tile_ceiling_pipe_{i+1}", bm, (5 + x_off, 5, 2.85), mat_pipe)
    add_to(obj, col_tiles)

# Inside corner trim (0.30×0.30×3)
obj = create_mesh("tile_corner_inside", cube_mesh(0.30, 0.30, 3.0), (10, 5, 1.5), mat_chrome)
add_to(obj, col_tiles)

# Outside corner trim
obj = create_mesh("tile_corner_outside", cube_mesh(0.30, 0.30, 3.0), (12, 5, 1.5), mat_chrome)
add_to(obj, col_tiles)

# T junction (4×4×3) — represented as a parent with 3 wall sections
parent = bpy.data.objects.new("tile_t_junction", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_tiles)
for i, (x, y, rot_z) in enumerate([(15, 5, 0), (15, 4, 90), (15, 6, 90)]):
    obj = create_mesh(f"tile_t_junction_arm_{i+1}", cube_mesh(2.0, 0.30, 3.0), (x, y, 1.5), mat_wall_panel)
    obj.rotation_euler = (0, 0, math.radians(rot_z))
    obj.parent = parent
    add_to(obj, col_tiles)

# X junction
parent = bpy.data.objects.new("tile_x_junction", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_tiles)
for i, rot_z in enumerate([0, 90, 180, 270]):
    obj = create_mesh(f"tile_x_junction_arm_{i+1}", cube_mesh(2.0, 0.30, 3.0), (20, 5, 1.5), mat_wall_panel)
    obj.rotation_euler = (0, 0, math.radians(rot_z))
    obj.parent = parent
    add_to(obj, col_tiles)

# End cap (4×4×3) — wall with door slot
parent = bpy.data.objects.new("tile_end_cap", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_tiles)
obj = create_mesh("tile_end_cap_wall", cube_mesh(4.0, 0.30, 3.0), (25, 5, 1.5), mat_wall_panel)
obj.parent = parent
add_to(obj, col_tiles)
# Door slot dark cube
obj = create_mesh("tile_end_cap_door_slot", cube_mesh(1.0, 0.05, 2.0), (25, 4.85, 1.0), mat_dark)
obj.parent = parent
add_to(obj, col_tiles)

# Door (2.0×2.5×0.10)
obj = create_mesh("tile_door", cube_mesh(2.0, 0.10, 2.5), (28, 5, 1.25), mat_chrome)
add_to(obj, col_tiles)
# Door cyan accent stripe
obj = create_mesh("tile_door_accent", cube_mesh(1.6, 0.06, 0.06), (28, 5, 2.20), mat_led_cyan)
add_to(obj, col_tiles)


# ===========================================================
# === HERO PROPS (Tasks 6, 11-17) ===
# ===========================================================

# 6 server rack hero variants — each with different LED color
LED_MATS = [mat_led_cyan, mat_led_blue, mat_led_red, mat_led_yellow, mat_led_green, mat_led_white]
for i, led_mat in enumerate(LED_MATS):
    parent = bpy.data.objects.new(f"prop_server_rack_{i+1}", None)
    bpy.context.scene.collection.objects.link(parent)
    add_to(parent, col_props)
    # Body — tall cabinet
    obj = create_mesh(f"server_rack_{i+1}_body", cube_mesh(0.80, 0.50, 2.20), (0, -10 + i * 1.5, 1.10), mat_dark)
    obj.parent = parent
    add_to(obj, col_props)
    # 8 LED slots on the front
    for j in range(8):
        z = 0.30 + j * 0.22
        obj = create_mesh(f"server_rack_{i+1}_slot_{j+1}", cube_mesh(0.65, 0.04, 0.10), (0, -10 + i * 1.5 - 0.27, z), mat_screen)
        obj.parent = parent
        add_to(obj, col_props)
        # LED bar
        obj = create_mesh(f"server_rack_{i+1}_led_{j+1}", cube_mesh(0.55, 0.02, 0.03), (0, -10 + i * 1.5 - 0.28, z), led_mat)
        obj.parent = parent
        add_to(obj, col_props)

# 6 terminal/console variants
for i in range(6):
    parent = bpy.data.objects.new(f"prop_terminal_{i+1}", None)
    bpy.context.scene.collection.objects.link(parent)
    add_to(parent, col_props)
    # Stand
    obj = create_mesh(f"terminal_{i+1}_stand", cube_mesh(0.40, 0.40, 1.0), (10 + i * 1.5, -10, 0.50), mat_dark)
    obj.parent = parent
    add_to(obj, col_props)
    # Screen — angled
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 0.40
        v.co.y *= 0.04
        v.co.z *= 0.30
    # Tilt 20 degrees
    rot = Matrix.Rotation(math.radians(-20), 4, 'X')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"terminal_{i+1}_screen", bm, (10 + i * 1.5, -10, 1.10), mat_screen)
    obj.parent = parent
    add_to(obj, col_props)
    # Keyboard tray
    obj = create_mesh(f"terminal_{i+1}_keys", cube_mesh(0.40, 0.20, 0.04), (10 + i * 1.5, -9.85, 0.95), mat_chrome)
    obj.parent = parent
    add_to(obj, col_props)

# Holographic display (Task 15)
parent = bpy.data.objects.new("prop_holo_display", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
# Base
obj = create_mesh("holo_base", cube_mesh(0.60, 0.60, 0.20), (20, -10, 0.10), mat_chrome)
obj.parent = parent
add_to(obj, col_props)
# Floating cyan hologram (sphere + ring)
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=18, v_segments=12, radius=0.30)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("holo_sphere", bm, (20, -10, 0.95), mat_holo)
obj.parent = parent
add_to(obj, col_props)
# Ring around it
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=24, radius1=0.45, radius2=0.45, depth=0.04, cap_ends=False)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("holo_ring", bm, (20, -10, 0.95), mat_holo)
obj.parent = parent
add_to(obj, col_props)

# Cooling fan (Task 13)
parent = bpy.data.objects.new("prop_cooling_fan", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
# Frame
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
for v in bm.verts:
    v.co.x *= 0.45
    v.co.y *= 0.10
    v.co.z *= 0.45
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("fan_frame", bm, (22, -10, 1.5), mat_chrome)
obj.parent = parent
add_to(obj, col_props)
# 4 fan blades — flat boxes rotated
for i in range(4):
    angle = i * (math.tau / 4)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= 0.30
        v.co.y *= 0.02
        v.co.z *= 0.05
    rot = Matrix.Rotation(angle, 4, 'Y')
    for v in bm.verts:
        v.co = rot @ v.co
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    obj = create_mesh(f"fan_blade_{i+1}", bm, (22, -10.05, 1.5), mat_dark)
    obj.parent = parent
    add_to(obj, col_props)

# Floor grate dropdown (Task 11)
obj = create_mesh("prop_grate_dropdown", cube_mesh(1.5, 1.5, 0.05), (24, -10, 0.025), mat_grate)
add_to(obj, col_props)

# Cable bundle variants ×3 (Task 12)
for i in range(3):
    parent = bpy.data.objects.new(f"prop_cable_bundle_{i+1}", None)
    bpy.context.scene.collection.objects.link(parent)
    add_to(parent, col_props)
    for j in range(4):
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=8, radius1=0.025, radius2=0.025, depth=0.80, cap_ends=True)
        rot = Matrix.Rotation(math.radians(90), 4, 'X')
        for v in bm.verts:
            v.co = rot @ v.co
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        offset_x = (j % 2) * 0.06
        offset_z = (j // 2) * 0.06
        obj = create_mesh(f"cable_bundle_{i+1}_{j+1}", bm, (26 + i * 1.0 + offset_x, -10, 1.5 + offset_z), mat_dark)
        obj.parent = parent
        add_to(obj, col_props)

# Power conduit (Task 16)
parent = bpy.data.objects.new("prop_power_conduit", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=10, radius1=0.18, radius2=0.18, depth=2.0, cap_ends=True)
rot = Matrix.Rotation(math.radians(90), 4, 'X')
for v in bm.verts:
    v.co = rot @ v.co
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("power_conduit_pipe", bm, (30, -10, 1.5), mat_pipe)
obj.parent = parent
add_to(obj, col_props)
# Glowing accent stripe along the conduit
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
for v in bm.verts:
    v.co.x *= 0.05
    v.co.y *= 1.0
    v.co.z *= 0.05
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("power_conduit_accent", bm, (30, -10, 1.65), mat_led_cyan)
obj.parent = parent
add_to(obj, col_props)

# Hazard pipe burst (Task 17) — broken pipe with steam vent anchor
parent = bpy.data.objects.new("prop_hazard_pipe_burst", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_props)
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=10, radius1=0.18, radius2=0.18, depth=1.0, cap_ends=True)
rot = Matrix.Rotation(math.radians(90), 4, 'X')
for v in bm.verts:
    v.co = rot @ v.co
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("hazard_pipe_burst_body", bm, (32, -10, 1.5), mat_pipe)
obj.parent = parent
add_to(obj, col_props)
# Burst hole / steam vent anchor
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=8, radius=0.10)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
obj = create_mesh("hazard_pipe_burst_anchor", bm, (32, -10, 1.65), mat_steam_anchor)
obj.parent = parent
add_to(obj, col_props)

# Steam vent anchor (Task 9)
obj = create_mesh("prop_steam_vent_anchor", cube_mesh(0.30, 0.30, 0.05), (34, -10, 0.025), mat_steam_anchor)
add_to(obj, col_props)


# ===========================================================
# === TRAPS (Task 21) ===
# ===========================================================

# Electric floor
parent = bpy.data.objects.new("trap_electric_floor", None)
bpy.context.scene.collection.objects.link(parent)
add_to(parent, col_traps)
obj = create_mesh("trap_elec_base", cube_mesh(2.0, 2.0, 0.04), (0, -15, 0.02), mat_dark)
obj.parent = parent
add_to(obj, col_traps)
# 9 LED nodes in a 3x3 grid
for i in range(3):
    for j in range(3):
        x = -0.6 + i * 0.6
        y = -0.6 + j * 0.6
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=8, v_segments=6, radius=0.06)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        obj = create_mesh(f"trap_elec_node_{i}_{j}", bm, (x, -15 + y, 0.06), mat_trap_electric)
        obj.parent = parent
        add_to(obj, col_traps)

# Falling tile trap
obj = create_mesh("trap_falling_tile", cube_mesh(2.0, 2.0, 0.10), (3, -15, 0.05), mat_grate)
add_to(obj, col_traps)


# ===========================================================
# === ROOM LAYOUTS (Task 47) — 8 prebuilt rooms ===
# ===========================================================

def make_room_floor(name, size_x, size_y, location):
    obj = create_mesh(f"{name}_floor", cube_mesh(size_x, size_y, 0.10), location, mat_grate)
    add_to(obj, col_rooms)
    return obj


def make_room_walls(parent_loc, size_x, size_y, name):
    """Walls around a rectangular room."""
    walls = []
    # Front + back
    for sy in (-1, 1):
        obj = create_mesh(f"{name}_wall_y{sy}", cube_mesh(size_x, 0.30, 3.0),
                          (parent_loc[0], parent_loc[1] + sy * size_y * 0.5, 1.55), mat_wall_metal)
        add_to(obj, col_rooms)
        walls.append(obj)
    # Left + right
    for sx in (-1, 1):
        obj = create_mesh(f"{name}_wall_x{sx}", cube_mesh(0.30, size_y, 3.0),
                          (parent_loc[0] + sx * size_x * 0.5, parent_loc[1], 1.55), mat_wall_metal)
        add_to(obj, col_rooms)
        walls.append(obj)
    return walls


# 8 rooms in a row, each at offset (0, -25 - i * 20, 0)
rooms = [
    ("room_corridor", 4, 16),
    ("room_junction_t", 8, 8),
    ("room_dead_end", 4, 4),
    ("room_loot", 8, 8),
    ("room_elite", 12, 8),
    ("room_boss_entry", 8, 16),
    ("room_secret", 4, 4),
    ("room_vent_route", 2, 8),
]
for i, (name, sx, sy) in enumerate(rooms):
    loc = (0, -25 - i * 20, 0)
    make_room_floor(name, sx, sy, loc)
    make_room_walls(loc, sx, sy, name)


# === SAVE ===
bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
total = len([o for o in bpy.context.scene.objects if o.type == 'MESH'])
print(f"\nServer Room biome complete. Total mesh objects: {total}")
print(f"Saved: {OUT_BLEND}")
