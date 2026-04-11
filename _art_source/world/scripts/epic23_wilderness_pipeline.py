"""
Epic 23 — Open Wilderness Zone Blender Pipeline
================================================
Builds the complete wilderness zone in a single Blender background pass:
- Heightmap terrain (large scale, 200x200m, gentle hills + river valley)
- River with curved course
- Cliff walls (north + south boundaries)
- Forest vegetation density (3 zones with scattered trees)
- 6 clearing variants (different shapes/props)
- Ruin prop set (8 unique ruin pieces)
- Ruin clusters (3 placed groups)
- Path network connecting key landmarks
- 9 path signposts
- 4 dungeon entrance hero monuments (Server Room / Memory Vaults / Corrupted Wilds / Boss Sanctum)
- Hero shot camera positions

Run via:
"/c/Program Files/Blender Foundation/Blender 5.1/blender.exe" --background --python "_art_source/world/scripts/epic23_wilderness_pipeline.py"
"""
import bpy, bmesh, math, random
from mathutils import Vector, Matrix, noise

random.seed(2342)
OUTPUT = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/wilderness_zone.blend"

# ---------- reset scene ----------
bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'

def make_pbr(name, base, rough=0.7, metal=0.0, emit=None, emit_strength=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    bsdf = nt.nodes['Principled BSDF']
    bsdf.inputs['Base Color'].default_value = (*base, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Metallic'].default_value = metal
    if emit is not None:
        bsdf.inputs['Emission Color'].default_value = (*emit, 1.0)
        bsdf.inputs['Emission Strength'].default_value = emit_strength
    return m

# ---------- materials ----------
mat_grass = make_pbr("wild_grass", (0.18, 0.32, 0.12), 0.85)
mat_dirt = make_pbr("wild_dirt", (0.28, 0.20, 0.13), 0.9)
mat_river = make_pbr("river_water", (0.10, 0.25, 0.40), 0.15, 0.0, (0.2, 0.4, 0.6), 0.4)
mat_cliff = make_pbr("cliff_rock", (0.32, 0.30, 0.27), 0.92)
mat_tree_bark = make_pbr("tree_bark", (0.22, 0.13, 0.07), 0.95)
mat_tree_leaves = make_pbr("tree_leaves", (0.16, 0.30, 0.10), 0.85)
mat_pine_leaves = make_pbr("pine_leaves", (0.10, 0.22, 0.10), 0.85)
mat_ruin_stone = make_pbr("ruin_stone", (0.40, 0.38, 0.34), 0.9)
mat_moss = make_pbr("moss", (0.13, 0.28, 0.10), 0.95)
mat_path_stone = make_pbr("path_stone", (0.42, 0.40, 0.36), 0.85)
mat_signpost_wood = make_pbr("signpost_wood", (0.30, 0.18, 0.10), 0.9)
mat_signpost_metal = make_pbr("signpost_metal", (0.50, 0.50, 0.55), 0.4, 0.9)
mat_portal_tech = make_pbr("portal_tech", (0.10, 0.20, 0.30), 0.3, 0.7, (0.2, 0.6, 1.0), 4.0)
mat_portal_gold = make_pbr("portal_gold", (0.50, 0.42, 0.18), 0.3, 1.0, (1.0, 0.8, 0.3), 3.5)
mat_portal_organic = make_pbr("portal_organic", (0.15, 0.35, 0.15), 0.6, 0.0, (0.4, 1.0, 0.4), 3.0)
mat_portal_void = make_pbr("portal_void", (0.05, 0.05, 0.10), 0.2, 0.0, (0.8, 0.2, 1.0), 5.0)
mat_monument = make_pbr("monument_stone", (0.35, 0.34, 0.32), 0.85)

# ---------- collections ----------
def make_coll(name):
    c = bpy.data.collections.new(name)
    bpy.context.scene.collection.children.link(c)
    return c

col_terrain = make_coll("Wild_Terrain")
col_river = make_coll("Wild_River")
col_cliffs = make_coll("Wild_Cliffs")
col_forest = make_coll("Wild_Forest")
col_clearings = make_coll("Wild_Clearings")
col_ruins = make_coll("Wild_Ruins")
col_paths = make_coll("Wild_Paths")
col_signposts = make_coll("Wild_Signposts")
col_entrances = make_coll("Wild_Entrances")
col_cameras = make_coll("Wild_Cameras")

def link_to(obj, coll):
    for c in obj.users_collection: c.objects.unlink(obj)
    coll.objects.link(obj)

def add_mesh_from_bmesh(name, bm, mat, coll, loc=(0,0,0), rot=(0,0,0), scale=(1,1,1)):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me); bm.free()
    me.materials.append(mat)
    obj = bpy.data.objects.new(name, me)
    obj.location = loc
    obj.rotation_euler = rot
    obj.scale = scale
    bpy.context.scene.collection.objects.link(obj)
    link_to(obj, coll)
    return obj

# ---------- 1. Heightmap terrain (200x200m) ----------
print("=== Heightmap Terrain ===")
bm = bmesh.new()
N = 60
S = 200.0
verts = {}
for i in range(N+1):
    for j in range(N+1):
        x = (i/N - 0.5) * S
        y = (j/N - 0.5) * S
        # gentle hills + river valley dip in the middle
        h = noise.noise((x*0.02, y*0.02, 0)) * 4.0
        h += noise.noise((x*0.05, y*0.05, 1)) * 1.5
        # river valley along x axis at y=0
        valley = math.exp(-(y*y)/120.0) * 2.5
        h -= valley
        verts[(i,j)] = bm.verts.new((x, y, h))
bm.verts.ensure_lookup_table()
for i in range(N):
    for j in range(N):
        bm.faces.new([verts[(i,j)], verts[(i+1,j)], verts[(i+1,j+1)], verts[(i,j+1)]])
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
add_mesh_from_bmesh("Wild_Terrain_Base", bm, mat_grass, col_terrain)

# Dirt patches scattered
for k in range(12):
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, segments=12, radius=random.uniform(2, 5))
    bmesh.ops.triangulate(bm, faces=bm.faces)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    px = random.uniform(-90, 90); py = random.uniform(-90, 90)
    add_mesh_from_bmesh(f"Wild_Dirt_{k}", bm, mat_dirt, col_terrain, loc=(px, py, 0.05))

