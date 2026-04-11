"""
Epic 24 — Multiple Dungeon Entrances Pipeline
==============================================
Builds 4 detailed hero monuments + portal VFX for the dungeon entrances:
1. Server Room Portal — cold tech, blue glow, pipes, cables
2. Memory Vaults Portal — gold archaic, runes, scrollwork
3. Corrupted Wilds Portal — organic, vines, twisted growths
4. Final Vault Portal — void/violet, sealed with chains, locked appearance

Each monument includes:
- 4-tier base platform
- 4 framing pillars
- Decorative arch with capstone
- Portal disk with animated emission material
- Theme-specific decor (pipes / runes / vines / chains)
- Banner pair flanking the entrance
- Hero light setup
- Render camera
"""
import bpy, bmesh, math, random
from mathutils import Vector, Matrix

random.seed(2424)
OUTPUT = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/dungeon_entrances.blend"

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'

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

# Stone & metal materials
mat_monument = make_pbr("ent_monument", (0.34, 0.33, 0.31), 0.85)
mat_dark_stone = make_pbr("ent_dark_stone", (0.18, 0.18, 0.20), 0.9)
mat_bronze = make_pbr("ent_bronze", (0.45, 0.30, 0.12), 0.4, 0.95)
mat_steel = make_pbr("ent_steel", (0.55, 0.55, 0.60), 0.3, 0.95)
mat_gold = make_pbr("ent_gold", (0.85, 0.65, 0.20), 0.2, 1.0)
mat_chain = make_pbr("ent_chain", (0.30, 0.30, 0.32), 0.4, 0.9)

# Per-entrance themed materials
mat_tech_glow = make_pbr("portal_tech", (0.05, 0.10, 0.20), 0.2, 0.7, (0.2, 0.6, 1.0), 6.0)
mat_tech_pipe = make_pbr("tech_pipe", (0.30, 0.32, 0.36), 0.3, 0.8, (0.1, 0.3, 0.6), 0.8)

mat_gold_glow = make_pbr("portal_gold_glow", (0.40, 0.30, 0.10), 0.2, 0.0, (1.0, 0.8, 0.3), 5.0)
mat_rune_gold = make_pbr("rune_gold", (0.60, 0.45, 0.10), 0.3, 0.9, (1.0, 0.7, 0.2), 1.5)

mat_organic_glow = make_pbr("portal_organic", (0.10, 0.25, 0.10), 0.4, 0.0, (0.4, 1.0, 0.4), 4.5)
mat_vine = make_pbr("vine", (0.10, 0.22, 0.06), 0.95, 0.0, (0.2, 0.5, 0.1), 0.4)
mat_growth = make_pbr("growth", (0.18, 0.30, 0.12), 0.85)

mat_void_glow = make_pbr("portal_void", (0.05, 0.02, 0.10), 0.15, 0.0, (0.8, 0.2, 1.0), 7.0)
mat_seal = make_pbr("seal_iron", (0.20, 0.20, 0.22), 0.5, 0.85)

def make_coll(name):
    c = bpy.data.collections.new(name)
    bpy.context.scene.collection.children.link(c)
    return c

col_tech = make_coll("Entrance_ServerRoom")
col_gold = make_coll("Entrance_MemoryVaults")
col_organic = make_coll("Entrance_CorruptedWilds")
col_void = make_coll("Entrance_FinalVault")
col_cameras = make_coll("Entrance_Cameras")

def link_to(obj, coll):
    for c in obj.users_collection: c.objects.unlink(obj)
    coll.objects.link(obj)

def add_bm(name, bm, mat, coll, loc=(0,0,0), rot=(0,0,0), scale=(1,1,1)):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me); bm.free()
    me.materials.append(mat)
    obj = bpy.data.objects.new(name, me)
    obj.location = loc; obj.rotation_euler = rot; obj.scale = scale
    bpy.context.scene.collection.objects.link(obj)
    link_to(obj, coll)
    return obj

