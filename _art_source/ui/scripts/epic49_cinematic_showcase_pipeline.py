"""
Epic 49 — Cinematic Showcase Reel
====================================
Renders 6 cinematic-style frames representing key moments:
  - opening: Globbler awakening on a pedestal
  - iteration_transition: portal flares with glitch effect
  - first_boss_kill: hero pose with falling ash
  - max_affinity: 2 figures embracing under stars
  - final_boss: massive crystal entity towering
  - ending: 9 candles burning at a memorial

Each frame uses cinematic framing (letterbox-aware aspect, DOF-friendly).
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/ui/cinematic_showcase.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/ui/renders"
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 48
scene.render.resolution_x = 1920
scene.render.resolution_y = 800  # Cinematic 2.4:1 aspect

def make_pbr(name, base, rough=0.55, metal=0.0, emit=None, emit_strength=0.0):
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

# Materials
mat_floor = make_pbr("c_floor", (0.20, 0.20, 0.25), 0.85)
mat_pedestal = make_pbr("c_pedestal", (0.45, 0.42, 0.38), 0.85)
mat_globbler = make_pbr("c_globbler", (0.30, 0.55, 0.95), 0.5)
mat_skin = make_pbr("c_skin", (0.85, 0.75, 0.60), 0.7)
mat_glow_warm = make_pbr("c_glow_warm", (1.0, 0.85, 0.45), 0.4, 0.0, (1.0, 0.85, 0.45), 5.0)
mat_glow_violet = make_pbr("c_glow_violet", (0.75, 0.40, 1.0), 0.3, 0.0, (0.7, 0.4, 1.0), 6.0)
mat_glow_red = make_pbr("c_glow_red", (1.0, 0.30, 0.20), 0.3, 0.0, (1.0, 0.3, 0.2), 5.0)
mat_glow_cyan = make_pbr("c_glow_cyan", (0.30, 0.85, 1.0), 0.3, 0.0, (0.4, 0.9, 1.0), 4.5)
mat_dark = make_pbr("c_dark", (0.05, 0.05, 0.10), 0.7)
mat_marble = make_pbr("c_marble", (0.85, 0.83, 0.80), 0.4)
mat_brass = make_pbr("c_brass", (0.85, 0.65, 0.20), 0.3, 0.95)

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_opening = make_coll("Opening")
col_iter = make_coll("IterTransition")
col_first_boss = make_coll("FirstBossKill")
col_max_affinity = make_coll("MaxAffinity")
col_final_boss = make_coll("FinalBoss")
col_ending = make_coll("Ending")
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

# === Scene 1: Opening (Globbler awakening on pedestal) ===
print("=== Opening ===")
OX, OY = 0, 0
add_bm("Op_Floor", cube(8, 6, 0.1), mat_floor, col_opening, loc=(OX, OY, 0))
add_bm("Op_Pedestal", cyl(0.8, 0.4, 16), mat_pedestal, col_opening, loc=(OX, OY, 0.2))
# Globbler crouched
add_bm("Op_Body", ico(0.40, 2), mat_globbler, col_opening, loc=(OX, OY, 0.85), scale=(1, 0.8, 0.8))
add_bm("Op_Head", ico(0.30, 2), mat_skin, col_opening, loc=(OX, OY, 1.30))
# Awakening glow ring around the pedestal
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=24, radius1=1.2, radius2=1.2, depth=0.04)
add_bm("Op_GlowRing", bm, mat_glow_warm, col_opening, loc=(OX, OY, 0.42))
# 3 floating data motes overhead
for i in range(3):
    add_bm(f"Op_Mote_{i}", ico(0.08, 1), mat_glow_warm, col_opening,
           loc=(OX + math.cos(i*2.09)*0.5, OY + math.sin(i*2.09)*0.5, 1.8))

# === Scene 2: Iteration transition (portal with glitch) ===
print("=== Iteration transition ===")
IX, IY = 20, 0
add_bm("It_Floor", cube(8, 6, 0.1), mat_floor, col_iter, loc=(IX, IY, 0))
# Portal arch (2 pillars + arch)
for sx in [-1.5, 1.5]:
    add_bm(f"It_Pillar_{sx}", cyl(0.20, 4, 12), mat_dark, col_iter, loc=(IX + sx, IY, 0))
add_bm("It_Arch", cube(3.5, 0.4, 0.4), mat_dark, col_iter, loc=(IX, IY, 4.0))
# Portal disk
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=20, radius1=1.4, radius2=1.4, depth=0.1)
bmesh.ops.rotate(bm, matrix=Matrix.Rotation(math.radians(90), 3, 'X'), verts=bm.verts)
add_bm("It_Portal", bm, mat_glow_violet, col_iter, loc=(IX, IY, 2.0))
# Glitch shards floating
for i in range(8):
    ang = (i / 8) * math.tau
    add_bm(f"It_Shard_{i}", cone(0.10, 0.0, 0.30), mat_glow_violet, col_iter,
           loc=(IX + math.cos(ang)*1.8, IY + math.sin(ang)*0.5, 2.0 + math.sin(ang)*0.4))

# === Scene 3: First boss kill ===
print("=== First boss kill ===")
FX, FY = 40, 0
add_bm("Fk_Floor", cube(8, 6, 0.1), mat_floor, col_first_boss, loc=(FX, FY, 0))
# Hero standing victorious
add_bm("Fk_HeroBody", ico(0.40, 2), mat_globbler, col_first_boss, loc=(FX, FY, 1.0))
add_bm("Fk_HeroHead", ico(0.30, 2), mat_skin, col_first_boss, loc=(FX, FY, 1.55))
# Arms raised
add_bm("Fk_ArmL", cyl(0.10, 0.6, 8), mat_globbler, col_first_boss,
       loc=(FX - 0.4, FY, 1.5), rot=(0, 0, math.radians(40)))
add_bm("Fk_ArmR", cyl(0.10, 0.6, 8), mat_globbler, col_first_boss,
       loc=(FX + 0.4, FY, 1.5), rot=(0, 0, math.radians(-40)))
# Defeated boss debris on ground
for i in range(5):
    ang = (i / 5) * math.tau
    add_bm(f"Fk_Debris_{i}", ico(0.20, 1), mat_dark, col_first_boss,
           loc=(FX + math.cos(ang)*2.5, FY + math.sin(ang)*1.5, 0.20))
# Falling ash particles (8 small icospheres)
for i in range(8):
    add_bm(f"Fk_Ash_{i}", ico(0.05, 1), mat_glow_warm, col_first_boss,
           loc=(FX + (i - 4) * 0.4, FY, 2 + (i % 3) * 0.4))

# === Scene 4: Max affinity (2 figures embracing under stars) ===
print("=== Max affinity ===")
MX, MY = 60, 0
add_bm("Ma_Floor", cube(8, 6, 0.1), mat_floor, col_max_affinity, loc=(MX, MY, 0))
# 2 figures close together
add_bm("Ma_FigA_Body", ico(0.35, 2), mat_globbler, col_max_affinity, loc=(MX - 0.3, MY, 0.95))
add_bm("Ma_FigA_Head", ico(0.27, 2), mat_skin, col_max_affinity, loc=(MX - 0.3, MY, 1.50))
add_bm("Ma_FigB_Body", ico(0.35, 2), make_pbr("c_npc_red", (0.85, 0.30, 0.40), 0.5), col_max_affinity, loc=(MX + 0.3, MY, 0.95))
add_bm("Ma_FigB_Head", ico(0.27, 2), mat_skin, col_max_affinity, loc=(MX + 0.3, MY, 1.50))
# Stars in the sky (12 small spheres)
for i in range(12):
    ang = (i / 12) * math.tau
    add_bm(f"Ma_Star_{i}", ico(0.06, 1), mat_glow_warm, col_max_affinity,
           loc=(MX + math.cos(ang)*3, MY - 1.5, 2 + math.sin(ang)*1.5))
# Heart glow between them
add_bm("Ma_Heart", ico(0.15, 2), mat_glow_warm, col_max_affinity, loc=(MX, MY, 1.2))

# === Scene 5: Final boss (massive crystal entity) ===
print("=== Final boss ===")
FBX, FBY = 80, 0
add_bm("Fb_Floor", cube(8, 6, 0.1), mat_floor, col_final_boss, loc=(FBX, FBY, 0))
# Massive crystal core
add_bm("Fb_Core", ico(1.4, 4), mat_glow_violet, col_final_boss, loc=(FBX, FBY, 2.5))
# Dark frame
for i in range(8):
    ang = (i / 8) * math.tau
    add_bm(f"Fb_Frame_{i}", cube(0.10, 0.10, 1.8), mat_dark, col_final_boss,
           loc=(FBX + math.cos(ang)*1.5, FBY + math.sin(ang)*1.5, 2.5),
           rot=(0, 0, ang))
# 6 outer crystal spires
for i in range(6):
    ang = (i / 6) * math.tau
    add_bm(f"Fb_Spire_{i}", cone(0.30, 0.0, 2.5), mat_glow_violet, col_final_boss,
           loc=(FBX + math.cos(ang)*2.5, FBY + math.sin(ang)*2.5, 0))
# Crown
for i in range(8):
    ang = (i / 8) * math.tau
    add_bm(f"Fb_Crown_{i}", cone(0.12, 0.0, 0.50), mat_glow_violet, col_final_boss,
           loc=(FBX + math.cos(ang)*0.6, FBY + math.sin(ang)*0.6, 4.0))
# Tiny hero silhouette for scale
add_bm("Fb_Hero", ico(0.30, 2), mat_globbler, col_final_boss, loc=(FBX, FBY - 2.5, 0.5))

# === Scene 6: Ending (9 candles at memorial) ===
print("=== Ending ===")
EX, EY = 100, 0
add_bm("En_Floor", cube(8, 6, 0.1), mat_marble, col_ending, loc=(EX, EY, 0))
# Memorial cenotaph (obelisk)
add_bm("En_Obelisk", cone(0.30, 0.04, 3.0), mat_marble, col_ending, loc=(EX, EY + 1, 0))
# 9 candles arranged in arc
for i in range(9):
    px = EX - 2.0 + i * 0.5
    add_bm(f"En_CandleBase_{i}", cyl(0.06, 0.20, 8), mat_brass, col_ending, loc=(px, EY - 0.5, 0.10))
    add_bm(f"En_CandleWax_{i}", cyl(0.05, 0.30, 8), make_pbr(f"en_wax_{i}", (0.95, 0.92, 0.85)), col_ending, loc=(px, EY - 0.5, 0.35))
    add_bm(f"En_CandleFlame_{i}", ico(0.04, 1), mat_glow_warm, col_ending, loc=(px, EY - 0.5, 0.55))

# === Cameras ===
def add_camera(name, loc, rot, lens=50):
    cam_data = bpy.data.cameras.new(name)
    cam_data.lens = lens
    cam_data.dof.use_dof = True
    cam_data.dof.aperture_fstop = 1.4
    cam_data.dof.focus_distance = 5.0
    cam_obj = bpy.data.objects.new(name, cam_data)
    cam_obj.location = loc
    cam_obj.rotation_euler = rot
    scene.collection.objects.link(cam_obj)
    link_to(cam_obj, col_cam)
    return cam_obj

# Per-scene cinematic cameras
cams = {
    "opening": add_camera("Op_Cam", (OX + 4, OY - 6, 1.8), (math.radians(80), 0, math.radians(25)), 35),
    "iter": add_camera("It_Cam", (IX, IY - 8, 2.5), (math.radians(78), 0, 0), 35),
    "first_boss": add_camera("Fk_Cam", (FX, FY - 6, 2.0), (math.radians(78), 0, 0), 40),
    "max_affinity": add_camera("Ma_Cam", (MX, MY - 4, 1.4), (math.radians(85), 0, 0), 50),
    "final_boss": add_camera("Fb_Cam", (FBX + 4, FBY - 8, 4.0), (math.radians(75), 0, math.radians(25)), 28),
    "ending": add_camera("En_Cam", (EX, EY - 5, 1.8), (math.radians(85), 0, 0), 50),
}

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

scene_lights = {
    "opening": add_area_light("Op_Key", (OX, OY - 5, 8), (1.0, 0.85, 0.55), 1500, 8, col_lights),
    "iter": add_area_light("It_Key", (IX, IY - 5, 8), (0.85, 0.55, 1.0), 1500, 8, col_lights),
    "first_boss": add_area_light("Fk_Key", (FX, FY - 5, 8), (1.0, 0.95, 0.55), 1800, 10, col_lights),
    "max_affinity": add_area_light("Ma_Key", (MX, MY - 5, 8), (1.0, 0.85, 0.65), 1200, 10, col_lights),
    "final_boss": add_area_light("Fb_Key", (FBX, FBY - 5, 10), (0.85, 0.55, 1.0), 2000, 10, col_lights),
    "ending": add_area_light("En_Key", (EX, EY - 4, 6), (1.0, 0.85, 0.55), 800, 6, col_lights),
}

world = bpy.data.worlds.new("World_Cine")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.02, 0.02, 0.05, 1.0)
bg.inputs['Strength'].default_value = 0.3

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# === Render 6 cinematic frames ===
print("=== Rendering 6 cinematic showcase frames ===")
all_colls = {
    "opening": col_opening,
    "iter": col_iter,
    "first_boss": col_first_boss,
    "max_affinity": col_max_affinity,
    "final_boss": col_final_boss,
    "ending": col_ending,
}

for name, coll in all_colls.items():
    # Hide all other scene cols + lights
    for other_name, other_coll in all_colls.items():
        for obj in other_coll.objects:
            obj.hide_render = (other_name != name)
    for other_name, other_light in scene_lights.items():
        other_light.hide_render = (other_name != name)
    scene.camera = cams[name]
    out_path = os.path.join(RENDER_DIR, f"cinematic_showcase_{name}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

print("Cinematic showcase pipeline complete.")
