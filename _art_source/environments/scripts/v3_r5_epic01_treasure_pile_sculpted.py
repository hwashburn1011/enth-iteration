"""
Expansion V3 — ROUND 5 — Epic R5-01 — Hero Treasure Pile Sculpted
=================================================================
Boss-arena treasure pile. Single-mesh sculpt of a gold coin mound
with embedded gems on top. R3 quality bar.

Pipeline:
  1. Icosphere base flattened on bottom into a low mound
  2. Per-vertex coin-stack noise displacement (irregular but coin-pile shaped)
  3. 8 coin disc bumps extruded from mound surface (small flat coins)
  4. 3 gem inset cuts on top of the mound (negative geometry where gems sit)
  5. Bevel + cube_project UV + multires 1
  6. Gold + emission shader (Pointiness drives polish on coin ridges)
  7. Bake albedo + normal high→low
  8. 3 separate gem icospheres on top (red/green/blue) with emission
  9. Cycles point light at the center for the gold glow
 10. Renders + GLB
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(501)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/v3_r5_treasure_pile.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/renders"
TEX_DIR      = "C:/Users/hwash/Documents/enth-iteration/_art_source/textures/baked"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/exports"
for d in [RENDER_DIR, TEX_DIR, EXPORT_DIR]:
    os.makedirs(d, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 128
scene.cycles.use_denoising = True
scene.cycles.device = 'CPU'
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.view_settings.look = 'AgX - High Contrast'

scene.world = bpy.data.worlds.new("v3r5_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.04, 0.03, 0.02, 1)
bg.inputs["Strength"].default_value = 0.3

# ============================================================
# STAGE 1 — TREASURE MOUND BASE
# ============================================================
print("=== STAGE 1: Treasure mound base ===")

bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=4, radius=0.50, location=(0, 0, 0.20))
hero = bpy.context.object
hero.name = "treasure_pile_hp"

bm = bmesh.new()
bm.from_mesh(hero.data)

# Flatten into a mound — bottom verts pinned to z=0, top verts squashed to ~0.40m height
for v in bm.verts:
    if v.co.z < 0:
        v.co.z *= 0.10
    else:
        v.co.z *= 0.85
    # Per-vertex coin-stack noise
    seed_val = hash((round(v.co.x, 1), round(v.co.y, 1), round(v.co.z, 1))) & 0xFFFF
    random.seed(seed_val)
    v.co += v.normal * random.uniform(-0.02, 0.05)

def closest_face(bm, target):
    best, best_d = None, 1e9
    for f in bm.faces:
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d; best = f
    return best

# === 8 coin disc bumps extruded from the mound surface ===
print("Extruding coin discs...")
COIN_TARGETS = []
for i in range(8):
    angle = i * (math.tau / 8) + random.uniform(-0.1, 0.1)
    radius = random.uniform(0.20, 0.40)
    height = random.uniform(0.20, 0.40)
    COIN_TARGETS.append(Vector((math.cos(angle) * radius, math.sin(angle) * radius, height)))

for target in COIN_TARGETS:
    cf = closest_face(bm, target)
    if cf:
        res = bmesh.ops.inset_individual(bm, faces=[cf], thickness=0.02, depth=0.0)
        new_f = res['faces'][0] if res.get('faces') else cf
        for v in new_f.verts:
            v.co += cf.normal * 0.012  # raise the coin disc

bm.normal_update()
bm.faces.ensure_lookup_table()

# === 3 gem inset cuts on top — these depressions will hold gems ===
print("Carving gem inset slots...")
GEM_SLOTS = [
    Vector((-0.10, 0.10, 0.45)),
    Vector((0.15, -0.05, 0.45)),
    Vector((0.00, -0.15, 0.45)),
]
for slot in GEM_SLOTS:
    sf = closest_face(bm, slot)
    if sf:
        res = bmesh.ops.inset_individual(bm, faces=[sf], thickness=0.04, depth=0.0)
        new_f = res['faces'][0] if res.get('faces') else sf
        for v in new_f.verts:
            v.co.z -= 0.025  # carve depression

bm.normal_update()
bm.to_mesh(hero.data)
bm.free()
hero.data.update()
for poly in hero.data.polygons:
    poly.use_smooth = True

bev = hero.modifiers.new("Bevel", 'BEVEL')
bev.width = 0.005
bev.segments = 2

# ============================================================
# STAGE 2 — UV UNWRAP
# ============================================================
print("=== STAGE 2: UV unwrap ===")
bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
bpy.context.view_layer.objects.active = hero
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.cube_project(cube_size=2.0)
bpy.ops.object.mode_set(mode='OBJECT')

# ============================================================
# STAGE 2.5 — Multires after unwrap
# ============================================================
hero.modifiers.new("Multires", 'MULTIRES')
bpy.context.view_layer.objects.active = hero
bpy.ops.object.multires_subdivide(modifier="Multires", mode='CATMULL_CLARK')

# ============================================================
# STAGE 3 — GOLD SHADER w/ Pointiness coin-edge polish
# ============================================================
print("=== STAGE 3: Gold shader ===")

def make_gold_shader():
    m = bpy.data.materials.new("v3r5_treasure_proc")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.25
    bsdf.inputs["Metallic"].default_value = 1.0
    bsdf.inputs["Emission Strength"].default_value = 4.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (5, 5, 5)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
    n.inputs["Scale"].default_value = 18.0
    n.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])

    gold_ramp = nodes.new("ShaderNodeValToRGB"); gold_ramp.location = (-450, 200)
    cr = gold_ramp.color_ramp
    cr.elements[0].position = 0.30
    cr.elements[0].color = (0.65, 0.40, 0.10, 1)
    cr.elements[1].position = 0.70
    cr.elements[1].color = (0.95, 0.75, 0.20, 1)
    links.new(n.outputs["Fac"], gold_ramp.inputs["Fac"])
    links.new(gold_ramp.outputs["Color"], bsdf.inputs["Base Color"])

    # Pointiness drives polish: coin ridges + edges shinier
    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-700, -200)
    pointy_ramp = nodes.new("ShaderNodeValToRGB"); pointy_ramp.location = (-450, -200)
    pointy_ramp.color_ramp.elements[0].position = 0.40
    pointy_ramp.color_ramp.elements[0].color = (1, 1, 1, 1)
    pointy_ramp.color_ramp.elements[1].position = 0.65
    pointy_ramp.color_ramp.elements[1].color = (0, 0, 0, 1)
    links.new(geo.outputs["Pointiness"], pointy_ramp.inputs["Fac"])

    rough_ramp = nodes.new("ShaderNodeValToRGB"); rough_ramp.location = (100, -200)
    rough_ramp.color_ramp.elements[0].position = 0.0
    rough_ramp.color_ramp.elements[0].color = (0.10, 0.10, 0.10, 1)
    rough_ramp.color_ramp.elements[1].position = 1.0
    rough_ramp.color_ramp.elements[1].color = (0.45, 0.45, 0.45, 1)
    links.new(pointy_ramp.outputs["Color"], rough_ramp.inputs["Fac"])
    links.new(rough_ramp.outputs["Color"], bsdf.inputs["Roughness"])

    # Subtle warm emission for the "treasure glow"
    em_color = nodes.new("ShaderNodeRGB"); em_color.location = (-450, -380)
    em_color.outputs[0].default_value = (1.0, 0.65, 0.20, 1)
    links.new(em_color.outputs[0], bsdf.inputs["Emission Color"])

    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -550)
    bp.inputs["Strength"].default_value = 0.30
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

mat_proc = make_gold_shader()
hero.data.materials.clear()
hero.data.materials.append(mat_proc)

# ============================================================
# STAGE 4 — BAKE DIFFUSE
# ============================================================
print("=== STAGE 4: Bake DIFFUSE ===")
bake_albedo = bpy.data.images.new("treasure_pile_albedo_bake", width=1024, height=1024)
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
    bake_path = os.path.join(TEX_DIR, "treasure_pile_albedo_1024.png")
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
low_poly.name = "treasure_pile_lp"
for mod in list(low_poly.modifiers):
    low_poly.modifiers.remove(mod)
dec = low_poly.modifiers.new("Decimate", 'DECIMATE')
dec.ratio = 0.30
bpy.ops.object.modifier_apply(modifier="Decimate")
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.cube_project(cube_size=2.0)
bpy.ops.object.mode_set(mode='OBJECT')

# ============================================================
# STAGE 6 — NORMAL BAKE
# ============================================================
print("=== STAGE 6: Normal bake ===")
bake_normal = bpy.data.images.new("treasure_pile_normal_bake", width=1024, height=1024,
                                    alpha=False, float_buffer=False)
bake_normal.colorspace_settings.name = 'Non-Color'
mat_lp = bpy.data.materials.new("v3r5_treasure_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (1200, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (900, 0)
bsdf_lp.inputs["Roughness"].default_value = 0.25
bsdf_lp.inputs["Metallic"].default_value = 1.0
ntlp.links.new(bsdf_lp.outputs[0], out_lp.inputs[0])
img_alb_lp = ntlp.nodes.new("ShaderNodeTexImage"); img_alb_lp.location = (200, 200)
img_alb_lp.image = bake_albedo
ntlp.links.new(img_alb_lp.outputs["Color"], bsdf_lp.inputs["Base Color"])
img_n = ntlp.nodes.new("ShaderNodeTexImage"); img_n.location = (200, -200)
img_n.image = bake_normal
img_n.image.colorspace_settings.name = 'Non-Color'
nrm_node = ntlp.nodes.new("ShaderNodeNormalMap"); nrm_node.location = (550, -200)
ntlp.links.new(img_n.outputs["Color"], nrm_node.inputs["Color"])
ntlp.links.new(nrm_node.outputs["Normal"], bsdf_lp.inputs["Normal"])
img_n.select = True
ntlp.nodes.active = img_n
low_poly.data.materials.clear()
low_poly.data.materials.append(mat_lp)

bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
low_poly.select_set(True)
bpy.context.view_layer.objects.active = low_poly
scene.cycles.bake_type = 'NORMAL'
scene.render.bake.use_selected_to_active = True
scene.render.bake.cage_extrusion = 0.02
scene.render.bake.max_ray_distance = 0.10
scene.cycles.samples = 16
try:
    bpy.ops.object.bake(type='NORMAL')
    nrm_path = os.path.join(TEX_DIR, "treasure_pile_normal_1024.png")
    bake_normal.filepath_raw = nrm_path
    bake_normal.file_format = 'PNG'
    bake_normal.save()
    print(f"Baked normal: {nrm_path}")
except Exception as e:
    print(f"Normal bake failed: {e}")
scene.render.bake.use_selected_to_active = False
scene.cycles.samples = 128

low_poly.location = (1.5, 0, 0.20)

# ============================================================
# STAGE 7 — GEM ICOSPHERES on top of the mound
# ============================================================
print("=== STAGE 7: Gem icospheres ===")
gem_specs = [
    (Vector((-0.10, 0.10, 0.42)), (1.0, 0.10, 0.10, 1)),  # red
    (Vector((0.15, -0.05, 0.42)), (0.10, 0.85, 0.30, 1)),  # green
    (Vector((0.00, -0.15, 0.42)), (0.20, 0.40, 1.0, 1)),  # blue
]
gem_objects = []
for i, (pos, color) in enumerate(gem_specs):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.05, location=pos)
    gem = bpy.context.object
    gem.name = f"treasure_gem_{i}"
    mat = bpy.data.materials.new(f"v3r5_gem_{i}")
    mat.use_nodes = True
    nt = mat.node_tree
    nt.nodes.clear()
    out = nt.nodes.new("ShaderNodeOutputMaterial"); out.location = (400, 0)
    bsdf = nt.nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (100, 0)
    bsdf.inputs["Base Color"].default_value = color
    bsdf.inputs["Roughness"].default_value = 0.05
    bsdf.inputs["IOR"].default_value = 1.55
    bsdf.inputs["Transmission Weight"].default_value = 0.30
    bsdf.inputs["Coat Weight"].default_value = 0.85
    bsdf.inputs["Emission Color"].default_value = color
    bsdf.inputs["Emission Strength"].default_value = 5.0
    nt.links.new(bsdf.outputs[0], out.inputs[0])
    gem.data.materials.append(mat)
    gem_objects.append(gem)

# Cycles point light at the center for treasure glow
bpy.ops.object.light_add(type='POINT', location=(0, 0, 0.40))
glow = bpy.context.object
glow.name = "treasure_glow_light"
glow.data.energy = 40
glow.data.color = (1.0, 0.75, 0.30)

# ============================================================
# STAGE 8 — RENDERS
# ============================================================
print("=== STAGE 8: Renders ===")

bpy.ops.object.light_add(type='AREA', location=(2, -3, 3))
key = bpy.context.object
key.data.energy = 1200; key.data.color = (1.0, 0.92, 0.78); key.data.size = 3

bpy.ops.object.light_add(type='AREA', location=(-3, -2, 2))
fill = bpy.context.object
fill.data.energy = 400; fill.data.color = (0.55, 0.65, 0.95); fill.data.size = 4

bpy.ops.mesh.primitive_plane_add(size=6, location=(0, 0, 0))
fl = bpy.context.object; fl.name = "floor"
mat_fl = bpy.data.materials.new("floor")
mat_fl.use_nodes = True
fbsdf = mat_fl.node_tree.nodes["Principled BSDF"]
fbsdf.inputs["Base Color"].default_value = (0.05, 0.04, 0.03, 1)
fbsdf.inputs["Roughness"].default_value = 0.30
fbsdf.inputs["Metallic"].default_value = 0.20
fl.data.materials.append(mat_fl)

def add_cam(name, loc, target, lens=85, dof=1.5, fstop=4.0):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = fstop
    c.data.dof.focus_distance = dof
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_hp = add_cam("cam_hp", Vector((0, -1.5, 0.7)), Vector((0, 0, 0.3)), lens=85, dof=1.5)
cam_lp = add_cam("cam_lp", Vector((1.5, -1.5, 0.7)), Vector((1.5, 0, 0.3)), lens=85, dof=1.5)
cam_compare = add_cam("cam_compare", Vector((0.75, -2.0, 0.9)), Vector((0.75, 0, 0.3)), lens=60, dof=2.0)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.camera = cam_hp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r5_treasure_pile_hp.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r5_treasure_pile_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r5_treasure_pile_compare.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# ============================================================
# STAGE 9 — GLB EXPORT
# ============================================================
print("=== STAGE 9: GLB export ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

bpy.ops.object.select_all(action='DESELECT')
low_poly.select_set(True)
for g in gem_objects:
    g.select_set(True)
bpy.context.view_layer.objects.active = low_poly

out_path = os.path.join(EXPORT_DIR, "treasure_pile_r5_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 5 Epic R5-01 Treasure Pile complete ===")
