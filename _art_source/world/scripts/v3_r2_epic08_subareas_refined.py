"""
Expansion V3 — ROUND 2 — Epic R2-08 — Sub-Area Refinement
=========================================================
Round 2 of V3-08 Sub-Areas. 3 hero sub-areas with full Round 2 stack
(Smart UV unwrap + vertex color paint + multires + 5-seg bevel +
vertex-color-aware shaders), each chosen as the most narrative-rich
of the original 8:

  SAGE'S GARDEN     — koi pond, bonsai, cherry blossom tree, stone
                       lantern, scattered petals, soft warm light
  ITERATION MEMORIAL — central obelisk w/ brass plaque, candles,
                       pine wreath, sun-glyph relief on backwall
  HIDDEN CAVE       — bioluminescent crystal cluster, glowing
                       mushrooms, moss patches, cool blue lighting

Each sub-area is its own diorama with per-area hero camera and
custom lighting tuned to mood (warm garden / memorial / cool cave).

Outputs: 4 hero renders @ 1920x1080 + 3 GLB exports.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(108)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/v3_r2_subareas.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/exports"
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

scene.world = bpy.data.worlds.new("v3r2sa_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.04, 0.05, 0.07, 1)
bg.inputs["Strength"].default_value = 0.5

# ============================================================
# REFINED VC-AWARE SHADER (architectural)
# ============================================================
def make_arch_shader(name, base_color, accent_color, roughness=0.85,
                     metallic=0.0, voronoi_scale=10.0, bump_strength=0.30,
                     emission_color=None, emission_strength=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1300, 0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    if emission_color:
        bsdf.inputs["Emission Color"].default_value = (*emission_color, 1)
        bsdf.inputs["Emission Strength"].default_value = emission_strength
    links.new(bsdf.outputs[0], out.inputs[0])

    vc = nodes.new("ShaderNodeAttribute"); vc.location = (-1200, 400)
    vc.attribute_name = "Color"
    sep_vc = nodes.new("ShaderNodeSeparateColor"); sep_vc.location = (-1000, 400)
    links.new(vc.outputs["Color"], sep_vc.inputs["Color"])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (5, 5, 5)
    links.new(tc.outputs["UV"], mp.inputs["Vector"])

    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
    n.inputs["Scale"].default_value = 14.0
    n.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])
    n_ramp = nodes.new("ShaderNodeValToRGB"); n_ramp.location = (-450, 200)
    n_ramp.color_ramp.elements[0].position = 0.35
    n_ramp.color_ramp.elements[0].color = (base_color[0]*0.78, base_color[1]*0.78, base_color[2]*0.78, 1)
    n_ramp.color_ramp.elements[1].position = 0.70
    n_ramp.color_ramp.elements[1].color = (min(base_color[0]*1.22,1), min(base_color[1]*1.22,1), min(base_color[2]*1.22,1), 1)
    links.new(n.outputs["Fac"], n_ramp.inputs["Fac"])

    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-700, -100)
    v.feature = 'F1'
    v.inputs["Scale"].default_value = voronoi_scale
    links.new(mp.outputs["Vector"], v.inputs["Vector"])
    v_ramp = nodes.new("ShaderNodeValToRGB"); v_ramp.location = (-450, -100)
    v_ramp.color_ramp.elements[0].position = 0.05
    v_ramp.color_ramp.elements[0].color = (base_color[0]*0.55, base_color[1]*0.55, base_color[2]*0.55, 1)
    v_ramp.color_ramp.elements[1].position = 0.30
    v_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(v.outputs["Distance"], v_ramp.inputs["Fac"])

    vc_mix = nodes.new("ShaderNodeMix"); vc_mix.data_type = 'RGBA'; vc_mix.location = (-200, 200)
    vc_mix.inputs[6].default_value = (*base_color, 1)
    vc_mix.inputs[7].default_value = (*accent_color, 1)
    links.new(sep_vc.outputs["Red"], vc_mix.inputs["Factor"])

    nv_mix = nodes.new("ShaderNodeMix"); nv_mix.data_type = 'RGBA'; nv_mix.location = (50, 100)
    nv_mix.inputs["Factor"].default_value = 0.40
    links.new(n_ramp.outputs["Color"], nv_mix.inputs[6])
    links.new(v_ramp.outputs["Color"], nv_mix.inputs[7])

    final_mix = nodes.new("ShaderNodeMix"); final_mix.data_type = 'RGBA'; final_mix.location = (250, 100)
    final_mix.inputs["Factor"].default_value = 0.55
    links.new(vc_mix.outputs[2], final_mix.inputs[6])
    links.new(nv_mix.outputs[2], final_mix.inputs[7])

    g = nodes.new("ShaderNodeNewGeometry"); g.location = (-200, -300)
    ar = nodes.new("ShaderNodeValToRGB"); ar.location = (50, -300)
    ar.color_ramp.elements[0].position = 0.30
    ar.color_ramp.elements[0].color = (0.10, 0.07, 0.04, 1)
    ar.color_ramp.elements[1].position = 0.70
    ar.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(g.outputs["Pointiness"], ar.inputs["Fac"])
    md = nodes.new("ShaderNodeMix"); md.data_type = 'RGBA'; md.location = (450, 0)
    md.inputs["Factor"].default_value = 0.40
    links.new(final_mix.outputs[2], md.inputs[6])
    links.new(ar.outputs["Color"], md.inputs[7])
    links.new(md.outputs[2], bsdf.inputs["Base Color"])

    bp = nodes.new("ShaderNodeBump"); bp.location = (450, -350)
    bp.inputs["Strength"].default_value = bump_strength
    links.new(v.outputs["Distance"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
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

def make_pbr_simple(name, color, rough, metal=0.0, em=None, em_str=0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (*color, 1)
    bs.inputs["Roughness"].default_value = rough
    bs.inputs["Metallic"].default_value = metal
    if em:
        bs.inputs["Emission Color"].default_value = (*em, 1)
        bs.inputs["Emission Strength"].default_value = em_str
    return m

# ============================================================
# MATERIALS
# ============================================================
mats = {}
mats["soil_garden"] = make_arch_shader("v3r2sa_soil", (0.22, 0.14, 0.08), (0.32, 0.20, 0.10),
                                        roughness=0.95, voronoi_scale=20.0, bump_strength=0.30)
mats["pond_water"]  = make_pbr_simple("v3r2sa_water", (0.10, 0.30, 0.40), 0.05, 0,
                                       em=(0.20, 0.50, 0.65), em_str=0.6)
mats["bonsai_leaf"] = make_arch_shader("v3r2sa_bonsai", (0.18, 0.40, 0.10), (0.28, 0.55, 0.18),
                                        roughness=0.85, voronoi_scale=30.0, bump_strength=0.25)
mats["cherry_blossom"] = make_pbr_simple("v3r2sa_cherry", (0.95, 0.75, 0.85), 0.65,
                                          em=(1.0, 0.85, 0.92), em_str=0.6)
mats["bark"] = make_arch_shader("v3r2sa_bark", (0.20, 0.13, 0.07), (0.30, 0.20, 0.10),
                                 roughness=0.95, voronoi_scale=12.0, bump_strength=0.45)
mats["stone_lantern"] = make_arch_shader("v3r2sa_stone_l", (0.55, 0.50, 0.42), (0.65, 0.60, 0.50),
                                          roughness=0.85, voronoi_scale=14.0, bump_strength=0.20)
mats["candle_flame"]  = make_emit("v3r2sa_candle", (1.0, 0.85, 0.55), 12.0)
mats["fish_orange"]   = make_pbr_simple("v3r2sa_fish_o", (0.95, 0.55, 0.20), 0.30, 0.20,
                                         em=(1.0, 0.65, 0.25), em_str=0.6)
mats["fish_white"]    = make_pbr_simple("v3r2sa_fish_w", (0.92, 0.92, 0.95), 0.30, 0.20)

mats["obelisk_stone"] = make_arch_shader("v3r2sa_obelisk", (0.45, 0.42, 0.40), (0.55, 0.52, 0.48),
                                          roughness=0.85, voronoi_scale=10.0, bump_strength=0.20)
mats["memorial_brass"] = make_arch_shader("v3r2sa_brass", (0.85, 0.65, 0.20), (0.95, 0.78, 0.35),
                                           roughness=0.20, metallic=0.92, voronoi_scale=18.0,
                                           bump_strength=0.10, emission_color=(1.0, 0.85, 0.30), emission_strength=0.7)
mats["candle_wax"]    = make_pbr_simple("v3r2sa_wax", (0.92, 0.88, 0.78), 0.40, 0,
                                         em=(1.0, 0.85, 0.55), em_str=4.0)
mats["wreath_pine"]   = make_arch_shader("v3r2sa_wreath", (0.15, 0.30, 0.12), (0.25, 0.42, 0.18),
                                          roughness=0.85, voronoi_scale=30.0, bump_strength=0.30)
mats["gold_relief"]   = make_arch_shader("v3r2sa_gold_r", (0.95, 0.78, 0.20), (1.0, 0.92, 0.40),
                                          roughness=0.10, metallic=1.0,
                                          emission_color=(1.0, 0.85, 0.40), emission_strength=2.0)

mats["cave_rock"]   = make_arch_shader("v3r2sa_cave", (0.10, 0.09, 0.11), (0.18, 0.15, 0.18),
                                        roughness=0.95, voronoi_scale=8.0, bump_strength=0.55)
mats["moss_wet"]    = make_arch_shader("v3r2sa_moss", (0.12, 0.30, 0.10), (0.20, 0.42, 0.15),
                                        roughness=0.65, voronoi_scale=25.0, bump_strength=0.35)
mats["crystal_blue"] = make_pbr_simple("v3r2sa_cry_b", (0.30, 0.55, 0.95), 0.10, 0,
                                        em=(0.45, 0.75, 1.0), em_str=8.0)
mats["mushroom_glow"] = make_pbr_simple("v3r2sa_mush", (0.65, 0.85, 1.0), 0.40, 0,
                                         em=(0.55, 0.85, 1.0), em_str=6.0)
mats["mushroom_stem"] = make_arch_shader("v3r2sa_mush_s", (0.85, 0.78, 0.65), (0.95, 0.88, 0.75),
                                          roughness=0.85, voronoi_scale=40.0, bump_strength=0.20)
mats["floor"]       = make_pbr_simple("v3r2sa_floor", (0.10, 0.10, 0.12), 0.30, 0.10)

# ============================================================
# UTIL — refined helpers
# ============================================================
def uv_unwrap(obj):
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.02)
    bpy.ops.object.mode_set(mode='OBJECT')

def paint_vertex_color(obj, base_red=0.5, variation=0.4):
    if obj.data.color_attributes:
        ca = obj.data.color_attributes[0]
    else:
        ca = obj.data.color_attributes.new(name="Color", type='FLOAT_COLOR', domain='POINT')
    for i, v in enumerate(obj.data.vertices):
        random.seed(hash((obj.name, i)) & 0xFFFFFF)
        r = max(0.0, min(1.0, base_red + (random.random() - 0.5) * variation * 2))
        ca.data[i].color = (r, r * 0.8, r * 0.6, 1.0)

def add_refined_modifiers(obj, multires_level=1, bevel_segments=5):
    obj.modifiers.new("Multires", 'MULTIRES')
    bpy.context.view_layer.objects.active = obj
    for _ in range(multires_level):
        bpy.ops.object.multires_subdivide(modifier="Multires", mode='CATMULL_CLARK')
    bv = obj.modifiers.new("Bevel", 'BEVEL')
    bv.width = 0.020; bv.segments = bevel_segments; bv.profile = 0.7
    for poly in obj.data.polygons:
        poly.use_smooth = True

def refined_part(name, primitive_op, mat, parent, vc_red=0.5, vc_var=0.4, multires=1, **kwargs):
    primitive_op(**kwargs)
    o = bpy.context.object
    o.name = name
    o.data.materials.append(mat)
    o.parent = parent
    uv_unwrap(o)
    paint_vertex_color(o, base_red=vc_red, variation=vc_var)
    add_refined_modifiers(o, multires_level=multires)
    return o

def r_box(name, loc, scale, mat, parent, vc_red=0.5, vc_var=0.4, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_cube_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     size=1, location=loc)
    o.scale = scale
    o.rotation_euler = rot
    return o

def r_cyl(name, loc, r, depth, mat, parent, vc_red=0.5, vc_var=0.4, verts=18, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_cylinder_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     vertices=verts, radius=r, depth=depth, location=loc)
    o.rotation_euler = rot
    return o

def r_sphere(name, loc, r, mat, parent, vc_red=0.5, vc_var=0.4, segs=20, multires=1):
    return refined_part(name, bpy.ops.mesh.primitive_uv_sphere_add, mat, parent,
                        vc_red=vc_red, vc_var=vc_var, multires=multires,
                        segments=segs, ring_count=segs//2, radius=r, location=loc)

def r_cone(name, loc, r1, r2, depth, mat, parent, vc_red=0.5, vc_var=0.4, verts=14, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_cone_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o.rotation_euler = rot
    return o

def r_torus(name, loc, R, r, mat, parent, vc_red=0.5, vc_var=0.4, ms=24, mn=10, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_torus_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     major_segments=ms, minor_segments=mn,
                     major_radius=R, minor_radius=r, location=loc)
    o.rotation_euler = rot
    return o

def r_ico(name, loc, r, mat, parent, vc_red=0.5, vc_var=0.4, sub=2, multires=1):
    return refined_part(name, bpy.ops.mesh.primitive_ico_sphere_add, mat, parent,
                        vc_red=vc_red, vc_var=vc_var, multires=multires,
                        subdivisions=sub, radius=r, location=loc)

# ============================================================
# SUB-AREA BUILDERS
# ============================================================
def build_sage_garden(origin):
    p = bpy.data.objects.new("sa_sage_garden", None); scene.collection.objects.link(p); p.location = origin
    # Soil floor
    r_box("soil", (0, 0, 0), (12, 12, 0.10), mats["soil_garden"], p, vc_red=0.55, vc_var=0.30)
    # Curved stone path (3 stones across)
    for i, sx in enumerate([-2.0, 0, 2.0]):
        r_cyl(f"path_{i}", (sx, -2, 0.06), 0.50, 0.04, mats["stone_lantern"], p, verts=16)
    # === Koi pond ===
    r_cyl("pond_rim", (0, 1.5, 0.10), 1.80, 0.20, mats["stone_lantern"], p, verts=32, vc_red=0.55, vc_var=0.25)
    r_cyl("pond_water", (0, 1.5, 0.16), 1.65, 0.06, mats["pond_water"], p, verts=32)
    # 3 koi swimming in pond
    for i, (fx, fy, color) in enumerate([(-0.4, 1.7, mats["fish_orange"]),(0.5, 1.4, mats["fish_white"]),(-0.2, 1.2, mats["fish_orange"])]):
        f = r_sphere(f"koi_{i}", (fx, fy, 0.15), 0.10, color, p, segs=14)
        f.scale = (1.6, 0.85, 0.5)
        f.rotation_euler = (0, 0, i*0.7)
    # === Bonsai tree (gnarled trunk + canopy) ===
    bx, by = -3.5, 2.5
    r_cyl("bonsai_trunk", (bx, by, 0.40), 0.10, 0.80, mats["bark"], p, verts=14)
    r_sphere("bonsai_top", (bx, by, 1.10), 0.45, mats["bonsai_leaf"], p, segs=20)
    # Side branches w/ extra leaf clumps
    r_sphere("bonsai_side1", (bx + 0.30, by + 0.10, 1.05), 0.25, mats["bonsai_leaf"], p, segs=14)
    r_sphere("bonsai_side2", (bx - 0.20, by + 0.20, 1.20), 0.20, mats["bonsai_leaf"], p, segs=14)
    # === Cherry blossom tree ===
    cx, cy = 3.5, 2.5
    r_cyl("cherry_trunk", (cx, cy, 0.90), 0.18, 1.80, mats["bark"], p, verts=14)
    # 5 blossom canopy spheres
    for i, (dx, dy, dz) in enumerate([(0, 0, 0.95),(0.50, 0.20, 0.85),(-0.50, 0.20, 0.85),(0.30, -0.40, 0.90),(-0.30, -0.40, 0.90)]):
        r_sphere(f"cherry_{i}", (cx + dx, cy + dy, 1.80 + dz), 0.45, mats["cherry_blossom"], p, segs=18)
    # === Stone lantern ===
    lx, ly = 2.5, -2.0
    r_box("lantern_base", (lx, ly, 0.20), (0.36, 0.36, 0.40), mats["stone_lantern"], p)
    r_cyl("lantern_post", (lx, ly, 0.65), 0.10, 0.50, mats["stone_lantern"], p, verts=12)
    r_box("lantern_top", (lx, ly, 1.00), (0.40, 0.40, 0.20), mats["stone_lantern"], p)
    r_box("lantern_light", (lx, ly, 1.16), (0.22, 0.22, 0.06), mats["candle_flame"], p)
    r_box("lantern_cap", (lx, ly, 1.24), (0.30, 0.30, 0.06), mats["stone_lantern"], p)
    # === Scattered cherry petals ===
    for i, (px, py) in enumerate([(0.5, 0.5),(-0.7, 0.0),(0.3, -0.5),(-1.2, 0.8),(0.8, -1.0),(-0.5, 1.1),(1.2, 1.4)]):
        pt = r_ico(f"petal_{i}", (px, py, 0.07), 0.06, mats["cherry_blossom"], p, sub=1)
        pt.scale = (1.0, 1.0, 0.2)
    return p

def build_memorial(origin):
    p = bpy.data.objects.new("sa_memorial", None); scene.collection.objects.link(p); p.location = origin
    # Stone floor
    r_box("floor", (0, 0, 0), (10, 10, 0.10), mats["obelisk_stone"], p, vc_red=0.55, vc_var=0.30)
    # Border ring
    for i in range(8):
        ang = i * math.pi / 4
        bx = math.cos(ang) * 4.0
        by = math.sin(ang) * 4.0
        r_cyl(f"border_stud_{i}", (bx, by, 0.08), 0.15, 0.12, mats["memorial_brass"], p, verts=14)
    # === Central obelisk ===
    r_box("ped_b1", (0, 0, 0.30), (1.20, 1.20, 0.60), mats["obelisk_stone"], p, vc_red=0.55, vc_var=0.25)
    r_box("ped_b2", (0, 0, 0.70), (1.05, 1.05, 0.20), mats["obelisk_stone"], p)
    r_box("obelisk_shaft", (0, 0, 2.00), (0.50, 0.50, 2.40), mats["obelisk_stone"], p, vc_red=0.55, vc_var=0.25)
    r_cone("obelisk_top", (0, 0, 3.40), 0.50, 0.0, 0.60, mats["obelisk_stone"], p, verts=4, rot=(0, 0, math.pi/4))
    # === Brass plaque on front of shaft ===
    r_box("plaque", (0, -0.52, 1.80), (0.40, 0.04, 0.55), mats["memorial_brass"], p)
    # 4 candles around base
    for i, (cx, cy) in enumerate([(-1.0, -1.0),(1.0, -1.0),(-1.0, 1.0),(1.0, 1.0)]):
        r_cyl(f"candle_{i}", (cx, cy, 0.85), 0.06, 0.30, mats["candle_wax"], p, verts=12)
        r_sphere(f"flame_{i}", (cx, cy, 1.05), 0.05, mats["candle_flame"], p, segs=12)
    # Pine wreath at base of obelisk
    r_torus("wreath", (0, -0.55, 1.10), 0.30, 0.06, mats["wreath_pine"], p, ms=32, mn=10)
    # 4 wreath berries
    for i in range(6):
        ang = i * math.pi / 3
        bx = math.cos(ang) * 0.30
        bz = 1.10 + math.sin(ang) * 0.06
        r_sphere(f"berry_{i}", (bx, -0.50, bz), 0.025, mats["fish_orange"], p, segs=10)
    # Sun glyph relief on backwall (large gold ring + 8 rays)
    bw_y = 4.50
    r_box("backwall", (0, bw_y, 1.80), (5.0, 0.20, 3.60), mats["obelisk_stone"], p)
    r_torus("relief_ring", (0, bw_y - 0.12, 2.20), 0.80, 0.08, mats["gold_relief"], p, ms=48, mn=14, rot=(math.pi/2, 0, 0))
    for i in range(8):
        ang = i * math.pi / 4
        rx = math.cos(ang) * 1.10
        rz = 2.20 + math.sin(ang) * 1.10
        r_box(f"ray_{i}", (rx, bw_y - 0.12, rz), (0.10, 0.04, 0.30), mats["gold_relief"], p, rot=(0, ang + math.pi/2, 0))
    r_sphere("relief_center", (0, bw_y - 0.12, 2.20), 0.20, mats["candle_flame"], p, segs=18)
    return p

def build_hidden_cave(origin):
    p = bpy.data.objects.new("sa_hidden_cave", None); scene.collection.objects.link(p); p.location = origin
    # Cave floor
    r_box("floor", (0, 0, 0), (10, 10, 0.10), mats["cave_rock"], p, vc_red=0.55, vc_var=0.30)
    # Back wall
    r_box("wall_back", (0, 4.0, 1.80), (10, 0.20, 3.60), mats["cave_rock"], p, vc_red=0.55, vc_var=0.30)
    # Side walls
    r_box("wall_l", (-4.95, 0, 1.80), (0.20, 8.0, 3.60), mats["cave_rock"], p)
    r_box("wall_r", (4.95, 0, 1.80), (0.20, 8.0, 3.60), mats["cave_rock"], p)
    # 4 large boulder formations
    for i, (bx, by, bz, sx) in enumerate([(-2.5, 0.5, 0.50, 0.80),(2.5, 0.5, 0.50, 0.75),(-1.0, -2.0, 0.40, 0.60),(1.5, -1.5, 0.40, 0.55)]):
        r = r_ico(f"boulder_{i}", (bx, by, bz), sx, mats["cave_rock"], p, sub=2)
        r.scale = (1.2, 1.0, 0.85)
    # Moss patches on boulders
    for i, (mx, my) in enumerate([(-2.5, 0.5),(2.5, 0.5),(-1.0, -2.0)]):
        m = r_ico(f"moss_{i}", (mx, my, 0.95), 0.40, mats["moss_wet"], p, sub=2)
        m.scale = (1.0, 1.0, 0.3)
    # === Big crystal cluster (centerpiece) ===
    cx, cy = 0, 1.5
    for i, (dx, dy, sz, h) in enumerate([(0, 0, 0.18, 1.4),(0.20, 0.10, 0.13, 1.0),(-0.18, 0.10, 0.12, 0.9),(0.10, -0.18, 0.14, 1.1),(-0.10, -0.10, 0.10, 0.7),(0.05, 0.20, 0.10, 0.8)]):
        r_cone(f"crystal_{i}", (cx + dx, cy + dy, 0.40 + h/2), sz, sz*0.25, h, mats["crystal_blue"], p, verts=8,
                rot=(random.uniform(-0.2, 0.2), random.uniform(-0.2, 0.2), random.uniform(0, math.pi*2)))
    # === Glowing mushroom clusters ===
    for cluster_i, (mcx, mcy) in enumerate([(-3.0, -2.0),(3.0, -2.0),(-3.0, 2.0),(3.0, 2.0)]):
        for i in range(4):
            ang = i * (math.pi*2/4)
            mx = mcx + math.cos(ang) * 0.15
            my = mcy + math.sin(ang) * 0.15
            h = 0.20 + (i % 2) * 0.06
            r_cyl(f"mush_st_{cluster_i}_{i}", (mx, my, h/2 + 0.06), 0.04, h, mats["mushroom_stem"], p, verts=10)
            cap = r_sphere(f"mush_cap_{cluster_i}_{i}", (mx, my, h + 0.06), 0.10, mats["mushroom_glow"], p, segs=14)
            cap.scale.z = 0.7
    # 8 floating particle motes around crystal
    for i in range(8):
        ang = i * (math.pi*2/8)
        ex = math.cos(ang) * 1.40
        ey = 1.5 + math.sin(ang) * 0.60
        ez = 0.8 + math.sin(i*1.5) * 0.40
        r_sphere(f"mote_{i}", (ex, ey, ez), 0.05, mats["crystal_blue"], p, segs=12)
    # Hanging stalactites from ceiling
    for i, (sx, sy) in enumerate([(-1.5, 0),(1.5, 0),(0, -1.5),(-2.5, 1.5),(2.5, 1.5)]):
        r_cone(f"stalactite_{i}", (sx, sy, 3.20), 0.20, 0.0, 0.80, mats["cave_rock"], p, verts=8, rot=(math.pi, 0, 0))
    return p

# ============================================================
# SCENE LAYOUT — 3 sub-areas spaced apart
# ============================================================
build_sage_garden(Vector((0, 0, 0)))
build_memorial(Vector((30, 0, 0)))
build_hidden_cave(Vector((60, 0, 0)))

# ============================================================
# LIGHTING — per sub-area accent points + 3-point overall
# ============================================================
# Sage Garden — warm afternoon
bpy.ops.object.light_add(type='AREA', location=(6, -10, 8))
g_key = bpy.context.object
g_key.data.energy = 1500; g_key.data.color = (1.0, 0.85, 0.55); g_key.data.size = 8

# Memorial — warm sunset glow
bpy.ops.object.light_add(type='AREA', location=(36, -10, 8))
m_key = bpy.context.object
m_key.data.energy = 1400; m_key.data.color = (1.0, 0.78, 0.45); m_key.data.size = 8
# Memorial back glow (sun glyph)
bpy.ops.object.light_add(type='POINT', location=(30, 4.0, 2.20))
m_glow = bpy.context.object
m_glow.data.energy = 800; m_glow.data.color = (1.0, 0.85, 0.40)

# Hidden Cave — cool blue
bpy.ops.object.light_add(type='SPOT', location=(63, -8, 6))
c_key = bpy.context.object
c_key.data.energy = 2200; c_key.data.color = (0.40, 0.65, 1.0)
c_key.data.spot_size = math.radians(80); c_key.data.spot_blend = 0.35
direction = Vector((60, 0, 1.5)) - c_key.location
c_key.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
# Crystal accent point at center crystal cluster
bpy.ops.object.light_add(type='POINT', location=(60, 1.5, 1.0))
c_acc = bpy.context.object
c_acc.data.energy = 600; c_acc.data.color = (0.45, 0.75, 1.0)

# Overall fill
bpy.ops.object.light_add(type='AREA', location=(30, 12, 8))
fill = bpy.context.object
fill.data.energy = 800; fill.data.color = (0.55, 0.65, 0.95); fill.data.size = 14

# ============================================================
# CAMERAS
# ============================================================
def add_cam(name, loc, target, lens=50, dof_dist=10, fstop=4.5):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = fstop
    c.data.dof.focus_distance = dof_dist
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_garden  = add_cam("cam_garden",   Vector((6, -8, 4)), Vector((0, 0, 1.0)), lens=40, dof_dist=10)
cam_memorial = add_cam("cam_memorial", Vector((35, -8, 4)), Vector((30, 0, 2.0)), lens=40, dof_dist=10)
cam_cave    = add_cam("cam_cave",      Vector((65, -7, 3.5)), Vector((60, 1.5, 1.0)), lens=40, dof_dist=8)
cam_overview = add_cam("cam_overview", Vector((30, -15, 14)), Vector((30, 0, 1.5)), lens=32, dof_dist=22)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

CAMERAS = [
    ("overview", cam_overview),
    ("garden",   cam_garden),
    ("memorial", cam_memorial),
    ("cave",     cam_cave),
]
for name, cam in CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_r2_subarea_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Per-subarea GLB
for name in ["sage_garden", "memorial", "hidden_cave"]:
    bpy.ops.object.select_all(action='DESELECT')
    parent_obj = bpy.data.objects.get(f"sa_{name}")
    if parent_obj:
        parent_obj.select_set(True)
        for child in parent_obj.children_recursive:
            child.select_set(True)
        out_path = os.path.join(EXPORT_DIR, f"subarea_{name}_r2_v3.glb")
        bpy.ops.export_scene.gltf(
            filepath=out_path, use_selection=True,
            export_format='GLB', export_apply=True
        )
        print(f"Exported: {out_path}")

print("=== V3 Round 2 Epic R2-08 Sub-Area Refinement complete ===")
