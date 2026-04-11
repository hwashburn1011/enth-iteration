"""
Expansion V3 — Epic 08 — Sub-Area Detailing
=====================================================
8 sub-areas with hero-quality mood texturing, each with its own
distinctive material palette, lighting identity, and 4-6 hero props.

  1. Outskirts        — barren road, signpost, hay bales, skeletal tree
  2. Cliffs           — cracked rock edge, bird perch, view bench
  3. Hidden Cave      — moss + crystal cluster + bioluminescent mushrooms
  4. Sage's Garden    — koi pond, bonsai, stone lantern, cherry blossoms
  5. Iteration Memorial — engraved brass plaque, candles, wreath, obelisk
  6. Underground Lounge — wood floor, lacquered bar, bottles, hanging lamp
  7. Tower Top         — stone parapet, brass telescope, weather vane
  8. Old Ruins         — broken columns, ivy-covered wall, fallen statue

All 5-layer V3 shader graph (noise + voronoi + curvature dirt + fresnel rim
+ procedural normal). Subdivision Surface + Bevel modifiers everywhere.

Outputs: 8 hero shot renders @ 1920x1080 + 8 GLB exports.
"""
import bpy, bmesh, math, os
from mathutils import Vector

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/v3_sub_areas.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/exports"
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 96
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.render.film_transparent = False
scene.view_settings.look = 'AgX - High Contrast'
scene.world = bpy.data.worlds.new("v3_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.04, 0.05, 0.07, 1)
bg.inputs["Strength"].default_value = 1.0

# ============================================================
# SHADER HELPER (V3 standard 5-layer)
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

    tex_coord = nodes.new("ShaderNodeTexCoord"); tex_coord.location = (-1200, 0)
    mapping = nodes.new("ShaderNodeMapping"); mapping.location = (-1000, 0)
    mapping.inputs["Scale"].default_value = (5, 5, 5)
    links.new(tex_coord.outputs["Generated"], mapping.inputs["Vector"])

    if noise_strength > 0:
        noise = nodes.new("ShaderNodeTexNoise"); noise.location = (-700, 200)
        noise.inputs["Scale"].default_value = 14.0
        noise.inputs["Detail"].default_value = 8.0
        links.new(mapping.outputs["Vector"], noise.inputs["Vector"])
        ramp = nodes.new("ShaderNodeValToRGB"); ramp.location = (-450, 200)
        ramp.color_ramp.elements[0].position = 0.35
        ramp.color_ramp.elements[0].color = (base_color[0]*0.80, base_color[1]*0.80, base_color[2]*0.80, 1)
        ramp.color_ramp.elements[1].position = 0.70
        ramp.color_ramp.elements[1].color = (min(base_color[0]*1.20,1), min(base_color[1]*1.20,1), min(base_color[2]*1.20,1), 1)
        links.new(noise.outputs["Fac"], ramp.inputs["Fac"])
        mix = nodes.new("ShaderNodeMix"); mix.data_type='RGBA'; mix.location=(-200,100)
        mix.inputs["Factor"].default_value = noise_strength
        mix.inputs[6].default_value = (*base_color, 1)
        links.new(ramp.outputs["Color"], mix.inputs[7])
        base_out = mix.outputs[2]
    else:
        rgb = nodes.new("ShaderNodeRGB"); rgb.location=(-200,100)
        rgb.outputs[0].default_value = (*base_color, 1)
        base_out = rgb.outputs[0]

    if voronoi_strength > 0:
        v = nodes.new("ShaderNodeTexVoronoi"); v.location=(-700,-100)
        v.feature='F1'; v.inputs["Scale"].default_value = voronoi_scale
        links.new(mapping.outputs["Vector"], v.inputs["Vector"])
        v_ramp = nodes.new("ShaderNodeValToRGB"); v_ramp.location=(-450,-100)
        v_ramp.color_ramp.elements[0].position = 0.05
        v_ramp.color_ramp.elements[0].color = (base_color[0]*0.55, base_color[1]*0.55, base_color[2]*0.55, 1)
        v_ramp.color_ramp.elements[1].position = 0.30
        v_ramp.color_ramp.elements[1].color = (1,1,1,1)
        links.new(v.outputs["Distance"], v_ramp.inputs["Fac"])
        mv = nodes.new("ShaderNodeMix"); mv.data_type='RGBA'; mv.location=(50,50)
        mv.inputs["Factor"].default_value = voronoi_strength
        links.new(base_out, mv.inputs[6])
        links.new(v_ramp.outputs["Color"], mv.inputs[7])
        base_out = mv.outputs[2]

    if curvature_dirt:
        geo = nodes.new("ShaderNodeNewGeometry"); geo.location=(-700,-350)
        ao_ramp = nodes.new("ShaderNodeValToRGB"); ao_ramp.location=(-450,-350)
        ao_ramp.color_ramp.elements[0].position = 0.30
        ao_ramp.color_ramp.elements[0].color = (0.15,0.10,0.06,1)
        ao_ramp.color_ramp.elements[1].position = 0.70
        ao_ramp.color_ramp.elements[1].color = (1,1,1,1)
        links.new(geo.outputs["Pointiness"], ao_ramp.inputs["Fac"])
        md = nodes.new("ShaderNodeMix"); md.data_type='RGBA'; md.location=(300,0)
        md.inputs["Factor"].default_value = 0.40
        links.new(base_out, md.inputs[6])
        links.new(ao_ramp.outputs["Color"], md.inputs[7])
        base_out = md.outputs[2]

    if fresnel_rim and emission_color is not None:
        fresnel = nodes.new("ShaderNodeFresnel"); fresnel.location=(300,300)
        fresnel.inputs["IOR"].default_value = 1.45
        rim_color = nodes.new("ShaderNodeRGB"); rim_color.location=(300,450)
        rim_color.outputs[0].default_value = (*emission_color, 1)
        mr = nodes.new("ShaderNodeMix"); mr.data_type='RGBA'; mr.location=(550,350)
        mr.inputs[6].default_value = (0,0,0,1)
        links.new(fresnel.outputs["Fac"], mr.inputs["Factor"])
        links.new(rim_color.outputs[0], mr.inputs[7])
        links.new(mr.outputs[2], bsdf.inputs["Emission Color"])
        bsdf.inputs["Emission Strength"].default_value = max(emission_strength, 1.5)

    bn = nodes.new("ShaderNodeTexNoise"); bn.location=(-700,-550)
    bn.inputs["Scale"].default_value = bump_scale
    bn.inputs["Detail"].default_value = 8.0
    links.new(mapping.outputs["Vector"], bn.inputs["Vector"])
    bump = nodes.new("ShaderNodeBump"); bump.location=(-450,-550)
    bump.inputs["Strength"].default_value = bump_strength
    links.new(bn.outputs["Fac"], bump.inputs["Height"])
    links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])

    links.new(base_out, bsdf.inputs["Base Color"])
    return m

