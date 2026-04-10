"""
Expansion V3 — ROUND 4 — Epic R4-16 — Wall Torch Sconce Sculpted
================================================================
Iron wall sconce with flame core. Used as repeating dungeon wall
lighting prop. Pipeline:

  1. Cube base for the wall mounting plate
  2. Carved 4 bolt-head insets on the plate corners
  3. Extrude bracket arm forward + downward (real arm geometry,
     not a separate cylinder)
  4. Extrude oil bowl from arm tip + flare outward into a cup
  5. Bevel + cube_project UV + multires 1
  6. Iron Pointiness shader (bolts/bracket render as polished iron,
     plate stays darker)
  7. Bake albedo + normal high→low
  8. Separate emission flame icosphere
  9. Embedded point light
 10. GLB export
"""
import bpy, bmesh, math, os
from mathutils import Vector

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/v3_r4_wall_sconce.blend"
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

scene.world = bpy.data.worlds.new("v3r4_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.02, 0.02, 0.04, 1)
bg.inputs["Strength"].default_value = 0.2

# ============================================================
# STAGE 1 — SCONCE BASE: WALL MOUNT + ARM + BOWL
# ============================================================
print("=== STAGE 1: Sconce base ===")

bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.5))
hero = bpy.context.object
hero.name = "wall_sconce_hp"
hero.scale = (0.20, 0.04, 0.30)  # 0.4m wide x 0.08m thick x 0.6m tall
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

# Subdivide for feature placement
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

def closest_face_normal(bm, target, normal_dir):
    best, best_d = None, 1e9
    for f in bm.faces:
        if f.normal.dot(normal_dir) < 0.5:
            continue
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d; best = f
    return best

# === Carve 4 bolt-head insets on the front plate corners ===
print("Carving bolt heads...")
for x in [-0.15, 0.15]:
    for z in [0.25, 0.75]:
        bf = closest_face_normal(bm, Vector((x, -0.04, z)), Vector((0, -1, 0)))
        if bf:
            res = bmesh.ops.inset_individual(bm, faces=[bf], thickness=0.02, depth=0.0)
            new_f = res['faces'][0] if res.get('faces') else bf
            for v in new_f.verts:
                v.co.y -= 0.012  # extrude bolt head outward

bm.normal_update()
bm.faces.ensure_lookup_table()

# === Extrude bracket arm: from front center → forward + slightly up ===
print("Extruding bracket arm...")
arm_face = closest_face_normal(bm, Vector((0, -0.04, 0.55)), Vector((0, -1, 0)))
if arm_face:
    geom = bmesh.ops.extrude_face_region(bm, geom=[arm_face])
    new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
    for v in new_verts:
        v.co.y -= 0.18
        v.co.z += 0.10
    new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
    if new_faces:
        # Second extrude — flare into bowl
        geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
        new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
        for v in new_verts2:
            v.co.y -= 0.04
            v.co.z += 0.05
            # Flare X+Z outward into a bowl shape
            v.co.x *= 2.5
            v.co.z = (v.co.z - 0.70) * 1.8 + 0.70

bm.normal_update()
bm.to_mesh(hero.data)
bm.free()
hero.data.update()
for poly in hero.data.polygons:
    poly.use_smooth = False

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
hero.modifiers.new("Multires", 'MULTIRES')
bpy.context.view_layer.objects.active = hero
bpy.ops.object.multires_subdivide(modifier="Multires", mode='CATMULL_CLARK')

# ============================================================
# STAGE 3 — IRON SHADER w/ Pointiness for bolt head highlights
# ============================================================
print("=== STAGE 3: Iron shader ===")

def make_sconce_shader():
    m = bpy.data.materials.new("v3r4_wall_sconce_proc")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.35
    bsdf.inputs["Metallic"].default_value = 0.85
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (5, 5, 5)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
    n.inputs["Scale"].default_value = 16.0
    n.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])

    iron_ramp = nodes.new("ShaderNodeValToRGB"); iron_ramp.location = (-450, 200)
    iron_ramp.color_ramp.elements[0].position = 0.30
    iron_ramp.color_ramp.elements[0].color = (0.04, 0.04, 0.05, 1)
    iron_ramp.color_ramp.elements[1].position = 0.70
    iron_ramp.color_ramp.elements[1].color = (0.18, 0.18, 0.20, 1)
    links.new(n.outputs["Fac"], iron_ramp.inputs["Fac"])

    # Pointiness drives polish on the bolt heads + bracket arm
    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-700, -200)
    pointy_ramp = nodes.new("ShaderNodeValToRGB"); pointy_ramp.location = (-450, -200)
    pointy_ramp.color_ramp.elements[0].position = 0.55
    pointy_ramp.color_ramp.elements[0].color = (0, 0, 0, 1)
    pointy_ramp.color_ramp.elements[1].position = 0.70
    pointy_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(geo.outputs["Pointiness"], pointy_ramp.inputs["Fac"])

    polished_color = nodes.new("ShaderNodeRGB"); polished_color.location = (-450, -380)
    polished_color.outputs[0].default_value = (0.45, 0.46, 0.50, 1)

    color_mix = nodes.new("ShaderNodeMix"); color_mix.data_type = 'RGBA'; color_mix.location = (100, 0)
    links.new(pointy_ramp.outputs["Color"], color_mix.inputs["Factor"])
    links.new(iron_ramp.outputs["Color"], color_mix.inputs[6])
    links.new(polished_color.outputs[0], color_mix.inputs[7])
    links.new(color_mix.outputs[2], bsdf.inputs["Base Color"])

    rough_ramp = nodes.new("ShaderNodeValToRGB"); rough_ramp.location = (100, -200)
    rough_ramp.color_ramp.elements[0].position = 0.0
    rough_ramp.color_ramp.elements[0].color = (0.55, 0.55, 0.55, 1)
    rough_ramp.color_ramp.elements[1].position = 1.0
    rough_ramp.color_ramp.elements[1].color = (0.15, 0.15, 0.15, 1)
    links.new(pointy_ramp.outputs["Color"], rough_ramp.inputs["Fac"])
    links.new(rough_ramp.outputs["Color"], bsdf.inputs["Roughness"])

    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -550)
    bp.inputs["Strength"].default_value = 0.30
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