# ---------- 2. River ----------
print("=== River ===")
bm = bmesh.new()
RN = 60
river_verts = []
for i in range(RN+1):
    t = i / RN
    x = (t - 0.5) * 200
    y = math.sin(t * 6.28) * 6.0
    river_verts.append((x, y))

# build flat ribbon
left = []; right = []
for (x, y) in river_verts:
    left.append(bm.verts.new((x, y - 5, -0.5)))
    right.append(bm.verts.new((x, y + 5, -0.5)))
bm.verts.ensure_lookup_table()
for i in range(RN):
    bm.faces.new([left[i], left[i+1], right[i+1], right[i]])
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
add_mesh_from_bmesh("Wild_River_Surface", bm, mat_river, col_river)

# ---------- 3. Cliff walls ----------
print("=== Cliff Walls ===")
def cliff_wall(name, side):
    bm = bmesh.new()
    CN = 20
    for i in range(CN+1):
        x = (i/CN - 0.5) * 200
        h = 12 + noise.noise((x*0.05, side, 5)) * 4
        # 4 vertical strips
        v_bot_back = bm.verts.new((x, 0, 0))
        v_bot_front = bm.verts.new((x, -2*side, 0))
        v_top_front = bm.verts.new((x, -2*side - 1, h))
        v_top_back = bm.verts.new((x, 1*side, h+1))
    bm.verts.ensure_lookup_table()
    vs = bm.verts[:]
    for i in range(CN):
        a = i*4; b = (i+1)*4
        bm.faces.new([vs[a], vs[a+1], vs[b+1], vs[b]])
        bm.faces.new([vs[a+1], vs[a+2], vs[b+2], vs[b+1]])
        bm.faces.new([vs[a+2], vs[a+3], vs[b+3], vs[b+2]])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return bm

