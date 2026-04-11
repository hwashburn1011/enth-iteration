"""
Expansion V3 — ROUND 4 — Epic R4-12 — Hero Shield Sculpted
==========================================================
Round wooden shield to pair with R3-13 hero sword on the player.

Pipeline (R3 quality bar):
  1. Single-mesh disc base — cylinder w/ low depth
  2. Front face inset → flatten + slight dome curvature
  3. Iron rim band: outer ring of front face faces extruded slightly outward
  4. Central iron boss: extruded dome from center face cluster
  5. 12 decorative rivet bumps extruded around the rim band
     (extrude_face_region tip-collapsed)
  6. Bevel modifier
  7. UV unwrap (cube_project)
  8. Multires 1 level (after unwrap)
  9. Wood + iron Pointiness shader (boss + rivets glow as iron, wood
     stays warm grain) — same pattern as R3-17 dungeon door
 10. Bake DIFFUSE + NORMAL high→low
 11. Renders + GLB export
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(412)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/weapons/v3_r4_hero_shield.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/weapons/renders"
TEX_DIR      = "C:/Users/hwash/Documents/enth-iteration/_art_source/textures/baked"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/weapons/exports"
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
bg.inputs["Color"].default_value = (0.05, 0.05, 0.08, 1)
bg.inputs["Strength"].default_value = 0.4

# ============================================================
# STAGE 1 — SHIELD DISC BASE
# ============================================================
print("=== STAGE 1: Shield disc base ===")

# Cylinder w/ low depth = disc
bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=0.50, depth=0.10, location=(0, 0, 0))
hero = bpy.context.object
hero.name = "hero_shield_hp"
hero.rotation_euler = (math.radians(90), 0, 0)
bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)

# Subdivide for feature placement
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
for _ in range(2):
    bpy.ops.mesh.subdivide()
bpy.ops.object.mode_set(mode='OBJECT')

bm = bmesh.new()
bm.from_mesh(hero.data)

# Slight dome curve on front face (-Y)
for v in bm.verts:
    if v.co.y < -0.02:
        # Push center verts slightly forward, edge verts back
        radial = math.sqrt(v.co.x ** 2 + v.co.z ** 2)
        dome_factor = 1.0 - (radial / 0.50)
        v.co.y -= dome_factor * 0.04

def closest_face(bm, target):
    best, best_d = None, 1e9
    for f in bm.faces:
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d; best = f
    return best

# === Central iron boss: extrude center face cluster forward into a dome ===
print("Extruding central boss...")
center_face = closest_face(bm, Vector((0, -0.06, 0)))
if center_face:
    geom = bmesh.ops.extrude_face_region(bm, geom=[center_face])
    new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
    for v in new_verts:
        v.co.y -= 0.08
    new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
    if new_faces:
        # Second extrude — pinch into dome
        geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
        new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
        for v in new_verts2:
            v.co.y -= 0.06
        avg = sum((v.co for v in new_verts2), Vector()) / len(new_verts2)
        for v in new_verts2:
            v.co = v.co.lerp(avg, 0.6)

bm.normal_update()
bm.faces.ensure_lookup_table()

# === 12 decorative rivet bumps extruded around the rim band ===
print("Extruding 12 rivet bumps...")
for i in range(12):
    angle = i * (math.tau / 12)
    rivet_target = Vector((math.cos(angle) * 0.40, -0.06, math.sin(angle) * 0.40))
    rf = closest_face(bm, rivet_target)
    if rf:
        geom = bmesh.ops.extrude_face_region(bm, geom=[rf])
        new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
        for v in new_verts:
            v.co.y -= 0.025
        new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
        if new_faces:
            # Pinch top to dome the rivet head
            geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
            new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
            for v in new_verts2:
                v.co.y -= 0.012
            avg = sum((v.co for v in new_verts2), Vector()) / len(new_verts2)
            for v in new_verts2:
                v.co = v.co.lerp(avg, 0.40)

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
print("=== STAGE 2.5: Multires ===")
hero.modifiers.new("Multires", 'MULTIRES')
bpy.context.view_layer.objects.active = hero
bpy.ops.object.multires_subdivide(modifier="Multires", mode='CATMULL_CLARK')

# ============================================================
# STAGE 3 — WOOD + IRON SHADER (Pointiness-driven)
# ============================================================
print("=== STAGE 3: Wood + iron shader ===")

def make_shield_shader():
    m = bpy.data.materials.new("v3r4_hero_shield_proc")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.65
    bsdf.inputs["Metallic"].default_value = 0.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1400, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1200, 0)
    mp.inputs["Scale"].default_value = (4, 4, 4)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Wood grain base
    grain = nodes.new("ShaderNodeTexNoise"); grain.location = (-900, 200)
    grain.inputs["Scale"].default_value = 14.0
    grain.inputs["Detail"].default_value = 10.0
    links.new(mp.outputs["Vector"], grain.inputs["Vector"])

    wood_ramp = nodes.new("ShaderNodeValToRGB"); wood_ramp.location = (-650, 200)
    cr = wood_ramp.color_ramp
    cr.elements[0].position = 0.30
    cr.elements[0].color = (0.18, 0.10, 0.05, 1)
    cr.elements[1].position = 0.70
    cr.elements[1].color = (0.45, 0.28, 0.15, 1)
    links.new(grain.outputs["Fac"], wood_ramp.inputs["Fac"])

    # Pointiness drives iron color on the boss + rivet ridges
    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-900, -200)
    pointy_ramp = nodes.new("ShaderNodeValToRGB"); pointy_ramp.location = (-650, -200)
    pointy_ramp.color_ramp.elements[0].position = 0.55
    pointy_ramp.color_ramp.elements[0].color = (0, 0, 0, 1)
    pointy_ramp.color_ramp.elements[1].position = 0.70
    pointy_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(geo.outputs["Pointiness"], pointy_ramp.inputs["Fac"])

    iron_color = nodes.new("ShaderNodeRGB"); iron_color.location = (-650, -350)
    iron_color.outputs[0].default_value = (0.30, 0.32, 0.38, 1)

    iron_mix = nodes.new("ShaderNodeMix"); iron_mix.data_type = 'RGBA'; iron_mix.location = (100, 0)
    links.new(pointy_ramp.outputs["Color"], iron_mix.inputs["Factor"])
    links.new(wood_ramp.outputs["Color"], iron_mix.inputs[6])
    links.new(iron_color.outputs[0], iron_mix.inputs[7])
    links.new(iron_mix.outputs[2], bsdf.inputs["Base Color"])

    # Roughness: iron polished, wood rough
    rough_ramp = nodes.new("ShaderNodeValToRGB"); rough_ramp.location = (100, -200)
    rough_ramp.color_ramp.elements[0].position = 0.0
    rough_ramp.color_ramp.elements[0].color = (0.85, 0.85, 0.85, 1)
    rough_ramp.color_ramp.elements[1].position = 1.0
    rough_ramp.color_ramp.elements[1].color = (0.25, 0.25, 0.25, 1)
    links.new(pointy_ramp.outputs["Color"], rough_ramp.inputs["Fac"])
    links.new(rough_ramp.outputs["Color"], bsdf.inputs["Roughness"])

    # Metallic on iron edges
    metal_ramp = nodes.new("ShaderNodeValToRGB"); metal_ramp.location = (100, -400)
    metal_ramp.color_ramp.elements[0].position = 0.0
    metal_ramp.color_ramp.elements[0].color = (0, 0, 0, 1)
    metal_ramp.color_ramp.elements[1].position = 1.0
    metal_ramp.color_ramp.elements[1].color = (0.95, 0.95, 0.95, 1)
    links.new(pointy_ramp.outputs["Color"], metal_ramp.inputs["Fac"])
    links.new(metal_ramp.outputs["Color"], bsdf.inputs["Metallic"])

    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -550)
    bp.inputs["Strength"].default_value = 0.40
    links.new(grain.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

mat_proc = make_shield_shader()
hero.data.materials.clear()
hero.data.materials.append(mat_proc)

# ============================================================
# STAGE 4 — BAKE DIFFUSE
# ============================================================
print("=== STAGE 4: Bake DIFFUSE ===")
bake_albedo = bpy.data.images.new("hero_shield_albedo_bake", width=1024, height=1024)
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
    bake_path = os.path.join(TEX_DIR, "hero_shield_albedo_1024.png")
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
low_poly.name = "hero_shield_lp"

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
print("=== STAGE 6: Normal bake ===")
bake_normal = bpy.data.images.new("hero_shield_normal_bake", width=1024, height=1024,
                                    alpha=False, float_buffer=False)
bake_normal.colorspace_settings.name = 'Non-Color'

mat_lp = bpy.data.materials.new("v3r4_hero_shield_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (1200, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (900, 0)
bsdf_lp.inputs["Roughness"].default_value = 0.55
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
scene.render.bake.cage_extrusion = 0.02
scene.render.bake.max_ray_distance = 0.10
scene.cycles.samples = 16

try:
    bpy.ops.object.bake(type='NORMAL')
    nrm_path = os.path.join(TEX_DIR, "hero_shield_normal_1024.png")
    bake_normal.filepath_raw = nrm_path
    bake_normal.file_format = 'PNG'
    bake_normal.save()
    print(f"Baked normal: {nrm_path}")
except Exception as e:
    print(f"Normal bake failed: {e}")

scene.render.bake.use_selected_to_active = False
scene.cycles.samples = 96

low_poly.location = (1.4, 0, 0)

# ============================================================
# STAGE 7 — RENDERS
# ============================================================
print("=== STAGE 7: Renders ===")

bpy.ops.object.light_add(type='AREA', location=(2, -3, 3))
key = bpy.context.object
key.data.energy = 1500; key.data.color = (1.0, 0.92, 0.78); key.data.size = 4

bpy.ops.object.light_add(type='AREA', location=(-3, -2, 2))
fill = bpy.context.object
fill.data.energy = 600; fill.data.color = (0.55, 0.65, 0.95); fill.data.size = 4

bpy.ops.object.light_add(type='AREA', location=(0, 3, 2))
rim = bpy.context.object
rim.data.energy = 800; rim.data.color = (1.0, 0.65, 0.30); rim.data.size = 4

bpy.ops.mesh.primitive_plane_add(size=8, location=(0, 0, -0.6))
fl = bpy.context.object; fl.name = "floor"
mat_fl = bpy.data.materials.new("floor")
mat_fl.use_nodes = True
fbsdf = mat_fl.node_tree.nodes["Principled BSDF"]
fbsdf.inputs["Base Color"].default_value = (0.05, 0.05, 0.07, 1)
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

cam_hp = add_cam("cam_hp", Vector((0, -1.6, 0.4)), Vector((0, 0, 0)), lens=85, dof=1.6)
cam_lp = add_cam("cam_lp", Vector((1.4, -1.6, 0.4)), Vector((1.4, 0, 0)), lens=85, dof=1.6)
cam_compare = add_cam("cam_compare", Vector((0.7, -2.4, 0.6)), Vector((0.7, 0, 0)), lens=60, dof=2.4)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.camera = cam_hp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r4_hero_shield_hp.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r4_hero_shield_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r4_hero_shield_compare.png")
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

out_path = os.path.join(EXPORT_DIR, "hero_shield_r4_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 4 Epic R4-12 Hero Shield complete ===")