# ============================================================
# MATERIAL LIBRARY (sub-area focused)
# ============================================================
mats = {}
mats["dirt_road"]    = make_pbr("v3sa_dirt_road", (0.32,0.24,0.15), 0.95, 0,
    noise_strength=0.40, voronoi_strength=0.30, voronoi_scale=22.0, bump_strength=0.30, bump_scale=18.0)
mats["wood_grey"]    = make_pbr("v3sa_wood_grey", (0.32,0.28,0.22), 0.85, 0,
    noise_strength=0.30, voronoi_strength=0.45, voronoi_scale=10.0, bump_strength=0.25, bump_scale=14.0)
mats["hay"]          = make_pbr("v3sa_hay", (0.78,0.62,0.22), 0.95, 0,
    noise_strength=0.45, voronoi_strength=0.55, voronoi_scale=40.0, bump_strength=0.45, bump_scale=80.0)
mats["wood_dead"]    = make_pbr("v3sa_wood_dead", (0.18,0.12,0.06), 0.95, 0,
    noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=18.0, bump_strength=0.40, bump_scale=22.0)

mats["cliff_rock"]   = make_pbr("v3sa_cliff_rock", (0.38,0.34,0.30), 0.92, 0,
    noise_strength=0.45, voronoi_strength=0.60, voronoi_scale=8.0, bump_strength=0.55, bump_scale=10.0)
mats["lichen"]       = make_pbr("v3sa_lichen", (0.42,0.55,0.22), 0.85, 0,
    noise_strength=0.40, voronoi_strength=0.40, voronoi_scale=30.0, bump_strength=0.30, bump_scale=40.0)
mats["bench_wood"]   = make_pbr("v3sa_bench_wood", (0.42,0.26,0.13), 0.85, 0,
    noise_strength=0.30, voronoi_strength=0.45, voronoi_scale=12.0, bump_strength=0.20, bump_scale=18.0)

mats["cave_rock"]    = make_pbr("v3sa_cave_rock", (0.10,0.09,0.11), 0.95, 0,
    noise_strength=0.40, voronoi_strength=0.55, voronoi_scale=8.0, bump_strength=0.55, bump_scale=10.0)
mats["moss_wet"]     = make_pbr("v3sa_moss_wet", (0.12,0.30,0.10), 0.65, 0,
    noise_strength=0.45, voronoi_strength=0.40, voronoi_scale=25.0, bump_strength=0.35, bump_scale=45.0)
mats["crystal_blue"] = make_pbr("v3sa_crystal_blue", (0.30,0.55,0.95), 0.10, 0,
    emission_color=(0.40,0.75,1.0), emission_strength=4.0,
    noise_strength=0.10, curvature_dirt=False, fresnel_rim=True, bump_strength=0.05)
