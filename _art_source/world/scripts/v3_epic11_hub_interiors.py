"""
Expansion V3 — Epic 11 — Hub Expansion Interior Texturing
=========================================================
14 hub interior dioramas, each with storytelling-grade prop dressing.

  1. Lounge Bar          — lacquered bar w/ liquor wall + glasses + lamp
  2. Sage's Study        — leather-bound bookshelves + writing desk + scrolls
  3. Training Arena      — sand floor + weapon racks + dummy + banner
  4. Fishing Dock        — boardwalk interior + tackle + lantern
  5. Cooking Station     — hearth + cauldron + spice rack + cutting board
  6. Grand Library       — tall bookcase wall + reading table + globe
  7. Workshop            — workbench + tool wall + forge stub + bellows
  8. Greenhouse          — planter beds + glass roof beams + watering can
  9. Player Bedroom      — bed + dresser + nightstand + window pane
 10. Bath House          — sunken stone tub + steam lamps + towel rack
 11. Music Hall          — grand piano-ish keyboard + harp + sheet stand
 12. Map Room            — round table + giant map + brass instruments
 13. Trophy Hall         — column pedestals w/ trophies + plaques
 14. Meditation Chamber  — circular rug + candles + incense + low cushion

Each interior uses full V3 5-layer PBR shader graph (noise+voronoi+
curvature dirt+fresnel rim+procedural normal), subdivision surface,
bevel modifiers, and 3-point cinematic lighting tuned per room mood.

Outputs: 14 hero shots @ 1600x1200 + 14 GLB exports.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(11)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/v3_hub_interiors.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/exports"
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 96
scene.render.resolution_x = 1600
scene.render.resolution_y = 1200
scene.view_settings.look = 'AgX - High Contrast'
scene.world = bpy.data.worlds.new("v3_hub_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.03, 0.04, 0.06, 1)
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
# SHARED MATERIAL LIBRARY
# ============================================================
mats = {}
mats["wood_dark"] = make_pbr("v3hi_wood_dark", (0.18,0.10,0.05), 0.65, 0.05,
    noise_strength=0.30, voronoi_strength=0.40, voronoi_scale=10.0, bump_strength=0.20, bump_scale=18.0)
mats["wood_med"] = make_pbr("v3hi_wood_med", (0.42,0.26,0.13), 0.85, 0.0,
    noise_strength=0.30, voronoi_strength=0.45, voronoi_scale=12.0, bump_strength=0.22, bump_scale=18.0)
mats["wood_light"] = make_pbr("v3hi_wood_light", (0.62,0.42,0.22), 0.85, 0.0,
    noise_strength=0.25, voronoi_strength=0.40, voronoi_scale=14.0, bump_strength=0.18, bump_scale=18.0)
mats["leather_red"] = make_pbr("v3hi_leather_red", (0.45,0.10,0.08), 0.55, 0.0,
    noise_strength=0.25, voronoi_strength=0.20, voronoi_scale=80.0, bump_strength=0.20, bump_scale=80.0)
mats["leather_brown"] = make_pbr("v3hi_leather_brown", (0.30,0.16,0.08), 0.55, 0.0,
    noise_strength=0.25, voronoi_strength=0.20, voronoi_scale=80.0, bump_strength=0.20, bump_scale=80.0)
mats["stone_grey"] = make_pbr("v3hi_stone_grey", (0.50,0.48,0.45), 0.85, 0.0,
    noise_strength=0.25, voronoi_strength=0.45, voronoi_scale=10.0, bump_strength=0.25, bump_scale=14.0)
mats["stone_warm"] = make_pbr("v3hi_stone_warm", (0.62,0.55,0.42), 0.85, 0.0,
    noise_strength=0.25, voronoi_strength=0.45, voronoi_scale=10.0, bump_strength=0.25, bump_scale=14.0)
mats["brass"] = make_pbr("v3hi_brass", (0.85,0.65,0.20), 0.20, 0.95,
    emission_color=(1.0,0.85,0.30), emission_strength=0.5,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True)
mats["iron"] = make_pbr("v3hi_iron", (0.30,0.30,0.32), 0.45, 0.85,
    noise_strength=0.10, curvature_dirt=True)
mats["gold"] = make_pbr("v3hi_gold", (0.95,0.78,0.20), 0.10, 1.0,
    emission_color=(1.0,0.92,0.40), emission_strength=0.6,
    noise_strength=0.05, curvature_dirt=True, fresnel_rim=True)
mats["fabric_red"] = make_pbr("v3hi_fab_red", (0.55,0.15,0.10), 0.85, 0.0,
    noise_strength=0.30, curvature_dirt=True, bump_strength=0.20, bump_scale=50.0)
mats["fabric_blue"] = make_pbr("v3hi_fab_blue", (0.15,0.30,0.55), 0.85, 0.0,
    noise_strength=0.30, curvature_dirt=True, bump_strength=0.20, bump_scale=50.0)
mats["fabric_white"] = make_pbr("v3hi_fab_white", (0.92,0.90,0.85), 0.85, 0.0,
    noise_strength=0.20, curvature_dirt=True, bump_strength=0.20, bump_scale=50.0)
mats["paper"] = make_pbr("v3hi_paper", (0.92,0.86,0.72), 0.85, 0.0,
    noise_strength=0.15, curvature_dirt=True, bump_strength=0.10, bump_scale=80.0)
mats["plant"] = make_pbr("v3hi_plant", (0.18,0.40,0.12), 0.85, 0.0,
    noise_strength=0.40, curvature_dirt=True, bump_strength=0.25, bump_scale=45.0)
mats["sand"] = make_pbr("v3hi_sand", (0.78,0.65,0.42), 0.95, 0.0,
    noise_strength=0.30, voronoi_strength=0.30, voronoi_scale=80.0, bump_strength=0.25, bump_scale=80.0)
mats["water"] = make_pbr("v3hi_water", (0.10,0.30,0.45), 0.10, 0.0,
    emission_color=(0.20,0.45,0.60), emission_strength=0.5,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True, bump_strength=0.05, bump_scale=80.0)
mats["glass"] = make_pbr("v3hi_glass", (0.85,0.92,0.95), 0.05, 0.0,
    emission_color=(0.95,0.98,1.0), emission_strength=0.4,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["bottle_green"] = make_pbr("v3hi_bot_green", (0.10,0.35,0.15), 0.10, 0.0,
    emission_color=(0.20,0.55,0.30), emission_strength=0.4,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["bottle_amber"] = make_pbr("v3hi_bot_amber", (0.65,0.35,0.10), 0.10, 0.0,
    emission_color=(0.95,0.55,0.20), emission_strength=0.4,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["bottle_blue"] = make_pbr("v3hi_bot_blue", (0.10,0.30,0.55), 0.10, 0.0,
    emission_color=(0.30,0.55,0.95), emission_strength=0.4,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["lamp_warm"] = make_pbr("v3hi_lamp_warm", (1.0,0.80,0.40), 0.20, 0.0,
    emission_color=(1.0,0.80,0.40), emission_strength=8.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["candle_flame"] = make_pbr("v3hi_candle", (1.0,0.85,0.50), 0.20, 0.0,
    emission_color=(1.0,0.85,0.50), emission_strength=10.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["fire"] = make_pbr("v3hi_fire", (1.0,0.45,0.10), 0.20, 0.0,
    emission_color=(1.0,0.50,0.15), emission_strength=14.0,
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

def sph(name, loc, r, mat, parent, segs=20):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segs, ring_count=segs//2, radius=r, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=2, bevel=0.005)
    o.parent = parent
    return o

def tor(name, loc, R, r, mat, parent, ms=24, mn=12):
    bpy.ops.mesh.primitive_torus_add(major_segments=ms, minor_segments=mn, major_radius=R, minor_radius=r, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.005)
    o.parent = parent
    return o

def cone(name, loc, r1, r2, depth, mat, parent, verts=18):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    return o

def floor_walls(parent, floor_mat, wall_mat, sx=6, sy=5):
    """Build a corner room floor + back wall + side wall."""
    bpy.ops.mesh.primitive_plane_add(size=1, location=(0,0,0))
    f = bpy.context.object; f.name = "fl"; f.scale = (sx, sy, 1)
    f.data.materials.append(floor_mat); add_subsurf_bevel(f, levels=1, bevel=0.002); f.parent = parent
    bpy.ops.mesh.primitive_plane_add(size=1, location=(0, sy/2, 1.6))
    bw = bpy.context.object; bw.name = "bw"; bw.scale = (sx, 3.2, 1)
    bw.rotation_euler = (math.pi/2, 0, 0)
    bw.data.materials.append(wall_mat); add_subsurf_bevel(bw, levels=1, bevel=0.002); bw.parent = parent
    bpy.ops.mesh.primitive_plane_add(size=1, location=(-sx/2, 0, 1.6))
    sw = bpy.context.object; sw.name = "sw"; sw.scale = (sy, 3.2, 1)
    sw.rotation_euler = (math.pi/2, 0, math.pi/2)
    sw.data.materials.append(wall_mat); add_subsurf_bevel(sw, levels=1, bevel=0.002); sw.parent = parent

def lights(origin, key_color=(1,0.85,0.5), key_energy=900, fill_color=(0.45,0.55,0.85), fill_energy=300):
    bpy.ops.object.light_add(type='AREA', location=(origin[0]+3, origin[1]-3, origin[2]+4))
    k = bpy.context.object; k.data.energy=key_energy; k.data.color=key_color; k.data.size=4
    bpy.ops.object.light_add(type='AREA', location=(origin[0]-3, origin[1]+2, origin[2]+3))
    f = bpy.context.object; f.data.energy=fill_energy; f.data.color=fill_color; f.data.size=4

# ============================================================
# 14 INTERIOR BUILDERS
# ============================================================
def hub_lounge(p, o):
    floor_walls(p, mats["wood_dark"], mats["wood_med"])
    box("bar", (0,1.0,0.6), (3.0,0.6,1.2), mats["wood_dark"], p)
    box("bar_top", (0,1.0,1.22), (3.05,0.65,0.05), mats["wood_dark"], p)
    # liquor wall shelves
    for i in range(2):
        z = 1.9 + i*0.5
        box(f"shelf_{i}", (0, 2.35, z), (2.6,0.18,0.04), mats["wood_med"], p)
        for j in range(6):
            x = -1.1 + j*0.45
            mat = [mats["bottle_green"], mats["bottle_amber"], mats["bottle_blue"]][j%3]
            cyl(f"bot_{i}_{j}", (x, 2.35, z+0.20), 0.06, 0.36, mat, p)
    for i, x in enumerate([-1.0, 0, 1.0]):
        cyl(f"st_top_{i}", (x, 0.0, 0.50), 0.18, 0.08, mats["wood_med"], p)
        cyl(f"st_p_{i}", (x, 0.0, 0.22), 0.04, 0.42, mats["iron"], p)
    cyl("lamp_chain", (0,0.5,2.4), 0.02, 0.8, mats["iron"], p)
    sph("lamp", (0,0.5,1.85), 0.18, mats["lamp_warm"], p)
    bpy.ops.object.light_add(type='POINT', location=(o[0],o[1]+0.5,o[2]+1.85))
    lp = bpy.context.object; lp.data.energy=400; lp.data.color=(1,0.78,0.45)
    lights(o, key_color=(1,0.75,0.40), key_energy=650, fill_color=(0.40,0.50,0.85), fill_energy=200)

def hub_study(p, o):
    floor_walls(p, mats["wood_med"], mats["leather_brown"])
    # bookshelf wall (3 shelves x 8 books)
    for s in range(3):
        z = 0.4 + s*0.7
        box(f"sh_{s}", (-1.8, 2.1, z+0.30), (3.2, 0.30, 0.05), mats["wood_dark"], p)
        for j in range(10):
            x = -3.30 + j*0.30
            color = [mats["leather_red"], mats["leather_brown"], mats["fabric_blue"]][j%3]
            box(f"bk_{s}_{j}", (x, 2.1, z+0.55), (0.10, 0.22, 0.45), color, p)
    # writing desk
    box("desk", (1.0, 0.0, 0.45), (1.6, 0.8, 0.06), mats["wood_dark"], p)
    box("desk_l1", (0.3, -0.3, 0.22), (0.06, 0.06, 0.42), mats["wood_dark"], p)
    box("desk_l2", (1.7, -0.3, 0.22), (0.06, 0.06, 0.42), mats["wood_dark"], p)
    box("desk_l3", (0.3, 0.3, 0.22), (0.06, 0.06, 0.42), mats["wood_dark"], p)
    box("desk_l4", (1.7, 0.3, 0.22), (0.06, 0.06, 0.42), mats["wood_dark"], p)
    # scroll
    cyl("scroll", (0.6, -0.2, 0.50), 0.05, 0.40, mats["paper"], p, rot=(0, math.pi/2, 0))
    # ink pot
    cyl("ink", (1.4, 0.1, 0.52), 0.06, 0.10, mats["iron"], p)
    cyl("quill", (1.45, 0.1, 0.62), 0.005, 0.20, mats["fabric_white"], p, rot=(0.3, 0, 0))
    # candle
    cyl("st_candle", (0.0, -0.2, 0.55), 0.04, 0.20, mats["fabric_white"], p)
    sph("st_flame", (0.0, -0.2, 0.70), 0.05, mats["candle_flame"], p)
    lights(o, key_color=(1,0.78,0.45), key_energy=700, fill_color=(0.40,0.50,0.85), fill_energy=180)

def hub_arena(p, o):
    floor_walls(p, mats["sand"], mats["stone_warm"], sx=7, sy=5)
    # weapon rack
    box("rk_b", (-2.5, 1.8, 0.05), (1.6, 0.4, 0.10), mats["wood_dark"], p)
    box("rk_v", (-2.5, 1.8, 1.2), (0.05, 0.05, 2.4), mats["wood_dark"], p)
    box("rk_t", (-2.5, 1.8, 2.4), (1.6, 0.4, 0.06), mats["wood_dark"], p)
    for i, x in enumerate([-3.1, -2.7, -2.3, -1.9]):
        cyl(f"sw_g_{i}", (x, 1.8, 1.0), 0.03, 0.15, mats["wood_med"], p)
        box(f"sw_b_{i}", (x, 1.8, 1.6), (0.04, 0.04, 1.0), mats["iron"], p)
        box(f"sw_x_{i}", (x, 1.8, 1.20), (0.18, 0.04, 0.04), mats["iron"], p)
    # training dummy
    box("dum_base", (1.5, 0, 0.20), (0.5, 0.5, 0.40), mats["wood_med"], p)
    cyl("dum_t", (1.5, 0, 1.0), 0.30, 1.2, mats["fabric_white"], p)
    sph("dum_h", (1.5, 0, 1.85), 0.30, mats["fabric_red"], p)
    # banner above
    box("ba_rod", (1.5, 1.6, 2.7), (1.4, 0.04, 0.04), mats["iron"], p)
    box("ba", (1.5, 1.6, 2.0), (1.2, 0.02, 1.2), mats["fabric_red"], p)
    lights(o, key_color=(1,0.85,0.55), key_energy=1100, fill_color=(0.50,0.55,0.85), fill_energy=300)

def hub_dock(p, o):
    floor_walls(p, mats["wood_med"], mats["wood_dark"], sx=6, sy=5)
    # water under deck
    bpy.ops.mesh.primitive_plane_add(size=1, location=(0,-2.0, -0.4))
    w = bpy.context.object; w.name = "dk_water"; w.scale = (6, 2, 1)
    w.data.materials.append(mats["water"]); add_subsurf_bevel(w, levels=1, bevel=0.002); w.parent = p
    # tackle box
    box("tac", (-1.6, 0.6, 0.30), (0.6, 0.4, 0.40), mats["wood_med"], p)
    box("tac_top", (-1.6, 0.6, 0.55), (0.6, 0.4, 0.10), mats["wood_dark"], p)
    # fishing pole
    cyl("rod", (1.4, 0.5, 1.0), 0.02, 2.4, mats["wood_dark"], p, rot=(0.4, 0, 0.2))
    cyl("rod2", (1.5, 1.5, 1.6), 0.015, 1.2, mats["wood_med"], p, rot=(0.6, 0, 0.2))
    # fish basket
    cyl("basket", (0, 0, 0.18), 0.40, 0.36, mats["wood_med"], p, verts=14)
    sph("fish1", (-0.10, 0.04, 0.32), 0.10, mats["fabric_blue"], p)
    sph("fish2", (0.12, -0.05, 0.32), 0.09, mats["wood_dark"], p)
    # lantern
    cyl("lt_p", (1.8, 1.7, 1.0), 0.03, 2.0, mats["iron"], p)
    box("lt_b", (1.8, 1.7, 2.10), (0.16, 0.16, 0.10), mats["iron"], p)
    sph("lt_f", (1.8, 1.7, 2.20), 0.10, mats["lamp_warm"], p)
    lights(o, key_color=(0.65,0.75,1.0), key_energy=900, fill_color=(0.45,0.55,0.85), fill_energy=250)

def hub_cooking(p, o):
    floor_walls(p, mats["stone_grey"], mats["stone_warm"])
    # hearth (back wall arch)
    box("h_base", (0, 1.8, 0.4), (2.0, 0.7, 0.8), mats["stone_grey"], p)
    box("h_top", (0, 1.8, 1.5), (2.4, 0.9, 0.4), mats["stone_grey"], p)
    box("h_arch", (0, 1.8, 1.0), (1.4, 0.4, 0.6), mats["wood_dark"], p)
    box("h_fire", (0, 1.6, 0.85), (1.0, 0.05, 0.30), mats["fire"], p)
    bpy.ops.object.light_add(type='POINT', location=(o[0], o[1]+1.6, o[2]+0.85))
    fl = bpy.context.object; fl.data.energy=600; fl.data.color=(1,0.45,0.15)
    # cauldron
    cyl("cd_b", (0, 0.3, 0.40), 0.45, 0.10, mats["iron"], p)
    sph("cd", (0, 0.3, 0.65), 0.42, mats["iron"], p)
    cyl("cd_top", (0, 0.3, 0.95), 0.40, 0.05, mats["water"], p)
    # spice rack
    box("sr_v", (-2.0, 1.0, 1.6), (0.04, 0.04, 1.4), mats["wood_dark"], p)
    box("sr_v2", (-2.0, 1.0, 2.4), (0.04, 0.04, 1.4), mats["wood_dark"], p)
    box("sr_h1", (-2.0, 1.0, 1.4), (0.5, 0.20, 0.05), mats["wood_med"], p)
    box("sr_h2", (-2.0, 1.0, 1.8), (0.5, 0.20, 0.05), mats["wood_med"], p)
    for i in range(4):
        cyl(f"jar_{i}", (-2.0 + (i-1.5)*0.12, 1.0, 1.55), 0.05, 0.18, mats["bottle_amber"], p)
        cyl(f"jar2_{i}", (-2.0 + (i-1.5)*0.12, 1.0, 1.95), 0.05, 0.18, mats["bottle_green"], p)
    # cutting board + knife
    box("cb", (1.6, 0, 0.30), (0.6, 0.4, 0.04), mats["wood_light"], p)
    box("knife_h", (1.5, 0, 0.34), (0.06, 0.04, 0.06), mats["wood_dark"], p)
    box("knife_b", (1.7, 0, 0.34), (0.20, 0.06, 0.04), mats["iron"], p)
    lights(o, key_color=(1,0.65,0.30), key_energy=800, fill_color=(0.45,0.55,0.85), fill_energy=250)

def hub_library(p, o):
    floor_walls(p, mats["wood_dark"], mats["wood_med"])
    # tall bookcase wall
    for s in range(5):
        z = 0.30 + s*0.55
        box(f"lb_sh_{s}", (0, 2.1, z+0.27), (5.5, 0.30, 0.05), mats["wood_dark"], p)
        for j in range(18):
            x = -2.65 + j*0.30
            color = [mats["leather_red"], mats["leather_brown"], mats["fabric_blue"], mats["fabric_red"]][j%4]
            box(f"lb_b_{s}_{j}", (x, 2.1, z+0.50), (0.10, 0.22, 0.42), color, p)
    # reading table
    box("lb_tab", (0, -0.2, 0.45), (1.4, 0.9, 0.06), mats["wood_dark"], p)
    box("lb_l1", (-0.65, -0.6, 0.22), (0.06, 0.06, 0.42), mats["wood_dark"], p)
    box("lb_l2", (0.65, -0.6, 0.22), (0.06, 0.06, 0.42), mats["wood_dark"], p)
    box("lb_l3", (-0.65, 0.2, 0.22), (0.06, 0.06, 0.42), mats["wood_dark"], p)
    box("lb_l4", (0.65, 0.2, 0.22), (0.06, 0.06, 0.42), mats["wood_dark"], p)
    # globe
    sph("gl", (1.4, 0.6, 0.65), 0.18, mats["leather_brown"], p)
    cyl("gl_p", (1.4, 0.6, 0.45), 0.05, 0.30, mats["brass"], p)
    cyl("gl_b", (1.4, 0.6, 0.30), 0.18, 0.04, mats["wood_dark"], p)
    # open book on table
    box("op_l", (-0.20, -0.2, 0.50), (0.18, 0.24, 0.02), mats["paper"], p, rot=(0, 0.05, 0))
    box("op_r", (0.20, -0.2, 0.50), (0.18, 0.24, 0.02), mats["paper"], p, rot=(0, -0.05, 0))
    lights(o, key_color=(1,0.78,0.50), key_energy=850, fill_color=(0.40,0.50,0.85), fill_energy=200)

def hub_workshop(p, o):
    floor_walls(p, mats["stone_grey"], mats["wood_dark"])
    # workbench
    box("wb", (0, 1.0, 0.45), (2.2, 0.8, 0.06), mats["wood_med"], p)
    box("wb_l1", (-1.0, 0.6, 0.22), (0.08, 0.08, 0.42), mats["wood_dark"], p)
    box("wb_l2", (1.0, 0.6, 0.22), (0.08, 0.08, 0.42), mats["wood_dark"], p)
    box("wb_l3", (-1.0, 1.4, 0.22), (0.08, 0.08, 0.42), mats["wood_dark"], p)
    box("wb_l4", (1.0, 1.4, 0.22), (0.08, 0.08, 0.42), mats["wood_dark"], p)
    # tool wall
    box("tw_b", (0, 2.32, 1.6), (2.4, 0.04, 1.0), mats["wood_dark"], p)
    for i, x in enumerate([-0.9, -0.4, 0.1, 0.6, 1.0]):
        box(f"hm_h_{i}", (x, 2.28, 1.7), (0.06, 0.06, 0.28), mats["wood_med"], p)
        box(f"hm_b_{i}", (x, 2.28, 1.95), (0.16, 0.10, 0.10), mats["iron"], p)
    # forge stub
    box("fg_b", (-2.0, 0.5, 0.40), (0.8, 0.8, 0.80), mats["stone_warm"], p)
    box("fg_t", (-2.0, 0.5, 0.85), (0.8, 0.8, 0.10), mats["iron"], p)
    box("fg_f", (-2.0, 0.5, 0.95), (0.55, 0.55, 0.20), mats["fire"], p)
    bpy.ops.object.light_add(type='POINT', location=(o[0]-2, o[1]+0.5, o[2]+1.0))
    fl = bpy.context.object; fl.data.energy=500; fl.data.color=(1,0.45,0.10)
    # bellows
    box("bel_h", (-2.7, 0.5, 1.10), (0.4, 0.5, 0.18), mats["leather_brown"], p)
    cyl("bel_n", (-2.4, 0.5, 1.10), 0.05, 0.30, mats["wood_dark"], p, rot=(0, math.pi/2, 0))
    # anvil on bench
    box("an_b", (1.2, 1.0, 0.55), (0.30, 0.20, 0.10), mats["iron"], p)
    box("an_t", (1.2, 1.0, 0.65), (0.40, 0.16, 0.06), mats["iron"], p)
    cone("an_horn", (1.5, 1.0, 0.65), 0.08, 0.0, 0.20, mats["iron"], p, verts=12)
    lights(o, key_color=(1,0.75,0.40), key_energy=900, fill_color=(0.45,0.55,0.85), fill_energy=250)

def hub_greenhouse(p, o):
    floor_walls(p, mats["stone_grey"], mats["glass"])
    # planter beds
    for i, x in enumerate([-1.6, 0.0, 1.6]):
        box(f"pb_{i}", (x, 0.6, 0.30), (1.0, 0.8, 0.30), mats["wood_med"], p)
        box(f"pd_{i}", (x, 0.6, 0.42), (0.95, 0.75, 0.06), mats["plant"], p)
        for j in range(4):
            jx = x - 0.32 + j*0.22
            cyl(f"st_{i}_{j}", (jx, 0.6, 0.55), 0.02, 0.30, mats["plant"], p)
            sph(f"lf_{i}_{j}", (jx, 0.6, 0.74), 0.10, mats["plant"], p)
    # glass roof beams (overhead arches)
    for i in range(4):
        x = -2.0 + i*1.3
        cyl(f"bm_{i}", (x, 0, 2.6), 0.06, 4.2, mats["wood_dark"], p, rot=(math.pi/2, 0, 0))
    # watering can
    sph("wc_b", (-2.0, -0.5, 0.45), 0.18, mats["brass"], p)
    cyl("wc_h", (-1.85, -0.5, 0.55), 0.04, 0.20, mats["brass"], p, rot=(0, math.pi/2, 0))
    cyl("wc_sp", (-2.18, -0.5, 0.50), 0.03, 0.30, mats["brass"], p, rot=(0, math.pi/2, 0.2))
    lights(o, key_color=(0.85,0.95,1.0), key_energy=1300, fill_color=(0.55,0.85,0.65), fill_energy=400)

def hub_bedroom(p, o):
    floor_walls(p, mats["wood_med"], mats["fabric_blue"])
    # bed frame
    box("bd_b", (0, 0.5, 0.30), (2.0, 1.4, 0.20), mats["wood_dark"], p)
    box("bd_m", (0, 0.5, 0.50), (1.9, 1.30, 0.20), mats["fabric_white"], p)
    box("bd_p1", (-0.6, 1.0, 0.65), (0.5, 0.30, 0.10), mats["fabric_red"], p)
    box("bd_p2", (0.6, 1.0, 0.65), (0.5, 0.30, 0.10), mats["fabric_red"], p)
    box("bd_q", (0, 0.0, 0.65), (1.9, 0.8, 0.06), mats["fabric_blue"], p)
    box("bd_hb", (0, 1.3, 0.85), (2.0, 0.10, 1.10), mats["wood_dark"], p)
    # nightstand
    box("ns", (1.4, 1.0, 0.40), (0.5, 0.5, 0.50), mats["wood_dark"], p)
    box("ns_t", (1.4, 1.0, 0.66), (0.55, 0.55, 0.04), mats["wood_dark"], p)
    cyl("ns_lp", (1.4, 1.0, 0.85), 0.06, 0.30, mats["brass"], p)
    cone("ns_lh", (1.4, 1.0, 1.10), 0.20, 0.10, 0.20, mats["fabric_white"], p, verts=20)
    bpy.ops.object.light_add(type='POINT', location=(o[0]+1.4, o[1]+1.0, o[2]+1.10))
    lp = bpy.context.object; lp.data.energy=350; lp.data.color=(1,0.78,0.45)
    # dresser
    box("dr", (-1.6, 1.5, 0.55), (0.8, 0.5, 0.90), mats["wood_dark"], p)
    box("dr_d1", (-1.6, 1.25, 0.40), (0.7, 0.04, 0.20), mats["wood_med"], p)
    box("dr_d2", (-1.6, 1.25, 0.65), (0.7, 0.04, 0.20), mats["wood_med"], p)
    box("dr_d3", (-1.6, 1.25, 0.90), (0.7, 0.04, 0.20), mats["wood_med"], p)
    sph("dr_k1", (-1.85, 1.23, 0.40), 0.02, mats["brass"], p)
    sph("dr_k2", (-1.35, 1.23, 0.40), 0.02, mats["brass"], p)
    sph("dr_k3", (-1.85, 1.23, 0.65), 0.02, mats["brass"], p)
    sph("dr_k4", (-1.35, 1.23, 0.65), 0.02, mats["brass"], p)
    lights(o, key_color=(1,0.78,0.45), key_energy=600, fill_color=(0.45,0.55,0.85), fill_energy=200)

def hub_bathhouse(p, o):
    floor_walls(p, mats["stone_grey"], mats["stone_warm"])
    # sunken stone tub
    box("tb_b", (0, 0.5, 0.20), (2.4, 1.6, 0.10), mats["stone_grey"], p)
    box("tb_w1", (0, -0.4, 0.40), (2.4, 0.10, 0.50), mats["stone_warm"], p)
    box("tb_w2", (0, 1.4, 0.40), (2.4, 0.10, 0.50), mats["stone_warm"], p)
    box("tb_w3", (-1.25, 0.5, 0.40), (0.10, 1.6, 0.50), mats["stone_warm"], p)
    box("tb_w4", (1.25, 0.5, 0.40), (0.10, 1.6, 0.50), mats["stone_warm"], p)
    box("tb_water", (0, 0.5, 0.40), (2.2, 1.4, 0.10), mats["water"], p)
    # steam lamps (4 corners)
    for i, (x, y) in enumerate([(-1.4, -0.6),(1.4, -0.6),(-1.4, 1.6),(1.4, 1.6)]):
        cyl(f"lm_p_{i}", (x, y, 1.2), 0.04, 2.0, mats["brass"], p)
        sph(f"lm_g_{i}", (x, y, 2.20), 0.12, mats["lamp_warm"], p)
    # towel rack
    box("tr_v1", (-2.2, 1.5, 1.0), (0.04, 0.04, 1.6), mats["wood_dark"], p)
    box("tr_v2", (-2.2, 0.5, 1.0), (0.04, 0.04, 1.6), mats["wood_dark"], p)
    cyl("tr_h", (-2.2, 1.0, 1.5), 0.03, 1.0, mats["wood_dark"], p, rot=(math.pi/2, 0, 0))
    box("tw1", (-2.2, 0.7, 1.10), (0.10, 0.18, 0.40), mats["fabric_white"], p, rot=(0,0.1,0))
    box("tw2", (-2.2, 1.3, 1.10), (0.10, 0.18, 0.40), mats["fabric_blue"], p, rot=(0,-0.1,0))
    lights(o, key_color=(0.95,0.95,1.0), key_energy=900, fill_color=(0.85,0.95,1.0), fill_energy=350)

def hub_music(p, o):
    floor_walls(p, mats["wood_dark"], mats["fabric_red"])
    # piano-ish keyboard chest
    box("pn_body", (0, 0.6, 0.50), (2.0, 1.0, 0.50), mats["wood_dark"], p)
    box("pn_top", (0, 0.6, 0.78), (2.0, 1.0, 0.06), mats["wood_dark"], p)
    box("pn_keys", (0, 0.10, 0.80), (1.8, 0.30, 0.04), mats["fabric_white"], p)
    # black keys
    for i in range(10):
        x = -0.85 + i*0.18
        if i % 7 not in (2, 6):
            box(f"pn_bk_{i}", (x, 0.05, 0.85), (0.06, 0.18, 0.04), mats["wood_dark"], p)
    # piano lid raised
    box("pn_lid", (0, 0.95, 1.05), (2.0, 0.04, 0.4), mats["wood_dark"], p, rot=(0.6, 0, 0))
    # harp
    box("hp_b", (-1.8, 1.6, 0.20), (0.5, 0.4, 0.10), mats["wood_dark"], p)
    cyl("hp_p", (-1.8, 1.6, 1.0), 0.06, 1.6, mats["wood_dark"], p)
    cyl("hp_a", (-1.5, 1.6, 1.6), 0.06, 0.8, mats["wood_dark"], p, rot=(0, math.pi/3, 0))
    for i in range(7):
        z = 0.50 + i*0.15
        cyl(f"hp_str_{i}", (-1.65 + i*0.05, 1.6, z+0.20), 0.005, 0.6, mats["fabric_white"], p)
    # sheet music stand
    box("ms_b", (1.8, 1.4, 0.04), (0.4, 0.4, 0.04), mats["iron"], p)
    cyl("ms_p", (1.8, 1.4, 0.65), 0.03, 1.20, mats["iron"], p)
    box("ms_pl", (1.8, 1.4, 1.30), (0.5, 0.04, 0.4), mats["wood_med"], p, rot=(0.4, 0, 0))
    box("ms_sh", (1.8, 1.32, 1.32), (0.45, 0.02, 0.36), mats["paper"], p, rot=(0.4, 0, 0))
    lights(o, key_color=(1,0.85,0.50), key_energy=900, fill_color=(0.55,0.55,0.85), fill_energy=300)

def hub_maproom(p, o):
    floor_walls(p, mats["wood_dark"], mats["stone_warm"])
    # round table
    cyl("mr_top", (0, 0.5, 0.70), 1.4, 0.06, mats["wood_dark"], p, verts=32)
    cyl("mr_p", (0, 0.5, 0.40), 0.18, 0.60, mats["wood_dark"], p)
    cyl("mr_b", (0, 0.5, 0.05), 0.6, 0.10, mats["wood_dark"], p)
    # giant map (paper plane on top)
    bpy.ops.mesh.primitive_plane_add(size=1, location=(0, 0.5, 0.74))
    mp = bpy.context.object; mp.name = "mr_map"; mp.scale = (2.0, 1.6, 1)
    mp.data.materials.append(mats["paper"]); add_subsurf_bevel(mp, levels=2, bevel=0.002); mp.parent = p
    # brass instruments (compass, sextant, telescope)
    cyl("cmp", (0.6, 0.3, 0.78), 0.12, 0.04, mats["brass"], p)
    sph("cmp_p", (0.6, 0.3, 0.81), 0.04, mats["iron"], p)
    box("sx", (-0.6, 0.7, 0.80), (0.30, 0.08, 0.18), mats["brass"], p, rot=(0, 0, 0.4))
    cyl("tl", (0.4, 0.8, 0.80), 0.05, 0.30, mats["brass"], p, rot=(0, 1.4, 0))
    # candle on table corner
    cyl("mr_cd", (-0.8, -0.2, 0.78), 0.04, 0.16, mats["fabric_white"], p)
    sph("mr_cf", (-0.8, -0.2, 0.92), 0.05, mats["candle_flame"], p)
    bpy.ops.object.light_add(type='POINT', location=(o[0]-0.8, o[1]-0.2, o[2]+0.92))
    fl = bpy.context.object; fl.data.energy=200; fl.data.color=(1,0.78,0.45)
    lights(o, key_color=(1,0.78,0.45), key_energy=700, fill_color=(0.45,0.55,0.85), fill_energy=250)

def hub_trophy(p, o):
    floor_walls(p, mats["stone_warm"], mats["wood_dark"])
    # 3 column pedestals
    for i, x in enumerate([-1.8, 0, 1.8]):
        box(f"pd_b_{i}", (x, 1.0, 0.20), (0.7, 0.7, 0.40), mats["stone_grey"], p)
        cyl(f"pd_s_{i}", (x, 1.0, 0.90), 0.30, 1.0, mats["stone_grey"], p, verts=20)
        box(f"pd_t_{i}", (x, 1.0, 1.45), (0.7, 0.7, 0.10), mats["stone_grey"], p)
    # trophies
    # 1: golden cup
    cyl("tp1_b", (-1.8, 1.0, 1.55), 0.18, 0.06, mats["gold"], p)
    sph("tp1_c", (-1.8, 1.0, 1.85), 0.22, mats["gold"], p)
    # 2: brass shield + sword
    cyl("tp2_sh", (0, 1.0, 1.95), 0.30, 0.06, mats["brass"], p, rot=(math.pi/2, 0, 0))
    box("tp2_sw", (0, 1.0, 2.30), (0.04, 0.04, 0.6), mats["iron"], p)
    box("tp2_xs", (0, 1.0, 2.05), (0.18, 0.04, 0.04), mats["iron"], p)
    # 3: crystal
    cone("tp3", (1.8, 1.0, 1.85), 0.18, 0.0, 0.5, mats["water"], p, verts=8)
    # plaques on wall
    box("plk1", (-1.8, 2.30, 2.4), (0.40, 0.04, 0.20), mats["brass"], p)
    box("plk2", (0, 2.30, 2.4), (0.40, 0.04, 0.20), mats["brass"], p)
    box("plk3", (1.8, 2.30, 2.4), (0.40, 0.04, 0.20), mats["brass"], p)
    lights(o, key_color=(1,0.85,0.55), key_energy=1100, fill_color=(0.55,0.55,0.85), fill_energy=350)

def hub_meditation(p, o):
    floor_walls(p, mats["stone_warm"], mats["wood_med"])
    # circular rug
    cyl("rug", (0, 0, 0.005), 1.6, 0.01, mats["fabric_red"], p, verts=48)
    cyl("rug2", (0, 0, 0.012), 1.4, 0.01, mats["fabric_blue"], p, verts=48)
    cyl("rug3", (0, 0, 0.020), 1.0, 0.01, mats["gold"], p, verts=48)
    # low cushion
    cyl("cn", (0, 0, 0.10), 0.45, 0.18, mats["fabric_red"], p, verts=32)
    # 4 corner candles on small bowls
    for i, (x, y) in enumerate([(-1.4,-1.0),(1.4,-1.0),(-1.4,1.4),(1.4,1.4)]):
        cyl(f"bw_{i}", (x, y, 0.05), 0.12, 0.06, mats["brass"], p)
        cyl(f"cd_{i}", (x, y, 0.18), 0.04, 0.20, mats["fabric_white"], p)
        sph(f"fl_{i}", (x, y, 0.32), 0.05, mats["candle_flame"], p)
    # incense pot center-back
    cyl("in_b", (0, 1.6, 0.10), 0.18, 0.20, mats["brass"], p)
    cyl("in_st", (0, 1.6, 0.50), 0.005, 0.6, mats["wood_dark"], p)
    sph("in_g", (0, 1.6, 0.78), 0.04, mats["candle_flame"], p)
    lights(o, key_color=(1,0.78,0.50), key_energy=600, fill_color=(0.55,0.45,0.75), fill_energy=250)

# ============================================================
# SCENE LAYOUT — 14 hubs in 4x4 grid (with 2 empty slots)
# ============================================================
HUBS = [
    ("lounge",     hub_lounge),
    ("study",      hub_study),
    ("arena",      hub_arena),
    ("dock",       hub_dock),
    ("cooking",    hub_cooking),
    ("library",    hub_library),
    ("workshop",   hub_workshop),
    ("greenhouse", hub_greenhouse),
    ("bedroom",    hub_bedroom),
    ("bathhouse",  hub_bathhouse),
    ("music",      hub_music),
    ("maproom",    hub_maproom),
    ("trophy",     hub_trophy),
    ("meditation", hub_meditation),
]

CAMERAS = []
for i, (name, builder) in enumerate(HUBS):
    col = i % 4
    row = i // 4
    origin = Vector((col * 20, row * 20, 0))
    parent = bpy.data.objects.new(f"hub_{name}", None)
    scene.collection.objects.link(parent)
    parent.location = origin
    builder(parent, origin)
    bpy.ops.object.camera_add(location=(origin[0]+4.0, origin[1]-3.5, origin[2]+2.5))
    cam = bpy.context.object; cam.name = f"cam_{name}"
    cam.data.lens = 35
    cam.data.dof.use_dof = True
    cam.data.dof.aperture_fstop = 4.0
    target = origin + Vector((0, 0.5, 1.2))
    direction = target - cam.location
    cam.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    CAMERAS.append((name, cam))

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render
for name, cam in CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_hub_{name}_hero.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# GLB exports
for name, _ in HUBS:
    bpy.ops.object.select_all(action='DESELECT')
    parent = bpy.data.objects.get(f"hub_{name}")
    if parent:
        parent.select_set(True)
        for child in parent.children_recursive:
            child.select_set(True)
        out_path = os.path.join(EXPORT_DIR, f"hub_{name}_v3.glb")
        bpy.ops.export_scene.gltf(
            filepath=out_path, use_selection=True,
            export_format='GLB', export_apply=True
        )
        print(f"Exported: {out_path}")

print("=== V3 Epic 11 Hub Interior Texturing complete ===")