mat_proc = make_sconce_shader()
hero.data.materials.clear()
hero.data.materials.append(mat_proc)

# ============================================================
# STAGE 4 — BAKE DIFFUSE
# ============================================================
print("=== STAGE 4: Bake DIFFUSE ===")
bake_albedo = bpy.data.images.new("wall_sconce_albedo_bake", width=1024, height=1024)
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
    bake_path = os.path.join(TEX_DIR, "wall_sconce_albedo_1024.png")
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
low_poly.name = "wall_sconce_lp"
for mod in list(low_poly.modifiers):
    low_poly.modifiers.remove(mod)
dec = low_poly.modifiers.new("Decimate", 'DECIMATE')
dec.ratio = 0.30
bpy.ops.object.modifier_apply(modifier="Decimate")
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.cube_project(cube_size=2.0)
bpy.ops.object.mode_set(mode='OBJECT')

bake_normal = bpy.data.images.new("wall_sconce_normal_bake", width=1024, height=1024,
                                    alpha=False, float_buffer=False)
bake_normal.colorspace_settings.name = 'Non-Color'
mat_lp = bpy.data.materials.new("v3r4_wall_sconce_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (1200, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (900, 0)
bsdf_lp.inputs["Roughness"].default_value = 0.35
bsdf_lp.inputs["Metallic"].default_value = 0.85
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
    nrm_path = os.path.join(TEX_DIR, "wall_sconce_normal_1024.png")
    bake_normal.filepath_raw = nrm_path
    bake_normal.file_format = 'PNG'
    bake_normal.save()
    print(f"Baked normal: {nrm_path}")
except Exception as e:
    print(f"Normal bake failed: {e}")
scene.render.bake.use_selected_to_active = False
scene.cycles.samples = 128

low_poly.location = (1.0, 0, 0.5)

# ============================================================
# STAGE 6 — FLAME + LIGHT
# ============================================================
print("=== STAGE 6: Flame + light ===")
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.06,
                                       location=(0, -0.30, 0.85))
flame = bpy.context.object
flame.name = "sconce_flame"

flame_mat = bpy.data.materials.new("v3r4_sconce_flame")
flame_mat.use_nodes = True
nt = flame_mat.node_tree
nt.nodes.clear()
out_f = nt.nodes.new("ShaderNodeOutputMaterial"); out_f.location = (400, 0)
em = nt.nodes.new("ShaderNodeEmission"); em.location = (200, 0)
em.inputs["Color"].default_value = (1.0, 0.55, 0.15, 1)
em.inputs["Strength"].default_value = 80.0
nt.links.new(em.outputs[0], out_f.inputs[0])
flame.data.materials.append(flame_mat)

bpy.ops.object.light_add(type='POINT', location=(0, -0.30, 0.85))
flame_light = bpy.context.object
flame_light.name = "sconce_flame_light"
flame_light.data.energy = 80
flame_light.data.color = (1.0, 0.65, 0.25)
flame_light.data.shadow_soft_size = 0.05

# ============================================================
# STAGE 7 — RENDERS
# ============================================================
print("=== STAGE 7: Renders ===")

bpy.ops.object.light_add(type='AREA', location=(-2, -2, 2))
fill = bpy.context.object
fill.data.energy = 200; fill.data.color = (0.45, 0.55, 0.85); fill.data.size = 2

bpy.ops.object.light_add(type='AREA', location=(2, 2, 2))
rim = bpy.context.object
rim.data.energy = 150; rim.data.color = (0.55, 0.65, 0.95); rim.data.size = 2

bpy.ops.mesh.primitive_plane_add(size=4, location=(0, 0.05, 0))
fl = bpy.context.object; fl.name = "wall"
fl.rotation_euler = (math.radians(90), 0, 0)
mat_fl = bpy.data.materials.new("wall")
mat_fl.use_nodes = True
fbsdf = mat_fl.node_tree.nodes["Principled BSDF"]
fbsdf.inputs["Base Color"].default_value = (0.10, 0.10, 0.12, 1)
fbsdf.inputs["Roughness"].default_value = 0.65
fl.data.materials.append(mat_fl)

def add_cam(name, loc, target, lens=85, dof=1.0, fstop=4.0):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = fstop
    c.data.dof.focus_distance = dof
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_hp = add_cam("cam_hp", Vector((0, -1.4, 0.6)), Vector((0, 0, 0.5)), lens=85, dof=1.4)
cam_lp = add_cam("cam_lp", Vector((1.0, -1.4, 0.6)), Vector((1.0, 0, 0.5)), lens=85, dof=1.4)
cam_compare = add_cam("cam_compare", Vector((0.5, -2.0, 0.7)), Vector((0.5, 0, 0.5)), lens=60, dof=2.0)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.camera = cam_hp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r4_wall_sconce_hp.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r4_wall_sconce_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r4_wall_sconce_compare.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# ============================================================
# STAGE 8 — GLB EXPORT
# ============================================================
print("=== STAGE 8: GLB export ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

bpy.ops.object.select_all(action='DESELECT')
low_poly.select_set(True)
flame.select_set(True)
bpy.context.view_layer.objects.active = low_poly

out_path = os.path.join(EXPORT_DIR, "wall_sconce_r4_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 4 Epic R4-16 Wall Sconce complete ===")