# ---------- Generic monument builder ----------
def build_monument_base(prefix, coll, origin):
    cx, cy, cz = origin
    # Tier 1 (largest)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=6.0, radius2=5.6, depth=0.6)
    bmesh.ops.translate(bm, vec=(0,0,0.3), verts=bm.verts)
    add_bm(f"{prefix}_Tier1", bm, mat_monument, coll, loc=(cx, cy, cz))
    # Tier 2
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=4.5, radius2=4.2, depth=0.6)
    bmesh.ops.translate(bm, vec=(0,0,0.3), verts=bm.verts)
    add_bm(f"{prefix}_Tier2", bm, mat_monument, coll, loc=(cx, cy, cz+0.6))
    # Tier 3
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=3.5, radius2=3.3, depth=0.5)
    bmesh.ops.translate(bm, vec=(0,0,0.25), verts=bm.verts)
    add_bm(f"{prefix}_Tier3", bm, mat_dark_stone, coll, loc=(cx, cy, cz+1.2))
    # Tier 4 inscription pad
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=2.8, radius2=2.7, depth=0.2)
    bmesh.ops.translate(bm, vec=(0,0,0.1), verts=bm.verts)
    add_bm(f"{prefix}_Pad", bm, mat_dark_stone, coll, loc=(cx, cy, cz+1.7))

def build_pillars(prefix, coll, origin, pillar_mat):
    cx, cy, cz = origin
    for i, (px, py) in enumerate([(-2.5, -2.5), (2.5, -2.5), (-2.5, 2.5), (2.5, 2.5)]):
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=8, radius1=0.55, radius2=0.45, depth=8.0)
        bmesh.ops.translate(bm, vec=(0,0,4), verts=bm.verts)
        add_bm(f"{prefix}_Pillar_{i}", bm, pillar_mat, coll, loc=(cx+px, cy+py, cz+1.9))
        # capital
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        bmesh.ops.scale(bm, vec=(0.9, 0.9, 0.4), verts=bm.verts)
        add_bm(f"{prefix}_Cap_{i}", bm, pillar_mat, coll, loc=(cx+px, cy+py, cz+10.1))

def build_arch(prefix, coll, origin, mat):
    cx, cy, cz = origin
    # crossbeam
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(6.5, 0.7, 0.7), verts=bm.verts)
    add_bm(f"{prefix}_Beam", bm, mat, coll, loc=(cx, cy, cz+10.7))
    # capstone
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(3.0, 1.0, 1.4), verts=bm.verts)
    add_bm(f"{prefix}_Capstone", bm, mat, coll, loc=(cx, cy, cz+12.0))

def build_portal_disk(prefix, coll, origin, glow_mat):
    cx, cy, cz = origin
    # Outer ring frame
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=20, radius1=2.4, radius2=2.4, depth=0.4)
    bmesh.ops.rotate(bm, matrix=Matrix.Rotation(math.radians(90), 3, 'X'), verts=bm.verts)
    add_bm(f"{prefix}_Ring", bm, mat_monument, coll, loc=(cx, cy, cz+5.5))
    # Inner glowing disk
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, segments=24, radius=2.0, cap_ends=True, cap_tris=True)
    bmesh.ops.rotate(bm, matrix=Matrix.Rotation(math.radians(90), 3, 'X'), verts=bm.verts)
    add_bm(f"{prefix}_Disk", bm, glow_mat, coll, loc=(cx, cy, cz+5.5))
    # Energy core (sphere)
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.5)
    add_bm(f"{prefix}_Core", bm, glow_mat, coll, loc=(cx, cy, cz+5.5))

def build_banner(prefix, coll, origin, banner_mat, side):
    cx, cy, cz = origin
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.05, 0.7, 2.5), verts=bm.verts)
    add_bm(f"{prefix}_Banner_{side}", bm, banner_mat, coll, loc=(cx + side*4, cy, cz+6.5))
    # pole
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.08, radius2=0.08, depth=4.0)
    bmesh.ops.translate(bm, vec=(0,0,2), verts=bm.verts)
    add_bm(f"{prefix}_Pole_{side}", bm, mat_steel, coll, loc=(cx + side*4, cy, cz+5))