mats["mushroom_glow"]= make_pbr("v3sa_mushroom_glow", (0.65,0.85,1.0), 0.40, 0,
    emission_color=(0.60,0.90,1.0), emission_strength=3.5,
    noise_strength=0.15, curvature_dirt=False, fresnel_rim=True, bump_strength=0.05)
mats["mushroom_stem"]= make_pbr("v3sa_mushroom_stem", (0.85,0.78,0.65), 0.85, 0,
    noise_strength=0.20, curvature_dirt=True, bump_strength=0.20, bump_scale=40.0)

mats["garden_soil"]  = make_pbr("v3sa_garden_soil", (0.22,0.14,0.08), 0.95, 0,
    noise_strength=0.40, voronoi_strength=0.30, voronoi_scale=22.0, bump_strength=0.30, bump_scale=20.0)
mats["pond_water"]   = make_pbr("v3sa_pond_water", (0.10,0.30,0.40), 0.10, 0,
    emission_color=(0.20,0.50,0.70), emission_strength=0.4,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True, bump_strength=0.05, bump_scale=80.0)
mats["bonsai_leaf"]  = make_pbr("v3sa_bonsai_leaf", (0.18,0.40,0.10), 0.85, 0,
    noise_strength=0.40, curvature_dirt=True, bump_strength=0.25, bump_scale=40.0)
mats["cherry_blossom"]= make_pbr("v3sa_cherry", (0.95,0.75,0.85), 0.85, 0,
    emission_color=(1.0,0.85,0.92), emission_strength=0.6,
    noise_strength=0.30, curvature_dirt=False, fresnel_rim=True, bump_strength=0.20, bump_scale=50.0)
mats["stone_lantern"]= make_pbr("v3sa_stone_lantern", (0.55,0.50,0.42), 0.85, 0,
    noise_strength=0.25, voronoi_strength=0.40, voronoi_scale=14.0, bump_strength=0.20, bump_scale=18.0)

mats["memorial_brass"]= make_pbr("v3sa_mem_brass", (0.85,0.65,0.20), 0.30, 0.92,
    emission_color=(1.0,0.85,0.30), emission_strength=0.7,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True)
mats["obelisk_stone"]= make_pbr("v3sa_obelisk", (0.45,0.42,0.40), 0.85, 0,
    noise_strength=0.25, voronoi_strength=0.30, voronoi_scale=10.0, bump_strength=0.18, bump_scale=14.0)
mats["candle_wax"]   = make_pbr("v3sa_candle", (0.92,0.88,0.78), 0.40, 0,
    emission_color=(1.0,0.85,0.55), emission_strength=4.5,
    noise_strength=0.10, curvature_dirt=False, fresnel_rim=True)
mats["wreath_pine"]  = make_pbr("v3sa_wreath", (0.15,0.30,0.12), 0.85, 0,
    noise_strength=0.40, curvature_dirt=True, bump_strength=0.30, bump_scale=50.0)

mats["lounge_floor"] = make_pbr("v3sa_lounge_floor", (0.32,0.18,0.08), 0.40, 0.05,
    noise_strength=0.25, voronoi_strength=0.40, voronoi_scale=12.0, bump_strength=0.10, bump_scale=20.0)
mats["lounge_bar"]   = make_pbr("v3sa_lounge_bar", (0.20,0.10,0.05), 0.20, 0.10,
    noise_strength=0.20, voronoi_strength=0.30, voronoi_scale=14.0, bump_strength=0.08, bump_scale=18.0)
mats["bottle_green"] = make_pbr("v3sa_bottle_green", (0.10,0.35,0.15), 0.10, 0,
    emission_color=(0.20,0.55,0.30), emission_strength=0.3,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True, bump_strength=0.0)
mats["bottle_amber"] = make_pbr("v3sa_bottle_amber", (0.65,0.35,0.10), 0.10, 0,
    emission_color=(0.95,0.55,0.20), emission_strength=0.3,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True, bump_strength=0.0)
mats["lounge_lamp"]  = make_pbr("v3sa_lounge_lamp", (1.0,0.78,0.40), 0.20, 0,
    emission_color=(1.0,0.78,0.40), emission_strength=6.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)

mats["tower_stone"]  = make_pbr("v3sa_tower_stone", (0.62,0.58,0.52), 0.85, 0,
    noise_strength=0.25, voronoi_strength=0.45, voronoi_scale=10.0, bump_strength=0.20, bump_scale=14.0)
mats["telescope_brass"]= make_pbr("v3sa_telescope", (0.80,0.55,0.18), 0.20, 0.95,
    emission_color=(1.0,0.85,0.30), emission_strength=0.4,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True)
mats["weather_iron"] = make_pbr("v3sa_weather_iron", (0.25,0.25,0.27), 0.45, 0.85,
    noise_strength=0.10, curvature_dirt=True)

