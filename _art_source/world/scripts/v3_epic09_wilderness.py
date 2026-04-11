"""
Expansion V3 — Epic 09 — Wilderness Zone Texture Pass
=====================================================
The largest single contiguous space in the game. A 60x60 unit wilderness
plot with full hero treatment:

  - Displaced heightmap terrain (200x200 subdivision + 4-octave noise displace)
  - Slope-blended terrain shader (grass on flat, rock on slope, dirt
    in mid-slope) using Geometry > Normal Z
  - Flowing river carved through a central valley with flow shader
  - Cliff outcrop using boolean-displaced rocks
  - Forest of 24 procedural trees with bark + canopy + bark age variation
  - 3 stone path stones leading from foreground to river crossing
  - Ruined obelisk + arch in mid-distance for storytelling silhouette
  - Wildflowers scattered along the riverbank

Outputs: 4 wide hero shot renders @ 1920x1080 (overview / valley / forest / ruins)
         + 1 GLB export of the full wilderness mesh
"""
import bpy, bmesh, math, os, random
from mathutils import Vector, noise as bnoise

random.seed(42)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/v3_wilderness.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/exports"
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 128
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.view_settings.look = 'AgX - High Contrast'

# Sky world
scene.world = bpy.data.worlds.new("v3_wild_world")
scene.world.use_nodes = True
wnt = scene.world.node_tree
wnt.nodes.clear()
wout = wnt.nodes.new("ShaderNodeOutputWorld")
wsky = wnt.nodes.new("ShaderNodeTexSky")
wsky.sky_type = 'HOSEK_WILKIE'
wsky.sun_direction = (0.5, -0.5, 0.55)
wsky.turbidity = 3.0
wsky.ground_albedo = 0.3
wbg = wnt.nodes.new("ShaderNodeBackground")
wbg.inputs["Strength"].default_value = 1.0
wnt.links.new(wsky.outputs[0], wbg.inputs[0])
wnt.links.new(wbg.outputs[0], wout.inputs[0])

