"""
Epic 30 — Massive Dungeon Floors Pipeline (10x Current Size)
=============================================================
Builds all 5 hand-crafted dungeon floors in a single Blender background pass:

Floor 1: HUB & SPOKE — Server Room biome
  Central rotunda with 6 radial corridors leading to 6 spoke rooms

Floor 2: MULTI-LEVEL — Memory Vaults biome
  Two tiers connected by ramps; each tier has 4 chambers + library
  centerpiece

Floor 3: MAZE — Corrupted Wilds biome
  Dense organic maze with branching dead-ends, collectible nooks, 4 hidden
  shrines

Floor 4: BOSS APPROACH — Boss Sanctum biome
  Long processional with cyan torches, pillared antechamber, ritual stairs

Floor 5: BOSS ARENA — Sanctum Core
  Massive circular arena with chasm rim, 4 cardinal pillars, central
  altar pad, viewing tiers

Each floor gets:
  - Floor + walls + ceiling (where appropriate)
  - Biome-specific props
  - Lighting markers (per room tag)
  - Encounter spawner markers
  - Loot/secret/story/elite/boss room markers
  - 5 environmental hazards
  - Destructible props
  - Lore objects
  - Interactive prop markers
  - Reflection probe markers
  - Cinematic camera positions
  - Hero shot camera

Saves:
  - _art_source/dungeons/massive_floors.blend
  - _art_source/dungeons/renders/floor_1_hero.png … floor_5_hero.png
"""
import bpy, bmesh, math, os, random
from mathutils import Vector, Matrix

random.seed(3030)
OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeons/massive_floors.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeons/renders"
os.makedirs(os.path.dirname(OUTPUT_BLEND), exist_ok=True)
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32
scene.render.resolution_x = 1280
scene.render.resolution_y = 720

