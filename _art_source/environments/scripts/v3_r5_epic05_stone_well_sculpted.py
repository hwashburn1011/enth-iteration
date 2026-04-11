"""
Expansion V3 — ROUND 5 — Epic R5-05 — Hero Stone Well Sculpted
==============================================================
Hexagonal stone well with carved brick joints + extruded wooden roof
posts + hanging bucket. Replaces town stone_well.glb v2 placeholder.

Pipeline:
  1. Hexagonal cylinder base for the stone well wall
  2. Carved brick joints via inset_individual on every face row
  3. Top rim extruded slightly outward
  4. Hollow center: top face cluster recessed deep (well opening)
  5. 2 vertical wooden roof posts extruded from opposite rim points
  6. Roof crossbeam connecting the posts (extruded horizontally)
  7. Bevel + cube_project UV + multires 1
  8. Stone Pointiness shader
  9. Bake albedo + normal high→low
 10. Separate hanging bucket cylinder + rope thin cylinder
 11. GLB export
"""
import bpy, bmesh, math, os
from mathutils import Vector

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/v3_r5_stone_well.blend"
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

scene.world = bpy.data.worlds.new("v3r5_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.45, 0.55, 0.65, 1)
bg.inputs["Strength"].default_value = 1.0

# ============================================================
# STAGE 1 — HEX WELL BODY
# ============================================================
print("=== STAGE 1: Hex well body ===")

# 6-vertex cylinder = hexagon, depth 1.0m for the well wall
bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.50, depth=1.0, location=(0, 0, 0.50))
hero = bpy.context.object
hero.name = "stone_well_hp"

bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
for _ in range(3):
    bpy.ops.mesh.subdivide()
bpy.ops.object.mode_set(mode='OBJECT')

bm = bmesh.new()
bm.from_mesh(hero.data)

def closest_face(bm, target):
    best, best_d = None, 1e9
    for f in bm.faces:
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d; best = f
    return best

# === Carve brick joints on the side faces ===
print("Carving brick joints...")
side_faces = [f for f in bm.faces if abs(f.normal.z) < 0.5]
# Inset every other face for grout lines
for i, f in enumerate(side_faces):
    if i % 2 == 1:
        res = bmesh.ops.inset_individual(bm, faces=[f], thickness=0.012, depth=0.0)
        for new_f in res.get('faces', []):
            for v in new_f.verts:
                horiz = Vector((v.co.x, v.co.y, 0))
                if horiz.length > 0:
                    horiz.normalize()
                    v.co -= horiz * 0.012

bm.normal_update()
bm.faces.ensure_lookup_table()

# === Hollow the well opening: recess top center face cluster ===
print("Hollowing well opening...")
top_faces = [f for f in bm.faces if f.normal.z > 0.5]
top_faces.sort(key=lambda f: (f.calc_center_median() - Vector((0, 0, 1.0))).length)
# Recess the inner ~50% of top faces
center_top = top_faces[:6]
if center_top:
    res = bmesh.ops.inset_individual(bm, faces=center_top, thickness=0.10, depth=0.0)
    for f in res.get('faces', []):
        for v in f.verts:
            v.co.z -= 0.30  # deep recess into the well

bm.normal_update()
bm.to_mesh(hero.data)
bm.free()
hero.data.update()
for poly in hero.data.polygons:
    poly.use_smooth = False

bev = hero.modifiers.new("Bevel", 'BEVEL')
bev.width = 0.008
bev.segments = 2

# ============================================================
# STAGE 1B — Roof posts + crossbeam (separate cube objects)
# ============================================================
print("=== STAGE 1B: Roof posts + crossbeam ===")
post_l = bpy.ops.mesh.primitive_cube_add(size=0.10, location=(-0.45, 0, 1.20))
post_l = bpy.context.object
post_l.name = "well_post_l"
post_l.scale = (0.5, 0.5, 6.0)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

