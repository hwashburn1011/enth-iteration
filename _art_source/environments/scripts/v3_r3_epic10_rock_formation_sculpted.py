"""
Expansion V3 — ROUND 3 — Epic R3-10 — Hero Rock Formation
=========================================================
Single-mesh boulder cluster (NOT multiple parented spheres).
A subdivided icosphere base is deformed via per-vertex
displacement + 3 sub-boulder bumps blended into the silhouette,
then real cracks are carved into the surface via bmesh inset.

Pipeline:
  1. High-subdiv icosphere
  2. Multi-center proximity-falloff displacement (3 boulder peaks)
  3. Per-vert noise jitter for natural surface
  4. Carve 5 surface cracks via inset_individual + push deep
  5. Inset 3 weathered hollows (small impact craters)
  6. Multires 2 levels
  7. UV unwrap + granite procedural shader (mica speckle + lichen)
  8. Bake DIFFUSE → 1024 PNG, decimate retopo, normal bake high→low
  9. Renders + GLB
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(310)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/v3_r3_rock_formation.blend"
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
bg.inputs["Color"].default_value = (0.50, 0.55, 0.65, 1)
bg.inputs["Strength"].default_value = 1.2

# ============================================================
# STAGE 1 — ROCK FORMATION BASE
# ============================================================
print("=== STAGE 1: Rock formation base ===")

bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=4, radius=1.5, location=(0, 0, 1.0))
hero = bpy.context.object
hero.name = "rock_formation_hp"

bm = bmesh.new()
bm.from_mesh(hero.data)

# Base shape: wider than tall (formation rests on the ground)
for v in bm.verts:
    v.co.z *= 0.75
    v.co.x *= 1.20
    v.co.y *= 1.10

# === 3 sub-boulder peaks: proximity-driven displacement ===
PEAKS = [
    (Vector((0.6, 0.4, 0.6)),  0.55),   # main peak
    (Vector((-0.8, -0.3, 0.4)), 0.45),  # left bump
    (Vector((0.2, -0.7, 0.3)),  0.35),  # back bump
]
for v in bm.verts:
    total_disp = 0.0
    for peak_pos, peak_strength in PEAKS:
        d = (v.co - peak_pos).length
        falloff = max(0, 1.0 - d / 1.4)  # falloff radius
        total_disp += peak_strength * (falloff ** 2)
    v.co += v.normal * total_disp

# === Per-vertex noise jitter for natural surface ===
for v in bm.verts:
    seed_val = hash((round(v.co.x, 1), round(v.co.y, 1), round(v.co.z, 1))) & 0xFFFF
    random.seed(seed_val)
    v.co += v.normal * random.uniform(-0.04, 0.06)

def closest_face(bm, target):
    best, best_d = None, 1e9
    for f in bm.faces:
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d; best = f
    return best

# === 5 surface cracks (deep insets) ===
print("Carving cracks...")
CRACK_TARGETS = [
    Vector((0.7, 0.6, 1.4)),
    Vector((-0.9, 0.0, 0.9)),
    Vector((0.4, -0.8, 0.8)),
    Vector((-0.4, 0.7, 0.4)),
    Vector((1.1, -0.2, 0.7)),
]
for target in CRACK_TARGETS:
    cf = closest_face(bm, target)
    if cf:
        res = bmesh.ops.inset_individual(bm, faces=[cf], thickness=0.06, depth=0.0)
        new_f = res['faces'][0] if res.get('faces') else cf
        for v in new_f.verts:
            v.co -= cf.normal * 0.10
        # Stretch the inset along one axis to look more crack-like
        avg = sum((v.co for v in new_f.verts), Vector()) / len(new_f.verts)
        for v in new_f.verts:
            offset = v.co - avg
            offset.x *= 1.6
            v.co = avg + offset

# === 3 small impact craters ===
print("Carving impact hollows...")
HOLLOW_TARGETS = [
    Vector((0.0, 1.0, 0.5)),
    Vector((-1.2, -0.5, 0.6)),
    Vector((0.9, 0.2, 1.1)),
]
for target in HOLLOW_TARGETS:
    hf = closest_face(bm, target)
    if hf:
        res = bmesh.ops.inset_individual(bm, faces=[hf], thickness=0.10, depth=0.0)
        new_f = res['faces'][0] if res.get('faces') else hf
        for v in new_f.verts:
            v.co -= hf.normal * 0.08

bm.normal_update()
bm.to_mesh(hero.data)
bm.free()
hero.data.update()
for poly in hero.data.polygons:
    poly.use_smooth = True

# Multires
print("Adding multires...")
hero.modifiers.new("Multires", 'MULTIRES')
bpy.context.view_layer.objects.active = hero
for _ in range(2):
    bpy.ops.object.multires_subdivide(modifier="Multires", mode='CATMULL_CLARK')

# ============================================================
# STAGE 2 — UV UNWRAP
# ============================================================
print("=== STAGE 2: UV unwrap ===")
bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
bpy.context.view_layer.objects.active = hero
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.02)
bpy.ops.object.mode_set(mode='OBJECT')

# ============================================================
# STAGE 3 — GRANITE SHADER (mica speckle + lichen patches)
# ============================================================
print("=== STAGE 3: Granite shader ===")

def make_granite_shader():
    m = bpy.data.materials.new("v3r3_granite_proc")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.65
    bsdf.inputs["Metallic"].default_value = 0.10
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1400, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1200, 0)
    mp.inputs["Scale"].default_value = (3.5, 3.5, 3.5)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Granite base — large warm noise
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-900, 200)
    n.inputs["Scale"].default_value = 5.0
    n.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])

    granite_ramp = nodes.new("ShaderNodeValToRGB"); granite_ramp.location = (-650, 200)
    cr = granite_ramp.color_ramp
    cr.elements[0].position = 0.30
    cr.elements[0].color = (0.32, 0.30, 0.28, 1)   # mid grey
    cr.elements[1].position = 0.70
    cr.elements[1].color = (0.55, 0.50, 0.45, 1)   # light grey
    el2 = cr.elements.new(0.85)
    el2.color = (0.65, 0.55, 0.45, 1)               # warm highlights
    links.new(n.outputs["Fac"], granite_ramp.inputs["Fac"])

    # Mica speckle: high-freq voronoi F1
    mica = nodes.new("ShaderNodeTexVoronoi"); mica.location = (-900, 0)
    mica.feature = 'F1'
    mica.inputs["Scale"].default_value = 60.0
    links.new(mp.outputs["Vector"], mica.inputs["Vector"])

    mica_ramp = nodes.new("ShaderNodeValToRGB"); mica_ramp.location = (-650, 0)
    mica_ramp.color_ramp.elements[0].position = 0.05
    mica_ramp.color_ramp.elements[0].color = (1, 1, 1, 1)
    mica_ramp.color_ramp.elements[1].position = 0.20
    mica_ramp.color_ramp.elements[1].color = (0, 0, 0, 1)
    links.new(mica.outputs["Distance"], mica_ramp.inputs["Fac"])

    mica_color = nodes.new("ShaderNodeRGB"); mica_color.location = (-650, -150)
    mica_color.outputs[0].default_value = (0.85, 0.80, 0.70, 1)

    mica_mix = nodes.new("ShaderNodeMix"); mica_mix.data_type = 'RGBA'; mica_mix.location = (-200, 100)
    links.new(mica_ramp.outputs["Color"], mica_mix.inputs["Factor"])
    links.new(granite_ramp.outputs["Color"], mica_mix.inputs[6])
    links.new(mica_color.outputs[0], mica_mix.inputs[7])

    # Lichen patches via larger noise
    lichen = nodes.new("ShaderNodeTexNoise"); lichen.location = (-900, -250)
    lichen.inputs["Scale"].default_value = 2.5
    lichen.inputs["Detail"].default_value = 4.0
    links.new(mp.outputs["Vector"], lichen.inputs["Vector"])
    lichen_ramp = nodes.new("ShaderNodeValToRGB"); lichen_ramp.location = (-650, -250)
    lichen_ramp.color_ramp.elements[0].position = 0.55
    lichen_ramp.color_ramp.elements[0].color = (0, 0, 0, 1)
    lichen_ramp.color_ramp.elements[1].position = 0.70
    lichen_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(lichen.outputs["Fac"], lichen_ramp.inputs["Fac"])

    lichen_color = nodes.new("ShaderNodeRGB"); lichen_color.location = (-650, -400)
    lichen_color.outputs[0].default_value = (0.45, 0.55, 0.20, 1)  # yellow-green lichen

    lichen_mix = nodes.new("ShaderNodeMix"); lichen_mix.data_type = 'RGBA'; lichen_mix.location = (100, 0)
    links.new(lichen_ramp.outputs["Color"], lichen_mix.inputs["Factor"])
    links.new(mica_mix.outputs[2], lichen_mix.inputs[6])
    links.new(lichen_color.outputs[0], lichen_mix.inputs[7])

    links.new(lichen_mix.outputs[2], bsdf.inputs["Base Color"])

    # Bump
    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -550)
    bp.inputs["Strength"].default_value = 0.40
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])

    # Roughness via lichen mask (lichen rougher than stone)
    rough_ramp = nodes.new("ShaderNodeValToRGB"); rough_ramp.location = (-200, -750)
    rough_ramp.color_ramp.elements[0].position = 0.0
    rough_ramp.color_ramp.elements[0].color = (0.55, 0.55, 0.55, 1)
    rough_ramp.color_ramp.elements[1].position = 1.0
    rough_ramp.color_ramp.elements[1].color = (0.95, 0.95, 0.95, 1)
    links.new(lichen_ramp.outputs["Color"], rough_ramp.inputs["Fac"])
    links.new(rough_ramp.outputs["Color"], bsdf.inputs["Roughness"])
    return m

mat_proc = make_granite_shader()
hero.data.materials.clear()
hero.data.materials.append(mat_proc)

# ============================================================
# STAGE 4 — BAKE DIFFUSE
# ============================================================
print("=== STAGE 4: Bake DIFFUSE ===")
bake_albedo = bpy.data.images.new("rock_formation_albedo_bake", width=1024, height=1024)
img_node_a = mat_proc.node_tree.nodes.new("ShaderNodeTexImage")
img_node_a.location = (1100, 400)
img_node_a.image = bake_albedo
img_node_a.select = True
mat_proc.node_tree.nodes.active = img_node_a

scene.cycles.bake_type = 'DIFFUSE'
scene.render.bake.use_pass_direct = False
scene.render.bake.use_pass_indirect = False
scene.render.bake.use_pass_color = True
scene.cycles.samples = 32

bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
bpy.context.view_layer.objects.active = hero

print("Baking diffuse...")
try:
    bpy.ops.object.bake(type='DIFFUSE')
    bake_path = os.path.join(TEX_DIR, "rock_formation_albedo_1024.png")
    bake_albedo.filepath_raw = bake_path
    bake_albedo.file_format = 'PNG'
    bake_albedo.save()
    print(f"Baked albedo: {bake_path}")
except Exception as e:
    print(f"Bake failed: {e}")

# ============================================================
# STAGE 5 — RETOPO
# ============================================================
print("=== STAGE 5: Retopo low-poly ===")
bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
bpy.context.view_layer.objects.active = hero
bpy.ops.object.duplicate()
low_poly = bpy.context.object
low_poly.name = "rock_formation_lp"

for mod in list(low_poly.modifiers):
    low_poly.modifiers.remove(mod)
dec = low_poly.modifiers.new("Decimate", 'DECIMATE')
dec.ratio = 0.18
bpy.ops.object.modifier_apply(modifier="Decimate")

bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.02)
bpy.ops.object.mode_set(mode='OBJECT')

print(f"Low-poly: {len(low_poly.data.polygons)} faces")

# ============================================================
# STAGE 6 — NORMAL BAKE
# ============================================================
print("=== STAGE 6: Normal bake high → low ===")
bake_normal = bpy.data.images.new("rock_formation_normal_bake", width=1024, height=1024,
                                    alpha=False, float_buffer=False)
bake_normal.colorspace_settings.name = 'Non-Color'

mat_lp = bpy.data.materials.new("v3r3_rock_formation_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (1200, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (900, 0)
bsdf_lp.inputs["Roughness"].default_value = 0.70
ntlp.links.new(bsdf_lp.outputs[0], out_lp.inputs[0])

img_alb_lp = ntlp.nodes.new("ShaderNodeTexImage"); img_alb_lp.location = (200, 200)
img_alb_lp.image = bake_albedo
ntlp.links.new(img_alb_lp.outputs["Color"], bsdf_lp.inputs["Base Color"])

img_nrm_lp = ntlp.nodes.new("ShaderNodeTexImage"); img_nrm_lp.location = (200, -200)
img_nrm_lp.image = bake_normal
img_nrm_lp.image.colorspace_settings.name = 'Non-Color'
nrm_node = ntlp.nodes.new("ShaderNodeNormalMap"); nrm_node.location = (550, -200)
ntlp.links.new(img_nrm_lp.outputs["Color"], nrm_node.inputs["Color"])
ntlp.links.new(nrm_node.outputs["Normal"], bsdf_lp.inputs["Normal"])

img_nrm_lp.select = True
ntlp.nodes.active = img_nrm_lp

low_poly.data.materials.clear()
low_poly.data.materials.append(mat_lp)

print("Performing selected-to-active NORMAL bake...")
bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
low_poly.select_set(True)
bpy.context.view_layer.objects.active = low_poly

scene.cycles.bake_type = 'NORMAL'
scene.render.bake.use_selected_to_active = True
scene.render.bake.cage_extrusion = 0.05
scene.render.bake.max_ray_distance = 0.30
scene.cycles.samples = 16

try:
    bpy.ops.object.bake(type='NORMAL')
    nrm_path = os.path.join(TEX_DIR, "rock_formation_normal_1024.png")
    bake_normal.filepath_raw = nrm_path
    bake_normal.file_format = 'PNG'
    bake_normal.save()
    print(f"Baked normal: {nrm_path}")
except Exception as e:
    print(f"Normal bake failed: {e}")
    import traceback; traceback.print_exc()

scene.render.bake.use_selected_to_active = False
scene.cycles.samples = 96

low_poly.location = (5.5, 0, 1.0)

# ============================================================
# STAGE 7 — LIGHTING + RENDERS
# ============================================================
print("=== STAGE 7: Lighting + Renders ===")

bpy.ops.object.light_add(type='SUN', location=(0, 0, 12))
sun = bpy.context.object
sun.data.energy = 4.5
sun.data.color = (1.0, 0.92, 0.78)
sun.rotation_euler = (math.radians(50), math.radians(20), 0)

bpy.ops.object.light_add(type='AREA', location=(-7, 7, 7))
fill = bpy.context.object
fill.data.energy = 700; fill.data.color = (0.55, 0.70, 0.95); fill.data.size = 8

bpy.ops.object.light_add(type='AREA', location=(8, -3, 4))
bounce = bpy.context.object
bounce.data.energy = 350; bounce.data.color = (1.0, 0.85, 0.55); bounce.data.size = 6

bpy.ops.mesh.primitive_plane_add(size=24, location=(0, 0, 0))
gnd = bpy.context.object; gnd.name = "ground"
mat_g = bpy.data.materials.new("ground")
mat_g.use_nodes = True
gbsdf = mat_g.node_tree.nodes["Principled BSDF"]
gbsdf.inputs["Base Color"].default_value = (0.18, 0.20, 0.10, 1)
gbsdf.inputs["Roughness"].default_value = 0.90
gnd.data.materials.append(mat_g)

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

cam_hp = add_cam("cam_hp", Vector((-2, -6, 2.5)), Vector((0, 0, 1.0)), lens=50, dof=6)
cam_lp = add_cam("cam_lp", Vector((4, -6, 2.5)), Vector((5.5, 0, 1.0)), lens=50, dof=6)
cam_compare = add_cam("cam_compare", Vector((2.5, -9, 3.0)), Vector((2.5, 0, 1.0)), lens=42, dof=10)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.camera = cam_hp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_rock_formation_hp.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_rock_formation_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_rock_formation_compare.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# ============================================================
# STAGE 8 — GLB EXPORT
# ============================================================
print("=== STAGE 8: GLB export ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

bpy.ops.object.select_all(action='DESELECT')
low_poly.select_set(True)
bpy.context.view_layer.objects.active = low_poly

out_path = os.path.join(EXPORT_DIR, "rock_formation_r3_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 3 Epic R3-10 Rock Formation complete ===")
