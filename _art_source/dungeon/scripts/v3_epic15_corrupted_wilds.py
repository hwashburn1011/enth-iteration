"""
Expansion V3 — Epic 15 — Corrupted Wilds Biome Texture Pass
============================================================
Third dungeon biome — twisted corrupted forest. Trailer-grade hero scene.

Layout: 20x20 unit corrupted wilds glade with:
  - Displaced corrupted soil terrain (subdivided plane + noise displacement)
  - 6 twisted dead trees with gnarled bark + purple glow tendrils
  - 4 mire pools (toxic green water with ripple shader)
  - 12 glowing fungi clusters (purple + cyan bioluminescent)
  - 8 thorn vines crawling along ground
  - 6 floating corruption mote spheres
  - Central altar of corruption (broken stone + crystal)
  - Volumetric purple haze + cyan key + warm rim
  - Hosek-Wilkie sky for backdrop

Outputs:
  - 1 hero glade render @ 1920x1080
  - 1 fungi close-up @ 1280x960
  - 1 altar render @ 1280x960
  - 1 GLB export
"""
import bpy, bmesh, math, os, random
from mathutils import Vector, noise as bnoise

random.seed(15)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/v3_corrupted_wilds.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/exports"
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 48
scene.cycles.use_denoising = True
scene.cycles.volume_step_rate = 8.0
scene.cycles.volume_max_steps = 64
scene.render.resolution_x = 1600
scene.render.resolution_y = 900
scene.view_settings.look = 'AgX - High Contrast'

# Volumetric purple corruption haze
scene.world = bpy.data.worlds.new("v3_cw_world")
scene.world.use_nodes = True
wnt = scene.world.node_tree
wnt.nodes.clear()
wout = wnt.nodes.new("ShaderNodeOutputWorld")
wbg = wnt.nodes.new("ShaderNodeBackground")
wbg.inputs["Color"].default_value = (0.04, 0.02, 0.06, 1)
wbg.inputs["Strength"].default_value = 0.4
wnt.links.new(wbg.outputs[0], wout.inputs[0])
# NOTE: world volumetrics removed for render performance — atmosphere
# is delivered via dense purple emissive lights and ground glow
# vol = wnt.nodes.new("ShaderNodeVolumeScatter")
# vol.inputs["Color"].default_value = (0.55, 0.25, 0.85, 1)
# vol.inputs["Density"].default_value = 0.006
# wnt.links.new(vol.outputs[0], wout.inputs["Volume"])

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
        ar.color_ramp.elements[0].color = (0.05,0.02,0.06,1)
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