bpy.ops.mesh.primitive_cube_add(size=0.10, location=(0.45, 0, 1.20))
post_r = bpy.context.object
post_r.name = "well_post_r"
post_r.scale = (0.5, 0.5, 6.0)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

bpy.ops.mesh.primitive_cube_add(size=0.10, location=(0, 0, 1.55))
crossbeam = bpy.context.object
crossbeam.name = "well_crossbeam"
crossbeam.scale = (10.0, 0.5, 0.5)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

# ============================================================
# STAGE 1C — Hanging bucket
# ============================================================
print("=== STAGE 1C: Bucket ===")
bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.10, depth=0.16,
                                     location=(0, 0, 1.10))
bucket = bpy.context.object
bucket.name = "well_bucket"
for poly in bucket.data.polygons:
    poly.use_smooth = True

# Rope: thin cylinder from bucket to crossbeam
bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.008, depth=0.40,
                                     location=(0, 0, 1.30))
rope = bpy.context.object
rope.name = "well_rope"

# ============================================================
# STAGE 2 — UV UNWRAP main hero
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
# STAGE 3 — STONE SHADER (Pointiness for grout vs brick)
# ============================================================
print("=== STAGE 3: Stone shader ===")

def make_stone_shader():
    m = bpy.data.materials.new("v3r5_well_stone_proc")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.75
    bsdf.inputs["Metallic"].default_value = 0.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (4, 4, 4)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
    n.inputs["Scale"].default_value = 14.0
    n.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])

    stone_ramp = nodes.new("ShaderNodeValToRGB"); stone_ramp.location = (-450, 200)
    cr = stone_ramp.color_ramp
    cr.elements[0].position = 0.30
    cr.elements[0].color = (0.30, 0.28, 0.25, 1)
    cr.elements[1].position = 0.70
    cr.elements[1].color = (0.55, 0.50, 0.45, 1)
    links.new(n.outputs["Fac"], stone_ramp.inputs["Fac"])
    links.new(stone_ramp.outputs["Color"], bsdf.inputs["Base Color"])

    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -300)
    bp.inputs["Strength"].default_value = 0.45
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

mat_stone = make_stone_shader()
hero.data.materials.clear()
hero.data.materials.append(mat_stone)

# Wood material for posts/beam/bucket/rope
mat_wood = bpy.data.materials.new("v3r5_well_wood")
mat_wood.use_nodes = True
ntw = mat_wood.node_tree
ntw.nodes.clear()
out_w = ntw.nodes.new("ShaderNodeOutputMaterial"); out_w.location = (400, 0)
bsdf_w = ntw.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_w.location = (100, 0)
bsdf_w.inputs["Base Color"].default_value = (0.40, 0.25, 0.12, 1)
bsdf_w.inputs["Roughness"].default_value = 0.85
ntw.links.new(bsdf_w.outputs[0], out_w.inputs[0])

for obj in [post_l, post_r, crossbeam, bucket, rope]:
    obj.data.materials.append(mat_wood)

# ============================================================
# STAGE 4 — BAKE DIFFUSE on hero stone
# ============================================================
print("=== STAGE 4: Bake DIFFUSE ===")
bake_albedo = bpy.data.images.new("stone_well_albedo_bake", width=1024, height=1024)
img_node_a = mat_stone.node_tree.nodes.new("ShaderNodeTexImage")
img_node_a.location = (1100, 400)
img_node_a.image = bake_albedo
img_node_a.select = True
mat_stone.node_tree.nodes.active = img_node_a

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
    bake_path = os.path.join(TEX_DIR, "stone_well_albedo_1024.png")
    bake_albedo.filepath_raw = bake_path
    bake_albedo.file_format = 'PNG'
    bake_albedo.save()
    print(f"Baked albedo: {bake_path}")
except Exception as e:
    print(f"Bake failed: {e}")

