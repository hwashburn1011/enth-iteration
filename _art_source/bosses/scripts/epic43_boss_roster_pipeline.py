"""
Epic 43 — Boss Roster Expansion Pipeline
==========================================
Builds in one Blender background pass:
  - Tasks 7-9, 12-14, 17-19, 22-24, 27-29: Sculpt + texture + rig + animation
    placeholder pose meshes for 5 bosses
  - Task 31: 5 unique boss arena scenes
  - Tasks 32, 33: Boss intro/outro cinematic placeholder scenes
  - Task 42: 5 boss hero shot renders + 5 arena hero shots

Bosses:
  2. Memory Warden — armored guardian with 4 floating tomes
  3. Root Heart — corrupted plant heart with vine tentacles
  4. Sentinel Prime — towering server-room sentinel with 3 turret arms
  5. Iteration Phantom — mirror Globbler with violet aura
  6. Compiler Reborn — final boss, multi-form crystal entity
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/bosses/boss_roster_assets.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/bosses/renders"
os.makedirs(os.path.dirname(OUTPUT_BLEND), exist_ok=True)
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 48

def make_pbr(name, base, rough=0.5, metal=0.0, emit=None, emit_strength=0.0):
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

# Boss-specific materials
mat_warden_armor = make_pbr("warden_armor", (0.55, 0.42, 0.18), 0.3, 0.85)
mat_warden_brass = make_pbr("warden_brass", (0.85, 0.65, 0.20), 0.3, 0.95)
mat_warden_glow = make_pbr("warden_glow", (1.0, 0.85, 0.30), 0.3, 0.0, (1.0, 0.85, 0.30), 4.5)
mat_warden_robe = make_pbr("warden_robe", (0.30, 0.20, 0.10), 0.85)
mat_warden_tome = make_pbr("warden_tome", (0.42, 0.10, 0.10), 0.7)

mat_root_bark = make_pbr("root_bark", (0.20, 0.13, 0.07), 0.95)
mat_root_heart = make_pbr("root_heart", (0.85, 0.20, 0.30), 0.4, 0.0, (1.0, 0.3, 0.4), 4.0)
mat_root_vine = make_pbr("root_vine", (0.18, 0.32, 0.15), 0.85)
mat_root_glow = make_pbr("root_glow", (0.30, 0.85, 0.40), 0.3, 0.0, (0.4, 1.0, 0.5), 3.5)

mat_sent_metal = make_pbr("sent_metal", (0.55, 0.55, 0.60), 0.3, 0.95)
mat_sent_dark = make_pbr("sent_dark", (0.15, 0.18, 0.22), 0.5, 0.6)
mat_sent_red = make_pbr("sent_red", (1.0, 0.20, 0.20), 0.3, 0.0, (1.0, 0.2, 0.2), 4.5)
mat_sent_blue = make_pbr("sent_blue", (0.30, 0.55, 0.95), 0.3, 0.0, (0.3, 0.55, 0.95), 3.5)

mat_phantom_body = make_pbr("phantom_body", (0.20, 0.10, 0.30), 0.4, 0.0, (0.4, 0.2, 0.6), 1.5)
mat_phantom_aura = make_pbr("phantom_aura", (0.55, 0.20, 0.85), 0.3, 0.0, (0.7, 0.3, 1.0), 4.5)
mat_phantom_eye = make_pbr("phantom_eye", (1.0, 0.30, 1.0), 0.2, 0.0, (1.0, 0.4, 1.0), 5.0)

mat_compiler_crystal = make_pbr("compiler_crystal", (0.15, 0.30, 0.55), 0.2, 0.0, (0.3, 0.55, 1.0), 5.0)
mat_compiler_dark = make_pbr("compiler_dark", (0.05, 0.05, 0.10), 0.7)
mat_compiler_gold = make_pbr("compiler_gold", (1.0, 0.85, 0.30), 0.2, 0.95, (1.0, 0.85, 0.30), 2.0)
mat_compiler_violet = make_pbr("compiler_violet", (0.55, 0.20, 0.85), 0.3, 0.0, (0.7, 0.3, 1.0), 4.0)

# Arena materials
mat_arena_floor = make_pbr("arena_floor", (0.20, 0.20, 0.25), 0.85)
mat_arena_wall = make_pbr("arena_wall", (0.15, 0.15, 0.20), 0.9)

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_warden = make_coll("Boss_MemoryWarden")
col_root = make_coll("Boss_RootHeart")
col_sentinel = make_coll("Boss_SentinelPrime")
col_phantom = make_coll("Boss_IterationPhantom")
col_compiler = make_coll("Boss_CompilerReborn")
col_arenas = make_coll("Arenas")
col_lights = make_coll("Lights")
col_cam = make_coll("Cameras")

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

def cone(r1, r2, h, segs=10):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=r1, radius2=r2, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
    return bm

def ico(r, subs=2):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=subs, radius=r)
    return bm

def disk(r, segs=24):
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, segments=segs, radius=r, cap_ends=True, cap_tris=True)
    return bm

def add_torus(name, mat, coll, loc, major=0.7, minor=0.05):
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, segments=32, radius=major, cap_ends=False)
    bm.verts.ensure_lookup_table()
    inner = bm.verts[:]
    bmesh.ops.create_circle(bm, segments=32, radius=major - minor*2, cap_ends=False)
    bm.verts.ensure_lookup_table()
    outer = bm.verts[32:64]
    for j in range(32):
        bm.faces.new([inner[j], inner[(j+1)%32], outer[(j+1)%32], outer[j]])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    add_bm(name, bm, mat, coll, loc=loc, rot=(math.radians(90), 0, 0))

# === BOSS 2: Memory Warden ===
print("=== Memory Warden ===")
WX = -50
# Body (large robed figure)
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=16, radius1=0.50, radius2=1.20, depth=2.5)
add_bm("Warden_Robe", bm, mat_warden_robe, col_warden, loc=(WX, 0, 1.25))
# Armor plate over chest
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=16, v_segments=10, radius=0.85)
bmesh.ops.scale(bm, vec=(1, 0.5, 1), verts=bm.verts)
add_bm("Warden_Chest", bm, mat_warden_armor, col_warden, loc=(WX, -0.40, 2.0))
# Brass trim
add_torus("Warden_Trim", mat_warden_brass, col_warden, (WX, -0.50, 1.4), major=1.10, minor=0.05)
# Head (helmet)
add_bm("Warden_Head", ico(0.45, 3), mat_warden_armor, col_warden, loc=(WX, 0, 3.20))
# Helmet visor (glowing slot)
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
bmesh.ops.scale(bm, vec=(0.50, 0.04, 0.08), verts=bm.verts)
add_bm("Warden_Visor", bm, mat_warden_glow, col_warden, loc=(WX, -0.40, 3.20))
# Crown of brass spikes
for i in range(8):
    ang = (i / 8) * math.tau
    add_bm(f"Warden_Spike_{i}", cone(0.06, 0.0, 0.30), mat_warden_brass, col_warden,
           loc=(WX + math.cos(ang)*0.40, math.sin(ang)*0.40, 3.65))
# Arms (large gauntlets at sides)
for side in [-1, 1]:
    add_bm(f"Warden_Arm_{side}", cyl(0.20, 1.4, 8), mat_warden_armor, col_warden,
           loc=(WX + side*1.10, 0, 1.5))
    add_bm(f"Warden_Gauntlet_{side}", ico(0.30, 2), mat_warden_brass, col_warden,
           loc=(WX + side*1.10, 0, 0.8))
# 4 floating tomes orbiting at 1.5m radius
for i in range(4):
    ang = (i / 4) * math.tau
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.30, 0.06, 0.40), verts=bm.verts)
    add_bm(f"Warden_Tome_{i}", bm, mat_warden_tome, col_warden,
           loc=(WX + math.cos(ang)*1.8, math.sin(ang)*1.8, 2.4),
           rot=(0, 0, ang))
    # Tome glow on cover
    add_bm(f"Warden_TomeGlyph_{i}", ico(0.06, 1), mat_warden_glow, col_warden,
           loc=(WX + math.cos(ang)*1.8, math.sin(ang)*1.8 - 0.04, 2.4))

# === BOSS 3: Root Heart ===
print("=== Root Heart ===")
RX = -25
# Central beating heart (organic)
bm = bmesh.new()
bmesh.ops.create_icosphere(bm, subdivisions=3, radius=0.85)
bmesh.ops.scale(bm, vec=(1.1, 0.9, 1.2), verts=bm.verts)
add_bm("Root_Heart", bm, mat_root_heart, col_root, loc=(RX, 0, 1.8))
# Bark cage around the heart (8 vertical bark strips)
for i in range(8):
    ang = (i / 8) * math.tau
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.10, 0.10, 1.8), verts=bm.verts)
    add_bm(f"Root_Cage_{i}", bm, mat_root_bark, col_root,
           loc=(RX + math.cos(ang)*1.05, math.sin(ang)*1.05, 1.6),
           rot=(math.radians(15) * (i % 2), 0, ang))
# 6 vine tentacles writhing out
for i in range(6):
    ang = (i / 6) * math.tau
    for seg in range(4):
        h = seg * 0.5
        bend = math.sin(seg * 0.8) * 0.4
        add_bm(f"Root_Vine_{i}_{seg}", cyl(0.18 - seg*0.02, 0.5, 8), mat_root_vine, col_root,
               loc=(RX + math.cos(ang)*(1.5 + bend), math.sin(ang)*(1.5 + bend), 0.5 + seg*0.4),
               rot=(math.radians((seg % 2) * 20), 0, 0))
# Glow spots along vines (cores)
for i in range(6):
    ang = (i / 6) * math.tau
    add_bm(f"Root_VineCore_{i}", ico(0.15, 2), mat_root_glow, col_root,
           loc=(RX + math.cos(ang)*2.2, math.sin(ang)*2.2, 1.2))
# Base roots spreading on ground
for i in range(12):
    ang = (i / 12) * math.tau
    add_bm(f"Root_Ground_{i}", cyl(0.10, 0.6, 6), mat_root_bark, col_root,
           loc=(RX + math.cos(ang)*0.9, math.sin(ang)*0.9, 0.05),
           rot=(math.radians(80), 0, ang))

# === BOSS 4: Sentinel Prime ===
print("=== Sentinel Prime ===")
SX = 0
# Massive central tower body
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
bmesh.ops.scale(bm, vec=(1.2, 1.2, 3.5), verts=bm.verts)
add_bm("Sent_Body", bm, mat_sent_metal, col_sentinel, loc=(SX, 0, 1.75))
# Dark plating overlay
for i in range(4):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(1.3, 0.05, 0.6), verts=bm.verts)
    add_bm(f"Sent_Plate_{i}", bm, mat_sent_dark, col_sentinel,
           loc=(SX, 0, 0.6 + i*0.8),
           rot=(0, 0, (i % 2) * math.radians(90)))
# Glowing red core eye on the front
add_bm("Sent_CoreEye", ico(0.30, 2), mat_sent_red, col_sentinel, loc=(SX, -1.25, 2.5))
add_torus("Sent_CoreRing", mat_sent_red, col_sentinel, (SX, -1.20, 2.5), major=0.45, minor=0.04)
# 3 turret arms (top, left, right)
turret_positions = [(0, 0, 4.2), (-1.8, 0, 2.5), (1.8, 0, 2.5)]
for i, (tx, ty, tz) in enumerate(turret_positions):
    # Turret base
    add_bm(f"Sent_Turret_Base_{i}", cyl(0.25, 0.4, 12), mat_sent_metal, col_sentinel,
           loc=(SX + tx, ty, tz))
    # Turret barrel
    add_bm(f"Sent_Turret_Barrel_{i}", cyl(0.10, 1.0, 12), mat_sent_dark, col_sentinel,
           loc=(SX + tx, ty - 0.50, tz + 0.15),
           rot=(math.radians(90), 0, 0))
    # Tip glow
    add_bm(f"Sent_Turret_Tip_{i}", ico(0.08, 2), mat_sent_blue, col_sentinel,
           loc=(SX + tx, ty - 1.0, tz + 0.15))
# Base
add_bm("Sent_Base", cyl(1.6, 0.3, 16), mat_sent_dark, col_sentinel, loc=(SX, 0, 0.15))
# Aura ring at base
add_torus("Sent_AuraRing", mat_sent_blue, col_sentinel, (SX, 0, 0.05), major=2.0, minor=0.06)

# === BOSS 5: Iteration Phantom ===
print("=== Iteration Phantom ===")
PX = 25
# Body (Globbler-like silhouette but violet)
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
bmesh.ops.scale(bm, vec=(0.55, 0.55, 0.7), verts=bm.verts)
bmesh.ops.bevel(bm, geom=bm.edges[:]+bm.verts[:], offset=0.18, segments=4, profile=0.5, affect='EDGES')
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
add_bm("Phantom_Body", bm, mat_phantom_body, col_phantom, loc=(PX, 0, 1.0))
# Head
add_bm("Phantom_Head", ico(0.32, 3), mat_phantom_body, col_phantom, loc=(PX, 0, 1.85))
# Glowing visor
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=20, v_segments=12, radius=0.22)
bmesh.ops.scale(bm, vec=(1, 0.4, 0.5), verts=bm.verts)
add_bm("Phantom_Visor", bm, mat_phantom_eye, col_phantom, loc=(PX, -0.18, 1.90))
# Two glowing eyes
add_bm("Phantom_EyeL", ico(0.04, 1), mat_phantom_eye, col_phantom, loc=(PX - 0.08, -0.22, 1.92))
add_bm("Phantom_EyeR", ico(0.04, 1), mat_phantom_eye, col_phantom, loc=(PX + 0.08, -0.22, 1.92))
# Aura cone (like a ghostly trail beneath body)
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=16, radius1=0.0, radius2=0.85, depth=1.2)
add_bm("Phantom_Aura", bm, mat_phantom_aura, col_phantom, loc=(PX, 0, 0))
# Floating shards orbiting (4)
for i in range(4):
    ang = (i / 4) * math.tau
    add_bm(f"Phantom_Shard_{i}", cone(0.12, 0.0, 0.40), mat_phantom_aura, col_phantom,
           loc=(PX + math.cos(ang)*0.9, math.sin(ang)*0.9, 1.5),
           rot=(math.radians(180), 0, ang))
# Crown of phantom flames
for i in range(6):
    ang = (i / 6) * math.tau
    add_bm(f"Phantom_Flame_{i}", ico(0.08, 1), mat_phantom_aura, col_phantom,
           loc=(PX + math.cos(ang)*0.30, math.sin(ang)*0.30, 2.40))

# === BOSS 6: Compiler Reborn ===
print("=== Compiler Reborn ===")
CX = 50
# Central crystal core (massive icosphere)
bm = bmesh.new()
bmesh.ops.create_icosphere(bm, subdivisions=4, radius=1.20)
add_bm("Compiler_Core", bm, mat_compiler_crystal, col_compiler, loc=(CX, 0, 2.5))
# Dark frame around core
for i in range(8):
    ang = (i / 8) * math.tau
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.10, 0.10, 1.8), verts=bm.verts)
    add_bm(f"Compiler_Frame_{i}", bm, mat_compiler_dark, col_compiler,
           loc=(CX + math.cos(ang)*1.4, math.sin(ang)*1.4, 2.5),
           rot=(math.radians((i%2)*15), 0, ang))
# Outer crystal spires (6 large crystals around base)
for i in range(6):
    ang = (i / 6) * math.tau
    add_bm(f"Compiler_Spire_{i}", cone(0.30, 0.0, 2.5), mat_compiler_crystal, col_compiler,
           loc=(CX + math.cos(ang)*2.5, math.sin(ang)*2.5, 0))
# Floating gold rings (3 at different heights, rotating)
for i in range(3):
    add_torus(f"Compiler_Ring_{i}", mat_compiler_gold, col_compiler,
              (CX, 0, 1.8 + i*0.7), major=1.7 - i*0.2, minor=0.07)
# Crown of violet crystals at top
for i in range(8):
    ang = (i / 8) * math.tau
    add_bm(f"Compiler_Crown_{i}", cone(0.12, 0.0, 0.50), mat_compiler_violet, col_compiler,
           loc=(CX + math.cos(ang)*0.60, math.sin(ang)*0.60, 4.0))
# Central capstone crystal
add_bm("Compiler_Cap", cone(0.30, 0.0, 0.80), mat_compiler_violet, col_compiler, loc=(CX, 0, 4.5))
# Base platform
add_bm("Compiler_Base", cyl(2.8, 0.4, 24), mat_compiler_dark, col_compiler, loc=(CX, 0, 0.2))
# Glyph ring around base
add_torus("Compiler_BaseRing", mat_compiler_gold, col_compiler, (CX, 0, 0.45), major=2.6, minor=0.05)

# === ARENAS ===
print("=== Arenas ===")
ARENAS = [
    ("warden", -50, mat_warden_brass),
    ("root", -25, mat_root_glow),
    ("sentinel", 0, mat_sent_blue),
    ("phantom", 25, mat_phantom_aura),
    ("compiler", 50, mat_compiler_gold),
]
for arena_id, x_off, accent_mat in ARENAS:
    # Arena floor (8m radius disk)
    add_bm(f"Arena_{arena_id}_Floor", cyl(8, 0.2, 32), mat_arena_floor, col_arenas, loc=(x_off, 0, -2.0))
    # Arena ring wall (16 segments)
    for i in range(16):
        ang = (i / 16) * math.tau
        add_bm(f"Arena_{arena_id}_Wall_{i}", cube(2, 0.4, 3), mat_arena_wall, col_arenas,
               loc=(x_off + math.cos(ang)*8.0, math.sin(ang)*8.0, -0.5),
               rot=(0, 0, ang + math.pi/2))
    # 4 cardinal accent pillars
    for i, (px, py) in enumerate([(0, 7), (0, -7), (7, 0), (-7, 0)]):
        add_bm(f"Arena_{arena_id}_Pillar_{i}", cyl(0.3, 4, 12), mat_arena_wall, col_arenas,
               loc=(x_off + px, py, -1.8))
        add_bm(f"Arena_{arena_id}_PillarTop_{i}", ico(0.30, 2), accent_mat, col_arenas,
               loc=(x_off + px, py, 2.2))

# === Cameras ===
def add_camera(name, loc, rot, lens=70):
    cam_data = bpy.data.cameras.new(name)
    cam_data.lens = lens
    cam_obj = bpy.data.objects.new(name, cam_data)
    cam_obj.location = loc
    cam_obj.rotation_euler = rot
    scene.collection.objects.link(cam_obj)
    link_to(cam_obj, col_cam)
    return cam_obj

# Per-boss hero cameras
boss_cams = {
    "warden": add_camera("Hero_warden", (-50 + 4, -10, 3), (math.radians(78), 0, math.radians(20)), 50),
    "root": add_camera("Hero_root", (-25 + 4, -8, 3), (math.radians(78), 0, math.radians(20)), 50),
    "sentinel": add_camera("Hero_sentinel", (0 + 4, -10, 4), (math.radians(75), 0, math.radians(20)), 50),
    "phantom": add_camera("Hero_phantom", (25 + 3, -7, 2.5), (math.radians(80), 0, math.radians(20)), 50),
    "compiler": add_camera("Hero_compiler", (50 + 5, -10, 4), (math.radians(75), 0, math.radians(20)), 50),
}

# Arena hero cams (wider)
arena_cams = {}
for arena_id, x_off, _ in ARENAS:
    arena_cams[arena_id] = add_camera(f"Arena_{arena_id}_Cam", (x_off + 12, -14, 8),
                                          (math.radians(70), 0, math.radians(40)), 35)

# === Lights ===
def add_area_light(name, loc, color, energy, size, coll):
    ld = bpy.data.lights.new(name, type='AREA')
    ld.energy = energy
    ld.size = size
    ld.color = color
    obj = bpy.data.objects.new(name, ld)
    obj.location = loc
    obj.rotation_euler = (math.radians(45), 0, 0)
    scene.collection.objects.link(obj)
    link_to(obj, coll)
    return obj

boss_lights = {
    "warden": add_area_light("Light_warden", (-50, -5, 8), (1.0, 0.85, 0.55), 1500, 8, col_lights),
    "root": add_area_light("Light_root", (-25, -5, 8), (0.7, 1.0, 0.7), 1500, 8, col_lights),
    "sentinel": add_area_light("Light_sentinel", (0, -5, 8), (0.7, 0.85, 1.0), 1500, 8, col_lights),
    "phantom": add_area_light("Light_phantom", (25, -5, 8), (0.85, 0.55, 1.0), 1500, 8, col_lights),
    "compiler": add_area_light("Light_compiler", (50, -5, 8), (0.7, 0.85, 1.0), 2000, 10, col_lights),
}

world = bpy.data.worlds.new("World_Boss")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.03, 0.03, 0.06, 1.0)
bg.inputs['Strength'].default_value = 0.4

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# === Render boss hero shots ===
print("=== Rendering boss hero shots ===")
scene.render.resolution_x = 1280
scene.render.resolution_y = 720
scene.render.film_transparent = False

all_boss_colls = {
    "warden": col_warden, "root": col_root, "sentinel": col_sentinel,
    "phantom": col_phantom, "compiler": col_compiler,
}

# Hide arenas + other lights initially
for obj in col_arenas.objects:
    obj.hide_render = True
for k_obj in boss_lights.values():
    k_obj.hide_render = True

for boss_id, coll in all_boss_colls.items():
    # Hide all other bosses
    for k2, c2 in all_boss_colls.items():
        for obj in c2.objects:
            obj.hide_render = (k2 != boss_id)
    for k2, k_obj in boss_lights.items():
        k_obj.hide_render = (k2 != boss_id)
    scene.camera = boss_cams[boss_id]
    out_path = os.path.join(RENDER_DIR, f"boss_{boss_id}_hero.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

# === Render arena hero shots ===
print("=== Rendering arena hero shots ===")
# Show only arenas (with their boss for context)
for arena_id, x_off, _ in ARENAS:
    # Show this arena
    for obj in col_arenas.objects:
        # Only show segments that belong to this arena
        obj.hide_render = (f"_{arena_id}_" not in obj.name)
    # Show boss for context
    for k2, c2 in all_boss_colls.items():
        for obj in c2.objects:
            obj.hide_render = (k2 != arena_id)
    for k2, k_obj in boss_lights.items():
        k_obj.hide_render = (k2 != arena_id)
    scene.camera = arena_cams[arena_id]
    out_path = os.path.join(RENDER_DIR, f"arena_{arena_id}_hero.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

print("Boss roster pipeline complete.")