mats["ruin_stone"]   = make_pbr("v3sa_ruin_stone", (0.55,0.50,0.42), 0.92, 0,
    noise_strength=0.40, voronoi_strength=0.55, voronoi_scale=8.0, bump_strength=0.45, bump_scale=10.0)
mats["ruin_ivy"]     = make_pbr("v3sa_ruin_ivy", (0.15,0.32,0.10), 0.85, 0,
    noise_strength=0.40, curvature_dirt=True, bump_strength=0.30, bump_scale=45.0)
mats["statue_marble"]= make_pbr("v3sa_statue_marble", (0.82,0.78,0.72), 0.40, 0,
    noise_strength=0.15, voronoi_strength=0.20, voronoi_scale=8.0, bump_strength=0.10, bump_scale=14.0)

# ============================================================
# UTILITIES
# ============================================================
def add_subsurf_bevel(obj, levels=2, bevel=0.025):
    s = obj.modifiers.new("Subsurf", 'SUBSURF'); s.levels = levels; s.render_levels = levels+1
    b = obj.modifiers.new("Bevel", 'BEVEL'); b.width = bevel; b.segments = 3; b.profile = 0.7
    for poly in obj.data.polygons: poly.use_smooth = True

def add_box(name, loc, size, mat, parent=None):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.object; o.name = name; o.scale = size
    o.data.materials.append(mat); add_subsurf_bevel(o)
    if parent: o.parent = parent
    return o

def add_cyl(name, loc, r, depth, mat, verts=24, parent=None):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=r, depth=depth, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.015)
    if parent: o.parent = parent
    return o

def add_sphere(name, loc, r, mat, segs=24, parent=None):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segs, ring_count=segs//2, radius=r, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=2, bevel=0.01)
    if parent: o.parent = parent
    return o

def add_ico(name, loc, r, mat, sub=2, parent=None):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=sub, radius=r, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=2, bevel=0.01)
    if parent: o.parent = parent
    return o

def add_cone(name, loc, r1, r2, depth, mat, verts=20, parent=None):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.015)
    if parent: o.parent = parent
    return o

def add_torus(name, loc, R, r, mat, ms=24, mn=12, parent=None):
    bpy.ops.mesh.primitive_torus_add(major_segments=ms, minor_segments=mn, major_radius=R, minor_radius=r, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.005)
    if parent: o.parent = parent
    return o

def add_plane(name, loc, sx, sy, mat):
    bpy.ops.mesh.primitive_plane_add(size=1, location=loc)
    o = bpy.context.object; o.name = name
    o.scale = (sx, sy, 1)
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.005)
    return o

# ============================================================
# SUB-AREA BUILDERS
# ============================================================
def build_outskirts(origin):
    parent = bpy.data.objects.new("sa_outskirts", None); scene.collection.objects.link(parent)
    parent.location = origin
    add_plane("ot_road", (0,0,0), 8, 8, mats["dirt_road"])
    # winding signpost
    post = add_cyl("ot_post", (-1.5,0.5,0.8), 0.06, 1.6, mats["wood_dead"], parent=parent)
    sign = add_box("ot_sign", (-1.5,0.5,1.6), (0.6,0.04,0.4), mats["wood_grey"], parent=parent)
    # hay bales
    for i, (x, y) in enumerate([(1.2, -1.0), (1.8, -1.0), (1.5, -0.4)]):
        h = add_cyl(f"ot_hay_{i}", (x, y, 0.3), 0.4, 0.6, mats["hay"], parent=parent)
        h.rotation_euler = (math.pi/2, 0, i*0.4)
    # skeletal tree (curved trunk + bare branches)
    trunk = add_cyl("ot_trunk", (1.8, 1.6, 1.0), 0.18, 2.0, mats["wood_dead"], parent=parent)
    for i in range(5):
        a = i * 1.2
        branch = add_cyl(f"ot_branch_{i}", (1.8 + math.cos(a)*0.4, 1.6 + math.sin(a)*0.4, 1.6 + i*0.15), 0.04, 0.7, mats["wood_dead"], parent=parent)
        branch.rotation_euler = (a, 0.4, 0)
    # warm sunset key
    bpy.ops.object.light_add(type='AREA', location=(4, -3, 4))
    k = bpy.context.object; k.data.energy = 1500; k.data.color = (1.0, 0.65, 0.35); k.data.size = 5
    bpy.ops.object.light_add(type='AREA', location=(-3, 3, 3))
    f = bpy.context.object; f.data.energy = 350; f.data.color = (0.55, 0.65, 0.95); f.data.size = 4
    return parent

