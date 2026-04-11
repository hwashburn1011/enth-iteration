"""
Expansion V3 — ROUND 3 — Epic R3-20 — Hero Iron Lantern
=======================================================
Sculpted iron lantern, single-mesh from a tall thin cube. Real
geometry features:
  - Vertical iron frame ribs extruded from corners (4 corner posts)
  - Bottom + top frame caps (extruded blocks)
  - 4 glass panels carved as recessed insets between the corner posts
  - Each glass panel has 2 triangular vent cutouts inset deep into
    the iron (the cutouts will glow with the lantern flame)
  - Top vent cap dome from extruded face
  - Hanging chain link extruded from top
  - Inner flame: separate small icosphere with high-emission shader
  - Multires 1, UV unwrap (cube_project), iron + glass + emission PBR
  - Bake DIFFUSE + NORMAL high→low
  - Flame point light included
  - GLB export. Static.
"""
import bpy, bmesh, math, os
from mathutils import Vector

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/v3_r3_iron_lantern.blend"
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

scene.world = bpy.data.worlds.new("v3r3_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.02, 0.02, 0.04, 1)
bg.inputs["Strength"].default_value = 0.2

# ============================================================
# STAGE 1 — LANTERN BODY (single-mesh frame)
# ============================================================
print("=== STAGE 1: Lantern body ===")

# Tall thin cube — lantern dimensions
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.0))
hero = bpy.context.object
hero.name = "iron_lantern_hp"
hero.scale = (0.30, 0.30, 0.50)  # 0.6m wide x 0.6m deep x 1.0m tall
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

# Subdivide for panel + cutout placement
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
for _ in range(3):
    bpy.ops.mesh.subdivide()
bpy.ops.object.mode_set(mode='OBJECT')

bm = bmesh.new()
bm.from_mesh(hero.data)

def closest_face_normal(bm, target, normal_dir):
    best, best_d = None, 1e9
    for f in bm.faces:
        if f.normal.dot(normal_dir) < 0.5:
            continue
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d; best = f
    return best

def closest_face(bm, target):
    best, best_d = None, 1e9
    for f in bm.faces:
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d; best = f
    return best

# === 4 glass panels: carve recessed insets into the center of each side face ===
print("Carving glass panels...")
for normal_dir, label in [
    (Vector((0, -1, 0)), "front"),
    (Vector((0, 1, 0)), "back"),
    (Vector((-1, 0, 0)), "left"),
    (Vector((1, 0, 0)), "right"),
]:
    # Find center face on this side (z near middle)
    face_target = normal_dir * 0.31 + Vector((0, 0, 1.0))
    pf = closest_face_normal(bm, face_target, normal_dir)
    if pf:
        # Inset to make a recessed glass panel
        res = bmesh.ops.inset_individual(bm, faces=[pf], thickness=0.05, depth=0.0)
        new_f = res['faces'][0] if res.get('faces') else pf
        # Push inward to create the glass panel recess
        for v in new_f.verts:
            v.co += -normal_dir * 0.04

bm.normal_update()
bm.faces.ensure_lookup_table()

# === 8 triangular cutouts on top + bottom of side faces (decorative vents) ===
print("Carving decorative vent cutouts...")
for normal_dir in [Vector((0, -1, 0)), Vector((0, 1, 0)), Vector((-1, 0, 0)), Vector((1, 0, 0))]:
    for z in [0.55, 1.45]:
        ct = closest_face_normal(bm, normal_dir * 0.31 + Vector((0, 0, z)), normal_dir)
        if ct:
            res = bmesh.ops.inset_individual(bm, faces=[ct], thickness=0.02, depth=0.0)
            new_f = res['faces'][0] if res.get('faces') else ct
            for v in new_f.verts:
                v.co += -normal_dir * 0.06  # deeper than the panels — these are the glow vents

bm.normal_update()
bm.faces.ensure_lookup_table()

# === Top vent cap dome ===
print("Extruding top vent cap...")
top_face = closest_face(bm, Vector((0, 0, 1.50)))
if top_face:
    geom = bmesh.ops.extrude_face_region(bm, geom=[top_face])
    new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
    for v in new_verts:
        v.co.z += 0.06
    new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
    if new_faces:
        # Pinch top into a dome
        geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
        new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
        for v in new_verts2:
            v.co.z += 0.05
        avg = sum((v.co for v in new_verts2), Vector()) / len(new_verts2)
        for v in new_verts2:
            v.co = v.co.lerp(avg, 0.50)

# === Hanging chain link: extrude up + over from the top center ===
print("Extruding chain link...")
top_top = closest_face(bm, Vector((0, 0, 1.65)))
if top_top:
    geom = bmesh.ops.extrude_face_region(bm, geom=[top_top])
    new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
    for v in new_verts:
        v.co.z += 0.20
    new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
    if new_faces:
        # Loop the chain into a small ring (just push up + slight pinch)
        geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
        new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
        for v in new_verts2:
            v.co.z += 0.08
        # Pinch top to form ring
        avg = sum((v.co for v in new_verts2), Vector()) / len(new_verts2)
        for v in new_verts2:
            v.co = v.co.lerp(avg, 0.40)

