"""
Epic 28 — World Map Art Pipeline
=================================
Builds the hand-drawn style world map assets:
 - Task 2: Hand-drawn map style reference (parchment + ink lines)
 - Task 3: World map background art — top-down render of biome shapes
 - Task 18: Hand-drawn landmark icons (10 unique icons)
 - Task 19: Region name typography (text meshes with ink styling)
 - Task 20: Animated map elements (waving flag armature + smoke puff meshes)
 - Task 39: Polish map illustration art (final composition)
 - Task 45: Hero shot render of full discovered map

Saves:
  - _art_source/world/world_map.blend
  - _art_source/world/renders/world_map_full.png
  - _art_source/world/renders/world_map_hero.png
  - _art_source/world/renders/world_map_icon_<name>.png (10 icons)
"""
import bpy, bmesh, math, os, random
from mathutils import Vector, Matrix

random.seed(2828)
OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/world_map.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/renders"
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 64
scene.render.film_transparent = False

def make_pbr(name, base, rough=0.7, metal=0.0, emit=None, emit_strength=0.0, alpha=1.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes['Principled BSDF']
    bsdf.inputs['Base Color'].default_value = (*base, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Metallic'].default_value = metal
    if 'Alpha' in bsdf.inputs:
        bsdf.inputs['Alpha'].default_value = alpha
    if emit is not None:
        bsdf.inputs['Emission Color'].default_value = (*emit, 1.0)
        bsdf.inputs['Emission Strength'].default_value = emit_strength
    if alpha < 1.0:
        m.blend_method = 'BLEND'
    return m

# Parchment palette (hand-drawn map feel)
mat_parchment = make_pbr("map_parchment", (0.88, 0.78, 0.58), 0.95)
mat_parchment_edge = make_pbr("map_parchment_edge", (0.65, 0.48, 0.25), 0.9)
mat_ink = make_pbr("map_ink", (0.15, 0.08, 0.04), 0.85)
mat_ink_glow = make_pbr("map_ink_glow", (0.18, 0.10, 0.04), 0.6, 0.0, (0.4, 0.25, 0.1), 0.3)

# Region colors (muted watercolor)
mat_region_town = make_pbr("map_region_town", (0.78, 0.68, 0.42), 0.9)
mat_region_wild = make_pbr("map_region_wild", (0.48, 0.60, 0.32), 0.9)
mat_region_forest = make_pbr("map_region_forest", (0.30, 0.50, 0.28), 0.9)
mat_region_tundra = make_pbr("map_region_tundra", (0.70, 0.78, 0.85), 0.9)
mat_region_server = make_pbr("map_region_server", (0.35, 0.45, 0.65), 0.8, 0.0, (0.2, 0.4, 0.8), 0.2)
mat_region_memory = make_pbr("map_region_memory", (0.72, 0.58, 0.22), 0.7, 0.0, (0.9, 0.7, 0.2), 0.15)
mat_region_wilds = make_pbr("map_region_wilds", (0.25, 0.45, 0.22), 0.9)
mat_region_sanctum = make_pbr("map_region_sanctum", (0.28, 0.12, 0.35), 0.8, 0.0, (0.5, 0.2, 0.7), 0.2)

# Water
mat_water = make_pbr("map_water", (0.45, 0.58, 0.78), 0.5, 0.0, (0.3, 0.45, 0.7), 0.3)
mat_mountain = make_pbr("map_mountain", (0.55, 0.50, 0.45), 0.85)

# Icons
mat_icon_gold = make_pbr("map_icon_gold", (0.85, 0.68, 0.22), 0.3, 0.9, (0.95, 0.75, 0.3), 0.4)
mat_icon_red = make_pbr("map_icon_red", (0.75, 0.18, 0.15), 0.7, 0.0, (0.9, 0.3, 0.2), 0.3)
mat_flag_cloth = make_pbr("map_flag_cloth", (0.72, 0.22, 0.15), 0.85)
mat_smoke = make_pbr("map_smoke", (0.75, 0.78, 0.80), 0.95, 0.0, None, 0.0, 0.45)

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_parchment = make_coll("Map_Parchment")
col_regions = make_coll("Map_Regions")
col_ink = make_coll("Map_InkLines")
col_icons = make_coll("Map_Icons")
col_typography = make_coll("Map_Typography")
col_animated = make_coll("Map_Animated")
col_cam = make_coll("Map_Cameras")
col_lights = make_coll("Map_Lights")

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

# ==================== Parchment Base ====================
print("=== Parchment ===")
# Large hexagonal parchment (hand-drawn feel)
bm = bmesh.new()
bmesh.ops.create_circle(bm, segments=40, radius=12.0, cap_ends=True, cap_tris=True)
# Wobble the edge for organic feel
for v in bm.verts:
    if abs(v.co.x) > 11 or abs(v.co.y) > 11:
        v.co.x += random.uniform(-0.3, 0.3)
        v.co.y += random.uniform(-0.3, 0.3)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
add_bm("Map_ParchmentBase", bm, mat_parchment, col_parchment, loc=(0, 0, 0))

# Parchment edge (darker ring)
bm = bmesh.new()
bmesh.ops.create_circle(bm, segments=40, radius=12.2, cap_ends=False)
bmesh.ops.create_circle(bm, segments=40, radius=11.7, cap_ends=False)
bm.verts.ensure_lookup_table()
outer = bm.verts[:40]
inner = bm.verts[40:80]
for i in range(40):
    bm.faces.new([outer[i], outer[(i+1)%40], inner[(i+1)%40], inner[i]])
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
add_bm("Map_ParchmentEdge", bm, mat_parchment_edge, col_parchment, loc=(0, 0, 0.02))

# ==================== Regions (hand-drawn blob shapes) ====================
print("=== Regions ===")
REGIONS = [
    ("Town_Central", mat_region_town, (-2, 3), 2.8, 10),
    ("Wild_Plains", mat_region_wild, (3, 2), 3.2, 12),
    ("Deep_Forest", mat_region_forest, (-5, -3), 2.5, 11),
    ("Frozen_Tundra", mat_region_tundra, (6, -4), 2.3, 10),
    ("Server_Room_Zone", mat_region_server, (-8, 5), 1.8, 9),
    ("Memory_Vaults_Zone", mat_region_memory, (8, 5), 1.8, 9),
    ("Corrupted_Wilds", mat_region_wilds, (-6, -7), 2.2, 11),
    ("Boss_Sanctum", mat_region_sanctum, (7, -7), 1.6, 9),
]

for name, mat, (cx, cy), radius, segs in REGIONS:
    bm = bmesh.new()
    # Irregular blob: sample radius with noise
    verts_list = []
    for i in range(segs):
        ang = (i / segs) * math.tau
        r = radius * (0.85 + random.uniform(0, 0.3))
        verts_list.append(bm.verts.new((math.cos(ang)*r, math.sin(ang)*r, 0)))
    # Create face
    bm.faces.new(verts_list)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    add_bm(f"Region_{name}", bm, mat, col_regions, loc=(cx, cy, 0.05))

# Water body (lake)
bm = bmesh.new()
verts_list = []
for i in range(14):
    ang = (i / 14) * math.tau
    r = 2.0 * (0.85 + random.uniform(0, 0.25))
    verts_list.append(bm.verts.new((math.cos(ang)*r, math.sin(ang)*r, 0)))
bm.faces.new(verts_list)
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
add_bm("Region_Lake", bm, mat_water, col_regions, loc=(0, -2, 0.06))

# ==================== Ink Lines (borders, rivers, paths) ====================
print("=== Ink Lines ===")
# Coastal outline around all regions — approximated with thin cylinders
def add_ink_line(name, points, thickness=0.04):
    for i in range(len(points)-1):
        p1, p2 = points[i], points[i+1]
        dx, dy = p2[0]-p1[0], p2[1]-p1[1]
        length = math.sqrt(dx*dx + dy*dy)
        ang = math.atan2(dy, dx)
        cx, cy = (p1[0]+p2[0])/2, (p1[1]+p2[1])/2
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        bmesh.ops.scale(bm, vec=(length/2, thickness, thickness), verts=bm.verts)
        add_bm(f"Ink_{name}_{i}", bm, mat_ink, col_ink,
               loc=(cx, cy, 0.15), rot=(0, 0, ang))

# River path
river_pts = [(-10, -8), (-7, -5), (-3, -2), (1, 0), (5, 2), (9, 4), (11, 6)]
add_ink_line("River", river_pts, thickness=0.07)

# Road from town to wilds
road_pts = [(-2, 3), (0, 1), (2, -2), (5, -4), (7, -5)]
add_ink_line("Road_Main", road_pts, thickness=0.04)

# Path to server room
add_ink_line("Road_Server", [(-2, 3), (-5, 4), (-8, 5)], thickness=0.04)

# Path to memory
add_ink_line("Road_Memory", [(-2, 3), (3, 4), (8, 5)], thickness=0.04)

# Mountain ridge ink marks
mountain_pts = [(-8, 8), (-6, 9), (-4, 8.5), (-2, 9)]
for (mx, my) in mountain_pts:
    bm = bmesh.new()
    # Caret shape
    v1 = bm.verts.new((-0.3, 0, 0))
    v2 = bm.verts.new((0, 0.3, 0))
    v3 = bm.verts.new((0.3, 0, 0))
    v4 = bm.verts.new((0, 0.05, 0))
    bm.faces.new([v1, v2, v3, v4])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    add_bm(f"Ink_Mountain_{mx}_{my}", bm, mat_ink, col_ink, loc=(mx, my, 0.12))

# ==================== Icons (hand-drawn style landmarks) ====================
print("=== Icons ===")
ICONS = [
    ("town_tower", (-2, 3), "tower"),
    ("forest_tree", (-5, -3), "tree"),
    ("skull", (7, -7), "skull"),
    ("vault_chest", (8, 5), "chest"),
    ("server_diamond", (-8, 5), "diamond"),
    ("dock_anchor", (0, -2.5), "anchor"),
    ("shrine_obelisk", (3, 2), "obelisk"),
    ("cave_arch", (-6, -7), "arch"),
    ("mountain_peak", (-6, 9), "peak"),
    ("flame_altar", (6, -4), "flame"),
]

def icon_tower(loc):
    bm = bmesh.new()
    # tower body
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.2, 0.2, 0.5), verts=bm.verts)
    bmesh.ops.translate(bm, vec=(0,0,0.25), verts=bm.verts)
    # battlements (top)
    tmp = bmesh.new()
    bmesh.ops.create_cube(tmp, size=1.0)
    bmesh.ops.scale(tmp, vec=(0.25, 0.25, 0.1), verts=tmp.verts)
    bmesh.ops.translate(tmp, vec=(0,0,0.55), verts=tmp.verts)
    me = bpy.data.meshes.new("_tmp"); tmp.to_mesh(me); tmp.free()
    bm.from_mesh(me); bpy.data.meshes.remove(me)
    return bm