bm = cliff_wall("north", -1)
add_mesh_from_bmesh("Wild_Cliff_North", bm, mat_cliff, col_cliffs, loc=(0, 90, 0))
bm = cliff_wall("south", 1)
add_mesh_from_bmesh("Wild_Cliff_South", bm, mat_cliff, col_cliffs, loc=(0, -90, 0))

# ---------- 4. Forest vegetation density ----------
print("=== Forest ===")
def make_tree(kind="oak"):
    bm = bmesh.new()
    # trunk
    bmesh.ops.create_cone(bm, segments=8, radius1=0.35, radius2=0.25, depth=4.0)
    bmesh.ops.translate(bm, vec=(0,0,2), verts=bm.verts)
    return bm

def make_canopy(kind="oak"):
    bm = bmesh.new()
    if kind == "pine":
        # 3 stacked cones
        for i, (r, h, z) in enumerate([(2.0, 2.0, 4.0), (1.5, 1.6, 5.5), (1.0, 1.4, 6.8)]):
            tmp = bmesh.new()
            bmesh.ops.create_cone(tmp, segments=8, radius1=r, radius2=0.0, depth=h)
            bmesh.ops.translate(tmp, vec=(0,0,z), verts=tmp.verts)
            me = bpy.data.meshes.new(f"_tmp_{i}")
            tmp.to_mesh(me); tmp.free()
            bm.from_mesh(me)
            bpy.data.meshes.remove(me)
    else:
        bmesh.ops.create_icosphere(bm, subdivisions=2, radius=2.2)
        bmesh.ops.translate(bm, vec=(0,0,5.5), verts=bm.verts)
    return bm

# Forest zones (3): NE corner, SW corner, far west
forest_zones = [(50, 50, 30, "oak"), (-50, -50, 30, "pine"), (-80, 30, 25, "oak")]
tree_id = 0
for cx, cy, count, kind in forest_zones:
    for k in range(count):
        px = cx + random.uniform(-25, 25)
        py = cy + random.uniform(-25, 25)
        # skip if inside cliffs
        if abs(py) > 80: continue
        # trunk
        bm = make_tree(kind)
        add_mesh_from_bmesh(f"Wild_TreeTrunk_{tree_id}", bm, mat_tree_bark, col_forest, loc=(px, py, 0))
        # canopy
        bm = make_canopy(kind)
        leaf_mat = mat_pine_leaves if kind == "pine" else mat_tree_leaves
        add_mesh_from_bmesh(f"Wild_TreeLeaves_{tree_id}", bm, leaf_mat, col_forest, loc=(px, py, 0))
        tree_id += 1

