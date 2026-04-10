"""
Expansion V3 — ROUND 3 — Epic R3-09 — Hero Tree (gnarled trunk + branches)
==========================================================================
Hero tree asset built from a SINGLE-MESH cylinder, not a parent of cones.
The trunk is sculpted via per-vertex displacement + branch extrusions
from real ring loops. Pipeline:

  1. High-segment cylinder base (32 sides, 16 rings)
  2. Per-vertex twist + bark displacement so silhouette is gnarled
  3. Extrude 5 branches outward from selected ring faces
  4. Each branch is extruded 2-3 segments and tapered toward the tip
  5. Multires 2 levels for bark detail
  6. UV unwrap + bark procedural shader (longitudinal grain + cracks)
  7. Bake DIFFUSE → 1024 PNG, decimate retopo, normal bake high→low
  8. SEPARATE foliage canopy: 4 large sphere clusters w/ SSS leaf shader
     (these stay procedural — leaves don't sculpt well in code)
  9. Renders + GLB
  10. No rig (foliage will sway via Godot vertex shader at runtime)
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(309)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/v3_r3_hero_tree.blend"
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
bg.inputs["Color"].default_value = (0.45, 0.55, 0.65, 1)
bg.inputs["Strength"].default_value = 1.0

# ============================================================
# STAGE 1 — TREE TRUNK BASE
# ============================================================
print("=== STAGE 1: Tree trunk base ===")

bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=0.45, depth=5.0, location=(0, 0, 2.5))
hero = bpy.context.object
hero.name = "hero_tree_hp"

# Subdivide for ring loops
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
for _ in range(3):
    bpy.ops.mesh.subdivide()
bpy.ops.object.mode_set(mode='OBJECT')

bm = bmesh.new()
bm.from_mesh(hero.data)

# Gnarled trunk: twist around Z + radius variation by height + bark bumps
for v in bm.verts:
    z_norm = (v.co.z) / 5.0  # 0 = bottom, 1 = top
    # Twist around Z
    twist = z_norm * 0.6
    cos_t = math.cos(twist); sin_t = math.sin(twist)
    nx = v.co.x * cos_t - v.co.y * sin_t
    ny = v.co.x * sin_t + v.co.y * cos_t
    v.co.x = nx
    v.co.y = ny
    # Radius narrows toward top
    if v.co.z > 0.5:
        scale = 1.0 - 0.35 * z_norm
        v.co.x *= scale
        v.co.y *= scale
    # Wide flared base (root system)
    if v.co.z < -1.5:
        base_factor = 1.0 + (-1.5 - v.co.z) * 0.4
        v.co.x *= base_factor
        v.co.y *= base_factor
    # Bark displacement
    seed_val = hash((round(v.co.x, 1), round(v.co.y, 1), round(v.co.z, 1))) & 0xFFFF
    random.seed(seed_val)
    horiz = Vector((v.co.x, v.co.y, 0))
    if horiz.length > 0:
        horiz.normalize()
        v.co += horiz * random.uniform(-0.04, 0.06)

def closest_face(bm, target):
    best, best_d = None, 1e9
    for f in bm.faces:
        d = (f.calc_center_median() - target).length
        if d < best_d:
            best_d = d; best = f
    return best

# === Extrude 5 branches from ring loops ===
print("Extruding branches...")
BRANCH_TARGETS = [
    (Vector(( 0.50, 0.10, 1.5)), Vector(( 1.40, 0.10, 2.4))),
    (Vector((-0.40, 0.30, 2.2)), Vector((-1.20, 0.50, 3.1))),
    (Vector(( 0.10, 0.50, 3.0)), Vector(( 0.20, 1.40, 3.9))),
    (Vector((-0.20, -0.45, 1.8)), Vector((-0.60, -1.30, 2.6))),
    (Vector(( 0.30, -0.30, 3.5)), Vector(( 0.80, -1.10, 4.4))),
]
branch_tips = []
for start, end in BRANCH_TARGETS:
    bf = closest_face(bm, start)
    if bf:
        # First extrude
        geom = bmesh.ops.extrude_face_region(bm, geom=[bf])
        new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
        # Direction from face center toward end
        face_center = bf.calc_center_median()
        direction = (end - face_center) * 0.4
        for v in new_verts:
            v.co += direction
        new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
        if new_faces:
            # Second extrude — taper
            geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
            new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
            for v in new_verts2:
                v.co += direction * 0.7
            # Pinch toward end target
            avg = sum((v.co for v in new_verts2), Vector()) / len(new_verts2)
            for v in new_verts2:
                v.co = v.co.lerp(avg, 0.4)
                v.co = v.co.lerp(end, 0.20)
            new_faces2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMFace)]
            if new_faces2:
                # Third extrude — final taper, near collapse
                geom3 = bmesh.ops.extrude_face_region(bm, geom=[new_faces2[0]])
                new_verts3 = [g for g in geom3['geom'] if isinstance(g, bmesh.types.BMVert)]
                for v in new_verts3:
                    v.co = v.co.lerp(end, 0.7)
                # Final almost-collapse
                avg3 = sum((v.co for v in new_verts3), Vector()) / len(new_verts3)
                for v in new_verts3:
                    v.co = v.co.lerp(avg3, 0.7)
                branch_tips.append(avg3)

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
bpy.ops.uv.smart_project(angle_limit=math.radians(50), island_margin=0.02)
bpy.ops.object.mode_set(mode='OBJECT')

# ============================================================
# STAGE 3 — BARK SHADER
# ============================================================
print("=== STAGE 3: Bark shader ===")

def make_bark_shader():
    m = bpy.data.materials.new("v3r3_bark_proc")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.85
    bsdf.inputs["Metallic"].default_value = 0.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1400, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1200, 0)
    # Stretch UVs vertically — bark grain runs along trunk
    mp.inputs["Scale"].default_value = (4.0, 4.0, 12.0)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Bark grain — vertical noise stretched
    grain = nodes.new("ShaderNodeTexNoise"); grain.location = (-900, 200)
    grain.inputs["Scale"].default_value = 8.0
    grain.inputs["Detail"].default_value = 12.0
    grain.inputs["Roughness"].default_value = 0.6
    links.new(mp.outputs["Vector"], grain.inputs["Vector"])

    # Voronoi bark plate cracks
    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-900, 0)
    v.feature = 'DISTANCE_TO_EDGE'
    v.inputs["Scale"].default_value = 4.0
    links.new(mp.outputs["Vector"], v.inputs["Vector"])

    crack_ramp = nodes.new("ShaderNodeValToRGB"); crack_ramp.location = (-650, 0)
    crack_ramp.color_ramp.elements[0].position = 0.0
    crack_ramp.color_ramp.elements[0].color = (1, 1, 1, 1)
    crack_ramp.color_ramp.elements[1].position = 0.10
    crack_ramp.color_ramp.elements[1].color = (0, 0, 0, 1)
    links.new(v.outputs["Distance"], crack_ramp.inputs["Fac"])

    # Bark color ramp — warm browns
    bark_ramp = nodes.new("ShaderNodeValToRGB"); bark_ramp.location = (-650, 200)
    cr = bark_ramp.color_ramp
    cr.elements[0].position = 0.30
    cr.elements[0].color = (0.10, 0.06, 0.03, 1)   # dark crack interior
    cr.elements[1].position = 0.70
    cr.elements[1].color = (0.30, 0.18, 0.10, 1)   # mid bark
    el2 = cr.elements.new(0.90)
    el2.color = (0.45, 0.30, 0.18, 1)               # highlights on ridges
    links.new(grain.outputs["Fac"], bark_ramp.inputs["Fac"])

    # Mix crack mask onto bark color (cracks darken)
    mix = nodes.new("ShaderNodeMix"); mix.data_type = 'RGBA'; mix.location = (-200, 100)
    links.new(crack_ramp.outputs["Color"], mix.inputs["Factor"])
    links.new(bark_ramp.outputs["Color"], mix.inputs[6])
    mix.inputs[7].default_value = (0.05, 0.03, 0.02, 1)
    links.new(mix.outputs[2], bsdf.inputs["Base Color"])

    # Mossy patches at the base via Z gradient
    sep = nodes.new("ShaderNodeSeparateXYZ"); sep.location = (-1200, -300)
    links.new(tc.outputs["Object"], sep.inputs["Vector"])
    moss_z = nodes.new("ShaderNodeMath"); moss_z.location = (-900, -300)
    moss_z.operation = 'LESS_THAN'
    moss_z.inputs[1].default_value = 0.5  # below z=0.5 = mossy
    links.new(sep.outputs["Z"], moss_z.inputs[0])

    moss_color = nodes.new("ShaderNodeRGB"); moss_color.location = (-900, -500)
    moss_color.outputs[0].default_value = (0.10, 0.20, 0.05, 1)

    moss_mix = nodes.new("ShaderNodeMix"); moss_mix.data_type = 'RGBA'; moss_mix.location = (100, -100)
    links.new(moss_z.outputs[0], moss_mix.inputs["Factor"])
    links.new(mix.outputs[2], moss_mix.inputs[6])
    links.new(moss_color.outputs[0], moss_mix.inputs[7])
    links.new(moss_mix.outputs[2], bsdf.inputs["Base Color"])

    # Bump from bark grain
    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -500)
    bp.inputs["Strength"].default_value = 0.55
    links.new(grain.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

mat_bark = make_bark_shader()
hero.data.materials.clear()
hero.data.materials.append(mat_bark)

# ============================================================
# STAGE 4 — BAKE DIFFUSE
# ============================================================
print("=== STAGE 4: Bake DIFFUSE ===")
bake_albedo = bpy.data.images.new("hero_tree_bark_bake", width=1024, height=1024)
img_node_a = mat_bark.node_tree.nodes.new("ShaderNodeTexImage")
img_node_a.location = (1100, 400)
img_node_a.image = bake_albedo
img_node_a.select = True
mat_bark.node_tree.nodes.active = img_node_a

scene.cycles.bake_type = 'DIFFUSE'
scene.render.bake.use_pass_direct = False
scene.render.bake.use_pass_indirect = False
scene.render.bake.use_pass_color = True
scene.cycles.samples = 32

bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
bpy.context.view_layer.objects.active = hero

print("Baking bark diffuse...")
try:
    bpy.ops.object.bake(type='DIFFUSE')
    bake_path = os.path.join(TEX_DIR, "hero_tree_bark_1024.png")
    bake_albedo.filepath_raw = bake_path
    bake_albedo.file_format = 'PNG'
    bake_albedo.save()
    print(f"Baked bark albedo: {bake_path}")
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
low_poly.name = "hero_tree_lp"

for mod in list(low_poly.modifiers):
    low_poly.modifiers.remove(mod)
dec = low_poly.modifiers.new("Decimate", 'DECIMATE')
dec.ratio = 0.20
bpy.ops.object.modifier_apply(modifier="Decimate")

bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.smart_project(angle_limit=math.radians(50), island_margin=0.02)
bpy.ops.object.mode_set(mode='OBJECT')

print(f"Low-poly trunk: {len(low_poly.data.polygons)} faces")

# ============================================================
# STAGE 6 — NORMAL BAKE
# ============================================================
print("=== STAGE 6: Normal bake ===")
bake_normal = bpy.data.images.new("hero_tree_normal_bake", width=1024, height=1024,
                                    alpha=False, float_buffer=False)
bake_normal.colorspace_settings.name = 'Non-Color'

mat_lp = bpy.data.materials.new("v3r3_hero_tree_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (1200, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (900, 0)
bsdf_lp.inputs["Roughness"].default_value = 0.85
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
    nrm_path = os.path.join(TEX_DIR, "hero_tree_normal_1024.png")
    bake_normal.filepath_raw = nrm_path
    bake_normal.file_format = 'PNG'
    bake_normal.save()
    print(f"Baked normal: {nrm_path}")
except Exception as e:
    print(f"Normal bake failed: {e}")
    import traceback; traceback.print_exc()

scene.render.bake.use_selected_to_active = False
scene.cycles.samples = 96

low_poly.location = (8.0, 0, 2.5)

# ============================================================
# STAGE 7 — FOLIAGE CANOPY (4 sphere clusters w/ SSS leaf shader)
# ============================================================
print("=== STAGE 7: Foliage canopy ===")

def make_leaf_shader():
    m = bpy.data.materials.new("v3r3_leaf_proc")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (800, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (500, 0)
    bsdf.inputs["Roughness"].default_value = 0.55
    bsdf.inputs["Subsurface Weight"].default_value = 0.45
    bsdf.inputs["Subsurface Radius"].default_value = (0.9, 1.0, 0.4)
    bsdf.inputs["Coat Weight"].default_value = 0.2
    bsdf.inputs["Base Color"].default_value = (0.12, 0.32, 0.08, 1)
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-700, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-500, 0)
    mp.inputs["Scale"].default_value = (8, 8, 8)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    n = nodes.new("ShaderNodeTexNoise"); n.location = (-300, 0)
    n.inputs["Scale"].default_value = 12.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])

    leaf_ramp = nodes.new("ShaderNodeValToRGB"); leaf_ramp.location = (-50, 100)
    cr = leaf_ramp.color_ramp
    cr.elements[0].position = 0.30
    cr.elements[0].color = (0.06, 0.18, 0.05, 1)
    cr.elements[1].position = 0.80
    cr.elements[1].color = (0.30, 0.55, 0.15, 1)
    links.new(n.outputs["Fac"], leaf_ramp.inputs["Fac"])
    links.new(leaf_ramp.outputs["Color"], bsdf.inputs["Base Color"])

    bp = nodes.new("ShaderNodeBump"); bp.location = (-50, -200)
    bp.inputs["Strength"].default_value = 0.6
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

mat_leaf = make_leaf_shader()

# 4 canopy clusters at branch tip locations + a top center
canopy_centers = [
    (Vector((1.5, 0.10, 4.6)), 1.20),
    (Vector((-1.30, 0.50, 5.0)), 1.10),
    (Vector((0.20, 1.50, 5.4)), 1.30),
    (Vector((-0.60, -1.40, 4.4)), 1.05),
    (Vector((0.85, -1.20, 5.2)), 1.10),
    (Vector((0, 0.20, 5.8)), 1.40),  # crown
]
canopy_objects = []
for i, (loc, radius) in enumerate(canopy_centers):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3, radius=radius, location=loc)
    leaf = bpy.context.object
    leaf.name = f"canopy_{i}"
    # Per-vertex jitter so clusters don't look like perfect spheres
    bm = bmesh.new()
    bm.from_mesh(leaf.data)
    for v in bm.verts:
        seed_val = hash((round(v.co.x, 2), round(v.co.y, 2), round(v.co.z, 2))) & 0xFFFF
        random.seed(seed_val + i)
        v.co += v.normal * random.uniform(-0.15, 0.20)
    bm.to_mesh(leaf.data)
    bm.free()
    leaf.data.materials.append(mat_leaf)
    for poly in leaf.data.polygons:
        poly.use_smooth = True
    canopy_objects.append(leaf)

# ============================================================
# STAGE 8 — LIGHTING + RENDERS (golden hour outdoor)
# ============================================================
print("=== STAGE 8: Lighting + Renders ===")

# Sun (warm golden hour)
bpy.ops.object.light_add(type='SUN', location=(0, 0, 12))
sun = bpy.context.object
sun.data.energy = 3.5
sun.data.color = (1.0, 0.85, 0.65)
sun.rotation_euler = (math.radians(55), math.radians(25), 0)

# Sky fill
bpy.ops.object.light_add(type='AREA', location=(-8, 8, 8))
fill = bpy.context.object
fill.data.energy = 800
fill.data.color = (0.45, 0.65, 0.95)
fill.data.size = 10

# Bounce
bpy.ops.object.light_add(type='AREA', location=(8, -8, 4))
bounce = bpy.context.object
bounce.data.energy = 400
bounce.data.color = (1.0, 0.80, 0.55)
bounce.data.size = 8

# Ground
bpy.ops.mesh.primitive_plane_add(size=40, location=(0, 0, 0))
gnd = bpy.context.object; gnd.name = "ground"
mat_g = bpy.data.materials.new("ground")
mat_g.use_nodes = True
gbsdf = mat_g.node_tree.nodes["Principled BSDF"]
gbsdf.inputs["Base Color"].default_value = (0.12, 0.18, 0.05, 1)
gbsdf.inputs["Roughness"].default_value = 0.90
gnd.data.materials.append(mat_g)

def add_cam(name, loc, target, lens=70, dof=8.0, fstop=4.0):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = fstop
    c.data.dof.focus_distance = dof
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_hp = add_cam("cam_hp", Vector((-3, -10, 4)), Vector((0, 0, 3.0)), lens=42, dof=12)
cam_lp = add_cam("cam_lp", Vector((5, -10, 4)), Vector((8, 0, 3.0)), lens=42, dof=12)
cam_compare = add_cam("cam_compare", Vector((4, -14, 5)), Vector((4, 0, 3.0)), lens=35, dof=15)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.camera = cam_hp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_hero_tree_hp.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_hero_tree_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_hero_tree_compare.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# ============================================================
# STAGE 9 — GLB EXPORT (low-poly trunk + canopies)
# ============================================================
print("=== STAGE 9: GLB export ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

bpy.ops.object.select_all(action='DESELECT')
low_poly.select_set(True)
for c in canopy_objects:
    c.select_set(True)
bpy.context.view_layer.objects.active = low_poly

out_path = os.path.join(EXPORT_DIR, "hero_tree_r3_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 3 Epic R3-09 Hero Tree complete ===")
