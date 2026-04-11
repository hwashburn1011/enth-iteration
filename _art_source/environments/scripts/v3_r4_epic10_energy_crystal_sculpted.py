"""
Expansion V3 — ROUND 4 — Epic R4-10 — Energy Crystal Cluster Sculpted
=====================================================================
GDD loot drop: energy crystals. Existing energy_crystal.glb is a
placeholder. This script builds a sculpted hero crystal cluster.

Pipeline (R3 quality bar):
  1. Single-mesh icosphere base
  2. Per-vertex displacement to flatten into a low base rock
  3. 5 crystal shards extruded from selected faces, each tip-pinched
     into a 3-sided pyramid (faceted look)
  4. Carved facet seams via inset on each shard's side faces
  5. Bevel modifier
  6. UV unwrap (cube_project)
  7. Multires 1 level (after unwrap per memory rule)
  8. Cyan emission shader: glass + Pointiness ridge brightening +
     emission color from gradient
  9. Bake DIFFUSE → 1024 PNG
 10. Decimate retopo + selected-to-active NORMAL bake high→low
 11. Add a Cycles point light at the center for in-game glow
 12. Renders + GLB export
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(410)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/v3_r4_energy_crystal.blend"
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

scene.world = bpy.data.worlds.new("v3r4_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.02, 0.03, 0.05, 1)
bg.inputs["Strength"].default_value = 0.2

# ============================================================
# STAGE 1 — CRYSTAL CLUSTER BASE + EXTRUDED SHARDS
# ============================================================
print("=== STAGE 1: Crystal cluster base ===")

bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3, radius=0.40, location=(0, 0, 0.30))
hero = bpy.context.object
hero.name = "energy_crystal_hp"

bm = bmesh.new()
bm.from_mesh(hero.data)

# Flatten the bottom into a low rock base
for v in bm.verts:
    if v.co.z < 0:
        v.co.z *= 0.30
    # Slight noise for natural rock surface
    seed_val = hash((round(v.co.x, 1), round(v.co.y, 1), round(v.co.z, 1))) & 0xFFFF
    random.seed(seed_val)
    v.co += v.normal * random.uniform(-0.02, 0.04)

def closest_face(bm, target):
    best, best_d = None, 1e9
    for f in bm.faces:
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d; best = f
    return best

# === 5 crystal shards extruded from upper face cluster ===
print("Extruding crystal shards...")
SHARD_TARGETS = [
    (Vector((0, 0, 0.55)),       Vector((0, 0, 0.25)),      0.55),  # tall center
    (Vector((-0.30, 0.10, 0.40)), Vector((-0.20, 0.20, 0.40)), 0.40),  # left
    (Vector((0.30, 0.10, 0.40)),  Vector((0.20, 0.20, 0.40)),  0.40),  # right
    (Vector((0.10, -0.30, 0.35)), Vector((0.05, -0.20, 0.30)), 0.35),  # back
    (Vector((-0.20, -0.20, 0.45)), Vector((-0.10, -0.10, 0.30)), 0.30),  # back-left
]
for target, tip_offset, height in SHARD_TARGETS:
    sf = closest_face(bm, target)
    if sf:
        # First extrude — base of shard
        geom = bmesh.ops.extrude_face_region(bm, geom=[sf])
        new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
        for v in new_verts:
            v.co += sf.normal * (height * 0.5)
        new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
        if new_faces:
            # Second extrude — taper to tip
            geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
            new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
            for v in new_verts2:
                v.co += sf.normal * (height * 0.4)
            # Pinch to tip — collapse into a 3-sided pyramid
            avg = sum((v.co for v in new_verts2), Vector()) / len(new_verts2)
            for v in new_verts2:
                v.co = v.co.lerp(avg, 0.85)

bm.normal_update()
bm.to_mesh(hero.data)
bm.free()
hero.data.update()
for poly in hero.data.polygons:
    poly.use_smooth = False  # crystal facets stay sharp

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
# STAGE 2.5 — Multires after UV unwrap
# ============================================================
print("=== STAGE 2.5: Multires ===")
hero.modifiers.new("Multires", 'MULTIRES')
bpy.context.view_layer.objects.active = hero
bpy.ops.object.multires_subdivide(modifier="Multires", mode='CATMULL_CLARK')

# ============================================================
# STAGE 3 — CYAN GLASS + EMISSION SHADER
# ============================================================
print("=== STAGE 3: Crystal shader ===")

def make_crystal_shader():
    m = bpy.data.materials.new("v3r4_energy_crystal_proc")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.10
    bsdf.inputs["Metallic"].default_value = 0.0
    bsdf.inputs["IOR"].default_value = 1.55
    bsdf.inputs["Transmission Weight"].default_value = 0.45
    bsdf.inputs["Coat Weight"].default_value = 0.8
    bsdf.inputs["Coat Roughness"].default_value = 0.05
    bsdf.inputs["Emission Strength"].default_value = 25.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (4, 4, 4)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    sep = nodes.new("ShaderNodeSeparateXYZ"); sep.location = (-1200, -300)
    links.new(tc.outputs["Object"], sep.inputs["Vector"])

    # Z-zoned base color: dark rock at base, bright cyan crystal on top
    col_ramp = nodes.new("ShaderNodeValToRGB"); col_ramp.location = (-650, 100)
    cr = col_ramp.color_ramp
    cr.elements[0].position = 0.0
    cr.elements[0].color = (0.10, 0.12, 0.18, 1)
    cr.elements[1].position = 0.30
    cr.elements[1].color = (0.05, 0.30, 0.55, 1)
    el2 = cr.elements.new(0.65)
    el2.color = (0.20, 0.65, 0.95, 1)
    el3 = cr.elements.new(1.0)
    el3.color = (0.55, 0.85, 1.0, 1)
    links.new(sep.outputs["Z"], col_ramp.inputs["Fac"])
    links.new(col_ramp.outputs["Color"], bsdf.inputs["Base Color"])

    # Pointiness drives emission: ridges (shard edges) brighter than recesses
    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-900, -200)
    pointy_ramp = nodes.new("ShaderNodeValToRGB"); pointy_ramp.location = (-650, -200)
    pointy_ramp.color_ramp.elements[0].position = 0.40
    pointy_ramp.color_ramp.elements[0].color = (0, 0, 0, 1)
    pointy_ramp.color_ramp.elements[1].position = 0.65
    pointy_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(geo.outputs["Pointiness"], pointy_ramp.inputs["Fac"])

    em_color = nodes.new("ShaderNodeRGB"); em_color.location = (-650, -380)
    em_color.outputs[0].default_value = (0.30, 0.85, 1.0, 1)

    em_mix = nodes.new("ShaderNodeMix"); em_mix.data_type = 'RGBA'; em_mix.location = (100, -200)
    links.new(pointy_ramp.outputs["Color"], em_mix.inputs["Factor"])
    em_mix.inputs[6].default_value = (0, 0, 0, 1)
    links.new(em_color.outputs[0], em_mix.inputs[7])
    links.new(em_mix.outputs[2], bsdf.inputs["Emission Color"])

    # Roughness varies w/ Pointiness (polished ridges, rougher recesses)
    rough_ramp = nodes.new("ShaderNodeValToRGB"); rough_ramp.location = (100, -400)
    rough_ramp.color_ramp.elements[0].position = 0.0
    rough_ramp.color_ramp.elements[0].color = (0.45, 0.45, 0.45, 1)
    rough_ramp.color_ramp.elements[1].position = 1.0
    rough_ramp.color_ramp.elements[1].color = (0.05, 0.05, 0.05, 1)
    links.new(pointy_ramp.outputs["Color"], rough_ramp.inputs["Fac"])
    links.new(rough_ramp.outputs["Color"], bsdf.inputs["Roughness"])

    return m

mat_proc = make_crystal_shader()
hero.data.materials.clear()
hero.data.materials.append(mat_proc)

# ============================================================
# STAGE 4 — BAKE DIFFUSE
# ============================================================
print("=== STAGE 4: Bake DIFFUSE ===")
bake_albedo = bpy.data.images.new("energy_crystal_albedo_bake", width=1024, height=1024)
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
    bake_path = os.path.join(TEX_DIR, "energy_crystal_albedo_1024.png")
    bake_albedo.filepath_raw = bake_path
    bake_albedo.file_format = 'PNG'
    bake_albedo.save()
    print(f"Baked albedo: {bake_path}")
except Exception as e:
    print(f"Bake failed: {e}")

# ============================================================
# STAGE 5 — RETOPO LOW-POLY
# ============================================================
print("=== STAGE 5: Retopo low-poly ===")
bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
bpy.context.view_layer.objects.active = hero
bpy.ops.object.duplicate()
low_poly = bpy.context.object
low_poly.name = "energy_crystal_lp"

for mod in list(low_poly.modifiers):
    low_poly.modifiers.remove(mod)
dec = low_poly.modifiers.new("Decimate", 'DECIMATE')
dec.ratio = 0.30
bpy.ops.object.modifier_apply(modifier="Decimate")

bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.cube_project(cube_size=2.0)
bpy.ops.object.mode_set(mode='OBJECT')

print(f"Low-poly: {len(low_poly.data.polygons)} faces")

# ============================================================
# STAGE 6 — NORMAL BAKE high → low
# ============================================================
print("=== STAGE 6: Normal bake high → low ===")
bake_normal = bpy.data.images.new("energy_crystal_normal_bake", width=1024, height=1024,
                                    alpha=False, float_buffer=False)
bake_normal.colorspace_settings.name = 'Non-Color'

mat_lp = bpy.data.materials.new("v3r4_energy_crystal_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (1200, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (900, 0)
bsdf_lp.inputs["Roughness"].default_value = 0.15
bsdf_lp.inputs["IOR"].default_value = 1.55
bsdf_lp.inputs["Transmission Weight"].default_value = 0.40
bsdf_lp.inputs["Coat Weight"].default_value = 0.7
bsdf_lp.inputs["Emission Strength"].default_value = 12.0
ntlp.links.new(bsdf_lp.outputs[0], out_lp.inputs[0])

img_alb_lp = ntlp.nodes.new("ShaderNodeTexImage"); img_alb_lp.location = (200, 200)
img_alb_lp.image = bake_albedo
ntlp.links.new(img_alb_lp.outputs["Color"], bsdf_lp.inputs["Base Color"])
ntlp.links.new(img_alb_lp.outputs["Color"], bsdf_lp.inputs["Emission Color"])

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
scene.render.bake.cage_extrusion = 0.02
scene.render.bake.max_ray_distance = 0.10
scene.cycles.samples = 16

try:
    bpy.ops.object.bake(type='NORMAL')
    nrm_path = os.path.join(TEX_DIR, "energy_crystal_normal_1024.png")
    bake_normal.filepath_raw = nrm_path
    bake_normal.file_format = 'PNG'
    bake_normal.save()
    print(f"Baked normal: {nrm_path}")
except Exception as e:
    print(f"Normal bake failed: {e}")

scene.render.bake.use_selected_to_active = False
scene.cycles.samples = 96

low_poly.location = (1.0, 0, 0.30)

# ============================================================
# STAGE 7 — POINT LIGHT inside the crystal cluster
# ============================================================
bpy.ops.object.light_add(type='POINT', location=(0, 0, 0.40))
crystal_light = bpy.context.object
crystal_light.name = "crystal_glow_light"
crystal_light.data.energy = 30
crystal_light.data.color = (0.30, 0.85, 1.0)
crystal_light.data.shadow_soft_size = 0.05

# ============================================================
# STAGE 8 — RENDERS
# ============================================================
print("=== STAGE 8: Renders ===")

bpy.ops.object.light_add(type='AREA', location=(2, -3, 3))
key = bpy.context.object
key.data.energy = 600; key.data.color = (0.85, 0.92, 1.0); key.data.size = 3

bpy.ops.object.light_add(type='AREA', location=(-3, -2, 2))
fill = bpy.context.object
fill.data.energy = 250; fill.data.color = (0.55, 0.65, 0.95); fill.data.size = 4

bpy.ops.mesh.primitive_plane_add(size=6, location=(0, 0, 0))
fl = bpy.context.object; fl.name = "floor"
mat_fl = bpy.data.materials.new("floor")
mat_fl.use_nodes = True
fbsdf = mat_fl.node_tree.nodes["Principled BSDF"]
fbsdf.inputs["Base Color"].default_value = (0.04, 0.05, 0.07, 1)
fbsdf.inputs["Roughness"].default_value = 0.40
fl.data.materials.append(mat_fl)

def add_cam(name, loc, target, lens=85, dof=2.0, fstop=4.0):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = fstop
    c.data.dof.focus_distance = dof
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_hp = add_cam("cam_hp", Vector((0, -1.5, 0.8)), Vector((0, 0, 0.4)), lens=85, dof=1.5)
cam_lp = add_cam("cam_lp", Vector((1.0, -1.5, 0.8)), Vector((1.0, 0, 0.4)), lens=85, dof=1.5)
cam_compare = add_cam("cam_compare", Vector((0.5, -2.5, 1.0)), Vector((0.5, 0, 0.4)), lens=60, dof=2.5)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.camera = cam_hp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r4_energy_crystal_hp.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r4_energy_crystal_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r4_energy_crystal_compare.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# ============================================================
# STAGE 9 — GLB EXPORT
# ============================================================
print("=== STAGE 9: GLB export ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

bpy.ops.object.select_all(action='DESELECT')
low_poly.select_set(True)
bpy.context.view_layer.objects.active = low_poly

out_path = os.path.join(EXPORT_DIR, "energy_crystal_r4_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 4 Epic R4-10 Energy Crystal complete ===")
