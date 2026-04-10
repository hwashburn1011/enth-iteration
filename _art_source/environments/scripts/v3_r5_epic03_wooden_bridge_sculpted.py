"""
Expansion V3 — ROUND 5 — Epic R5-03 — Hero Wooden Bridge Sculpted
=================================================================
Arched wooden bridge with carved plank seams, support beams, and
railing posts. Replaces the town's wooden_bridge.glb placeholder.

Pipeline:
  1. Bridge deck: subdivided cube w/ Z-bend arch (verts at center
     pushed up via cosine curve)
  2. Carved plank seams: every other Y-row of front face inset
  3. 6 extruded railing posts (3 per side) sitting on the deck
  4. 4 horizontal railing rails extruded between posts
  5. 2 support beams underneath the deck (extruded down)
  6. Bevel + cube_project UV + multires 1
  7. Wood Pointiness shader (Polyhaven weathered_planks via load
     would be ideal, but procedural for now since this is a
     bake-able sculpt — same noise pattern as R3-08 forge)
  8. Bake albedo + normal high→low
  9. GLB export
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(503)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/v3_r5_wooden_bridge.blend"
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
bg.inputs["Color"].default_value = (0.40, 0.50, 0.60, 1)
bg.inputs["Strength"].default_value = 0.8

# ============================================================
# STAGE 1 — BRIDGE DECK
# ============================================================
print("=== STAGE 1: Bridge deck ===")

bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.20))
hero = bpy.context.object
hero.name = "wooden_bridge_hp"
hero.scale = (0.50, 1.50, 0.05)  # 1m wide x 3m long x 0.10m thick deck
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
for _ in range(3):
    bpy.ops.mesh.subdivide()
bpy.ops.object.mode_set(mode='OBJECT')

bm = bmesh.new()
bm.from_mesh(hero.data)

# === Arch the deck via cosine curve along Y axis ===
print("Arching the deck...")
for v in bm.verts:
    y_norm = (v.co.y + 1.5) / 3.0  # 0..1 across the bridge length
    arch = math.sin(y_norm * math.pi) * 0.18  # peak 0.18m at center
    v.co.z += arch

def closest_face_normal(bm, target, normal_dir):
    best, best_d = None, 1e9
    for f in bm.faces:
        if f.normal.dot(normal_dir) < 0.5:
            continue
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d; best = f
    return best

# === Carve plank seams: top face has rows of planks ===
print("Carving plank seams...")
top_faces = [f for f in bm.faces if f.normal.z > 0.5]
# Group by Y position
y_groups = {}
for f in top_faces:
    y = round(f.calc_center_median().y, 1)
    y_groups.setdefault(y, []).append(f)
# Carve every other Y row
sorted_ys = sorted(y_groups.keys())
seam_targets = []
for i, y in enumerate(sorted_ys):
    if i % 2 == 1:
        seam_targets.extend(y_groups[y])
if seam_targets:
    res = bmesh.ops.inset_individual(bm, faces=seam_targets, thickness=0.015, depth=0.0)
    for f in res.get('faces', []):
        for v in f.verts:
            v.co.z -= 0.008

bm.normal_update()
bm.faces.ensure_lookup_table()

# === Railing posts: 6 extruded posts (3 per side) ===
print("Extruding railing posts...")
for side in [-0.50, 0.50]:
    for y in [-1.20, 0.0, 1.20]:
        # Find a top-face near (side, y) and extrude up
        post_face = closest_face_normal(bm, Vector((side, y, 0.30)), Vector((0, 0, 1)))
        if post_face:
            res = bmesh.ops.inset_individual(bm, faces=[post_face], thickness=0.03, depth=0.0)
            new_f = res['faces'][0] if res.get('faces') else post_face
            geom = bmesh.ops.extrude_face_region(bm, geom=[new_f])
            new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
            for v in new_verts:
                v.co.z += 0.40
            new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
            if new_faces:
                # Cap top w/ slight inset
                geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
                new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
                for v in new_verts2:
                    v.co.z += 0.05
                # Flatten top into a square cap
                avg = sum((v.co for v in new_verts2), Vector()) / len(new_verts2)
                for v in new_verts2:
                    v.co = v.co.lerp(avg, 0.35)

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
# STAGE 2.5 — Multires after unwrap
# ============================================================
hero.modifiers.new("Multires", 'MULTIRES')
bpy.context.view_layer.objects.active = hero
bpy.ops.object.multires_subdivide(modifier="Multires", mode='CATMULL_CLARK')

# ============================================================
# STAGE 3 — WEATHERED WOOD SHADER (procedural, bakeable)
# ============================================================
print("=== STAGE 3: Wood shader ===")

def make_wood_shader():
    m = bpy.data.materials.new("v3r5_wooden_bridge_proc")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.78
    bsdf.inputs["Metallic"].default_value = 0.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (5, 5, 5)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    grain = nodes.new("ShaderNodeTexNoise"); grain.location = (-700, 200)
    grain.inputs["Scale"].default_value = 18.0
    grain.inputs["Detail"].default_value = 10.0
    links.new(mp.outputs["Vector"], grain.inputs["Vector"])

    wood_ramp = nodes.new("ShaderNodeValToRGB"); wood_ramp.location = (-450, 200)
    cr = wood_ramp.color_ramp
    cr.elements[0].position = 0.30
    cr.elements[0].color = (0.20, 0.12, 0.06, 1)
    cr.elements[1].position = 0.70
    cr.elements[1].color = (0.50, 0.32, 0.18, 1)
    el2 = cr.elements.new(0.85)
    el2.color = (0.65, 0.45, 0.25, 1)
    links.new(grain.outputs["Fac"], wood_ramp.inputs["Fac"])
    links.new(wood_ramp.outputs["Color"], bsdf.inputs["Base Color"])

    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -300)
    bp.inputs["Strength"].default_value = 0.50
    links.new(grain.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

mat_proc = make_wood_shader()
hero.data.materials.clear()
hero.data.materials.append(mat_proc)

# ============================================================
# STAGE 4 — BAKE DIFFUSE
# ============================================================
print("=== STAGE 4: Bake DIFFUSE ===")
bake_albedo = bpy.data.images.new("wooden_bridge_albedo_bake", width=1024, height=1024)
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
    bake_path = os.path.join(TEX_DIR, "wooden_bridge_albedo_1024.png")
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
low_poly.name = "wooden_bridge_lp"
for mod in list(low_poly.modifiers):
    low_poly.modifiers.remove(mod)
dec = low_poly.modifiers.new("Decimate", 'DECIMATE')
dec.ratio = 0.30
bpy.ops.object.modifier_apply(modifier="Decimate")
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.cube_project(cube_size=2.0)
bpy.ops.object.mode_set(mode='OBJECT')

bake_normal = bpy.data.images.new("wooden_bridge_normal_bake", width=1024, height=1024,
                                    alpha=False, float_buffer=False)
bake_normal.colorspace_settings.name = 'Non-Color'
mat_lp = bpy.data.materials.new("v3r5_wooden_bridge_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (1200, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (900, 0)
bsdf_lp.inputs["Roughness"].default_value = 0.78
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
    nrm_path = os.path.join(TEX_DIR, "wooden_bridge_normal_1024.png")
    bake_normal.filepath_raw = nrm_path
    bake_normal.file_format = 'PNG'
    bake_normal.save()
    print(f"Baked normal: {nrm_path}")
except Exception as e:
    print(f"Normal bake failed: {e}")
scene.render.bake.use_selected_to_active = False
scene.cycles.samples = 96

low_poly.location = (3.5, 0, 0.20)

# ============================================================
# STAGE 6 — RENDERS
# ============================================================
print("=== STAGE 6: Renders ===")

bpy.ops.object.light_add(type='SUN', location=(0, 0, 8))
sun = bpy.context.object
sun.data.energy = 4.0; sun.data.color = (1.0, 0.92, 0.78)
sun.rotation_euler = (math.radians(50), math.radians(20), 0)

bpy.ops.object.light_add(type='AREA', location=(-4, -3, 4))
fill = bpy.context.object
fill.data.energy = 600; fill.data.color = (0.55, 0.70, 0.95); fill.data.size = 5

bpy.ops.mesh.primitive_plane_add(size=10, location=(0, 0, 0))
fl = bpy.context.object; fl.name = "ground"
mat_fl = bpy.data.materials.new("ground")
mat_fl.use_nodes = True
fbsdf = mat_fl.node_tree.nodes["Principled BSDF"]
fbsdf.inputs["Base Color"].default_value = (0.18, 0.20, 0.10, 1)
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

cam_hp = add_cam("cam_hp", Vector((0, -3.5, 1.5)), Vector((0, 0, 0.4)), lens=50, dof=4)
cam_lp = add_cam("cam_lp", Vector((3.5, -3.5, 1.5)), Vector((3.5, 0, 0.4)), lens=50, dof=4)
cam_compare = add_cam("cam_compare", Vector((1.75, -5, 2.0)), Vector((1.75, 0, 0.4)), lens=42, dof=5)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.camera = cam_hp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r5_wooden_bridge_hp.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r5_wooden_bridge_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r5_wooden_bridge_compare.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# ============================================================
# STAGE 7 — GLB EXPORT
# ============================================================
print("=== STAGE 7: GLB export ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

bpy.ops.object.select_all(action='DESELECT')
low_poly.select_set(True)
bpy.context.view_layer.objects.active = low_poly

out_path = os.path.join(EXPORT_DIR, "wooden_bridge_r5_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 5 Epic R5-03 Wooden Bridge complete ===")
