"""
Expansion V3 — ROUND 3 — Epic R3-07 — Dungeon Wall Hero
=======================================================
Sculpted dungeon wall section. Single mesh w/:
  - Subdivided plane base (tall slab)
  - Real brick joint recesses carved via inset_individual on a grid
  - 3 glowing rune insets (rune-shaped recesses) with strong emission
  - Cracked/broken top edge (extruded random verts upward at random heights)
  - 1 protruding sconce bracket extruded from face
  - Multires 2 levels for sub-detail
  - UV unwrap, wet-stone procedural shader
  - Bake DIFFUSE + NORMAL high→low
  - Static mesh, no rig
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(307)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/v3_r3_dungeon_wall.blend"
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
bg.inputs["Color"].default_value = (0.02, 0.02, 0.04, 1)
bg.inputs["Strength"].default_value = 0.3

# ============================================================
# STAGE 1 — DUNGEON WALL BASE MESH
# ============================================================
print("=== STAGE 1: Dungeon wall base ===")

# Use a cube (give it real depth) instead of plane — walls have thickness
bpy.ops.mesh.primitive_cube_add(size=2.0, location=(0, 0, 2.0))
hero = bpy.context.object
hero.name = "dungeon_wall_hp"

# Stretch to wall proportions
hero.scale = (3.0, 0.4, 2.0)  # 6m wide, 0.8m thick, 4m tall
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

# Subdivide the front face for brick layout
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
for _ in range(4):  # 4 subdivisions
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

# === Carve brick joint grid on the front face (-Y normal) ===
# Find all front faces and inset them in a brick-offset pattern
print("Carving brick joints...")
front_faces = [f for f in bm.faces if f.normal.y < -0.5]
# Sort by Z then X for stable iteration
front_faces.sort(key=lambda f: (round(f.calc_center_median().z, 2), round(f.calc_center_median().x, 2)))

# Inset every face individually to create grout lines
inset_targets = []
for f in front_faces:
    c = f.calc_center_median()
    # Skip faces near the broken top edge (we'll smash those)
    if c.z > 3.6:
        continue
    inset_targets.append(f)

if inset_targets:
    res = bmesh.ops.inset_individual(bm, faces=inset_targets, thickness=0.025, depth=0.0)
    new_faces = res.get('faces', [])
    # Push them slightly outward (bricks proud of grout, grout recessed)
    for f in new_faces:
        for v in f.verts:
            v.co.y -= 0.025  # push brick face outward (-Y)

# Random per-brick height variation
for f in new_faces:
    seed_val = hash((round(f.calc_center_median().x, 1), round(f.calc_center_median().z, 1))) & 0xFFFF
    random.seed(seed_val)
    jitter = random.uniform(-0.015, 0.025)
    for v in f.verts:
        v.co.y -= jitter

bm.normal_update()

# === 3 glowing rune insets — pick faces in upper-middle area ===
print("Carving glowing runes...")
# Refresh face list after inset
bm.faces.ensure_lookup_table()
RUNE_TARGETS = [
    Vector((-1.6, -0.40, 2.4)),
    Vector((0.0, -0.40, 2.6)),
    Vector((1.6, -0.40, 2.4)),
]
rune_faces = []
for target in RUNE_TARGETS:
    rf = closest_face_normal(bm, target, Vector((0, -1, 0)))
    if rf:
        # Inset deep — runes are carved INTO the wall
        res = bmesh.ops.inset_individual(bm, faces=[rf], thickness=0.06, depth=0.0)
        new_f = res['faces'][0] if res.get('faces') else rf
        for v in new_f.verts:
            v.co.y += 0.10  # push back into wall
        rune_faces.append(new_f)

bm.normal_update()

# === Sconce bracket — extrude one face on the side ===
print("Extruding sconce bracket...")
sconce_face = closest_face_normal(bm, Vector((-2.5, -0.40, 2.8)), Vector((0, -1, 0)))
if sconce_face:
    geom = bmesh.ops.extrude_face_region(bm, geom=[sconce_face])
    new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
    for v in new_verts:
        v.co.y -= 0.30  # push outward
        v.co.z -= 0.05
    new_faces2 = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
    if new_faces2:
        # Extrude tip into a small bowl
        geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces2[0]])
        new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
        for v in new_verts2:
            v.co.y -= 0.10
            v.co.z -= 0.08

# === Broken top edge — find top verts and randomize their Z ===
print("Breaking top edge...")
for v in bm.verts:
    if v.co.z > 3.85:
        seed_val = hash((round(v.co.x, 1), round(v.co.y, 1))) & 0xFFFF
        random.seed(seed_val)
        v.co.z -= random.uniform(0.0, 0.5)
        # Slight horizontal jitter for jagged silhouette
        v.co.x += random.uniform(-0.03, 0.03)

bm.normal_update()
bm.to_mesh(hero.data)
bm.free()
hero.data.update()

# Mark rune faces for material slot 1 (we'll assign separate emissive material later)
# Track them by index BEFORE bm.free
# ... actually we'll handle rune emission via the procedural shader using a geometry mask
for poly in hero.data.polygons:
    poly.use_smooth = False  # stone walls flat-shaded

# Bevel + multires
print("Adding bevel + multires...")
bev = hero.modifiers.new("Bevel", 'BEVEL')
bev.width = 0.012
bev.segments = 2

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
bpy.ops.uv.smart_project(angle_limit=math.radians(45), island_margin=0.02)
bpy.ops.object.mode_set(mode='OBJECT')

# ============================================================
# STAGE 3 — PROCEDURAL SHADER (wet stone + rune glow via curvature)
# ============================================================
print("=== STAGE 3: Procedural shader ===")

def make_shader(name):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.55
    bsdf.inputs["Metallic"].default_value = 0.05
    bsdf.inputs["Emission Strength"].default_value = 6.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1400, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1200, 0)
    mp.inputs["Scale"].default_value = (3.0, 3.0, 3.0)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Stone noise
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-900, 200)
    n.inputs["Scale"].default_value = 18.0
    n.inputs["Detail"].default_value = 10.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])

    stone_ramp = nodes.new("ShaderNodeValToRGB"); stone_ramp.location = (-650, 200)
    cr = stone_ramp.color_ramp
    cr.elements[0].position = 0.30
    cr.elements[0].color = (0.10, 0.09, 0.08, 1)   # dark wet stone
    cr.elements[1].position = 0.70
    cr.elements[1].color = (0.30, 0.27, 0.24, 1)   # mid stone
    links.new(n.outputs["Fac"], stone_ramp.inputs["Fac"])

    # Mossy patches via second noise (greenish in low areas)
    moss_n = nodes.new("ShaderNodeTexNoise"); moss_n.location = (-900, -50)
    moss_n.inputs["Scale"].default_value = 4.0
    moss_n.inputs["Detail"].default_value = 4.0
    links.new(mp.outputs["Vector"], moss_n.inputs["Vector"])
    moss_ramp = nodes.new("ShaderNodeValToRGB"); moss_ramp.location = (-650, -50)
    moss_ramp.color_ramp.elements[0].position = 0.50
    moss_ramp.color_ramp.elements[0].color = (0, 0, 0, 1)
    moss_ramp.color_ramp.elements[1].position = 0.65
    moss_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(moss_n.outputs["Fac"], moss_ramp.inputs["Fac"])

    moss_color = nodes.new("ShaderNodeRGB"); moss_color.location = (-650, -200)
    moss_color.outputs[0].default_value = (0.10, 0.20, 0.08, 1)

    moss_mix = nodes.new("ShaderNodeMix"); moss_mix.data_type = 'RGBA'; moss_mix.location = (-300, 100)
    links.new(moss_ramp.outputs["Color"], moss_mix.inputs["Factor"])
    links.new(stone_ramp.outputs["Color"], moss_mix.inputs[6])
    links.new(moss_color.outputs[0], moss_mix.inputs[7])

    links.new(moss_mix.outputs[2], bsdf.inputs["Base Color"])

    # === Rune emission via Geometry pointiness (negative curvature = recess) ===
    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-900, -400)
    pointy_ramp = nodes.new("ShaderNodeValToRGB"); pointy_ramp.location = (-650, -400)
    # Pointiness: 0 = recess, 0.5 = flat, 1 = ridge
    pointy_ramp.color_ramp.elements[0].position = 0.30
    pointy_ramp.color_ramp.elements[0].color = (1, 1, 1, 1)
    pointy_ramp.color_ramp.elements[1].position = 0.45
    pointy_ramp.color_ramp.elements[1].color = (0, 0, 0, 1)
    links.new(geo.outputs["Pointiness"], pointy_ramp.inputs["Fac"])

    # Rune emission color (cyan-blue dungeon glow)
    rune_color = nodes.new("ShaderNodeRGB"); rune_color.location = (-650, -550)
    rune_color.outputs[0].default_value = (0.20, 0.65, 1.0, 1)

    em_mix = nodes.new("ShaderNodeMix"); em_mix.data_type = 'RGBA'; em_mix.location = (100, -400)
    links.new(pointy_ramp.outputs["Color"], em_mix.inputs["Factor"])
    em_mix.inputs[6].default_value = (0, 0, 0, 1)
    links.new(rune_color.outputs[0], em_mix.inputs[7])
    links.new(em_mix.outputs[2], bsdf.inputs["Emission Color"])

    # Bump
    bp = nodes.new("ShaderNodeBump"); bp.location = (-300, -700)
    bp.inputs["Strength"].default_value = 0.50
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])

    # Roughness varies with moss
    rough_ramp = nodes.new("ShaderNodeValToRGB"); rough_ramp.location = (-300, -900)
    rough_ramp.color_ramp.elements[0].position = 0.0
    rough_ramp.color_ramp.elements[0].color = (0.50, 0.50, 0.50, 1)  # smooth wet stone
    rough_ramp.color_ramp.elements[1].position = 1.0
    rough_ramp.color_ramp.elements[1].color = (0.95, 0.95, 0.95, 1)  # rough moss
    links.new(moss_ramp.outputs["Color"], rough_ramp.inputs["Fac"])
    links.new(rough_ramp.outputs["Color"], bsdf.inputs["Roughness"])
    return m

mat_proc = make_shader("v3r3_dungeon_wall_proc")
hero.data.materials.clear()
hero.data.materials.append(mat_proc)

# ============================================================
# STAGE 4 — BAKE DIFFUSE
# ============================================================
print("=== STAGE 4: Bake DIFFUSE ===")
bake_albedo = bpy.data.images.new("dungeon_wall_albedo_bake", width=1024, height=1024)
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
    bake_path = os.path.join(TEX_DIR, "dungeon_wall_albedo_1024.png")
    bake_albedo.filepath_raw = bake_path
    bake_albedo.file_format = 'PNG'
    bake_albedo.save()
    print(f"Baked albedo: {bake_path}")
except Exception as e:
    print(f"Albedo bake failed: {e}")

# ============================================================
# STAGE 5 — RETOPO LOW-POLY
# ============================================================
print("=== STAGE 5: Retopo low-poly ===")
bpy.ops.object.select_all(action='DESELECT')
hero.select_set(True)
bpy.context.view_layer.objects.active = hero
bpy.ops.object.duplicate()
low_poly = bpy.context.object
low_poly.name = "dungeon_wall_lp"

for mod in list(low_poly.modifiers):
    low_poly.modifiers.remove(mod)
dec = low_poly.modifiers.new("Decimate", 'DECIMATE')
dec.ratio = 0.25
bpy.ops.object.modifier_apply(modifier="Decimate")

bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.smart_project(angle_limit=math.radians(45), island_margin=0.02)
bpy.ops.object.mode_set(mode='OBJECT')

print(f"Low-poly: {len(low_poly.data.polygons)} faces")

# ============================================================
# STAGE 6 — NORMAL BAKE
# ============================================================
print("=== STAGE 6: Normal bake high → low ===")
bake_normal = bpy.data.images.new("dungeon_wall_normal_bake", width=1024, height=1024,
                                    alpha=False, float_buffer=False)
bake_normal.colorspace_settings.name = 'Non-Color'

mat_lp = bpy.data.materials.new("v3r3_dungeon_wall_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (1200, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (900, 0)
bsdf_lp.inputs["Roughness"].default_value = 0.60
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
scene.render.bake.cage_extrusion = 0.04
scene.render.bake.max_ray_distance = 0.30
scene.cycles.samples = 16

try:
    bpy.ops.object.bake(type='NORMAL')
    nrm_path = os.path.join(TEX_DIR, "dungeon_wall_normal_1024.png")
    bake_normal.filepath_raw = nrm_path
    bake_normal.file_format = 'PNG'
    bake_normal.save()
    print(f"Baked normal: {nrm_path}")
except Exception as e:
    print(f"Normal bake failed: {e}")
    import traceback; traceback.print_exc()

scene.render.bake.use_selected_to_active = False
scene.cycles.samples = 96

low_poly.location = (8.0, 0, 2.0)

# ============================================================
# STAGE 7 — LIGHTING + RENDERS (dungeon torch lighting)
# ============================================================
print("=== STAGE 7: Lighting + Renders ===")

# Torch key (warm flicker)
bpy.ops.object.light_add(type='POINT', location=(-2.5, -1.5, 3.0))
torch = bpy.context.object
torch.data.energy = 250
torch.data.color = (1.0, 0.55, 0.20)

# Cool rim from "rune glow" direction
bpy.ops.object.light_add(type='AREA', location=(2, -3, 2.5))
rim = bpy.context.object
rim.data.energy = 600; rim.data.color = (0.30, 0.55, 1.0); rim.data.size = 4

# Ambient fill
bpy.ops.object.light_add(type='AREA', location=(0, -8, 5))
fill = bpy.context.object
fill.data.energy = 200; fill.data.color = (0.50, 0.55, 0.65); fill.data.size = 6

# Floor
bpy.ops.mesh.primitive_plane_add(size=20, location=(0, 0, 0))
fl = bpy.context.object; fl.name = "floor"
mat_fl = bpy.data.materials.new("floor")
mat_fl.use_nodes = True
fbsdf = mat_fl.node_tree.nodes["Principled BSDF"]
fbsdf.inputs["Base Color"].default_value = (0.05, 0.05, 0.06, 1)
fbsdf.inputs["Roughness"].default_value = 0.65
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

cam_hp = add_cam("cam_hp", Vector((0, -7, 2.5)), Vector((0, 0, 2.0)), lens=50, dof=7)
cam_lp = add_cam("cam_lp", Vector((8, -7, 2.5)), Vector((8, 0, 2.0)), lens=50, dof=7)
cam_compare = add_cam("cam_compare", Vector((4, -10, 3.0)), Vector((4, 0, 2.0)), lens=40, dof=10)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.camera = cam_hp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_dungeon_wall_hp.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_dungeon_wall_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_dungeon_wall_compare.png")
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

out_path = os.path.join(EXPORT_DIR, "dungeon_wall_r3_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 3 Epic R3-07 Dungeon Wall complete ===")