def build_cliffs(origin):
    parent = bpy.data.objects.new("sa_cliffs", None); scene.collection.objects.link(parent)
    parent.location = origin
    # cliff edge plateau
    add_box("cl_top", (0,0,0.4), (5,4,0.8), mats["cliff_rock"], parent=parent)
    # cracked rocks
    for i, (x,y,z,s) in enumerate([(-1.5,-1.0,1.0,0.4),(1.0,1.2,1.0,0.5),(0.0,-1.5,1.0,0.35),(1.7,-0.8,1.0,0.3)]):
        r = add_ico(f"cl_rock_{i}", (x,y,z), s, mats["cliff_rock"], parent=parent)
        r.scale.z *= 0.6
    # lichen patches
    add_ico("cl_lichen0", (-0.5, 0.8, 0.85), 0.3, mats["lichen"], parent=parent).scale.z = 0.3
    add_ico("cl_lichen1", (1.4, -0.2, 0.85), 0.25, mats["lichen"], parent=parent).scale.z = 0.3
    # view bench (back to camera, facing the void)
    bench_seat = add_box("cl_bench_seat", (0, 1.6, 1.05), (1.5, 0.4, 0.08), mats["bench_wood"], parent=parent)
    add_box("cl_bench_back", (0, 1.85, 1.35), (1.5, 0.06, 0.6), mats["bench_wood"], parent=parent)
    add_box("cl_bench_l1", (-0.7, 1.6, 0.65), (0.06, 0.36, 0.8), mats["bench_wood"], parent=parent)
    add_box("cl_bench_l2", (0.7, 1.6, 0.65), (0.06, 0.36, 0.8), mats["bench_wood"], parent=parent)
    # bird perch (small post with bird sphere)
    add_cyl("cl_perch", (-2.0, 1.2, 1.4), 0.04, 0.8, mats["wood_dead"], parent=parent)
    add_sphere("cl_bird", (-2.0, 1.2, 1.85), 0.10, mats["lichen"], parent=parent)
    # cool dawn lighting
    bpy.ops.object.light_add(type='AREA', location=(4, -3, 5))
    k = bpy.context.object; k.data.energy = 1300; k.data.color = (1.0, 0.85, 0.65); k.data.size = 5
    bpy.ops.object.light_add(type='AREA', location=(-4, 4, 4))
    f = bpy.context.object; f.data.energy = 500; f.data.color = (0.45, 0.6, 0.95); f.data.size = 5
    return parent

def build_hidden_cave(origin):
    parent = bpy.data.objects.new("sa_hidden_cave", None); scene.collection.objects.link(parent)
    parent.location = origin
    # cave floor
    add_plane("hc_floor", (0,0,0), 7, 6, mats["cave_rock"])
    # cave back wall (large rotated plane)
    wall = add_plane("hc_wall", (0,2.5,1.4), 7, 3.0, mats["cave_rock"])
    wall.rotation_euler = (math.pi/2, 0, 0)
    # boulders
    for i, (x,y,z,s) in enumerate([(-1.8,-0.5,0.3,0.5),(1.6,-0.6,0.3,0.45),(0.0,1.2,0.4,0.6)]):
        r = add_ico(f"hc_rock_{i}", (x,y,z), s, mats["cave_rock"], parent=parent)
        r.scale = (s*1.2, s, s*0.9)
    # moss patches
    for i, (x,y,r) in enumerate([(-1.8,-0.5,0.55),(1.6,-0.6,0.50),(0.0,1.2,0.65)]):
        m = add_ico(f"hc_moss_{i}", (x,y,r+0.1), 0.40, mats["moss_wet"], parent=parent)
        m.scale.z = 0.18
    # crystal cluster (4 elongated icospheres)
    for i, (x,y) in enumerate([(0.4,-1.0),(0.7,-0.7),(0.2,-1.3),(0.55,-1.45)]):
        c = add_ico(f"hc_crystal_{i}", (x,y,0.6+i*0.05), 0.18, mats["crystal_blue"], parent=parent)
        c.scale = (0.4, 0.4, 1.6)
        c.rotation_euler = (i*0.2, i*0.15, i*0.5)
    # bioluminescent mushrooms
    for i, (x,y) in enumerate([(-1.0,1.0),(-1.4,0.8),(-1.2,0.4),(1.6,1.0)]):
        s = add_cyl(f"hc_ms_{i}", (x,y,0.20), 0.04, 0.40, mats["mushroom_stem"], parent=parent)
        c = add_sphere(f"hc_mc_{i}", (x,y,0.45), 0.10, mats["mushroom_glow"], parent=parent)
        c.scale.z = 0.6
    # cool emissive light only
    bpy.ops.object.light_add(type='AREA', location=(2, -3, 3))
    k = bpy.context.object; k.data.energy = 350; k.data.color = (0.45, 0.7, 1.0); k.data.size = 4
    bpy.ops.object.light_add(type='AREA', location=(-2, -2, 2))
    f = bpy.context.object; f.data.energy = 200; f.data.color = (0.55, 0.85, 1.0); f.data.size = 3
    return parent