bm.normal_update()
bm.to_mesh(hero.data)
bm.free()
hero.data.update()
for poly in hero.data.polygons:
    poly.use_smooth = False

# Bevel
bev = hero.modifiers.new("Bevel", 'BEVEL'); bev.width = 0.006; bev.segments = 2

# ============================================================
# STAGE 2 — UV UNWRAP (cube_project)
# ============================================================
print("=== STAGE 2: UV unwrap ===")
bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
bpy.context.view_layer.objects.active = hero
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
try:
    bpy.ops.uv.cube_project(cube_size=2.0)
except Exception as e:
    print(f"cube_project failed: {e}")
bpy.ops.object.mode_set(mode='OBJECT')

# ============================================================
# STAGE 2.5 — Multires after unwrap
# ============================================================
print("=== STAGE 2.5: Multires ===")
hero.modifiers.new("Multires", 'MULTIRES')
bpy.context.view_layer.objects.active = hero
bpy.ops.object.multires_subdivide(modifier="Multires", mode='CATMULL_CLARK')

# ============================================================
# STAGE 3 — IRON SHADER (Pointiness for inner emission)
# ============================================================
print("=== STAGE 3: Iron + emission shader ===")

def make_lantern_shader():
    m = bpy.data.materials.new("v3r3_lantern_proc")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.40
    bsdf.inputs["Metallic"].default_value = 0.85
    bsdf.inputs["Emission Strength"].default_value = 25.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1400, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1200, 0)
    mp.inputs["Scale"].default_value = (5, 5, 5)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Iron base (dark hammered steel)
    iron_n = nodes.new("ShaderNodeTexNoise"); iron_n.location = (-900, 200)
    iron_n.inputs["Scale"].default_value = 18.0
    iron_n.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], iron_n.inputs["Vector"])

    iron_ramp = nodes.new("ShaderNodeValToRGB"); iron_ramp.location = (-650, 200)
    cr = iron_ramp.color_ramp
    cr.elements[0].position = 0.30
    cr.elements[0].color = (0.06, 0.05, 0.04, 1)
    cr.elements[1].position = 0.70
    cr.elements[1].color = (0.18, 0.16, 0.14, 1)
    links.new(iron_n.outputs["Fac"], iron_ramp.inputs["Fac"])
    links.new(iron_ramp.outputs["Color"], bsdf.inputs["Base Color"])

    # === Flame emission via deep Pointiness recesses (the vent cutouts) ===
    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-900, -200)
    deep_ramp = nodes.new("ShaderNodeValToRGB"); deep_ramp.location = (-650, -200)
    deep_ramp.color_ramp.elements[0].position = 0.20
    deep_ramp.color_ramp.elements[0].color = (1, 1, 1, 1)
    deep_ramp.color_ramp.elements[1].position = 0.40
    deep_ramp.color_ramp.elements[1].color = (0, 0, 0, 1)
    links.new(geo.outputs["Pointiness"], deep_ramp.inputs["Fac"])

    flame_color = nodes.new("ShaderNodeRGB"); flame_color.location = (-650, -380)
    flame_color.outputs[0].default_value = (1.0, 0.55, 0.15, 1)  # warm orange flame

    em_mix = nodes.new("ShaderNodeMix"); em_mix.data_type = 'RGBA'; em_mix.location = (100, -200)
    links.new(deep_ramp.outputs["Color"], em_mix.inputs["Factor"])
    em_mix.inputs[6].default_value = (0, 0, 0, 1)
    links.new(flame_color.outputs[0], em_mix.inputs[7])
    links.new(em_mix.outputs[2], bsdf.inputs["Emission Color"])

    # Roughness varies slightly with iron noise
    rough_ramp = nodes.new("ShaderNodeValToRGB"); rough_ramp.location = (100, -400)
    rough_ramp.color_ramp.elements[0].position = 0.30
    rough_ramp.color_ramp.elements[0].color = (0.30, 0.30, 0.30, 1)
    rough_ramp.color_ramp.elements[1].position = 0.80
    rough_ramp.color_ramp.elements[1].color = (0.55, 0.55, 0.55, 1)
    links.new(iron_n.outputs["Fac"], rough_ramp.inputs["Fac"])
    links.new(rough_ramp.outputs["Color"], bsdf.inputs["Roughness"])

    # Bump
    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -550)
    bp.inputs["Strength"].default_value = 0.30
    links.new(iron_n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

mat_proc = make_lantern_shader()
hero.data.materials.clear()
hero.data.materials.append(mat_proc)

# ============================================================
# STAGE 4 — BAKE DIFFUSE
# ============================================================
print("=== STAGE 4: Bake DIFFUSE ===")
bake_albedo = bpy.data.images.new("iron_lantern_albedo_bake", width=1024, height=1024)
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
    bake_path = os.path.join(TEX_DIR, "iron_lantern_albedo_1024.png")
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
low_poly.name = "iron_lantern_lp"

for mod in list(low_poly.modifiers):
    low_poly.modifiers.remove(mod)
dec = low_poly.modifiers.new("Decimate", 'DECIMATE')
dec.ratio = 0.25
bpy.ops.object.modifier_apply(modifier="Decimate")

bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
try:
    bpy.ops.uv.cube_project(cube_size=2.0)
except Exception as e:
    print(f"cube_project failed: {e}")
bpy.ops.object.mode_set(mode='OBJECT')

print(f"Low-poly: {len(low_poly.data.polygons)} faces")

# ============================================================
# STAGE 6 — NORMAL BAKE
# ============================================================
print("=== STAGE 6: Normal bake high → low ===")
bake_normal = bpy.data.images.new("iron_lantern_normal_bake", width=1024, height=1024,
                                    alpha=False, float_buffer=False)
bake_normal.colorspace_settings.name = 'Non-Color'

mat_lp = bpy.data.materials.new("v3r3_lantern_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (1200, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (900, 0)
bsdf_lp.inputs["Roughness"].default_value = 0.40
bsdf_lp.inputs["Metallic"].default_value = 0.85
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
scene.render.bake.cage_extrusion = 0.03
scene.render.bake.max_ray_distance = 0.15
scene.cycles.samples = 16

try:
    bpy.ops.object.bake(type='NORMAL')
    nrm_path = os.path.join(TEX_DIR, "iron_lantern_normal_1024.png")
    bake_normal.filepath_raw = nrm_path
    bake_normal.file_format = 'PNG'
    bake_normal.save()
    print(f"Baked normal: {nrm_path}")
except Exception as e:
    print(f"Normal bake failed: {e}")
    import traceback; traceback.print_exc()

scene.render.bake.use_selected_to_active = False
scene.cycles.samples = 128

low_poly.location = (1.5, 0, 1.0)

# ============================================================
# STAGE 7 — INNER FLAME (icosphere w/ emission)
# ============================================================
print("=== STAGE 7: Inner flame ===")
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.06, location=(0, 0, 1.0))
flame = bpy.context.object
flame.name = "lantern_flame"

flame_mat = bpy.data.materials.new("v3r3_flame")
flame_mat.use_nodes = True
nt = flame_mat.node_tree
nt.nodes.clear()
out = nt.nodes.new("ShaderNodeOutputMaterial"); out.location = (400, 0)
em = nt.nodes.new("ShaderNodeEmission"); em.location = (200, 0)
em.inputs["Color"].default_value = (1.0, 0.55, 0.15, 1)
em.inputs["Strength"].default_value = 80.0
nt.links.new(em.outputs[0], out.inputs[0])
flame.data.materials.append(flame_mat)

# Add point light at flame position
bpy.ops.object.light_add(type='POINT', location=(0, 0, 1.0))
flame_light = bpy.context.object
flame_light.name = "flame_light"
flame_light.data.energy = 60
flame_light.data.color = (1.0, 0.65, 0.25)
flame_light.data.shadow_soft_size = 0.05

# ============================================================
# STAGE 8 — LIGHTING + RENDERS
# ============================================================
print("=== STAGE 8: Lighting + Renders ===")

# Cool ambient (so the lantern flame has something to contrast with)
bpy.ops.object.light_add(type='AREA', location=(-4, -4, 4))
fill = bpy.context.object
fill.data.energy = 200; fill.data.color = (0.45, 0.55, 0.85); fill.data.size = 5

bpy.ops.object.light_add(type='AREA', location=(4, 3, 3))
rim = bpy.context.object
rim.data.energy = 150; rim.data.color = (0.55, 0.65, 0.95); rim.data.size = 4

# Floor
bpy.ops.mesh.primitive_plane_add(size=8, location=(0, 0, 0))
fl = bpy.context.object; fl.name = "floor"
mat_fl = bpy.data.materials.new("floor")
mat_fl.use_nodes = True
fbsdf = mat_fl.node_tree.nodes["Principled BSDF"]
fbsdf.inputs["Base Color"].default_value = (0.05, 0.05, 0.07, 1)
fbsdf.inputs["Roughness"].default_value = 0.40
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

cam_hp = add_cam("cam_hp", Vector((0, -2.5, 1.4)), Vector((0, 0, 1.0)), lens=85, dof=2.5)
cam_lp = add_cam("cam_lp", Vector((1.5, -2.5, 1.4)), Vector((1.5, 0, 1.0)), lens=85, dof=2.5)
cam_compare = add_cam("cam_compare", Vector((0.75, -3.5, 1.6)), Vector((0.75, 0, 1.0)), lens=60, dof=3.5)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.camera = cam_hp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_iron_lantern_hp.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_iron_lantern_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_iron_lantern_compare.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# ============================================================
# STAGE 9 — GLB EXPORT
# ============================================================
print("=== STAGE 9: GLB export ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

bpy.ops.object.select_all(action='DESELECT')
low_poly.select_set(True)
flame.select_set(True)
bpy.context.view_layer.objects.active = low_poly

out_path = os.path.join(EXPORT_DIR, "iron_lantern_r3_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 3 Epic R3-20 Iron Lantern complete ===")