def make_corrupted_soil():
    """Soil with purple veins via voronoi mask + emission seams."""
    m = bpy.data.materials.new("v3cw_soil")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Roughness"].default_value = 0.92
    bsdf.inputs["Emission Strength"].default_value = 2.0
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (3, 3, 3)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Base soil noise
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
    n.inputs["Scale"].default_value = 6.0
    n.inputs["Detail"].default_value = 8.0
    n.inputs["Roughness"].default_value = 0.7
    links.new(mp.outputs["Vector"], n.inputs["Vector"])
    soil_ramp = nodes.new("ShaderNodeValToRGB"); soil_ramp.location = (-450, 200)
    soil_ramp.color_ramp.elements[0].position = 0.30
    soil_ramp.color_ramp.elements[0].color = (0.06, 0.04, 0.10, 1)
    soil_ramp.color_ramp.elements[1].position = 0.70
    soil_ramp.color_ramp.elements[1].color = (0.18, 0.10, 0.22, 1)
    links.new(n.outputs["Fac"], soil_ramp.inputs["Fac"])

    # Voronoi cracks (Distance feature)
    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-700, -100)
    v.feature = 'DISTANCE_TO_EDGE'
    v.inputs["Scale"].default_value = 4.0
    links.new(mp.outputs["Vector"], v.inputs["Vector"])
    crack_ramp = nodes.new("ShaderNodeValToRGB"); crack_ramp.location = (-450, -100)
    crack_ramp.color_ramp.elements[0].position = 0.0
    crack_ramp.color_ramp.elements[0].color = (1, 1, 1, 1)
    crack_ramp.color_ramp.elements[1].position = 0.10
    crack_ramp.color_ramp.elements[1].color = (0, 0, 0, 1)
    links.new(v.outputs["Distance"], crack_ramp.inputs["Fac"])

    # Mix soil with crack mask -> dark veins
    mix = nodes.new("ShaderNodeMix"); mix.data_type='RGBA'; mix.location = (-200, 100)
    links.new(crack_ramp.outputs["Color"], mix.inputs["Factor"])
    links.new(soil_ramp.outputs["Color"], mix.inputs[6])
    mix.inputs[7].default_value = (0.04, 0.02, 0.08, 1)
    links.new(mix.outputs[2], bsdf.inputs["Base Color"])

    # Crack glow emission
    glow = nodes.new("ShaderNodeMix"); glow.data_type='RGBA'; glow.location = (100, -100)
    links.new(crack_ramp.outputs["Color"], glow.inputs["Factor"])
    glow.inputs[6].default_value = (0, 0, 0, 1)
    glow.inputs[7].default_value = (0.85, 0.30, 1.0, 1)
    links.new(glow.outputs[2], bsdf.inputs["Emission Color"])

    # Bump from soil noise
    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -300)
    bp.inputs["Strength"].default_value = 0.5
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_mire_water():
    """Toxic mire pool with ripple shader + emission."""
    m = bpy.data.materials.new("v3cw_mire")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1200, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (900, 0)
    bsdf.inputs["Base Color"].default_value = (0.10, 0.30, 0.10, 1)
    bsdf.inputs["Roughness"].default_value = 0.10
    bsdf.inputs["Transmission Weight"].default_value = 0.4
    bsdf.inputs["IOR"].default_value = 1.4
    bsdf.inputs["Emission Color"].default_value = (0.30, 0.85, 0.30, 1)
    bsdf.inputs["Emission Strength"].default_value = 2.5
    links.new(bsdf.outputs[0], out.inputs[0])

    # Ripple normal
    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-900, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-700, 0)
    mp.inputs["Scale"].default_value = (5, 5, 5)
    links.new(tc.outputs["Object"], mp.inputs["Vector"])
    # concentric rings via wave
    wave = nodes.new("ShaderNodeTexWave"); wave.location = (-450, 0)
    wave.wave_type = 'RINGS'
    wave.inputs["Scale"].default_value = 8.0
    wave.inputs["Distortion"].default_value = 3.0
    links.new(mp.outputs["Vector"], wave.inputs["Vector"])
    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, 0)
    bp.inputs["Strength"].default_value = 0.4
    links.new(wave.outputs["Color"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

# ============================================================
# MATERIALS
# ============================================================
mat_soil = make_corrupted_soil()
mat_mire = make_mire_water()
mat_bark_twisted = make_pbr("v3cw_bark_twisted", (0.10,0.05,0.10), 0.95,
    noise_strength=0.40, voronoi_strength=0.65, voronoi_scale=10.0, bump_strength=0.55, bump_scale=12.0)
mat_bark_glow = make_pbr("v3cw_bark_glow", (0.20,0.08,0.30), 0.65, 0,
    emission_color=(0.85,0.30,1.0), emission_strength=2.5,
    noise_strength=0.30, voronoi_strength=0.50, voronoi_scale=12.0,
    curvature_dirt=True, fresnel_rim=True, bump_strength=0.40, bump_scale=14.0)
mat_canopy_dead = make_pbr("v3cw_canopy_dead", (0.18,0.08,0.22), 0.95,
    noise_strength=0.40, curvature_dirt=True, bump_strength=0.30, bump_scale=40.0)
mat_fungi_purple = make_pbr("v3cw_fungi_purple", (0.65,0.20,0.95), 0.30, 0,
    emission_color=(0.85,0.30,1.0), emission_strength=8.0,
    noise_strength=0.20, curvature_dirt=False, fresnel_rim=True, bump_strength=0.20, bump_scale=80.0)
mat_fungi_cyan = make_pbr("v3cw_fungi_cyan", (0.30,0.85,1.0), 0.30, 0,
    emission_color=(0.40,0.95,1.0), emission_strength=8.0,
    noise_strength=0.20, curvature_dirt=False, fresnel_rim=True, bump_strength=0.20, bump_scale=80.0)
mat_fungi_stem = make_pbr("v3cw_fungi_stem", (0.45,0.32,0.35), 0.85,
    noise_strength=0.30, voronoi_strength=0.20, voronoi_scale=40.0, bump_strength=0.25, bump_scale=80.0)
mat_thorn = make_pbr("v3cw_thorn", (0.10,0.05,0.05), 0.85,
    emission_color=(0.85,0.20,0.50), emission_strength=0.4,
    noise_strength=0.30, voronoi_strength=0.45, voronoi_scale=18.0, fresnel_rim=True,
    bump_strength=0.30, bump_scale=22.0)
mat_corruption_mote = make_pbr("v3cw_mote", (0.85,0.30,1.0), 0.10, 0,
    emission_color=(0.95,0.45,1.0), emission_strength=14.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mat_altar_stone = make_pbr("v3cw_altar", (0.18,0.10,0.20), 0.85,
    emission_color=(0.55,0.20,0.85), emission_strength=0.6,
    noise_strength=0.35, voronoi_strength=0.55, voronoi_scale=10.0,
    curvature_dirt=True, fresnel_rim=True, bump_strength=0.40, bump_scale=14.0)
mat_altar_crystal = make_pbr("v3cw_crystal", (0.65,0.20,0.95), 0.10, 0,
    emission_color=(0.85,0.30,1.0), emission_strength=12.0,
    noise_strength=0.10, curvature_dirt=False, fresnel_rim=True, bump_strength=0.05)
mat_root = make_pbr("v3cw_root", (0.08,0.04,0.08), 0.95,
    emission_color=(0.85,0.30,1.0), emission_strength=0.4,
    noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=14.0,
    fresnel_rim=True, bump_strength=0.40, bump_scale=18.0)

# ============================================================
# UTIL
# ============================================================
def add_subsurf_bevel(obj, levels=2, bevel=0.025):
    s = obj.modifiers.new("Subsurf", 'SUBSURF'); s.levels = levels; s.render_levels = levels+1
    b = obj.modifiers.new("Bevel", 'BEVEL'); b.width = bevel; b.segments = 3; b.profile = 0.7
    for poly in obj.data.polygons: poly.use_smooth = True

def cyl(name, loc, r, depth, mat, parent, verts=14, rot=(0,0,0)):
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

def ico(name, loc, r, mat, parent, sub=2):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=sub, radius=r, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=2, bevel=0.005)
    o.parent = parent
    return o

def cone(name, loc, r1, r2, depth, mat, parent, verts=14, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.01)
    o.parent = parent
    return o

# ============================================================
# SCENE
# ============================================================
parent = bpy.data.objects.new("v3_corrupted_wilds", None); scene.collection.objects.link(parent)

# Displaced terrain — 20x20 plane subdivided
TERRAIN = 20
SUB = 50
bpy.ops.mesh.primitive_plane_add(size=TERRAIN, location=(0,0,0))
terrain = bpy.context.object
terrain.name = "cw_terrain"
bm = bmesh.new()
bm.from_mesh(terrain.data)
bmesh.ops.subdivide_edges(bm, edges=bm.edges, cuts=SUB, use_grid_fill=True)
bm.to_mesh(terrain.data)
bm.free()
terrain.data.update()

for v in terrain.data.vertices:
    x, y = v.co.x, v.co.y
    h  = bnoise.noise(Vector((x*0.10, y*0.10, 0))) * 1.2
    h += bnoise.noise(Vector((x*0.30, y*0.30, 5))) * 0.5
    h += bnoise.noise(Vector((x*0.60, y*0.60, 10))) * 0.2
    # carved central altar mound — raise center slightly
    d = math.sqrt(x*x + y*y)
    if d < 2.5:
        h += (2.5 - d) * 0.6
    v.co.z = h

terrain.data.materials.append(mat_soil)
for poly in terrain.data.polygons: poly.use_smooth = True

# helper to sample terrain height at a point
def terrain_h(x, y):
    h  = bnoise.noise(Vector((x*0.10, y*0.10, 0))) * 1.2
    h += bnoise.noise(Vector((x*0.30, y*0.30, 5))) * 0.5
    h += bnoise.noise(Vector((x*0.60, y*0.60, 10))) * 0.2
    d = math.sqrt(x*x + y*y)
    if d < 2.5:
        h += (2.5 - d) * 0.6
    return h

# ============================================================
# TWISTED DEAD TREES — 6 with gnarled bark + glow tendrils
# ============================================================
def twisted_tree(name, x, y, parent):
    base_z = terrain_h(x, y)
    trunk_h = random.uniform(3.5, 5.0)
    # main trunk — slightly tilted + tapered cylinder
    trunk = cyl(f"{name}_t", (x, y, base_z + trunk_h/2), 0.30, trunk_h, mat_bark_twisted, parent, verts=14)
    trunk.rotation_euler = (random.uniform(-0.15, 0.15), random.uniform(-0.15, 0.15), 0)
    # 5 secondary branches at top, twisted
    for i in range(5):
        ang = i * (math.pi*2/5) + random.uniform(-0.2, 0.2)
        bx = x + math.cos(ang) * 0.3
        by = y + math.sin(ang) * 0.3
        bz = base_z + trunk_h - 0.2
        b = cyl(f"{name}_b_{i}", (bx, by, bz + 0.7), 0.10, 1.5, mat_bark_twisted, parent, verts=10,
                 rot=(0.5 + math.sin(ang)*0.3, math.cos(ang)*0.3, ang))
        # 3 finger twigs each
        for j in range(3):
            tang = ang + (j-1) * 0.3
            tx = bx + math.cos(tang) * 0.5
            ty = by + math.sin(tang) * 0.5
            tz = bz + 1.2 + j * 0.2
            cyl(f"{name}_b_{i}_t_{j}", (tx, ty, tz), 0.04, 0.6, mat_bark_twisted, parent, verts=6,
                 rot=(0.7 + j*0.2, 0, tang))
    # purple glow tendril growths along trunk
    for i in range(4):
        ang = i * (math.pi*2/4) + 0.3
        gx = x + math.cos(ang) * 0.32
        gy = y + math.sin(ang) * 0.32
        gz = base_z + 0.6 + i * 0.4
        ico(f"{name}_g_{i}", (gx, gy, gz), 0.10, mat_bark_glow, parent)
    # exposed roots at base
    for i in range(5):
        ang = i * (math.pi*2/5)
        rx = x + math.cos(ang) * 0.45
        ry = y + math.sin(ang) * 0.45
        cyl(f"{name}_r_{i}", (rx, ry, base_z + 0.10), 0.08, 0.6, mat_root, parent, verts=8,
             rot=(math.pi/2 + 0.3, 0, ang))

# 6 trees scattered around the edges
TREE_POSITIONS = [(-7, -6), (-8, 5), (-2, 8), (4, 7), (8, -2), (6, -7)]
for i, (x, y) in enumerate(TREE_POSITIONS):
    twisted_tree(f"tree_{i}", x, y, parent)

# ============================================================
# MIRE POOLS — 4 toxic pools
# ============================================================
def mire_pool(name, x, y, r, parent):
    # the pool is a flat disc slightly above terrain (the displacement creates depressions, but
    # we add an explicit pool plane)
    base_z = terrain_h(x, y)
    cyl(f"{name}_p", (x, y, base_z + 0.10), r, 0.04, mat_mire, parent, verts=32)
    # rim of slightly raised dark soil
    cyl(f"{name}_rim", (x, y, base_z + 0.05), r * 1.10, 0.02, mat_bark_twisted, parent, verts=32)

mire_pool("mire_0", -4, -3, 0.8, parent)
mire_pool("mire_1",  3,  4, 1.0, parent)
mire_pool("mire_2",  5, -5, 0.7, parent)
mire_pool("mire_3", -6,  2, 0.9, parent)

# ============================================================
# GLOWING FUNGI CLUSTERS — 12 across scene
# ============================================================
def fungi_cluster(name, x, y, parent):
    base_z = terrain_h(x, y)
    color_mat = random.choice([mat_fungi_purple, mat_fungi_cyan])
    # 3-5 mushrooms in cluster
    for i in range(random.randint(3, 5)):
        ang = i * (math.pi*2 / 5)
        sx = x + math.cos(ang) * 0.15
        sy = y + math.sin(ang) * 0.15
        h = random.uniform(0.20, 0.45)
        cyl(f"{name}_{i}_st", (sx, sy, base_z + h/2 + 0.05), 0.04, h, mat_fungi_stem, parent, verts=10)
        cap_z = base_z + h + 0.05
        if random.random() < 0.5:
            # round cap
            cap = sph(f"{name}_{i}_cap", (sx, sy, cap_z), 0.14, color_mat, parent, segs=16)
            cap.scale.z = 0.7
        else:
            # pointed cap
            cone(f"{name}_{i}_cap", (sx, sy, cap_z + 0.04), 0.13, 0.04, 0.20, color_mat, parent, verts=14)

# 12 clusters scattered
random.seed(15)
FUNGI_POSITIONS = [(-3, 1), (1, -2), (4, 0), (-1, 5), (-5, -1), (2, 7),
                   (-8, 0), (7, 2), (0, -6), (-2, -8), (5, 5), (-7, 7)]
for i, (x, y) in enumerate(FUNGI_POSITIONS):
    fungi_cluster(f"fg_{i}", x, y, parent)

# ============================================================
# THORN VINES — 8 crawling along ground
# ============================================================
def thorn_vine(name, x, y, length, angle, parent):
    base_z = terrain_h(x, y)
    # 6 segments
    for i in range(6):
        sx = x + math.cos(angle) * (i * length/6)
        sy = y + math.sin(angle) * (i * length/6)
        sz = terrain_h(sx, sy) + 0.06 + math.sin(i * 0.8) * 0.05
        cyl(f"{name}_s_{i}", (sx, sy, sz), 0.05, length/6 * 1.1, mat_thorn, parent, verts=8,
             rot=(0, math.pi/2, angle + math.sin(i)*0.2))
        # thorn spike at each segment
        if i % 2 == 0:
            cone(f"{name}_th_{i}", (sx, sy, sz + 0.10), 0.025, 0.0, 0.10, mat_thorn, parent, verts=5)

THORN_LAYOUTS = [
    (-3, -5, 2.5, 0.5),
    (4, -4, 2.0, 1.8),
    (-5, 3, 2.2, 2.5),
    (3, 6, 2.0, 4.0),
    (7, 0, 2.4, 3.2),
    (-7, -2, 2.0, 0.0),
    (1, 4, 2.0, 1.0),
    (-1, -3, 1.8, 5.4),
]
for i, (x, y, l, a) in enumerate(THORN_LAYOUTS):
    thorn_vine(f"th_{i}", x, y, l, a, parent)

# ============================================================
# FLOATING CORRUPTION MOTES — 8 across scene
# ============================================================
MOTE_POSITIONS = [(-3, -4, 1.8), (2, 3, 2.2), (5, -2, 1.4), (-5, 1, 1.6),
                  (1, 6, 2.5), (6, 4, 1.9), (-7, -3, 2.0), (-1, -7, 1.5)]
for i, (x, y, z) in enumerate(MOTE_POSITIONS):
    sph(f"mote_{i}", (x, y, terrain_h(x,y) + z), 0.07, mat_corruption_mote, parent, segs=14)

# ============================================================
# CENTRAL CORRUPTION ALTAR
# ============================================================
ax, ay = 0, 0
az = terrain_h(ax, ay)
# stepped base
cyl("alt_b1", (ax, ay, az + 0.20), 1.2, 0.40, mat_altar_stone, parent, verts=20)
cyl("alt_b2", (ax, ay, az + 0.55), 1.0, 0.30, mat_altar_stone, parent, verts=20)
cyl("alt_b3", (ax, ay, az + 0.85), 0.8, 0.30, mat_altar_stone, parent, verts=20)
# central crystal cluster
for i, (dx, dy, sz, h) in enumerate([(0,0,0.20,1.4),(0.18,0.10,0.14,1.0),(-0.15,0.10,0.13,0.95),(0.10,-0.20,0.16,1.1),(-0.10,-0.10,0.10,0.7)]):
    cone(f"alt_cr_{i}", (ax+dx, ay+dy, az + 1.05 + h/2), sz, sz*0.25, h, mat_altar_crystal, parent, verts=8,
         rot=(random.uniform(-0.15, 0.15), random.uniform(-0.15, 0.15), random.uniform(0, math.pi*2)))
# floating cracked stones around altar
for i in range(6):
    ang = i * (math.pi*2/6)
    sx = ax + math.cos(ang) * 1.8
    sy = ay + math.sin(ang) * 1.8
    sz_pos = az + 1.4 + math.sin(ang*2) * 0.3
    fr = ico(f"alt_fr_{i}", (sx, sy, sz_pos), 0.20, mat_altar_stone, parent)
    fr.scale = (1.2, 0.8, 0.6)
    fr.rotation_euler = (ang, ang*0.5, ang*0.3)

# Strong purple point light at altar
bpy.ops.object.light_add(type='POINT', location=(0, 0, 1.8))
ap = bpy.context.object
ap.data.energy = 1500; ap.data.color = (0.85, 0.30, 1.0)

# ============================================================
# LIGHTING
# ============================================================
# Cyan key from above-front
bpy.ops.object.light_add(type='SPOT', location=(6, -10, 12))
key = bpy.context.object
key.data.energy = 4500; key.data.color = (0.45, 0.65, 1.0)
key.data.spot_size = math.radians(80)
key.data.spot_blend = 0.4
direction = Vector((0,0,0)) - key.location
key.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

# Warm orange rim from back
bpy.ops.object.light_add(type='AREA', location=(-8, 8, 6))
rim = bpy.context.object
rim.data.energy = 800; rim.data.color = (1.0, 0.45, 0.20); rim.data.size = 8

# Soft purple fill from below
bpy.ops.object.light_add(type='AREA', location=(0, -6, 1))
fl = bpy.context.object
fl.data.energy = 200; fl.data.color = (0.65, 0.30, 0.95); fl.data.size = 6

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

cam_main   = add_cam("cam_glade", Vector((10, -12, 6.5)), Vector((0, 0, 1.5)), lens=35, dof_dist=15)
cam_fungi  = add_cam("cam_fungi", Vector((-2, -1, 1.0)),  Vector((-3, 1, 0.5)), lens=70, dof_dist=2)
cam_altar  = add_cam("cam_altar", Vector((3, -3, 2.5)),   Vector((0, 0, 2.0)), lens=50, dof_dist=4)

CAMERAS = [
    ("glade", cam_main, (1920, 1080)),
    ("fungi", cam_fungi, (1280, 960)),
    ("altar", cam_altar, (1280, 960)),
]

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render
for name, cam, (w, h) in CAMERAS:
    scene.camera = cam
    scene.render.resolution_x = w
    scene.render.resolution_y = h
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_corrupted_wilds_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Export GLB
bpy.ops.object.select_all(action='DESELECT')
parent.select_set(True)
for child in parent.children_recursive:
    child.select_set(True)
terrain.select_set(True)
out_path = os.path.join(EXPORT_DIR, "corrupted_wilds_v3.glb")
bpy.ops.export_scene.gltf(
    filepath=out_path, use_selection=True,
    export_format='GLB', export_apply=True
)
print(f"Exported: {out_path}")

print("=== V3 Epic 15 Corrupted Wilds Biome complete ===")