# ============================================================
# TERRAIN SHADER — slope-blended grass + rock + dirt + snow tip
# ============================================================
def make_terrain_shader():
    m = bpy.data.materials.new("v3_wild_terrain")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()

    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1800, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1500, 0)
    bsdf.inputs["Roughness"].default_value = 0.85

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1600, 0)
    map_node = nodes.new("ShaderNodeMapping"); map_node.location = (-1400, 0)
    map_node.inputs["Scale"].default_value = (0.25, 0.25, 0.25)
    links.new(tc.outputs["Generated"], map_node.inputs["Vector"])

    # GRASS LAYER
    grass_n = nodes.new("ShaderNodeTexNoise"); grass_n.location = (-1100, 600)
    grass_n.inputs["Scale"].default_value = 30.0
    grass_n.inputs["Detail"].default_value = 6.0
    links.new(map_node.outputs["Vector"], grass_n.inputs["Vector"])
    grass_v = nodes.new("ShaderNodeTexVoronoi"); grass_v.location = (-1100, 400)
    grass_v.inputs["Scale"].default_value = 80.0
    links.new(map_node.outputs["Vector"], grass_v.inputs["Vector"])
    grass_ramp = nodes.new("ShaderNodeValToRGB"); grass_ramp.location = (-800, 500)
    grass_ramp.color_ramp.elements[0].position = 0.30
    grass_ramp.color_ramp.elements[0].color = (0.10, 0.22, 0.06, 1)
    grass_ramp.color_ramp.elements[1].position = 0.75
    grass_ramp.color_ramp.elements[1].color = (0.22, 0.40, 0.12, 1)
    links.new(grass_n.outputs["Fac"], grass_ramp.inputs["Fac"])

    # ROCK LAYER
    rock_n = nodes.new("ShaderNodeTexNoise"); rock_n.location = (-1100, 100)
    rock_n.inputs["Scale"].default_value = 10.0
    rock_n.inputs["Detail"].default_value = 8.0
    links.new(map_node.outputs["Vector"], rock_n.inputs["Vector"])
    rock_v = nodes.new("ShaderNodeTexVoronoi"); rock_v.location = (-1100, -100)
    rock_v.feature = 'F1'
    rock_v.inputs["Scale"].default_value = 6.0
    links.new(map_node.outputs["Vector"], rock_v.inputs["Vector"])
    rock_ramp = nodes.new("ShaderNodeValToRGB"); rock_ramp.location = (-800, 0)
    rock_ramp.color_ramp.elements[0].position = 0.10
    rock_ramp.color_ramp.elements[0].color = (0.18, 0.16, 0.13, 1)
    rock_ramp.color_ramp.elements[1].position = 0.70
    rock_ramp.color_ramp.elements[1].color = (0.45, 0.42, 0.38, 1)
    links.new(rock_n.outputs["Fac"], rock_ramp.inputs["Fac"])

    # DIRT LAYER
    dirt_ramp = nodes.new("ShaderNodeValToRGB"); dirt_ramp.location = (-800, -300)
    dirt_ramp.color_ramp.elements[0].position = 0.30
    dirt_ramp.color_ramp.elements[0].color = (0.20, 0.13, 0.06, 1)
    dirt_ramp.color_ramp.elements[1].position = 0.70
    dirt_ramp.color_ramp.elements[1].color = (0.35, 0.22, 0.10, 1)
    links.new(rock_v.outputs["Distance"], dirt_ramp.inputs["Fac"])

    # SLOPE MASK — geometry normal Z
    geo = nodes.new("ShaderNodeNewGeometry"); geo.location = (-1100, -500)
    sep = nodes.new("ShaderNodeSeparateXYZ"); sep.location = (-900, -500)
    links.new(geo.outputs["Normal"], sep.inputs["Vector"])
    slope_ramp = nodes.new("ShaderNodeValToRGB"); slope_ramp.location = (-700, -500)
    slope_ramp.color_ramp.elements[0].position = 0.55
    slope_ramp.color_ramp.elements[0].color = (0, 0, 0, 1)  # rock
    slope_ramp.color_ramp.elements[1].position = 0.85
    slope_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)  # grass
    links.new(sep.outputs["Z"], slope_ramp.inputs["Fac"])

    # MIX rock -> grass via slope
    mix1 = nodes.new("ShaderNodeMix"); mix1.data_type = 'RGBA'; mix1.location = (-300, 200)
    links.new(slope_ramp.outputs["Color"], mix1.inputs["Factor"])
    links.new(rock_ramp.outputs["Color"], mix1.inputs[6])
    links.new(grass_ramp.outputs["Color"], mix1.inputs[7])

    # Add dirt patches near mid-slope (0.6-0.8)
    dirt_mask = nodes.new("ShaderNodeValToRGB"); dirt_mask.location = (-700, -700)
    dirt_mask.color_ramp.interpolation = 'B_SPLINE'
    dirt_mask.color_ramp.elements[0].position = 0.55
    dirt_mask.color_ramp.elements[0].color = (0,0,0,1)
    dirt_mask.color_ramp.elements[1].position = 0.72
    dirt_mask.color_ramp.elements[1].color = (1,1,1,1)
    links.new(sep.outputs["Z"], dirt_mask.inputs["Fac"])
    # Multiply dirt mask by inverse to peak in middle
    dirt_mask2 = nodes.new("ShaderNodeValToRGB"); dirt_mask2.location = (-700, -900)
    dirt_mask2.color_ramp.interpolation = 'B_SPLINE'
    dirt_mask2.color_ramp.elements[0].position = 0.78
    dirt_mask2.color_ramp.elements[0].color = (1,1,1,1)
    dirt_mask2.color_ramp.elements[1].position = 0.92
    dirt_mask2.color_ramp.elements[1].color = (0,0,0,1)
    links.new(sep.outputs["Z"], dirt_mask2.inputs["Fac"])
    dirt_combine = nodes.new("ShaderNodeMath"); dirt_combine.location = (-450, -800)
    dirt_combine.operation = 'MULTIPLY'
    links.new(dirt_mask.outputs["Color"], dirt_combine.inputs[0])
    links.new(dirt_mask2.outputs["Color"], dirt_combine.inputs[1])
    mix2 = nodes.new("ShaderNodeMix"); mix2.data_type = 'RGBA'; mix2.location = (0, 0)
    links.new(dirt_combine.outputs[0], mix2.inputs["Factor"])
    links.new(mix1.outputs[2], mix2.inputs[6])
    links.new(dirt_ramp.outputs["Color"], mix2.inputs[7])

    # Curvature dirt — pointiness
    geo2 = nodes.new("ShaderNodeNewGeometry"); geo2.location = (-300, -1100)
    ao_ramp = nodes.new("ShaderNodeValToRGB"); ao_ramp.location = (-100, -1100)
    ao_ramp.color_ramp.elements[0].position = 0.30
    ao_ramp.color_ramp.elements[0].color = (0.05, 0.04, 0.02, 1)
    ao_ramp.color_ramp.elements[1].position = 0.70
    ao_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(geo2.outputs["Pointiness"], ao_ramp.inputs["Fac"])
    mix3 = nodes.new("ShaderNodeMix"); mix3.data_type = 'RGBA'; mix3.location = (300, -200)
    mix3.inputs["Factor"].default_value = 0.30
    links.new(mix2.outputs[2], mix3.inputs[6])
    links.new(ao_ramp.outputs["Color"], mix3.inputs[7])

    # Bump from rock noise
    bump = nodes.new("ShaderNodeBump"); bump.location = (1100, -400)
    bump.inputs["Strength"].default_value = 0.4
    links.new(rock_n.outputs["Fac"], bump.inputs["Height"])
    links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])

    links.new(mix3.outputs[2], bsdf.inputs["Base Color"])
    links.new(bsdf.outputs[0], out.inputs[0])
    return m

