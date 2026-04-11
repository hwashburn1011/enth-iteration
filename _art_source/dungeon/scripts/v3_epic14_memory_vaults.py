"""
Expansion V3 — Epic 14 — Memory Vaults Biome Texture Pass
=========================================================
Second dungeon biome — ancient knowledge vault. Trailer-grade hero hall.

Layout: 16-unit deep cathedral hall with:
  - Aged sandstone tile floor with gold inlay seams
  - Vaulted ceiling arches (4 arches across)
  - 6 weathered stone pillars (3 per side) with gold inscription bands
  - 4 wall niches with brass urns inside
  - 6 brass urns scattered along walls (with patina)
  - 4 floating glowing scrolls in mid-air
  - 2 stone podiums with relics (book + crystal)
  - Golden brazier at the far altar
  - Dust mote particles in warm shafts of light
  - 3-point warm sunset lighting through high windows

Outputs:
  - 1 hero hall render @ 1920x1080
  - 1 pillar close-up @ 1280x960
  - 1 altar render @ 1280x960
  - 1 GLB export
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(14)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/v3_memory_vaults.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/exports"
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 128
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.view_settings.look = 'AgX - High Contrast'

# Volumetric world (warm dust haze)
scene.world = bpy.data.worlds.new("v3_mv_world")
scene.world.use_nodes = True
wnt = scene.world.node_tree
wnt.nodes.clear()
wout = wnt.nodes.new("ShaderNodeOutputWorld")
wbg = wnt.nodes.new("ShaderNodeBackground")
wbg.inputs["Color"].default_value = (0.04, 0.025, 0.015, 1)
wbg.inputs["Strength"].default_value = 0.3
wnt.links.new(wbg.outputs[0], wout.inputs[0])
vol = wnt.nodes.new("ShaderNodeVolumeScatter")
vol.inputs["Color"].default_value = (0.95, 0.78, 0.45, 1)
vol.inputs["Density"].default_value = 0.010
wnt.links.new(vol.outputs[0], wout.inputs["Volume"])

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
        ar.color_ramp.elements[0].color = (0.15,0.10,0.06,1)
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

def make_inscription_tile(name):
    """Sandstone tile with gold inlay seams via brick texture."""
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.85
    bsdf.inputs["Emission Strength"].default_value = 0.6
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (4, 4, 4)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Brick = sandstone tile pattern
    brick = nodes.new("ShaderNodeTexBrick"); brick.location = (-700, 100)
    brick.inputs["Scale"].default_value = 4.0
    brick.inputs["Color1"].default_value = (0.62, 0.50, 0.32, 1)
    brick.inputs["Color2"].default_value = (0.55, 0.42, 0.25, 1)
    brick.inputs["Mortar"].default_value = (0.85, 0.65, 0.20, 1)  # gold seam
    brick.inputs["Mortar Size"].default_value = 0.018
    brick.inputs["Bias"].default_value = 0.0
    links.new(mp.outputs["Vector"], brick.inputs["Vector"])

    # Noise variation
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, -100)
    n.inputs["Scale"].default_value = 18.0
    n.inputs["Detail"].default_value = 6.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])
    nr = nodes.new("ShaderNodeValToRGB"); nr.location = (-450, -100)
    nr.color_ramp.elements[0].position = 0.40
    nr.color_ramp.elements[0].color = (0.50, 0.40, 0.22, 1)
    nr.color_ramp.elements[1].position = 0.70
    nr.color_ramp.elements[1].color = (0.70, 0.55, 0.32, 1)
    links.new(n.outputs["Fac"], nr.inputs["Fac"])

    # Mix brick * noise
    mix = nodes.new("ShaderNodeMix"); mix.data_type='RGBA'; mix.location = (-200, 0)
    mix.blend_type = 'MULTIPLY'
    mix.inputs["Factor"].default_value = 0.4
    links.new(brick.outputs["Color"], mix.inputs[6])
    links.new(nr.outputs["Color"], mix.inputs[7])

    # Curvature darkening
    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-200, -300)
    ar = nodes.new("ShaderNodeValToRGB"); ar.location = (50, -300)
    ar.color_ramp.elements[0].position = 0.30
    ar.color_ramp.elements[0].color = (0.15, 0.10, 0.05, 1)
    ar.color_ramp.elements[1].position = 0.70
    ar.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(geo.outputs["Pointiness"], ar.inputs["Fac"])
    md = nodes.new("ShaderNodeMix"); md.data_type='RGBA'; md.location = (300, 0)
    md.inputs["Factor"].default_value = 0.40
    links.new(mix.outputs[2], md.inputs[6])
    links.new(ar.outputs["Color"], md.inputs[7])
    links.new(md.outputs[2], bsdf.inputs["Base Color"])

    # Glow on the gold seams via brick output emission factor
    glow_mix = nodes.new("ShaderNodeMix"); glow_mix.data_type='RGBA'; glow_mix.location = (550, 200)
    glow_mix.inputs[6].default_value = (0, 0, 0, 1)
    glow_mix.inputs[7].default_value = (1.0, 0.78, 0.30, 1)
    # Use mortar mask: when brick fac is high (mortar), mix more gold
    # We approximate by inverting brick color
    glow_mix.inputs["Factor"].default_value = 0.0
    links.new(brick.outputs["Fac"], glow_mix.inputs["Factor"])
    links.new(glow_mix.outputs[2], bsdf.inputs["Emission Color"])

    # Bump from noise
    bp = nodes.new("ShaderNodeBump"); bp.location = (550, -300)
    bp.inputs["Strength"].default_value = 0.30
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_brass_patina(name):
    """Brass with verdigris patina in crevices."""
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1200, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (900, 0)
    bsdf.inputs["Base Color"].default_value = (0.78, 0.55, 0.18, 1)
    bsdf.inputs["Roughness"].default_value = 0.35
    bsdf.inputs["Metallic"].default_value = 0.92
    bsdf.inputs["Emission Color"].default_value = (1.0, 0.80, 0.30, 1)
    bsdf.inputs["Emission Strength"].default_value = 0.6
    links.new(bsdf.outputs[0], out.inputs[0])

    # Curvature -> patina mask
    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-600, -100)
    inv = nodes.new("ShaderNodeMath"); inv.location = (-400, -100)
    inv.operation = 'SUBTRACT'
    inv.inputs[0].default_value = 1.0
    links.new(geo.outputs["Pointiness"], inv.inputs[1])
    patina_ramp = nodes.new("ShaderNodeValToRGB"); patina_ramp.location = (-200, -100)
    patina_ramp.color_ramp.elements[0].position = 0.50
    patina_ramp.color_ramp.elements[0].color = (0, 0, 0, 1)
    patina_ramp.color_ramp.elements[1].position = 0.85
    patina_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(inv.outputs[0], patina_ramp.inputs["Fac"])

    # Brass + patina mix
    brass_color = nodes.new("ShaderNodeRGB"); brass_color.location = (-200, 200)
    brass_color.outputs[0].default_value = (0.78, 0.55, 0.18, 1)
    patina_color = nodes.new("ShaderNodeRGB"); patina_color.location = (-200, 0)
    patina_color.outputs[0].default_value = (0.20, 0.55, 0.45, 1)  # verdigris green

    mix = nodes.new("ShaderNodeMix"); mix.data_type='RGBA'; mix.location = (100, 100)
    links.new(patina_ramp.outputs["Color"], mix.inputs["Factor"])
    links.new(brass_color.outputs[0], mix.inputs[6])
    links.new(patina_color.outputs[0], mix.inputs[7])
    links.new(mix.outputs[2], bsdf.inputs["Base Color"])

    # Roughness modulated by patina
    rough_mix = nodes.new("ShaderNodeMix"); rough_mix.location = (100, -150)
    rough_mix.inputs[2].default_value = 0.85
    rough_mix.inputs[3].default_value = 0.30
    links.new(patina_ramp.outputs["Color"], rough_mix.inputs[0])
    links.new(rough_mix.outputs[0], bsdf.inputs["Roughness"])

    # Bump from noise
    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-900, -400)
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, -400)
    n.inputs["Scale"].default_value = 25.0
    links.new(tc.outputs["Object"], n.inputs["Vector"])
    bp = nodes.new("ShaderNodeBump"); bp.location = (-400, -400)
    bp.inputs["Strength"].default_value = 0.20
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

# ============================================================
# MATERIALS
# ============================================================
mat_floor      = make_inscription_tile("v3mv_floor")
mat_pillar     = make_pbr("v3mv_pillar", (0.65,0.55,0.40), 0.85,
    noise_strength=0.30, voronoi_strength=0.45, voronoi_scale=8.0, bump_strength=0.30, bump_scale=12.0)
mat_pillar_glow = make_pbr("v3mv_pillar_glyph", (0.85,0.65,0.20), 0.30, 0.85,
    emission_color=(1.0,0.80,0.30), emission_strength=4.0,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True)
mat_wall       = make_pbr("v3mv_wall", (0.55,0.45,0.32), 0.92,
    noise_strength=0.30, voronoi_strength=0.45, voronoi_scale=8.0, bump_strength=0.40, bump_scale=10.0)
mat_ceiling    = make_pbr("v3mv_ceiling", (0.45,0.36,0.25), 0.92,
    noise_strength=0.30, voronoi_strength=0.45, voronoi_scale=10.0, bump_strength=0.35, bump_scale=12.0)
mat_brass_patina = make_brass_patina("v3mv_brass_patina")
mat_brass_clean  = make_pbr("v3mv_brass_clean", (0.85,0.65,0.20), 0.20, 0.95,
    emission_color=(1.0,0.80,0.30), emission_strength=0.8,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True)
mat_scroll_paper = make_pbr("v3mv_scroll", (0.92,0.80,0.55), 0.85,
    emission_color=(1.0,0.85,0.45), emission_strength=2.5,
    noise_strength=0.20, curvature_dirt=True, fresnel_rim=True, bump_strength=0.10, bump_scale=80.0)
mat_glyph_glow = make_pbr("v3mv_glyph", (1.0,0.85,0.40), 0.10,
    emission_color=(1.0,0.85,0.40), emission_strength=8.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mat_book_leather = make_pbr("v3mv_book", (0.35,0.10,0.05), 0.55,
    noise_strength=0.25, voronoi_strength=0.20, voronoi_scale=80.0, bump_strength=0.20, bump_scale=80.0)
mat_crystal = make_pbr("v3mv_crystal", (0.30,0.55,0.95), 0.10, 0,
    emission_color=(0.40,0.75,1.0), emission_strength=4.0,
    noise_strength=0.10, curvature_dirt=False, fresnel_rim=True, bump_strength=0.05)
mat_brazier_fire = make_pbr("v3mv_fire", (1.0,0.55,0.20), 0.10, 0,
    emission_color=(1.0,0.55,0.20), emission_strength=14.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mat_relief_gold = make_pbr("v3mv_relief", (1.0,0.85,0.30), 0.20, 1.0,
    emission_color=(1.0,0.85,0.40), emission_strength=2.5,
    noise_strength=0.05, curvature_dirt=True, fresnel_rim=True)

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

def sph(name, loc, r, mat, parent, segs=20):
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

def tor(name, loc, R, r, mat, parent, ms=24, mn=12):
    bpy.ops.mesh.primitive_torus_add(major_segments=ms, minor_segments=mn, major_radius=R, minor_radius=r, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.005)
    o.parent = parent
    return o

# ============================================================
# HALL LAYOUT
# ============================================================
parent = bpy.data.objects.new("v3_memory_vaults", None); scene.collection.objects.link(parent)

HALL_LEN = 16
HALL_WID = 7
CEIL_H = 5.5

# Floor
box("floor", (0, 0, 0), (HALL_WID, HALL_LEN, 0.10), mat_floor, parent)
# Walls
box("wall_L", (-HALL_WID/2 - 0.10, 0, CEIL_H/2), (0.20, HALL_LEN, CEIL_H), mat_wall, parent)
box("wall_R", ( HALL_WID/2 + 0.10, 0, CEIL_H/2), (0.20, HALL_LEN, CEIL_H), mat_wall, parent)
# Far altar wall
box("wall_back", (0, HALL_LEN/2 + 0.10, CEIL_H/2), (HALL_WID, 0.20, CEIL_H), mat_wall, parent)

# Vaulted ceiling — 4 arch segments
def vaulted_arch(name, y_pos, parent):
    # Two side curves + a top keystone
    box(f"{name}_keystone", (0, y_pos, CEIL_H + 0.10), (HALL_WID, 0.40, 0.40), mat_ceiling, parent)
    # 5-segment arch on each side
    for i in range(5):
        ang = (i+0.5) * (math.pi / 5) - math.pi/2
        x = math.cos(ang) * (HALL_WID/2 - 0.4)
        z = CEIL_H + 0.10 + (math.sin(ang) + 1) * 0.30
        box(f"{name}_a_{i}", (x, y_pos, z), (0.6, 0.40, 0.20), mat_ceiling, parent, rot=(0, ang, 0))

for i, ay in enumerate([-6, -2, 2, 6]):
    vaulted_arch(f"arch_{i}", ay, parent)

# ============================================================
# PILLARS — 6 pillars (3 per side) with gold inscription bands
# ============================================================
def build_pillar(name, x, y, parent):
    # Base
    box(f"{name}_base", (x, y, 0.30), (1.0, 1.0, 0.40), mat_pillar, parent)
    box(f"{name}_b2",   (x, y, 0.65), (0.85, 0.85, 0.30), mat_pillar, parent)
    # Shaft
    cyl(f"{name}_shaft", (x, y, 2.7), 0.32, 4.0, mat_pillar, parent, verts=24)
    # Fluting (6 vertical strips)
    for f in range(6):
        ang = f * math.pi/3
        fx = x + math.cos(ang) * 0.32
        fy = y + math.sin(ang) * 0.32
        box(f"{name}_fl_{f}", (fx, fy, 2.7), (0.05, 0.05, 3.8), mat_pillar, parent, rot=(0, 0, ang))
    # Gold inscription band (mid-height)
    tor(f"{name}_band1", (x, y, 1.5), 0.36, 0.06, mat_pillar_glow, parent, ms=32, mn=12)
    tor(f"{name}_band2", (x, y, 3.7), 0.36, 0.06, mat_pillar_glow, parent, ms=32, mn=12)
    # 8 glyph studs around band
    for i in range(8):
        ang = i * math.pi/4
        gx = x + math.cos(ang) * 0.40
        gy = y + math.sin(ang) * 0.40
        sph(f"{name}_g_{i}", (gx, gy, 1.5), 0.05, mat_glyph_glow, parent, segs=12)
    # Capital
    box(f"{name}_c1", (x, y, 4.85), (0.85, 0.85, 0.30), mat_pillar, parent)
    box(f"{name}_c2", (x, y, 5.20), (1.0, 1.0, 0.40), mat_pillar, parent)
    return parent

for i, py in enumerate([-5, 0, 5]):
    build_pillar(f"pl_L_{i}", -2.4, py, parent)
    build_pillar(f"pl_R_{i}",  2.4, py, parent)

# ============================================================
# BRASS URNS — 6 along walls + 4 in wall niches
# ============================================================
def build_urn(name, x, y, z, parent, scale=1.0):
    # Base ring
    cyl(f"{name}_base", (x, y, z + 0.05*scale), 0.28*scale, 0.10*scale, mat_brass_patina, parent, verts=20)
    # Body sphere (slightly squashed)
    s = sph(f"{name}_body", (x, y, z + 0.45*scale), 0.32*scale, mat_brass_patina, parent, segs=24)
    s.scale = (1.0*scale, 1.0*scale, 1.2*scale)
    # Neck
    cyl(f"{name}_neck", (x, y, z + 0.85*scale), 0.18*scale, 0.16*scale, mat_brass_patina, parent, verts=16)
    # Lip
    cyl(f"{name}_lip", (x, y, z + 0.95*scale), 0.22*scale, 0.04*scale, mat_brass_patina, parent, verts=20)
    # Two handles
    tor(f"{name}_h1", (x + 0.30*scale, y, z + 0.55*scale), 0.10*scale, 0.025*scale, mat_brass_patina, parent, ms=12, mn=8)
    tor(f"{name}_h2", (x - 0.30*scale, y, z + 0.55*scale), 0.10*scale, 0.025*scale, mat_brass_patina, parent, ms=12, mn=8)

for i, (x, y) in enumerate([(-3.0, -7), (3.0, -7), (-3.0, 7), (3.0, 7), (-3.0, -3.5), (3.0, 3.5)]):
    build_urn(f"urn_{i}", x, y, 0.05, parent)

# Wall niche urns (on shelves)
def wall_niche(name, x, y, z, parent):
    box(f"{name}_shelf", (x, y, z), (0.6, 0.4, 0.10), mat_pillar, parent)
    box(f"{name}_back",  (x + (0.20 if x > 0 else -0.20), y, z + 0.50), (0.04, 0.5, 1.0), mat_pillar_glow, parent)
    build_urn(f"{name}_urn", x, y, z + 0.10, parent, scale=0.7)

wall_niche("nch_L0", -3.4, -4, 1.5, parent)
wall_niche("nch_L1", -3.4,  4, 1.5, parent)
wall_niche("nch_R0",  3.4, -4, 1.5, parent)
wall_niche("nch_R1",  3.4,  4, 1.5, parent)

# ============================================================
# FLOATING SCROLLS — 4 floating glowing scrolls
# ============================================================
def floating_scroll(name, x, y, z, parent):
    # rolled scroll body
    cyl(f"{name}_body", (x, y, z), 0.10, 0.50, mat_scroll_paper, parent, verts=18, rot=(0, math.pi/2, 0))
    # protruding rolls
    cyl(f"{name}_r1", (x - 0.30, y, z), 0.12, 0.10, mat_scroll_paper, parent, verts=14, rot=(0, math.pi/2, 0))
    cyl(f"{name}_r2", (x + 0.30, y, z), 0.12, 0.10, mat_scroll_paper, parent, verts=14, rot=(0, math.pi/2, 0))
    # glowing seal
    sph(f"{name}_seal", (x, y + 0.12, z), 0.06, mat_glyph_glow, parent, segs=12)

floating_scroll("sc_0", -1.0, -3, 2.4, parent)
floating_scroll("sc_1",  1.0,  1, 2.6, parent)
floating_scroll("sc_2", -0.5,  4, 2.2, parent)
floating_scroll("sc_3",  0.5, -1, 2.8, parent)

# ============================================================
# ALTAR PODIUMS — 2 with relics + central brazier at far end
# ============================================================
# Podium 1 (left of altar)
box("pod_L_b", (-1.5, 7.0, 0.20), (0.9, 0.9, 0.40), mat_pillar, parent)
box("pod_L_c", (-1.5, 7.0, 0.55), (0.7, 0.7, 0.10), mat_pillar_glow, parent)
# leather book on top
box("pod_L_book", (-1.5, 7.0, 0.66), (0.30, 0.40, 0.08), mat_book_leather, parent)
box("pod_L_pg",   (-1.5, 7.0, 0.71), (0.27, 0.36, 0.02), mat_scroll_paper, parent)
# bookmark
box("pod_L_bm", (-1.5, 7.20, 0.73), (0.04, 0.10, 0.005), mat_relief_gold, parent)

# Podium 2 (right of altar) with crystal
box("pod_R_b", (1.5, 7.0, 0.20), (0.9, 0.9, 0.40), mat_pillar, parent)
box("pod_R_c", (1.5, 7.0, 0.55), (0.7, 0.7, 0.10), mat_pillar_glow, parent)
# crystal cluster
for i, (dx, dy, sz, h) in enumerate([(0,0,0.10,0.5),(0.10,0.05,0.07,0.35),(-0.08,0.06,0.06,0.30),(0.04,-0.10,0.06,0.32)]):
    cone(f"pod_R_cr_{i}", (1.5+dx, 7.0+dy, 0.65+h/2), sz, sz*0.3, h, mat_crystal, parent, verts=8)

# Central altar brazier at very back
box("alt_base", (0, 7.5, 0.30), (1.6, 0.6, 0.60), mat_pillar, parent)
box("alt_top",  (0, 7.5, 0.65), (1.8, 0.8, 0.10), mat_pillar_glow, parent)
cyl("brz_b", (0, 7.5, 0.85), 0.50, 0.30, mat_brass_patina, parent, verts=24)
sph("brz_bowl", (0, 7.5, 1.05), 0.50, mat_brass_patina, parent, segs=24)
cyl("brz_water", (0, 7.5, 1.20), 0.45, 0.06, mat_brazier_fire, parent, verts=24)
# fire flames
sph("flame_1", (0, 7.5, 1.45), 0.20, mat_brazier_fire, parent, segs=14)
sph("flame_2", (-0.10, 7.5, 1.55), 0.12, mat_brazier_fire, parent, segs=12)
sph("flame_3", (0.10, 7.5, 1.55), 0.12, mat_brazier_fire, parent, segs=12)
sph("flame_4", (0, 7.5, 1.75), 0.10, mat_brazier_fire, parent, segs=10)

# Brazier point light
bpy.ops.object.light_add(type='POINT', location=(0, 7.5, 1.6))
bp = bpy.context.object; bp.data.energy = 1500; bp.data.color = (1.0, 0.55, 0.20)

# Floating relief on back wall — large gold sun glyph
tor("relief_outer", (0, HALL_LEN/2 + 0.05, 4.0), 1.4, 0.12, mat_relief_gold, parent, ms=48, mn=16)
tor("relief_inner", (0, HALL_LEN/2 + 0.05, 4.0), 0.9, 0.08, mat_relief_gold, parent, ms=36, mn=14)
# 8 sun rays
for i in range(8):
    ang = i * math.pi/4
    rx = math.cos(ang) * 1.7
    rz = 4.0 + math.sin(ang) * 1.7
    box(f"relief_ray_{i}", (rx, HALL_LEN/2 + 0.05, rz), (0.10, 0.04, 0.40), mat_relief_gold, parent, rot=(0, ang + math.pi/2, 0))
sph("relief_center", (0, HALL_LEN/2 + 0.05, 4.0), 0.30, mat_glyph_glow, parent)

# ============================================================
# LIGHTING — high warm sunset shafts + brazier accent
# ============================================================
# Main key — high front sun coming down from ceiling at front
bpy.ops.object.light_add(type='SPOT', location=(0, -8, CEIL_H + 1))
key = bpy.context.object
key.data.energy = 5000; key.data.color = (1.0, 0.78, 0.40)
key.data.spot_size = math.radians(70)
key.data.spot_blend = 0.35
key.rotation_euler = (math.pi - 0.2, 0, 0)

# Side warm fill
bpy.ops.object.light_add(type='AREA', location=(-5, 0, 4))
fl = bpy.context.object; fl.data.energy = 600; fl.data.color = (1.0, 0.65, 0.35); fl.data.size = 8

# Cool counter rim
bpy.ops.object.light_add(type='AREA', location=(5, 0, 4))
fr = bpy.context.object; fr.data.energy = 400; fr.data.color = (0.45, 0.55, 0.85); fr.data.size = 8

# Back glow from relief
bpy.ops.object.light_add(type='POINT', location=(0, HALL_LEN/2 - 0.5, 4.0))
br = bpy.context.object; br.data.energy = 600; br.data.color = (1.0, 0.85, 0.40)

# ============================================================
# CAMERAS
# ============================================================
def add_cam(name, loc, target, lens=35, dof_dist=10):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = 4.0
    c.data.dof.focus_distance = dof_dist
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_main   = add_cam("cam_hall",   Vector((0, -8.5, 2.0)), Vector((0, 7, 2.5)), lens=28, dof_dist=14)
cam_pillar = add_cam("cam_pillar", Vector((0, -3.5, 1.6)), Vector((-2.4, 0, 2.0)), lens=70, dof_dist=4)
cam_altar  = add_cam("cam_altar",  Vector((0, 4.5, 1.8)),  Vector((0, 7.5, 1.6)), lens=60, dof_dist=4)

CAMERAS = [
    ("hall",   cam_main, (1920, 1080)),
    ("pillar", cam_pillar, (1280, 960)),
    ("altar",  cam_altar, (1280, 960)),
]

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render
for name, cam, (w, h) in CAMERAS:
    scene.camera = cam
    scene.render.resolution_x = w
    scene.render.resolution_y = h
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_memory_vaults_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Export GLB
bpy.ops.object.select_all(action='DESELECT')
parent.select_set(True)
for child in parent.children_recursive:
    child.select_set(True)
out_path = os.path.join(EXPORT_DIR, "memory_vaults_v3.glb")
bpy.ops.export_scene.gltf(
    filepath=out_path, use_selection=True,
    export_format='GLB', export_apply=True
)
print(f"Exported: {out_path}")

print("=== V3 Epic 14 Memory Vaults Biome complete ===")