def icon_tree(loc):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=8, radius1=0.3, radius2=0.0, depth=0.6)
    bmesh.ops.translate(bm, vec=(0,0,0.3), verts=bm.verts)
    return bm

def icon_skull(loc):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.28)
    bmesh.ops.translate(bm, vec=(0,0,0.28), verts=bm.verts)
    return bm

def icon_chest(loc):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.35, 0.25, 0.2), verts=bm.verts)
    bmesh.ops.translate(bm, vec=(0,0,0.2), verts=bm.verts)
    return bm

def icon_diamond(loc):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=1, radius=0.3)
    bmesh.ops.scale(bm, vec=(0.8, 0.8, 1.2), verts=bm.verts)
    bmesh.ops.translate(bm, vec=(0,0,0.3), verts=bm.verts)
    return bm

def icon_anchor(loc):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.05, 0.05, 0.35), verts=bm.verts)
    bmesh.ops.translate(bm, vec=(0,0,0.175), verts=bm.verts)
    # crossbar
    tmp = bmesh.new()
    bmesh.ops.create_cube(tmp, size=1.0)
    bmesh.ops.scale(tmp, vec=(0.3, 0.05, 0.05), verts=tmp.verts)
    bmesh.ops.translate(tmp, vec=(0,0,0.3), verts=tmp.verts)
    me = bpy.data.meshes.new("_tmp"); tmp.to_mesh(me); tmp.free()
    bm.from_mesh(me); bpy.data.meshes.remove(me)
    return bm