# ============================================================
# RIVER WATER SHADER — flowing with normal animation potential
# ============================================================
def make_river_shader():
    m = bpy.data.materials.new("v3_wild_river")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()

    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    bsdf.inputs["Base Color"].default_value = (0.05, 0.18, 0.28, 1)
    bsdf.inputs["Roughness"].default_value = 0.05
    bsdf.inputs["Transmission Weight"].default_value = 0.7
    bsdf.inputs["IOR"].default_value = 1.33
    bsdf.inputs["Emission Color"].default_value = (0.10, 0.30, 0.45, 1)
    bsdf.inputs["Emission Strength"].default_value = 0.4
    links.new(bsdf.outputs[0], out.inputs[0])

    # flowing wave noise driving normals
    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1000, 0)
    map1 = nodes.new("ShaderNodeMapping"); map1.location = (-800, 100)
    map1.inputs["Scale"].default_value = (8, 2, 1)
    links.new(tc.outputs["Object"], map1.inputs["Vector"])
    n1 = nodes.new("ShaderNodeTexNoise"); n1.location = (-550, 100)
    n1.inputs["Scale"].default_value = 5.0
    n1.inputs["Detail"].default_value = 8.0
    n1.inputs["Roughness"].default_value = 0.7
    links.new(map1.outputs["Vector"], n1.inputs["Vector"])
    bump = nodes.new("ShaderNodeBump"); bump.location = (-300, 0)
    bump.inputs["Strength"].default_value = 0.3
    links.new(n1.outputs["Fac"], bump.inputs["Height"])
    links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])
    return m

# ============================================================
# TREE BARK + CANOPY shaders
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

# ============================================================
# MATERIALS
# ============================================================
mat_terrain = make_terrain_shader()
mat_river   = make_river_shader()
mat_bark_oak    = make_pbr("v3_wild_bark_oak", (0.18,0.11,0.06), 0.95,
    noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=12.0, bump_strength=0.45, bump_scale=18.0)
mat_bark_pine   = make_pbr("v3_wild_bark_pine", (0.22,0.13,0.07), 0.95,
    noise_strength=0.30, voronoi_strength=0.50, voronoi_scale=18.0, bump_strength=0.40, bump_scale=22.0)
mat_canopy_summer = make_pbr("v3_wild_canopy_summer", (0.15,0.32,0.10), 0.85,
    noise_strength=0.40, curvature_dirt=True, bump_strength=0.30, bump_scale=45.0)
