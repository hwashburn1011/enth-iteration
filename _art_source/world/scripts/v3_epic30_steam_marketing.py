"""
Expansion V3 — Epic 30 — Steam Marketing Asset Polish
======================================================
The FINAL epic in the V3 30-epic refinement plan. Builds the trailer
beauty shot and Steam page hero key art.

The composition: Globbler hero figure standing on a rocky outcrop in
the foreground, with the town in mid-distance and the dungeon spire
on the horizon. Sunset lighting (the cinematic_sunset preset from the
V3-29 lighting bible).

Outputs (3 sizes for Steam page deliverables):
  1. Hero key art            — 1920x1080 (steam screenshot/key visual)
  2. Steam header strip      — 1920x620  (steam page banner)
  3. Steam capsule (portrait)— 600x900   (steam library capsule)
  4. Square thumbnail        —  512x512  (favicon / social)
  5. Trailer beauty shot     — 2560x1080 (cinematic widescreen)

Plus a high-quality .blend saved for future cinematic re-renders.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(30)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/v3_steam_marketing.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/marketing"
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 192
scene.cycles.use_denoising = True
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.view_settings.look = 'AgX - High Contrast'

# Sky world (Hosek-Wilkie sunset)
scene.world = bpy.data.worlds.new("v3sm_world")
scene.world.use_nodes = True
wnt = scene.world.node_tree
wnt.nodes.clear()
wout = wnt.nodes.new("ShaderNodeOutputWorld")
wsky = wnt.nodes.new("ShaderNodeTexSky")
wsky.sky_type = 'HOSEK_WILKIE'
wsky.sun_direction = (0.5, -0.5, 0.20)  # low sun (sunset)
wsky.turbidity = 4.0
wsky.ground_albedo = 0.4
wbg = wnt.nodes.new("ShaderNodeBackground")
wbg.inputs["Strength"].default_value = 1.2
wnt.links.new(wsky.outputs[0], wbg.inputs[0])
wnt.links.new(wbg.outputs[0], wout.inputs[0])

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
# Globbler hero
mats["shell_blue"]   = make_pbr("v3sm_shell", (0.18, 0.42, 0.85), 0.20, 0.40,
    emission_color=(0.40, 0.65, 1.0), emission_strength=0.6,
    noise_strength=0.15, curvature_dirt=True, fresnel_rim=True, bump_strength=0.10)
mats["shell_gold"]   = make_pbr("v3sm_gold", (0.95, 0.78, 0.20), 0.10, 1.0,
    emission_color=(1.0, 0.85, 0.40), emission_strength=1.5,
    noise_strength=0.05, curvature_dirt=True, fresnel_rim=True)
mats["visor_glass"]  = make_pbr("v3sm_visor", (0.05, 0.05, 0.10), 0.10, 0.50,
    emission_color=(0.30, 0.85, 1.0), emission_strength=2.5,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["eye_emit"]     = make_pbr("v3sm_eye", (0.30, 0.95, 1.0), 0.05, 0,
    emission_color=(0.45, 1.0, 1.0), emission_strength=14.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
# Outcrop / terrain
mats["rock_outcrop"] = make_pbr("v3sm_rock", (0.32, 0.28, 0.22), 0.92,
    noise_strength=0.40, voronoi_strength=0.55, voronoi_scale=8.0, bump_strength=0.50, bump_scale=12.0)
mats["dirt_path"]    = make_pbr("v3sm_dirt", (0.40, 0.28, 0.16), 0.95,
    noise_strength=0.30, voronoi_strength=0.40, voronoi_scale=18.0, bump_strength=0.25, bump_scale=20.0)
mats["grass"]        = make_pbr("v3sm_grass", (0.18, 0.32, 0.10), 0.92,
    noise_strength=0.30, voronoi_strength=0.20, voronoi_scale=22.0, bump_strength=0.25, bump_scale=14.0)
# Distant town silhouettes
mats["building_warm"] = make_pbr("v3sm_b_warm", (0.55, 0.42, 0.28), 0.85,
    emission_color=(1.0, 0.78, 0.40), emission_strength=0.6,
    noise_strength=0.30, voronoi_strength=0.40, voronoi_scale=8.0,
    fresnel_rim=True, bump_strength=0.20, bump_scale=14.0)
mats["building_dark"] = make_pbr("v3sm_b_dark", (0.20, 0.18, 0.15), 0.85,
    noise_strength=0.30, voronoi_strength=0.40, voronoi_scale=10.0, bump_strength=0.20, bump_scale=14.0)
mats["roof_red"]     = make_pbr("v3sm_roof", (0.45, 0.15, 0.10), 0.85,
    noise_strength=0.30, voronoi_strength=0.40, voronoi_scale=12.0, bump_strength=0.20, bump_scale=18.0)
mats["window_warm"]  = make_pbr("v3sm_window", (1.0, 0.78, 0.40), 0.10, 0,
    emission_color=(1.0, 0.85, 0.45), emission_strength=10.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
# Dungeon spire (background)
mats["spire"]        = make_pbr("v3sm_spire", (0.10, 0.08, 0.12), 0.40, 0.30,
    emission_color=(1.0, 0.30, 0.10), emission_strength=1.5,
    noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=10.0,
    fresnel_rim=True, bump_strength=0.40, bump_scale=14.0)
mats["spire_glow"]   = make_pbr("v3sm_spire_g", (1.0, 0.30, 0.10), 0.10, 0,
    emission_color=(1.0, 0.45, 0.10), emission_strength=12.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
# Trees
mats["bark"]         = make_pbr("v3sm_bark", (0.20, 0.12, 0.06), 0.95,
    noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=12.0, bump_strength=0.40, bump_scale=18.0)
mats["canopy_warm"]  = make_pbr("v3sm_canopy", (0.30, 0.20, 0.08), 0.85,
    noise_strength=0.40, curvature_dirt=True, bump_strength=0.30, bump_scale=45.0)

# ============================================================
# UTIL
# ============================================================
def add_subsurf_bevel(obj, levels=2, bevel=0.025):
    s = obj.modifiers.new("Subsurf", 'SUBSURF'); s.levels = levels; s.render_levels = levels+1
    b = obj.modifiers.new("Bevel", 'BEVEL'); b.width = bevel; b.segments = 3; b.profile = 0.7
    for poly in obj.data.polygons: poly.use_smooth = True

def make_parent(name, origin):
    p = bpy.data.objects.new(name, None); scene.collection.objects.link(p); p.location = origin
    return p

def box(name, loc, scale, mat, parent, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.object; o.name = name; o.scale = scale; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o)
    o.parent = parent
    return o

def cyl(name, loc, r, depth, mat, parent, verts=18, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=r, depth=depth, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    return o

def sph(name, loc, r, mat, parent, segs=24):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segs, ring_count=segs//2, radius=r, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=2, bevel=0.005)
    o.parent = parent
    return o

def cone(name, loc, r1, r2, depth, mat, parent, verts=14, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    return o

def tor(name, loc, R, r, mat, parent, ms=24, mn=10, rot=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_segments=ms, minor_segments=mn, major_radius=R, minor_radius=r, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.005)
    o.parent = parent
    return o

def ico(name, loc, r, mat, parent, sub=2):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=sub, radius=r, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=2, bevel=0.005)
    o.parent = parent
    return o

# ============================================================
# GROUND PLANE — large + sloping rocky terrain
# ============================================================
parent = bpy.data.objects.new("v3_steam_marketing", None); scene.collection.objects.link(parent)

# Ground plane (large, stretched)
bpy.ops.mesh.primitive_plane_add(size=200, location=(0, 30, -1))
gnd = bpy.context.object; gnd.name = "sm_ground"
gnd.data.materials.append(mats["grass"])
add_subsurf_bevel(gnd, levels=1, bevel=0.005)
gnd.parent = parent

# Hero outcrop — rocky platform Globbler stands on
def hero_outcrop(parent):
    # 3-tier rocky base
    b = ico("oc_b1", (0, 0, -0.30), 1.6, mats["rock_outcrop"], parent)
    b.scale = (1.4, 1.0, 0.8)
    ico("oc_b2", (0, -0.20, 0.20), 1.30, mats["rock_outcrop"], parent).scale = (1.2, 1.0, 0.6)
    ico("oc_top", (0, 0, 0.55), 1.10, mats["rock_outcrop"], parent).scale = (1.2, 1.0, 0.4)
    # 4 surrounding boulders
    for i, (bx, by, bz, sx) in enumerate([(-1.4, 0.20, -0.10, 0.45),(1.4, 0.20, -0.10, 0.40),(-0.80, 1.10, -0.20, 0.30),(0.80, 1.10, -0.20, 0.32)]):
        ic = ico(f"oc_r_{i}", (bx, by, bz), sx, mats["rock_outcrop"], parent)
        ic.scale = (1.0, 0.85, 0.7)
hero_outcrop(parent)

# ============================================================
# GLOBBLER HERO FIGURE — V3 trailer-grade
# ============================================================
hero_p = bpy.data.objects.new("globbler_hero", None); scene.collection.objects.link(hero_p)
hero_p.location = (0, 0, 1.0)
hero_p.parent = parent

# Body — main shell sphere stretched into capsule
body = sph("hero_body", (0, 0, 0), 0.50, mats["shell_blue"], hero_p, segs=32)
body.scale = (1.0, 0.85, 1.4)
# Belt
tor("hero_belt", (0, 0, -0.35), 0.50, 0.06, mats["shell_gold"], hero_p, ms=32, mn=12)
# Chest emblem
sph("hero_emblem", (0, 0.45, 0.10), 0.12, mats["shell_gold"], hero_p, segs=18)
# Shoulders
sph("hero_sh_l", (-0.55, 0, 0.55), 0.22, mats["shell_blue"], hero_p, segs=20)
sph("hero_sh_r", (0.55, 0, 0.55), 0.22, mats["shell_blue"], hero_p, segs=20)
# Pauldron caps (gold)
sph("hero_pl_l", (-0.55, 0, 0.65), 0.12, mats["shell_gold"], hero_p, segs=14)
sph("hero_pl_r", (0.55, 0, 0.65), 0.12, mats["shell_gold"], hero_p, segs=14)
# Arms (heroic pose: right arm raised, left arm at side)
# Right arm raised — upper
cyl("hero_arm_ru", (0.75, 0, 0.55), 0.10, 0.50, mats["shell_blue"], hero_p, verts=14, rot=(0, 0.6, 0))
cyl("hero_arm_rl", (1.10, 0, 0.85), 0.09, 0.45, mats["shell_blue"], hero_p, verts=14, rot=(0, 1.4, 0))
sph("hero_hand_r", (1.30, 0, 1.05), 0.12, mats["shell_gold"], hero_p, segs=14)
# Left arm at side
cyl("hero_arm_lu", (-0.65, 0, 0.30), 0.10, 0.55, mats["shell_blue"], hero_p, verts=14, rot=(0, -0.1, 0))
cyl("hero_arm_ll", (-0.70, 0, -0.20), 0.09, 0.45, mats["shell_blue"], hero_p, verts=14)
sph("hero_hand_l", (-0.70, 0, -0.45), 0.12, mats["shell_gold"], hero_p, segs=14)
# Sword raised in right hand
cyl("hero_sword_h", (1.30, 0, 1.20), 0.04, 0.20, mats["shell_gold"], hero_p, verts=10)
box("hero_sword_g", (1.30, 0, 1.32), (0.18, 0.04, 0.04), mats["shell_gold"], hero_p)
box("hero_sword_b", (1.30, 0, 1.70), (0.06, 0.02, 0.60), mats["shell_gold"], hero_p)
cone("hero_sword_t", (1.30, 0, 2.05), 0.06, 0.0, 0.15, mats["shell_gold"], hero_p, verts=8)
# Sword glow blade overlay
box("hero_sword_glow", (1.30, 0.04, 1.70), (0.04, 0.005, 0.55), mats["eye_emit"], hero_p)
# Head
head = sph("hero_head", (0, 0.05, 0.95), 0.32, mats["shell_blue"], hero_p, segs=24)
head.scale = (1.0, 0.95, 1.05)
# Visor bar
box("hero_visor", (0, 0.30, 0.95), (0.42, 0.08, 0.12), mats["visor_glass"], hero_p)
# 2 cyan eye dots
sph("hero_eye_l", (-0.10, 0.36, 0.95), 0.05, mats["eye_emit"], hero_p, segs=12)
sph("hero_eye_r", (0.10, 0.36, 0.95), 0.05, mats["eye_emit"], hero_p, segs=12)
# Gold antenna
cyl("hero_ant", (0, 0, 1.40), 0.025, 0.30, mats["shell_gold"], hero_p, verts=8)
sph("hero_ant_t", (0, 0, 1.55), 0.06, mats["eye_emit"], hero_p, segs=12)
# Cape behind (subtle wave)
bpy.ops.mesh.primitive_plane_add(size=1, location=(0, -0.55, 0))
cape = bpy.context.object; cape.name = "hero_cape"
cape.scale = (0.8, 0.04, 1.4)
cape.rotation_euler = (math.pi/2, 0, 0)
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.subdivide(number_cuts=10)
bpy.ops.object.mode_set(mode='OBJECT')
bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
for v in cape.data.vertices:
    v.co.x += math.sin(v.co.z * 4) * 0.04
    v.co.y += abs(v.co.z) * 0.10
cape.data.materials.append(mats["roof_red"])
add_subsurf_bevel(cape, levels=2, bevel=0.001)
cape.parent = hero_p
# Halo behind head
tor("hero_halo", (0, -0.30, 1.30), 0.45, 0.025, mats["shell_gold"], hero_p, ms=48, mn=12, rot=(math.pi/2, 0, 0))

# ============================================================
# DISTANT TOWN — silhouettes in mid-distance
# ============================================================
def town_building(name, loc, w, d, h, color, parent, has_windows=True):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.object; o.name = name; o.scale = (w, d, h)
    o.data.materials.append(color); add_subsurf_bevel(o)
    o.parent = parent
    # Roof (triangular cone or box)
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=w*0.7, radius2=0, depth=h*0.6, location=(loc[0], loc[1], loc[2] + h*0.5 + h*0.3))
    r = bpy.context.object; r.name = f"{name}_roof"
    r.rotation_euler = (0, 0, math.pi/4)
    r.data.materials.append(mats["roof_red"])
    add_subsurf_bevel(r, levels=1, bevel=0.012)
    r.parent = parent
    # Glowing windows
    if has_windows:
        for wi in range(2):
            wz = loc[2] - h*0.2 + wi * h*0.4
            box(f"{name}_w_{wi}_l", (loc[0] - w*0.30, loc[1] + d*0.55, wz),
                 (w*0.18, 0.04, h*0.18), mats["window_warm"], parent)
            box(f"{name}_w_{wi}_r", (loc[0] + w*0.30, loc[1] + d*0.55, wz),
                 (w*0.18, 0.04, h*0.18), mats["window_warm"], parent)
    return o

# Town spread across mid-distance, behind hero
town_p = bpy.data.objects.new("sm_town", None); scene.collection.objects.link(town_p)
town_p.parent = parent
TOWN_BUILDINGS = [
    ("b1", (-12, 18, 1.2),  2.5, 2.5, 2.5, mats["building_warm"]),
    ("b2", (-7,  20, 1.5),  2.0, 2.0, 3.0, mats["building_dark"]),
    ("b3", (-3,  17, 1.0),  1.8, 1.8, 2.2, mats["building_warm"]),
    ("b4", (1,   19, 1.3),  2.2, 2.2, 2.8, mats["building_dark"]),
    ("b5", (5,   17, 1.0),  1.8, 1.8, 2.2, mats["building_warm"]),
    ("b6", (10,  20, 1.5),  2.0, 2.0, 3.0, mats["building_dark"]),
    ("b7", (15,  18, 1.2),  2.4, 2.4, 2.6, mats["building_warm"]),
]
for name, loc, w, d, h, color in TOWN_BUILDINGS:
    town_building(name, loc, w, d, h, color, town_p)

# Central watchtower (taller landmark)
cyl("tower_b", (0, 22, 2.0), 1.4, 4.0, mats["building_dark"], town_p, verts=24)
cyl("tower_t", (0, 22, 4.4), 1.6, 0.40, mats["building_warm"], town_p, verts=24)
cone("tower_roof", (0, 22, 5.4), 1.6, 0.0, 1.6, mats["roof_red"], town_p, verts=8)
sph("tower_top", (0, 22, 6.4), 0.20, mats["window_warm"], town_p, segs=14)
# Watchtower windows
for i in range(4):
    ang = i * math.pi/2
    wx = math.cos(ang) * 1.45
    wy = 22 + math.sin(ang) * 1.45
    box(f"tower_w_{i}", (wx, wy, 4.4), (0.20, 0.20, 0.10), mats["window_warm"], town_p)

# ============================================================
# DUNGEON SPIRE — far horizon, ominous
# ============================================================
spire_p = bpy.data.objects.new("sm_spire", None); scene.collection.objects.link(spire_p)
spire_p.parent = parent
# Spire is far away (Z=0 reference, far Y)
sx, sy = 25, 60
cyl("sp_b", (sx, sy, 4.0), 4.0, 8.0, mats["spire"], spire_p, verts=14)
cyl("sp_m", (sx, sy, 10.0), 2.5, 4.0, mats["spire"], spire_p, verts=14)
cone("sp_t", (sx, sy, 14.0), 2.5, 0.0, 6.0, mats["spire"], spire_p, verts=14)
# Glowing crystal heart at top
sph("sp_heart", (sx, sy, 13.5), 1.20, mats["spire_glow"], spire_p, segs=18)
# Ring around the spire
tor("sp_ring", (sx, sy, 12.0), 4.0, 0.30, mats["spire_glow"], spire_p, ms=64, mn=14)

# Strong red point light at the spire heart
bpy.ops.object.light_add(type='POINT', location=(sx, sy, 13.5))
sphl = bpy.context.object
sphl.data.energy = 80000
sphl.data.color = (1.0, 0.45, 0.15)

# ============================================================
# FOREGROUND DETAILS — wildflowers, scattered rocks
# ============================================================
random.seed(30)
for i in range(12):
    fx = random.uniform(-3.0, 3.0)
    fy = random.uniform(-1.5, 2.5)
    if abs(fx) < 1.5 and abs(fy) < 1.5:
        continue  # don't place where outcrop is
    fz = -0.95
    color_choice = random.choice([
        make_pbr(f"v3sm_flw_{i}", (0.85, 0.20, 0.20), 0.65,
                 emission_color=(1.0, 0.45, 0.30), emission_strength=0.6,
                 noise_strength=0.20, curvature_dirt=False, fresnel_rim=True),
        make_pbr(f"v3sm_flw_{i}b", (1.0, 0.85, 0.30), 0.65,
                 emission_color=(1.0, 0.95, 0.45), emission_strength=0.6,
                 noise_strength=0.20, curvature_dirt=False, fresnel_rim=True),
    ])
    cyl(f"flw_st_{i}", (fx, fy, fz + 0.10), 0.012, 0.20, mats["bark"], parent, verts=6)
    ic = ico(f"flw_b_{i}", (fx, fy, fz + 0.22), 0.06, color_choice, parent)
    ic.scale = (1.4, 1.4, 0.5)

# Scattered foreground rocks
for i in range(6):
    rx = random.uniform(-3.5, 3.5)
    ry = random.uniform(-2.0, 2.5)
    if abs(rx) < 1.8 and abs(ry) < 1.8:
        continue
    rz = -0.92 + random.uniform(0, 0.10)
    sz = random.uniform(0.10, 0.20)
    ic = ico(f"fg_rock_{i}", (rx, ry, rz), sz, mats["rock_outcrop"], parent)
    ic.scale = (1.2, 1.0, 0.6)
    ic.rotation_euler = (random.uniform(0,1), random.uniform(0,1), random.uniform(0, math.pi*2))

# 3 background trees on the grass
for i, (tx, ty) in enumerate([(-15, 8), (15, 8), (-12, 13)]):
    cyl(f"tree_t_{i}", (tx, ty, 1.5), 0.30, 3.0, mats["bark"], parent, verts=12)
    sph(f"tree_c_{i}", (tx, ty, 3.6), 1.5, mats["canopy_warm"], parent, segs=18).scale = (1.0, 1.0, 0.8)

# ============================================================
# LIGHTING — V3-29 Cinematic Sunset preset
# ============================================================
# Sun (Hosek-Wilkie companion sun)
bpy.ops.object.light_add(type='SUN', location=(15, -25, 25))
sun = bpy.context.object
sun.data.energy = 5.0
sun.data.color = (1.0, 0.78, 0.45)
sun.data.angle = math.radians(2)
direction = Vector((0, 0, 1)) - sun.location
sun.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

# Cool fill from opposite side
bpy.ops.object.light_add(type='AREA', location=(-12, 10, 14))
fill = bpy.context.object
fill.data.energy = 2500
fill.data.color = (0.45, 0.55, 0.95)
fill.data.size = 14

# Warm rim from behind hero
bpy.ops.object.light_add(type='AREA', location=(0, 12, 5))
rim = bpy.context.object
rim.data.energy = 2200
rim.data.color = (1.0, 0.55, 0.20)
rim.data.size = 8

# Hero accent point — subtle warm key on hero only
bpy.ops.object.light_add(type='POINT', location=(2, -2, 3))
hp = bpy.context.object
hp.data.energy = 600
hp.data.color = (1.0, 0.85, 0.55)

# ============================================================
# CAMERAS — 5 marketing deliverables
# ============================================================
def add_cam(name, loc, target, lens=50, dof_dist=8, fstop=4.0):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = fstop
    c.data.dof.focus_distance = dof_dist
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

# Hero key art — 1920x1080
cam_hero = add_cam("cam_hero", Vector((6, -8, 3.0)), Vector((0, 0, 1.4)), lens=50, dof_dist=10, fstop=4.0)
# Steam header strip — 1920x620 (slightly cinematic)
cam_header = add_cam("cam_header", Vector((4, -10, 2.5)), Vector((0, 5, 1.6)), lens=40, dof_dist=12, fstop=4.5)
# Steam capsule portrait — 600x900 (vertical, hero focus)
cam_capsule = add_cam("cam_capsule", Vector((4, -5, 2.0)), Vector((0, 0, 1.2)), lens=70, dof_dist=6, fstop=3.5)
# Square thumbnail — 512x512 (close hero)
cam_thumb = add_cam("cam_thumb", Vector((3, -4, 1.8)), Vector((0, 0, 1.0)), lens=85, dof_dist=4.5, fstop=3.5)
# Trailer beauty cinematic — 2560x1080 (ultra-wide)
cam_trailer = add_cam("cam_trailer", Vector((8, -10, 2.5)), Vector((0, 4, 1.4)), lens=35, dof_dist=12, fstop=5.6)

# Save .blend with cameras and lights
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# ============================================================
# RENDER deliverables
# ============================================================
DELIVERABLES = [
    ("hero_keyart",      cam_hero,    1920, 1080),
    ("steam_header",     cam_header,  1920, 620),
    ("steam_capsule",    cam_capsule, 600,  900),
    ("square_thumb",     cam_thumb,   512,  512),
    ("trailer_beauty",   cam_trailer, 2560, 1080),
]

for name, cam, w, h in DELIVERABLES:
    scene.camera = cam
    scene.render.resolution_x = w
    scene.render.resolution_y = h
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_steam_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

print("=== V3 Epic 30 Steam Marketing Asset Polish complete ===")
print("=== ALL 30 V3 EPICS COMPLETE — Loop will roll over to V3-01 next ===")