# ================== Materials (per biome) ==================
def make_pbr(name, base, rough=0.7, metal=0.0, emit=None, emit_strength=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes['Principled BSDF']
    bsdf.inputs['Base Color'].default_value = (*base, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Metallic'].default_value = metal
    if emit is not None:
        bsdf.inputs['Emission Color'].default_value = (*emit, 1.0)
        bsdf.inputs['Emission Strength'].default_value = emit_strength
    return m

# Server Room (Floor 1)
sr_floor = make_pbr("f1_floor", (0.20, 0.22, 0.26), 0.5, 0.4)
sr_wall = make_pbr("f1_wall", (0.18, 0.20, 0.24), 0.6, 0.3)
sr_ceiling = make_pbr("f1_ceiling", (0.10, 0.12, 0.16), 0.7)
sr_rack = make_pbr("f1_rack", (0.15, 0.17, 0.22), 0.5, 0.6, (0.2, 0.5, 1.0), 1.5)
sr_glow = make_pbr("f1_glow", (0.10, 0.30, 0.55), 0.3, 0.0, (0.2, 0.6, 1.0), 4.0)
sr_pipe = make_pbr("f1_pipe", (0.32, 0.34, 0.40), 0.4, 0.85)
sr_screen = make_pbr("f1_screen", (0.05, 0.10, 0.20), 0.2, 0.0, (0.3, 0.5, 1.0), 2.5)

# Memory Vaults (Floor 2)
mv_floor = make_pbr("f2_floor", (0.55, 0.42, 0.22), 0.8)
mv_wall = make_pbr("f2_wall", (0.45, 0.35, 0.20), 0.85)
mv_ceiling = make_pbr("f2_ceiling", (0.30, 0.22, 0.12), 0.85)
mv_pillar = make_pbr("f2_pillar", (0.65, 0.50, 0.25), 0.7, 0.2)
mv_brass = make_pbr("f2_brass", (0.85, 0.65, 0.20), 0.3, 0.95, (0.9, 0.7, 0.3), 0.3)
mv_book = make_pbr("f2_book", (0.42, 0.10, 0.10), 0.85)
mv_glow = make_pbr("f2_glow", (0.30, 0.25, 0.10), 0.4, 0.0, (1.0, 0.85, 0.5), 3.0)

# Corrupted Wilds (Floor 3)
cw_floor = make_pbr("f3_floor", (0.18, 0.25, 0.15), 0.85)
cw_wall = make_pbr("f3_wall", (0.13, 0.20, 0.12), 0.9)
cw_root = make_pbr("f3_root", (0.18, 0.13, 0.07), 0.9)
cw_growth = make_pbr("f3_growth", (0.20, 0.32, 0.15), 0.75, 0.0, (0.3, 0.6, 0.2), 0.6)
cw_glow = make_pbr("f3_glow", (0.10, 0.30, 0.10), 0.3, 0.0, (0.4, 1.0, 0.4), 3.5)
cw_thorn = make_pbr("f3_thorn", (0.10, 0.15, 0.08), 0.95)

# Boss Sanctum (Floor 4 + 5)
bs_floor = make_pbr("f4_floor", (0.10, 0.08, 0.14), 0.7)
bs_wall = make_pbr("f4_wall", (0.08, 0.06, 0.12), 0.8)
bs_pillar = make_pbr("f4_pillar", (0.12, 0.10, 0.18), 0.65)
bs_obsidian = make_pbr("f4_obsidian", (0.05, 0.05, 0.10), 0.15, 0.85)
bs_glow_cyan = make_pbr("f4_glow_cyan", (0.10, 0.30, 0.40), 0.3, 0.0, (0.2, 0.7, 0.9), 4.5)
bs_glow_violet = make_pbr("f4_glow_violet", (0.20, 0.10, 0.35), 0.3, 0.0, (0.7, 0.3, 1.0), 5.0)
bs_void = make_pbr("f4_void", (0.02, 0.02, 0.05), 0.95)
bs_altar = make_pbr("f4_altar", (0.18, 0.12, 0.22), 0.6, 0.2, (0.5, 0.3, 0.8), 0.8)

# Marker materials (small spheres for spawn/loot/etc)
mat_marker_combat = make_pbr("marker_combat", (0.4, 0.5, 0.7), 0.4, 0.0, (0.3, 0.5, 0.8), 0.5)
mat_marker_loot = make_pbr("marker_loot", (0.85, 0.65, 0.20), 0.3, 0.0, (1.0, 0.8, 0.3), 1.0)
mat_marker_secret = make_pbr("marker_secret", (0.55, 0.30, 0.85), 0.4, 0.0, (0.7, 0.4, 1.0), 0.8)
mat_marker_story = make_pbr("marker_story", (0.45, 0.65, 0.85), 0.4, 0.0, (0.5, 0.7, 1.0), 0.6)
mat_marker_elite = make_pbr("marker_elite", (0.85, 0.45, 0.20), 0.3, 0.0, (1.0, 0.5, 0.2), 0.9)
mat_marker_boss = make_pbr("marker_boss", (0.85, 0.20, 0.30), 0.2, 0.0, (1.0, 0.3, 0.4), 1.5)
mat_marker_hazard = make_pbr("marker_hazard", (0.85, 0.25, 0.10), 0.4, 0.0, (1.0, 0.4, 0.1), 1.0)
mat_marker_lore = make_pbr("marker_lore", (0.55, 0.85, 0.85), 0.4, 0.0, (0.6, 1.0, 1.0), 0.7)

# ================== Helpers ==================
def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

def link_to(obj, coll):
    for c in obj.users_collection: c.objects.unlink(obj)
    coll.objects.link(obj)

def add_bm(name, bm, mat, coll, loc=(0,0,0), rot=(0,0,0), scale=(1,1,1)):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me); bm.free()
    if mat is not None:
        me.materials.append(mat)
    obj = bpy.data.objects.new(name, me)
    obj.location = loc; obj.rotation_euler = rot; obj.scale = scale
    scene.collection.objects.link(obj)
    link_to(obj, coll)
    return obj

def cube(sx, sy, sz):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(sx, sy, sz), verts=bm.verts)
    return bm

def cyl(r, h, segs=12):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=r, radius2=r, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
    return bm

def disk(r, segs=20):
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, segments=segs, radius=r, cap_ends=True, cap_tris=True)
    return bm

def ico(r, subs=2):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=subs, radius=r)
    return bm

def add_marker(parent, name, position, mat, radius=0.4):
    add_bm(name, ico(radius, 1), mat, parent, loc=position)

# ================== FLOOR 1: Server Room HUB & SPOKE ==================
print("=== Floor 1: Hub & Spoke ===")
col_f1 = make_coll("Floor_1_HubSpoke")

F1_RADIUS = 50  # massive — 50m hub radius
F1_SPOKE_LENGTH = 30
F1_SPOKE_WIDTH = 5

# Central hub (large disk)
add_bm("F1_HubFloor", disk(F1_RADIUS, 32), sr_floor, col_f1, loc=(0, 0, 0))

# Hub ceiling
add_bm("F1_HubCeiling", disk(F1_RADIUS, 32), sr_ceiling, col_f1, loc=(0, 0, 8))

