"""
Expansion V3 — Epic 22 — New Bosses Texture Pass
================================================
5 brand-new boss models built to trailer-grade hero quality.

  1. MEMORY WARDEN     — robed librarian with leather tome bindings,
                          floating books, runic chains, golden eye visor.
  2. ROOT HEART        — twisted heart-shaped forest tree with bark
                          displacement, glowing root tendrils, canopy crown.
  3. SENTINEL PRIME    — industrial mech sentinel w/ paint chip wear,
                          rocket pods, glowing cyclops eye, 2 arm cannons.
  4. ITERATION PHANTOM — ghostly humanoid w/ fresnel-driven transparency,
                          floating clock fragments, robe streamers.
  5. COMPILER REBORN   — multi-form crystal entity, 5 floating crystal
                          phase shards, central void core, prism flares.

Outputs:
  - 1 group hero @ 1920x1080
  - 5 portrait close-ups @ 1280x1280
  - 5 GLB exports
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(22)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/v3_new_bosses.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/exports"
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 64
scene.cycles.use_denoising = True
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.view_settings.look = 'AgX - High Contrast'

scene.world = bpy.data.worlds.new("v3_nb_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.03, 0.03, 0.05, 1)
bg.inputs["Strength"].default_value = 0.5

# ============================================================
# SHADER HELPER (V3 5-layer)
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
    if voronoi_strength > 0:
        v = nodes.new("ShaderNodeTexVoronoi"); v.location=(-700,-100)
        v.feature='F1'; v.inputs["Scale"].default_value = voronoi_scale
        links.new(mp.outputs["Vector"], v.inputs["Vector"])
        vr = nodes.new("ShaderNodeValToRGB"); vr.location=(-450,-100)
        vr.color_ramp.elements[0].position = 0.05
        vr.color_ramp.elements[0].color = (base_color[0]*0.55, base_color[1]*0.55, base_color[2]*0.55, 1)
        vr.color_ramp.elements[1].position = 0.30
        vr.color_ramp.elements[1].color = (1,1,1,1)
        links.new(v.outputs["Distance"], vr.inputs["Fac"])
        mv = nodes.new("ShaderNodeMix"); mv.data_type='RGBA'; mv.location=(50,50)
        mv.inputs["Factor"].default_value = voronoi_strength
        links.new(base_out, mv.inputs[6])
        links.new(vr.outputs["Color"], mv.inputs[7])
        base_out = mv.outputs[2]
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

def make_phantom_shader():
    """Iteration Phantom: fresnel-driven transparency w/ ghost glow."""
    m = bpy.data.materials.new("v3nb_phantom")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1200, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (900, 0)
    bsdf.inputs["Base Color"].default_value = (0.30, 0.55, 0.95, 1)
    bsdf.inputs["Roughness"].default_value = 0.10
    bsdf.inputs["Transmission Weight"].default_value = 0.85
    bsdf.inputs["IOR"].default_value = 1.05
    bsdf.inputs["Emission Color"].default_value = (0.45, 0.75, 1.0, 1)
    bsdf.inputs["Emission Strength"].default_value = 3.5
    links.new(bsdf.outputs[0], out.inputs[0])

    # Fresnel-driven alpha
    fr = nodes.new("ShaderNodeFresnel"); fr.location = (-400, 0)
    fr.inputs["IOR"].default_value = 1.4
    invert = nodes.new("ShaderNodeMath"); invert.location = (-200, 0)
    invert.operation = 'SUBTRACT'
    invert.inputs[0].default_value = 1.0
    links.new(fr.outputs["Fac"], invert.inputs[1])
    # boost the rim emission
    em_mix = nodes.new("ShaderNodeMix"); em_mix.data_type='RGBA'; em_mix.location = (200, 0)
    em_mix.inputs[6].default_value = (0.20, 0.40, 0.85, 1)
    em_mix.inputs[7].default_value = (0.95, 0.98, 1.0, 1)
    links.new(fr.outputs["Fac"], em_mix.inputs["Factor"])
    links.new(em_mix.outputs[2], bsdf.inputs["Emission Color"])
    return m

def make_crystal_shader(color):
    m = bpy.data.materials.new(f"v3nb_crystal_{color[0]:.2f}")
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (*color, 1)
    bs.inputs["Roughness"].default_value = 0.05
    bs.inputs["Transmission Weight"].default_value = 0.4
    bs.inputs["IOR"].default_value = 1.5
    bs.inputs["Emission Color"].default_value = (*color, 1)
    bs.inputs["Emission Strength"].default_value = 8.0
    return m

def make_emit(name, color, strength):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (*color, 1)
    bs.inputs["Roughness"].default_value = 0.05
    bs.inputs["Emission Color"].default_value = (*color, 1)
    bs.inputs["Emission Strength"].default_value = strength
    return m

# ============================================================
# MATERIALS
# ============================================================
mats = {}
# Memory Warden
mats["robe_red"]    = make_pbr("v3nb_robe", (0.55, 0.10, 0.10), 0.85,
    noise_strength=0.30, voronoi_strength=0.30, voronoi_scale=40.0, bump_strength=0.20, bump_scale=50.0)
mats["leather_book"] = make_pbr("v3nb_leather", (0.30, 0.12, 0.05), 0.55,
    noise_strength=0.25, voronoi_strength=0.20, voronoi_scale=80.0, bump_strength=0.20, bump_scale=80.0)
mats["paper"]       = make_pbr("v3nb_paper", (0.92, 0.86, 0.72), 0.85,
    emission_color=(1.0, 0.85, 0.45), emission_strength=0.4,
    noise_strength=0.15, curvature_dirt=True, bump_strength=0.10, bump_scale=80.0)
mats["chain"]       = make_pbr("v3nb_chain", (0.10, 0.10, 0.12), 0.55, 0.85,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.20, bump_scale=40.0)
mats["gold_visor"]  = make_pbr("v3nb_gold", (0.95, 0.78, 0.20), 0.10, 1.0,
    emission_color=(1.0, 0.85, 0.40), emission_strength=4.0,
    noise_strength=0.05, curvature_dirt=True, fresnel_rim=True)
# Root Heart
mats["bark_twisted"] = make_pbr("v3nb_bark", (0.15, 0.08, 0.04), 0.95,
    emission_color=(0.85, 0.30, 0.20), emission_strength=0.5,
    noise_strength=0.40, voronoi_strength=0.65, voronoi_scale=10.0,
    fresnel_rim=True, bump_strength=0.55, bump_scale=12.0)
mats["root_glow"]    = make_pbr("v3nb_root_glow", (0.85, 0.30, 0.10), 0.30, 0.0,
    emission_color=(1.0, 0.45, 0.15), emission_strength=10.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["canopy_dark"]  = make_pbr("v3nb_canopy", (0.10, 0.20, 0.06), 0.85,
    emission_color=(0.55, 0.85, 0.30), emission_strength=0.6,
    noise_strength=0.40, curvature_dirt=True, fresnel_rim=True, bump_strength=0.30, bump_scale=45.0)
# Sentinel Prime
mats["mech_paint"]   = make_pbr("v3nb_mech", (0.55, 0.45, 0.20), 0.55, 0.40,
    noise_strength=0.30, voronoi_strength=0.40, voronoi_scale=30.0,
    curvature_dirt=True, fresnel_rim=False, bump_strength=0.25, bump_scale=22.0)
mats["mech_metal"]   = make_pbr("v3nb_mech_metal", (0.18, 0.18, 0.20), 0.40, 0.85,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.10, bump_scale=22.0)
mats["mech_warning"] = make_pbr("v3nb_mech_warn", (1.0, 0.55, 0.10), 0.30, 0.10,
    emission_color=(1.0, 0.55, 0.10), emission_strength=2.5,
    noise_strength=0.15, curvature_dirt=True, fresnel_rim=True, bump_strength=0.20, bump_scale=22.0)
# Phantom
mats["phantom"]      = make_phantom_shader()
mats["clock_brass"]  = make_pbr("v3nb_clock", (0.85, 0.65, 0.20), 0.20, 0.92,
    emission_color=(1.0, 0.85, 0.40), emission_strength=2.0,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True)
# Compiler Reborn
mats["crystal_cyan"]    = make_crystal_shader((0.30, 0.85, 1.0))
mats["crystal_magenta"] = make_crystal_shader((1.0, 0.30, 0.85))
mats["crystal_amber"]   = make_crystal_shader((1.0, 0.65, 0.20))
mats["void_core"]       = make_pbr("v3nb_void", (0.02, 0.02, 0.04), 0.20, 0.30,
    emission_color=(0.55, 0.20, 0.95), emission_strength=2.0,
    noise_strength=0.15, curvature_dirt=True, fresnel_rim=True)

# Eyes
mats["eye_red"]    = make_emit("v3nb_eye_r", (1.0, 0.20, 0.10), 16.0)
mats["eye_white"]  = make_emit("v3nb_eye_w", (0.95, 0.95, 1.0), 14.0)
mats["eye_cyan"]   = make_emit("v3nb_eye_c", (0.30, 0.85, 1.0), 14.0)

# Floor
mats["floor"] = make_pbr("v3nb_floor", (0.06, 0.06, 0.08), 0.30, 0.10,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.05)

# ============================================================
# UTIL
# ============================================================
def add_subsurf_bevel(obj, levels=2, bevel=0.025):
    s = obj.modifiers.new("Subsurf", 'SUBSURF'); s.levels = levels; s.render_levels = levels+1
    b = obj.modifiers.new("Bevel", 'BEVEL'); b.width = bevel; b.segments = 3; b.profile = 0.7
    for poly in obj.data.polygons: poly.use_smooth = True

def sph(name, loc, r, mat, parent, segs=20):
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

def tor(name, loc, R, r, mat, parent, ms=20, mn=10, rot=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_segments=ms, minor_segments=mn, major_radius=R, minor_radius=r, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.005)
    o.parent = parent
    return o

# ============================================================
# 1. MEMORY WARDEN
# ============================================================
def build_memory_warden(origin):
    p = bpy.data.objects.new("v3_memory_warden", None); scene.collection.objects.link(p); p.location = origin
    # Robed body — wide cone for robe drape
    cone("mw_robe", (0, 0, 1.0), 0.85, 0.45, 2.0, mats["robe_red"], p, verts=24)
    # Hood (sphere with front cut implied via separate inset)
    head = sph("mw_hood", (0, 0, 2.10), 0.40, mats["robe_red"], p, segs=20)
    head.scale = (1.0, 1.0, 1.1)
    # Inner head sphere (darker, recessed)
    sph("mw_face", (0, 0.05, 2.05), 0.28, mats["leather_book"], p, segs=18)
    # Golden eye visor (horizontal bar)
    box("mw_visor", (0, 0.30, 2.10), (0.45, 0.05, 0.10), mats["gold_visor"], p)
    # 2 thin glow eye dots inside visor
    sph("mw_eye_l", (-0.10, 0.34, 2.10), 0.025, mats["eye_red"], p, segs=10)
    sph("mw_eye_r", (0.10, 0.34, 2.10), 0.025, mats["eye_red"], p, segs=10)
    # Floating tomes around the warden (4 books at hip height)
    for i in range(4):
        ang = i * (math.pi*2/4) + 0.4
        bx = math.cos(ang) * 1.1
        by = math.sin(ang) * 1.1
        bz = 0.95 + math.sin(i*1.5) * 0.20
        # Book body
        bk = box(f"mw_book_{i}", (bx, by, bz), (0.18, 0.26, 0.06), mats["leather_book"], p,
                  rot=(0, 0, ang + math.pi/2))
        # Book pages (slightly smaller)
        pgs = box(f"mw_pages_{i}", (bx, by, bz + 0.01), (0.16, 0.24, 0.04), mats["paper"], p,
                   rot=(0, 0, ang + math.pi/2))
        # Glowing rune on cover
        sph(f"mw_book_glow_{i}", (bx, by, bz + 0.04), 0.025, mats["gold_visor"], p, segs=10)
    # Runic chains (3 torus loops connecting hood to floating books)
    for i in range(3):
        z = 1.50 + i * 0.20
        tor(f"mw_chain_{i}", (0, 0, z), 0.55 + i*0.05, 0.025, mats["chain"], p, ms=24, mn=8)
    # Sleeve cuffs (2 wider sleeves around upper body)
    cyl("mw_arm_l", (-0.50, 0, 1.10), 0.18, 0.6, mats["robe_red"], p, verts=14, rot=(0, 0.2, 0))
    cyl("mw_arm_r", (0.50, 0, 1.10), 0.18, 0.6, mats["robe_red"], p, verts=14, rot=(0, -0.2, 0))
    # Hands (golden gloves)
    sph("mw_hand_l", (-0.65, 0, 0.78), 0.10, mats["gold_visor"], p, segs=14)
    sph("mw_hand_r", (0.65, 0, 0.78), 0.10, mats["gold_visor"], p, segs=14)
    # Floating central tome held in front of warden
    box("mw_tome_b", (0, 0.55, 1.20), (0.40, 0.30, 0.10), mats["leather_book"], p)
    box("mw_tome_p", (0, 0.55, 1.27), (0.36, 0.28, 0.04), mats["paper"], p)
    sph("mw_tome_g", (0, 0.55, 1.31), 0.05, mats["gold_visor"], p, segs=10)
    return p

# ============================================================
# 2. ROOT HEART
# ============================================================
def build_root_heart(origin):
    p = bpy.data.objects.new("v3_root_heart", None); scene.collection.objects.link(p); p.location = origin
    # Trunk base (twisted thick column)
    cyl("rh_trunk", (0, 0, 1.0), 0.50, 2.0, mats["bark_twisted"], p, verts=14)
    # 3 thick lower roots spreading outward
    for i in range(5):
        ang = i * (math.pi*2/5)
        rx = math.cos(ang) * 0.4
        ry = math.sin(ang) * 0.4
        cyl(f"rh_root_{i}", (rx, ry, 0.20), 0.18, 0.8, mats["bark_twisted"], p, verts=10,
             rot=(math.radians(60), 0, ang))
    # 5 root tendrils with glow snaking up the trunk
    for i in range(5):
        ang = i * (math.pi*2/5) + 0.3
        for j in range(4):
            tx = math.cos(ang) * (0.55 + j*0.04)
            ty = math.sin(ang) * (0.55 + j*0.04)
            tz = 0.40 + j * 0.40
            cyl(f"rh_tendril_{i}_{j}", (tx, ty, tz), 0.04, 0.35, mats["root_glow"], p, verts=6,
                 rot=(0, math.pi/2 + math.sin(j)*0.2, ang))
    # Heart cavity at the top (twin hemispheres with seam)
    head_l = sph("rh_heart_l", (-0.20, 0, 2.40), 0.45, mats["bark_twisted"], p, segs=22)
    head_l.scale = (1.0, 1.0, 1.2)
    head_r = sph("rh_heart_r", (0.20, 0, 2.40), 0.45, mats["bark_twisted"], p, segs=22)
    head_r.scale = (1.0, 1.0, 1.2)
    # Glowing core in heart
    sph("rh_core", (0, 0, 2.40), 0.25, mats["root_glow"], p, segs=18)
    # Heart spike crown (5 pointed branches above)
    for i in range(5):
        ang = i * (math.pi*2/5)
        sx = math.cos(ang) * 0.25
        sy = math.sin(ang) * 0.25
        cone(f"rh_spike_{i}", (sx, sy, 3.20), 0.10, 0.0, 0.80, mats["bark_twisted"], p, verts=8,
             rot=(0, math.cos(ang)*0.3, ang))
    # Canopy clumps surrounding the heart (5 dark clumps)
    for i in range(5):
        ang = i * (math.pi*2/5) + 0.3
        cx = math.cos(ang) * 0.85
        cy = math.sin(ang) * 0.85
        cz = 2.50 + math.sin(i)*0.20
        sph(f"rh_canopy_{i}", (cx, cy, cz), 0.35, mats["canopy_dark"], p, segs=18)
    # 8 floating ember motes around heart
    for i in range(8):
        ang = i * (math.pi*2/8)
        ex = math.cos(ang) * 1.2
        ey = math.sin(ang) * 1.2
        ez = 2.40 + math.sin(i*1.5) * 0.30
        sph(f"rh_ember_{i}", (ex, ey, ez), 0.05, mats["root_glow"], p, segs=10)
    return p

# ============================================================
# 3. SENTINEL PRIME
# ============================================================
def build_sentinel_prime(origin):
    p = bpy.data.objects.new("v3_sentinel_prime", None); scene.collection.objects.link(p); p.location = origin
    # Massive chassis torso
    box("sp_torso", (0, 0, 1.30), (1.3, 0.9, 1.4), mats["mech_paint"], p)
    # Shoulder pads (2 large angled boxes)
    box("sp_sh_l", (-0.85, 0, 1.85), (0.45, 0.7, 0.50), mats["mech_paint"], p, rot=(0, -0.3, 0))
    box("sp_sh_r", (0.85, 0, 1.85), (0.45, 0.7, 0.50), mats["mech_paint"], p, rot=(0, 0.3, 0))
    # Helmet (sphere + visor)
    head = sph("sp_head", (0, 0, 2.20), 0.40, mats["mech_paint"], p, segs=18)
    head.scale = (1.0, 0.95, 1.0)
    # Cyclops eye scanner (cyan emissive cylinder)
    cyl("sp_eye_ring", (0, 0.30, 2.20), 0.18, 0.06, mats["mech_metal"], p, verts=20, rot=(math.pi/2, 0, 0))
    sph("sp_eye", (0, 0.34, 2.20), 0.14, mats["eye_cyan"], p, segs=14)
    # Helmet crest (sweeping upward)
    box("sp_crest", (0, -0.10, 2.55), (0.10, 0.15, 0.30), mats["mech_warning"], p)
    # 2 arm cannons (cylindrical with glow tip)
    cyl("sp_arm_l", (-1.05, 0, 1.30), 0.20, 0.80, mats["mech_metal"], p, verts=14)
    cyl("sp_cannon_l", (-1.05, 0, 0.70), 0.16, 0.50, mats["mech_metal"], p, verts=14)
    cyl("sp_cannon_l_in", (-1.05, 0, 0.50), 0.10, 0.20, mats["eye_cyan"], p, verts=12)
    cyl("sp_arm_r", (1.05, 0, 1.30), 0.20, 0.80, mats["mech_metal"], p, verts=14)
    cyl("sp_cannon_r", (1.05, 0, 0.70), 0.16, 0.50, mats["mech_metal"], p, verts=14)
    cyl("sp_cannon_r_in", (1.05, 0, 0.50), 0.10, 0.20, mats["eye_cyan"], p, verts=12)
    # Rocket pod on each shoulder (4 small tubes per pod)
    for side in [-1, 1]:
        for i in range(4):
            x = side * 0.85 + (i % 2) * 0.10 * side
            y = -0.30 + (i // 2) * 0.20
            cyl(f"sp_rkt_{side}_{i}", (x, y, 2.30), 0.05, 0.20, mats["mech_metal"], p, verts=8)
            sph(f"sp_rkt_g_{side}_{i}", (x, y, 2.42), 0.025, mats["eye_red"], p, segs=8)
    # Warning chevrons (3 stripes on torso)
    for i in range(3):
        z = 0.85 + i * 0.30
        box(f"sp_chev_{i}", (0, 0.46, z), (0.30, 0.04, 0.04), mats["mech_warning"], p)
    # Legs (chunky armored)
    cyl("sp_leg_l", (-0.40, 0, 0.40), 0.22, 0.80, mats["mech_paint"], p, verts=14)
    cyl("sp_leg_r", (0.40, 0, 0.40), 0.22, 0.80, mats["mech_paint"], p, verts=14)
    # Feet
    box("sp_ft_l", (-0.40, 0.10, 0.05), (0.40, 0.50, 0.10), mats["mech_metal"], p)
    box("sp_ft_r", (0.40, 0.10, 0.05), (0.40, 0.50, 0.10), mats["mech_metal"], p)
    # Back pack (jet thrusters)
    box("sp_pack", (0, -0.55, 1.50), (0.80, 0.20, 0.80), mats["mech_metal"], p)
    cyl("sp_jet_l", (-0.30, -0.65, 1.10), 0.10, 0.20, mats["mech_metal"], p, verts=12)
    cyl("sp_jet_r", (0.30, -0.65, 1.10), 0.10, 0.20, mats["mech_metal"], p, verts=12)
    sph("sp_jet_g_l", (-0.30, -0.78, 1.10), 0.07, mats["eye_cyan"], p, segs=10)
    sph("sp_jet_g_r", (0.30, -0.78, 1.10), 0.07, mats["eye_cyan"], p, segs=10)
    return p

# ============================================================
# 4. ITERATION PHANTOM
# ============================================================
def build_iteration_phantom(origin):
    p = bpy.data.objects.new("v3_iteration_phantom", None); scene.collection.objects.link(p); p.location = origin
    # Tall body — humanoid silhouette w/ phantom shader
    body = sph("ip_body", (0, 0, 1.10), 0.45, mats["phantom"], p, segs=24)
    body.scale = (1.0, 0.85, 1.4)
    # Head sphere
    head = sph("ip_head", (0, 0, 1.85), 0.30, mats["phantom"], p, segs=20)
    head.scale = (1.0, 1.0, 1.1)
    # 2 hollow eye sockets
    sph("ip_eye_l", (-0.10, 0.20, 1.90), 0.06, mats["eye_white"], p, segs=12)
    sph("ip_eye_r", (0.10, 0.20, 1.90), 0.06, mats["eye_white"], p, segs=12)
    # Robe streamers — long tapered cones from waist downward (5)
    for i in range(5):
        ang = i * (math.pi*2/5) + 0.3
        sx = math.cos(ang) * 0.30
        sy = math.sin(ang) * 0.30
        cone(f"ip_stream_{i}", (sx, sy, 0.40), 0.20, 0.05, 0.90, mats["phantom"], p, verts=10,
             rot=(math.cos(ang)*0.3, math.sin(ang)*0.3, ang))
    # Floating clock fragments around body (6 brass shards)
    for i in range(6):
        ang = i * (math.pi*2/6)
        cx = math.cos(ang) * 1.00
        cy = math.sin(ang) * 1.00
        cz = 1.10 + math.sin(i*1.2) * 0.40
        # Clock face disc
        cyl(f"ip_clock_{i}", (cx, cy, cz), 0.18, 0.04, mats["clock_brass"], p, verts=20,
             rot=(math.pi/2 + math.cos(ang)*0.4, 0, ang))
        # Hand pointer (small bar)
        box(f"ip_hand_{i}", (cx, cy, cz + 0.03), (0.02, 0.10, 0.005), mats["clock_brass"], p,
             rot=(math.pi/2 + math.cos(ang)*0.4, 0, ang + i*0.5))
    # Arm-like wisps (2 wispy curving cylinders extending out)
    for side in [-1, 1]:
        for j in range(3):
            x = side * (0.40 + j*0.20)
            z = 1.05 + math.sin(j*0.6) * 0.10
            sph(f"ip_arm_{side}_{j}", (x, -0.10, z), 0.10 - j*0.025, mats["phantom"], p, segs=12)
    # 8 floating hourglass particles
    for i in range(8):
        ang = i * (math.pi*2/8)
        ex = math.cos(ang) * 1.40
        ey = math.sin(ang) * 1.40
        ez = 1.5 + math.sin(i)*0.30
        sph(f"ip_part_{i}", (ex, ey, ez), 0.04, mats["clock_brass"], p, segs=10)
    return p

# ============================================================
# 5. COMPILER REBORN
# ============================================================
def build_compiler_reborn(origin):
    p = bpy.data.objects.new("v3_compiler_reborn", None); scene.collection.objects.link(p); p.location = origin
    # Central void core
    sph("cr_void", (0, 0, 1.20), 0.50, mats["void_core"], p, segs=24)
    sph("cr_void_inner", (0, 0, 1.20), 0.20, mats["crystal_magenta"], p, segs=18)
    # 5 floating phase shards orbiting at different heights
    SHARDS = [
        (0.0, 1.20, mats["crystal_cyan"]),
        (math.pi*2/5, 1.50, mats["crystal_amber"]),
        (math.pi*4/5, 1.10, mats["crystal_magenta"]),
        (math.pi*6/5, 1.40, mats["crystal_cyan"]),
        (math.pi*8/5, 1.00, mats["crystal_amber"]),
    ]
    for i, (ang, sz, mat) in enumerate(SHARDS):
        r = 1.10
        x = math.cos(ang) * r
        y = math.sin(ang) * r
        cone(f"cr_shard_{i}", (x, y, sz), 0.20, 0.05, 0.80, mat, p, verts=8,
              rot=(ang, ang*0.5, ang*0.3))
        # Glow ring around each shard
        tor(f"cr_shard_r_{i}", (x, y, sz), 0.30, 0.025, mat, p, ms=24, mn=8,
             rot=(ang*0.5, ang, 0))
    # Top crown of 6 floating crystal spires
    for i in range(6):
        ang = i * (math.pi*2/6)
        x = math.cos(ang) * 0.40
        y = math.sin(ang) * 0.40
        cone(f"cr_crown_{i}", (x, y, 1.95), 0.08, 0.0, 0.30, mats["crystal_cyan"], p, verts=6)
    # Bottom anchor pyramid (4 cones forming base)
    for i in range(4):
        ang = i * math.pi/2
        x = math.cos(ang) * 0.35
        y = math.sin(ang) * 0.35
        cone(f"cr_base_{i}", (x, y, 0.40), 0.15, 0.0, 0.50, mats["void_core"], p, verts=6,
              rot=(0, math.pi, ang))
    # 3 perpendicular halo aura rings
    tor("cr_halo_h", (0, 0, 1.20), 1.6, 0.06, mats["crystal_cyan"], p, ms=64, mn=12)
    tor("cr_halo_v1", (0, 0, 1.20), 1.6, 0.05, mats["crystal_magenta"], p, ms=48, mn=10, rot=(math.pi/2, 0, 0))
    tor("cr_halo_v2", (0, 0, 1.20), 1.6, 0.05, mats["crystal_amber"], p, ms=48, mn=10, rot=(0, math.pi/2, 0))
    # 12 prism flares
    for i in range(12):
        ang = i * (math.pi*2/12)
        r = 0.85
        x = math.cos(ang) * r
        y = math.sin(ang) * r
        z = 1.20
        color = [mats["crystal_cyan"], mats["crystal_magenta"], mats["crystal_amber"]][i % 3]
        sph(f"cr_flare_{i}", (x, y, z), 0.05, color, p, segs=10)
    return p

# ============================================================
# LAYOUT
# ============================================================
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, -0.05))
fl = bpy.context.object; fl.name = "nb_floor"; fl.scale = (16, 6, 0.10)
fl.data.materials.append(mats["floor"]); add_subsurf_bevel(fl, levels=1, bevel=0.005)

BOSSES = [
    ("memory_warden",      build_memory_warden,      Vector((-6, 0, 0))),
    ("root_heart",         build_root_heart,         Vector((-3, 0, 0))),
    ("sentinel_prime",     build_sentinel_prime,     Vector((0, 0, 0))),
    ("iteration_phantom",  build_iteration_phantom,  Vector((3, 0, 0))),
    ("compiler_reborn",    build_compiler_reborn,    Vector((6, 0, 0))),
]

BOSS_OBJS = []
for name, builder, origin in BOSSES:
    obj = builder(origin)
    BOSS_OBJS.append((name, obj, origin))

# ============================================================
# LIGHTING
# ============================================================
bpy.ops.object.light_add(type='AREA', location=(8, -10, 12))
key = bpy.context.object
key.data.energy = 1800; key.data.color = (1.0, 0.92, 0.78); key.data.size = 10

bpy.ops.object.light_add(type='AREA', location=(-8, 8, 10))
fill = bpy.context.object
fill.data.energy = 700; fill.data.color = (0.55, 0.65, 0.95); fill.data.size = 10

bpy.ops.object.light_add(type='AREA', location=(0, 8, 4))
rim = bpy.context.object
rim.data.energy = 500; rim.data.color = (1.0, 0.75, 0.45); rim.data.size = 8

# ============================================================
# CAMERAS
# ============================================================
def add_cam(name, loc, target, lens=50, dof_dist=4):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = 4.5
    c.data.dof.focus_distance = dof_dist
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_group = add_cam("cam_group", Vector((0, -10, 6)), Vector((0, 0, 1.4)), lens=32, dof_dist=12)

PORTRAIT_CAMERAS = []
for name, _, origin in BOSSES:
    cam = add_cam(f"cam_{name}", Vector((origin.x, origin.y - 3.5, 2.0)),
                   Vector((origin.x, origin.y, 1.4)), lens=85, dof_dist=4)
    PORTRAIT_CAMERAS.append((name, cam))

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render group
scene.camera = cam_group
scene.render.resolution_x = 1920; scene.render.resolution_y = 1080
scene.render.filepath = os.path.join(RENDER_DIR, "v3_new_bosses_group.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# Render portraits
scene.render.resolution_x = 1280; scene.render.resolution_y = 1280
for name, cam in PORTRAIT_CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_new_boss_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Per-boss GLBs
for name, obj, _ in BOSS_OBJS:
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    for child in obj.children_recursive:
        child.select_set(True)
    out_path = os.path.join(EXPORT_DIR, f"v3_new_boss_{name}_v3.glb")
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=True
    )
    print(f"Exported: {out_path}")

print("=== V3 Epic 22 New Bosses Texture Pass complete ===")