def icon_obelisk(loc):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=4, radius1=0.2, radius2=0.05, depth=0.7)
    bmesh.ops.translate(bm, vec=(0,0,0.35), verts=bm.verts)
    return bm

def icon_arch(loc):
    bm = bmesh.new()
    # Two verticals + top
    for x in [-0.15, 0.15]:
        tmp = bmesh.new()
        bmesh.ops.create_cube(tmp, size=1.0)
        bmesh.ops.scale(tmp, vec=(0.05, 0.1, 0.35), verts=tmp.verts)
        bmesh.ops.translate(tmp, vec=(x,0,0.175), verts=tmp.verts)
        me = bpy.data.meshes.new("_tmp"); tmp.to_mesh(me); tmp.free()
        bm.from_mesh(me); bpy.data.meshes.remove(me)
    tmp = bmesh.new()
    bmesh.ops.create_cube(tmp, size=1.0)
    bmesh.ops.scale(tmp, vec=(0.25, 0.1, 0.05), verts=tmp.verts)
    bmesh.ops.translate(tmp, vec=(0,0,0.38), verts=tmp.verts)
    me = bpy.data.meshes.new("_tmp"); tmp.to_mesh(me); tmp.free()
    bm.from_mesh(me); bpy.data.meshes.remove(me)
    return bm

