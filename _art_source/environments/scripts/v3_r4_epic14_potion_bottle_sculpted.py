"""
Expansion V3 — ROUND 4 — Epic R4-14 — Health Potion Bottle Sculpted
===================================================================
Glass potion bottle to replace the prompt cube placeholders.

Pipeline (R3 quality bar):
  1. Cylinder base, scaled to bottle proportions
  2. Bmesh: shoulder taper at top, narrow neck above shoulders,
     wider belly below shoulders, recessed bottom punt (real glass
     bottle silhouette, not a stretched cylinder)
  3. Carved label panel inset on the front of the belly
  4. Cork stopper: extruded top face cluster
  5. Liquid: separate inner mesh (smaller cylinder) using emission
     shader for the red glow
  6. Bevel + cube_project UV + multires 1
  7. Glass shader for the bottle (transmission + IOR)
  8. Bake albedo + normal high→low
  9. GLB w/ both bottle + liquid meshes
"""
import bpy, bmesh, math, os
from mathutils import Vector

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/v3_r4_potion_bottle.blend"
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
bg.inputs["Color"].default_value = (0.05, 0.05, 0.08, 1)
bg.inputs["Strength"].default_value = 0.4

# ============================================================
# STAGE 1 — BOTTLE BASE MESH
# ============================================================
print("=== STAGE 1: Bottle base ===")

bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=0.15, depth=0.40, location=(0, 0, 0.20))
hero = bpy.context.object
hero.name = "potion_bottle_hp"

# Subdivide rings
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
for _ in range(3):
    bpy.ops.mesh.subdivide()
bpy.ops.object.mode_set(mode='OBJECT')

bm = bmesh.new()
bm.from_mesh(hero.data)

# Sculpt bottle silhouette by Z-zone radius variation
for v in bm.verts:
    z_local = v.co.z
    horiz = Vector((v.co.x, v.co.y, 0))
    if horiz.length > 0:
        # Belly: wider in the middle
        if 0.05 < z_local < 0.20:
            scale = 1.30
            horiz.normalize()
            v.co.x = horiz.x * 0.15 * scale
            v.co.y = horiz.y * 0.15 * scale
        # Shoulder taper
        elif 0.20 <= z_local < 0.30:
            t = (z_local - 0.20) / 0.10
            scale = 1.30 - 0.55 * t
            horiz.normalize()
            v.co.x = horiz.x * 0.15 * scale
            v.co.y = horiz.y * 0.15 * scale
        # Neck (narrow)
        elif z_local >= 0.30:
            scale = 0.50
            horiz.normalize()
            v.co.x = horiz.x * 0.15 * scale
            v.co.y = horiz.y * 0.15 * scale

def closest_face(bm, target):
    best, best_d = None, 1e9
    for f in bm.faces:
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d; best = f
    return best

# === Carved label panel on the front of the belly (-Y face) ===
print("Carving label panel...")
label_face = closest_face(bm, Vector((0, -0.20, 0.13)))
if label_face:
    res = bmesh.ops.inset_individual(bm, faces=[label_face], thickness=0.02, depth=0.0)
    new_f = res['faces'][0] if res.get('faces') else label_face
    for v in new_f.verts:
        v.co.y += 0.005  # slight recess

bm.normal_update()
bm.to_mesh(hero.data)
bm.free()
hero.data.update()
for poly in hero.data.polygons:
    poly.use_smooth = True

# === Cork stopper as a separate small cylinder ===
print("Adding cork stopper...")
bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.085, depth=0.04, location=(0, 0, 0.42))
cork = bpy.context.object
cork.name = "potion_cork"
for poly in cork.data.polygons:
    poly.use_smooth = True

bev = hero.modifiers.new("Bevel", 'BEVEL')
bev.width = 0.003
bev.segments = 2

bev_cork = cork.modifiers.new("Bevel", 'BEVEL')
bev_cork.width = 0.005
bev_cork.segments = 2

