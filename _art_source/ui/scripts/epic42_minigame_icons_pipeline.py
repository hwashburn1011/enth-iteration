"""
Epic 42 — Minigame Icons Pipeline
====================================
Renders 8 minigame hero icons + 8 gameplay screenshot mockups.
Each icon is a 256x256 transparent PNG with a unique themed symbol.
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/ui/minigame_icons.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/ui/renders"
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

mat_frame = make_pbr("mg_frame", (0.20, 0.30, 0.45), 0.4, 0.4)
mat_inner = make_pbr("mg_inner", (0.05, 0.08, 0.15), 0.7)
mat_glow = make_pbr("mg_glow", (0.30, 0.85, 1.0), 0.3, 0.0, (0.4, 0.9, 1.0), 3.5)
mat_gold = make_pbr("mg_gold", (1.0, 0.85, 0.30), 0.3, 0.0, (1.0, 0.85, 0.30), 2.5)
mat_red = make_pbr("mg_red", (1.0, 0.30, 0.20), 0.3, 0.0, (1.0, 0.3, 0.2), 2.5)
mat_green = make_pbr("mg_green", (0.30, 0.95, 0.40), 0.3, 0.0, (0.4, 1.0, 0.5), 2.5)
mat_violet = make_pbr("mg_violet", (0.85, 0.30, 1.0), 0.3, 0.0, (0.9, 0.4, 1.0), 3.0)
mat_silver = make_pbr("mg_silver", (0.85, 0.85, 0.92), 0.4, 0.95)
mat_metal = make_pbr("mg_metal", (0.55, 0.55, 0.60), 0.3, 0.95)
mat_dark = make_pbr("mg_dark", (0.05, 0.05, 0.08), 0.7)

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_icons = make_coll("Minigame_Icons")
col_lights = make_coll("Lights")
col_cam = make_coll("Cameras")

def link_to(obj, coll):
    for c in obj.users_collection: c.objects.unlink(obj)
    coll.objects.link(obj)

def add_bm(name, bm, mat, coll, loc=(0,0,0), rot=(0,0,0)):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me); bm.free()
    if mat is not None:
        me.materials.append(mat)
    obj = bpy.data.objects.new(name, me)
    obj.location = loc; obj.rotation_euler = rot
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

# === Build a backed icon with frame + inner + symbol ===
def build_icon(name, symbol_builder, position):
    objs = []
    # Frame disc
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=24, radius1=0.5, radius2=0.5, depth=0.05)
    objs.append(add_bm(f"{name}_frame", bm, mat_frame, col_icons, loc=position))
    # Inner disc
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=24, radius1=0.45, radius2=0.45, depth=0.06)
    objs.append(add_bm(f"{name}_inner", bm, mat_inner, col_icons,
                       loc=(position[0], position[1], position[2] + 0.005)))
    # Symbol parts
    symbol_builder(name, position, objs)
    return objs

# Symbol builders (all parts placed at position[2] + 0.06 with 90° rotation about X to face camera)
def sym_terminal_hacking(name, pos, objs):
    # Brackets + cursor: < cursor >
    bm = cube(0.10, 0.06, 0.06)
    objs.append(add_bm(f"{name}_lb1", bm, mat_glow, col_icons,
                       loc=(pos[0]-0.20, pos[1]+0.06, pos[2]+0.05),
                       rot=(0, math.radians(45), 0)))
    bm = cube(0.10, 0.06, 0.06)
    objs.append(add_bm(f"{name}_lb2", bm, mat_glow, col_icons,
                       loc=(pos[0]-0.20, pos[1]+0.06, pos[2]-0.05),
                       rot=(0, math.radians(-45), 0)))
    bm = cube(0.10, 0.06, 0.06)
    objs.append(add_bm(f"{name}_rb1", bm, mat_glow, col_icons,
                       loc=(pos[0]+0.20, pos[1]+0.06, pos[2]+0.05),
                       rot=(0, math.radians(-45), 0)))
    bm = cube(0.10, 0.06, 0.06)
    objs.append(add_bm(f"{name}_rb2", bm, mat_glow, col_icons,
                       loc=(pos[0]+0.20, pos[1]+0.06, pos[2]-0.05),
                       rot=(0, math.radians(45), 0)))
    # Cursor block
    bm = cube(0.06, 0.06, 0.20)
    objs.append(add_bm(f"{name}_cursor", bm, mat_glow, col_icons,
                       loc=(pos[0], pos[1]+0.06, pos[2])))

def sym_memory_match(name, pos, objs):
    # 4 small cards in a 2x2 grid
    for sx in [-1, 1]:
        for sz in [-1, 1]:
            bm = cube(0.12, 0.04, 0.16)
            color = mat_glow if (sx*sz > 0) else mat_violet
            objs.append(add_bm(f"{name}_card_{sx}_{sz}", bm, color, col_icons,
                               loc=(pos[0]+sx*0.16, pos[1]+0.06, pos[2]+sz*0.16)))

def sym_code_compile(name, pos, objs):
    # 3 stacked horizontal bars + downward arrow
    for i in range(3):
        bm = cube(0.30, 0.05, 0.04)
        objs.append(add_bm(f"{name}_bar_{i}", bm, mat_glow, col_icons,
                           loc=(pos[0], pos[1]+0.06, pos[2]+0.18 - i*0.08)))
    # Arrow tip
    bm = cone(0.10, 0.0, 0.10)
    bmesh.ops.rotate(bm, matrix=Matrix.Rotation(math.pi, 3, 'X'), verts=bm.verts)
    objs.append(add_bm(f"{name}_arrow", bm, mat_gold, col_icons,
                       loc=(pos[0], pos[1]+0.06, pos[2]-0.10)))

def sym_data_sort(name, pos, objs):
    # 4 columns of varying heights (sort visualization)
    heights = [0.10, 0.20, 0.15, 0.25]
    colors = [mat_glow, mat_gold, mat_violet, mat_green]
    for i in range(4):
        bm = cube(0.06, 0.06, heights[i])
        objs.append(add_bm(f"{name}_col_{i}", bm, colors[i], col_icons,
                           loc=(pos[0]-0.18 + i*0.12, pos[1]+0.06, pos[2]-0.10 + heights[i]/2)))

def sym_fishing(name, pos, objs):
    # Fishing rod (line + hook)
    bm = cyl(0.025, 0.40, 6)
    objs.append(add_bm(f"{name}_rod", bm, mat_metal, col_icons,
                       loc=(pos[0]-0.20, pos[1]+0.06, pos[2]-0.10),
                       rot=(0, math.radians(-30), 0)))
    # Line
    bm = cyl(0.005, 0.30, 4)
    objs.append(add_bm(f"{name}_line", bm, mat_silver, col_icons,
                       loc=(pos[0]+0.10, pos[1]+0.06, pos[2]-0.10)))
    # Hook (small ico)
    objs.append(add_bm(f"{name}_hook", ico(0.04, 1), mat_silver, col_icons,
                       loc=(pos[0]+0.10, pos[1]+0.06, pos[2]-0.25)))
    # Fish (icosphere)
    bm = ico(0.10, 2)
    bmesh.ops.scale(bm, vec=(1.5, 0.6, 0.8), verts=bm.verts)
    objs.append(add_bm(f"{name}_fish", bm, mat_glow, col_icons,
                       loc=(pos[0]+0.20, pos[1]+0.06, pos[2]+0.10)))

def sym_cooking(name, pos, objs):
    # Pot + steam
    bm = cyl(0.18, 0.20, 16)
    objs.append(add_bm(f"{name}_pot", bm, mat_metal, col_icons,
                       loc=(pos[0], pos[1]+0.06, pos[2]-0.15)))
    # Lid
    bm = cyl(0.20, 0.04, 16)
    objs.append(add_bm(f"{name}_lid", bm, mat_metal, col_icons,
                       loc=(pos[0], pos[1]+0.06, pos[2]+0.06)))
    # Lid handle
    objs.append(add_bm(f"{name}_handle", ico(0.04, 1), mat_gold, col_icons,
                       loc=(pos[0], pos[1]+0.06, pos[2]+0.10)))
    # Steam (3 spheres)
    for i in range(3):
        objs.append(add_bm(f"{name}_steam_{i}", ico(0.05 + i*0.02, 1), mat_silver, col_icons,
                           loc=(pos[0]-0.05 + i*0.05, pos[1]+0.06, pos[2]+0.20 + i*0.04)))

def sym_lockpicking(name, pos, objs):
    # Keyhole + 2 picks
    bm = cube(0.20, 0.04, 0.30)
    objs.append(add_bm(f"{name}_lock", bm, mat_metal, col_icons,
                       loc=(pos[0], pos[1]+0.06, pos[2])))
    bm = cyl(0.05, 0.04, 12)
    objs.append(add_bm(f"{name}_keyhole", bm, mat_dark, col_icons,
                       loc=(pos[0], pos[1]+0.07, pos[2]+0.05),
                       rot=(math.radians(90), 0, 0)))
    # Pick
    bm = cube(0.02, 0.02, 0.20)
    objs.append(add_bm(f"{name}_pick", bm, mat_gold, col_icons,
                       loc=(pos[0]+0.08, pos[1]+0.07, pos[2]+0.05),
                       rot=(0, math.radians(-25), 0)))

def sym_music_sync(name, pos, objs):
    # Music note (head + stem + flag)
    objs.append(add_bm(f"{name}_head", ico(0.10, 2), mat_violet, col_icons,
                       loc=(pos[0]-0.05, pos[1]+0.06, pos[2]-0.10)))
    bm = cube(0.04, 0.04, 0.30)
    objs.append(add_bm(f"{name}_stem", bm, mat_glow, col_icons,
                       loc=(pos[0], pos[1]+0.06, pos[2]+0.05)))
    bm = cube(0.10, 0.04, 0.04)
    objs.append(add_bm(f"{name}_flag", bm, mat_glow, col_icons,
                       loc=(pos[0]+0.05, pos[1]+0.06, pos[2]+0.18)))

MINIGAMES = [
    ("terminal_hacking", sym_terminal_hacking),
    ("memory_match", sym_memory_match),
    ("code_compile", sym_code_compile),
    ("data_sort", sym_data_sort),
    ("fishing", sym_fishing),
    ("cooking", sym_cooking),
    ("lockpicking", sym_lockpicking),
    ("music_sync", sym_music_sync),
]

print("=== Building 8 minigame icons ===")
icon_objs = {}
for i, (name, builder) in enumerate(MINIGAMES):
    pos_x = (i - 3.5) * 1.5
    objs = build_icon(name, builder, (pos_x, 0, 0))
    icon_objs[name] = objs

# === Cameras ===
icon_cam_data = bpy.data.cameras.new("Icon_Cam")
icon_cam_data.lens = 80
icon_cam = bpy.data.objects.new("Icon_Cam", icon_cam_data)
icon_cam.rotation_euler = (math.radians(15), 0, 0)
scene.collection.objects.link(icon_cam)
link_to(icon_cam, col_cam)

# === Lights ===
key_data = bpy.data.lights.new("Key", type='AREA')
key_data.energy = 250
key_data.size = 3
key_data.color = (1.0, 0.95, 0.92)
key_obj = bpy.data.objects.new("Key", key_data)
key_obj.location = (0, -2, 3)
key_obj.rotation_euler = (math.radians(45), 0, 0)
scene.collection.objects.link(key_obj)
link_to(key_obj, col_lights)

fill_data = bpy.data.lights.new("Fill", type='AREA')
fill_data.energy = 100
fill_data.size = 4
fill_data.color = (0.6, 0.78, 1.0)
fill_obj = bpy.data.objects.new("Fill", fill_data)
fill_obj.location = (0, -3, 2)
fill_obj.rotation_euler = (math.radians(60), 0, 0)
scene.collection.objects.link(fill_obj)
link_to(fill_obj, col_lights)

world = bpy.data.worlds.new("World_Mg")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.04, 0.05, 0.10, 1.0)
bg.inputs['Strength'].default_value = 0.3

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# === Render 8 icons ===
print("=== Rendering 8 minigame icons ===")
scene.render.resolution_x = 256
scene.render.resolution_y = 256
scene.render.film_transparent = True
scene.camera = icon_cam

for name in icon_objs.keys():
    for k2, o2 in icon_objs.items():
        for o in o2:
            o.hide_render = (k2 != name)
    objs = icon_objs[name]
    cx = sum(o.location.x for o in objs) / len(objs)
    icon_cam.location = (cx, -1.6, 0.0)
    icon_cam.rotation_euler = (math.radians(85), 0, 0)
    out_path = os.path.join(RENDER_DIR, f"minigame_{name}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

print("Minigame icons pipeline complete.")