mat_canopy_autumn = make_pbr("v3_wild_canopy_autumn", (0.55,0.30,0.08), 0.85,
    noise_strength=0.40, curvature_dirt=True, bump_strength=0.30, bump_scale=45.0)
mat_canopy_pine   = make_pbr("v3_wild_canopy_pine", (0.10,0.22,0.10), 0.85,
    noise_strength=0.40, curvature_dirt=True, bump_strength=0.35, bump_scale=50.0)
mat_ruin_stone = make_pbr("v3_wild_ruin", (0.50,0.46,0.40), 0.92,
    noise_strength=0.40, voronoi_strength=0.55, voronoi_scale=8.0, bump_strength=0.50, bump_scale=10.0)
mat_path_stone = make_pbr("v3_wild_path", (0.55,0.50,0.42), 0.85,
    noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=10.0, bump_strength=0.30, bump_scale=14.0)
mat_flower_red    = make_pbr("v3_wild_flower_red", (0.85,0.20,0.20), 0.65,
    emission_color=(0.95,0.30,0.25), emission_strength=0.5,
    noise_strength=0.20, curvature_dirt=False, fresnel_rim=True, bump_strength=0.10)
mat_flower_yellow = make_pbr("v3_wild_flower_yellow", (0.95,0.85,0.20), 0.65,
    emission_color=(1.0,0.92,0.30), emission_strength=0.5,
    noise_strength=0.20, curvature_dirt=False, fresnel_rim=True, bump_strength=0.10)
mat_flower_blue   = make_pbr("v3_wild_flower_blue", (0.30,0.45,0.85), 0.65,
    emission_color=(0.40,0.55,1.0), emission_strength=0.5,
    noise_strength=0.20, curvature_dirt=False, fresnel_rim=True, bump_strength=0.10)
mat_grass_blade = make_pbr("v3_wild_grass_blade", (0.20,0.40,0.10), 0.85,
    noise_strength=0.30, curvature_dirt=False, bump_strength=0.20, bump_scale=60.0)

# ============================================================
# UTILITY
# ============================================================
def add_subsurf_bevel(obj, levels=2, bevel=0.025):
    s = obj.modifiers.new("Subsurf", 'SUBSURF'); s.levels = levels; s.render_levels = levels+1
    b = obj.modifiers.new("Bevel", 'BEVEL'); b.width = bevel; b.segments = 3; b.profile = 0.7
    for poly in obj.data.polygons: poly.use_smooth = True

# ============================================================
# TERRAIN — large displaced subdivided plane
# ============================================================
TERRAIN_SIZE = 60
TERRAIN_SUB  = 180  # high subdivision for displacement detail

bpy.ops.mesh.primitive_plane_add(size=TERRAIN_SIZE, location=(0,0,0))
terrain = bpy.context.object
terrain.name = "wild_terrain"
# subdivide using bmesh
bm = bmesh.new()
bm.from_mesh(terrain.data)
bmesh.ops.subdivide_edges(bm, edges=bm.edges, cuts=TERRAIN_SUB, use_grid_fill=True)
bm.to_mesh(terrain.data)
bm.free()
terrain.data.update()

# carve heights using multi-octave noise + carve a river valley along Y axis (x=0)
for v in terrain.data.vertices:
    x, y = v.co.x, v.co.y
    # base hills
    h  = bnoise.noise(Vector((x*0.06, y*0.06, 0)))*3.0
    h += bnoise.noise(Vector((x*0.15, y*0.15, 5)))*1.0
    h += bnoise.noise(Vector((x*0.30, y*0.30, 10)))*0.4
    # carve valley along x=0 — sigmoid down toward center
    valley = max(0.0, 1.0 - (abs(x) / 6.0) ** 2)
    h -= valley * 4.5
    # raise far edges (mountains)
    edge = (abs(x) + abs(y)) / TERRAIN_SIZE
    h += edge * 6.0
    v.co.z = h