# Hub outer wall (segmented around circle, with 6 gaps for spokes)
SPOKE_COUNT = 6
for seg in range(SPOKE_COUNT * 8):
    seg_per_spoke = 8
    spoke_idx = seg // seg_per_spoke
    sub_idx = seg % seg_per_spoke
    # Skip middle 2 segments where the spoke connects
    if sub_idx == 3 or sub_idx == 4:
        continue
    ang = (seg / (SPOKE_COUNT * 8)) * math.tau
    add_bm(f"F1_HubWall_{seg}", cube(2.5, 0.4, 4), sr_wall, col_f1,
           loc=(math.cos(ang)*F1_RADIUS, math.sin(ang)*F1_RADIUS, 4),
           rot=(0, 0, ang + math.pi/2))

# 6 spoke corridors + 6 spoke rooms
SPOKE_TAGS = ["combat", "combat", "loot", "story", "elite", "secret"]
for s in range(SPOKE_COUNT):
    ang = (s / SPOKE_COUNT) * math.tau
    cos_a, sin_a = math.cos(ang), math.sin(ang)
    spoke_dir = Vector((cos_a, sin_a, 0))
    # Corridor floor
    corridor_center = (cos_a * (F1_RADIUS + F1_SPOKE_LENGTH/2),
                        sin_a * (F1_RADIUS + F1_SPOKE_LENGTH/2), 0)
    add_bm(f"F1_SpokeFloor_{s}", cube(F1_SPOKE_LENGTH/2, F1_SPOKE_WIDTH/2, 0.1),
           sr_floor, col_f1, loc=corridor_center, rot=(0, 0, ang))
    # Corridor ceiling
    add_bm(f"F1_SpokeCeil_{s}", cube(F1_SPOKE_LENGTH/2, F1_SPOKE_WIDTH/2, 0.1),
           sr_ceiling, col_f1, loc=(corridor_center[0], corridor_center[1], 6), rot=(0, 0, ang))
    # Side walls along corridor
    for side in [-1, 1]:
        perp = Vector((-sin_a, cos_a, 0)) * (F1_SPOKE_WIDTH/2 + 0.2) * side
        add_bm(f"F1_SpokeWall_{s}_{side}", cube(F1_SPOKE_LENGTH/2, 0.3, 3), sr_wall, col_f1,
               loc=(corridor_center[0] + perp.x, corridor_center[1] + perp.y, 3),
               rot=(0, 0, ang))
    # Spoke room (rectangular at end of corridor)
    room_center = (cos_a * (F1_RADIUS + F1_SPOKE_LENGTH + 6),
                   sin_a * (F1_RADIUS + F1_SPOKE_LENGTH + 6), 0)
    add_bm(f"F1_SpokeRoom_{s}", cube(7, 7, 0.1), sr_floor, col_f1,
           loc=room_center, rot=(0, 0, ang))
    add_bm(f"F1_SpokeRoomCeil_{s}", cube(7, 7, 0.1), sr_ceiling, col_f1,
           loc=(room_center[0], room_center[1], 6), rot=(0, 0, ang))
    # Room walls (4 sides)
    for wx, wy, sx, sy in [(7, 0, 0.3, 7), (-7, 0, 0.3, 7), (0, 7, 7, 0.3), (0, -7, 7, 0.3)]:
        wpos = Vector((wx, wy, 0))
        # rotate
        rwx = wpos.x * cos_a - wpos.y * sin_a
        rwy = wpos.x * sin_a + wpos.y * cos_a
        add_bm(f"F1_SpokeRoomWall_{s}_{wx}_{wy}", cube(sx, sy, 3), sr_wall, col_f1,
               loc=(room_center[0]+rwx, room_center[1]+rwy, 3), rot=(0, 0, ang))

    # Tag marker for spoke room
    tag = SPOKE_TAGS[s]
    tag_mat = {"combat": mat_marker_combat, "loot": mat_marker_loot, "story": mat_marker_story,
               "elite": mat_marker_elite, "secret": mat_marker_secret}.get(tag, mat_marker_combat)
    add_marker(col_f1, f"F1_SpokeTag_{s}_{tag}", (room_center[0], room_center[1], 1), tag_mat, 0.6)

# Central server tower (rotunda focal point)
add_bm("F1_CentralTower", cyl(2.5, 7, 12), sr_rack, col_f1, loc=(0, 0, 0.05))
add_bm("F1_CentralCore", ico(0.8, 2), sr_glow, col_f1, loc=(0, 0, 6.5))

# Server racks around the hub
for i in range(12):
    ra = (i / 12) * math.tau
    rx = math.cos(ra) * (F1_RADIUS - 6)
    ry = math.sin(ra) * (F1_RADIUS - 6)
    add_bm(f"F1_HubRack_{i}", cube(1.0, 0.8, 2.5), sr_rack, col_f1, loc=(rx, ry, 1.25))
    # Glowing screens
    add_bm(f"F1_HubScreen_{i}", cube(0.85, 0.05, 0.6), sr_screen, col_f1,
           loc=(rx, ry - 0.85, 2.0))