# ============================================================
# STAGE 2 — UV UNWRAP
# ============================================================
print("=== STAGE 2: UV unwrap ===")
for obj in [hero, cork]:
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
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
# STAGE 3 — GLASS + CORK SHADERS
# ============================================================
print("=== STAGE 3: Shaders ===")

def make_glass_shader():
    m = bpy.data.materials.new("v3r4_potion_glass_proc")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1200, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (900, 0)
    bsdf.inputs["Base Color"].default_value = (0.85, 0.55, 0.40, 1)  # warm tinted glass
    bsdf.inputs["Roughness"].default_value = 0.05
    bsdf.inputs["Metallic"].default_value = 0.0
    bsdf.inputs["IOR"].default_value = 1.50
    bsdf.inputs["Transmission Weight"].default_value = 0.85
    bsdf.inputs["Coat Weight"].default_value = 0.7
    bsdf.inputs["Coat Roughness"].default_value = 0.05
    links.new(bsdf.outputs[0], out.inputs[0])
    return m

def make_cork_shader():
    m = bpy.data.materials.new("v3r4_potion_cork_proc")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1200, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (900, 0)
    bsdf.inputs["Base Color"].default_value = (0.45, 0.30, 0.18, 1)
    bsdf.inputs["Roughness"].default_value = 0.85
    bsdf.inputs["Metallic"].default_value = 0.0
    links.new(bsdf.outputs[0], out.inputs[0])
    return m

mat_glass = make_glass_shader()
hero.data.materials.clear(); hero.data.materials.append(mat_glass)

mat_cork = make_cork_shader()
cork.data.materials.clear(); cork.data.materials.append(mat_cork)

# ============================================================
# STAGE 4 — LIQUID MESH (inside the bottle)
# ============================================================
print("=== STAGE 4: Liquid mesh ===")
bpy.ops.mesh.primitive_cylinder_add(vertices=20, radius=0.13, depth=0.20, location=(0, 0, 0.13))
liquid = bpy.context.object
liquid.name = "potion_liquid"
for poly in liquid.data.polygons:
    poly.use_smooth = True

mat_liquid = bpy.data.materials.new("v3r4_potion_liquid_proc")
mat_liquid.use_nodes = True
nt = mat_liquid.node_tree
nt.nodes.clear()
out_l = nt.nodes.new("ShaderNodeOutputMaterial"); out_l.location = (400, 0)
bsdf_l = nt.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_l.location = (100, 0)
bsdf_l.inputs["Base Color"].default_value = (0.95, 0.15, 0.20, 1)  # health red
bsdf_l.inputs["Roughness"].default_value = 0.10
bsdf_l.inputs["Transmission Weight"].default_value = 0.40
bsdf_l.inputs["Emission Color"].default_value = (1.0, 0.20, 0.15, 1)
bsdf_l.inputs["Emission Strength"].default_value = 8.0
nt.links.new(bsdf_l.outputs[0], out_l.inputs[0])
liquid.data.materials.append(mat_liquid)

# ============================================================
# STAGE 5 — BAKE DIFFUSE on bottle (+ cork)
# ============================================================
print("=== STAGE 5: Bake DIFFUSE ===")

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
    print(f"Baking {name}...")
    try:
        bpy.ops.object.bake(type='DIFFUSE')
        path = os.path.join(TEX_DIR, f"{name}_albedo_1024.png")
        img.filepath_raw = path
        img.file_format = 'PNG'
        img.save()
        print(f"Baked: {path}")
    except Exception as e:
        print(f"Bake failed: {e}")
    return img

bottle_albedo = bake_diffuse(hero, mat_glass, "potion_bottle")
cork_albedo = bake_diffuse(cork, mat_cork, "potion_cork")

# ============================================================
# STAGE 6 — RETOPO + NORMAL BAKE bottle only
# ============================================================
print("=== STAGE 6: Retopo + normal bake ===")
bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
bpy.context.view_layer.objects.active = hero
bpy.ops.object.duplicate()
low_poly = bpy.context.object
low_poly.name = "potion_bottle_lp"
for mod in list(low_poly.modifiers):
    low_poly.modifiers.remove(mod)
