"""
Expansion V3 — Epic 19 — Base Enemy Texture Pass
================================================
3 base enemies rebuilt to hero quality with custom shaders:

  1. GLITCHBUG — chitinous insect with glitch shell pattern, 6 legs,
                 segmented body, curved mandibles, glitch eye-emission.
  2. MEMORYLEAK — slime liquid creature with translucent SSS body,
                  dripping core, leak tendrils.
  3. ROGUEPROCESS — metal carapace bot with circuit pattern overlay,
                    chassis plates, articulated legs, glow eye scanner.

Each uses a bespoke shader stack:
  - Glitchbug: chitin (curvature shine + voronoi cells + glitch
    color stripes via brick texture)
  - Memoryleak: SSS slime (high subsurface, noise color flow,
    refractive transmission)
  - RogueProcess: brushed metal + emissive circuit pattern overlay
    (musgrave-driven trace lines)

Outputs:
  - 1 group hero shot @ 1920x1080
  - 3 portrait close-ups @ 1280x1280
  - 3 GLB exports
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(19)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/v3_base_enemies.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/exports"
os.makedirs(os.path.dirname(OUTPUT_BLEND), exist_ok=True)
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 96
scene.cycles.use_denoising = True
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.view_settings.look = 'AgX - High Contrast'

scene.world = bpy.data.worlds.new("v3_be_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.04, 0.04, 0.06, 1)
bg.inputs["Strength"].default_value = 0.5

# ============================================================
# CUSTOM SHADERS
# ============================================================
def make_chitin_shader():
    """Glitchbug chitin: voronoi cell pattern + curvature shine +
    glitch color brick stripes."""
    m = bpy.data.materials.new("v3be_chitin")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1300, 0)
    bsdf.inputs["Roughness"].default_value = 0.20
    bsdf.inputs["Metallic"].default_value = 0.30
    bsdf.inputs["Coat Weight"].default_value = 0.6
    bsdf.inputs["Coat Roughness"].default_value = 0.05
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (5, 5, 5)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Voronoi cells (chitin plates)
    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-700, 200)
    v.feature = 'F1'
    v.inputs["Scale"].default_value = 12.0
    links.new(mp.outputs["Vector"], v.inputs["Vector"])
    v_ramp = nodes.new("ShaderNodeValToRGB"); v_ramp.location = (-450, 200)
    v_ramp.color_ramp.elements[0].position = 0.05
    v_ramp.color_ramp.elements[0].color = (0.10, 0.20, 0.08, 1)
    v_ramp.color_ramp.elements[1].position = 0.30
    v_ramp.color_ramp.elements[1].color = (0.30, 0.55, 0.20, 1)
    links.new(v.outputs["Distance"], v_ramp.inputs["Fac"])

    # Glitch stripes via brick (cyan / magenta error bands)
    brick = nodes.new("ShaderNodeTexBrick"); brick.location = (-700, -100)
    brick.inputs["Scale"].default_value = 8.0
    brick.inputs["Color1"].default_value = (0.20, 0.85, 1.0, 1)   # cyan
    brick.inputs["Color2"].default_value = (1.00, 0.20, 0.85, 1)  # magenta
    brick.inputs["Mortar"].default_value = (0, 0, 0, 1)
    brick.inputs["Mortar Size"].default_value = 0.0
    brick.inputs["Bias"].default_value = 0.0
    links.new(mp.outputs["Vector"], brick.inputs["Vector"])

    # Mix mostly chitin, occasional glitch flash
    mix = nodes.new("ShaderNodeMix"); mix.data_type='RGBA'; mix.location = (-200, 100)
    mix.inputs["Factor"].default_value = 0.15
    links.new(v_ramp.outputs["Color"], mix.inputs[6])
    links.new(brick.outputs["Color"], mix.inputs[7])

    # Curvature highlights (brighten ridges)
    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-200, -200)
    cr = nodes.new("ShaderNodeValToRGB"); cr.location = (50, -200)
    cr.color_ramp.elements[0].position = 0.40
    cr.color_ramp.elements[0].color = (0.05, 0.10, 0.04, 1)
    cr.color_ramp.elements[1].position = 0.75
    cr.color_ramp.elements[1].color = (0.65, 0.95, 0.35, 1)
    links.new(geo.outputs["Pointiness"], cr.inputs["Fac"])
    md = nodes.new("ShaderNodeMix"); md.data_type='RGBA'; md.location = (300, 0)
    md.inputs["Factor"].default_value = 0.45
    links.new(mix.outputs[2], md.inputs[6])
    links.new(cr.outputs["Color"], md.inputs[7])
    links.new(md.outputs[2], bsdf.inputs["Base Color"])

    # Bump from voronoi cells
    bp = nodes.new("ShaderNodeBump"); bp.location = (550, -300)
    bp.inputs["Strength"].default_value = 0.40
    links.new(v.outputs["Distance"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_slime_shader(color):
    """Memoryleak slime: high SSS + transmission + flowing noise color."""
    m = bpy.data.materials.new("v3be_slime")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Roughness"].default_value = 0.15
    bsdf.inputs["Metallic"].default_value = 0.0
    bsdf.inputs["Transmission Weight"].default_value = 0.40
    bsdf.inputs["IOR"].default_value = 1.4
    bsdf.inputs["Subsurface Weight"].default_value = 0.7
    bsdf.inputs["Subsurface Radius"].default_value = (1.5, 0.6, 0.4)
    bsdf.inputs["Subsurface Scale"].default_value = 0.5
    bsdf.inputs["Coat Weight"].default_value = 0.8
    bsdf.inputs["Coat Roughness"].default_value = 0.05
    bsdf.inputs["Emission Color"].default_value = (color[0]*1.2, color[1]*1.3, color[2]*1.2, 1)
    bsdf.inputs["Emission Strength"].default_value = 1.0
    links.new(bsdf.outputs[0], out.inputs[0])

    # Flowing internal noise color
    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1000, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-800, 0)
    mp.inputs["Scale"].default_value = (3, 3, 3)
    links.new(tc.outputs["Object"], mp.inputs["Vector"])
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-550, 0)
    n.inputs["Scale"].default_value = 4.0
    n.inputs["Detail"].default_value = 8.0
    n.inputs["Roughness"].default_value = 0.7
    links.new(mp.outputs["Vector"], n.inputs["Vector"])
    ramp = nodes.new("ShaderNodeValToRGB"); ramp.location = (-300, 0)
    ramp.color_ramp.elements[0].position = 0.25
    ramp.color_ramp.elements[0].color = (color[0]*0.4, color[1]*0.6, color[2]*0.5, 1)
    ramp.color_ramp.elements[1].position = 0.75
    ramp.color_ramp.elements[1].color = (color[0]*1.4, color[1]*1.5, color[2]*1.3, 1)
    links.new(n.outputs["Fac"], ramp.inputs["Fac"])
    links.new(ramp.outputs["Color"], bsdf.inputs["Base Color"])

    # Surface normal subtle bump
    bp = nodes.new("ShaderNodeBump"); bp.location = (-100, -300)
    bp.inputs["Strength"].default_value = 0.10
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_metal_circuit_shader():
    """RogueProcess: brushed metal + emissive circuit pattern overlay."""
    m = bpy.data.materials.new("v3be_metal_circuit")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1300, 0)
    bsdf.inputs["Roughness"].default_value = 0.25
    bsdf.inputs["Metallic"].default_value = 0.92
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (4, 4, 4)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Brushed metal noise
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
    n.inputs["Scale"].default_value = 12.0
    n.inputs["Detail"].default_value = 4.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])
    metal_ramp = nodes.new("ShaderNodeValToRGB"); metal_ramp.location = (-450, 200)
    metal_ramp.color_ramp.elements[0].position = 0.35
    metal_ramp.color_ramp.elements[0].color = (0.20, 0.22, 0.26, 1)
    metal_ramp.color_ramp.elements[1].position = 0.70
    metal_ramp.color_ramp.elements[1].color = (0.40, 0.42, 0.48, 1)
    links.new(n.outputs["Fac"], metal_ramp.inputs["Fac"])

    # Circuit pattern via musgrave (lines + nodes)
    mus = nodes.new("ShaderNodeTexNoise"); mus.location = (-700, -100)
    mus.inputs["Scale"].default_value = 30.0
    mus.inputs["Detail"].default_value = 1.0
    mus.inputs["Roughness"].default_value = 0.0
    links.new(mp.outputs["Vector"], mus.inputs["Vector"])
    # threshold to create thin trace lines
    thresh = nodes.new("ShaderNodeValToRGB"); thresh.location = (-450, -100)
    thresh.color_ramp.interpolation = 'CONSTANT'
    thresh.color_ramp.elements[0].position = 0.45
    thresh.color_ramp.elements[0].color = (0, 0, 0, 1)
    thresh.color_ramp.elements[1].position = 0.50
    thresh.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(mus.outputs["Fac"], thresh.inputs["Fac"])

    # Mix metal with circuit color
    mix = nodes.new("ShaderNodeMix"); mix.data_type='RGBA'; mix.location = (-200, 50)
    links.new(thresh.outputs["Color"], mix.inputs["Factor"])
    links.new(metal_ramp.outputs["Color"], mix.inputs[6])
    mix.inputs[7].default_value = (0.10, 0.85, 1.0, 1)  # cyan circuit traces
    links.new(mix.outputs[2], bsdf.inputs["Base Color"])

    # Emission for traces (drives glow)
    glow = nodes.new("ShaderNodeMix"); glow.data_type='RGBA'; glow.location = (100, -150)
    links.new(thresh.outputs["Color"], glow.inputs["Factor"])
    glow.inputs[6].default_value = (0, 0, 0, 1)
    glow.inputs[7].default_value = (0.30, 0.85, 1.0, 1)
    links.new(glow.outputs[2], bsdf.inputs["Emission Color"])
    bsdf.inputs["Emission Strength"].default_value = 6.0

    # Metal bump
    bp = nodes.new("ShaderNodeBump"); bp.location = (300, -350)
    bp.inputs["Strength"].default_value = 0.15
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

# ============================================================
# SUPPORT MATERIALS
# ============================================================
def make_simple_emission(name, color, strength):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (*color, 1)
    bs.inputs["Roughness"].default_value = 0.05
    bs.inputs["Emission Color"].default_value = (*color, 1)
    bs.inputs["Emission Strength"].default_value = strength
    return m

mat_chitin       = make_chitin_shader()
mat_chitin_dark  = make_chitin_shader()  # second instance for body underbelly
mat_chitin_dark.name = "v3be_chitin_dark"
mat_slime_green  = make_slime_shader((0.20, 0.65, 0.30))
mat_slime_core   = make_slime_shader((0.45, 0.95, 0.35))
mat_metal       = make_metal_circuit_shader()
mat_eye_red      = make_simple_emission("v3be_eye_red", (1.0, 0.20, 0.10), 18.0)
mat_eye_cyan     = make_simple_emission("v3be_eye_cyan", (0.30, 0.85, 1.0), 16.0)
mat_eye_glitch_a = make_simple_emission("v3be_eye_glitch_a", (0.30, 1.0, 0.95), 14.0)
mat_eye_glitch_b = make_simple_emission("v3be_eye_glitch_b", (1.0, 0.20, 0.85), 14.0)
mat_drip         = make_simple_emission("v3be_drip", (0.45, 0.95, 0.35), 8.0)
mat_floor        = bpy.data.materials.new("v3be_floor")
mat_floor.use_nodes = True
fb = mat_floor.node_tree.nodes["Principled BSDF"]
fb.inputs["Base Color"].default_value = (0.10, 0.10, 0.12, 1)
fb.inputs["Roughness"].default_value = 0.4
fb.inputs["Metallic"].default_value = 0.10

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

def cyl(name, loc, r, depth, mat, parent, verts=14, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=r, depth=depth, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    return o

def cone(name, loc, r1, r2, depth, mat, parent, verts=12, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
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

# ============================================================
# GLITCHBUG
# ============================================================
def build_glitchbug(origin):
    parent = bpy.data.objects.new("v3_glitchbug", None); scene.collection.objects.link(parent)
    parent.location = origin
    # Body — 3-segment thorax/abdomen/head
    abd = sph("gb_abd", (0, -0.30, 0.45), 0.42, mat_chitin, parent)
    abd.scale = (1.1, 1.4, 0.9)
    thx = sph("gb_thx", (0, 0.20, 0.50), 0.32, mat_chitin, parent)
    thx.scale = (1.1, 1.0, 1.0)
    head = sph("gb_head", (0, 0.55, 0.55), 0.22, mat_chitin, parent)
    head.scale = (1.1, 1.0, 0.9)
    # Glitch eye orbs (one cyan, one magenta — broken visual)
    sph("gb_eye_l", (-0.12, 0.70, 0.62), 0.07, mat_eye_glitch_a, parent, segs=14)
    sph("gb_eye_r", (0.12, 0.70, 0.62), 0.07, mat_eye_glitch_b, parent, segs=14)
    # Mandibles
    cone("gb_mnd_l", (-0.10, 0.78, 0.42), 0.04, 0.0, 0.20, mat_chitin, parent, rot=(0.4, 0.2, 0))
    cone("gb_mnd_r", (0.10, 0.78, 0.42), 0.04, 0.0, 0.20, mat_chitin, parent, rot=(0.4, -0.2, 0))
    # Antennae
    cyl("gb_ant_l", (-0.10, 0.78, 0.80), 0.012, 0.50, mat_chitin, parent, verts=8, rot=(-0.6, -0.3, 0))
    cyl("gb_ant_r", (0.10, 0.78, 0.80), 0.012, 0.50, mat_chitin, parent, verts=8, rot=(-0.6, 0.3, 0))
    sph("gb_ant_t_l", (-0.20, 0.65, 1.10), 0.025, mat_eye_glitch_a, parent, segs=10)
    sph("gb_ant_t_r", (0.20, 0.65, 1.10), 0.025, mat_eye_glitch_b, parent, segs=10)
    # 6 legs
    leg_positions = [(-0.40, 0.10), (0.40, 0.10), (-0.40, -0.20), (0.40, -0.20), (-0.40, -0.50), (0.40, -0.50)]
    for i, (lx, ly) in enumerate(leg_positions):
        # Upper leg
        ul = cyl(f"gb_leg_u_{i}", (lx*1.3, ly, 0.30), 0.025, 0.55, mat_chitin, parent, verts=8,
                  rot=(0, math.radians(60) if lx > 0 else -math.radians(60), 0))
        # Lower leg
        ll = cyl(f"gb_leg_l_{i}", (lx*1.7, ly, 0.10), 0.020, 0.45, mat_chitin, parent, verts=8,
                  rot=(0, math.radians(15) if lx > 0 else -math.radians(15), 0))
        # Tip claw
        cone(f"gb_claw_{i}", (lx*1.85, ly, 0.02), 0.025, 0.0, 0.08, mat_chitin, parent, verts=6, rot=(0, math.pi/2, 0))
    # Wing covers (slight raised)
    wing_l = sph("gb_wing_l", (-0.20, -0.30, 0.75), 0.30, mat_chitin, parent, segs=18)
    wing_l.scale = (0.6, 1.4, 0.15)
    wing_l.rotation_euler.y = -0.2
    wing_r = sph("gb_wing_r", (0.20, -0.30, 0.75), 0.30, mat_chitin, parent, segs=18)
    wing_r.scale = (0.6, 1.4, 0.15)
    wing_r.rotation_euler.y = 0.2
    # 3 dorsal spines on abdomen
    for i, py in enumerate([-0.55, -0.30, -0.05]):
        cone(f"gb_sp_{i}", (0, py, 0.85), 0.05, 0.0, 0.15, mat_chitin, parent, verts=6)
    return parent

# ============================================================
# MEMORYLEAK
# ============================================================
def build_memoryleak(origin):
    parent = bpy.data.objects.new("v3_memoryleak", None); scene.collection.objects.link(parent)
    parent.location = origin
    # Main blob body
    body = sph("ml_body", (0, 0, 0.55), 0.55, mat_slime_green, parent, segs=32)
    body.scale = (1.0, 1.0, 1.2)
    # Inner glowing core (visible through transmission)
    sph("ml_core", (0, 0, 0.55), 0.20, mat_slime_core, parent, segs=20)
    # Drip blobs hanging below
    for i, (dx, dy) in enumerate([(0, 0),(0.20, 0.15),(-0.18, 0.10),(0.10, -0.18),(-0.10, -0.15)]):
        d = sph(f"ml_drip_{i}", (dx, dy, 0.10), 0.06, mat_slime_green, parent, segs=14)
        d.scale = (1.0, 1.0, 1.6)
    # Big bottom puddle
    pud = sph("ml_pud", (0, 0, 0.04), 0.40, mat_slime_green, parent, segs=20)
    pud.scale = (1.4, 1.4, 0.2)
    # Leak tendrils reaching outward
    for i in range(5):
        ang = i * (math.pi*2/5)
        tx = math.cos(ang) * 0.55
        ty = math.sin(ang) * 0.55
        # Tendril segments
        for j in range(3):
            jx = math.cos(ang) * (0.55 + j*0.20)
            jy = math.sin(ang) * (0.55 + j*0.20)
            jz = 0.55 - j*0.15
            sph(f"ml_t_{i}_{j}", (jx, jy, jz), 0.08 - j*0.02, mat_slime_green, parent, segs=12)
    # Eyes (2 floating cores in body)
    sph("ml_eye_l", (-0.18, 0.40, 0.65), 0.08, mat_eye_cyan, parent, segs=12)
    sph("ml_eye_r", (0.18, 0.40, 0.65), 0.08, mat_eye_cyan, parent, segs=12)
    # 4 floating internal bubble particles
    for i, (bx, by, bz) in enumerate([(-0.15, -0.10, 0.40),(0.15, -0.20, 0.50),(0.10, 0.25, 0.30),(-0.20, 0.20, 0.45)]):
        sph(f"ml_bub_{i}", (bx, by, bz), 0.05, mat_drip, parent, segs=10)
    return parent

# ============================================================
# ROGUEPROCESS
# ============================================================
def build_rogueprocess(origin):
    parent = bpy.data.objects.new("v3_rogueprocess", None); scene.collection.objects.link(parent)
    parent.location = origin
    # Main chassis (rectangular body)
    body = box("rp_body", (0, 0, 0.70), (0.80, 0.55, 0.50), mat_metal, parent)
    # Top dome
    dome = sph("rp_dome", (0, 0, 1.00), 0.30, mat_metal, parent, segs=20)
    dome.scale.z = 0.7
    # Side carapace plates (4 angled panels)
    box("rp_pl_l", (-0.45, 0, 0.70), (0.06, 0.5, 0.45), mat_metal, parent, rot=(0, -0.15, 0))
    box("rp_pl_r", (0.45, 0, 0.70), (0.06, 0.5, 0.45), mat_metal, parent, rot=(0, 0.15, 0))
    box("rp_pl_f", (0, 0.30, 0.70), (0.7, 0.06, 0.45), mat_metal, parent, rot=(0.15, 0, 0))
    box("rp_pl_b", (0, -0.30, 0.70), (0.7, 0.06, 0.45), mat_metal, parent, rot=(-0.15, 0, 0))
    # Eye scanner (cyan emissive cyclops eye)
    cyl("rp_eye_ring", (0, 0.30, 1.00), 0.10, 0.04, mat_metal, parent, verts=20, rot=(math.pi/2, 0, 0))
    sph("rp_eye", (0, 0.32, 1.00), 0.08, mat_eye_cyan, parent, segs=14)
    # Head antennae (sensors)
    cyl("rp_ant_l", (-0.10, 0, 1.30), 0.015, 0.30, mat_metal, parent, verts=8)
    cyl("rp_ant_r", (0.10, 0, 1.30), 0.015, 0.30, mat_metal, parent, verts=8)
    sph("rp_ant_l_t", (-0.10, 0, 1.50), 0.03, mat_eye_red, parent, segs=10)
    sph("rp_ant_r_t", (0.10, 0, 1.50), 0.03, mat_eye_red, parent, segs=10)
    # 4 articulated legs
    LEG_POS = [(-0.60, 0.30),(0.60, 0.30),(-0.60, -0.30),(0.60, -0.30)]
    for i, (lx, ly) in enumerate(LEG_POS):
        # Hip joint (sphere)
        sph(f"rp_hip_{i}", (lx, ly, 0.65), 0.10, mat_metal, parent, segs=12)
        # Upper leg (downward angled cylinder)
        ul = cyl(f"rp_ul_{i}", (lx*1.2, ly, 0.40), 0.05, 0.55, mat_metal, parent, verts=10,
                  rot=(0, math.radians(35) if lx > 0 else -math.radians(35), 0))
        # Knee joint
        sph(f"rp_kn_{i}", (lx*1.4, ly, 0.20), 0.07, mat_metal, parent, segs=12)
        # Lower leg (vertical to floor)
        cyl(f"rp_ll_{i}", (lx*1.4, ly, 0.10), 0.045, 0.20, mat_metal, parent, verts=10)
        # Foot
        sph(f"rp_ft_{i}", (lx*1.4, ly, 0.0), 0.06, mat_metal, parent, segs=12)
    # Chassis vent slits (3 horizontal on front face)
    for i in range(3):
        z = 0.55 + i * 0.15
        box(f"rp_vent_{i}", (0, 0.36, z), (0.4, 0.005, 0.04), mat_eye_cyan, parent)
    # Back exhaust pipes
    for i, dx in enumerate([-0.20, 0.20]):
        cyl(f"rp_ex_{i}", (dx, -0.42, 0.85), 0.05, 0.20, mat_metal, parent, verts=10, rot=(math.pi/2, 0, 0))
        sph(f"rp_ex_g_{i}", (dx, -0.55, 0.85), 0.04, mat_eye_cyan, parent, segs=10)
    return parent

# ============================================================
# LAYOUT
# ============================================================
# Floor plinth
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, -0.05))
fl = bpy.context.object; fl.name = "be_floor"; fl.scale = (10, 4, 0.10)
fl.data.materials.append(mat_floor); add_subsurf_bevel(fl, levels=1, bevel=0.005)

build_glitchbug(Vector((-2.5, 0, 0)))
build_memoryleak(Vector((0, 0, 0)))
build_rogueprocess(Vector((2.5, 0, 0)))

# ============================================================
# LIGHTING — 3-point cinematic
# ============================================================
bpy.ops.object.light_add(type='AREA', location=(4, -5, 5))
key = bpy.context.object
key.data.energy = 1500; key.data.color = (1.0, 0.92, 0.78); key.data.size = 6

bpy.ops.object.light_add(type='AREA', location=(-4, 4, 4))
fill = bpy.context.object
fill.data.energy = 500; fill.data.color = (0.55, 0.65, 0.95); fill.data.size = 6

bpy.ops.object.light_add(type='AREA', location=(0, 5, 3))
rim = bpy.context.object
rim.data.energy = 400; rim.data.color = (1.0, 0.75, 0.45); rim.data.size = 5

# ============================================================
# CAMERAS
# ============================================================
def add_cam(name, loc, target, lens=50, dof_dist=4):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = 4.0
    c.data.dof.focus_distance = dof_dist
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_group   = add_cam("cam_group",   Vector((0, -5, 2.0)), Vector((0, 0, 0.6)), lens=40, dof_dist=5)
cam_glitch  = add_cam("cam_glitch",  Vector((-2.5, -2, 1.0)), Vector((-2.5, 0, 0.5)), lens=85, dof_dist=2)
cam_leak    = add_cam("cam_leak",    Vector((0, -2, 1.0)), Vector((0, 0, 0.5)), lens=85, dof_dist=2)
cam_rp      = add_cam("cam_rp",      Vector((2.5, -2, 1.2)), Vector((2.5, 0, 0.7)), lens=85, dof_dist=2)

CAMERAS = [
    ("group",   cam_group,  (1920, 1080)),
    ("glitch",  cam_glitch, (1280, 1280)),
    ("leak",    cam_leak,   (1280, 1280)),
    ("rp",      cam_rp,     (1280, 1280)),
]

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render
for name, cam, (w, h) in CAMERAS:
    scene.camera = cam
    scene.render.resolution_x = w
    scene.render.resolution_y = h
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_enemy_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Per-enemy GLBs
for enemy_name in ["v3_glitchbug", "v3_memoryleak", "v3_rogueprocess"]:
    bpy.ops.object.select_all(action='DESELECT')
    parent = bpy.data.objects.get(enemy_name)
    if parent:
        parent.select_set(True)
        for child in parent.children_recursive:
            child.select_set(True)
        out_path = os.path.join(EXPORT_DIR, f"{enemy_name}_v3.glb")
        bpy.ops.export_scene.gltf(
            filepath=out_path, use_selection=True,
            export_format='GLB', export_apply=True
        )
        print(f"Exported: {out_path}")

print("=== V3 Epic 19 Base Enemy Texture Pass complete ===")
