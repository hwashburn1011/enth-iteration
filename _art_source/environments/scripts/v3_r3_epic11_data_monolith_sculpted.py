"""
Expansion V3 — ROUND 3 — Epic R3-11 — Corrupted Data Monolith
=============================================================
Hero techno-dungeon prop fitting the "AI agent inside a crumbling
computer simulation" GDD framing. Floating data shard monolith.

Single-mesh build from a tall subdivided cube w/:
  - Tall obelisk proportions
  - Carved horizontal circuit-trace grooves on each face (inset rows)
  - Carved vertical data slot on the front
  - 3 cube panel insets w/ recessed centers (display ports)
  - Broken upper corner: cluster of verts pulled inward + Z-jittered
    so the silhouette has a fractured look (NOT a clean cube)
  - 4 floating fragment shards extruded from edges (separated mini
    cubes hovering near the broken corner — done via face extrude
    then disconnect)
  - Multires 2 levels
  - Brass/circuit shader: brushed metal + emissive Pointiness on
    recesses (the circuit grooves glow)
  - Bake DIFFUSE + NORMAL high→low
  - GLB export. Static, no rig.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(311)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/v3_r3_data_monolith.blend"
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
bg.inputs["Color"].default_value = (0.04, 0.06, 0.10, 1)
bg.inputs["Strength"].default_value = 0.5

# ============================================================
# STAGE 1 — DATA MONOLITH BASE
# ============================================================
print("=== STAGE 1: Data monolith base ===")

bpy.ops.mesh.primitive_cube_add(size=2.0, location=(0, 0, 2.5))
hero = bpy.context.object
hero.name = "data_monolith_hp"
hero.scale = (0.6, 0.5, 2.5)  # tall obelisk
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

# Subdivide for trace placement
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
for _ in range(4):
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

# === Carve horizontal circuit-trace grooves on the front face ===
print("Carving circuit traces (front)...")
front_faces = [f for f in bm.faces if f.normal.y < -0.5]
# Sort by Z then X
front_faces.sort(key=lambda f: (round(f.calc_center_median().z, 2), round(f.calc_center_median().x, 2)))

# Pick every other Z-row of faces for "trace rows"
z_rows = {}
for f in front_faces:
    z = round(f.calc_center_median().z, 1)
    z_rows.setdefault(z, []).append(f)
sorted_zs = sorted(z_rows.keys())
trace_rows = sorted_zs[::2]  # every 2nd row

trace_faces = []
for z in trace_rows:
    for f in z_rows[z]:
        c = f.calc_center_median()
        # Skip top region (we'll break that)
        if c.z > 4.0:
            continue
        trace_faces.append(f)

if trace_faces:
    res = bmesh.ops.inset_individual(bm, faces=trace_faces, thickness=0.025, depth=0.0)
    new_traces = res.get('faces', [])
    for f in new_traces:
        for v in f.verts:
            v.co.y += 0.04  # push back into the slab

bm.normal_update()
bm.faces.ensure_lookup_table()

# === Carve vertical data slot on the front (center column) ===
print("Carving vertical data slot...")
DATA_SLOT_TARGETS = [
    Vector((0, -0.50, z)) for z in [1.5, 2.0, 2.5, 3.0, 3.5]
]
for target in DATA_SLOT_TARGETS:
    sf = closest_face_normal(bm, target, Vector((0, -1, 0)))
    if sf:
        res = bmesh.ops.inset_individual(bm, faces=[sf], thickness=0.04, depth=0.0)
        new_f = res['faces'][0] if res.get('faces') else sf
        for v in new_f.verts:
            v.co.y += 0.08

bm.normal_update()
bm.faces.ensure_lookup_table()

# === 3 cube panel display ports on the side faces ===
print("Carving display ports...")
PORT_TARGETS = [
    (Vector((-0.62, 0, 1.8)), Vector((-1, 0, 0))),
    (Vector((-0.62, 0, 3.2)), Vector((-1, 0, 0))),
    (Vector((0.62, 0, 2.5)), Vector((1, 0, 0))),
]
for target, normal in PORT_TARGETS:
    pf = closest_face_normal(bm, target, normal)
    if pf:
        # Outer inset (frame)
        res = bmesh.ops.inset_individual(bm, faces=[pf], thickness=0.06, depth=0.0)
        new_f = res['faces'][0] if res.get('faces') else pf
        for v in new_f.verts:
            v.co += -normal * 0.04
        # Inner inset (deep recess for the screen)
        res2 = bmesh.ops.inset_individual(bm, faces=[new_f], thickness=0.03, depth=0.0)
        new_f2 = res2['faces'][0] if res2.get('faces') else new_f
        for v in new_f2.verts:
            v.co += -normal * 0.06

bm.normal_update()

# === Broken upper corner: pull in upper verts + jitter Z ===
print("Breaking upper corner...")
for v in bm.verts:
    if v.co.z > 4.4:
        seed_val = hash((round(v.co.x, 1), round(v.co.y, 1))) & 0xFFFF
        random.seed(seed_val)
        # Pull inward toward center, randomize Z down
        center = Vector((0, 0, 4.5))
        offset = v.co - center
        offset.x *= 0.6
        offset.y *= 0.6
        v.co = center + offset
        v.co.z -= random.uniform(0.0, 0.4)
        # Slight horizontal jitter for fractured look
        v.co.x += random.uniform(-0.04, 0.04)
        v.co.y += random.uniform(-0.04, 0.04)

# === Slight overall verticality jitter for "glitched" effect ===
for v in bm.verts:
    if 1.0 < v.co.z < 4.0:
        seed_val = hash((round(v.co.x, 2), round(v.co.y, 2), round(v.co.z, 2))) & 0xFFFF
        random.seed(seed_val + 999)
        v.co += v.normal * random.uniform(-0.012, 0.012)

bm.normal_update()
bm.to_mesh(hero.data)
bm.free()
hero.data.update()
for poly in hero.data.polygons:
    poly.use_smooth = False  # techno surface flat-shaded for hard edges

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
# STAGE 1B — 4 floating fragment shards (separate small cubes hovering)
# ============================================================
print("=== STAGE 1B: Floating fragments ===")
fragments = []
FRAG_LOCS = [
    (Vector((0.85, 0.35, 4.7)), (0.18, 0.10, 0.10)),
    (Vector((-0.75, 0.45, 4.5)), (0.12, 0.10, 0.18)),
    (Vector((0.20, 0.85, 4.9)), (0.16, 0.08, 0.10)),
    (Vector((-0.45, -0.65, 4.4)), (0.10, 0.10, 0.14)),
]
for i, (loc, sz) in enumerate(FRAG_LOCS):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=loc)
    frag = bpy.context.object
    frag.name = f"data_frag_{i}"
    frag.scale = sz
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    # Random rotation
    random.seed(311 + i)
    frag.rotation_euler = (random.uniform(0, 1), random.uniform(0, 1), random.uniform(0, 1))
    fragments.append(frag)

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
# STAGE 3 — BRASS / CIRCUIT SHADER
# ============================================================
print("=== STAGE 3: Brass + circuit shader ===")

def make_shader():
    m = bpy.data.materials.new("v3r3_data_monolith_proc")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.25
    bsdf.inputs["Metallic"].default_value = 0.85
    bsdf.inputs["Emission Strength"].default_value = 10.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1400, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1200, 0)
    mp.inputs["Scale"].default_value = (4, 4, 4)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Brushed brass base
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-900, 200)
    n.inputs["Scale"].default_value = 18.0
    n.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])

    brass_ramp = nodes.new("ShaderNodeValToRGB"); brass_ramp.location = (-650, 200)
    cr = brass_ramp.color_ramp
    cr.elements[0].position = 0.30
    cr.elements[0].color = (0.30, 0.20, 0.08, 1)   # dark patina
    cr.elements[1].position = 0.70
    cr.elements[1].color = (0.75, 0.55, 0.20, 1)   # bright brass
    links.new(n.outputs["Fac"], brass_ramp.inputs["Fac"])

    # Verdigris green patches (oxidation)
    verd_n = nodes.new("ShaderNodeTexNoise"); verd_n.location = (-900, 0)
    verd_n.inputs["Scale"].default_value = 3.0
    verd_n.inputs["Detail"].default_value = 4.0
    links.new(mp.outputs["Vector"], verd_n.inputs["Vector"])
    verd_ramp = nodes.new("ShaderNodeValToRGB"); verd_ramp.location = (-650, 0)
    verd_ramp.color_ramp.elements[0].position = 0.55
    verd_ramp.color_ramp.elements[0].color = (0, 0, 0, 1)
    verd_ramp.color_ramp.elements[1].position = 0.70
    verd_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(verd_n.outputs["Fac"], verd_ramp.inputs["Fac"])

    verd_color = nodes.new("ShaderNodeRGB"); verd_color.location = (-650, -150)
    verd_color.outputs[0].default_value = (0.18, 0.45, 0.30, 1)

    verd_mix = nodes.new("ShaderNodeMix"); verd_mix.data_type = 'RGBA'; verd_mix.location = (-200, 100)
    links.new(verd_ramp.outputs["Color"], verd_mix.inputs["Factor"])
    links.new(brass_ramp.outputs["Color"], verd_mix.inputs[6])
    links.new(verd_color.outputs[0], verd_mix.inputs[7])

    links.new(verd_mix.outputs[2], bsdf.inputs["Base Color"])

    # === Circuit emission via Pointiness (recesses glow) ===
    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-900, -300)
    pointy_ramp = nodes.new("ShaderNodeValToRGB"); pointy_ramp.location = (-650, -300)
    pointy_ramp.color_ramp.elements[0].position = 0.30
    pointy_ramp.color_ramp.elements[0].color = (1, 1, 1, 1)
    pointy_ramp.color_ramp.elements[1].position = 0.45
    pointy_ramp.color_ramp.elements[1].color = (0, 0, 0, 1)
    links.new(geo.outputs["Pointiness"], pointy_ramp.inputs["Fac"])

    em_color = nodes.new("ShaderNodeRGB"); em_color.location = (-650, -480)
    em_color.outputs[0].default_value = (0.15, 0.85, 1.0, 1)  # cyan circuit glow

    em_mix = nodes.new("ShaderNodeMix"); em_mix.data_type = 'RGBA'; em_mix.location = (100, -300)
    links.new(pointy_ramp.outputs["Color"], em_mix.inputs["Factor"])
    em_mix.inputs[6].default_value = (0, 0, 0, 1)
    links.new(em_color.outputs[0], em_mix.inputs[7])
    links.new(em_mix.outputs[2], bsdf.inputs["Emission Color"])

    # Bump
    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -650)
    bp.inputs["Strength"].default_value = 0.30
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])

    # Roughness varies w/ patina
    rough_ramp = nodes.new("ShaderNodeValToRGB"); rough_ramp.location = (-200, -850)
    rough_ramp.color_ramp.elements[0].position = 0.0
    rough_ramp.color_ramp.elements[0].color = (0.20, 0.20, 0.20, 1)
    rough_ramp.color_ramp.elements[1].position = 1.0
    rough_ramp.color_ramp.elements[1].color = (0.65, 0.65, 0.65, 1)
    links.new(verd_ramp.outputs["Color"], rough_ramp.inputs["Fac"])
    links.new(rough_ramp.outputs["Color"], bsdf.inputs["Roughness"])
    return m

mat_proc = make_shader()
hero.data.materials.clear()
hero.data.materials.append(mat_proc)
for f in fragments:
    f.data.materials.append(mat_proc)
    for poly in f.data.polygons:
        poly.use_smooth = False

# ============================================================
# STAGE 4 — BAKE DIFFUSE
# ============================================================
print("=== STAGE 4: Bake DIFFUSE ===")
bake_albedo = bpy.data.images.new("data_monolith_albedo_bake", width=1024, height=1024)
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
    bake_path = os.path.join(TEX_DIR, "data_monolith_albedo_1024.png")
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
low_poly.name = "data_monolith_lp"

for mod in list(low_poly.modifiers):
    low_poly.modifiers.remove(mod)
dec = low_poly.modifiers.new("Decimate", 'DECIMATE')
dec.ratio = 0.20
bpy.ops.object.modifier_apply(modifier="Decimate")

bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.smart_project(angle_limit=math.radians(50), island_margin=0.02)
bpy.ops.object.mode_set(mode='OBJECT')

print(f"Low-poly: {len(low_poly.data.polygons)} faces")

# ============================================================
# STAGE 6 — NORMAL BAKE
# ============================================================
print("=== STAGE 6: Normal bake high → low ===")
bake_normal = bpy.data.images.new("data_monolith_normal_bake", width=1024, height=1024,
                                    alpha=False, float_buffer=False)
bake_normal.colorspace_settings.name = 'Non-Color'

mat_lp = bpy.data.materials.new("v3r3_data_monolith_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (1200, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (900, 0)
bsdf_lp.inputs["Roughness"].default_value = 0.30
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
scene.render.bake.cage_extrusion = 0.04
scene.render.bake.max_ray_distance = 0.30
scene.cycles.samples = 16

try:
    bpy.ops.object.bake(type='NORMAL')
    nrm_path = os.path.join(TEX_DIR, "data_monolith_normal_1024.png")
    bake_normal.filepath_raw = nrm_path
    bake_normal.file_format = 'PNG'
    bake_normal.save()
    print(f"Baked normal: {nrm_path}")
except Exception as e:
    print(f"Normal bake failed: {e}")
    import traceback; traceback.print_exc()

scene.render.bake.use_selected_to_active = False
scene.cycles.samples = 96

low_poly.location = (5.0, 0, 2.5)

# ============================================================
# STAGE 7 — LIGHTING + RENDERS
# ============================================================
print("=== STAGE 7: Lighting + Renders ===")

# Cyan key from below (data glow ambience)
bpy.ops.object.light_add(type='SPOT', location=(2, -8, 1))
key = bpy.context.object
key.data.energy = 3000; key.data.color = (0.40, 0.85, 1.0)
key.data.spot_size = math.radians(80)
direction = Vector((0, 0, 2.5)) - key.location
key.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

# Warm rim
bpy.ops.object.light_add(type='AREA', location=(-6, 6, 6))
rim = bpy.context.object
rim.data.energy = 1100; rim.data.color = (1.0, 0.55, 0.20); rim.data.size = 6

# Cool fill
bpy.ops.object.light_add(type='AREA', location=(6, 4, 4))
fill = bpy.context.object
fill.data.energy = 500; fill.data.color = (0.45, 0.55, 0.85); fill.data.size = 6

# Floor
bpy.ops.mesh.primitive_plane_add(size=20, location=(0, 0, 0))
fl = bpy.context.object; fl.name = "floor"
mat_fl = bpy.data.materials.new("floor")
mat_fl.use_nodes = True
fbsdf = mat_fl.node_tree.nodes["Principled BSDF"]
fbsdf.inputs["Base Color"].default_value = (0.04, 0.05, 0.07, 1)
fbsdf.inputs["Roughness"].default_value = 0.30
fbsdf.inputs["Metallic"].default_value = 0.30
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

cam_hp = add_cam("cam_hp", Vector((-1, -8, 3.0)), Vector((0, 0, 2.5)), lens=50, dof=8)
cam_lp = add_cam("cam_lp", Vector((4, -8, 3.0)), Vector((5.0, 0, 2.5)), lens=50, dof=8)
cam_compare = add_cam("cam_compare", Vector((2.5, -11, 3.5)), Vector((2.5, 0, 2.5)), lens=42, dof=12)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.camera = cam_hp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_data_monolith_hp.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_data_monolith_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_data_monolith_compare.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# ============================================================
# STAGE 8 — GLB EXPORT
# ============================================================
print("=== STAGE 8: GLB export ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

bpy.ops.object.select_all(action='DESELECT')
low_poly.select_set(True)
for f in fragments:
    f.select_set(True)
bpy.context.view_layer.objects.active = low_poly

out_path = os.path.join(EXPORT_DIR, "data_monolith_r3_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 3 Epic R3-11 Data Monolith complete ===")