def build_sage_garden(origin):
    parent = bpy.data.objects.new("sa_sage_garden", None); scene.collection.objects.link(parent)
    parent.location = origin
    add_plane("sg_soil", (0,0,0), 8, 8, mats["garden_soil"])
    # koi pond
    pond_rim = add_cyl("sg_pond_rim", (0,0,0.05), 1.5, 0.10, mats["stone_lantern"], parent=parent)
    pond = add_cyl("sg_pond", (0,0,0.08), 1.35, 0.08, mats["pond_water"], parent=parent)
    # bonsai (gnarled trunk + canopy)
    trunk = add_cyl("sg_bonsai_trunk", (-2.2, 1.5, 0.4), 0.10, 0.8, mats["bench_wood"], parent=parent)
    trunk.rotation_euler = (0, 0.3, 0)
    add_sphere("sg_bonsai_top", (-2.0, 1.5, 0.95), 0.40, mats["bonsai_leaf"], parent=parent).scale.z = 0.7
    # cherry blossom tree
    add_cyl("sg_cherry_tr", (2.2, -1.5, 0.7), 0.18, 1.4, mats["bench_wood"], parent=parent)
    for i in range(5):
        a = i * 1.25; r = 0.7
        add_sphere(f"sg_cherry_b_{i}", (2.2 + math.cos(a)*r, -1.5 + math.sin(a)*r, 1.6 + (i%2)*0.15), 0.45, mats["cherry_blossom"], parent=parent)
    # stone lantern
    add_box("sg_lantern_base", (1.5, 1.5, 0.15), (0.32, 0.32, 0.30), mats["stone_lantern"], parent=parent)
    add_cyl("sg_lantern_post", (1.5, 1.5, 0.55), 0.08, 0.5, mats["stone_lantern"], parent=parent)
    add_box("sg_lantern_top", (1.5, 1.5, 0.95), (0.36, 0.36, 0.20), mats["stone_lantern"], parent=parent)
    add_box("sg_lantern_lite", (1.5, 1.5, 1.10), (0.20, 0.20, 0.06), mats["candle_wax"], parent=parent)
    # cherry petals scattered
    for i, (x, y) in enumerate([(0.4, 1.6),(-0.6, 0.8),(1.0, 0.3),(-1.2, 1.2),(0.2, -1.6)]):
        p = add_ico(f"sg_petal_{i}", (x, y, 0.05), 0.06, mats["cherry_blossom"], parent=parent)
        p.scale.z = 0.2
    # warm garden light
    bpy.ops.object.light_add(type='AREA', location=(4, -3, 5))
    k = bpy.context.object; k.data.energy = 1400; k.data.color = (1.0, 0.85, 0.65); k.data.size = 5
    bpy.ops.object.light_add(type='AREA', location=(-3, 3, 4))
    f = bpy.context.object; f.data.energy = 450; f.data.color = (0.55, 0.7, 0.95); f.data.size = 5
    return parent

def build_memorial(origin):
    parent = bpy.data.objects.new("sa_memorial", None); scene.collection.objects.link(parent)
    parent.location = origin
    add_plane("mm_floor", (0,0,0), 7, 7, mats["obelisk_stone"])
    # central obelisk
    add_box("mm_pedestal", (0,0,0.3), (1.0, 1.0, 0.6), mats["obelisk_stone"], parent=parent)
    obelisk = add_box("mm_obelisk", (0,0,1.8), (0.45, 0.45, 2.2), mats["obelisk_stone"], parent=parent)
    add_cone("mm_obelisk_top", (0,0,3.05), 0.45, 0, 0.5, mats["obelisk_stone"], parent=parent)
    # brass plaque
    add_box("mm_plaque", (0, -0.46, 1.7), (0.35, 0.04, 0.50), mats["memorial_brass"], parent=parent)
    # candles around base
    for i, (x, y) in enumerate([(-0.8,-0.8),(0.8,-0.8),(-0.8,0.8),(0.8,0.8)]):
        add_cyl(f"mm_candle_{i}", (x, y, 0.75), 0.05, 0.30, mats["candle_wax"], parent=parent)
        add_sphere(f"mm_flame_{i}", (x, y, 0.95), 0.04, mats["candle_wax"], parent=parent).scale.z = 1.6
    # wreath
    add_torus("mm_wreath", (0, -0.55, 1.0), 0.3, 0.05, mats["wreath_pine"], parent=parent)
    # warm memorial light
    bpy.ops.object.light_add(type='AREA', location=(3, -3, 4))
    k = bpy.context.object; k.data.energy = 1200; k.data.color = (1.0, 0.78, 0.45); k.data.size = 5
    bpy.ops.object.light_add(type='AREA', location=(-3, 3, 4))
    f = bpy.context.object; f.data.energy = 350; f.data.color = (0.50, 0.65, 0.95); f.data.size = 4
    return parent