def icon_peak(loc):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=4, radius1=0.4, radius2=0.0, depth=0.55)
    bmesh.ops.translate(bm, vec=(0,0,0.275), verts=bm.verts)
    return bm

def icon_flame(loc):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.18)
    bmesh.ops.scale(bm, vec=(0.8, 0.8, 1.4), verts=bm.verts)
    bmesh.ops.translate(bm, vec=(0,0,0.25), verts=bm.verts)
    return bm

ICON_BUILDERS = {
    "tower": (icon_tower, mat_ink),
    "tree": (icon_tree, mat_region_forest),
    "skull": (icon_skull, mat_ink),
    "chest": (icon_chest, mat_icon_gold),
    "diamond": (icon_diamond, mat_region_server),
    "anchor": (icon_anchor, mat_ink),
    "obelisk": (icon_obelisk, mat_ink),
    "arch": (icon_arch, mat_ink),
    "peak": (icon_peak, mat_mountain),
    "flame": (icon_flame, mat_icon_red),
}

for icon_id, (px, py), kind in ICONS:
    builder, mat = ICON_BUILDERS[kind]
    bm = builder((px, py))
    add_bm(f"Icon_{icon_id}", bm, mat, col_icons, loc=(px, py, 0.18))

# ==================== Typography (region name pedestals) ====================
print("=== Typography ===")
REGION_LABELS = [
    ("TOWN", (-2, 5.5)),
    ("WILDS", (3, 4.3)),
    ("FOREST", (-5, -1)),
    ("TUNDRA", (6, -2)),
    ("LAKE", (0, -2)),
]
for label, (tx, ty) in REGION_LABELS:
    # Create actual Text object
    text_curve = bpy.data.curves.new(type='FONT', name=f"Text_{label}")
    text_curve.body = label
    text_curve.size = 0.4
    text_curve.extrude = 0.03
    text_obj = bpy.data.objects.new(f"Text_{label}", text_curve)
    text_obj.location = (tx - 0.5*len(label)*0.15, ty, 0.15)
    text_obj.rotation_euler = (0, 0, 0)
    text_obj.data.materials.append(mat_ink)
    scene.collection.objects.link(text_obj)
    link_to(text_obj, col_typography)

# ==================== Animated Map Elements ====================
print("=== Animated Elements ===")
# Waving flag on town tower
flag_loc = (-2, 3.2, 0.65)
# Pole
bm = bmesh.new()
bmesh.ops.create_cone(bm, segments=6, radius1=0.025, radius2=0.025, depth=0.45)
bmesh.ops.translate(bm, vec=(0,0,0.225), verts=bm.verts)
add_bm("Anim_FlagPole", bm, mat_ink, col_animated, loc=flag_loc)
# Flag cloth (rectangle)
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
bmesh.ops.scale(bm, vec=(0.22, 0.01, 0.12), verts=bm.verts)
add_bm("Anim_FlagCloth", bm, mat_flag_cloth, col_animated,
       loc=(flag_loc[0] + 0.22, flag_loc[1], flag_loc[2] + 0.35))

# Smoke puffs rising from forge icon
smoke_loc = (-2, 3, 0.6)
for i in range(5):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.08 + i*0.03)
    add_bm(f"Anim_Smoke_{i}", bm, mat_smoke, col_animated,
           loc=(smoke_loc[0] + 0.15, smoke_loc[1], smoke_loc[2] + 0.2 + i*0.15))