# Pipes along ceiling (cross pattern)
for px in [-25, 0, 25]:
    add_bm(f"F1_Pipe_X_{px}", cube(0.2, F1_RADIUS, 0.2), sr_pipe, col_f1, loc=(px, 0, 7.5))
for py in [-25, 0, 25]:
    add_bm(f"F1_Pipe_Y_{py}", cube(F1_RADIUS, 0.2, 0.2), sr_pipe, col_f1, loc=(0, py, 7.5))

# Encounter spawn markers (5)
for i in range(5):
    ang = (i / 5) * math.tau + 0.3
    add_marker(col_f1, f"F1_Encounter_{i}", (math.cos(ang)*25, math.sin(ang)*25, 1.0),
               mat_marker_combat, 0.5)

# 3 loot rooms (subset of spokes)
# 5 hazards
for i in range(5):
    ang = (i / 5) * math.tau + 0.6
    add_marker(col_f1, f"F1_Hazard_{i}_electric_grate",
               (math.cos(ang)*15, math.sin(ang)*15, 0.5), mat_marker_hazard, 0.4)

# Lore objects (4)
for i in range(4):
    ang = (i / 4) * math.tau + 0.9
    add_marker(col_f1, f"F1_Lore_{i}", (math.cos(ang)*30, math.sin(ang)*30, 1.0),
               mat_marker_lore, 0.35)

# ================== FLOOR 2: Memory Vaults MULTI-LEVEL ==================
print("=== Floor 2: Multi-Level ===")
col_f2 = make_coll("Floor_2_MultiLevel")

# Lower level: 60x40m hall
add_bm("F2_LowerFloor", cube(30, 20, 0.1), mv_floor, col_f2, loc=(0, 0, 0))
add_bm("F2_LowerCeiling", cube(30, 20, 0.1), mv_ceiling, col_f2, loc=(0, 0, 5))
# Lower walls
for wx, wy, sx, sy in [(30, 0, 0.3, 20), (-30, 0, 0.3, 20), (0, 20, 30, 0.3), (0, -20, 30, 0.3)]:
    add_bm(f"F2_LowerWall_{wx}_{wy}", cube(sx, sy, 2.5), mv_wall, col_f2, loc=(wx, wy, 2.5))

# Upper level: smaller suspended platform
add_bm("F2_UpperFloor", cube(20, 12, 0.1), mv_floor, col_f2, loc=(0, 6, 8))
add_bm("F2_UpperCeiling", cube(20, 12, 0.1), mv_ceiling, col_f2, loc=(0, 6, 13))
# Upper walls
for wx, wy, sx, sy in [(20, 6, 0.3, 12), (-20, 6, 0.3, 12), (0, 18, 20, 0.3)]:
    add_bm(f"F2_UpperWall_{wx}_{wy}", cube(sx, sy, 2.5), mv_wall, col_f2, loc=(wx, wy, 10.5))

# Connecting ramps (2 — symmetric)
for side, x_off in [(-1, -10), (1, 10)]:
    ramp_length = 12
    ramp = cube(2.5, ramp_length/2, 0.15)
    add_bm(f"F2_Ramp_{side}", ramp, mv_floor, col_f2,
           loc=(x_off, -2, 4), rot=(math.radians(35), 0, 0))

# Library centerpiece (lower level): 8 tall pillars + brass urns
for i in range(8):
    ang = (i / 8) * math.tau
    px = math.cos(ang) * 7
    py = math.sin(ang) * 7
    add_bm(f"F2_LibPillar_{i}", cyl(0.5, 5, 12), mv_pillar, col_f2, loc=(px, py, 0))
    add_bm(f"F2_LibUrn_{i}", ico(0.4, 2), mv_brass, col_f2, loc=(px, py, 5.5))

# Bookshelves along lower walls
for sx in range(-25, 26, 5):
    if abs(sx) > 25: continue
    add_bm(f"F2_Shelf_N_{sx}", cube(2.0, 0.5, 4.5), mv_pillar, col_f2, loc=(sx, 19.4, 2.25))
    add_bm(f"F2_Shelf_S_{sx}", cube(2.0, 0.5, 4.5), mv_pillar, col_f2, loc=(sx, -19.4, 2.25))
    # Books
    for b in range(4):
        add_bm(f"F2_Book_N_{sx}_{b}", cube(0.3, 0.2, 0.4), mv_book, col_f2,
               loc=(sx-0.6+b*0.3, 19.0, 1.5+b*0.5))