def build_lounge(origin):
    parent = bpy.data.objects.new("sa_lounge", None); scene.collection.objects.link(parent)
    parent.location = origin
    add_plane("lg_floor", (0,0,0), 7, 6, mats["lounge_floor"])
    # back wall
    wall = add_plane("lg_wall", (0,2.0,1.5), 7, 3, mats["lounge_bar"])
    wall.rotation_euler = (math.pi/2, 0, 0)
    # bar counter
    add_box("lg_bar", (0, 1.0, 0.6), (3.0, 0.6, 1.2), mats["lounge_bar"], parent=parent)
    # bar top
    add_box("lg_bar_top", (0, 1.0, 1.22), (3.05, 0.65, 0.05), mats["lounge_bar"], parent=parent)
    # bottles row
    for i in range(7):
        x = -1.6 + i * 0.55
        b = add_cyl(f"lg_bottle_{i}", (x, 1.5, 1.45), 0.07, 0.40, mats["bottle_green"] if i%2==0 else mats["bottle_amber"], parent=parent)
    # bar stools
    for i, x in enumerate([-1.0, 0.0, 1.0]):
        st = add_cyl(f"lg_stool_{i}", (x, 0.0, 0.45), 0.18, 0.10, mats["lounge_bar"], parent=parent)
        add_cyl(f"lg_stool_p_{i}", (x, 0.0, 0.20), 0.04, 0.40, mats["weather_iron"], parent=parent)
    # hanging lamp
    add_cyl("lg_lamp_chain", (0, 0.5, 2.2), 0.02, 1.0, mats["weather_iron"], parent=parent)
    add_sphere("lg_lamp", (0, 0.5, 1.6), 0.20, mats["lounge_lamp"], parent=parent)
    # warm interior light
    bpy.ops.object.light_add(type='AREA', location=(2, -1.5, 3))
    k = bpy.context.object; k.data.energy = 800; k.data.color = (1.0, 0.78, 0.45); k.data.size = 4
    bpy.ops.object.light_add(type='POINT', location=(0, 0.5, 1.6))
    p = bpy.context.object; p.data.energy = 600; p.data.color = (1.0, 0.82, 0.50)
    return parent

def build_tower_top(origin):
    parent = bpy.data.objects.new("sa_tower_top", None); scene.collection.objects.link(parent)
    parent.location = origin
    # platform
    add_cyl("tt_floor", (0,0,0.05), 3.5, 0.15, mats["tower_stone"], parent=parent)
    # parapet (8 merlons around edge)
    for i in range(8):
        a = i * (math.pi*2/8)
        x = math.cos(a)*3.4; y = math.sin(a)*3.4
        m = add_box(f"tt_merlon_{i}", (x,y,0.55), (0.35, 0.35, 0.65), mats["tower_stone"], parent=parent)
        m.rotation_euler.z = a
    # telescope on tripod
    add_cyl("tt_tripod_l1", (-0.4,-0.3,0.55), 0.03, 1.0, mats["weather_iron"], parent=parent).rotation_euler = (0.3, 0, 0)
    add_cyl("tt_tripod_l2", (0.4,-0.3,0.55), 0.03, 1.0, mats["weather_iron"], parent=parent).rotation_euler = (0.3, 0, 0)
    add_cyl("tt_tripod_l3", (0,0.3,0.55), 0.03, 1.0, mats["weather_iron"], parent=parent).rotation_euler = (-0.3, 0, 0)
    tele = add_cyl("tt_telescope", (0,0,1.15), 0.10, 0.8, mats["telescope_brass"], parent=parent)
    tele.rotation_euler = (math.radians(75), 0, 0)
    add_cyl("tt_telescope_lens", (0,0.5,1.5), 0.13, 0.10, mats["telescope_brass"], parent=parent)
    # weather vane
    add_cyl("tt_vane_post", (1.8, 1.8, 0.85), 0.05, 1.6, mats["weather_iron"], parent=parent)
    add_cone("tt_vane_arrow", (1.8, 2.0, 1.6), 0.0, 0.06, 0.4, mats["weather_iron"], parent=parent)
    # cool dusk light
    bpy.ops.object.light_add(type='AREA', location=(4, -3, 6))
    k = bpy.context.object; k.data.energy = 1500; k.data.color = (1.0, 0.70, 0.40); k.data.size = 6
    bpy.ops.object.light_add(type='AREA', location=(-3, 3, 5))
    f = bpy.context.object; f.data.energy = 500; f.data.color = (0.45, 0.55, 0.95); f.data.size = 5
    return parent