dec = low_poly.modifiers.new("Decimate", 'DECIMATE')
dec.ratio = 0.30
bpy.ops.object.modifier_apply(modifier="Decimate")
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.cube_project(cube_size=2.0)
bpy.ops.object.mode_set(mode='OBJECT')

bake_normal = bpy.data.images.new("potion_bottle_normal_bake", width=1024, height=1024,
                                    alpha=False, float_buffer=False)
bake_normal.colorspace_settings.name = 'Non-Color'
mat_lp = bpy.data.materials.new("v3r4_potion_bottle_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (1200, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (900, 0)
bsdf_lp.inputs["Base Color"].default_value = (0.85, 0.55, 0.40, 1)
bsdf_lp.inputs["Roughness"].default_value = 0.05
bsdf_lp.inputs["IOR"].default_value = 1.50
bsdf_lp.inputs["Transmission Weight"].default_value = 0.85
ntlp.links.new(bsdf_lp.outputs[0], out_lp.inputs[0])
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
scene.render.bake.cage_extrusion = 0.01
scene.render.bake.max_ray_distance = 0.05
scene.cycles.samples = 16
try:
    bpy.ops.object.bake(type='NORMAL')
    nrm_path = os.path.join(TEX_DIR, "potion_bottle_normal_1024.png")
    bake_normal.filepath_raw = nrm_path
    bake_normal.file_format = 'PNG'
    bake_normal.save()
    print(f"Baked normal: {nrm_path}")
except Exception as e:
    print(f"Normal bake failed: {e}")
scene.render.bake.use_selected_to_active = False
scene.cycles.samples = 128

low_poly.location = (0.6, 0, 0)

# ============================================================
# STAGE 7 — RENDERS
# ============================================================
print("=== STAGE 7: Renders ===")

bpy.ops.object.light_add(type='AREA', location=(2, -2, 2))
key = bpy.context.object
key.data.energy = 800; key.data.color = (1.0, 0.92, 0.78); key.data.size = 2

bpy.ops.object.light_add(type='AREA', location=(-2, -1, 1.5))
fill = bpy.context.object
fill.data.energy = 350; fill.data.color = (0.55, 0.65, 0.95); fill.data.size = 2

bpy.ops.object.light_add(type='AREA', location=(0, 2, 1.5))
rim = bpy.context.object
rim.data.energy = 500; rim.data.color = (1.0, 0.55, 0.30); rim.data.size = 2

bpy.ops.mesh.primitive_plane_add(size=4, location=(0, 0, 0))
fl = bpy.context.object; fl.name = "floor"
mat_fl = bpy.data.materials.new("floor")
mat_fl.use_nodes = True
fbsdf = mat_fl.node_tree.nodes["Principled BSDF"]
fbsdf.inputs["Base Color"].default_value = (0.06, 0.06, 0.08, 1)
fbsdf.inputs["Roughness"].default_value = 0.30
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

cam_hp = add_cam("cam_hp", Vector((0, -0.8, 0.4)), Vector((0, 0, 0.2)), lens=85, dof=0.8)
cam_lp = add_cam("cam_lp", Vector((0.6, -0.8, 0.4)), Vector((0.6, 0, 0.2)), lens=85, dof=0.8)
cam_compare = add_cam("cam_compare", Vector((0.3, -1.2, 0.5)), Vector((0.3, 0, 0.2)), lens=60, dof=1.2)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.camera = cam_hp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r4_potion_bottle_hp.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r4_potion_bottle_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r4_potion_bottle_compare.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# ============================================================
# STAGE 8 — GLB EXPORT
# ============================================================
print("=== STAGE 8: GLB export ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

bpy.ops.object.select_all(action='DESELECT')
low_poly.select_set(True)
cork.select_set(True)
liquid.select_set(True)
bpy.context.view_layer.objects.active = low_poly

out_path = os.path.join(EXPORT_DIR, "potion_bottle_r4_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 4 Epic R4-14 Potion Bottle complete ===")