# ---------- 5. 6 Clearing variants ----------
print("=== Clearings ===")
clearings = [
    ("Mossy", (-30, 30), 6, mat_moss, "logs"),
    ("Stone", (30, -30), 6, mat_path_stone, "rocks"),
    ("Flower", (-60, -20), 5, mat_grass, "flowers"),
    ("Fire", (60, 30), 5, mat_dirt, "campfire"),
    ("Pond", (20, 60), 7, mat_river, "pond"),
    ("Ritual", (-20, -60), 6, mat_path_stone, "circle"),
]
for cname, (cx, cy), radius, base_mat, feature in clearings:
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, segments=16, radius=radius, cap_ends=True, cap_tris=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    add_mesh_from_bmesh(f"Wild_Clear_{cname}_Base", bm, base_mat, col_clearings, loc=(cx, cy, 0.1))
    if feature == "logs":
        for i in range(3):
            bm = bmesh.new()
            bmesh.ops.create_cone(bm, segments=8, radius1=0.4, radius2=0.4, depth=3.0)
            bmesh.ops.rotate(bm, matrix=Matrix.Rotation(math.radians(90), 3, 'Y'), verts=bm.verts)
            ang = i * 2.1
            add_mesh_from_bmesh(f"Wild_Clear_{cname}_Log_{i}", bm, mat_tree_bark, col_clearings,
                                loc=(cx + math.cos(ang)*2, cy + math.sin(ang)*2, 0.4),
                                rot=(0,0,ang))
    elif feature == "rocks":
        for i in range(5):
            bm = bmesh.new()
            bmesh.ops.create_icosphere(bm, subdivisions=1, radius=random.uniform(0.4, 0.8))
            ang = i * 1.25
            add_mesh_from_bmesh(f"Wild_Clear_{cname}_Rock_{i}", bm, mat_cliff, col_clearings,
                                loc=(cx + math.cos(ang)*3, cy + math.sin(ang)*3, 0.3))
    elif feature == "flowers":
        for i in range(8):
            bm = bmesh.new()
            bmesh.ops.create_cone(bm, segments=6, radius1=0.15, radius2=0.0, depth=0.5)
            ang = random.uniform(0, 6.28); r = random.uniform(0.5, 4)
            add_mesh_from_bmesh(f"Wild_Clear_{cname}_Flower_{i}", bm, mat_pine_leaves, col_clearings,
                                loc=(cx + math.cos(ang)*r, cy + math.sin(ang)*r, 0.25))
    elif feature == "campfire":
        bm = bmesh.new()
        bmesh.ops.create_circle(bm, segments=8, radius=0.6, cap_ends=True, cap_tris=True)
        add_mesh_from_bmesh(f"Wild_Clear_{cname}_FirePit", bm, mat_dirt, col_clearings, loc=(cx, cy, 0.15))
        for i in range(4):
            bm = bmesh.new()
            bmesh.ops.create_cone(bm, segments=6, radius1=0.1, radius2=0.05, depth=1.0)
            ang = i * 1.57
            add_mesh_from_bmesh(f"Wild_Clear_{cname}_Log_{i}", bm, mat_tree_bark, col_clearings,
                                loc=(cx + math.cos(ang)*0.5, cy + math.sin(ang)*0.5, 0.4),
                                rot=(math.radians(70), 0, ang))
    elif feature == "pond":
        bm = bmesh.new()
        bmesh.ops.create_circle(bm, segments=20, radius=4, cap_ends=True, cap_tris=True)
        add_mesh_from_bmesh(f"Wild_Clear_{cname}_Pond", bm, mat_river, col_clearings, loc=(cx, cy, 0.05))
    elif feature == "circle":
        for i in range(8):
            bm = bmesh.new()
            bmesh.ops.create_cone(bm, segments=4, radius1=0.4, radius2=0.3, depth=1.5)
            ang = i * 0.785
            add_mesh_from_bmesh(f"Wild_Clear_{cname}_Stone_{i}", bm, mat_ruin_stone, col_clearings,
                                loc=(cx + math.cos(ang)*4, cy + math.sin(ang)*4, 0.75))

# ---------- 6. Ruin prop set (8 unique) ----------
print("=== Ruin Props ===")
def make_pillar(h=3.0, r=0.5):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=10, radius1=r*1.1, radius2=r, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
    return bm

def make_archway():
    bm = bmesh.new()
    # 2 columns + lintel
    for x in [-1.5, 1.5]:
        tmp = bmesh.new()
        bmesh.ops.create_cube(tmp, size=1.0)
        bmesh.ops.scale(tmp, vec=(0.5, 0.5, 4), verts=tmp.verts)
        bmesh.ops.translate(tmp, vec=(x, 0, 2), verts=tmp.verts)
        me = bpy.data.meshes.new("_tmp"); tmp.to_mesh(me); tmp.free()
        bm.from_mesh(me); bpy.data.meshes.remove(me)
    tmp = bmesh.new()
    bmesh.ops.create_cube(tmp, size=1.0)
    bmesh.ops.scale(tmp, vec=(4, 0.5, 0.6), verts=tmp.verts)
    bmesh.ops.translate(tmp, vec=(0, 0, 4.3), verts=tmp.verts)
    me = bpy.data.meshes.new("_tmp"); tmp.to_mesh(me); tmp.free()
    bm.from_mesh(me); bpy.data.meshes.remove(me)
    return bm

def make_fallen_block():
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(2.5, 1.0, 0.7), verts=bm.verts)
    return bm

def make_broken_wall():
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(4.0, 0.4, 2.0), verts=bm.verts)
    bmesh.ops.translate(bm, vec=(0, 0, 1), verts=bm.verts)
    # cut top jagged
    for v in bm.verts:
        if v.co.z > 1.5:
            v.co.z += random.uniform(-0.5, 0.5)
    return bm

