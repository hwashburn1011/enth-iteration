"""
Epic 50 — Steam Launch Assets Pipeline
=========================================
The FINAL epic. Builds every Steam-store asset in one comprehensive pass:
  - Tasks 6-9: 32 gameplay/environment/combat/NPC screenshots
  - Task 10: 4 hero screenshots for store header
  - Tasks 15-19: 16 trailer storyboard frames
  - Task 28: 5 trading cards
  - Task 29: 1 + 5 badge levels (6 badges total)
  - Task 30: 5 emoticons
  - Task 31: 3 profile backgrounds

Output:
  - _art_source/steam/steam_assets.blend
  - _art_source/steam/renders/screenshot_<category>_<n>.png (32)
  - _art_source/steam/renders/hero_<n>.png (4)
  - _art_source/steam/renders/trailer_<n>.png (16)
  - _art_source/steam/renders/card_<n>.png (5)
  - _art_source/steam/renders/badge_<level>.png (6)
  - _art_source/steam/renders/emoticon_<n>.png (5)
  - _art_source/steam/renders/profile_bg_<n>.png (3)
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/steam/steam_assets.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/steam/renders"
os.makedirs(os.path.dirname(OUTPUT_BLEND), exist_ok=True)
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32

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

# Universal palette
mat_floor = make_pbr("st_floor", (0.20, 0.20, 0.25), 0.85)
mat_wall = make_pbr("st_wall", (0.15, 0.15, 0.20), 0.9)
mat_globbler = make_pbr("st_globbler", (0.30, 0.55, 0.95), 0.5)
mat_skin = make_pbr("st_skin", (0.85, 0.75, 0.60), 0.7)
mat_glow_warm = make_pbr("st_glow_warm", (1.0, 0.85, 0.45), 0.4, 0.0, (1.0, 0.85, 0.45), 4.5)
mat_glow_cool = make_pbr("st_glow_cool", (0.40, 0.85, 1.0), 0.4, 0.0, (0.4, 0.85, 1.0), 4.0)
mat_glow_red = make_pbr("st_glow_red", (1.0, 0.30, 0.20), 0.4, 0.0, (1.0, 0.3, 0.2), 4.5)
mat_glow_violet = make_pbr("st_glow_violet", (0.75, 0.40, 1.0), 0.4, 0.0, (0.7, 0.4, 1.0), 4.5)
mat_glow_green = make_pbr("st_glow_green", (0.30, 0.95, 0.40), 0.4, 0.0, (0.4, 1.0, 0.5), 4.5)
mat_dark = make_pbr("st_dark", (0.05, 0.05, 0.10), 0.7)
mat_brass = make_pbr("st_brass", (0.85, 0.65, 0.20), 0.3, 0.95)
mat_silver = make_pbr("st_silver", (0.85, 0.85, 0.92), 0.3, 0.95)
mat_gold = make_pbr("st_gold", (1.0, 0.85, 0.30), 0.2, 1.0, (1.0, 0.85, 0.30), 1.5)
mat_grass = make_pbr("st_grass", (0.18, 0.32, 0.12), 0.85)
mat_marble = make_pbr("st_marble", (0.85, 0.83, 0.80), 0.4)
mat_npc_red = make_pbr("st_npc_red", (0.85, 0.30, 0.40), 0.5)
mat_npc_green = make_pbr("st_npc_green", (0.30, 0.65, 0.45), 0.5)
mat_npc_yellow = make_pbr("st_npc_yellow", (0.95, 0.85, 0.30), 0.5)

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_screenshots = make_coll("Screenshots")
col_hero = make_coll("Hero")
col_trailer = make_coll("Trailer")
col_cards = make_coll("Cards")
col_badges = make_coll("Badges")
col_emoticons = make_coll("Emoticons")
col_profile_bgs = make_coll("ProfileBGs")
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

# === Build a small generic scene per category ===
def build_globbler(coll, x_off, y_off, z_off=0):
    add_bm(f"glob_body_{x_off}_{y_off}", ico(0.40, 2), mat_globbler, coll,
           loc=(x_off, y_off, z_off + 1.0))
    add_bm(f"glob_head_{x_off}_{y_off}", ico(0.30, 2), mat_skin, coll,
           loc=(x_off, y_off, z_off + 1.55))

def build_npc(coll, x_off, y_off, color, z_off=0):
    add_bm(f"npc_body_{x_off}_{y_off}", ico(0.40, 2), color, coll,
           loc=(x_off, y_off, z_off + 1.0))
    add_bm(f"npc_head_{x_off}_{y_off}", ico(0.30, 2), mat_skin, coll,
           loc=(x_off, y_off, z_off + 1.55))

# === SCREENSHOTS: 32 total ===
print("=== Building screenshot scenes ===")
# Each category gets 8 mini-scenes laid out in a grid

# 8 gameplay screenshots: Globbler with combat
for i in range(8):
    pos_x = (i % 4) * 6 - 9
    pos_y = (i // 4) * 6 - 30
    add_bm(f"sc_gameplay_floor_{i}", cube(3, 3, 0.1), mat_floor, col_screenshots, loc=(pos_x, pos_y, 0))
    build_globbler(col_screenshots, pos_x, pos_y)
    # Mid-combat ability
    add_bm(f"sc_gameplay_glow_{i}", ico(0.30, 2), mat_glow_warm, col_screenshots,
           loc=(pos_x + 1.5, pos_y - 0.5, 1.2))

# 8 environment screenshots: small biome dioramas
biomes = [
    (mat_grass, mat_glow_green),
    (mat_floor, mat_glow_cool),  # server room
    (mat_marble, mat_glow_warm),  # memory vaults
    (mat_grass, mat_glow_violet),  # corrupted wilds
    (mat_marble, mat_glow_warm),  # boss sanctum
    (mat_grass, mat_glow_cool),  # wilderness
    (mat_grass, mat_glow_warm),  # town
    (mat_dark, mat_glow_red),  # dungeon
]
for i in range(8):
    pos_x = (i % 4) * 6 - 9
    pos_y = (i // 4) * 6 - 12
    floor_mat, accent_mat = biomes[i]
    add_bm(f"sc_env_floor_{i}", cube(3, 3, 0.1), floor_mat, col_screenshots, loc=(pos_x, pos_y, 0))
    # 3 random props
    for j in range(3):
        ang = j * 2.09
        add_bm(f"sc_env_prop_{i}_{j}", cyl(0.20, 1.2, 8), mat_dark, col_screenshots,
               loc=(pos_x + math.cos(ang)*1, pos_y + math.sin(ang)*1, 0.6))
        add_bm(f"sc_env_glow_{i}_{j}", ico(0.15, 2), accent_mat, col_screenshots,
               loc=(pos_x + math.cos(ang)*1, pos_y + math.sin(ang)*1, 1.4))

# 8 combat screenshots: Globbler vs enemy
for i in range(8):
    pos_x = (i % 4) * 6 - 9
    pos_y = (i // 4) * 6 + 6
    add_bm(f"sc_combat_floor_{i}", cube(3, 3, 0.1), mat_floor, col_screenshots, loc=(pos_x, pos_y, 0))
    build_globbler(col_screenshots, pos_x - 0.7, pos_y)
    # Enemy
    add_bm(f"sc_combat_enemy_body_{i}", ico(0.40, 2), mat_npc_red, col_screenshots,
           loc=(pos_x + 0.7, pos_y, 1.0))
    add_bm(f"sc_combat_enemy_eye_{i}", ico(0.06, 1), mat_glow_red, col_screenshots,
           loc=(pos_x + 0.7, pos_y - 0.30, 1.55))
    # VFX between them
    add_bm(f"sc_combat_vfx_{i}", ico(0.20, 2), mat_glow_warm, col_screenshots,
           loc=(pos_x, pos_y, 1.2))

# 8 NPC screenshots
npc_colors = [mat_npc_red, mat_npc_green, mat_npc_yellow, mat_globbler] * 2
for i in range(8):
    pos_x = (i % 4) * 6 - 9
    pos_y = (i // 4) * 6 + 24
    add_bm(f"sc_npc_floor_{i}", cube(3, 3, 0.1), mat_marble, col_screenshots, loc=(pos_x, pos_y, 0))
    build_npc(col_screenshots, pos_x, pos_y, npc_colors[i])

# === HERO SCREENSHOTS (4) — bigger, more cinematic ===
print("=== Hero screenshots ===")
hero_scenes = [
    ("hero_combat", mat_npc_red, mat_glow_warm),
    ("hero_explore", mat_globbler, mat_glow_cool),
    ("hero_npc", mat_npc_yellow, mat_glow_violet),
    ("hero_boss", mat_dark, mat_glow_red),
]
for i, (name, fig_mat, accent_mat) in enumerate(hero_scenes):
    pos_x = i * 12 + 30
    pos_y = -30
    add_bm(f"{name}_floor", cube(8, 6, 0.1), mat_floor, col_hero, loc=(pos_x, pos_y, 0))
    # Globbler
    add_bm(f"{name}_glob_body", ico(0.40, 2), mat_globbler, col_hero, loc=(pos_x - 1.5, pos_y, 1.0))
    add_bm(f"{name}_glob_head", ico(0.30, 2), mat_skin, col_hero, loc=(pos_x - 1.5, pos_y, 1.55))
    # Other figure
    add_bm(f"{name}_other_body", ico(0.45, 2), fig_mat, col_hero, loc=(pos_x + 1.5, pos_y, 1.1))
    add_bm(f"{name}_other_eye", ico(0.06, 1), accent_mat, col_hero, loc=(pos_x + 1.5, pos_y - 0.35, 1.65))
    # Big VFX in center
    add_bm(f"{name}_vfx_core", ico(0.40, 2), accent_mat, col_hero, loc=(pos_x, pos_y, 1.5))
    # 4 backdrop pillars
    for j in range(4):
        ang = (j / 4) * math.tau + 0.785
        add_bm(f"{name}_pillar_{j}", cyl(0.30, 4, 12), mat_dark, col_hero,
               loc=(pos_x + math.cos(ang)*3.5, pos_y + math.sin(ang)*2, 0))

# === TRAILER (16 frames) ===
print("=== Trailer storyboard ===")
trailer_frames = []
for i in range(16):
    pos_x = (i % 4) * 8 + 80
    pos_y = (i // 4) * 8 - 16
    add_bm(f"trailer_floor_{i}", cube(4, 4, 0.1), mat_floor, col_trailer, loc=(pos_x, pos_y, 0))
    # Hero in different poses
    if i < 4:
        # Awakening shots
        build_globbler(col_trailer, pos_x, pos_y)
        add_bm(f"trailer_pedestal_{i}", cyl(0.6, 0.3, 16), mat_marble, col_trailer, loc=(pos_x, pos_y, 0.15))
    elif i < 8:
        # Combat shots
        build_globbler(col_trailer, pos_x - 0.5, pos_y)
        add_bm(f"trailer_enemy_{i}", ico(0.40, 2), mat_npc_red, col_trailer, loc=(pos_x + 0.7, pos_y, 1.0))
        add_bm(f"trailer_vfx_{i}", ico(0.30, 2), mat_glow_warm, col_trailer, loc=(pos_x, pos_y, 1.3))
    elif i < 12:
        # Boss reveal shots
        add_bm(f"trailer_boss_{i}", ico(1.0, 3), mat_glow_violet, col_trailer, loc=(pos_x, pos_y, 1.5))
        for j in range(6):
            ang = (j / 6) * math.tau
            add_bm(f"trailer_boss_spire_{i}_{j}", cone(0.20, 0.0, 1.5), mat_dark, col_trailer,
                   loc=(pos_x + math.cos(ang)*1.5, pos_y + math.sin(ang)*1.5, 0))
    else:
        # Title card / final shots
        add_bm(f"trailer_titlebg_{i}", cube(3, 0.1, 1.5), mat_dark, col_trailer, loc=(pos_x, pos_y + 1, 1.5))
        add_bm(f"trailer_titlefg_{i}", cube(2.8, 0.05, 1.3), mat_glow_warm, col_trailer, loc=(pos_x, pos_y + 0.95, 1.5))
        build_globbler(col_trailer, pos_x, pos_y - 1)

# === TRADING CARDS (5) — small framed icons ===
print("=== Trading cards ===")
card_themes = [
    ("globbler", mat_globbler, mat_glow_cool),
    ("compiler", mat_dark, mat_glow_violet),
    ("forge", mat_npc_red, mat_glow_warm),
    ("memorial", mat_marble, mat_glow_warm),
    ("crystal", mat_glow_violet, mat_glow_violet),
]
for i, (name, fig_mat, accent_mat) in enumerate(card_themes):
    pos_x = i * 2.5 - 5
    pos_y = 35
    # Card frame
    add_bm(f"card_{name}_frame", cube(0.9, 0.05, 1.4), mat_dark, col_cards, loc=(pos_x, pos_y, 0.7))
    # Card inner
    add_bm(f"card_{name}_inner", cube(0.85, 0.06, 1.35), accent_mat, col_cards, loc=(pos_x, pos_y, 0.7))
    # Hero figure on card
    add_bm(f"card_{name}_fig", ico(0.20, 2), fig_mat, col_cards, loc=(pos_x, pos_y - 0.06, 0.85))
    # Title strip at bottom
    add_bm(f"card_{name}_title", cube(0.85, 0.06, 0.20), mat_dark, col_cards, loc=(pos_x, pos_y - 0.07, 0.20))

# === BADGES (1 + 5 levels) ===
print("=== Badges ===")
badge_levels = [
    ("base", mat_silver, 0.6),
    ("lv1", mat_silver, 0.7),
    ("lv2", mat_brass, 0.8),
    ("lv3", mat_gold, 0.9),
    ("lv4", mat_glow_warm, 1.0),
    ("lv5", mat_glow_violet, 1.2),
]
for i, (name, mat, glow_scale) in enumerate(badge_levels):
    pos_x = i * 2 - 5
    pos_y = 42
    # Badge backing
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=24, radius1=0.5 * glow_scale, radius2=0.5 * glow_scale, depth=0.05)
    add_bm(f"badge_{name}_disc", bm, mat, col_badges, loc=(pos_x, pos_y, 0))
    # Inner glow
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=24, radius1=0.40 * glow_scale, radius2=0.40 * glow_scale, depth=0.06)
    add_bm(f"badge_{name}_inner", bm, mat_glow_warm, col_badges, loc=(pos_x, pos_y, 0.005))
    # Center symbol (Globbler silhouette)
    add_bm(f"badge_{name}_sym", ico(0.16 * glow_scale, 2), mat_dark, col_badges, loc=(pos_x, pos_y + 0.06, 0))

# === EMOTICONS (5) — small expressive faces ===
print("=== Emoticons ===")
emoticon_data = [
    ("happy", mat_glow_warm),
    ("sad", mat_glow_cool),
    ("angry", mat_glow_red),
    ("surprised", mat_glow_violet),
    ("love", mat_glow_warm),
]
for i, (name, mat) in enumerate(emoticon_data):
    pos_x = i * 1.5 - 3
    pos_y = 47
    # Round face
    add_bm(f"emote_{name}_face", ico(0.28, 2), mat, col_emoticons, loc=(pos_x, pos_y, 0))
    # 2 eyes
    add_bm(f"emote_{name}_eye_l", ico(0.04, 1), mat_dark, col_emoticons, loc=(pos_x - 0.10, pos_y - 0.25, 0.05))
    add_bm(f"emote_{name}_eye_r", ico(0.04, 1), mat_dark, col_emoticons, loc=(pos_x + 0.10, pos_y - 0.25, 0.05))
    # Mouth (happy = ico, sad = inverted ico, etc.)
    add_bm(f"emote_{name}_mouth", ico(0.06, 1), mat_dark, col_emoticons, loc=(pos_x, pos_y - 0.27, -0.05))

# === PROFILE BACKGROUNDS (3) — wide cinematic plates ===
print("=== Profile backgrounds ===")
bg_themes = [
    ("town", mat_glow_warm, mat_marble),
    ("dungeon", mat_glow_cool, mat_dark),
    ("boss", mat_glow_violet, mat_dark),
]
for i, (name, accent_mat, base_mat) in enumerate(bg_themes):
    pos_x = i * 8 - 8
    pos_y = 56
    # Wide backdrop
    add_bm(f"bg_{name}_plate", cube(6, 0.05, 3), base_mat, col_profile_bgs, loc=(pos_x, pos_y + 1, 1.5))
    # Globbler silhouette in front
    add_bm(f"bg_{name}_glob_body", ico(0.50, 2), mat_globbler, col_profile_bgs, loc=(pos_x, pos_y, 1.2))
    add_bm(f"bg_{name}_glob_head", ico(0.38, 2), mat_skin, col_profile_bgs, loc=(pos_x, pos_y, 1.85))
    # 5 accent glows in background
    for j in range(5):
        add_bm(f"bg_{name}_glow_{j}", ico(0.20, 2), accent_mat, col_profile_bgs,
               loc=(pos_x - 2 + j, pos_y + 0.95, 1.3 + (j % 2) * 0.4))

# === Cameras ===
def add_camera(name, loc, rot, lens=50):
    cam_data = bpy.data.cameras.new(name)
    cam_data.lens = lens
    cam_obj = bpy.data.objects.new(name, cam_data)
    cam_obj.location = loc
    cam_obj.rotation_euler = rot
    scene.collection.objects.link(cam_obj)
    link_to(cam_obj, col_cam)
    return cam_obj

icon_cam = add_camera("Icon_Cam", (0, -3, 0), (math.radians(85), 0, 0), 70)
hero_cam = add_camera("Hero_Cam", (0, -10, 4), (math.radians(78), 0, 0), 35)

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

key_light = add_area_light("Key", (0, -10, 12), (1.0, 0.95, 0.85), 1500, 12, col_lights)
fill_light = add_area_light("Fill", (0, 5, 8), (0.65, 0.78, 1.0), 600, 14, col_lights)

world = bpy.data.worlds.new("World_Steam")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.04, 0.05, 0.10, 1.0)
bg.inputs['Strength'].default_value = 0.4

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# === Render screenshots (1280x720) ===
print("=== Rendering screenshots ===")
scene.render.resolution_x = 1280
scene.render.resolution_y = 720
scene.render.film_transparent = False

# Helper to render a scene cell
def render_cell(category: str, idx: int, base_x: float, base_y: float, out_filename: str):
    scene.camera = icon_cam
    icon_cam.location = (base_x, base_y - 5, 2.0)
    icon_cam.rotation_euler = (math.radians(78), 0, 0)
    scene.render.filepath = os.path.join(RENDER_DIR, out_filename)
    bpy.ops.render.render(write_still=True)

# Hide everything not currently being rendered
def hide_all_except(visible_coll):
    for col in [col_screenshots, col_hero, col_trailer, col_cards, col_badges,
                col_emoticons, col_profile_bgs]:
        for obj in col.objects:
            obj.hide_render = (col != visible_coll)

# Gameplay screenshots (8)
hide_all_except(col_screenshots)
for i in range(8):
    pos_x = (i % 4) * 6 - 9
    pos_y = (i // 4) * 6 - 30
    render_cell("gameplay", i, pos_x, pos_y, f"screenshot_gameplay_{i}.png")

# Environment screenshots (8)
for i in range(8):
    pos_x = (i % 4) * 6 - 9
    pos_y = (i // 4) * 6 - 12
    render_cell("env", i, pos_x, pos_y, f"screenshot_environment_{i}.png")

# Combat screenshots (8)
for i in range(8):
    pos_x = (i % 4) * 6 - 9
    pos_y = (i // 4) * 6 + 6
    render_cell("combat", i, pos_x, pos_y, f"screenshot_combat_{i}.png")

# NPC screenshots (8)
for i in range(8):
    pos_x = (i % 4) * 6 - 9
    pos_y = (i // 4) * 6 + 24
    render_cell("npc", i, pos_x, pos_y, f"screenshot_npc_{i}.png")

# === Hero screenshots (4) — bigger ===
print("=== Hero shots ===")
hide_all_except(col_hero)
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
for i in range(4):
    pos_x = i * 12 + 30
    pos_y = -30
    scene.camera = hero_cam
    hero_cam.location = (pos_x + 4, pos_y - 10, 4)
    hero_cam.rotation_euler = (math.radians(75), 0, math.radians(20))
    scene.render.filepath = os.path.join(RENDER_DIR, f"hero_{i+1}.png")
    bpy.ops.render.render(write_still=True)

# === Trailer storyboard frames (16) ===
print("=== Trailer frames ===")
hide_all_except(col_trailer)
scene.render.resolution_x = 1920
scene.render.resolution_y = 800  # cinematic
for i in range(16):
    pos_x = (i % 4) * 8 + 80
    pos_y = (i // 4) * 8 - 16
    hero_cam.location = (pos_x + 3, pos_y - 7, 3.5)
    hero_cam.rotation_euler = (math.radians(78), 0, math.radians(20))
    scene.camera = hero_cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"trailer_%02d.png" % (i+1))
    bpy.ops.render.render(write_still=True)

# === Cards (5) — vertical 184x252 (Steam trading card aspect) ===
print("=== Cards ===")
hide_all_except(col_cards)
scene.render.resolution_x = 460
scene.render.resolution_y = 630
scene.render.film_transparent = True
for i, (name, _, _) in enumerate(card_themes):
    pos_x = i * 2.5 - 5
    pos_y = 35
    icon_cam.location = (pos_x, pos_y - 1.8, 0.6)
    icon_cam.rotation_euler = (math.radians(85), 0, 0)
    scene.camera = icon_cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"card_{name}.png")
    bpy.ops.render.render(write_still=True)

# === Badges (6) — square 256x256 ===
print("=== Badges ===")
hide_all_except(col_badges)
scene.render.resolution_x = 256
scene.render.resolution_y = 256
for i, (name, _, _) in enumerate(badge_levels):
    pos_x = i * 2 - 5
    pos_y = 42
    icon_cam.location = (pos_x, pos_y - 1.4, 0.0)
    icon_cam.rotation_euler = (math.radians(85), 0, 0)
    scene.camera = icon_cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"badge_{name}.png")
    bpy.ops.render.render(write_still=True)

# === Emoticons (5) — small 64x64 ===
print("=== Emoticons ===")
hide_all_except(col_emoticons)
scene.render.resolution_x = 64
scene.render.resolution_y = 64
for i, (name, _) in enumerate(emoticon_data):
    pos_x = i * 1.5 - 3
    pos_y = 47
    icon_cam.location = (pos_x, pos_y - 1.0, 0.0)
    icon_cam.rotation_euler = (math.radians(85), 0, 0)
    scene.camera = icon_cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"emoticon_{name}.png")
    bpy.ops.render.render(write_still=True)

# === Profile backgrounds (3) — wide 1920x620 (Steam profile bg aspect) ===
print("=== Profile backgrounds ===")
hide_all_except(col_profile_bgs)
scene.render.resolution_x = 1920
scene.render.resolution_y = 620
scene.render.film_transparent = False
for i, (name, _, _) in enumerate(bg_themes):
    pos_x = i * 8 - 8
    pos_y = 56
    hero_cam.location = (pos_x, pos_y - 5, 2)
    hero_cam.rotation_euler = (math.radians(85), 0, 0)
    scene.camera = hero_cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"profile_bg_{name}.png")
    bpy.ops.render.render(write_still=True)

print("Steam launch assets pipeline complete.")