# Smoke above boss sanctum
for i in range(4):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.1 + i*0.04)
    add_bm(f"Anim_Smoke_Sanctum_{i}", bm, mat_smoke, col_animated,
           loc=(7, -7 + 0.1, 0.5 + i*0.18))

# ==================== Camera + Light ====================
print("=== Camera / Lighting ===")
# Top-down camera
cam_data = bpy.data.cameras.new("Map_TopCam")
cam_data.lens = 50
cam_obj = bpy.data.objects.new("Map_TopCam", cam_data)
cam_obj.location = (0, 0, 18)
cam_obj.rotation_euler = (0, 0, 0)
scene.collection.objects.link(cam_obj)
link_to(cam_obj, col_cam)
scene.camera = cam_obj

# Hero shot camera (3/4 angle)
hero_cam = bpy.data.cameras.new("Map_HeroCam")
hero_cam.lens = 50
hero_cam_obj = bpy.data.objects.new("Map_HeroCam", hero_cam)
hero_cam_obj.location = (0, -18, 14)
hero_cam_obj.rotation_euler = (math.radians(55), 0, 0)
scene.collection.objects.link(hero_cam_obj)
link_to(hero_cam_obj, col_cam)

# Area light from above
light_data = bpy.data.lights.new("Map_Key", type='AREA')
light_data.energy = 1500
light_data.size = 20
light_data.color = (1.0, 0.95, 0.85)
light_obj = bpy.data.objects.new("Map_Key", light_data)
light_obj.location = (0, 0, 15)
light_obj.rotation_euler = (0, 0, 0)
scene.collection.objects.link(light_obj)
link_to(light_obj, col_lights)

# Rim light for depth
rim_data = bpy.data.lights.new("Map_Rim", type='AREA')
rim_data.energy = 400
rim_data.size = 15
rim_data.color = (0.85, 0.70, 0.45)
rim_obj = bpy.data.objects.new("Map_Rim", rim_data)
rim_obj.location = (-8, -8, 10)
rim_obj.rotation_euler = (math.radians(30), math.radians(25), 0)
scene.collection.objects.link(rim_obj)
link_to(rim_obj, col_lights)

# World background (soft beige so the parchment feels lit)
world = bpy.data.worlds.new("Map_World")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.10, 0.08, 0.06, 1.0)
bg.inputs['Strength'].default_value = 0.3

# ==================== Save ====================
print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)
print(f"Saved: {OUTPUT_BLEND}")

# ==================== Renders ====================
# Task 3: World map full top-down
scene.camera = cam_obj
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.render.filepath = os.path.join(RENDER_DIR, "world_map_full.png")
print("=== Rendering full world map ===")
bpy.ops.render.render(write_still=True)

# Task 45: Hero shot
scene.camera = hero_cam_obj
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.render.filepath = os.path.join(RENDER_DIR, "world_map_hero.png")
print("=== Rendering hero shot ===")
bpy.ops.render.render(write_still=True)

# Task 18: Individual icon renders (small)
print("=== Rendering individual icons ===")
scene.render.resolution_x = 256
scene.render.resolution_y = 256
scene.render.film_transparent = True

icon_cam_data = bpy.data.cameras.new("Icon_Cam")
icon_cam_data.lens = 50
icon_cam = bpy.data.objects.new("Icon_Cam", icon_cam_data)
icon_cam.rotation_euler = (0, 0, 0)
scene.collection.objects.link(icon_cam)
scene.camera = icon_cam

# Hide everything except one icon at a time
all_icon_objs = list(col_icons.objects)
for icon_obj in all_icon_objs:
    # Hide all icons
    for other in all_icon_objs:
        other.hide_render = (other != icon_obj)
    # Hide regions/ink/typography/animated — we want pure icon
    for h_coll in [col_regions, col_ink, col_typography, col_animated, col_parchment]:
        for obj in h_coll.objects:
            obj.hide_render = True
    # Position camera directly above the icon
    ix, iy, iz = icon_obj.location
    icon_cam.location = (ix, iy, iz + 1.8)
    out_path = os.path.join(RENDER_DIR, f"world_map_{icon_obj.name.lower()}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

print("World map pipeline complete.")