def make_altar():
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(1.5, 1.5, 0.4), verts=bm.verts)
    bmesh.ops.translate(bm, vec=(0,0,0.8), verts=bm.verts)
    tmp = bmesh.new()
    bmesh.ops.create_cube(tmp, size=1.0)
    bmesh.ops.scale(tmp, vec=(2.0, 2.0, 0.8), verts=tmp.verts)
    bmesh.ops.translate(tmp, vec=(0,0,0.4), verts=tmp.verts)
    me = bpy.data.meshes.new("_tmp"); tmp.to_mesh(me); tmp.free()
    bm.from_mesh(me); bpy.data.meshes.remove(me)
    return bm

def make_obelisk():
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=4, radius1=0.7, radius2=0.0, depth=5.0)
    bmesh.ops.translate(bm, vec=(0,0,2.5), verts=bm.verts)
    return bm

def make_round_base():
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=2.0, radius2=1.8, depth=0.6)
    bmesh.ops.translate(bm, vec=(0,0,0.3), verts=bm.verts)
    return bm

def make_sphere_orb():
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.8)
    bmesh.ops.translate(bm, vec=(0,0,1.0), verts=bm.verts)
    return bm

ruin_builders = [
    ("Pillar", make_pillar, mat_ruin_stone),
    ("Archway", make_archway, mat_ruin_stone),
    ("FallenBlock", make_fallen_block, mat_ruin_stone),
    ("BrokenWall", make_broken_wall, mat_ruin_stone),
    ("Altar", make_altar, mat_ruin_stone),
    ("Obelisk", make_obelisk, mat_ruin_stone),
    ("RoundBase", make_round_base, mat_ruin_stone),
    ("Orb", make_sphere_orb, mat_moss),
]

# ---------- 7. Ruin clusters (3 placed groups) ----------
print("=== Ruin Clusters ===")
ruin_clusters = [(-70, 70), (70, -70), (0, 70)]
for ci, (cx, cy) in enumerate(ruin_clusters):
    for ri, (rname, builder, mat) in enumerate(ruin_builders):
        ang = (ri / 8) * 6.28
        rad = 4 + (ri % 3)
        px = cx + math.cos(ang) * rad
        py = cy + math.sin(ang) * rad
        bm = builder()
        rot_z = random.uniform(0, 6.28)
        if rname == "FallenBlock":
            rot_x = random.uniform(0, 1.0)
        else:
            rot_x = 0
        add_mesh_from_bmesh(f"Wild_Ruin_C{ci}_{rname}", bm, mat, col_ruins,
                            loc=(px, py, 0), rot=(rot_x, 0, rot_z))

# ---------- 8. Path network ----------
print("=== Paths ===")
path_segments = [
    ((-90, 0), (-30, 30)),    # west to mossy clearing
    ((-30, 30), (30, -30)),   # mossy to stone
    ((30, -30), (90, 0)),     # stone to east
    ((-30, 30), (0, 70)),     # mossy to north ruin
    ((30, -30), (60, 30)),    # stone to fire clearing
    ((-60, -20), (-30, 30)),  # flower to mossy
    ((20, 60), (0, 70)),      # pond to north ruin
]
for pi, (p1, p2) in enumerate(path_segments):
    dx = p2[0] - p1[0]; dy = p2[1] - p1[1]
    length = math.sqrt(dx*dx + dy*dy)
    angle = math.atan2(dy, dx)
    cx = (p1[0] + p2[0]) / 2; cy = (p1[1] + p2[1]) / 2
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(length/2, 1.5, 0.05), verts=bm.verts)
    add_mesh_from_bmesh(f"Wild_Path_{pi}", bm, mat_path_stone, col_paths,
                        loc=(cx, cy, 0.06), rot=(0, 0, angle))