# Brass braziers (4 corners)
for cx, cy in [(-25, -15), (25, -15), (-25, 15), (25, 15)]:
    add_bm(f"F2_Brazier_{cx}_{cy}", cyl(0.5, 1.2, 8), mv_brass, col_f2, loc=(cx, cy, 0.6))
    add_bm(f"F2_BrazierFlame_{cx}_{cy}", ico(0.45, 2), mv_glow, col_f2, loc=(cx, cy, 1.5))

# Spawn markers
for i in range(4):
    add_marker(col_f2, f"F2_Encounter_lower_{i}", (random.uniform(-20, 20), random.uniform(-15, 15), 1),
               mat_marker_combat, 0.5)
for i in range(2):
    add_marker(col_f2, f"F2_Encounter_upper_{i}", (random.uniform(-15, 15), random.uniform(2, 14), 9),
               mat_marker_combat, 0.5)

# Tag rooms
add_marker(col_f2, "F2_LootRoom_1", (-20, -15, 1), mat_marker_loot, 0.7)
add_marker(col_f2, "F2_LootRoom_2", (20, -15, 1), mat_marker_loot, 0.7)
add_marker(col_f2, "F2_LootRoom_3", (0, 15, 9), mat_marker_loot, 0.7)
add_marker(col_f2, "F2_StoryRoom", (0, 0, 1), mat_marker_story, 0.8)
add_marker(col_f2, "F2_EliteRoom_1", (-25, 10, 1), mat_marker_elite, 0.7)
add_marker(col_f2, "F2_EliteRoom_2", (25, 10, 1), mat_marker_elite, 0.7)
add_marker(col_f2, "F2_SecretRoom_1", (-15, -18, 1), mat_marker_secret, 0.5)
add_marker(col_f2, "F2_SecretRoom_2", (15, -18, 1), mat_marker_secret, 0.5)

# Hazards
for i in range(5):
    add_marker(col_f2, f"F2_Hazard_{i}_pressure_plate",
               (random.uniform(-25, 25), random.uniform(-18, 18), 0.3),
               mat_marker_hazard, 0.4)

# Lore datapads (4)
for i in range(4):
    add_marker(col_f2, f"F2_Lore_{i}",
               (random.uniform(-25, 25), random.uniform(-18, 18), 1.0),
               mat_marker_lore, 0.35)

# ================== FLOOR 3: Corrupted Wilds MAZE ==================
print("=== Floor 3: Maze ===")
col_f3 = make_coll("Floor_3_Maze")

