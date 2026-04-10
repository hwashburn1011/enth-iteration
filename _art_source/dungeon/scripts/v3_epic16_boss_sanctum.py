"""
Expansion V3 — Epic 16 — Boss Sanctum Biome Texture Pass
========================================================
Fourth and final dungeon biome — volcanic obsidian boss arena where
the Corrupted Compiler awaits. Trailer-grade hero scene.

Layout: 16-radius octagonal arena with:
  - Central elevated boss spawn platform (with sigil glow)
  - 8 tall obsidian pillars around the perimeter (arena ring)
  - Octagonal volcanic basalt floor with lava crack grid
  - Outer lava moat (toxic crimson, ring shape) flowing around arena
  - 4 broken chains hanging from above with embedded skull cores
  - Massive obsidian throne at far end with crystal heart
  - 8 lava braziers along inner ring
  - 12 floating ember motes
  - 4 banner cloth drops from chains with ember holes
  - Hard crimson key + cool magenta back-rim + red ground glow
  - NO world volumetrics (per V3-15 lesson — atmosphere via lighting)

Outputs:
  - 1 hero arena render @ 1600x900
  - 1 throne close-up @ 1280x960
  - 1 platform close-up @ 1280x960
  - 1 GLB export
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(16)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/v3_boss_sanctum.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/exports"
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 64
scene.cycles.use_denoising = True
scene.render.resolution_x = 1600
scene.render.resolution_y = 900
scene.view_settings.look = 'AgX - High Contrast'

# Dark crimson world background — NO world volumetrics
scene.world = bpy.data.worlds.new("v3_bs_world")
scene.world.use_nodes = True
wnt = scene.world.node_tree
wnt.nodes.clear()
wout = wnt.nodes.new("ShaderNodeOutputWorld")
wbg = wnt.nodes.new("ShaderNodeBackground")
wbg.inputs["Color"].default_value = (0.06, 0.01, 0.005, 1)
wbg.inputs["Strength"].default_value = 0.5
wnt.links.new(wbg.outputs[0], wout.inputs[0])

# ============================================================
# SHADER HELPERS
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
        r.color_ramp.elements[0].color = (base_color[0]*0.80, base_color[1]*0.80, base_color[2]*0.80, 1)
        r.color_ramp.elements[1].position = 0.70
        r.color_ramp.elements[1].color = (min(base_color[0]*1.20,1), min(base_color[1]*1.20,1), min(base_color[2]*1.20,1), 1)
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
        ar.color_ramp.elements[0].color = (0.05,0.02,0.01,1)
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

def make_basalt_lava():
    """Volcanic basalt floor with lava cracks via voronoi DISTANCE_TO_EDGE."""
    m = bpy.data.materials.new("v3bs_basalt")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.85
    bsdf.inputs["Emission Strength"].default_value = 8.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (3, 3, 3)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Basalt noise base
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
    n.inputs["Scale"].default_value = 8.0
    n.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])
    basalt_ramp = nodes.new("ShaderNodeValToRGB"); basalt_ramp.location = (-450, 200)
    basalt_ramp.color_ramp.elements[0].position = 0.30
    basalt_ramp.color_ramp.elements[0].color = (0.04, 0.03, 0.02, 1)
    basalt_ramp.color_ramp.elements[1].position = 0.70
    basalt_ramp.color_ramp.elements[1].color = (0.12, 0.08, 0.06, 1)
    links.new(n.outputs["Fac"], basalt_ramp.inputs["Fac"])

    # Voronoi crack mask
    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-700, -100)
    v.feature = 'DISTANCE_TO_EDGE'
    v.inputs["Scale"].default_value = 5.0
    links.new(mp.outputs["Vector"], v.inputs["Vector"])
    crack_ramp = nodes.new("ShaderNodeValToRGB"); crack_ramp.location = (-450, -100)
    crack_ramp.color_ramp.elements[0].position = 0.0
    crack_ramp.color_ramp.elements[0].color = (1, 1, 1, 1)
    crack_ramp.color_ramp.elements[1].position = 0.08
    crack_ramp.color_ramp.elements[1].color = (0, 0, 0, 1)
    links.new(v.outputs["Distance"], crack_ramp.inputs["Fac"])

    # Mix basalt with crack mask -> dark cracks
    mix = nodes.new("ShaderNodeMix"); mix.data_type='RGBA'; mix.location = (-200, 100)
    links.new(crack_ramp.outputs["Color"], mix.inputs["Factor"])
    links.new(basalt_ramp.outputs["Color"], mix.inputs[6])
    mix.inputs[7].default_value = (0.02, 0.01, 0.01, 1)
    links.new(mix.outputs[2], bsdf.inputs["Base Color"])

    # Crack glow emission (orange-red)
    glow = nodes.new("ShaderNodeMix"); glow.data_type='RGBA'; glow.location = (100, -100)
    links.new(crack_ramp.outputs["Color"], glow.inputs["Factor"])
    glow.inputs[6].default_value = (0, 0, 0, 1)
    glow.inputs[7].default_value = (1.0, 0.45, 0.10, 1)
    links.new(glow.outputs[2], bsdf.inputs["Emission Color"])

    # Bump from basalt noise
    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -300)
    bp.inputs["Strength"].default_value = 0.4
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_lava_pool():
    """Flowing lava with bright emission + ring wave normal."""
    m = bpy.data.materials.new("v3bs_lava")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1200, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (900, 0)
    bsdf.inputs["Base Color"].default_value = (1.0, 0.30, 0.05, 1)
    bsdf.inputs["Roughness"].default_value = 0.20
    bsdf.inputs["Emission Color"].default_value = (1.0, 0.45, 0.10, 1)
    bsdf.inputs["Emission Strength"].default_value = 18.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-900, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-700, 0)
    mp.inputs["Scale"].default_value = (8, 8, 8)
    links.new(tc.outputs["Object"], mp.inputs["Vector"])

    # Voronoi ridges for crust pattern
    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-450, 0)
    v.feature = 'DISTANCE_TO_EDGE'
    v.inputs["Scale"].default_value = 6.0
    links.new(mp.outputs["Vector"], v.inputs["Vector"])
    ramp = nodes.new("ShaderNodeValToRGB"); ramp.location = (-200, 0)
    ramp.color_ramp.elements[0].position = 0.0
    ramp.color_ramp.elements[0].color = (1.0, 0.85, 0.30, 1)
    ramp.color_ramp.elements[1].position = 0.30
    ramp.color_ramp.elements[1].color = (0.4, 0.05, 0.02, 1)
    links.new(v.outputs["Distance"], ramp.inputs["Fac"])
    links.new(ramp.outputs["Color"], bsdf.inputs["Emission Color"])
    links.new(ramp.outputs["Color"], bsdf.inputs["Base Color"])

    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -200)
    bp.inputs["Strength"].default_value = 0.5
    links.new(v.outputs["Distance"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

# ============================================================
# MATERIALS
# ============================================================
mat_basalt = make_basalt_lava()
mat_lava = make_lava_pool()
mat_obsidian = make_pbr("v3bs_obsidian", (0.05,0.04,0.04), 0.20, 0.50,
    emission_color=(1.0,0.30,0.10), emission_strength=0.4,
    noise_strength=0.15, curvature_dirt=True, fresnel_rim=True, bump_strength=0.10, bump_scale=20.0)
mat_obsidian_carved = make_pbr("v3bs_obs_carved", (0.06,0.04,0.04), 0.30, 0.55,
    emission_color=(1.0,0.30,0.10), emission_strength=0.6,
    noise_strength=0.20, voronoi_strength=0.40, voronoi_scale=12.0,
    curvature_dirt=True, fresnel_rim=True, bump_strength=0.20, bump_scale=14.0)
mat_glow_red = make_pbr("v3bs_glow_r", (1.0,0.30,0.10), 0.10, 0,
    emission_color=(1.0,0.30,0.10), emission_strength=14.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mat_glow_orange = make_pbr("v3bs_glow_o", (1.0,0.55,0.20), 0.10, 0,
    emission_color=(1.0,0.55,0.20), emission_strength=16.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mat_glow_magenta = make_pbr("v3bs_glow_m", (0.85,0.20,0.55), 0.10, 0,
    emission_color=(1.0,0.30,0.65), emission_strength=12.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mat_chain = make_pbr("v3bs_chain", (0.08,0.07,0.07), 0.55, 0.85,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.20, bump_scale=40.0)
mat_skull_bone = make_pbr("v3bs_skull", (0.65,0.55,0.42), 0.85,
    emission_color=(1.0,0.45,0.10), emission_strength=0.6,
    noise_strength=0.20, curvature_dirt=True, fresnel_rim=True, bump_strength=0.20, bump_scale=40.0)
mat_brazier_metal = make_pbr("v3bs_brazier", (0.10,0.06,0.05), 0.45, 0.80,
    emission_color=(1.0,0.30,0.10), emission_strength=0.8,
    noise_strength=0.15, curvature_dirt=True, fresnel_rim=True, bump_strength=0.20, bump_scale=22.0)
mat_banner = make_pbr("v3bs_banner", (0.45,0.05,0.05), 0.85,
    emission_color=(1.0,0.30,0.10), emission_strength=0.8,
    noise_strength=0.30, curvature_dirt=True, fresnel_rim=True, bump_strength=0.20, bump_scale=50.0)
mat_crystal_heart = make_pbr("v3bs_heart", (1.0,0.20,0.30), 0.05, 0,
    emission_color=(1.0,0.30,0.40), emission_strength=20.0,
    noise_strength=0.05, curvature_dirt=False, fresnel_rim=True, bump_strength=0.05)
mat_sigil_glow = make_pbr("v3bs_sigil", (1.0,0.45,0.20), 0.05, 0,
    emission_color=(1.0,0.55,0.20), emission_strength=18.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mat_ember = make_pbr("v3bs_ember", (1.0,0.55,0.10), 0.10, 0,
    emission_color=(1.0,0.55,0.10), emission_strength=20.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)

# ============================================================
# UTIL
# ============================================================
def add_subsurf_bevel(obj, levels=2, bevel=0.025):
    s = obj.modifiers.new("Subsurf", 'SUBSURF'); s.levels = levels; s.render_levels = levels+1
    b = obj.modifiers.new("Bevel", 'BEVEL'); b.width = bevel; b.segments = 3; b.profile = 0.7
    for poly in obj.data.polygons: poly.use_smooth = True

def box(name, loc, scale, mat, parent, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.object; o.name = name; o.scale = scale; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o)
    o.parent = parent
    return o

def cyl(name, loc, r, depth, mat, parent, verts=20, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=r, depth=depth, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    return o

def sph(name, loc, r, mat, parent, segs=18):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segs, ring_count=segs//2, radius=r, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=2, bevel=0.005)
    o.parent = parent
    return o

def cone(name, loc, r1, r2, depth, mat, parent, verts=18, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    return o

def tor(name, loc, R, r, mat, parent, ms=24, mn=12, rot=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_segments=ms, minor_segments=mn, major_radius=R, minor_radius=r, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.005)
    o.parent = parent
    return o

# ============================================================
# SCENE
# ============================================================
parent = bpy.data.objects.new("v3_boss_sanctum", None); scene.collection.objects.link(parent)

ARENA_R = 8.0
INNER_R = 5.5

# Octagonal floor — basalt
cyl("floor", (0,0,0), ARENA_R, 0.30, mat_basalt, parent, verts=8)
# inner ring (slightly raised) for the combat circle
cyl("inner_ring", (0,0,0.16), INNER_R, 0.10, mat_basalt, parent, verts=32)
# Inner ring lava trim
tor("inner_trim", (0,0,0.22), INNER_R, 0.08, mat_glow_orange, parent, ms=64, mn=12)

# Outer lava moat — annulus made of 16 wedge segments
def lava_moat():
    SEG = 16
    for i in range(SEG):
        ang = i * (math.pi*2/SEG)
        x = math.cos(ang) * (ARENA_R + 1.2)
        y = math.sin(ang) * (ARENA_R + 1.2)
        bpy.ops.mesh.primitive_cube_add(size=1, location=(x, y, 0.04))
        seg = bpy.context.object
        seg.name = f"moat_{i}"
        seg.scale = (1.6, 0.8, 0.05)
        seg.rotation_euler = (0, 0, ang)
        seg.data.materials.append(mat_lava)
        add_subsurf_bevel(seg, levels=1, bevel=0.002)
        seg.parent = parent
lava_moat()

# ============================================================
# 8 OBSIDIAN PILLARS around perimeter
# ============================================================
def obsidian_pillar(name, x, y, parent):
    # Stepped base
    box(f"{name}_b1", (x, y, 0.40), (1.4, 1.4, 0.40), mat_obsidian, parent)
    box(f"{name}_b2", (x, y, 0.85), (1.2, 1.2, 0.30), mat_obsidian_carved, parent)
    # Tapered shaft (cone with small top radius)
    cone(f"{name}_shaft", (x, y, 3.5), 0.55, 0.40, 4.8, mat_obsidian, parent, verts=8)
    # Mid carving band
    tor(f"{name}_band", (x, y, 3.5), 0.55, 0.06, mat_glow_red, parent, ms=24, mn=10)
    # Glyph studs around band (4 per pillar)
    for i in range(4):
        ang = i * math.pi/2
        gx = x + math.cos(ang) * 0.60
        gy = y + math.sin(ang) * 0.60
        sph(f"{name}_g_{i}", (gx, gy, 3.5), 0.06, mat_sigil_glow, parent, segs=12)
    # Pillar top crystal cluster
    cone(f"{name}_top_cap", (x, y, 6.10), 0.50, 0.0, 0.40, mat_obsidian_carved, parent, verts=8)
    cone(f"{name}_top_c", (x, y, 6.50), 0.18, 0.04, 0.50, mat_crystal_heart, parent, verts=6)

PILLAR_COUNT = 8
for i in range(PILLAR_COUNT):
    ang = i * (math.pi*2/PILLAR_COUNT) + math.pi/8
    x = math.cos(ang) * (ARENA_R - 1.1)
    y = math.sin(ang) * (ARENA_R - 1.1)
    obsidian_pillar(f"pillar_{i}", x, y, parent)

# ============================================================
# CENTRAL BOSS SPAWN PLATFORM
# ============================================================
# 3-tier raised platform at center
cyl("plat_b1", (0, 0, 0.45), 2.4, 0.30, mat_obsidian, parent, verts=24)
cyl("plat_b2", (0, 0, 0.70), 2.0, 0.20, mat_obsidian_carved, parent, verts=24)
cyl("plat_b3", (0, 0, 0.85), 1.6, 0.10, mat_obsidian_carved, parent, verts=32)
# Sigil ring on top
tor("plat_sigil1", (0, 0, 0.92), 1.4, 0.05, mat_sigil_glow, parent, ms=48, mn=10)
tor("plat_sigil2", (0, 0, 0.92), 1.0, 0.04, mat_sigil_glow, parent, ms=48, mn=10)
tor("plat_sigil3", (0, 0, 0.92), 0.6, 0.03, mat_sigil_glow, parent, ms=48, mn=10)
# 6 glyphs at center radial points
for i in range(6):
    ang = i * (math.pi*2/6)
    gx = math.cos(ang) * 1.1
    gy = math.sin(ang) * 1.1
    sph(f"plat_gl_{i}", (gx, gy, 0.92), 0.10, mat_glow_orange, parent, segs=14)
# Strong central red point light
bpy.ops.object.light_add(type='POINT', location=(0, 0, 1.5))
cp = bpy.context.object; cp.data.energy = 800; cp.data.color = (1.0, 0.40, 0.15)

# ============================================================
# 8 LAVA BRAZIERS along inner ring
# ============================================================
def brazier(name, x, y, parent):
    cyl(f"{name}_b", (x, y, 0.40), 0.30, 0.40, mat_brazier_metal, parent, verts=18)
    cyl(f"{name}_p", (x, y, 0.85), 0.10, 0.50, mat_brazier_metal, parent, verts=10)
    sph(f"{name}_bowl", (x, y, 1.20), 0.32, mat_brazier_metal, parent, segs=20)
    cyl(f"{name}_lava", (x, y, 1.40), 0.28, 0.04, mat_lava, parent, verts=24)
    sph(f"{name}_f1", (x, y, 1.55), 0.18, mat_glow_orange, parent, segs=12)
    sph(f"{name}_f2", (x, y, 1.70), 0.10, mat_glow_red, parent, segs=10)

for i in range(PILLAR_COUNT):
    ang = i * (math.pi*2/PILLAR_COUNT) + math.pi/8 + math.pi/PILLAR_COUNT
    x = math.cos(ang) * (INNER_R + 0.8)
    y = math.sin(ang) * (INNER_R + 0.8)
    brazier(f"brz_{i}", x, y, parent)

# ============================================================
# 4 HANGING CHAINS WITH SKULL CORES
# ============================================================
def hanging_chain(name, x, y, parent):
    # Long vertical "chain" — 6 torus links
    for i in range(6):
        z = 6.0 - i * 0.30
        rot = (math.pi/2 if i % 2 == 0 else 0, 0, 0)
        tor(f"{name}_l_{i}", (x, y, z), 0.10, 0.025, mat_chain, parent, ms=14, mn=8, rot=rot)
    # Skull core at the bottom
    sph(f"{name}_skull", (x, y, 4.0), 0.18, mat_skull_bone, parent, segs=18)
    # Dark eye sockets
    sph(f"{name}_e1", (x - 0.07, y + 0.05, 4.05), 0.04, mat_glow_red, parent, segs=10)
    sph(f"{name}_e2", (x + 0.07, y + 0.05, 4.05), 0.04, mat_glow_red, parent, segs=10)
    # Banner cloth drop hanging from chain
    bpy.ops.mesh.primitive_plane_add(size=1, location=(x, y, 4.7))
    b = bpy.context.object; b.name = f"{name}_banner"
    b.scale = (0.7, 0.05, 1.4); b.rotation_euler = (math.pi/2, 0, 0)
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.subdivide(number_cuts=8)
    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    for v in b.data.vertices:
        v.co.x += math.sin(v.co.z * 4) * 0.04
    b.data.materials.append(mat_banner); add_subsurf_bevel(b, levels=2, bevel=0.001)
    b.parent = parent

CHAIN_POSITIONS = [(-3.5, -3.5), (3.5, -3.5), (-3.5, 3.5), (3.5, 3.5)]
for i, (cx, cy) in enumerate(CHAIN_POSITIONS):
    hanging_chain(f"chain_{i}", cx, cy, parent)

# ============================================================
# THRONE — massive obsidian throne at far end (positive Y)
# ============================================================
tx, ty = 0, ARENA_R - 1.5
# Throne base
box("th_base", (tx, ty, 0.50), (3.2, 2.0, 1.0), mat_obsidian, parent)
box("th_b2", (tx, ty, 1.10), (2.8, 1.6, 0.20), mat_obsidian_carved, parent)
# Seat
box("th_seat", (tx, ty, 1.40), (2.4, 1.4, 0.30), mat_obsidian, parent)
# Massive backrest (5m tall)
box("th_back", (tx, ty + 0.65, 3.50), (2.8, 0.40, 4.0), mat_obsidian, parent)
# Backrest carved insets (3 vertical glow strips)
for i, dx in enumerate([-0.6, 0, 0.6]):
    box(f"th_st_{i}", (tx + dx, ty + 0.40, 3.50), (0.04, 0.04, 3.2), mat_glow_red, parent)
# Backrest top spikes (5)
for i, dx in enumerate([-1.2, -0.6, 0, 0.6, 1.2]):
    cone(f"th_sp_{i}", (tx + dx, ty + 0.65, 5.7), 0.20 - abs(i-2)*0.04, 0.0, 0.6, mat_obsidian_carved, parent, verts=6)
# Throne arms
box("th_a1", (tx - 1.4, ty - 0.10, 1.8), (0.30, 1.20, 0.60), mat_obsidian, parent)
box("th_a2", (tx + 1.4, ty - 0.10, 1.8), (0.30, 1.20, 0.60), mat_obsidian, parent)
# Crystal heart embedded center of backrest
sph("th_heart", (tx, ty + 0.30, 3.5), 0.40, mat_crystal_heart, parent, segs=24)
# Heart frame (torus around it)
tor("th_heart_frame", (tx, ty + 0.30, 3.5), 0.50, 0.06, mat_glow_red, parent, ms=32, mn=12, rot=(math.pi/2, 0, 0))
# Strong heart glow
bpy.ops.object.light_add(type='POINT', location=(tx, ty + 0.30, 3.5))
hp = bpy.context.object; hp.data.energy = 1500; hp.data.color = (1.0, 0.30, 0.40)

# Side standards (banner poles flanking throne)
for i, dx in enumerate([-2.6, 2.6]):
    cyl(f"std_p_{i}", (tx + dx, ty, 3.0), 0.08, 6.0, mat_chain, parent, verts=10)
    cyl(f"std_top_{i}", (tx + dx, ty, 6.10), 0.04, 0.20, mat_glow_red, parent, verts=10)
    sph(f"std_orb_{i}", (tx + dx, ty, 6.30), 0.12, mat_crystal_heart, parent, segs=14)

# ============================================================
# 12 FLOATING EMBER MOTES
# ============================================================
EMBER_POSITIONS = [
    (-2, -1, 1.6), (2, 1, 2.0), (-1, 2, 1.4),
    (3, -2, 1.8), (-3, 0, 2.4), (0, -3, 1.2),
    (1, 3, 2.2), (-2, -3, 1.6), (4, 2, 1.4),
    (-4, 1, 1.8), (0, 4, 2.6), (2, -4, 1.0),
]
for i, (x, y, z) in enumerate(EMBER_POSITIONS):
    sph(f"ember_{i}", (x, y, z), 0.06, mat_ember, parent, segs=12)

# ============================================================
# LIGHTING — strong cinematic without volumetrics
# ============================================================
# Crimson key from front-above
bpy.ops.object.light_add(type='SPOT', location=(8, -10, 12))
key = bpy.context.object
key.data.energy = 5500; key.data.color = (1.0, 0.30, 0.15)
key.data.spot_size = math.radians(80)
key.data.spot_blend = 0.4
direction = Vector((0,0,1)) - key.location
key.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

# Magenta back rim
bpy.ops.object.light_add(type='AREA', location=(-6, 10, 8))
rim = bpy.context.object
rim.data.energy = 1200; rim.data.color = (0.85, 0.20, 0.55); rim.data.size = 8

# Orange ground glow
bpy.ops.object.light_add(type='AREA', location=(0, 0, 0.5))
gl = bpy.context.object
gl.data.energy = 600; gl.data.color = (1.0, 0.45, 0.10); gl.data.size = 12
gl.rotation_euler = (math.pi, 0, 0)

# Throne backlight
bpy.ops.object.light_add(type='AREA', location=(0, ARENA_R + 2, 4))
tb = bpy.context.object
tb.data.energy = 800; tb.data.color = (1.0, 0.30, 0.15); tb.data.size = 6
tb.rotation_euler = (math.pi/2 - 0.3, 0, 0)

# ============================================================
# CAMERAS
# ============================================================
def add_cam(name, loc, target, lens=35, dof_dist=10):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = 4.5
    c.data.dof.focus_distance = dof_dist
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_main   = add_cam("cam_arena",   Vector((10, -12, 5.5)), Vector((0, 0, 2)), lens=32, dof_dist=14)
cam_throne = add_cam("cam_throne",  Vector((4, 0, 3.0)),    Vector((0, ARENA_R - 1.5, 3.5)), lens=50, dof_dist=8)
cam_plat   = add_cam("cam_platform", Vector((3.5, -3.5, 2.5)), Vector((0, 0, 1.0)), lens=50, dof_dist=5)

CAMERAS = [
    ("arena",   cam_main,   (1600, 900)),
    ("throne",  cam_throne, (1280, 960)),
    ("platform", cam_plat,  (1280, 960)),
]

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render
for name, cam, (w, h) in CAMERAS:
    scene.camera = cam
    scene.render.resolution_x = w
    scene.render.resolution_y = h
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_boss_sanctum_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Export GLB
bpy.ops.object.select_all(action='DESELECT')
parent.select_set(True)
for child in parent.children_recursive:
    child.select_set(True)
out_path = os.path.join(EXPORT_DIR, "boss_sanctum_v3.glb")
bpy.ops.export_scene.gltf(
    filepath=out_path, use_selection=True,
    export_format='GLB', export_apply=True
)
print(f"Exported: {out_path}")

print("=== V3 Epic 16 Boss Sanctum Biome complete ===")
