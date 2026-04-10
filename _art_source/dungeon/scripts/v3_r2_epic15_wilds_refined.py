"""
Expansion V3 — ROUND 2 — Epic R2-15 — Corrupted Wilds Refinement
================================================================
Round 2 of V3-15 Corrupted Wilds. Refined twisted forest glade
with full Round 2 stack (UV unwrap + vertex color paint + multires
+ 5-seg bevel + vertex-color-aware shaders) on every prop, but with
plain (non-multires) terrain for performance.

CRITICAL: NO world volumetrics — per V3-15 saved feedback rule, dense
biome scenes hang Cycles when volumetric scatter is enabled. R1 of
V3-15 originally hung the renderer until volumetrics were removed.

Layout: 16x16 corrupted glade with:
  - Displaced corrupted soil terrain (60-cut subdivided plane)
  - Slope-blended corruption shader (purple seams + emission)
  - 4 twisted dead trees w/ Round 2 stack
  - 3 mire pools w/ ripple shader
  - 8 glowing fungi clusters
  - 4 thorn vines crawling
  - 6 floating corruption motes
  - Central corruption altar (3-tier base + crystal cluster + 4 floating
    cracked stone fragments)

Outputs: 3 hero renders + 1 GLB export.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector, noise as bnoise

random.seed(115)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/dungeon/v3_r2_corrupted_wilds.blend"
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

scene.world = bpy.data.worlds.new("v3r2cw_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.04, 0.02, 0.06, 1)
bg.inputs["Strength"].default_value = 0.4
# NO volumetrics — per saved memory rule

# ============================================================
# CUSTOM CORRUPTED SOIL SHADER (no VC since terrain isn't refined_part)
# ============================================================
def make_corrupted_soil():
    m = bpy.data.materials.new("v3r2cw_soil")
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

    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
    n.inputs["Scale"].default_value = 6.0
    n.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])
    soil_ramp = nodes.new("ShaderNodeValToRGB"); soil_ramp.location = (-450, 200)
    soil_ramp.color_ramp.elements[0].position = 0.30
    soil_ramp.color_ramp.elements[0].color = (0.06, 0.04, 0.10, 1)
    soil_ramp.color_ramp.elements[1].position = 0.70
    soil_ramp.color_ramp.elements[1].color = (0.18, 0.10, 0.22, 1)
    links.new(n.outputs["Fac"], soil_ramp.inputs["Fac"])

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

    mix = nodes.new("ShaderNodeMix"); mix.data_type='RGBA'; mix.location = (-200, 100)
    links.new(crack_ramp.outputs["Color"], mix.inputs["Factor"])
    links.new(soil_ramp.outputs["Color"], mix.inputs[6])
    mix.inputs[7].default_value = (0.04, 0.02, 0.08, 1)
    links.new(mix.outputs[2], bsdf.inputs["Base Color"])

    glow = nodes.new("ShaderNodeMix"); glow.data_type='RGBA'; glow.location = (100, -100)
    links.new(crack_ramp.outputs["Color"], glow.inputs["Factor"])
    glow.inputs[6].default_value = (0, 0, 0, 1)
    glow.inputs[7].default_value = (0.85, 0.30, 1.0, 1)
    links.new(glow.outputs[2], bsdf.inputs["Emission Color"])

    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -300)
    bp.inputs["Strength"].default_value = 0.5
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_mire_water():
    m = bpy.data.materials.new("v3r2cw_mire")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1200, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (900, 0)
    bsdf.inputs["Base Color"].default_value = (0.10, 0.30, 0.10, 1)
    bsdf.inputs["Roughness"].default_value = 0.10
    bsdf.inputs["Transmission Weight"].default_value = 0.40
    bsdf.inputs["IOR"].default_value = 1.4
    bsdf.inputs["Emission Color"].default_value = (0.30, 0.85, 0.30, 1)
    bsdf.inputs["Emission Strength"].default_value = 2.5
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-900, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-700, 0)
    mp.inputs["Scale"].default_value = (5, 5, 5)
    links.new(tc.outputs["Object"], mp.inputs["Vector"])
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

def make_arch(name, base_color, accent_color, roughness=0.85,
              voronoi_scale=10.0, bump_strength=0.30,
              emission_color=None, emission_strength=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1300, 0)
    bsdf.inputs["Roughness"].default_value = roughness
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
    v.feature = 'F1'; v.inputs["Scale"].default_value = voronoi_scale
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
    ar.color_ramp.elements[0].color = (0.05, 0.02, 0.06, 1)
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

def make_simple(name, color, rough, metal=0.0, em=None, em_str=0):
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
mats["soil"] = make_corrupted_soil()
mats["mire"] = make_mire_water()
mats["bark_twisted"] = make_arch("v3r2cw_bark", (0.10, 0.05, 0.10), (0.18, 0.10, 0.18),
                                   roughness=0.95, voronoi_scale=10.0, bump_strength=0.55)
mats["bark_glow"] = make_arch("v3r2cw_bark_glow", (0.20, 0.08, 0.30), (0.30, 0.15, 0.42),
                               roughness=0.65, voronoi_scale=12.0, bump_strength=0.40,
                               emission_color=(0.85, 0.30, 1.0), emission_strength=2.5)
mats["fungi_purple"] = make_simple("v3r2cw_fungi_p", (0.65, 0.20, 0.95), 0.30, 0,
                                     em=(0.85, 0.30, 1.0), em_str=8.0)
mats["fungi_cyan"]   = make_simple("v3r2cw_fungi_c", (0.30, 0.85, 1.0), 0.30, 0,
                                     em=(0.40, 0.95, 1.0), em_str=8.0)
mats["fungi_stem"] = make_arch("v3r2cw_fungi_stem", (0.45, 0.32, 0.35), (0.55, 0.42, 0.45),
                                 roughness=0.85, voronoi_scale=40.0, bump_strength=0.25)
mats["thorn"] = make_arch("v3r2cw_thorn", (0.10, 0.05, 0.05), (0.18, 0.10, 0.10),
                            roughness=0.85, voronoi_scale=18.0, bump_strength=0.30,
                            emission_color=(0.85, 0.20, 0.50), emission_strength=0.4)
mats["mote"] = make_simple("v3r2cw_mote", (0.85, 0.30, 1.0), 0.10, 0,
                             em=(0.95, 0.45, 1.0), em_str=14.0)
mats["altar_stone"] = make_arch("v3r2cw_altar", (0.18, 0.10, 0.20), (0.28, 0.16, 0.28),
                                  roughness=0.85, voronoi_scale=10.0, bump_strength=0.40,
                                  emission_color=(0.55, 0.20, 0.85), emission_strength=0.6)
mats["altar_crystal"] = make_simple("v3r2cw_crystal", (0.65, 0.20, 0.95), 0.10, 0,
                                      em=(0.85, 0.30, 1.0), em_str=12.0)
mats["root"] = make_arch("v3r2cw_root", (0.08, 0.04, 0.08), (0.15, 0.08, 0.15),
                           roughness=0.95, voronoi_scale=14.0, bump_strength=0.40,
                           emission_color=(0.85, 0.30, 1.0), emission_strength=0.4)

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
    bv.width = 0.015; bv.segments = bevel_segments; bv.profile = 0.7
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

def r_cyl(name, loc, r, depth, mat, parent, vc_red=0.5, vc_var=0.4, verts=14, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_cylinder_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     vertices=verts, radius=r, depth=depth, location=loc)
    o.rotation_euler = rot
    return o

def r_sphere(name, loc, r, mat, parent, vc_red=0.5, vc_var=0.4, segs=18, multires=1):
    return refined_part(name, bpy.ops.mesh.primitive_uv_sphere_add, mat, parent,
                        vc_red=vc_red, vc_var=vc_var, multires=multires,
                        segments=segs, ring_count=segs//2, radius=r, location=loc)

def r_ico(name, loc, r, mat, parent, vc_red=0.5, vc_var=0.4, sub=2, multires=1):
    return refined_part(name, bpy.ops.mesh.primitive_ico_sphere_add, mat, parent,
                        vc_red=vc_red, vc_var=vc_var, multires=multires,
                        subdivisions=sub, radius=r, location=loc)

def r_cone(name, loc, r1, r2, depth, mat, parent, vc_red=0.5, vc_var=0.4, verts=14, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_cone_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o.rotation_euler = rot
    return o

# ============================================================
# DISPLACED TERRAIN — small subdivision, NO multires
# ============================================================
parent = bpy.data.objects.new("v3_r2_corrupted_wilds", None); scene.collection.objects.link(parent)

TERRAIN_SIZE = 16
TERRAIN_SUB = 60
bpy.ops.mesh.primitive_plane_add(size=TERRAIN_SIZE, location=(0, 0, 0))
terrain = bpy.context.object
terrain.name = "cw_terrain"
bm = bmesh.new()
bm.from_mesh(terrain.data)
bmesh.ops.subdivide_edges(bm, edges=bm.edges, cuts=TERRAIN_SUB, use_grid_fill=True)
bm.to_mesh(terrain.data)
bm.free()
terrain.data.update()

for v in terrain.data.vertices:
    x, y = v.co.x, v.co.y
    h  = bnoise.noise(Vector((x*0.10, y*0.10, 0))) * 1.0
    h += bnoise.noise(Vector((x*0.30, y*0.30, 5))) * 0.4
    d = math.sqrt(x*x + y*y)
    if d < 2.0:
        h += (2.0 - d) * 0.5
    v.co.z = h

terrain.data.materials.append(mats["soil"])
for poly in terrain.data.polygons: poly.use_smooth = True
terrain.parent = parent

def terrain_h(x, y):
    h  = bnoise.noise(Vector((x*0.10, y*0.10, 0))) * 1.0
    h += bnoise.noise(Vector((x*0.30, y*0.30, 5))) * 0.4
    d = math.sqrt(x*x + y*y)
    if d < 2.0:
        h += (2.0 - d) * 0.5
    return h

# ============================================================
# 4 TWISTED DEAD TREES
# ============================================================
def twisted_tree(name, x, y):
    base_z = terrain_h(x, y)
    trunk_h = random.uniform(3.0, 4.0)
    r_cyl(f"{name}_trunk", (x, y, base_z + trunk_h/2), 0.28, trunk_h, mats["bark_twisted"], parent,
           vc_red=0.55, vc_var=0.30, verts=14, multires=1)
    # 4 secondary branches
    for i in range(4):
        ang = i * (math.pi*2/4) + random.uniform(-0.2, 0.2)
        bx = x + math.cos(ang) * 0.3
        by = y + math.sin(ang) * 0.3
        bz = base_z + trunk_h - 0.2
        r_cyl(f"{name}_b_{i}", (bx, by, bz + 0.7), 0.10, 1.4, mats["bark_twisted"], parent,
               vc_red=0.55, vc_var=0.30, verts=10,
               rot=(0.5 + math.sin(ang)*0.3, math.cos(ang)*0.3, ang))
    # 4 purple glow tendrils
    for i in range(4):
        ang = i * math.pi/2 + 0.3
        gx = x + math.cos(ang) * 0.30
        gy = y + math.sin(ang) * 0.30
        gz = base_z + 0.6 + i * 0.4
        r_ico(f"{name}_g_{i}", (gx, gy, gz), 0.10, mats["bark_glow"], parent,
               vc_red=0.55, vc_var=0.30)
    # 4 exposed roots at base
    for i in range(4):
        ang = i * math.pi/2
        rx = x + math.cos(ang) * 0.45
        ry = y + math.sin(ang) * 0.45
        r_cyl(f"{name}_r_{i}", (rx, ry, base_z + 0.10), 0.07, 0.5, mats["root"], parent,
               vc_red=0.55, vc_var=0.30, verts=8, rot=(math.pi/2 + 0.3, 0, ang))

TREE_POSITIONS = [(-5, -5), (5, -5), (-5, 5), (5, 5)]
for i, (tx, ty) in enumerate(TREE_POSITIONS):
    twisted_tree(f"tree_{i}", tx, ty)

# ============================================================
# 3 MIRE POOLS
# ============================================================
def mire_pool(name, x, y, r):
    base_z = terrain_h(x, y)
    r_cyl(f"{name}_p", (x, y, base_z + 0.10), r, 0.04, mats["mire"], parent,
           vc_red=0.5, vc_var=0.10, verts=24)
    r_cyl(f"{name}_rim", (x, y, base_z + 0.05), r * 1.10, 0.02, mats["bark_twisted"], parent,
           vc_red=0.55, vc_var=0.30, verts=24)

mire_pool("mire_0", -3, -2, 0.7)
mire_pool("mire_1",  3,  2, 0.8)
mire_pool("mire_2",  0,  4, 0.6)

# ============================================================
# 8 GLOWING FUNGI CLUSTERS
# ============================================================
def fungi_cluster(name, x, y):
    base_z = terrain_h(x, y)
    color_mat = random.choice([mats["fungi_purple"], mats["fungi_cyan"]])
    for i in range(4):
        ang = i * (math.pi*2/4)
        sx = x + math.cos(ang) * 0.15
        sy = y + math.sin(ang) * 0.15
        h = random.uniform(0.20, 0.40)
        r_cyl(f"{name}_{i}_st", (sx, sy, base_z + h/2 + 0.05), 0.04, h, mats["fungi_stem"], parent,
               vc_red=0.55, vc_var=0.20, verts=10)
        cap = r_sphere(f"{name}_{i}_cap", (sx, sy, base_z + h + 0.05), 0.13, color_mat, parent,
                        vc_red=0.5, vc_var=0.15, segs=14)
        cap.scale.z = 0.7

FUNGI_POSITIONS = [(-2, 1), (1, -2), (3, -1), (-1, 4), (-4, 1), (2, 4), (4, 4), (-3, -3)]
for i, (fx, fy) in enumerate(FUNGI_POSITIONS):
    fungi_cluster(f"fg_{i}", fx, fy)

# ============================================================
# 4 THORN VINES
# ============================================================
def thorn_vine(name, x, y, length, angle):
    for i in range(5):
        sx = x + math.cos(angle) * (i * length/5)
        sy = y + math.sin(angle) * (i * length/5)
        sz = terrain_h(sx, sy) + 0.06 + math.sin(i * 0.8) * 0.05
        r_cyl(f"{name}_s_{i}", (sx, sy, sz), 0.05, length/5 * 1.1, mats["thorn"], parent,
               vc_red=0.55, vc_var=0.30, verts=8,
               rot=(0, math.pi/2, angle + math.sin(i)*0.2))
        if i % 2 == 0:
            r_cone(f"{name}_th_{i}", (sx, sy, sz + 0.10), 0.025, 0.0, 0.10, mats["thorn"], parent,
                    vc_red=0.55, vc_var=0.30, verts=5)

THORN_LAYOUTS = [(-2, -3, 1.8, 0.5), (3, -2, 1.6, 1.8), (-3, 2, 1.6, 2.5), (2, 4, 1.8, 4.0)]
for i, (x, y, l, a) in enumerate(THORN_LAYOUTS):
    thorn_vine(f"th_{i}", x, y, l, a)

# ============================================================
# 6 FLOATING CORRUPTION MOTES
# ============================================================
MOTE_POSITIONS = [(-2, -2, 1.5), (2, 2, 1.8), (4, -1, 1.4), (-4, 1, 1.6), (0, 4, 2.0), (-3, -3, 1.6)]
for i, (x, y, z) in enumerate(MOTE_POSITIONS):
    r_sphere(f"mote_{i}", (x, y, terrain_h(x, y) + z), 0.07, mats["mote"], parent,
              vc_red=0.5, vc_var=0.10, segs=14)

# ============================================================
# CENTRAL CORRUPTION ALTAR
# ============================================================
ax, ay = 0, 0
az = terrain_h(ax, ay)
r_cyl("alt_b1", (ax, ay, az + 0.20), 1.2, 0.40, mats["altar_stone"], parent,
       vc_red=0.55, vc_var=0.30, verts=20)
r_cyl("alt_b2", (ax, ay, az + 0.55), 1.0, 0.30, mats["altar_stone"], parent,
       vc_red=0.55, vc_var=0.30, verts=20)
r_cyl("alt_b3", (ax, ay, az + 0.85), 0.8, 0.30, mats["altar_stone"], parent,
       vc_red=0.55, vc_var=0.30, verts=20)
# Crystal cluster
for i, (dx, dy, sz, h) in enumerate([(0,0,0.20,1.2),(0.18,0.10,0.14,0.9),(-0.15,0.10,0.13,0.85),(0.10,-0.20,0.16,1.0),(-0.10,-0.10,0.10,0.7)]):
    r_cone(f"alt_cr_{i}", (ax+dx, ay+dy, az + 1.05 + h/2), sz, sz*0.25, h, mats["altar_crystal"], parent,
           vc_red=0.5, vc_var=0.10, verts=8,
           rot=(random.uniform(-0.15, 0.15), random.uniform(-0.15, 0.15), random.uniform(0, math.pi*2)))
# 4 floating cracked stones
for i in range(4):
    ang = i * (math.pi*2/4)
    sx = ax + math.cos(ang) * 1.6
    sy = ay + math.sin(ang) * 1.6
    sz_pos = az + 1.4 + math.sin(ang*2) * 0.3
    fr = r_ico(f"alt_fr_{i}", (sx, sy, sz_pos), 0.20, mats["altar_stone"], parent,
                vc_red=0.55, vc_var=0.30)
    fr.scale = (1.2, 0.8, 0.6)

# Strong purple altar light
bpy.ops.object.light_add(type='POINT', location=(0, 0, 1.8))
ap = bpy.context.object
ap.data.energy = 1500; ap.data.color = (0.85, 0.30, 1.0)

# ============================================================
# LIGHTING — atmosphere via lighting only, NO volumetrics
# ============================================================
bpy.ops.object.light_add(type='SPOT', location=(6, -10, 12))
key = bpy.context.object
key.data.energy = 4500; key.data.color = (0.45, 0.65, 1.0)
key.data.spot_size = math.radians(80); key.data.spot_blend = 0.4
direction = Vector((0, 0, 0)) - key.location
key.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

bpy.ops.object.light_add(type='AREA', location=(-8, 8, 6))
rim = bpy.context.object
rim.data.energy = 800; rim.data.color = (1.0, 0.45, 0.20); rim.data.size = 8

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

cam_glade = add_cam("cam_glade", Vector((8, -10, 5)), Vector((0, 0, 1)), lens=35, dof_dist=12)
cam_fungi = add_cam("cam_fungi", Vector((-2, -1, 1.0)), Vector((-3, 1, 0.5)), lens=70, dof_dist=2)
cam_altar = add_cam("cam_altar", Vector((3, -3, 2.5)), Vector((0, 0, 2.0)), lens=50, dof_dist=4)

bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

CAMERAS = [
    ("glade", cam_glade),
    ("fungi", cam_fungi),
    ("altar", cam_altar),
]
for name, cam in CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_r2_wilds_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Export GLB
bpy.ops.object.select_all(action='DESELECT')
parent.select_set(True)
for child in parent.children_recursive:
    child.select_set(True)
terrain.select_set(True)
out_path = os.path.join(EXPORT_DIR, "corrupted_wilds_r2_v3.glb")
bpy.ops.export_scene.gltf(
    filepath=out_path, use_selection=True,
    export_format='GLB', export_apply=True
)
print(f"Exported: {out_path}")

print("=== V3 Round 2 Epic R2-15 Corrupted Wilds Refinement complete ===")
