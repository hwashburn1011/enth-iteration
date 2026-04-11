"""
Expansion V3 — Epic 25 — Decoration Library Texture Pass
========================================================
50 placeable decoration props across 5 categories of 10:

  FURNITURE (10):  chair, stool, bench, dining table, side table, bookshelf,
                    dresser, cabinet, desk, wardrobe
  SOFT (10):       cushion sq, pillow long, folded blanket, small rug,
                    round rug, throw, tapestry, banner, curtain, mat
  CERAMIC (10):    vase tall, vase wide, bowl, plate, jug, urn, planter,
                    kettle, teapot, pitcher
  LANTERNS (10):   hanging, table, wall sconce, lamp post, candle holder,
                    brazier, oil lamp, lantern stake, chandelier, torch
  MISC (10):       clock, mirror, painting frame, bookend pair, statue,
                    hourglass, telescope, globe, music box, treasure chest

Each prop uses V3 5-layer PBR shaders + subdivision + bevel. No prop
exceeds 12 parts to keep build/render time reasonable across 50 items.

Outputs:
  - 1 grid hero render @ 1920x1080
  - 5 category close-ups @ 1280x720
  - 50 GLB exports
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(25)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/buildings/v3_decorations.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/buildings/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/buildings/exports"
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

scene.world = bpy.data.worlds.new("v3_dec_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.06, 0.06, 0.08, 1)
bg.inputs["Strength"].default_value = 0.6

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

# ============================================================
# MATERIALS
# ============================================================
mats = {}
mats["wood_dark"]   = make_pbr("v3dec_wood_d", (0.18, 0.10, 0.05), 0.85,
    noise_strength=0.30, voronoi_strength=0.45, voronoi_scale=12.0, bump_strength=0.20, bump_scale=18.0)
mats["wood_med"]    = make_pbr("v3dec_wood_m", (0.42, 0.26, 0.13), 0.85,
    noise_strength=0.30, voronoi_strength=0.45, voronoi_scale=12.0, bump_strength=0.22, bump_scale=18.0)
mats["wood_light"]  = make_pbr("v3dec_wood_l", (0.62, 0.42, 0.22), 0.85,
    noise_strength=0.25, voronoi_strength=0.40, voronoi_scale=14.0, bump_strength=0.18, bump_scale=18.0)
mats["fabric_red"]  = make_pbr("v3dec_fab_r", (0.55, 0.15, 0.10), 0.85,
    noise_strength=0.30, curvature_dirt=True, bump_strength=0.20, bump_scale=50.0)
mats["fabric_blue"] = make_pbr("v3dec_fab_b", (0.15, 0.30, 0.55), 0.85,
    noise_strength=0.30, curvature_dirt=True, bump_strength=0.20, bump_scale=50.0)
mats["fabric_green"] = make_pbr("v3dec_fab_g", (0.20, 0.42, 0.15), 0.85,
    noise_strength=0.30, curvature_dirt=True, bump_strength=0.20, bump_scale=50.0)
mats["fabric_white"] = make_pbr("v3dec_fab_w", (0.92, 0.90, 0.85), 0.85,
    noise_strength=0.20, curvature_dirt=True, bump_strength=0.20, bump_scale=50.0)
mats["fabric_purple"] = make_pbr("v3dec_fab_p", (0.45, 0.20, 0.65), 0.85,
    noise_strength=0.30, curvature_dirt=True, bump_strength=0.20, bump_scale=50.0)
mats["ceramic_white"] = make_pbr("v3dec_cer_w", (0.85, 0.82, 0.78), 0.30, 0,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.05, bump_scale=80.0)
mats["ceramic_blue"]  = make_pbr("v3dec_cer_b", (0.30, 0.45, 0.85), 0.30, 0,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.05, bump_scale=80.0)
mats["ceramic_red"]   = make_pbr("v3dec_cer_r", (0.65, 0.20, 0.20), 0.30, 0,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.05, bump_scale=80.0)
mats["clay_brown"]    = make_pbr("v3dec_clay", (0.55, 0.32, 0.18), 0.65,
    noise_strength=0.20, voronoi_strength=0.20, voronoi_scale=40.0, bump_strength=0.15, bump_scale=40.0)
mats["iron"]         = make_pbr("v3dec_iron", (0.18, 0.18, 0.20), 0.45, 0.85,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.10, bump_scale=22.0)
mats["brass"]        = make_pbr("v3dec_brass", (0.85, 0.65, 0.20), 0.20, 0.92,
    emission_color=(1.0, 0.85, 0.30), emission_strength=0.5,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True)
mats["gold"]         = make_pbr("v3dec_gold", (0.95, 0.78, 0.20), 0.10, 1.0,
    emission_color=(1.0, 0.85, 0.40), emission_strength=1.0,
    noise_strength=0.05, curvature_dirt=True, fresnel_rim=True)
mats["glass"]        = make_pbr("v3dec_glass", (0.85, 0.92, 0.95), 0.05, 0.0,
    emission_color=(0.95, 0.98, 1.0), emission_strength=0.4,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["lamp_warm"]    = make_pbr("v3dec_lamp_w", (1.0, 0.80, 0.40), 0.20, 0,
    emission_color=(1.0, 0.80, 0.40), emission_strength=10.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["fire"]         = make_pbr("v3dec_fire", (1.0, 0.55, 0.10), 0.10, 0,
    emission_color=(1.0, 0.55, 0.10), emission_strength=14.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["paper"]        = make_pbr("v3dec_paper", (0.92, 0.86, 0.72), 0.85,
    noise_strength=0.15, curvature_dirt=True, bump_strength=0.10, bump_scale=80.0)
mats["leather"]      = make_pbr("v3dec_leather", (0.30, 0.16, 0.08), 0.55,
    noise_strength=0.25, voronoi_strength=0.20, voronoi_scale=80.0, bump_strength=0.20, bump_scale=80.0)
mats["stone_grey"]   = make_pbr("v3dec_stone", (0.45, 0.42, 0.40), 0.85,
    noise_strength=0.25, voronoi_strength=0.30, voronoi_scale=10.0, bump_strength=0.15, bump_scale=14.0)
mats["floor"]        = make_pbr("v3dec_floor", (0.10, 0.10, 0.12), 0.30, 0.10,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.05)

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

def cyl(name, loc, r, depth, mat, parent, verts=14, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=r, depth=depth, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    return o

def sph(name, loc, r, mat, parent, segs=16):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segs, ring_count=segs//2, radius=r, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=2, bevel=0.005)
    o.parent = parent
    return o

def cone(name, loc, r1, r2, depth, mat, parent, verts=12, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    return o

def tor(name, loc, R, r, mat, parent, ms=20, mn=10, rot=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_segments=ms, minor_segments=mn, major_radius=R, minor_radius=r, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.005)
    o.parent = parent
    return o

# ============================================================
# 50 DECORATION BUILDERS — each takes (origin) and returns parent
# ============================================================
def make_parent(name, origin):
    p = bpy.data.objects.new(name, None); scene.collection.objects.link(p); p.location = origin
    return p

# ----- FURNITURE (10) -----
def dec_chair(o):
    p = make_parent("dec_chair", o)
    box("seat", (0, 0, 0.40), (0.50, 0.50, 0.06), mats["wood_med"], p)
    box("back", (0, 0.22, 0.65), (0.50, 0.04, 0.50), mats["wood_med"], p)
    for cx, cy in [(-0.20,-0.20),(0.20,-0.20),(-0.20,0.20),(0.20,0.20)]:
        box(f"l_{cx}_{cy}", (cx, cy, 0.20), (0.06, 0.06, 0.40), mats["wood_dark"], p)
    box("cushion", (0, 0, 0.46), (0.45, 0.45, 0.04), mats["fabric_red"], p)
    return p

def dec_stool(o):
    p = make_parent("dec_stool", o)
    cyl("seat", (0, 0, 0.40), 0.20, 0.06, mats["wood_med"], p)
    for i in range(3):
        ang = i * (math.pi*2/3)
        lx = math.cos(ang) * 0.15
        ly = math.sin(ang) * 0.15
        cyl(f"l_{i}", (lx, ly, 0.20), 0.025, 0.40, mats["wood_dark"], p)
    return p

def dec_bench(o):
    p = make_parent("dec_bench", o)
    box("seat", (0, 0, 0.40), (1.20, 0.35, 0.08), mats["wood_med"], p)
    for cx, cy in [(-0.50,-0.13),(0.50,-0.13),(-0.50,0.13),(0.50,0.13)]:
        box(f"l_{cx}_{cy}", (cx, cy, 0.20), (0.06, 0.06, 0.40), mats["wood_dark"], p)
    return p

def dec_dining_table(o):
    p = make_parent("dec_dining_table", o)
    box("top", (0, 0, 0.75), (1.40, 0.80, 0.06), mats["wood_med"], p)
    for cx, cy in [(-0.55,-0.30),(0.55,-0.30),(-0.55,0.30),(0.55,0.30)]:
        box(f"l_{cx}_{cy}", (cx, cy, 0.36), (0.08, 0.08, 0.74), mats["wood_dark"], p)
    return p

def dec_side_table(o):
    p = make_parent("dec_side_table", o)
    cyl("top", (0, 0, 0.50), 0.30, 0.05, mats["wood_med"], p)
    cyl("post", (0, 0, 0.25), 0.05, 0.50, mats["wood_dark"], p)
    cyl("base", (0, 0, 0.02), 0.20, 0.04, mats["wood_dark"], p, verts=18)
    return p

def dec_bookshelf(o):
    p = make_parent("dec_bookshelf", o)
    box("frame", (0, 0, 0.80), (0.80, 0.30, 1.60), mats["wood_dark"], p)
    box("interior", (0, 0.05, 0.80), (0.72, 0.20, 1.50), mats["wood_med"], p)
    for s in range(4):
        z = 0.20 + s * 0.40
        box(f"shelf_{s}", (0, 0, z), (0.72, 0.30, 0.04), mats["wood_dark"], p)
        for j in range(5):
            x = -0.28 + j * 0.14
            color = [mats["fabric_red"], mats["leather"], mats["fabric_blue"]][j % 3]
            box(f"book_{s}_{j}", (x, 0, z+0.20), (0.10, 0.20, 0.30), color, p)
    return p

def dec_dresser(o):
    p = make_parent("dec_dresser", o)
    box("body", (0, 0, 0.50), (0.80, 0.40, 1.0), mats["wood_dark"], p)
    box("top", (0, 0, 1.02), (0.85, 0.45, 0.04), mats["wood_med"], p)
    for d in range(3):
        z = 0.30 + d * 0.30
        box(f"drawer_{d}", (0, 0.21, z), (0.74, 0.04, 0.24), mats["wood_med"], p)
        sph(f"knob_{d}", (-0.15, 0.24, z), 0.025, mats["brass"], p, segs=10)
        sph(f"knob2_{d}", (0.15, 0.24, z), 0.025, mats["brass"], p, segs=10)
    return p

def dec_cabinet(o):
    p = make_parent("dec_cabinet", o)
    box("body", (0, 0, 0.65), (0.70, 0.40, 1.30), mats["wood_dark"], p)
    box("top", (0, 0, 1.32), (0.75, 0.45, 0.04), mats["wood_med"], p)
    box("door_l", (-0.18, 0.21, 0.65), (0.32, 0.04, 1.10), mats["wood_med"], p)
    box("door_r", (0.18, 0.21, 0.65), (0.32, 0.04, 1.10), mats["wood_med"], p)
    sph("handle_l", (-0.30, 0.24, 0.65), 0.025, mats["brass"], p, segs=10)
    sph("handle_r", (0.30, 0.24, 0.65), 0.025, mats["brass"], p, segs=10)
    return p

def dec_desk(o):
    p = make_parent("dec_desk", o)
    box("top", (0, 0, 0.75), (1.20, 0.60, 0.06), mats["wood_med"], p)
    box("drawer", (0, 0.10, 0.55), (1.10, 0.40, 0.18), mats["wood_dark"], p)
    sph("d_knob", (0, 0.31, 0.55), 0.025, mats["brass"], p, segs=10)
    box("l1", (-0.55, 0, 0.36), (0.06, 0.50, 0.74), mats["wood_dark"], p)
    box("l2", (0.55, 0, 0.36), (0.06, 0.50, 0.74), mats["wood_dark"], p)
    return p

def dec_wardrobe(o):
    p = make_parent("dec_wardrobe", o)
    box("body", (0, 0, 1.00), (0.80, 0.50, 2.00), mats["wood_dark"], p)
    box("top_trim", (0, 0, 2.04), (0.85, 0.55, 0.06), mats["wood_med"], p)
    box("door_l", (-0.20, 0.26, 1.00), (0.36, 0.04, 1.85), mats["wood_med"], p)
    box("door_r", (0.20, 0.26, 1.00), (0.36, 0.04, 1.85), mats["wood_med"], p)
    sph("hl", (-0.32, 0.29, 1.00), 0.03, mats["brass"], p, segs=10)
    sph("hr", (0.32, 0.29, 1.00), 0.03, mats["brass"], p, segs=10)
    return p

# ----- SOFT (10) -----
def dec_cushion_sq(o):
    p = make_parent("dec_cushion_sq", o)
    box("c", (0, 0, 0.10), (0.40, 0.40, 0.16), mats["fabric_red"], p)
    return p

def dec_pillow_long(o):
    p = make_parent("dec_pillow_long", o)
    box("c", (0, 0, 0.10), (0.60, 0.25, 0.14), mats["fabric_blue"], p)
    return p

def dec_blanket_folded(o):
    p = make_parent("dec_blanket_folded", o)
    box("c", (0, 0, 0.10), (0.50, 0.40, 0.18), mats["fabric_green"], p)
    box("c2", (0, 0, 0.20), (0.50, 0.40, 0.04), mats["fabric_white"], p)
    return p

def dec_rug_small(o):
    p = make_parent("dec_rug_small", o)
    box("r", (0, 0, 0.02), (0.80, 0.50, 0.02), mats["fabric_red"], p)
    box("trim", (0, 0, 0.025), (0.74, 0.44, 0.005), mats["fabric_white"], p)
    return p

def dec_rug_round(o):
    p = make_parent("dec_rug_round", o)
    cyl("r", (0, 0, 0.02), 0.50, 0.02, mats["fabric_blue"], p, verts=32)
    cyl("trim", (0, 0, 0.025), 0.45, 0.005, mats["fabric_white"], p, verts=32)
    return p

def dec_throw(o):
    p = make_parent("dec_throw", o)
    box("c", (0, 0, 0.05), (0.55, 0.45, 0.10), mats["fabric_purple"], p, rot=(0, 0, 0.3))
    box("c2", (0.10, 0.10, 0.10), (0.40, 0.30, 0.06), mats["fabric_purple"], p, rot=(0.1, 0.1, 0.6))
    return p

def dec_tapestry(o):
    p = make_parent("dec_tapestry", o)
    box("c", (0, 0, 0.50), (0.60, 0.04, 1.00), mats["fabric_red"], p)
    box("rod", (0, 0, 1.02), (0.70, 0.04, 0.04), mats["wood_dark"], p)
    box("trim_t", (0, -0.02, 0.96), (0.55, 0.02, 0.04), mats["gold"], p)
    return p

def dec_banner(o):
    p = make_parent("dec_banner", o)
    cyl("rod", (0, 0, 0.50), 0.025, 1.0, mats["wood_dark"], p, verts=10)
    box("flag", (0.20, 0, 0.70), (0.40, 0.02, 0.50), mats["fabric_blue"], p)
    return p

def dec_curtain(o):
    p = make_parent("dec_curtain", o)
    box("rod", (0, 0, 1.00), (0.80, 0.04, 0.04), mats["brass"], p)
    box("c1", (-0.18, 0, 0.50), (0.30, 0.04, 0.96), mats["fabric_red"], p)
    box("c2", (0.18, 0, 0.50), (0.30, 0.04, 0.96), mats["fabric_red"], p)
    sph("rod_l", (-0.42, 0, 1.00), 0.05, mats["brass"], p, segs=12)
    sph("rod_r", (0.42, 0, 1.00), 0.05, mats["brass"], p, segs=12)
    return p

def dec_mat(o):
    p = make_parent("dec_mat", o)
    box("c", (0, 0, 0.015), (0.50, 0.30, 0.015), mats["fabric_green"], p)
    return p

# ----- CERAMIC (10) -----
def dec_vase_tall(o):
    p = make_parent("dec_vase_tall", o)
    cyl("base", (0, 0, 0.05), 0.10, 0.10, mats["ceramic_blue"], p)
    cyl("body", (0, 0, 0.40), 0.13, 0.55, mats["ceramic_blue"], p, verts=20)
    cyl("neck", (0, 0, 0.72), 0.07, 0.10, mats["ceramic_blue"], p, verts=16)
    cyl("rim", (0, 0, 0.78), 0.10, 0.04, mats["ceramic_blue"], p, verts=18)
    return p

def dec_vase_wide(o):
    p = make_parent("dec_vase_wide", o)
    sph("body", (0, 0, 0.20), 0.22, mats["ceramic_red"], p, segs=20)
    cyl("rim", (0, 0, 0.36), 0.16, 0.04, mats["ceramic_red"], p, verts=18)
    return p

def dec_bowl(o):
    p = make_parent("dec_bowl", o)
    sph("b", (0, 0, 0.10), 0.20, mats["ceramic_white"], p, segs=20)
    cyl("rim", (0, 0, 0.20), 0.20, 0.02, mats["ceramic_white"], p, verts=20)
    return p

def dec_plate(o):
    p = make_parent("dec_plate", o)
    cyl("p", (0, 0, 0.04), 0.30, 0.04, mats["ceramic_white"], p, verts=24)
    cyl("rim", (0, 0, 0.06), 0.30, 0.005, mats["ceramic_blue"], p, verts=24)
    return p

def dec_jug(o):
    p = make_parent("dec_jug", o)
    sph("body", (0, 0, 0.25), 0.18, mats["clay_brown"], p, segs=18)
    cyl("neck", (0, 0, 0.42), 0.08, 0.10, mats["clay_brown"], p, verts=14)
    tor("handle", (0.18, 0, 0.30), 0.08, 0.02, mats["clay_brown"], p, ms=14, mn=8, rot=(math.pi/2, 0, 0))
    return p

def dec_urn(o):
    p = make_parent("dec_urn", o)
    cyl("base", (0, 0, 0.05), 0.12, 0.10, mats["ceramic_blue"], p)
    sph("body", (0, 0, 0.30), 0.20, mats["ceramic_blue"], p, segs=18)
    cyl("neck", (0, 0, 0.50), 0.10, 0.06, mats["ceramic_blue"], p, verts=14)
    box("lid", (0, 0, 0.55), (0.22, 0.22, 0.04), mats["brass"], p)
    sph("knob", (0, 0, 0.60), 0.04, mats["brass"], p, segs=10)
    return p

def dec_planter(o):
    p = make_parent("dec_planter", o)
    cyl("body", (0, 0, 0.18), 0.22, 0.30, mats["clay_brown"], p, verts=20)
    cyl("rim", (0, 0, 0.34), 0.24, 0.04, mats["clay_brown"], p, verts=20)
    sph("plant", (0, 0, 0.45), 0.20, mats["fabric_green"], p, segs=14)
    return p

def dec_kettle(o):
    p = make_parent("dec_kettle", o)
    sph("body", (0, 0, 0.15), 0.20, mats["iron"], p, segs=18)
    cyl("lid", (0, 0, 0.32), 0.12, 0.04, mats["iron"], p, verts=14)
    sph("knob", (0, 0, 0.36), 0.03, mats["brass"], p, segs=8)
    cyl("spout", (0.20, 0, 0.20), 0.04, 0.20, mats["iron"], p, verts=10, rot=(0, math.pi/3, 0))
    tor("handle", (0, 0, 0.40), 0.20, 0.02, mats["iron"], p, ms=14, mn=8, rot=(0, math.pi/2, 0))
    return p

def dec_teapot(o):
    p = make_parent("dec_teapot", o)
    sph("body", (0, 0, 0.15), 0.18, mats["ceramic_white"], p, segs=18)
    cyl("lid", (0, 0, 0.30), 0.10, 0.03, mats["ceramic_white"], p, verts=14)
    sph("knob", (0, 0, 0.34), 0.025, mats["ceramic_blue"], p, segs=8)
    cyl("spout", (0.18, 0, 0.18), 0.03, 0.18, mats["ceramic_white"], p, verts=10, rot=(0, math.pi/3, 0))
    tor("handle", (-0.20, 0, 0.18), 0.10, 0.02, mats["ceramic_white"], p, ms=14, mn=8, rot=(0, math.pi/2, 0))
    return p

def dec_pitcher(o):
    p = make_parent("dec_pitcher", o)
    cyl("body", (0, 0, 0.20), 0.13, 0.40, mats["ceramic_blue"], p, verts=18)
    cyl("rim", (0, 0, 0.42), 0.14, 0.02, mats["ceramic_blue"], p, verts=18)
    tor("handle", (-0.15, 0, 0.20), 0.10, 0.02, mats["ceramic_blue"], p, ms=14, mn=8, rot=(0, math.pi/2, 0))
    return p

# ----- LANTERNS (10) -----
def dec_lantern_hanging(o):
    p = make_parent("dec_lantern_hanging", o)
    cyl("chain", (0, 0, 0.85), 0.012, 0.30, mats["iron"], p, verts=8)
    box("top", (0, 0, 0.65), (0.15, 0.15, 0.04), mats["iron"], p)
    box("body", (0, 0, 0.50), (0.18, 0.18, 0.30), mats["glass"], p)
    box("bot", (0, 0, 0.34), (0.15, 0.15, 0.04), mats["iron"], p)
    sph("flame", (0, 0, 0.50), 0.06, mats["lamp_warm"], p, segs=12)
    return p

def dec_lantern_table(o):
    p = make_parent("dec_lantern_table", o)
    cyl("base", (0, 0, 0.04), 0.10, 0.04, mats["iron"], p)
    cyl("body", (0, 0, 0.20), 0.08, 0.30, mats["glass"], p, verts=14)
    cyl("top", (0, 0, 0.38), 0.10, 0.04, mats["iron"], p, verts=14)
    sph("flame", (0, 0, 0.20), 0.05, mats["lamp_warm"], p, segs=12)
    return p

def dec_sconce(o):
    p = make_parent("dec_sconce", o)
    box("plate", (0, 0, 0.50), (0.04, 0.20, 0.30), mats["iron"], p)
    cyl("arm", (0.10, 0, 0.50), 0.025, 0.20, mats["iron"], p, verts=8, rot=(0, math.pi/2, 0))
    cyl("bowl", (0.20, 0, 0.55), 0.10, 0.06, mats["iron"], p, verts=14)
    sph("flame", (0.20, 0, 0.65), 0.10, mats["lamp_warm"], p, segs=12)
    return p

def dec_lamp_post(o):
    p = make_parent("dec_lamp_post", o)
    cyl("base", (0, 0, 0.10), 0.15, 0.20, mats["iron"], p, verts=18)
    cyl("post", (0, 0, 0.80), 0.04, 1.40, mats["iron"], p, verts=12)
    box("top", (0, 0, 1.55), (0.20, 0.20, 0.30), mats["glass"], p)
    sph("flame", (0, 0, 1.55), 0.08, mats["lamp_warm"], p, segs=12)
    return p

def dec_candle_holder(o):
    p = make_parent("dec_candle_holder", o)
    cyl("base", (0, 0, 0.04), 0.10, 0.04, mats["brass"], p, verts=18)
    cyl("stem", (0, 0, 0.16), 0.025, 0.20, mats["brass"], p, verts=10)
    cyl("cup", (0, 0, 0.28), 0.05, 0.04, mats["brass"], p, verts=12)
    cyl("candle", (0, 0, 0.40), 0.04, 0.20, mats["fabric_white"], p, verts=10)
    sph("flame", (0, 0, 0.55), 0.04, mats["fire"], p, segs=10)
    return p

def dec_brazier(o):
    p = make_parent("dec_brazier", o)
    cyl("base", (0, 0, 0.10), 0.20, 0.20, mats["iron"], p)
    cyl("post", (0, 0, 0.45), 0.04, 0.50, mats["iron"], p, verts=10)
    sph("bowl", (0, 0, 0.78), 0.20, mats["iron"], p, segs=18)
    cyl("fuel", (0, 0, 0.92), 0.18, 0.04, mats["fire"], p, verts=18)
    sph("flame", (0, 0, 1.05), 0.14, mats["fire"], p, segs=12)
    return p

def dec_oil_lamp(o):
    p = make_parent("dec_oil_lamp", o)
    sph("body", (0, 0, 0.08), 0.13, mats["brass"], p, segs=16)
    cyl("spout", (0.15, 0, 0.10), 0.025, 0.10, mats["brass"], p, verts=10, rot=(0, math.pi/2 - 0.3, 0))
    sph("flame", (0.22, 0, 0.13), 0.04, mats["fire"], p, segs=10)
    tor("handle", (-0.12, 0, 0.10), 0.06, 0.015, mats["brass"], p, ms=12, mn=8, rot=(0, math.pi/2, 0))
    return p

def dec_lantern_stake(o):
    p = make_parent("dec_lantern_stake", o)
    cone("stake", (0, 0, 0.20), 0.025, 0.005, 0.40, mats["iron"], p, verts=8)
    box("body", (0, 0, 0.55), (0.10, 0.10, 0.20), mats["glass"], p)
    box("top", (0, 0, 0.66), (0.12, 0.12, 0.04), mats["iron"], p)
    sph("flame", (0, 0, 0.55), 0.05, mats["lamp_warm"], p, segs=12)
    return p

def dec_chandelier(o):
    p = make_parent("dec_chandelier", o)
    cyl("chain", (0, 0, 0.75), 0.012, 0.50, mats["brass"], p, verts=8)
    cyl("hub", (0, 0, 0.42), 0.05, 0.10, mats["brass"], p, verts=14)
    tor("ring", (0, 0, 0.40), 0.25, 0.02, mats["brass"], p, ms=24, mn=8)
    for i in range(6):
        ang = i * (math.pi*2/6)
        cx = math.cos(ang) * 0.25
        cy = math.sin(ang) * 0.25
        cyl(f"c_{i}", (cx, cy, 0.46), 0.025, 0.10, mats["fabric_white"], p, verts=10)
        sph(f"f_{i}", (cx, cy, 0.55), 0.04, mats["fire"], p, segs=10)
    return p

def dec_torch(o):
    p = make_parent("dec_torch", o)
    cyl("handle", (0, 0, 0.30), 0.025, 0.60, mats["wood_dark"], p, verts=10)
    cyl("head", (0, 0, 0.65), 0.05, 0.10, mats["leather"], p, verts=12)
    sph("flame", (0, 0, 0.78), 0.10, mats["fire"], p, segs=12)
    sph("flame2", (0, 0, 0.88), 0.06, mats["fire"], p, segs=10)
    return p

# ----- MISC (10) -----
def dec_clock(o):
    p = make_parent("dec_clock", o)
    cyl("face", (0, 0, 0.50), 0.25, 0.06, mats["wood_dark"], p, verts=24, rot=(math.pi/2, 0, 0))
    cyl("face_in", (0, -0.04, 0.50), 0.22, 0.02, mats["fabric_white"], p, verts=24, rot=(math.pi/2, 0, 0))
    box("hand_h", (0, -0.07, 0.50), (0.02, 0.005, 0.10), mats["iron"], p)
    box("hand_m", (0.04, -0.08, 0.55), (0.005, 0.005, 0.14), mats["iron"], p)
    sph("center", (0, -0.06, 0.50), 0.015, mats["brass"], p, segs=10)
    return p

def dec_mirror(o):
    p = make_parent("dec_mirror", o)
    box("frame", (0, 0, 0.50), (0.40, 0.04, 0.60), mats["wood_dark"], p)
    box("glass", (0, -0.02, 0.50), (0.34, 0.02, 0.54), mats["glass"], p)
    return p

def dec_painting(o):
    p = make_parent("dec_painting", o)
    box("frame", (0, 0, 0.50), (0.50, 0.04, 0.40), mats["gold"], p)
    box("canvas", (0, -0.02, 0.50), (0.42, 0.02, 0.32), mats["fabric_white"], p)
    return p

def dec_bookend(o):
    p = make_parent("dec_bookend", o)
    box("end_l", (-0.20, 0, 0.10), (0.04, 0.20, 0.20), mats["brass"], p)
    box("end_r", (0.20, 0, 0.10), (0.04, 0.20, 0.20), mats["brass"], p)
    for i in range(4):
        x = -0.16 + i * 0.10
        color = [mats["fabric_red"], mats["leather"], mats["fabric_blue"]][i % 3]
        box(f"book_{i}", (x, 0, 0.12), (0.08, 0.18, 0.22), color, p)
    return p

def dec_statue(o):
    p = make_parent("dec_statue", o)
    box("base", (0, 0, 0.10), (0.30, 0.30, 0.20), mats["stone_grey"], p)
    cyl("body", (0, 0, 0.50), 0.10, 0.40, mats["stone_grey"], p, verts=14)
    sph("head", (0, 0, 0.78), 0.12, mats["stone_grey"], p, segs=14)
    return p

def dec_hourglass(o):
    p = make_parent("dec_hourglass", o)
    cyl("top_b", (0, 0, 0.55), 0.10, 0.04, mats["wood_dark"], p)
    cone("top_c", (0, 0, 0.40), 0.10, 0.02, 0.30, mats["glass"], p, verts=14)
    cone("bot_c", (0, 0, 0.20), 0.02, 0.10, 0.30, mats["glass"], p, verts=14)
    cyl("bot_b", (0, 0, 0.04), 0.10, 0.04, mats["wood_dark"], p)
    return p

def dec_telescope(o):
    p = make_parent("dec_telescope", o)
    for i in range(3):
        x = -0.10 + i * 0.10
        cyl(f"l_{i}", (x, 0, 0.20), 0.025, 0.40, mats["wood_dark"], p, verts=8,
             rot=(math.cos(i * 2)*0.3, 0.2, 0))
    cyl("scope", (0, 0, 0.50), 0.05, 0.30, mats["brass"], p, verts=12,
         rot=(math.radians(75), 0, 0))
    cyl("lens", (0, 0.20, 0.62), 0.06, 0.06, mats["brass"], p, verts=14,
         rot=(math.radians(75), 0, 0))
    return p

def dec_globe(o):
    p = make_parent("dec_globe", o)
    cyl("base", (0, 0, 0.04), 0.10, 0.04, mats["wood_dark"], p)
    cyl("post", (0, 0, 0.16), 0.025, 0.20, mats["brass"], p, verts=10)
    sph("globe", (0, 0, 0.40), 0.18, mats["leather"], p, segs=20)
    tor("ring", (0, 0, 0.40), 0.20, 0.012, mats["brass"], p, ms=24, mn=8, rot=(math.pi/2, 0, 0))
    return p

def dec_music_box(o):
    p = make_parent("dec_music_box", o)
    box("body", (0, 0, 0.10), (0.30, 0.20, 0.20), mats["wood_dark"], p)
    box("lid", (0, 0, 0.21), (0.30, 0.20, 0.02), mats["wood_med"], p, rot=(0.4, 0, 0))
    sph("knob", (0.12, 0.10, 0.10), 0.02, mats["brass"], p, segs=10)
    box("inlay", (0, 0, 0.20), (0.18, 0.10, 0.005), mats["gold"], p)
    return p

def dec_chest(o):
    p = make_parent("dec_chest", o)
    box("body", (0, 0, 0.20), (0.50, 0.30, 0.30), mats["wood_dark"], p)
    box("lid", (0, 0, 0.40), (0.50, 0.30, 0.10), mats["wood_med"], p)
    box("lock", (0, 0.16, 0.35), (0.06, 0.04, 0.10), mats["brass"], p)
    box("strap1", (-0.20, 0, 0.20), (0.04, 0.30, 0.30), mats["iron"], p)
    box("strap2", (0.20, 0, 0.20), (0.04, 0.30, 0.30), mats["iron"], p)
    return p

# ============================================================
# LAYOUT — 50 props in 10 cols × 5 rows
# ============================================================
parent = bpy.data.objects.new("v3_decorations", None); scene.collection.objects.link(parent)

bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, -0.05))
fl = bpy.context.object; fl.name = "dec_floor"; fl.scale = (24, 14, 0.10)
fl.data.materials.append(mats["floor"]); add_subsurf_bevel(fl, levels=1, bevel=0.005)

DECORATIONS = [
    # Furniture row
    ("chair", dec_chair), ("stool", dec_stool), ("bench", dec_bench),
    ("dining_table", dec_dining_table), ("side_table", dec_side_table),
    ("bookshelf", dec_bookshelf), ("dresser", dec_dresser), ("cabinet", dec_cabinet),
    ("desk", dec_desk), ("wardrobe", dec_wardrobe),
    # Soft row
    ("cushion_sq", dec_cushion_sq), ("pillow_long", dec_pillow_long),
    ("blanket_folded", dec_blanket_folded), ("rug_small", dec_rug_small),
    ("rug_round", dec_rug_round), ("throw", dec_throw),
    ("tapestry", dec_tapestry), ("banner", dec_banner),
    ("curtain", dec_curtain), ("mat", dec_mat),
    # Ceramic row
    ("vase_tall", dec_vase_tall), ("vase_wide", dec_vase_wide),
    ("bowl", dec_bowl), ("plate", dec_plate), ("jug", dec_jug),
    ("urn", dec_urn), ("planter", dec_planter), ("kettle", dec_kettle),
    ("teapot", dec_teapot), ("pitcher", dec_pitcher),
    # Lanterns row
    ("lantern_hanging", dec_lantern_hanging), ("lantern_table", dec_lantern_table),
    ("sconce", dec_sconce), ("lamp_post", dec_lamp_post),
    ("candle_holder", dec_candle_holder), ("brazier", dec_brazier),
    ("oil_lamp", dec_oil_lamp), ("lantern_stake", dec_lantern_stake),
    ("chandelier", dec_chandelier), ("torch", dec_torch),
    # Misc row
    ("clock", dec_clock), ("mirror", dec_mirror), ("painting", dec_painting),
    ("bookend", dec_bookend), ("statue", dec_statue),
    ("hourglass", dec_hourglass), ("telescope", dec_telescope),
    ("globe", dec_globe), ("music_box", dec_music_box), ("chest", dec_chest),
]

COL_SPACING = 2.0
ROW_SPACING = 2.5
DEC_OBJS = []
for idx, (name, builder) in enumerate(DECORATIONS):
    col = idx % 10
    row = idx // 10
    x = -9 + col * COL_SPACING
    y = -5 + row * ROW_SPACING
    origin = Vector((x, y, 0))
    obj = builder(origin)
    obj.parent = parent
    DEC_OBJS.append((name, obj))

# ============================================================
# LIGHTING
# ============================================================
bpy.ops.object.light_add(type='AREA', location=(8, -12, 14))
key = bpy.context.object
key.data.energy = 2500; key.data.color = (1.0, 0.95, 0.85); key.data.size = 14

bpy.ops.object.light_add(type='AREA', location=(-8, 12, 12))
fill = bpy.context.object
fill.data.energy = 1000; fill.data.color = (0.65, 0.78, 1.0); fill.data.size = 14

bpy.ops.object.light_add(type='AREA', location=(0, 14, 6))
rim = bpy.context.object
rim.data.energy = 700; rim.data.color = (1.0, 0.85, 0.55); rim.data.size = 12

# ============================================================
# CAMERAS
# ============================================================
def add_cam(name, loc, target, lens=50, dof_dist=4):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = 6.3
    c.data.dof.focus_distance = dof_dist
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_grid = add_cam("cam_grid", Vector((0, -16, 14)), Vector((0, 0, 0.5)), lens=28, dof_dist=20)

CAT_NAMES = ["furniture", "soft", "ceramic", "lanterns", "misc"]
CAT_CAMS = []
for r, name in enumerate(CAT_NAMES):
    y = -5 + r * ROW_SPACING
    cam = add_cam(f"cam_{name}", Vector((0, y - 4, 2.5)), Vector((0, y, 0.6)), lens=50, dof_dist=6)
    CAT_CAMS.append((name, cam))

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render
scene.camera = cam_grid
scene.render.resolution_x = 1920; scene.render.resolution_y = 1080
scene.render.filepath = os.path.join(RENDER_DIR, "v3_decorations_grid.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.render.resolution_x = 1280; scene.render.resolution_y = 720
for name, cam in CAT_CAMS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_decorations_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Per-decoration GLB exports
for name, obj in DEC_OBJS:
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    for child in obj.children_recursive:
        child.select_set(True)
    out_path = os.path.join(EXPORT_DIR, f"dec_{name}_v3.glb")
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=True
    )

print("=== V3 Epic 25 Decoration Library complete ===")