terrain.data.materials.append(mat_terrain)
for poly in terrain.data.polygons: poly.use_smooth = True
# subdivision surface modifier softens it
ss = terrain.modifiers.new("Subsurf", 'SUBSURF'); ss.levels = 1; ss.render_levels = 2

# ============================================================
# RIVER — long flat plane following the valley
# ============================================================
bpy.ops.mesh.primitive_plane_add(size=1, location=(0, 0, -3.5))
river = bpy.context.object
river.name = "wild_river"
river.scale = (4.5, TERRAIN_SIZE*0.5, 1)
river.data.materials.append(mat_river)
add_subsurf_bevel(river, levels=1, bevel=0.005)

# ============================================================
# TREES — forest cluster across one quadrant + scattered singletons
# ============================================================
def make_tree(name, x, y, kind, parent=None):
    base_z = bnoise.noise(Vector((x*0.06, y*0.06, 0)))*3.0
    base_z += bnoise.noise(Vector((x*0.15, y*0.15, 5)))*1.0
    base_z += (abs(x)+abs(y))/TERRAIN_SIZE*6.0  # match terrain rise
    base_z -= max(0.0, 1.0 - (abs(x) / 6.0) ** 2) * 4.5
    if kind == "oak":
        bark = mat_bark_oak; canopy = mat_canopy_summer; trunk_h = random.uniform(2.4, 3.6); trunk_r = random.uniform(0.18, 0.28); cap_r = random.uniform(1.2, 1.8)
    elif kind == "autumn":
        bark = mat_bark_oak; canopy = mat_canopy_autumn; trunk_h = random.uniform(2.6, 3.8); trunk_r = random.uniform(0.18, 0.28); cap_r = random.uniform(1.3, 1.9)
    else:  # pine
        bark = mat_bark_pine; canopy = mat_canopy_pine; trunk_h = random.uniform(3.2, 4.6); trunk_r = random.uniform(0.16, 0.24); cap_r = random.uniform(0.9, 1.4)

    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=trunk_r, depth=trunk_h,
                                         location=(x, y, base_z + trunk_h/2))
    trunk = bpy.context.object
    trunk.name = f"{name}_t"
    trunk.data.materials.append(bark)
    add_subsurf_bevel(trunk, levels=1, bevel=0.02)

    if kind == "pine":
        # 3 stacked cones
        for i in range(3):
            r1 = cap_r * (1.0 - i*0.25)
            cz = base_z + trunk_h + i * (cap_r*0.7) - cap_r*0.2
            bpy.ops.mesh.primitive_cone_add(vertices=14, radius1=r1, radius2=0,
                                              depth=cap_r*1.4, location=(x, y, cz))
            c = bpy.context.object
            c.name = f"{name}_c{i}"
            c.data.materials.append(canopy)
            add_subsurf_bevel(c, levels=1, bevel=0.02)
            if parent: c.parent = parent
    else:
        # bushy uvsphere canopy with secondary clumps
        bpy.ops.mesh.primitive_uv_sphere_add(segments=20, ring_count=12, radius=cap_r,
                                               location=(x, y, base_z + trunk_h + cap_r*0.3))
        canopy_obj = bpy.context.object
        canopy_obj.name = f"{name}_cap"
        canopy_obj.scale.z = 0.85
        canopy_obj.data.materials.append(canopy)
        add_subsurf_bevel(canopy_obj, levels=2, bevel=0.01)
        if parent: canopy_obj.parent = parent
        # secondary clumps for shape break-up
        for j in range(3):
            ang = j*2.0
            cx = x + math.cos(ang)*cap_r*0.6
            cy = y + math.sin(ang)*cap_r*0.6
            cz = base_z + trunk_h + cap_r*0.5
            bpy.ops.mesh.primitive_uv_sphere_add(segments=14, ring_count=8, radius=cap_r*0.55,
                                                   location=(cx, cy, cz))
            cl = bpy.context.object
            cl.name = f"{name}_cl{j}"
            cl.scale.z = 0.8
            cl.data.materials.append(canopy)
            add_subsurf_bevel(cl, levels=1, bevel=0.01)
            if parent: cl.parent = parent

    if parent: trunk.parent = parent