def build_old_ruins(origin):
    parent = bpy.data.objects.new("sa_old_ruins", None); scene.collection.objects.link(parent)
    parent.location = origin
    add_plane("or_floor", (0,0,0), 8, 7, mats["ruin_stone"])
    # broken column 1 (full height)
    add_cyl("or_col1_b", (-1.8, 0, 0.10), 0.45, 0.20, mats["ruin_stone"], parent=parent)
    add_cyl("or_col1_s", (-1.8, 0, 1.4), 0.35, 2.4, mats["ruin_stone"], parent=parent, verts=18)
    add_box("or_col1_t", (-1.8, 0, 2.7), (0.55, 0.55, 0.18), mats["ruin_stone"], parent=parent)
    # broken column 2 (mid height)
    add_cyl("or_col2_b", (1.8, 0, 0.10), 0.45, 0.20, mats["ruin_stone"], parent=parent)
    c2 = add_cyl("or_col2_s", (1.8, 0, 0.9), 0.35, 1.4, mats["ruin_stone"], parent=parent, verts=18)
    # toppled column piece on ground
    f1 = add_cyl("or_col_fall", (0.5, 1.5, 0.4), 0.35, 1.8, mats["ruin_stone"], parent=parent, verts=18)
    f1.rotation_euler = (0, math.pi/2, 0.3)
    # ivy on standing column
    add_ico("or_ivy1", (-1.8, 0.40, 1.6), 0.5, mats["ruin_ivy"], parent=parent).scale = (1.2, 0.2, 1.6)
    add_ico("or_ivy2", (-1.8, -0.40, 0.9), 0.4, mats["ruin_ivy"], parent=parent).scale = (1.2, 0.2, 1.4)
    # fallen statue (torso + head)
    statue_t = add_cyl("or_statue_t", (-0.5, -1.6, 0.35), 0.30, 1.2, mats["statue_marble"], parent=parent)
    statue_t.rotation_euler = (math.pi/2, 0, 0.4)
    add_sphere("or_statue_h", (-0.5, -2.2, 0.45), 0.22, mats["statue_marble"], parent=parent)
    # rubble
    for i, (x,y) in enumerate([(0.0, -0.6),(-0.8, 0.8),(1.2, -1.2),(0.6, -0.2)]):
        r = add_ico(f"or_rub_{i}", (x,y,0.12), 0.18, mats["ruin_stone"], parent=parent); r.scale.z = 0.6
    # sunset light
    bpy.ops.object.light_add(type='AREA', location=(4, -3, 5))
    k = bpy.context.object; k.data.energy = 1500; k.data.color = (1.0, 0.62, 0.30); k.data.size = 6
    bpy.ops.object.light_add(type='AREA', location=(-3, 3, 4))
    f = bpy.context.object; f.data.energy = 400; f.data.color = (0.45, 0.55, 0.95); f.data.size = 5
    return parent

# ============================================================
# SCENE LAYOUT — 8 sub-areas spaced apart
# ============================================================
SUB_AREAS = [
    ("outskirts",   build_outskirts,   ( 0,    0,   0)),
    ("cliffs",      build_cliffs,      ( 30,   0,   0)),
    ("hidden_cave", build_hidden_cave, ( 60,   0,   0)),
    ("sage_garden", build_sage_garden, ( 90,   0,   0)),
    ("memorial",    build_memorial,    ( 0,   30,   0)),
    ("lounge",      build_lounge,      ( 30,  30,   0)),
    ("tower_top",   build_tower_top,   ( 60,  30,   0)),
    ("old_ruins",   build_old_ruins,   ( 90,  30,   0)),
]

CAMERAS = []
for name, builder, origin in SUB_AREAS:
    parent = builder(Vector(origin))
    bpy.ops.object.camera_add(location=(origin[0]+5, origin[1]-5, 4.0))
    cam = bpy.context.object; cam.name = f"cam_{name}"
    cam.data.lens = 45
    cam.data.dof.use_dof = True
    cam.data.dof.aperture_fstop = 4.0
    # aim at origin center
    direction = Vector(origin) + Vector((0, 0, 1.2)) - cam.location
    rot = direction.to_track_quat('-Z', 'Y').to_euler()
    cam.rotation_euler = rot
    CAMERAS.append((name, cam))

# Save the .blend
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# ============================================================
# RENDER + EXPORT
# ============================================================
for name, cam in CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_subarea_{name}_hero.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# GLB exports — select per-area children only
for name, _, origin in SUB_AREAS:
    bpy.ops.object.select_all(action='DESELECT')
    parent = bpy.data.objects.get(f"sa_{name}")
    if parent:
        parent.select_set(True)
        for child in parent.children_recursive:
            child.select_set(True)
        out_path = os.path.join(EXPORT_DIR, f"subarea_{name}_v3.glb")
        bpy.ops.export_scene.gltf(
            filepath=out_path, use_selection=True,
            export_format='GLB', export_apply=True
        )
        print(f"Exported: {out_path}")

print("=== V3 Epic 08 Sub-Area Detailing complete ===")