# ---------- 9. Path signposts (9) ----------
print("=== Signposts ===")
signpost_positions = [
    ((-90, 0), "West Gate"),
    ((90, 0), "East Gate"),
    ((-30, 30), "Mossy Hollow"),
    ((30, -30), "Stone Glade"),
    ((-60, -20), "Flower Meadow"),
    ((60, 30), "Camp"),
    ((20, 60), "Quiet Pond"),
    ((-20, -60), "Ritual Site"),
    ((0, 70), "Old Ruins"),
]
for si, ((sx, sy), label) in enumerate(signpost_positions):
    # post
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.1, radius2=0.1, depth=2.5)
    bmesh.ops.translate(bm, vec=(0,0,1.25), verts=bm.verts)
    add_mesh_from_bmesh(f"Wild_Sign_Post_{si}", bm, mat_signpost_wood, col_signposts, loc=(sx, sy, 0))
    # plate
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.8, 0.05, 0.4), verts=bm.verts)
    add_mesh_from_bmesh(f"Wild_Sign_Plate_{si}", bm, mat_signpost_metal, col_signposts,
                        loc=(sx, sy, 2.2))

# ---------- 10. 4 Dungeon entrance hero monuments ----------
print("=== Dungeon Entrance Monuments ===")
entrances = [
    ("ServerRoom", (-90, -50), mat_portal_tech, "tech"),
    ("MemoryVaults", (90, -50), mat_portal_gold, "gold"),
    ("CorruptedWilds", (-90, 50), mat_portal_organic, "organic"),
    ("BossSanctum", (90, 50), mat_portal_void, "void"),
]
for name, (ex, ey), portal_mat, kind in entrances:
    # base platform
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=8, radius1=4.0, radius2=3.6, depth=0.8)
    bmesh.ops.translate(bm, vec=(0,0,0.4), verts=bm.verts)
    add_mesh_from_bmesh(f"Wild_Entrance_{name}_Base", bm, mat_monument, col_entrances, loc=(ex, ey, 0))
    # 2 framing pillars
    for i, x_off in enumerate([-2.0, 2.0]):
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=8, radius1=0.5, radius2=0.4, depth=6.0)
        bmesh.ops.translate(bm, vec=(0,0,3.0), verts=bm.verts)
        add_mesh_from_bmesh(f"Wild_Entrance_{name}_Pillar_{i}", bm, mat_monument, col_entrances,
                            loc=(ex + x_off, ey, 0.8))
    # arch top
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(2.7, 0.6, 0.6), verts=bm.verts)
    add_mesh_from_bmesh(f"Wild_Entrance_{name}_Arch", bm, mat_monument, col_entrances,
                        loc=(ex, ey, 7.0))
    # portal disk
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, segments=20, radius=1.6, cap_ends=True, cap_tris=True)
    bmesh.ops.rotate(bm, matrix=Matrix.Rotation(math.radians(90), 3, 'X'), verts=bm.verts)
    add_mesh_from_bmesh(f"Wild_Entrance_{name}_Portal", bm, portal_mat, col_entrances,
                        loc=(ex, ey, 3.5))
    # signature glyph (small cube above arch with portal mat)
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=1, radius=0.4)
    add_mesh_from_bmesh(f"Wild_Entrance_{name}_Glyph", bm, portal_mat, col_entrances,
                        loc=(ex, ey, 8.0))

# ---------- 11. Hero shot cameras ----------
print("=== Hero Cameras ===")
hero_shots = [
    ("Hero_River", (0, -25, 8), (math.radians(70), 0, 0)),
    ("Hero_NorthRuins", (0, 50, 12), (math.radians(70), 0, math.radians(180))),
    ("Hero_ServerEntrance", (-70, -50, 6), (math.radians(75), 0, math.radians(-45))),
    ("Hero_BossSanctum", (70, 50, 6), (math.radians(75), 0, math.radians(135))),
    ("Hero_Forest", (50, 50, 5), (math.radians(80), 0, math.radians(225))),
]
for cname, loc, rot in hero_shots:
    cam_data = bpy.data.cameras.new(cname)
    cam_obj = bpy.data.objects.new(cname, cam_data)
    cam_obj.location = loc
    cam_obj.rotation_euler = rot
    bpy.context.scene.collection.objects.link(cam_obj)
    link_to(cam_obj, col_cameras)

# ---------- save ----------
total = sum(1 for o in bpy.data.objects if o.type == 'MESH')
print(f"Wilderness pipeline complete. Total mesh objects: {total}")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT)
print(f"Saved: {OUTPUT}")