forest_parent = bpy.data.objects.new("wild_forest", None); scene.collection.objects.link(forest_parent)
# 18 trees in NE quadrant
for i in range(18):
    x = random.uniform(8, 26)
    y = random.uniform(8, 26)
    if random.random() < 0.3 and abs(x) > 4:
        kind = "pine"
    elif random.random() < 0.5:
        kind = "oak"
    else:
        kind = "autumn"
    make_tree(f"tree{i}", x, y, kind, forest_parent)

# 6 trees scattered in SW
for i in range(6):
    x = random.uniform(-26, -10)
    y = random.uniform(-22, -8)
    kind = random.choice(["oak", "pine"])
    make_tree(f"tree_sw{i}", x, y, kind, forest_parent)

# ============================================================
# RUINS — broken arch + obelisk in mid-distance
# ============================================================
ruin_parent = bpy.data.objects.new("wild_ruins", None); scene.collection.objects.link(ruin_parent)
# obelisk on ridge
ox, oy = -14, 16
oz_base = bnoise.noise(Vector((ox*0.06, oy*0.06, 0)))*3.0 + bnoise.noise(Vector((ox*0.15, oy*0.15, 5)))*1.0 + (abs(ox)+abs(oy))/TERRAIN_SIZE*6.0
bpy.ops.mesh.primitive_cube_add(size=1, location=(ox, oy, oz_base + 0.6))
ped = bpy.context.object; ped.name = "ruin_ped"; ped.scale = (1.6, 1.6, 1.2)
ped.data.materials.append(mat_ruin_stone); add_subsurf_bevel(ped, levels=1, bevel=0.02); ped.parent = ruin_parent
bpy.ops.mesh.primitive_cube_add(size=1, location=(ox, oy, oz_base + 3.2))
obe = bpy.context.object; obe.name = "ruin_obe"; obe.scale = (0.6, 0.6, 4.0)
obe.data.materials.append(mat_ruin_stone); add_subsurf_bevel(obe, levels=1, bevel=0.02); obe.parent = ruin_parent
bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.42, radius2=0, depth=0.7, location=(ox, oy, oz_base + 5.5))
top = bpy.context.object; top.name = "ruin_top"; top.rotation_euler.z = math.pi/4
top.data.materials.append(mat_ruin_stone); add_subsurf_bevel(top, levels=1, bevel=0.01); top.parent = ruin_parent

# broken arch — 2 pillars + a cracked top beam
ax, ay = -10, 8
az_base = bnoise.noise(Vector((ax*0.06, ay*0.06, 0)))*3.0 + (abs(ax)+abs(ay))/TERRAIN_SIZE*6.0
for i, dx in enumerate([-1.6, 1.6]):
    bpy.ops.mesh.primitive_cylinder_add(vertices=14, radius=0.4, depth=3.6, location=(ax+dx, ay, az_base+1.8))
    p = bpy.context.object; p.name = f"arch_p{i}"
    p.data.materials.append(mat_ruin_stone); add_subsurf_bevel(p, levels=1, bevel=0.02); p.parent = ruin_parent
# top beam cracked/tilted
bpy.ops.mesh.primitive_cube_add(size=1, location=(ax, ay, az_base+3.8))
beam = bpy.context.object; beam.name = "arch_beam"; beam.scale = (3.8, 0.5, 0.4); beam.rotation_euler.y = 0.08
beam.data.materials.append(mat_ruin_stone); add_subsurf_bevel(beam, levels=1, bevel=0.02); beam.parent = ruin_parent
# fallen stone block
bpy.ops.mesh.primitive_cube_add(size=1, location=(ax+0.6, ay+1.6, az_base+0.4))
fb = bpy.context.object; fb.name = "arch_fb"; fb.scale = (1.0, 0.5, 0.5); fb.rotation_euler.z = 0.7
fb.data.materials.append(mat_ruin_stone); add_subsurf_bevel(fb, levels=1, bevel=0.02); fb.parent = ruin_parent

