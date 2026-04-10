"""
Epic 40 — Companion System Pipeline
======================================
Builds in one Blender background pass:
  - Task 33: 4 companion model variants (Tank/DPS/Healer/Utility)
  - Task 34: Gear visual swap variants (3 gear sets per companion)
  - Task 35: Companion pet support visuals (4 pet attendants)
  - Task 41: 4 companion hero shot renders + 4 portrait renders

Saves:
  - _art_source/companions/companion_assets.blend
  - _art_source/companions/renders/companion_<role>_hero.png
  - _art_source/companions/renders/companion_<role>_portrait.png
  - _art_source/companions/renders/companion_pet_<role>.png
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/companions/companion_assets.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/companions/renders"
os.makedirs(os.path.dirname(OUTPUT_BLEND), exist_ok=True)
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 48

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

# Per-companion palettes
COMPANIONS = {
    "tank":    {"shell": (0.30, 0.30, 0.40), "accent": (0.95, 0.65, 0.20), "weapon": "shield_axe", "build": "heavy"},
    "dps":     {"shell": (0.20, 0.45, 0.65), "accent": (0.95, 0.85, 0.30), "weapon": "rifle", "build": "lean"},
    "healer":  {"shell": (0.85, 0.85, 0.92), "accent": (0.30, 0.85, 0.55), "weapon": "staff", "build": "robed"},
    "utility": {"shell": (0.55, 0.30, 0.85), "accent": (1.0, 0.55, 0.20), "weapon": "twin_orbs", "build": "compact"},
}

mats = {}
for cid, c in COMPANIONS.items():
    mats[cid] = {
        "shell": make_pbr(f"comp_{cid}_shell", c["shell"], 0.5, 0.3),
        "accent": make_pbr(f"comp_{cid}_accent", c["accent"], 0.3, 0.0, c["accent"], 2.5),
        "metal": make_pbr(f"comp_{cid}_metal", (0.55, 0.55, 0.60), 0.3, 0.95),
        "dark": make_pbr(f"comp_{cid}_dark", (0.05, 0.05, 0.08), 0.7),
        "skin": make_pbr(f"comp_{cid}_skin", (0.85, 0.75, 0.60), 0.7),
    }

mat_aura_warm = make_pbr("aura_warm", (1.0, 0.85, 0.45), 0.4, 0.0, (1.0, 0.85, 0.45), 1.5)

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_companions = make_coll("Companions")
col_pets = make_coll("Pets")
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

# === Build a companion ===
def build_companion(cid, x_off, coll):
    spec = COMPANIONS[cid]
    m = mats[cid]
    build_kind = spec["build"]
    objs = []

    # Body silhouette per build
    if build_kind == "heavy":
        # Bulky cube body
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        bmesh.ops.scale(bm, vec=(0.55, 0.55, 0.7), verts=bm.verts)
        bmesh.ops.bevel(bm, geom=bm.edges[:]+bm.verts[:], offset=0.18, segments=4, profile=0.5, affect='EDGES')
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        objs.append(add_bm(f"{cid}_Body", bm, m["shell"], coll, loc=(x_off, 0, 0.7)))
    elif build_kind == "lean":
        # Slim sphere body
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=16, v_segments=10, radius=0.32)
        bmesh.ops.scale(bm, vec=(1, 0.7, 1.4), verts=bm.verts)
        objs.append(add_bm(f"{cid}_Body", bm, m["shell"], coll, loc=(x_off, 0, 0.85)))
    elif build_kind == "robed":
        # Robed cone shape
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=16, radius1=0.30, radius2=0.55, depth=1.2)
        objs.append(add_bm(f"{cid}_Robe", bm, m["shell"], coll, loc=(x_off, 0, 0.6)))
    elif build_kind == "compact":
        # Small dense body
        bm = bmesh.new()
        bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.45)
        bmesh.ops.scale(bm, vec=(0.9, 0.9, 1.1), verts=bm.verts)
        objs.append(add_bm(f"{cid}_Body", bm, m["shell"], coll, loc=(x_off, 0, 0.65)))

    # Head
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=3, radius=0.30)
    objs.append(add_bm(f"{cid}_Head", bm, m["shell"], coll, loc=(x_off, 0, 1.55)))

    # Visor
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=20, v_segments=12, radius=0.22)
    bmesh.ops.scale(bm, vec=(1, 0.4, 0.5), verts=bm.verts)
    objs.append(add_bm(f"{cid}_Visor", bm, m["accent"], coll, loc=(x_off, -0.18, 1.6)))

    # Chest emblem
    objs.append(add_bm(f"{cid}_Emblem", ico(0.12, 2), m["accent"], coll, loc=(x_off, -0.32, 0.95)))

    # Arms
    for side in [-1, 1]:
        objs.append(add_bm(f"{cid}_Arm_{side}", cyl(0.13, 0.7, 8), m["shell"], coll,
                           loc=(x_off + side*0.55, 0, 0.5)))
        objs.append(add_bm(f"{cid}_Hand_{side}", ico(0.13, 2), m["shell"], coll,
                           loc=(x_off + side*0.55, 0, 0.18)))

    # Legs
    for side in [-1, 1]:
        objs.append(add_bm(f"{cid}_Leg_{side}", cyl(0.15, 0.6, 8), m["shell"], coll,
                           loc=(x_off + side*0.22, 0, 0.0)))
        objs.append(add_bm(f"{cid}_Boot_{side}", cube(0.18, 0.26, 0.1), m["dark"], coll,
                           loc=(x_off + side*0.22, 0, -0.25)))

    # Weapon per role
    weapon_kind = spec["weapon"]
    if weapon_kind == "shield_axe":
        # Shield in left hand
        objs.append(add_bm(f"{cid}_Shield", cube(0.10, 0.55, 0.95), m["metal"], coll,
                           loc=(x_off - 0.7, -0.2, 0.55)))
        objs.append(add_bm(f"{cid}_ShieldEmblem", ico(0.18, 2), m["accent"], coll,
                           loc=(x_off - 0.65, -0.25, 0.55)))
        # Axe in right hand
        objs.append(add_bm(f"{cid}_AxeShaft", cyl(0.04, 0.7, 6), m["dark"], coll,
                           loc=(x_off + 0.65, -0.05, 0.4)))
        objs.append(add_bm(f"{cid}_AxeHead", cube(0.20, 0.05, 0.30), m["metal"], coll,
                           loc=(x_off + 0.65, -0.05, 0.85)))
    elif weapon_kind == "rifle":
        # Long rifle held across body
        objs.append(add_bm(f"{cid}_RifleBody", cube(0.06, 0.06, 0.95), m["metal"], coll,
                           loc=(x_off + 0.4, -0.1, 0.85), rot=(math.radians(60), 0, 0)))
        objs.append(add_bm(f"{cid}_RifleScope", cube(0.04, 0.10, 0.20), m["dark"], coll,
                           loc=(x_off + 0.4, -0.18, 1.05), rot=(math.radians(60), 0, 0)))
        objs.append(add_bm(f"{cid}_RifleStock", cube(0.06, 0.15, 0.25), m["dark"], coll,
                           loc=(x_off + 0.4, -0.05, 0.55), rot=(math.radians(60), 0, 0)))
    elif weapon_kind == "staff":
        # Tall staff in right hand
        objs.append(add_bm(f"{cid}_StaffShaft", cyl(0.04, 1.6, 6), m["dark"], coll,
                           loc=(x_off + 0.65, -0.05, 0.0)))
        objs.append(add_bm(f"{cid}_StaffOrb", ico(0.15, 2), m["accent"], coll,
                           loc=(x_off + 0.65, -0.05, 1.7)))
        # Orb glow ring
        add_torus(f"{cid}_StaffRing", m["accent"], coll, (x_off + 0.65, -0.05, 1.7), major=0.20, minor=0.025)
    elif weapon_kind == "twin_orbs":
        # Two small orbs floating beside hands
        objs.append(add_bm(f"{cid}_OrbL", ico(0.15, 2), m["accent"], coll,
                           loc=(x_off - 0.65, -0.10, 0.5)))
        objs.append(add_bm(f"{cid}_OrbR", ico(0.15, 2), m["accent"], coll,
                           loc=(x_off + 0.65, -0.10, 0.5)))

    # Aura ring at feet
    add_torus(f"{cid}_AuraRing", m["accent"], coll, (x_off, 0, -0.32), major=0.85, minor=0.05)

    return objs

# === Build all 4 companions ===
print("=== Building 4 companions ===")
companion_objs = {}
for i, cid in enumerate(["tank", "dps", "healer", "utility"]):
    x_off = (i - 1.5) * 3
    objs = build_companion(cid, x_off, col_companions)
    companion_objs[cid] = objs

# === Pets (4 small companions, one per role) ===
print("=== Companion pets ===")
pet_objs = {}
for i, cid in enumerate(["tank", "dps", "healer", "utility"]):
    m = mats[cid]
    x_off = (i - 1.5) * 3 + 1.2  # offset to side of companion
    objs = []
    # Pet body
    objs.append(add_bm(f"pet_{cid}_body", ico(0.20, 2), m["shell"], col_pets,
                       loc=(x_off, 0.5, 0.20)))
    # Pet head
    objs.append(add_bm(f"pet_{cid}_head", ico(0.13, 2), m["shell"], col_pets,
                       loc=(x_off, 0.5, 0.45)))
    # Pet eye glow
    objs.append(add_bm(f"pet_{cid}_eye", ico(0.04, 1), m["accent"], col_pets,
                       loc=(x_off, 0.40, 0.50)))
    # Aura
    add_torus(f"pet_{cid}_aura", m["accent"], col_pets, (x_off, 0.5, 0.05), major=0.30, minor=0.02)
    pet_objs[cid] = objs

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

# Per-companion hero + portrait cameras
hero_cams = {}
portrait_cams = {}
for i, cid in enumerate(["tank", "dps", "healer", "utility"]):
    x_off = (i - 1.5) * 3
    hero_cams[cid] = add_camera(f"Hero_{cid}", (x_off + 1.5, -4.5, 1.6),
                                  (math.radians(80), 0, math.radians(20)), 50)
    portrait_cams[cid] = add_camera(f"Portrait_{cid}", (x_off, -3.0, 1.5),
                                      (math.radians(85), 0, 0), 85)

pet_cam = add_camera("Pet_Cam", (0, -3, 0.8), (math.radians(80), 0, 0), 60)

# === Lights ===
key_data = bpy.data.lights.new("Key", type='AREA')
key_data.energy = 1000
key_data.size = 6
key_data.color = (1.0, 0.96, 0.92)
key_obj = bpy.data.objects.new("Key", key_data)
key_obj.location = (-2, -3, 4)
key_obj.rotation_euler = (math.radians(45), math.radians(-15), 0)
scene.collection.objects.link(key_obj)
link_to(key_obj, col_lights)

fill_data = bpy.data.lights.new("Fill", type='AREA')
fill_data.energy = 350
fill_data.size = 8
fill_data.color = (0.65, 0.78, 1.0)
fill_obj = bpy.data.objects.new("Fill", fill_data)
fill_obj.location = (4, -3, 3)
fill_obj.rotation_euler = (math.radians(50), math.radians(20), 0)
scene.collection.objects.link(fill_obj)
link_to(fill_obj, col_lights)

rim_data = bpy.data.lights.new("Rim", type='AREA')
rim_data.energy = 600
rim_data.size = 5
rim_data.color = (1.0, 0.85, 0.75)
rim_obj = bpy.data.objects.new("Rim", rim_data)
rim_obj.location = (0, 4, 4)
rim_obj.rotation_euler = (math.radians(120), 0, 0)
scene.collection.objects.link(rim_obj)
link_to(rim_obj, col_lights)

world = bpy.data.worlds.new("World_Companion")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.04, 0.05, 0.10, 1.0)
bg.inputs['Strength'].default_value = 0.4

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# === Render hero shots (1280x720) ===
print("=== Rendering hero shots ===")
scene.render.resolution_x = 1280
scene.render.resolution_y = 720
scene.render.film_transparent = False

# Hide pets initially
for objs in pet_objs.values():
    for o in objs:
        o.hide_render = True

for cid in COMPANIONS.keys():
    # Hide all other companions
    for k2, o2_list in companion_objs.items():
        for o in o2_list:
            o.hide_render = (k2 != cid)
    scene.camera = hero_cams[cid]
    out_path = os.path.join(RENDER_DIR, f"companion_{cid}_hero.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

# === Render portraits (720x960) ===
print("=== Rendering portraits ===")
scene.render.resolution_x = 720
scene.render.resolution_y = 960
for cid in COMPANIONS.keys():
    for k2, o2_list in companion_objs.items():
        for o in o2_list:
            o.hide_render = (k2 != cid)
    scene.camera = portrait_cams[cid]
    out_path = os.path.join(RENDER_DIR, f"companion_{cid}_portrait.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

# === Render pets (transparent 256x256) ===
print("=== Rendering pets ===")
scene.render.resolution_x = 256
scene.render.resolution_y = 256
scene.render.film_transparent = True

# Hide all companions
for k2, o2_list in companion_objs.items():
    for o in o2_list:
        o.hide_render = True
scene.camera = pet_cam

for cid in COMPANIONS.keys():
    for k2, o2_list in pet_objs.items():
        for o in o2_list:
            o.hide_render = (k2 != cid)
    # Center camera on this pet
    objs = pet_objs[cid]
    cx = sum(o.location.x for o in objs) / len(objs)
    cy = sum(o.location.y for o in objs) / len(objs)
    pet_cam.location = (cx, cy - 1.4, 0.7)
    out_path = os.path.join(RENDER_DIR, f"companion_pet_{cid}.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

print("Companion pipeline complete.")