def add_hero_light(prefix, coll, origin, color, energy):
    cx, cy, cz = origin
    light_data = bpy.data.lights.new(f"{prefix}_Key", type='SPOT')
    light_data.energy = energy
    light_data.color = color
    light_data.spot_size = math.radians(80)
    obj = bpy.data.objects.new(f"{prefix}_Key", light_data)
    obj.location = (cx, cy - 8, cz + 8)
    obj.rotation_euler = (math.radians(60), 0, 0)
    bpy.context.scene.collection.objects.link(obj)
    link_to(obj, coll)

def add_camera(name, coll, origin):
    cx, cy, cz = origin
    cam_data = bpy.data.cameras.new(name)
    cam_obj = bpy.data.objects.new(name, cam_data)
    cam_obj.location = (cx, cy - 12, cz + 6)
    cam_obj.rotation_euler = (math.radians(75), 0, 0)
    bpy.context.scene.collection.objects.link(cam_obj)
    link_to(cam_obj, coll)

# ---------- 1. Server Room Portal ----------
print("=== Server Room Portal ===")
ORIGIN_TECH = (-30, 0, 0)
build_monument_base("Tech", col_tech, ORIGIN_TECH)
build_pillars("Tech", col_tech, ORIGIN_TECH, mat_steel)
build_arch("Tech", col_tech, ORIGIN_TECH, mat_steel)
build_portal_disk("Tech", col_tech, ORIGIN_TECH, mat_tech_glow)
build_banner("Tech", col_tech, ORIGIN_TECH, mat_tech_glow, -1)
build_banner("Tech", col_tech, ORIGIN_TECH, mat_tech_glow, 1)
# Tech: pipes around the portal
for i in range(8):
    ang = i * 0.785
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=8, radius1=0.18, radius2=0.18, depth=2.5)
    add_bm(f"Tech_Pipe_{i}", bm, mat_tech_pipe, col_tech,
           loc=(ORIGIN_TECH[0] + math.cos(ang)*3.0, ORIGIN_TECH[1] + math.sin(ang)*0.4, 5.5),
           rot=(0, math.radians(90), ang))
# Tech: cables draped from arch
for i in range(5):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=6, radius1=0.1, radius2=0.1, depth=4.0)
    add_bm(f"Tech_Cable_{i}", bm, mat_tech_pipe, col_tech,
           loc=(ORIGIN_TECH[0] - 2 + i, ORIGIN_TECH[1], 8.0),
           rot=(math.radians(20), 0, 0))
add_hero_light("Tech", col_tech, ORIGIN_TECH, (0.4, 0.7, 1.0), 800)
add_camera("Tech_HeroShot", col_cameras, ORIGIN_TECH)

# ---------- 2. Memory Vaults Portal ----------
print("=== Memory Vaults Portal ===")
ORIGIN_GOLD = (-10, 0, 0)
build_monument_base("Gold", col_gold, ORIGIN_GOLD)
build_pillars("Gold", col_gold, ORIGIN_GOLD, mat_bronze)
build_arch("Gold", col_gold, ORIGIN_GOLD, mat_bronze)
build_portal_disk("Gold", col_gold, ORIGIN_GOLD, mat_gold_glow)
build_banner("Gold", col_gold, ORIGIN_GOLD, mat_gold_glow, -1)
build_banner("Gold", col_gold, ORIGIN_GOLD, mat_gold_glow, 1)
# Gold: rune ring around disk
for i in range(12):
    ang = i * 0.5236
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.2, 0.05, 0.3), verts=bm.verts)
    add_bm(f"Gold_Rune_{i}", bm, mat_rune_gold, col_gold,
           loc=(ORIGIN_GOLD[0] + math.cos(ang)*2.6, ORIGIN_GOLD[1] - 0.3, 5.5 + math.sin(ang)*2.6),
           rot=(0, 0, ang))
# Gold: scrollwork on capstone
for i in range(4):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=1, radius=0.3)
    add_bm(f"Gold_Scroll_{i}", bm, mat_gold, col_gold,
           loc=(ORIGIN_GOLD[0] - 1.5 + i, ORIGIN_GOLD[1], 12.5))
add_hero_light("Gold", col_gold, ORIGIN_GOLD, (1.0, 0.85, 0.5), 700)
add_camera("Gold_HeroShot", col_cameras, ORIGIN_GOLD)