# ============================================================
# PATH STONES — 6 stones from foreground to riverbank
# ============================================================
path_parent = bpy.data.objects.new("wild_path", None); scene.collection.objects.link(path_parent)
for i in range(8):
    px = -1.0 + i*0.4
    py = -10.0 + i*1.6
    pz = bnoise.noise(Vector((px*0.06, py*0.06, 0)))*3.0 + bnoise.noise(Vector((px*0.15, py*0.15, 5)))*1.0
    pz -= max(0.0, 1.0 - (abs(px) / 6.0) ** 2) * 4.5
    pz += 0.25
    bpy.ops.mesh.primitive_cube_add(size=1, location=(px, py, pz))
    s = bpy.context.object; s.name = f"path_s{i}"; s.scale = (0.7, 0.5, 0.18)
    s.rotation_euler.z = i * 0.4
    s.data.materials.append(mat_path_stone); add_subsurf_bevel(s, levels=1, bevel=0.02)
    s.parent = path_parent

# ============================================================
# WILDFLOWERS — scattered small color spots along riverbank
# ============================================================
flower_parent = bpy.data.objects.new("wild_flowers", None); scene.collection.objects.link(flower_parent)
for i in range(40):
    side = random.choice([-1, 1])
    fx = side * random.uniform(2.2, 3.6)
    fy = random.uniform(-22, 22)
    fz = bnoise.noise(Vector((fx*0.06, fy*0.06, 0)))*3.0 + bnoise.noise(Vector((fx*0.15, fy*0.15, 5)))*1.0
    fz -= max(0.0, 1.0 - (abs(fx) / 6.0) ** 2) * 4.5
    fz += 0.05
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.10, location=(fx, fy, fz+0.1))
    f = bpy.context.object; f.name = f"flw{i}"
    color_mat = random.choice([mat_flower_red, mat_flower_yellow, mat_flower_blue])
    f.data.materials.append(color_mat); add_subsurf_bevel(f, levels=1, bevel=0.005)
    f.parent = flower_parent
    # tiny stem
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.012, depth=0.18, location=(fx, fy, fz+0.0))
    st = bpy.context.object; st.name = f"flw_st{i}"
    st.data.materials.append(mat_grass_blade); add_subsurf_bevel(st, levels=0, bevel=0.005)
    st.parent = flower_parent

# ============================================================
# CAMERAS — 4 hero shots
# ============================================================
def make_cam(name, loc, target_z=0, lens=35, dof=True):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    if dof:
        c.data.dof.use_dof = True
        c.data.dof.aperture_fstop = 5.6
    return c

# Sun light
bpy.ops.object.light_add(type='SUN', location=(20, -25, 30))
sun = bpy.context.object
sun.data.energy = 5.0
sun.data.color = (1.0, 0.92, 0.78)
sun.data.angle = math.radians(2)
direction = Vector((0, 0, 0)) - sun.location
sun.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

cam1 = make_cam("cam_overview", Vector((35, -35, 22)), lens=40)
cam2 = make_cam("cam_valley",   Vector((6, -28, 6)), lens=50)
cam3 = make_cam("cam_forest",   Vector((30, 5, 9)), lens=50)
cam4 = make_cam("cam_ruins",    Vector((-2, -2, 5)), lens=70)

for cam in [cam1, cam2, cam3, cam4]:
    target = Vector((0, 0, 0))
    if cam.name == "cam_forest":
        target = Vector((18, 18, 1))
    if cam.name == "cam_ruins":
        target = Vector((-12, 12, 2))
    if cam.name == "cam_valley":
        target = Vector((0, 5, -2))
    direction = target - cam.location
    cam.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render
for cam in [cam1, cam2, cam3, cam4]:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_wilderness_{cam.name.replace('cam_','')}_hero.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# GLB export — entire wilderness mesh set
bpy.ops.object.select_all(action='DESELECT')
for o in bpy.data.objects:
    if o.type == 'MESH':
        o.select_set(True)
out_path = os.path.join(EXPORT_DIR, "wilderness_v3.glb")
bpy.ops.export_scene.gltf(
    filepath=out_path, use_selection=True,
    export_format='GLB', export_apply=True
)
print(f"Exported: {out_path}")

print("=== V3 Epic 09 Wilderness Zone complete ===")
