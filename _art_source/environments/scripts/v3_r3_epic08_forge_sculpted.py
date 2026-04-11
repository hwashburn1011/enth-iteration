"""
Expansion V3 — ROUND 3 — Epic R3-08 — Forge / Anvil Hero
========================================================
Crafting workshop hero asset. TWO single-mesh objects (forge + anvil)
each carved from one base mesh, not parented primitives. The forge
has a real fire pit cavity carved into its top. The anvil has a real
extruded horn and table face shaped from a single block.

  FORGE:
    - Single subdivided cube base
    - Top fire pit cavity carved via bmesh inset_individual + push DOWN
    - Stone arch lip extruded around the cavity
    - Side bellows cut-out (two small recesses on -X face)
    - Multires 1, weathered stone shader, bake albedo + normal

  ANVIL:
    - Single subdivided cube base
    - Wide flat top face from inset (the working face)
    - Horn extruded forward (-Y) and tip-pointed via collapse
    - Pritchel hole carved on top via inset push down
    - Round-pene step inset
    - Multires 1, dark iron + dust PBR shader

Both static, both with normal map bake high→low.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(308)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/v3_r3_forge.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/renders"
TEX_DIR      = "C:/Users/hwash/Documents/enth-iteration/_art_source/textures/baked"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/exports"
for d in [RENDER_DIR, TEX_DIR, EXPORT_DIR]:
    os.makedirs(d, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 96
scene.cycles.use_denoising = True
scene.cycles.device = 'CPU'
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.view_settings.look = 'AgX - High Contrast'

scene.world = bpy.data.worlds.new("v3r3_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.03, 0.02, 0.02, 1)
bg.inputs["Strength"].default_value = 0.4

# ============================================================
# HELPERS
# ============================================================
def closest_face(bm, target):
    best, best_d = None, 1e9
    for f in bm.faces:
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d; best = f
    return best

def closest_face_normal(bm, target, normal_dir):
    best, best_d = None, 1e9
    for f in bm.faces:
        if f.normal.dot(normal_dir) < 0.5:
            continue
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d; best = f
    return best

# ============================================================
# STAGE 1A — FORGE BASE MESH
# ============================================================
print("=== STAGE 1A: Forge base ===")
bpy.ops.mesh.primitive_cube_add(size=2.0, location=(-2.0, 0, 1.0))
forge = bpy.context.object
forge.name = "forge_hp"
forge.scale = (1.4, 1.2, 1.0)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
for _ in range(3):
    bpy.ops.mesh.subdivide()
bpy.ops.object.mode_set(mode='OBJECT')

bm = bmesh.new()
bm.from_mesh(forge.data)

# Slight stone-block jitter
for v in bm.verts:
    seed_val = hash((round(v.co.x, 1), round(v.co.y, 1), round(v.co.z, 1))) & 0xFFFF
    random.seed(seed_val)
    v.co += v.normal * random.uniform(-0.02, 0.02)

# === Carve fire pit cavity on the top face ===
print("Carving fire pit cavity...")
top_faces = [f for f in bm.faces if f.normal.z > 0.7 and f.calc_center_median().z > 0.85]
# Get center-most top faces (the cavity)
top_faces.sort(key=lambda f: (f.calc_center_median() - Vector((-2.0, 0, 1.0))).length)
cavity_faces = top_faces[:8]  # central cluster
if cavity_faces:
    res = bmesh.ops.inset_individual(bm, faces=cavity_faces, thickness=0.05, depth=0.0)
    new_faces = res.get('faces', [])
    # Push deep down to form pit
    for f in new_faces:
        for v in f.verts:
            v.co.z -= 0.40

# === Stone arch lip around the cavity (extrude up the OUTER ring) ===
print("Building stone lip...")
# The faces NOT in the cavity but on the top — extrude up slightly
top_now = [f for f in bm.faces if f.normal.z > 0.7 and f.calc_center_median().z > 0.85]
lip_faces = [f for f in top_now if f not in new_faces]
if lip_faces:
    geom = bmesh.ops.extrude_face_region(bm, geom=lip_faces[:6])
    new_verts_lip = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
    for v in new_verts_lip:
        v.co.z += 0.10

# === Side bellows recess ===
print("Carving bellows recesses...")
for z in [0.4, -0.2]:
    bf = closest_face_normal(bm, Vector((-2.0 - 1.4, 0, z)), Vector((-1, 0, 0)))
    if bf:
        res = bmesh.ops.inset_individual(bm, faces=[bf], thickness=0.10, depth=0.0)
        new_f = res['faces'][0] if res.get('faces') else bf
        for v in new_f.verts:
            v.co.x += 0.12  # push into the body

bm.normal_update()
bm.to_mesh(forge.data)
bm.free()
forge.data.update()
for poly in forge.data.polygons:
    poly.use_smooth = False

# Bevel + multires
print("Adding bevel + multires to forge...")
bev = forge.modifiers.new("Bevel", 'BEVEL'); bev.width = 0.015; bev.segments = 2
forge.modifiers.new("Multires", 'MULTIRES')
bpy.context.view_layer.objects.active = forge
bpy.ops.object.multires_subdivide(modifier="Multires", mode='CATMULL_CLARK')

# ============================================================
# STAGE 1B — ANVIL BASE MESH
# ============================================================
print("=== STAGE 1B: Anvil base ===")
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(1.0, 0, 0.85))
anvil = bpy.context.object
anvil.name = "anvil_hp"
anvil.scale = (0.55, 1.0, 0.85)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
for _ in range(3):
    bpy.ops.mesh.subdivide()
bpy.ops.object.mode_set(mode='OBJECT')

bm = bmesh.new()
bm.from_mesh(anvil.data)

# Anvil shape: narrow waist (pinch the middle horizontally)
for v in bm.verts:
    # Pinch waist
    if -0.35 < v.co.z - 0.85 < 0.30:
        v.co.x *= 0.55
        v.co.y *= 0.85
    # Slight outward flare at top (working face wider than waist)
    if v.co.z > 1.20:
        v.co.x *= 1.15
    # Base flares wide at bottom
    if v.co.z < 0.50:
        v.co.x *= 1.20
        v.co.y *= 1.10

# === Extrude horn forward (-Y) ===
print("Extruding anvil horn...")
# Find faces on +Z near front (-Y) at top of anvil
horn_face = closest_face(bm, Vector((1.0, -1.0, 1.30)))
if horn_face:
    geom = bmesh.ops.extrude_face_region(bm, geom=[horn_face])
    new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
    for v in new_verts:
        v.co.y -= 0.30
        v.co.z -= 0.05
    new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
    if new_faces:
        # Second extrude — taper toward tip
        geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
        new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
        avg2 = Vector((1.0, -1.50, 1.20))
        for v in new_verts2:
            v.co = v.co.lerp(avg2, 0.6)
        new_faces2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMFace)]
        if new_faces2:
            # Third extrude — collapse to point
            geom3 = bmesh.ops.extrude_face_region(bm, geom=[new_faces2[0]])
            new_verts3 = [g for g in geom3['geom'] if isinstance(g, bmesh.types.BMVert)]
            avg3 = Vector((1.0, -1.75, 1.18))
            for v in new_verts3:
                v.co = avg3

# === Pritchel hole on top ===
print("Carving pritchel hole...")
prit_face = closest_face(bm, Vector((1.0, 0.4, 1.60)))
if prit_face:
    res = bmesh.ops.inset_individual(bm, faces=[prit_face], thickness=0.05, depth=0.0)
    new_f = res['faces'][0] if res.get('faces') else prit_face
    for v in new_f.verts:
        v.co.z -= 0.12

# === Hardy hole (square) on top ===
hardy_face = closest_face(bm, Vector((1.0, -0.30, 1.60)))
if hardy_face:
    res = bmesh.ops.inset_individual(bm, faces=[hardy_face], thickness=0.05, depth=0.0)
    new_f = res['faces'][0] if res.get('faces') else hardy_face
    for v in new_f.verts:
        v.co.z -= 0.10

bm.normal_update()
bm.to_mesh(anvil.data)
bm.free()
anvil.data.update()
for poly in anvil.data.polygons:
    poly.use_smooth = False

print("Adding bevel + multires to anvil...")
bev = anvil.modifiers.new("Bevel", 'BEVEL'); bev.width = 0.015; bev.segments = 2
anvil.modifiers.new("Multires", 'MULTIRES')
bpy.context.view_layer.objects.active = anvil
bpy.ops.object.multires_subdivide(modifier="Multires", mode='CATMULL_CLARK')

# ============================================================
# STAGE 2 — UV UNWRAP BOTH
# ============================================================
print("=== STAGE 2: UV unwrap ===")
for obj in [forge, anvil]:
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=math.radians(50), island_margin=0.02)
    bpy.ops.object.mode_set(mode='OBJECT')

# ============================================================
# STAGE 3 — SHADERS (forge stone w/ ember glow, dark iron anvil)
# ============================================================
print("=== STAGE 3: Procedural shaders ===")

def make_forge_shader():
    m = bpy.data.materials.new("v3r3_forge_proc")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.75
    bsdf.inputs["Metallic"].default_value = 0.05
    bsdf.inputs["Emission Strength"].default_value = 12.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (3, 3, 3)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Soot-stained stone
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
    n.inputs["Scale"].default_value = 14.0
    n.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])

    stone_ramp = nodes.new("ShaderNodeValToRGB"); stone_ramp.location = (-450, 200)
    stone_ramp.color_ramp.elements[0].position = 0.30
    stone_ramp.color_ramp.elements[0].color = (0.06, 0.05, 0.04, 1)  # soot black
    stone_ramp.color_ramp.elements[1].position = 0.70
    stone_ramp.color_ramp.elements[1].color = (0.30, 0.22, 0.18, 1)  # warm stone
    links.new(n.outputs["Fac"], stone_ramp.inputs["Fac"])
    links.new(stone_ramp.outputs["Color"], bsdf.inputs["Base Color"])

    # === Ember glow via Pointiness (recesses = fire pit interior) ===
    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-700, -200)
    pointy_ramp = nodes.new("ShaderNodeValToRGB"); pointy_ramp.location = (-450, -200)
    pointy_ramp.color_ramp.elements[0].position = 0.25
    pointy_ramp.color_ramp.elements[0].color = (1, 1, 1, 1)
    pointy_ramp.color_ramp.elements[1].position = 0.42
    pointy_ramp.color_ramp.elements[1].color = (0, 0, 0, 1)
    links.new(geo.outputs["Pointiness"], pointy_ramp.inputs["Fac"])

    # Ember color: orange-red
    em_color = nodes.new("ShaderNodeRGB"); em_color.location = (-450, -400)
    em_color.outputs[0].default_value = (1.0, 0.45, 0.10, 1)

    em_mix = nodes.new("ShaderNodeMix"); em_mix.data_type = 'RGBA'; em_mix.location = (100, -300)
    links.new(pointy_ramp.outputs["Color"], em_mix.inputs["Factor"])
    em_mix.inputs[6].default_value = (0, 0, 0, 1)
    links.new(em_color.outputs[0], em_mix.inputs[7])
    links.new(em_mix.outputs[2], bsdf.inputs["Emission Color"])

    # Bump
    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -550)
    bp.inputs["Strength"].default_value = 0.45
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_anvil_shader():
    m = bpy.data.materials.new("v3r3_anvil_proc")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.30
    bsdf.inputs["Metallic"].default_value = 0.85
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (4, 4, 4)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Iron base w/ subtle scratches
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
    n.inputs["Scale"].default_value = 22.0
    n.inputs["Detail"].default_value = 10.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])

    iron_ramp = nodes.new("ShaderNodeValToRGB"); iron_ramp.location = (-450, 200)
    iron_ramp.color_ramp.elements[0].position = 0.30
    iron_ramp.color_ramp.elements[0].color = (0.04, 0.04, 0.05, 1)
    iron_ramp.color_ramp.elements[1].position = 0.80
    iron_ramp.color_ramp.elements[1].color = (0.18, 0.18, 0.20, 1)
    links.new(n.outputs["Fac"], iron_ramp.inputs["Fac"])
    links.new(iron_ramp.outputs["Color"], bsdf.inputs["Base Color"])

    # Polished face on top — use Pointiness inverse (ridges polished)
    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-700, -200)
    rough_ramp = nodes.new("ShaderNodeValToRGB"); rough_ramp.location = (-450, -200)
    rough_ramp.color_ramp.elements[0].position = 0.40
    rough_ramp.color_ramp.elements[0].color = (0.65, 0.65, 0.65, 1)  # rough recesses
    rough_ramp.color_ramp.elements[1].position = 0.60
    rough_ramp.color_ramp.elements[1].color = (0.10, 0.10, 0.10, 1)  # polished ridges
    links.new(geo.outputs["Pointiness"], rough_ramp.inputs["Fac"])
    links.new(rough_ramp.outputs["Color"], bsdf.inputs["Roughness"])

    # Bump
    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -550)
    bp.inputs["Strength"].default_value = 0.20
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

mat_forge = make_forge_shader()
forge.data.materials.clear(); forge.data.materials.append(mat_forge)

mat_anvil = make_anvil_shader()
anvil.data.materials.clear(); anvil.data.materials.append(mat_anvil)

# ============================================================
# STAGE 4 — BAKE DIFFUSE (one per object)
# ============================================================
print("=== STAGE 4: Bake DIFFUSE ===")
def bake_diffuse(obj, mat, name):
    img = bpy.data.images.new(f"{name}_albedo_bake", width=1024, height=1024)
    img_node = mat.node_tree.nodes.new("ShaderNodeTexImage")
    img_node.location = (1100, 400)
    img_node.image = img
    img_node.select = True
    mat.node_tree.nodes.active = img_node

    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj

    scene.cycles.bake_type = 'DIFFUSE'
    scene.render.bake.use_pass_direct = False
    scene.render.bake.use_pass_indirect = False
    scene.render.bake.use_pass_color = True
    scene.cycles.samples = 32
    print(f"Baking {name} diffuse...")
    try:
        bpy.ops.object.bake(type='DIFFUSE')
        path = os.path.join(TEX_DIR, f"{name}_albedo_1024.png")
        img.filepath_raw = path
        img.file_format = 'PNG'
        img.save()
        print(f"Baked: {path}")
        return img
    except Exception as e:
        print(f"Bake failed: {e}")
        return img

forge_albedo = bake_diffuse(forge, mat_forge, "forge")
anvil_albedo = bake_diffuse(anvil, mat_anvil, "anvil")

# ============================================================
# STAGE 5 — RETOPO LOW-POLY (both)
# ============================================================
print("=== STAGE 5: Retopo low-poly ===")
def make_low_poly(obj, name):
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.duplicate()
    lp = bpy.context.object
    lp.name = f"{name}_lp"
    for mod in list(lp.modifiers):
        lp.modifiers.remove(mod)
    dec = lp.modifiers.new("Decimate", 'DECIMATE')
    dec.ratio = 0.25
    bpy.ops.object.modifier_apply(modifier="Decimate")
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=math.radians(50), island_margin=0.02)
    bpy.ops.object.mode_set(mode='OBJECT')
    print(f"{name}_lp: {len(lp.data.polygons)} faces")
    return lp

forge_lp = make_low_poly(forge, "forge")
anvil_lp = make_low_poly(anvil, "anvil")

# ============================================================
# STAGE 6 — NORMAL BAKES
# ============================================================
print("=== STAGE 6: Normal bakes high → low ===")
def bake_normal(hp, lp, alb_img, name):
    nrm = bpy.data.images.new(f"{name}_normal_bake", width=1024, height=1024,
                               alpha=False, float_buffer=False)
    nrm.colorspace_settings.name = 'Non-Color'

    mat_lp_baked = bpy.data.materials.new(f"v3r3_{name}_baked")
    mat_lp_baked.use_nodes = True
    nt = mat_lp_baked.node_tree
    nt.nodes.clear()
    out = nt.nodes.new("ShaderNodeOutputMaterial"); out.location = (1200, 0)
    bs = nt.nodes.new("ShaderNodeBsdfPrincipled"); bs.location = (900, 0)
    nt.links.new(bs.outputs[0], out.inputs[0])
    img_a = nt.nodes.new("ShaderNodeTexImage"); img_a.location = (200, 200)
    img_a.image = alb_img
    nt.links.new(img_a.outputs["Color"], bs.inputs["Base Color"])
    img_n = nt.nodes.new("ShaderNodeTexImage"); img_n.location = (200, -200)
    img_n.image = nrm
    img_n.image.colorspace_settings.name = 'Non-Color'
    nm = nt.nodes.new("ShaderNodeNormalMap"); nm.location = (550, -200)
    nt.links.new(img_n.outputs["Color"], nm.inputs["Color"])
    nt.links.new(nm.outputs["Normal"], bs.inputs["Normal"])
    img_n.select = True
    nt.nodes.active = img_n

    lp.data.materials.clear()
    lp.data.materials.append(mat_lp_baked)

    bpy.ops.object.select_all(action='DESELECT')
    hp.select_set(True)
    lp.select_set(True)
    bpy.context.view_layer.objects.active = lp

    scene.cycles.bake_type = 'NORMAL'
    scene.render.bake.use_selected_to_active = True
    scene.render.bake.cage_extrusion = 0.04
    scene.render.bake.max_ray_distance = 0.30
    scene.cycles.samples = 16
    try:
        bpy.ops.object.bake(type='NORMAL')
        path = os.path.join(TEX_DIR, f"{name}_normal_1024.png")
        nrm.filepath_raw = path
        nrm.file_format = 'PNG'
        nrm.save()
        print(f"Baked normal: {path}")
    except Exception as e:
        print(f"Normal bake failed: {e}")
        import traceback; traceback.print_exc()
    scene.render.bake.use_selected_to_active = False
    scene.cycles.samples = 96
    return mat_lp_baked

bake_normal(forge, forge_lp, forge_albedo, "forge")
bake_normal(anvil, anvil_lp, anvil_albedo, "anvil")

# Reposition low-polys for the compare camera
forge_lp.location = (-2.0 + 8, 0, 1.0)
anvil_lp.location = (1.0 + 8, 0, 0.85)

# ============================================================
# STAGE 7 — LIGHTING + RENDERS
# ============================================================
print("=== STAGE 7: Lighting + Renders ===")

# Forge interior light (from inside the cavity — strong orange)
bpy.ops.object.light_add(type='POINT', location=(-2.0, 0, 1.10))
emb = bpy.context.object
emb.data.energy = 800
emb.data.color = (1.0, 0.40, 0.08)

# Workshop key
bpy.ops.object.light_add(type='AREA', location=(4, -8, 8))
key = bpy.context.object
key.data.energy = 2200; key.data.color = (1.0, 0.92, 0.78); key.data.size = 6

# Cool fill
bpy.ops.object.light_add(type='AREA', location=(-6, 6, 6))
fill = bpy.context.object
fill.data.energy = 600; fill.data.color = (0.55, 0.65, 0.85); fill.data.size = 6

# Floor
bpy.ops.mesh.primitive_plane_add(size=24, location=(0, 0, 0))
fl = bpy.context.object; fl.name = "floor"
mat_fl = bpy.data.materials.new("floor")
mat_fl.use_nodes = True
fbsdf = mat_fl.node_tree.nodes["Principled BSDF"]
fbsdf.inputs["Base Color"].default_value = (0.10, 0.08, 0.06, 1)
fbsdf.inputs["Roughness"].default_value = 0.85
fl.data.materials.append(mat_fl)

def add_cam(name, loc, target, lens=70, dof=4.0, fstop=4.0):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = fstop
    c.data.dof.focus_distance = dof
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_hp = add_cam("cam_hp", Vector((1, -7, 2.5)), Vector((-0.5, 0, 1.0)), lens=42, dof=8)
cam_lp = add_cam("cam_lp", Vector((9, -7, 2.5)), Vector((7.5, 0, 1.0)), lens=42, dof=8)
cam_compare = add_cam("cam_compare", Vector((4, -10, 3.5)), Vector((4, 0, 1.0)), lens=35, dof=12)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.camera = cam_hp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_forge_hp.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_forge_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_forge_compare.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# ============================================================
# STAGE 8 — GLB EXPORT
# ============================================================
print("=== STAGE 8: GLB export ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Export both lp meshes to a single glb
bpy.ops.object.select_all(action='DESELECT')
forge_lp.select_set(True)
anvil_lp.select_set(True)
bpy.context.view_layer.objects.active = forge_lp

out_path = os.path.join(EXPORT_DIR, "forge_anvil_r3_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 3 Epic R3-08 Forge + Anvil complete ===")