# ---------- 3. Corrupted Wilds Portal ----------
print("=== Corrupted Wilds Portal ===")
ORIGIN_ORG = (10, 0, 0)
build_monument_base("Org", col_organic, ORIGIN_ORG)
build_pillars("Org", col_organic, ORIGIN_ORG, mat_growth)
build_arch("Org", col_organic, ORIGIN_ORG, mat_growth)
build_portal_disk("Org", col_organic, ORIGIN_ORG, mat_organic_glow)
build_banner("Org", col_organic, ORIGIN_ORG, mat_organic_glow, -1)
build_banner("Org", col_organic, ORIGIN_ORG, mat_organic_glow, 1)
# Organic: vines spiraling around pillars
for p_idx, (px, py) in enumerate([(-2.5, -2.5), (2.5, -2.5), (-2.5, 2.5), (2.5, 2.5)]):
    for j in range(6):
        h = 2 + j * 1.4
        ang = j * 1.0
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=6, radius1=0.12, radius2=0.08, depth=0.8)
        add_bm(f"Org_Vine_{p_idx}_{j}", bm, mat_vine, col_organic,
               loc=(ORIGIN_ORG[0] + px + math.cos(ang)*0.6,
                    ORIGIN_ORG[1] + py + math.sin(ang)*0.6, h),
               rot=(math.radians(50), 0, ang))
# Organic: growths on platform
for i in range(8):
    ang = i * 0.785
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=1, radius=random.uniform(0.4, 0.7))
    add_bm(f"Org_Growth_{i}", bm, mat_growth, col_organic,
           loc=(ORIGIN_ORG[0] + math.cos(ang)*4.5, ORIGIN_ORG[1] + math.sin(ang)*4.5, 1.0))
add_hero_light("Org", col_organic, ORIGIN_ORG, (0.5, 1.0, 0.5), 700)
add_camera("Org_HeroShot", col_cameras, ORIGIN_ORG)

# ---------- 4. Final Vault Portal ----------
print("=== Final Vault Portal ===")
ORIGIN_VOID = (30, 0, 0)
build_monument_base("Void", col_void, ORIGIN_VOID)
build_pillars("Void", col_void, ORIGIN_VOID, mat_dark_stone)
build_arch("Void", col_void, ORIGIN_VOID, mat_dark_stone)
build_portal_disk("Void", col_void, ORIGIN_VOID, mat_void_glow)
build_banner("Void", col_void, ORIGIN_VOID, mat_void_glow, -1)
build_banner("Void", col_void, ORIGIN_VOID, mat_void_glow, 1)
# Void: chains crossing the portal (locked appearance)
for i in range(6):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.15, 0.15, 2.5), verts=bm.verts)
    add_bm(f"Void_Chain_{i}", bm, mat_chain, col_void,
           loc=(ORIGIN_VOID[0] - 1.5 + i*0.6, ORIGIN_VOID[1], 5.5),
           rot=(0, math.radians(90 + (i-2)*20), 0))
# Void: massive iron seal lock at center
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=12, radius1=1.0, radius2=0.9, depth=0.3)
bmesh.ops.rotate(bm, matrix=Matrix.Rotation(math.radians(90), 3, 'X'), verts=bm.verts)
add_bm("Void_Seal", bm, mat_seal, col_void, loc=(ORIGIN_VOID[0], ORIGIN_VOID[1] - 0.4, 5.5))
# Void: warning glyphs
for i in range(4):
    ang = i * 1.57 + 0.785
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=1, radius=0.2)
    add_bm(f"Void_Glyph_{i}", bm, mat_void_glow, col_void,
           loc=(ORIGIN_VOID[0] + math.cos(ang)*3.0,
                ORIGIN_VOID[1] - 0.4, 5.5 + math.sin(ang)*3.0))
add_hero_light("Void", col_void, ORIGIN_VOID, (0.7, 0.3, 1.0), 900)
add_camera("Void_HeroShot", col_cameras, ORIGIN_VOID)

# ---------- save ----------
total = sum(1 for o in bpy.data.objects if o.type == 'MESH')
print(f"Dungeon entrances pipeline complete. Total mesh objects: {total}")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT)
print(f"Saved: {OUTPUT}")