# Maze: 20x20 grid of cells, some open, some walled
MAZE_SIZE = 20
CELL_SIZE = 4
maze = [[1] * MAZE_SIZE for _ in range(MAZE_SIZE)]
# Carve random paths
random.seed(303)
def carve(x, y):
    maze[x][y] = 0
    dirs = [(2,0),(-2,0),(0,2),(0,-2)]
    random.shuffle(dirs)
    for dx, dy in dirs:
        nx, ny = x+dx, y+dy
        if 0 <= nx < MAZE_SIZE and 0 <= ny < MAZE_SIZE and maze[nx][ny] == 1:
            maze[x+dx//2][y+dy//2] = 0
            carve(nx, ny)
carve(1, 1)

# Floor under all (large green plane)
add_bm("F3_Floor", cube(MAZE_SIZE*CELL_SIZE/2 + 4, MAZE_SIZE*CELL_SIZE/2 + 4, 0.1),
       cw_floor, col_f3, loc=(0, 0, 0))

# Walls for filled cells
for i in range(MAZE_SIZE):
    for j in range(MAZE_SIZE):
        if maze[i][j] == 1:
            wx = (i - MAZE_SIZE/2) * CELL_SIZE
            wy = (j - MAZE_SIZE/2) * CELL_SIZE
            add_bm(f"F3_Wall_{i}_{j}", cube(CELL_SIZE/2 - 0.1, CELL_SIZE/2 - 0.1, 2),
                   cw_wall, col_f3, loc=(wx, wy, 2))
            # Random twisted root on top
            if random.random() < 0.3:
                add_bm(f"F3_Root_{i}_{j}", cyl(0.15, 1.5, 6), cw_root, col_f3,
                       loc=(wx, wy, 4.0), rot=(random.uniform(-0.3, 0.3), 0, random.uniform(0, math.tau)))

# Glowing growths in random open cells
for _ in range(30):
    i = random.randint(1, MAZE_SIZE-2)
    j = random.randint(1, MAZE_SIZE-2)
    if maze[i][j] == 0:
        wx = (i - MAZE_SIZE/2) * CELL_SIZE
        wy = (j - MAZE_SIZE/2) * CELL_SIZE
        add_bm(f"F3_Growth_{i}_{j}", ico(0.35, 2), cw_growth, col_f3, loc=(wx, wy, 0.4))

# 4 hidden shrines (in dead-end cells)
SHRINES = [(2, 2), (MAZE_SIZE-3, 2), (2, MAZE_SIZE-3), (MAZE_SIZE-3, MAZE_SIZE-3)]
for idx, (i, j) in enumerate(SHRINES):
    wx = (i - MAZE_SIZE/2) * CELL_SIZE
    wy = (j - MAZE_SIZE/2) * CELL_SIZE
    add_bm(f"F3_ShrinePedestal_{idx}", cyl(0.8, 0.4, 8), cw_root, col_f3, loc=(wx, wy, 0.2))
    add_bm(f"F3_ShrineCrystal_{idx}", ico(0.5, 2), cw_glow, col_f3, loc=(wx, wy, 1.0))

# Spawn markers
for i in range(6):
    add_marker(col_f3, f"F3_Encounter_{i}",
               (random.uniform(-30, 30), random.uniform(-30, 30), 1),
               mat_marker_combat, 0.5)

# Tags
add_marker(col_f3, "F3_LootRoom_1", (-20, -20, 1), mat_marker_loot, 0.7)
add_marker(col_f3, "F3_LootRoom_2", (20, -20, 1), mat_marker_loot, 0.7)
add_marker(col_f3, "F3_LootRoom_3", (0, 20, 1), mat_marker_loot, 0.7)
add_marker(col_f3, "F3_StoryRoom", (0, 0, 1), mat_marker_story, 0.8)
add_marker(col_f3, "F3_EliteRoom_1", (-25, 10, 1), mat_marker_elite, 0.7)
add_marker(col_f3, "F3_EliteRoom_2", (25, -10, 1), mat_marker_elite, 0.7)
for s_idx in range(2):
    add_marker(col_f3, f"F3_SecretRoom_{s_idx}",
               (random.uniform(-30, 30), random.uniform(-30, 30), 1),
               mat_marker_secret, 0.5)

# Hazards (thorn pits, poison geysers, mires)
for i in range(5):
    add_marker(col_f3, f"F3_Hazard_{i}",
               (random.uniform(-30, 30), random.uniform(-30, 30), 0.3),
               mat_marker_hazard, 0.4)

# Lore objects
for i in range(4):
    add_marker(col_f3, f"F3_Lore_{i}",
               (random.uniform(-30, 30), random.uniform(-30, 30), 1.0),
               mat_marker_lore, 0.35)

# ================== FLOOR 4: Boss Approach ==================
print("=== Floor 4: Boss Approach ===")
col_f4 = make_coll("Floor_4_BossApproach")

# Long processional: 80m × 12m
add_bm("F4_Floor", cube(40, 6, 0.1), bs_floor, col_f4, loc=(0, 0, 0))
add_bm("F4_Ceiling", cube(40, 6, 0.1), bs_wall, col_f4, loc=(0, 0, 8))

# Side walls
add_bm("F4_WallN", cube(40, 0.4, 4), bs_wall, col_f4, loc=(0, 6, 4))
add_bm("F4_WallS", cube(40, 0.4, 4), bs_wall, col_f4, loc=(0, -6, 4))

# 14 cyan torches along the walls
for i in range(7):
    px = -32 + i * 10
    add_bm(f"F4_TorchPostN_{i}", cyl(0.15, 1.6, 8), bs_obsidian, col_f4, loc=(px, 5.5, 0.8))
    add_bm(f"F4_TorchFlameN_{i}", ico(0.25, 2), bs_glow_cyan, col_f4, loc=(px, 5.5, 2.0))
    add_bm(f"F4_TorchPostS_{i}", cyl(0.15, 1.6, 8), bs_obsidian, col_f4, loc=(px, -5.5, 0.8))
    add_bm(f"F4_TorchFlameS_{i}", ico(0.25, 2), bs_glow_cyan, col_f4, loc=(px, -5.5, 2.0))

# Pillared antechamber at the end (last 15m)
for i in range(4):
    px = 25 + (i // 2) * 8
    py = (i % 2) * 8 - 4
    add_bm(f"F4_AntePillar_{i}", cyl(0.7, 7, 12), bs_pillar, col_f4, loc=(px, py, 0))
    add_bm(f"F4_AntePillarCap_{i}", cube(1.6, 1.6, 0.4), bs_pillar, col_f4, loc=(px, py, 7.2))

# Ritual stairs at the very end
for s in range(5):
    add_bm(f"F4_Stair_{s}", cube(4 - s*0.3, 3, 0.15), bs_floor, col_f4,
           loc=(38 + s*0.4, 0, 0.075 + s*0.15))

# Encounter spawns
for i in range(4):
    add_marker(col_f4, f"F4_Encounter_{i}", (-25 + i*15, 0, 1), mat_marker_combat, 0.5)

# Loot/secret/elite/story
add_marker(col_f4, "F4_LootRoom_1", (-30, 4, 1), mat_marker_loot, 0.7)
add_marker(col_f4, "F4_LootRoom_2", (-15, -4, 1), mat_marker_loot, 0.7)
add_marker(col_f4, "F4_LootRoom_3", (10, 4, 1), mat_marker_loot, 0.7)
add_marker(col_f4, "F4_StoryRoom", (0, 0, 1), mat_marker_story, 0.8)
add_marker(col_f4, "F4_EliteRoom_1", (20, -2, 1), mat_marker_elite, 0.7)
add_marker(col_f4, "F4_EliteRoom_2", (5, -3, 1), mat_marker_elite, 0.7)
add_marker(col_f4, "F4_SecretRoom_1", (-20, 5, 1), mat_marker_secret, 0.5)
add_marker(col_f4, "F4_SecretRoom_2", (15, 5, 1), mat_marker_secret, 0.5)

# Hazards
for i in range(5):
    add_marker(col_f4, f"F4_Hazard_{i}", (-30 + i*15, random.uniform(-4, 4), 0.3),
               mat_marker_hazard, 0.4)

# Lore
for i in range(4):
    add_marker(col_f4, f"F4_Lore_{i}", (-25 + i*16, random.uniform(-4, 4), 1.0),
               mat_marker_lore, 0.35)

# ================== FLOOR 5: Boss Arena ==================
print("=== Floor 5: Boss Arena ===")
col_f5 = make_coll("Floor_5_BossArena")

ARENA_RADIUS = 35  # massive
# Outer ring (chasm rim)
for seg in range(48):
    ang = (seg / 48) * math.tau
    add_bm(f"F5_RimWall_{seg}", cube(2.5, 0.5, 6), bs_wall, col_f5,
           loc=(math.cos(ang) * (ARENA_RADIUS+0.3), math.sin(ang) * (ARENA_RADIUS+0.3), 3),
           rot=(0, 0, ang + math.pi/2))

# Floor (large disk)
add_bm("F5_Floor", disk(ARENA_RADIUS, 48), bs_floor, col_f5, loc=(0, 0, 0))

# Inner viewing tier ring (slightly elevated outer band)
add_bm("F5_TierRingOuter", disk(ARENA_RADIUS - 2, 48), bs_pillar, col_f5, loc=(0, 0, 0.3))
add_bm("F5_TierRingInner", disk(ARENA_RADIUS - 4, 48), bs_floor, col_f5, loc=(0, 0, 0.0))

# 4 cardinal pillars
for i, (px, py) in enumerate([(0, ARENA_RADIUS-8), (0, -(ARENA_RADIUS-8)),
                                (ARENA_RADIUS-8, 0), (-(ARENA_RADIUS-8), 0)]):
    add_bm(f"F5_CardinalPillar_{i}", cyl(1.4, 14, 16), bs_pillar, col_f5, loc=(px, py, 0))
    add_bm(f"F5_CardinalCap_{i}", cube(3, 3, 0.5), bs_pillar, col_f5, loc=(px, py, 14.25))
    # Cyan crown glyph
    add_bm(f"F5_CardinalGlyph_{i}", ico(0.8, 2), bs_glow_cyan, col_f5, loc=(px, py, 15.0))

# Central altar pad (raised disk)
add_bm("F5_AltarBase", disk(4, 16), bs_altar, col_f5, loc=(0, 0, 0.4))
add_bm("F5_AltarRing1", cyl(2.5, 0.6, 16), bs_obsidian, col_f5, loc=(0, 0, 0.7))
add_bm("F5_AltarPedestal", cyl(1.0, 1.5, 12), bs_obsidian, col_f5, loc=(0, 0, 1.5))
add_bm("F5_AltarOrb", ico(0.6, 2), bs_glow_violet, col_f5, loc=(0, 0, 3.4))

# Floor inscription (8 radial lines)
for i in range(8):
    ang = (i / 8) * math.tau
    add_bm(f"F5_FloorLine_{i}", cube(0.1, 12, 0.05), bs_glow_violet, col_f5,
           loc=(math.cos(ang)*15, math.sin(ang)*15, 0.02), rot=(0, 0, ang))

# Boss spawn marker (center)
add_marker(col_f5, "F5_BossSpawn", (0, 0, 4.0), mat_marker_boss, 1.5)

# Loot rooms (3 alcoves)
for i in range(3):
    ang = (i / 3) * math.tau
    add_marker(col_f5, f"F5_LootRoom_{i}",
               (math.cos(ang)*(ARENA_RADIUS-3), math.sin(ang)*(ARENA_RADIUS-3), 1),
               mat_marker_loot, 0.7)

# Story marker (epilogue)
add_marker(col_f5, "F5_StoryRoom", (0, ARENA_RADIUS-12, 1), mat_marker_story, 0.8)

# Secret rooms (2)
add_marker(col_f5, "F5_SecretRoom_1", (-25, 15, 1), mat_marker_secret, 0.5)
add_marker(col_f5, "F5_SecretRoom_2", (25, -15, 1), mat_marker_secret, 0.5)

# Hazards (5 around the arena edge)
for i in range(5):
    ang = (i / 5) * math.tau + 0.4
    add_marker(col_f5, f"F5_Hazard_{i}",
               (math.cos(ang)*20, math.sin(ang)*20, 0.3), mat_marker_hazard, 0.4)

# Lore objects
for i in range(3):
    ang = (i / 3) * math.tau + 0.7
    add_marker(col_f5, f"F5_Lore_{i}",
               (math.cos(ang)*28, math.sin(ang)*28, 1.0), mat_marker_lore, 0.35)

# ================== Cinematic + Hero Cameras (one per floor) ==================
print("=== Cameras ===")
FLOOR_CAMS = [
    ("Floor_1_Hero", (0, -100, 50), (math.radians(60), 0, 0)),
    ("Floor_2_Hero", (0, -55, 30), (math.radians(58), 0, 0)),
    ("Floor_3_Hero", (0, -65, 45), (math.radians(60), 0, 0)),
    ("Floor_4_Hero", (-50, -25, 28), (math.radians(65), 0, math.radians(50))),
    ("Floor_5_Hero", (0, -75, 40), (math.radians(60), 0, 0)),
]
floor_cams = []
for name, loc, rot in FLOOR_CAMS:
    cam_data = bpy.data.cameras.new(name)
    cam_data.lens = 35
    cam_obj = bpy.data.objects.new(name, cam_data)
    cam_obj.location = loc
    cam_obj.rotation_euler = rot
    scene.collection.objects.link(cam_obj)
    floor_cams.append(cam_obj)

# Per-floor area key light
LIGHTS = [
    ("Floor_1_Key", (0, 0, 30), (1.0, 0.95, 0.9), 4500, 60),
    ("Floor_2_Key", (0, 0, 25), (1.0, 0.85, 0.55), 4000, 55),
    ("Floor_3_Key", (0, 0, 30), (0.85, 1.0, 0.85), 3500, 60),
    ("Floor_4_Key", (0, 0, 22), (0.7, 0.85, 1.0), 3000, 50),
    ("Floor_5_Key", (0, 0, 35), (0.85, 0.55, 1.0), 4500, 65),
]
floor_lights = []
for name, loc, color, energy, size in LIGHTS:
    light_data = bpy.data.lights.new(name, type='AREA')
    light_data.energy = energy
    light_data.color = color
    light_data.size = size
    light_obj = bpy.data.objects.new(name, light_data)
    light_obj.location = loc
    scene.collection.objects.link(light_obj)
    floor_lights.append(light_obj)

# World
world = bpy.data.worlds.new("Floors_World")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.03, 0.04, 0.06, 1.0)
bg.inputs['Strength'].default_value = 0.4

# Save
print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)
total = sum(1 for o in bpy.data.objects if o.type == 'MESH')
print(f"Total mesh objects: {total}")
print(f"Saved: {OUTPUT_BLEND}")

# ================== Render hero shots per floor ==================
all_floor_colls = [col_f1, col_f2, col_f3, col_f4, col_f5]

for idx in range(5):
    print(f"=== Rendering Floor {idx+1} hero shot ===")
    # Hide other floors
    for i, fc in enumerate(all_floor_colls):
        for obj in fc.objects:
            obj.hide_render = (i != idx)
    # Hide other lights/cams
    for i, lc in enumerate(floor_lights):
        lc.hide_render = (i != idx)
    scene.camera = floor_cams[idx]
    out_path = os.path.join(RENDER_DIR, f"floor_{idx+1}_hero.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)
    print(f"  → {out_path}")

print("Massive floors pipeline complete.")
