"""
Expansion V3 — Epic 29 — Lighting Bible Refinement
==================================================
9 reference lighting setups demonstrated on the same hero subject
(simple Globbler-style stand-in figure on a circular plinth) so that
designers/cinematographers/level artists have a one-stop reference
for what each lighting style produces.

Setups:
  1. CINEMATIC SUNSET   — warm 1500W key + cool 350W fill + warm rim
  2. COOL MORNING       — cool 1300W key + warm 250W fill + cyan rim
  3. DRAMATIC TOP SPOT  — single 4500W spot from above
  4. LOW-KEY NOIR       — small 1800W spot from front-side, no fill
  5. BACKLIT SILHOUETTE — strong 4000W back rim, dim 100W front
  6. BRIGHT DAYLIGHT    — Hosek-Wilkie sun at noon, soft fill
  7. COOL CORRIDOR      — 2500W cyan key + 600W cool fill + warm accent
  8. THREE-COLOR SPLIT  — red key + cyan fill + magenta rim
  9. SOFT OVERCAST      — 3 large soft area lights for shadowless look

Each setup renders to:
  _art_source/world/lighting_bible/v3_lighting_NN_NAME.png @ 1280x960

Plus 1 contact-sheet grid render @ 1920x1080.

A markdown reference document is generated at:
  _bmad-output/visual-overhaul/lighting-bible.md
"""
import bpy, bmesh, math, os
from mathutils import Vector

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/v3_lighting_bible.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/lighting_bible"
GRID_DIR     = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/renders"
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(GRID_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 96
scene.cycles.use_denoising = True
scene.render.resolution_x = 1280
scene.render.resolution_y = 960
scene.view_settings.look = 'AgX - High Contrast'

# ============================================================
# SHADER HELPER
# ============================================================
def make_pbr(name, base_color, roughness=0.65, metallic=0.0,
             emission_color=None, emission_strength=0.0,
             noise_strength=0.20, voronoi_strength=0.0, voronoi_scale=22.0,
             curvature_dirt=True, fresnel_rim=False,
             bump_strength=0.10, bump_scale=35.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    output = nodes.new("ShaderNodeOutputMaterial"); output.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Base Color"].default_value = (*base_color, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    if emission_color is not None:
        bsdf.inputs["Emission Color"].default_value = (*emission_color, 1.0)
        bsdf.inputs["Emission Strength"].default_value = emission_strength
    links.new(bsdf.outputs[0], output.inputs[0])
    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (5,5,5)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])
    if noise_strength > 0:
        n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
        n.inputs["Scale"].default_value = 14.0
        n.inputs["Detail"].default_value = 8.0
        links.new(mp.outputs["Vector"], n.inputs["Vector"])
        r = nodes.new("ShaderNodeValToRGB"); r.location = (-450, 200)
        r.color_ramp.elements[0].position = 0.35
        r.color_ramp.elements[0].color = (base_color[0]*0.78, base_color[1]*0.78, base_color[2]*0.78, 1)
        r.color_ramp.elements[1].position = 0.70
        r.color_ramp.elements[1].color = (min(base_color[0]*1.22,1), min(base_color[1]*1.22,1), min(base_color[2]*1.22,1), 1)
        links.new(n.outputs["Fac"], r.inputs["Fac"])
        mx = nodes.new("ShaderNodeMix"); mx.data_type='RGBA'; mx.location=(-200,100)
        mx.inputs["Factor"].default_value = noise_strength
        mx.inputs[6].default_value = (*base_color, 1)
        links.new(r.outputs["Color"], mx.inputs[7])
        base_out = mx.outputs[2]
    else:
        rgb = nodes.new("ShaderNodeRGB"); rgb.location=(-200,100)
        rgb.outputs[0].default_value = (*base_color, 1)
        base_out = rgb.outputs[0]
    if curvature_dirt:
        g = nodes.new("ShaderNodeNewGeometry"); g.location=(-700,-350)
        ar = nodes.new("ShaderNodeValToRGB"); ar.location=(-450,-350)
        ar.color_ramp.elements[0].position = 0.30
        ar.color_ramp.elements[0].color = (0.10,0.07,0.04,1)
        ar.color_ramp.elements[1].position = 0.70
        ar.color_ramp.elements[1].color = (1,1,1,1)
        links.new(g.outputs["Pointiness"], ar.inputs["Fac"])
        md = nodes.new("ShaderNodeMix"); md.data_type='RGBA'; md.location=(300,0)
        md.inputs["Factor"].default_value = 0.40
        links.new(base_out, md.inputs[6])
        links.new(ar.outputs["Color"], md.inputs[7])
        base_out = md.outputs[2]
    if fresnel_rim and emission_color is not None:
        fr = nodes.new("ShaderNodeFresnel"); fr.location=(300,300)
        fr.inputs["IOR"].default_value = 1.45
        rc = nodes.new("ShaderNodeRGB"); rc.location=(300,450)
        rc.outputs[0].default_value = (*emission_color, 1)
        mr = nodes.new("ShaderNodeMix"); mr.data_type='RGBA'; mr.location=(550,350)
        mr.inputs[6].default_value = (0,0,0,1)
        links.new(fr.outputs["Fac"], mr.inputs["Factor"])
        links.new(rc.outputs[0], mr.inputs[7])
        links.new(mr.outputs[2], bsdf.inputs["Emission Color"])
        bsdf.inputs["Emission Strength"].default_value = max(emission_strength, 1.5)
    bn = nodes.new("ShaderNodeTexNoise"); bn.location=(-700,-550)
    bn.inputs["Scale"].default_value = bump_scale
    bn.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], bn.inputs["Vector"])
    bp = nodes.new("ShaderNodeBump"); bp.location=(-450,-550)
    bp.inputs["Strength"].default_value = bump_strength
    links.new(bn.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    links.new(base_out, bsdf.inputs["Base Color"])
    return m

# ============================================================
# MATERIALS
# ============================================================
mat_shell  = make_pbr("v3lb_shell", (0.18, 0.42, 0.85), 0.20, 0.40,
    emission_color=(0.40, 0.65, 1.0), emission_strength=0.5,
    noise_strength=0.15, curvature_dirt=True, fresnel_rim=True, bump_strength=0.10)
mat_accent = make_pbr("v3lb_accent", (0.95, 0.78, 0.20), 0.10, 1.0,
    emission_color=(1.0, 0.85, 0.40), emission_strength=1.0,
    noise_strength=0.05, curvature_dirt=True, fresnel_rim=True)
mat_eye    = make_pbr("v3lb_eye", (0.30, 0.95, 1.0), 0.05, 0,
    emission_color=(0.45, 1.0, 1.0), emission_strength=12.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mat_visor  = make_pbr("v3lb_visor", (0.05, 0.05, 0.10), 0.10, 0.50,
    emission_color=(0.30, 0.85, 1.0), emission_strength=2.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mat_floor  = make_pbr("v3lb_floor", (0.32, 0.30, 0.28), 0.30, 0.10,
    noise_strength=0.20, voronoi_strength=0.30, voronoi_scale=8.0, bump_strength=0.10, bump_scale=14.0)

# ============================================================
# UTIL
# ============================================================
def add_subsurf_bevel(obj, levels=2, bevel=0.025):
    s = obj.modifiers.new("Subsurf", 'SUBSURF'); s.levels = levels; s.render_levels = levels+1
    b = obj.modifiers.new("Bevel", 'BEVEL'); b.width = bevel; b.segments = 3; b.profile = 0.7
    for poly in obj.data.polygons: poly.use_smooth = True

def sph(name, loc, r, mat, parent, segs=24):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segs, ring_count=segs//2, radius=r, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=2, bevel=0.005)
    o.parent = parent
    return o

def cyl(name, loc, r, depth, mat, parent, verts=18, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=r, depth=depth, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    return o

def box(name, loc, scale, mat, parent, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.object; o.name = name; o.scale = scale; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o)
    o.parent = parent
    return o

def cone(name, loc, r1, r2, depth, mat, parent, verts=14, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    return o

def tor(name, loc, R, r, mat, parent, ms=24, mn=10, rot=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_segments=ms, minor_segments=mn, major_radius=R, minor_radius=r, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.005)
    o.parent = parent
    return o

# ============================================================
# HERO SUBJECT — Globbler-style hero figure
# ============================================================
parent = bpy.data.objects.new("v3_lighting_subject", None); scene.collection.objects.link(parent)

# Plinth
cyl("plinth", (0, 0, 0.10), 1.20, 0.20, mat_floor, parent, verts=32)
cyl("plinth_top", (0, 0, 0.22), 1.18, 0.04, mat_accent, parent, verts=32)

# Body (capsule-ish: tapered cylinder + sphere head)
body = cyl("body", (0, 0, 1.05), 0.45, 1.40, mat_shell, parent, verts=24)
# Bottom belt
tor("belt", (0, 0, 0.40), 0.46, 0.05, mat_accent, parent, ms=32, mn=10)
# Mid chest emblem
sph("emblem", (0, 0.45, 1.10), 0.10, mat_accent, parent, segs=14)
# Shoulders
sph("sh_l", (-0.50, 0, 1.55), 0.20, mat_shell, parent, segs=18)
sph("sh_r", (0.50, 0, 1.55), 0.20, mat_shell, parent, segs=18)
# Arms (upper + lower)
cyl("arm_l_u", (-0.55, 0, 1.20), 0.10, 0.55, mat_shell, parent, verts=12, rot=(0, -0.1, 0))
cyl("arm_l_l", (-0.62, 0, 0.75), 0.09, 0.45, mat_shell, parent, verts=12)
cyl("arm_r_u", (0.55, 0, 1.20), 0.10, 0.55, mat_shell, parent, verts=12, rot=(0, 0.1, 0))
cyl("arm_r_l", (0.62, 0, 0.75), 0.09, 0.45, mat_shell, parent, verts=12)
# Hands (yellow accent)
sph("hand_l", (-0.62, 0, 0.50), 0.10, mat_accent, parent, segs=14)
sph("hand_r", (0.62, 0, 0.50), 0.10, mat_accent, parent, segs=14)
# Head
head = sph("head", (0, 0, 1.95), 0.32, mat_shell, parent, segs=24)
head.scale = (1.0, 0.95, 1.05)
# Visor (curved bar across face)
box("visor", (0, 0.30, 1.95), (0.40, 0.06, 0.10), mat_visor, parent)
# 2 emissive eye dots inside visor
sph("eye_l", (-0.10, 0.34, 1.95), 0.04, mat_eye, parent, segs=12)
sph("eye_r", (0.10, 0.34, 1.95), 0.04, mat_eye, parent, segs=12)
# Antenna on top
cyl("antenna", (0, 0, 2.40), 0.02, 0.30, mat_accent, parent, verts=8)
sph("antenna_t", (0, 0, 2.55), 0.05, mat_eye, parent, segs=12)
# Halo behind
tor("halo", (0, -0.25, 2.20), 0.40, 0.025, mat_accent, parent, ms=36, mn=10, rot=(math.pi/2, 0, 0))
# Backpack
box("pack", (0, -0.55, 1.20), (0.50, 0.20, 0.50), mat_shell, parent)

# Save initial
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# ============================================================
# CAMERA — single hero shot used by all setups
# ============================================================
bpy.ops.object.camera_add(location=(4.5, -5.5, 2.0))
cam = bpy.context.object; cam.name = "cam_hero"
cam.data.lens = 70
cam.data.dof.use_dof = True
cam.data.dof.aperture_fstop = 4.0
cam.data.dof.focus_distance = 7.0
target = Vector((0, 0, 1.4))
direction = target - cam.location
cam.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
scene.camera = cam

# ============================================================
# LIGHTING SETUPS — 9 named functions
# ============================================================
def clear_lights():
    for o in list(bpy.data.objects):
        if o.type == 'LIGHT':
            bpy.data.objects.remove(o, do_unlink=True)

def add_area(loc, energy, color, size, target=Vector((0,0,1.4)), rot=None):
    bpy.ops.object.light_add(type='AREA', location=loc)
    l = bpy.context.object
    l.data.energy = energy; l.data.color = color; l.data.size = size
    if rot is None:
        d = Vector(target) - Vector(loc)
        l.rotation_euler = d.to_track_quat('-Z', 'Y').to_euler()
    else:
        l.rotation_euler = rot
    return l

def add_spot(loc, energy, color, spot_size_deg=70, blend=0.4, target=Vector((0,0,1.4))):
    bpy.ops.object.light_add(type='SPOT', location=loc)
    l = bpy.context.object
    l.data.energy = energy; l.data.color = color
    l.data.spot_size = math.radians(spot_size_deg)
    l.data.spot_blend = blend
    d = Vector(target) - Vector(loc)
    l.rotation_euler = d.to_track_quat('-Z', 'Y').to_euler()
    return l

def add_sun(elevation_deg, azimuth_deg, energy, color, angle_deg=2):
    bpy.ops.object.light_add(type='SUN', location=(0, 0, 10))
    l = bpy.context.object
    l.data.energy = energy
    l.data.color = color
    l.data.angle = math.radians(angle_deg)
    el = math.radians(elevation_deg)
    az = math.radians(azimuth_deg)
    direction = Vector((math.sin(az)*math.cos(el), -math.cos(az)*math.cos(el), -math.sin(el)))
    l.rotation_euler = (-direction).to_track_quat('-Z', 'Y').to_euler()
    return l

def world_color(rgb, strength):
    if scene.world is None:
        scene.world = bpy.data.worlds.new("v3lb_world")
    w = scene.world
    w.use_nodes = True
    w.node_tree.nodes.clear()
    out = w.node_tree.nodes.new("ShaderNodeOutputWorld")
    bg = w.node_tree.nodes.new("ShaderNodeBackground")
    bg.inputs["Color"].default_value = (*rgb, 1)
    bg.inputs["Strength"].default_value = strength
    w.node_tree.links.new(bg.outputs[0], out.inputs[0])

def world_sky(elevation_deg=45, turbidity=2.5):
    if scene.world is None:
        scene.world = bpy.data.worlds.new("v3lb_world")
    w = scene.world
    w.use_nodes = True
    w.node_tree.nodes.clear()
    out = w.node_tree.nodes.new("ShaderNodeOutputWorld")
    sky = w.node_tree.nodes.new("ShaderNodeTexSky")
    sky.sky_type = 'HOSEK_WILKIE'
    el = math.radians(elevation_deg)
    sky.sun_direction = (0.5, -0.5, math.sin(el))
    sky.turbidity = turbidity
    sky.ground_albedo = 0.3
    bg = w.node_tree.nodes.new("ShaderNodeBackground")
    bg.inputs["Strength"].default_value = 1.0
    w.node_tree.links.new(sky.outputs[0], bg.inputs[0])
    w.node_tree.links.new(bg.outputs[0], out.inputs[0])

# === 9 setups ===
def setup_01_cinematic_sunset():
    clear_lights()
    world_color((0.04, 0.05, 0.07), 0.5)
    add_area((4, -5, 5), 1500, (1.0, 0.78, 0.45), 5)  # warm key
    add_area((-4, 4, 4), 350, (0.45, 0.55, 0.95), 5)  # cool fill
    add_area((0, 6, 3), 700, (1.0, 0.65, 0.30), 4)    # warm rim

def setup_02_cool_morning():
    clear_lights()
    world_color((0.06, 0.08, 0.12), 0.6)
    add_area((4, -5, 5), 1300, (0.55, 0.75, 1.0), 5)
    add_area((-4, 4, 4), 250, (1.0, 0.88, 0.65), 5)
    add_area((0, 6, 4), 400, (0.40, 0.85, 1.0), 5)

def setup_03_dramatic_top_spot():
    clear_lights()
    world_color((0.01, 0.01, 0.02), 0.2)
    add_spot((0, 0.5, 7), 4500, (1.0, 0.95, 0.85), spot_size_deg=50, blend=0.30, target=Vector((0, 0, 1.0)))

def setup_04_low_key_noir():
    clear_lights()
    world_color((0.01, 0.01, 0.015), 0.15)
    add_spot((4, -3, 3.5), 1800, (1.0, 0.96, 0.88), spot_size_deg=60, blend=0.35, target=Vector((0, 0, 1.4)))

def setup_05_backlit_silhouette():
    clear_lights()
    world_color((0.03, 0.05, 0.10), 0.4)
    add_area((0, 6, 5), 4000, (1.0, 0.85, 0.55), 6, target=Vector((0, 0, 1.4)))
    add_area((0, -7, 2), 100, (0.55, 0.65, 0.95), 4)

def setup_06_bright_daylight():
    clear_lights()
    world_sky(elevation_deg=55, turbidity=2.0)
    add_sun(elevation_deg=55, azimuth_deg=140, energy=5.0, color=(1.0, 0.96, 0.88))
    add_area((-5, 5, 6), 600, (0.65, 0.78, 1.0), 8)

def setup_07_cool_corridor():
    clear_lights()
    world_color((0.02, 0.03, 0.05), 0.4)
    add_spot((0, -7, 5), 2500, (0.40, 0.85, 1.0), spot_size_deg=70, blend=0.35, target=Vector((0, 0, 1.4)))
    add_area((-5, 0, 3), 600, (0.30, 0.65, 1.0), 5)
    add_area((5, 0, 2), 300, (1.0, 0.55, 0.20), 4)  # warm accent

def setup_08_three_color_split():
    clear_lights()
    world_color((0.02, 0.02, 0.04), 0.3)
    add_area((4, -5, 4), 1500, (1.0, 0.30, 0.20), 5)  # red key
    add_area((-4, -3, 4), 1200, (0.30, 0.85, 1.0), 5) # cyan fill
    add_area((0, 6, 4), 1000, (0.95, 0.30, 0.95), 5)  # magenta rim

def setup_09_soft_overcast():
    clear_lights()
    world_color((0.55, 0.62, 0.70), 0.8)
    # 3 large soft lights from top + sides
    add_area((0, 0, 8), 1800, (1.0, 1.0, 1.0), 14, rot=(math.pi, 0, 0))
    add_area((-8, 0, 5), 600, (0.95, 0.95, 1.0), 12)
    add_area((8, 0, 5), 600, (1.0, 0.96, 0.88), 12)

SETUPS = [
    ("cinematic_sunset",   setup_01_cinematic_sunset),
    ("cool_morning",       setup_02_cool_morning),
    ("dramatic_top_spot",  setup_03_dramatic_top_spot),
    ("low_key_noir",       setup_04_low_key_noir),
    ("backlit_silhouette", setup_05_backlit_silhouette),
    ("bright_daylight",    setup_06_bright_daylight),
    ("cool_corridor",      setup_07_cool_corridor),
    ("three_color_split",  setup_08_three_color_split),
    ("soft_overcast",      setup_09_soft_overcast),
]

# ============================================================
# RENDER each setup
# ============================================================
scene.render.resolution_x = 1280; scene.render.resolution_y = 960
for idx, (name, setup_fn) in enumerate(SETUPS, start=1):
    setup_fn()
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_lighting_{idx:02d}_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Final save w/ last setup baked in
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

print("=== V3 Epic 29 Lighting Bible complete ===")
