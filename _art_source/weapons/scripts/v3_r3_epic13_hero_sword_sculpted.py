"""
Expansion V3 — ROUND 3 — Epic R3-13 — Hero Weapon (Sculpted Sword)
==================================================================
First R3 weapon. Single-mesh ARPG sword carved from a tall flattened
cube. Real geometry features:
  - Diamond cross-section blade w/ carved center fuller (groove)
  - 4 rune insets along the blade (Pointiness-glow capable)
  - Crossguard extruded perpendicular to the blade
  - Grip section w/ carved leather wrap rings (inset ring loops)
  - Pommel formed by ring extrude + bulge
  - Multires 1 level (weapon should stay readable, not over-soft)
  - Steel+brass procedural shader w/ Pointiness-driven cyan rune emission
  - Bake DIFFUSE + NORMAL high→low
  - GLB export. Static.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(313)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/weapons/v3_r3_hero_sword.blend"
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

scene.world = bpy.data.worlds.new("v3r3_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.05, 0.05, 0.08, 1)
bg.inputs["Strength"].default_value = 0.4

# ============================================================
# STAGE 1 — SWORD BASE MESH
# ============================================================
print("=== STAGE 1: Sword base ===")

# Tall flat slab — blade dominates
bpy.ops.mesh.primitive_cube_add(size=2.0, location=(0, 0, 0))
hero = bpy.context.object
hero.name = "hero_sword_hp"
# Scale: blade is long (Z), wide (X), thin (Y)
hero.scale = (0.10, 0.04, 0.85)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

# Subdivide for feature placement
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
for _ in range(4):
    bpy.ops.mesh.subdivide()
bpy.ops.object.mode_set(mode='OBJECT')

bm = bmesh.new()
bm.from_mesh(hero.data)

# Diamond cross-section: pinch X toward center on Y axis
# (the slab is wider in X than Y; we want the silhouette to be a sharp blade)
# We achieve this by pushing the center-Y verts outward along X (blade ridge)
for v in bm.verts:
    # The "front" and "back" of the blade (Y > 0 and Y < 0) should pinch toward center-X
    # The center plane (Y near 0) should bulge outward at the blade edges
    # Currently the slab is a rectangle in cross-section. We want a diamond.
    # Step 1: Reduce X for non-center-Y verts (front/back faces become narrower)
    if abs(v.co.y) > 0.02:
        v.co.x *= 0.55
    # Step 2: The blade tip should taper. We're using Z range; tip is at top (highest Z).
    if v.co.z > 1.30:
        # Linear taper in X from 1.30 to 1.70
        t = (v.co.z - 1.30) / 0.40  # 0 at base, 1 at very tip
        t = min(1.0, max(0.0, t))
        v.co.x *= (1.0 - t * 0.95)

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

# === Carve fuller groove down the center of the blade (front + back faces) ===
print("Carving fuller groove...")
front_faces = [f for f in bm.faces if f.normal.y > 0.5]
back_faces = [f for f in bm.faces if f.normal.y < -0.5]

# Pick the center column of front/back faces along the blade region (Z=0.0 to 1.20)
def column_faces(faces, x_target=0.0, z_min=-0.6, z_max=1.20, x_tol=0.04):
    return [f for f in faces if abs(f.calc_center_median().x) < x_tol and z_min < f.calc_center_median().z < z_max]

fuller_front = column_faces(front_faces)
fuller_back = column_faces(back_faces)

if fuller_front:
    res = bmesh.ops.inset_individual(bm, faces=fuller_front, thickness=0.012, depth=0.0)
    for f in res.get('faces', []):
        for v in f.verts:
            v.co.y -= 0.012

if fuller_back:
    res = bmesh.ops.inset_individual(bm, faces=fuller_back, thickness=0.012, depth=0.0)
    for f in res.get('faces', []):
        for v in f.verts:
            v.co.y += 0.012

bm.normal_update()
bm.faces.ensure_lookup_table()

# === 4 rune insets along the blade ===
print("Carving rune insets...")
RUNE_Z = [0.20, 0.50, 0.80, 1.10]
for z in RUNE_Z:
    for normal_dir, sign in [(Vector((0, 1, 0)), -1), (Vector((0, -1, 0)), 1)]:
        rf = closest_face_normal(bm, Vector((0, sign * 0.05, z)), normal_dir)
        if rf:
            res = bmesh.ops.inset_individual(bm, faces=[rf], thickness=0.015, depth=0.0)
            new_f = res['faces'][0] if res.get('faces') else rf
            for v in new_f.verts:
                v.co += normal_dir * -0.008  # push back into blade

bm.normal_update()
bm.faces.ensure_lookup_table()

# === Crossguard: extrude wide on X at Z = -0.65 ===
print("Extruding crossguard...")
# Find faces on the sides (X faces) at the base of the blade
left_guard_face = closest_face_normal(bm, Vector((-0.10, 0, -0.65)), Vector((-1, 0, 0)))
right_guard_face = closest_face_normal(bm, Vector((0.10, 0, -0.65)), Vector((1, 0, 0)))

for gf, side in [(left_guard_face, -1), (right_guard_face, 1)]:
    if gf:
        # Extrude outward
        geom = bmesh.ops.extrude_face_region(bm, geom=[gf])
        new_verts = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMVert)]
        for v in new_verts:
            v.co.x += side * 0.20
        new_faces = [g for g in geom['geom'] if isinstance(g, bmesh.types.BMFace)]
        if new_faces:
            geom2 = bmesh.ops.extrude_face_region(bm, geom=[new_faces[0]])
            new_verts2 = [g for g in geom2['geom'] if isinstance(g, bmesh.types.BMVert)]
            for v in new_verts2:
                v.co.x += side * 0.10
            avg = sum((v.co for v in new_verts2), Vector()) / len(new_verts2)
            for v in new_verts2:
                v.co = v.co.lerp(avg, 0.30)

bm.normal_update()
bm.faces.ensure_lookup_table()

# === Grip wrap rings: inset 4 rings on the bottom face column ===
print("Carving grip wrap rings...")
# Grip extends from Z = -1.30 to -0.70. Inset front+back at 4 Z positions.
GRIP_Z = [-1.20, -1.05, -0.90, -0.75]
for z in GRIP_Z:
    for normal_dir in [Vector((0, 1, 0)), Vector((0, -1, 0))]:
        gf = closest_face_normal(bm, Vector((0, normal_dir.y * 0.05, z)), normal_dir)
        if gf:
            res = bmesh.ops.inset_individual(bm, faces=[gf], thickness=0.010, depth=0.0)
            new_f = res['faces'][0] if res.get('faces') else gf
            for v in new_f.verts:
                v.co += normal_dir * -0.006

bm.normal_update()

# === Pommel: bulge bottom ring outward ===
print("Bulging pommel...")
for v in bm.verts:
    if v.co.z < -1.55:
        v.co.x *= 1.6
        v.co.y *= 1.6

bm.normal_update()
bm.to_mesh(hero.data)
bm.free()
hero.data.update()
for poly in hero.data.polygons:
    poly.use_smooth = False  # weapon flat-shaded for clean edges

# Bevel + multires 1
print("Adding bevel + multires...")
bev = hero.modifiers.new("Bevel", 'BEVEL')
bev.width = 0.005
bev.segments = 2

hero.modifiers.new("Multires", 'MULTIRES')
bpy.context.view_layer.objects.active = hero
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
# STAGE 3 — STEEL + BRASS SHADER
# ============================================================
print("=== STAGE 3: Steel + brass shader ===")

def make_shader():
    m = bpy.data.materials.new("v3r3_hero_sword_proc")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.15
    bsdf.inputs["Metallic"].default_value = 0.95
    bsdf.inputs["Emission Strength"].default_value = 8.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1400, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1200, 0)
    mp.inputs["Scale"].default_value = (4, 4, 4)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    sep = nodes.new("ShaderNodeSeparateXYZ"); sep.location = (-1200, -300)
    links.new(tc.outputs["Object"], sep.inputs["Vector"])

    # Polished steel — high-frequency low-amplitude noise
    steel_n = nodes.new("ShaderNodeTexNoise"); steel_n.location = (-900, 200)
    steel_n.inputs["Scale"].default_value = 24.0
    steel_n.inputs["Detail"].default_value = 12.0
    links.new(mp.outputs["Vector"], steel_n.inputs["Vector"])

    steel_ramp = nodes.new("ShaderNodeValToRGB"); steel_ramp.location = (-650, 200)
    steel_ramp.color_ramp.elements[0].position = 0.40
    steel_ramp.color_ramp.elements[0].color = (0.30, 0.32, 0.36, 1)
    steel_ramp.color_ramp.elements[1].position = 0.70
    steel_ramp.color_ramp.elements[1].color = (0.75, 0.78, 0.85, 1)
    links.new(steel_n.outputs["Fac"], steel_ramp.inputs["Fac"])

    # Brass — for crossguard + pommel + grip wrap (Z based)
    brass_color = nodes.new("ShaderNodeRGB"); brass_color.location = (-650, 0)
    brass_color.outputs[0].default_value = (0.85, 0.55, 0.18, 1)

    # Z mask: brass below z=-0.55 (crossguard, grip, pommel)
    z_brass = nodes.new("ShaderNodeMath"); z_brass.location = (-900, -150)
    z_brass.operation = 'LESS_THAN'
    z_brass.inputs[1].default_value = -0.55
    links.new(sep.outputs["Z"], z_brass.inputs[0])

    # Mix steel → brass
    mix_metal = nodes.new("ShaderNodeMix"); mix_metal.data_type = 'RGBA'; mix_metal.location = (-200, 100)
    links.new(z_brass.outputs[0], mix_metal.inputs["Factor"])
    links.new(steel_ramp.outputs["Color"], mix_metal.inputs[6])
    links.new(brass_color.outputs[0], mix_metal.inputs[7])

    # Leather grip wrap zone: -1.30 < z < -0.75 → brown
    leather_color = nodes.new("ShaderNodeRGB"); leather_color.location = (-650, -200)
    leather_color.outputs[0].default_value = (0.20, 0.10, 0.04, 1)

    z_leather_lo = nodes.new("ShaderNodeMath"); z_leather_lo.location = (-900, -300)
    z_leather_lo.operation = 'GREATER_THAN'
    z_leather_lo.inputs[1].default_value = -1.30
    links.new(sep.outputs["Z"], z_leather_lo.inputs[0])

    z_leather_hi = nodes.new("ShaderNodeMath"); z_leather_hi.location = (-900, -450)
    z_leather_hi.operation = 'LESS_THAN'
    z_leather_hi.inputs[1].default_value = -0.75
    links.new(sep.outputs["Z"], z_leather_hi.inputs[0])

    z_leather_and = nodes.new("ShaderNodeMath"); z_leather_and.location = (-700, -350)
    z_leather_and.operation = 'MULTIPLY'
    links.new(z_leather_lo.outputs[0], z_leather_and.inputs[0])
    links.new(z_leather_hi.outputs[0], z_leather_and.inputs[1])

    mix_leather = nodes.new("ShaderNodeMix"); mix_leather.data_type = 'RGBA'; mix_leather.location = (100, 0)
    links.new(z_leather_and.outputs[0], mix_leather.inputs["Factor"])
    links.new(mix_metal.outputs[2], mix_leather.inputs[6])
    links.new(leather_color.outputs[0], mix_leather.inputs[7])

    links.new(mix_leather.outputs[2], bsdf.inputs["Base Color"])

    # === Rune emission via Pointiness ===
    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-900, -600)
    pointy_ramp = nodes.new("ShaderNodeValToRGB"); pointy_ramp.location = (-650, -600)
    pointy_ramp.color_ramp.elements[0].position = 0.30
    pointy_ramp.color_ramp.elements[0].color = (1, 1, 1, 1)
    pointy_ramp.color_ramp.elements[1].position = 0.45
    pointy_ramp.color_ramp.elements[1].color = (0, 0, 0, 1)
    links.new(geo.outputs["Pointiness"], pointy_ramp.inputs["Fac"])

    em_color = nodes.new("ShaderNodeRGB"); em_color.location = (-650, -780)
    em_color.outputs[0].default_value = (0.30, 0.85, 1.0, 1)  # cyan rune

    em_mix = nodes.new("ShaderNodeMix"); em_mix.data_type = 'RGBA'; em_mix.location = (100, -500)
    links.new(pointy_ramp.outputs["Color"], em_mix.inputs["Factor"])
    em_mix.inputs[6].default_value = (0, 0, 0, 1)
    links.new(em_color.outputs[0], em_mix.inputs[7])
    links.new(em_mix.outputs[2], bsdf.inputs["Emission Color"])

    # Roughness: leather rougher than metal
    rough_ramp = nodes.new("ShaderNodeValToRGB"); rough_ramp.location = (100, -700)
    rough_ramp.color_ramp.elements[0].position = 0.0
    rough_ramp.color_ramp.elements[0].color = (0.12, 0.12, 0.12, 1)
    rough_ramp.color_ramp.elements[1].position = 1.0
    rough_ramp.color_ramp.elements[1].color = (0.85, 0.85, 0.85, 1)
    links.new(z_leather_and.outputs[0], rough_ramp.inputs["Fac"])
    links.new(rough_ramp.outputs["Color"], bsdf.inputs["Roughness"])

    # Bump
    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -900)
    bp.inputs["Strength"].default_value = 0.20
    links.new(steel_n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

mat_proc = make_shader()
hero.data.materials.clear()
hero.data.materials.append(mat_proc)

# ============================================================
# STAGE 4 — BAKE DIFFUSE
# ============================================================
print("=== STAGE 4: Bake DIFFUSE ===")
bake_albedo = bpy.data.images.new("hero_sword_albedo_bake", width=1024, height=1024)
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
    bake_path = os.path.join(TEX_DIR, "hero_sword_albedo_1024.png")
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
low_poly.name = "hero_sword_lp"

for mod in list(low_poly.modifiers):
    low_poly.modifiers.remove(mod)
dec = low_poly.modifiers.new("Decimate", 'DECIMATE')
dec.ratio = 0.30
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
bake_normal = bpy.data.images.new("hero_sword_normal_bake", width=1024, height=1024,
                                    alpha=False, float_buffer=False)
bake_normal.colorspace_settings.name = 'Non-Color'

mat_lp = bpy.data.materials.new("v3r3_hero_sword_baked")
mat_lp.use_nodes = True
ntlp = mat_lp.node_tree
ntlp.nodes.clear()
out_lp = ntlp.nodes.new("ShaderNodeOutputMaterial"); out_lp.location = (1200, 0)
bsdf_lp = ntlp.nodes.new("ShaderNodeBsdfPrincipled"); bsdf_lp.location = (900, 0)
bsdf_lp.inputs["Roughness"].default_value = 0.20
bsdf_lp.inputs["Metallic"].default_value = 0.95
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
    nrm_path = os.path.join(TEX_DIR, "hero_sword_normal_1024.png")
    bake_normal.filepath_raw = nrm_path
    bake_normal.file_format = 'PNG'
    bake_normal.save()
    print(f"Baked normal: {nrm_path}")
except Exception as e:
    print(f"Normal bake failed: {e}")
    import traceback; traceback.print_exc()

scene.render.bake.use_selected_to_active = False
scene.cycles.samples = 96

low_poly.location = (1.0, 0, 0)

# ============================================================
# STAGE 7 — LIGHTING + RENDERS
# ============================================================
print("=== STAGE 7: Lighting + Renders ===")

# Cool key (steel highlights)
bpy.ops.object.light_add(type='AREA', location=(-3, -5, 4))
key = bpy.context.object
key.data.energy = 1500; key.data.color = (0.85, 0.92, 1.0); key.data.size = 4

# Warm rim (brass glow)
bpy.ops.object.light_add(type='AREA', location=(4, 4, 3))
rim = bpy.context.object
rim.data.energy = 800; rim.data.color = (1.0, 0.65, 0.30); rim.data.size = 5

# Cyan accent (rune mood)
bpy.ops.object.light_add(type='AREA', location=(0, -4, -1))
fill = bpy.context.object
fill.data.energy = 400; fill.data.color = (0.30, 0.80, 1.0); fill.data.size = 4

# Floor
bpy.ops.mesh.primitive_plane_add(size=10, location=(0, 0, -2.0))
fl = bpy.context.object; fl.name = "floor"
mat_fl = bpy.data.materials.new("floor")
mat_fl.use_nodes = True
fbsdf = mat_fl.node_tree.nodes["Principled BSDF"]
fbsdf.inputs["Base Color"].default_value = (0.06, 0.07, 0.10, 1)
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

cam_hp = add_cam("cam_hp", Vector((0, -3, 0.5)), Vector((0, 0, 0)), lens=85, dof=3)
cam_lp = add_cam("cam_lp", Vector((1.0, -3, 0.5)), Vector((1.0, 0, 0)), lens=85, dof=3)
cam_compare = add_cam("cam_compare", Vector((0.5, -4.5, 0.5)), Vector((0.5, 0, 0)), lens=60, dof=4.5)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

scene.camera = cam_hp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_hero_sword_hp.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_lp
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_hero_sword_lp_baked.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.camera = cam_compare
scene.render.filepath = os.path.join(RENDER_DIR, "v3_r3_hero_sword_compare.png")
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

out_path = os.path.join(EXPORT_DIR, "hero_sword_r3_v3.glb")
try:
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=False,
    )
    print(f"Exported: {out_path}")
except Exception as e:
    print(f"GLB export failed: {e}")

print("=== V3 Round 3 Epic R3-13 Hero Sword complete ===")
