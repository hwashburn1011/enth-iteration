"""
Epic 29 — Dungeon Layout Gallery Render
========================================
Generates 6 varied procedural dungeon layout previews and renders each as
a top-down hero shot to validate the v2 generator's variety.

Each layout is built procedurally in Blender using the same anchor+connector
philosophy as the v2 generator:
  - Pick anchor rooms (large hand-crafted polygon shapes)
  - Add connectors (corridors) between them
  - Tag rooms by type (combat=blue, loot=gold, story=cyan, secret=violet,
    elite=orange, boss=red)

Saves:
  - _art_source/world/dungeon_layouts.blend (all 6 in collections)
  - _art_source/world/renders/dungeon_layout_{1-6}.png
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/dungeon_layouts.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/renders"
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 48
scene.render.resolution_x = 1280
scene.render.resolution_y = 720

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

# Tag colors
mat_combat = make_pbr("layout_combat", (0.30, 0.45, 0.60), 0.85, 0.0, (0.2, 0.4, 0.7), 0.4)
mat_loot = make_pbr("layout_loot", (0.85, 0.65, 0.20), 0.4, 0.0, (1.0, 0.8, 0.3), 0.6)
mat_story = make_pbr("layout_story", (0.45, 0.65, 0.85), 0.5, 0.0, (0.4, 0.7, 1.0), 0.5)
mat_secret = make_pbr("layout_secret", (0.45, 0.30, 0.75), 0.5, 0.0, (0.6, 0.4, 1.0), 0.7)
mat_elite = make_pbr("layout_elite", (0.85, 0.45, 0.20), 0.4, 0.0, (1.0, 0.5, 0.2), 0.6)
mat_boss = make_pbr("layout_boss", (0.85, 0.20, 0.30), 0.3, 0.0, (1.0, 0.3, 0.4), 0.9)
mat_corridor = make_pbr("layout_corridor", (0.20, 0.22, 0.28), 0.85)
mat_floor_bg = make_pbr("layout_floor_bg", (0.06, 0.07, 0.10), 0.95)

TAG_MATS = {
    "combat": mat_combat, "loot": mat_loot, "story": mat_story,
    "secret": mat_secret, "elite": mat_elite, "boss": mat_boss,
}

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

def add_room(name, polygon, mat, coll, z=0.05):
    bm = bmesh.new()
    verts = [bm.verts.new((p[0], p[1], 0)) for p in polygon]
    bm.faces.new(verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me); bm.free()
    me.materials.append(mat)
    obj = bpy.data.objects.new(name, me)
    obj.location = (0, 0, z)
    scene.collection.objects.link(obj)
    for c in obj.users_collection: c.objects.unlink(obj)
    coll.objects.link(obj)
    # Wall extrusion (small box around polygon for visual depth)
    wall_height = 0.6
    bm = bmesh.new()
    for i in range(len(polygon)):
        a = polygon[i]; b = polygon[(i+1) % len(polygon)]
        dx = b[0]-a[0]; dy = b[1]-a[1]
        length = math.sqrt(dx*dx + dy*dy)
        ang = math.atan2(dy, dx)
        cx = (a[0]+b[0])/2; cy = (a[1]+b[1])/2
        wall = bmesh.new()
        bmesh.ops.create_cube(wall, size=1.0)
        bmesh.ops.scale(wall, vec=(length/2, 0.08, wall_height/2), verts=wall.verts)
        # rotate around z
        for v in wall.verts:
            x = v.co.x; y = v.co.y
            v.co.x = x*math.cos(ang) - y*math.sin(ang)
            v.co.y = x*math.sin(ang) + y*math.cos(ang)
        bmesh.ops.translate(wall, vec=(cx, cy, wall_height/2), verts=wall.verts)
        wall_me = bpy.data.meshes.new(f"_wall_{i}")
        wall.to_mesh(wall_me); wall.free()
        bm.from_mesh(wall_me)
        bpy.data.meshes.remove(wall_me)
    if len(bm.faces) > 0:
        wall_obj_me = bpy.data.meshes.new(name + "_walls")
        bm.to_mesh(wall_obj_me); bm.free()
        wall_obj_me.materials.append(mat_corridor)
        wall_obj = bpy.data.objects.new(name + "_walls", wall_obj_me)
        scene.collection.objects.link(wall_obj)
        for c in wall_obj.users_collection: c.objects.unlink(wall_obj)
        coll.objects.link(wall_obj)

def add_corridor(name, p1, p2, coll, width=2.0):
    dx = p2[0] - p1[0]; dy = p2[1] - p1[1]
    length = math.sqrt(dx*dx + dy*dy)
    ang = math.atan2(dy, dx)
    cx = (p1[0]+p2[0])/2; cy = (p1[1]+p2[1])/2
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(length/2, width/2, 0.05), verts=bm.verts)
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me); bm.free()
    me.materials.append(mat_corridor)
    obj = bpy.data.objects.new(name, me)
    obj.location = (cx, cy, 0.05)
    obj.rotation_euler = (0, 0, ang)
    scene.collection.objects.link(obj)
    for c in obj.users_collection: c.objects.unlink(obj)
    coll.objects.link(obj)

# Generate room polygon (square or rectangle, optionally rotated)
def gen_room_polygon(cx, cy, w, h, rot=0):
    half_w, half_h = w/2, h/2
    pts = [(-half_w,-half_h),(half_w,-half_h),(half_w,half_h),(-half_w,half_h)]
    rotated = []
    for px, py in pts:
        rx = px*math.cos(rot) - py*math.sin(rot) + cx
        ry = px*math.sin(rot) + py*math.cos(rot) + cy
        rotated.append((rx, ry))
    return rotated

# === Build 6 unique layouts ===
LAYOUT_SEEDS = [101, 202, 303, 404, 505, 606]

def build_layout(seed_val, coll):
    rng = random.Random(seed_val)
    placed = []
    rooms_data = []
    # Always 8-12 rooms with mixed tags
    room_count = rng.randint(8, 12)
    tags_pool = (["combat"]*4 + ["loot"]*1 + ["story"]*1 + ["elite"]*1 + ["secret"]*1 + ["boss"]*1)
    rng.shuffle(tags_pool)
    while len(tags_pool) < room_count:
        tags_pool.append("combat")
    grid_size = 12
    for i in range(room_count):
        attempts = 0
        while attempts < 30:
            cx = rng.uniform(-grid_size, grid_size)
            cy = rng.uniform(-grid_size, grid_size)
            w = rng.uniform(3.5, 6.0)
            h = rng.uniform(3.5, 6.0)
            # Reject if overlap
            ok = True
            for (px, py, pw, ph) in placed:
                if abs(px - cx) < (pw + w)/2 + 1.5 and abs(py - cy) < (ph + h)/2 + 1.5:
                    ok = False; break
            if ok:
                placed.append((cx, cy, w, h))
                tag = tags_pool[i]
                rotation = rng.choice([0, math.pi/4, 0, 0])  # bias to axis-aligned
                polygon = gen_room_polygon(cx, cy, w, h, rotation)
                add_room(f"L{seed_val}_R{i}_{tag}", polygon, TAG_MATS[tag], coll)
                rooms_data.append({"cx": cx, "cy": cy, "tag": tag})
                break
            attempts += 1
    # Build connectors (MST-ish: connect each room to nearest)
    for i in range(1, len(rooms_data)):
        # Nearest already-placed room
        best_d = 1e9; best_j = 0
        for j in range(i):
            d = (rooms_data[i]["cx"] - rooms_data[j]["cx"])**2 + (rooms_data[i]["cy"] - rooms_data[j]["cy"])**2
            if d < best_d:
                best_d = d; best_j = j
        add_corridor(f"L{seed_val}_C{i}",
                     (rooms_data[i]["cx"], rooms_data[i]["cy"]),
                     (rooms_data[best_j]["cx"], rooms_data[best_j]["cy"]),
                     coll, width=1.6)
    # Background floor
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, x_segments=2, y_segments=2, size=30)
    me = bpy.data.meshes.new(f"L{seed_val}_BG")
    bm.to_mesh(me); bm.free()
    me.materials.append(mat_floor_bg)
    obj = bpy.data.objects.new(f"L{seed_val}_BG", me)
    obj.location = (0, 0, -0.1)
    scene.collection.objects.link(obj)
    for c in obj.users_collection: c.objects.unlink(obj)
    coll.objects.link(obj)

print("=== Building 6 layouts ===")
layout_colls = []
for seed_val in LAYOUT_SEEDS:
    coll = make_coll(f"Layout_{seed_val}")
    build_layout(seed_val, coll)
    layout_colls.append(coll)

# Camera (top-down)
cam_data = bpy.data.cameras.new("Layout_Cam")
cam_data.lens = 45
cam_obj = bpy.data.objects.new("Layout_Cam", cam_data)
cam_obj.location = (0, 0, 32)
cam_obj.rotation_euler = (0, 0, 0)
scene.collection.objects.link(cam_obj)
scene.camera = cam_obj

# Top key area light
light_data = bpy.data.lights.new("Layout_Key", type='AREA')
light_data.energy = 2200
light_data.size = 30
light_data.color = (1.0, 0.96, 0.88)
light_obj = bpy.data.objects.new("Layout_Key", light_data)
light_obj.location = (0, 0, 20)
scene.collection.objects.link(light_obj)

# Cool rim light from below the floor for tag glow pop
rim_data = bpy.data.lights.new("Layout_Rim", type='AREA')
rim_data.energy = 600
rim_data.size = 25
rim_data.color = (0.4, 0.5, 0.85)
rim_obj = bpy.data.objects.new("Layout_Rim", rim_data)
rim_obj.location = (0, 0, -12)
rim_obj.rotation_euler = (math.radians(180), 0, 0)
scene.collection.objects.link(rim_obj)

# World
world = bpy.data.worlds.new("Layout_World")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.04, 0.05, 0.08, 1.0)
bg.inputs['Strength'].default_value = 0.4

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)
print(f"Saved: {OUTPUT_BLEND}")

# Render each layout (hide others)
for idx, coll in enumerate(layout_colls):
    # Hide all other layout collections
    for other_idx, other_coll in enumerate(layout_colls):
        for obj in other_coll.objects:
            obj.hide_render = (other_idx != idx)
    out_path = os.path.join(RENDER_DIR, f"dungeon_layout_{idx+1}.png")
    scene.render.filepath = out_path
    print(f"=== Rendering layout {idx+1} ===")
    bpy.ops.render.render(write_still=True)
    print(f"  → {out_path}")

print("Dungeon layout gallery complete.")