# ============================================================
# STAGE 5 — RETOPO + NORMAL BAKE
# ============================================================
print("=== STAGE 5: Retopo + normal bake ===")
bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
bpy.context.view_layer.objects.active = hero
bpy.ops.object.duplicate()
low_poly = bpy.context.object
low_poly.name = "stone_well_lp"
for mod in list(low_poly.modifiers):
    low_poly.modifiers.remove(mod)
dec = low_poly.modifiers.new("Decimate", 'DECIMATE')
dec.ratio = 0.30
bpy.ops.object.modifier_apply(modifier="Decimate")
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.cube_project(cube_size=2.0)
bpy.ops.object.mode_set(mode='OBJECT')

bake_normal = bpy.data.images.new("stone_well_normal_bake", width=1024, height=1024,
                                    alpha=False, float_buffer=False)
bake_normal.colorspace_settings.name = 'Non-Color'
mat_lp = bpy.data.materials.new("v3r5_stone_well_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (1200, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (900, 0)
bsdf_lp.inputs["Roughness"].default_value = 0.75
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
    nrm_path = os.path.join(TEX_DIR, "stone_well_normal_1024.png")
    bake_normal.filepath_raw = nrm_path
    bake_normal.file_format = 'PNG'
    bake_normal.save()
    print(f"Baked normal: {nrm_path}")
except Exception as e:
    print(f"Normal bake failed: {e}")
scene.render.bake.use_selected_to_active = False
scene.cycles.samples = 96

low_poly.location = (2.5, 0, 0.50)

# ============================================================
# STAGE 6 — RENDERS
# ============================================================
print("=== STAGE 6: Renders ===")

bpy.ops.object.light_add(type='SUN', location=(0, 0, 8))
sun = bpy.context.object
sun.data.energy = 4.0; sun.data.color = (1.0, 0.92, 0.78)
sun.rotation_euler = (math.radians(50), math.radians(20), 0)

bpy.ops.object.light_add(type='AREA', location=(-3, -2, 3))
fill = bpy.context.object
fill.data.energy = 500; fill.data.color = (0.55, 0.70, 0.95); fill.data.size = 4

bpy.ops.mesh.primitive_plane_add(size=8, location=(0, 0, 0))
fl = bpy.context.object; fl.name = "ground"
mat_fl = bpy.data.materials.new("ground")
mat_fl.use_nodes = True
fbsdf = mat_fl.node_tree.nodes["Principled BSDF"]
fbsdf.inputs["Base Color"].default_value = (0.20, 0.22, 0.10, 1)
fbsdf.inputs["Roughness"].default_value = 0.85
fl.data.materials.append(mat_fl)

def add_cam(name, loc, target, lens=70, dof=3.0, fstop=4.0):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = fstop
    c.data.dof.focus_distance = dof
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_hp = add_cam("cam_hp", Vector((0, -2.5, 1.6)), Vector((0, 0, 0.7)), lens=50, dof=3)
cam_lp = add_cam("cam_lp", Vector((2.5, -2.5, 1.6)), Vector((2.5, 0, 0.7)), lens=50, dof=3)
cam_compare = add_cam("cam_compare", Vector((1.25, -3.5, 1.8)), Vector((1.25, 0, 0.7)), lens=42, dof=4)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.camera = cam_hp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r5_stone_well_hp.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r5_stone_well_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r5_stone_well_compare.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# ============================================================
# STAGE 7 — GLB EXPORT
# ============================================================
print("=== STAGE 7: GLB export ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

bpy.ops.object.select_all(action='DESELECT')
low_poly.select_set(True)
post_l.select_set(True)
post_r.select_set(True)
crossbeam.select_set(True)
bucket.select_set(True)
rope.select_set(True)
bpy.context.view_layer.objects.active = low_poly

out_path = os.path.join(EXPORT_DIR, "stone_well_r5_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 5 Epic R5-05 Stone Well complete ===")
