"""
Expansion V3 — Epic 27 — Skill Tree & Module Icon Texture Pass
==============================================================
24 hero 3D skill/module icons across 4 categories of 6, each rendered
as a 512x512 thumbnail on its own dark backdrop.

  COMBAT (6):  sword, shield, bow, battleaxe, dagger, gauntlet
  MAGIC (6):   fireball, frost orb, lightning bolt, void rift,
                light beam, hourglass
  DEFENSE (6): tower shield, plate armor, rune ward, barrier dome,
                regen heart, holy ring
  MODULES (6): compiler crystal, daemon mask, kernel core, sage tome,
                warden lock, root heart

Each icon:
  - Custom shader stack (metal/crystal/emission as appropriate)
  - 4-8 hero parts maximum (these are icons, not full models)
  - Rendered on tiny dark plate to give grounding shadow
  - 512x512 portrait, neutral 3-point lighting

Outputs:
  - 1 grid hero render @ 1920x1080 (24 icon contact sheet)
  - 24 individual icon renders @ 512x512
  - 24 GLB exports
"""
import bpy, bmesh, math, os
from mathutils import Vector

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/v3_skill_icons.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/renders"
ICON_DIR     = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/icons"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/exports"
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(ICON_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 96
scene.cycles.use_denoising = True
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.view_settings.look = 'AgX - High Contrast'
scene.render.film_transparent = False

scene.world = bpy.data.worlds.new("v3_si_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.04, 0.05, 0.07, 1)
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
mats["steel"]   = make_pbr("v3si_steel", (0.55, 0.58, 0.62), 0.20, 0.95,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.05, bump_scale=22.0)
mats["iron"]    = make_pbr("v3si_iron", (0.20, 0.20, 0.22), 0.40, 0.85,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.10, bump_scale=22.0)
mats["gold"]    = make_pbr("v3si_gold", (0.95, 0.78, 0.20), 0.10, 1.0,
    emission_color=(1.0, 0.85, 0.40), emission_strength=2.0,
    noise_strength=0.05, curvature_dirt=True, fresnel_rim=True)
mats["brass"]   = make_pbr("v3si_brass", (0.85, 0.65, 0.20), 0.20, 0.92,
    emission_color=(1.0, 0.85, 0.30), emission_strength=1.0,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True)
mats["wood"]    = make_pbr("v3si_wood", (0.32, 0.18, 0.08), 0.85,
    noise_strength=0.30, voronoi_strength=0.45, voronoi_scale=12.0, bump_strength=0.20, bump_scale=18.0)
mats["leather"] = make_pbr("v3si_leather", (0.30, 0.16, 0.08), 0.55,
    noise_strength=0.25, voronoi_strength=0.20, voronoi_scale=80.0, bump_strength=0.20, bump_scale=80.0)
mats["fire"]    = make_pbr("v3si_fire", (1.0, 0.55, 0.10), 0.10, 0,
    emission_color=(1.0, 0.55, 0.10), emission_strength=14.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["frost"]   = make_pbr("v3si_frost", (0.65, 0.85, 1.0), 0.05, 0,
    emission_color=(0.85, 0.95, 1.0), emission_strength=8.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["lightning"] = make_pbr("v3si_lightning", (0.85, 0.85, 0.30), 0.05, 0,
    emission_color=(1.0, 1.0, 0.55), emission_strength=14.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["void"]    = make_pbr("v3si_void", (0.10, 0.04, 0.20), 0.20, 0.40,
    emission_color=(0.65, 0.20, 0.95), emission_strength=4.0,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True)
mats["light"]   = make_pbr("v3si_light", (1.0, 0.95, 0.85), 0.05, 0,
    emission_color=(1.0, 0.95, 0.85), emission_strength=14.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mats["crystal_blue"]  = make_pbr("v3si_cry_b", (0.30, 0.55, 0.95), 0.05, 0,
    emission_color=(0.40, 0.75, 1.0), emission_strength=8.0,
    noise_strength=0.05, curvature_dirt=False, fresnel_rim=True)
mats["crystal_red"]   = make_pbr("v3si_cry_r", (0.95, 0.20, 0.30), 0.05, 0,
    emission_color=(1.0, 0.30, 0.40), emission_strength=8.0,
    noise_strength=0.05, curvature_dirt=False, fresnel_rim=True)
mats["crystal_green"] = make_pbr("v3si_cry_g", (0.30, 0.95, 0.45), 0.05, 0,
    emission_color=(0.40, 1.0, 0.55), emission_strength=8.0,
    noise_strength=0.05, curvature_dirt=False, fresnel_rim=True)
mats["plate_dark"] = make_pbr("v3si_plate", (0.10, 0.10, 0.12), 0.30, 0.95,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.10, bump_scale=22.0)
mats["bone"]    = make_pbr("v3si_bone", (0.78, 0.72, 0.62), 0.85,
    noise_strength=0.20, curvature_dirt=True, bump_strength=0.20, bump_scale=80.0)
mats["bark"]    = make_pbr("v3si_bark", (0.20, 0.12, 0.06), 0.95,
    noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=12.0, bump_strength=0.45, bump_scale=18.0)
mats["heart"]   = make_pbr("v3si_heart", (0.95, 0.20, 0.30), 0.30, 0,
    emission_color=(1.0, 0.30, 0.40), emission_strength=4.0,
    noise_strength=0.10, curvature_dirt=False, fresnel_rim=True)
mats["plate_b"] = make_pbr("v3si_plate_b", (0.30, 0.30, 0.32), 0.30, 0.85,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.10, bump_scale=22.0)
mats["plate_grey"] = make_pbr("v3si_plate_grey", (0.40, 0.42, 0.45), 0.30, 0.85,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.10, bump_scale=22.0)
mats["paper"]   = make_pbr("v3si_paper", (0.92, 0.86, 0.72), 0.85,
    noise_strength=0.15, curvature_dirt=True, bump_strength=0.10, bump_scale=80.0)
mats["plate_dish"] = make_pbr("v3si_dish", (0.18, 0.18, 0.20), 0.30, 0.10,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.05, bump_scale=22.0)

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

def tor(name, loc, R, r, mat, parent, ms=24, mn=10, rot=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_segments=ms, minor_segments=mn, major_radius=R, minor_radius=r, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.005)
    o.parent = parent
    return o

def icon_plate(o, parent):
    """Small dark plate that grounds the icon."""
    cyl("plate", (0, 0, 0.0), 0.45, 0.04, mats["plate_dish"], parent, verts=24)

# ============================================================
# COMBAT ICONS
# ============================================================
def icon_sword(o):
    p = make_parent("icon_sword", o); icon_plate(o, p)
    cyl("handle", (0, 0, 0.20), 0.04, 0.20, mats["leather"], p, verts=10)
    box("guard", (0, 0, 0.32), (0.20, 0.04, 0.04), mats["gold"], p)
    box("blade", (0, 0, 0.55), (0.06, 0.02, 0.45), mats["steel"], p)
    cone("tip", (0, 0, 0.83), 0.06, 0.0, 0.12, mats["steel"], p, verts=6)
    sph("pommel", (0, 0, 0.10), 0.05, mats["gold"], p, segs=12)
    return p

def icon_shield(o):
    p = make_parent("icon_shield", o); icon_plate(o, p)
    box("body", (0, 0, 0.45), (0.40, 0.06, 0.55), mats["steel"], p)
    box("rim_t", (0, 0.04, 0.72), (0.40, 0.04, 0.04), mats["gold"], p)
    box("rim_b", (0, 0.04, 0.18), (0.40, 0.04, 0.04), mats["gold"], p)
    box("rim_l", (-0.20, 0.04, 0.45), (0.04, 0.04, 0.55), mats["gold"], p)
    box("rim_r", (0.20, 0.04, 0.45), (0.04, 0.04, 0.55), mats["gold"], p)
    sph("emblem", (0, 0.05, 0.45), 0.10, mats["gold"], p, segs=14)
    return p

def icon_bow(o):
    p = make_parent("icon_bow", o); icon_plate(o, p)
    # Curved bow approximation: 3 segments forming an arc
    for i, ang in enumerate([0.7, 0.0, -0.7]):
        x = math.sin(ang) * 0.30
        z = 0.45 + math.cos(ang) * 0.30
        cyl(f"bow_{i}", (x, 0, z), 0.025, 0.30, mats["wood"], p, verts=8, rot=(0, 0, ang))
    cyl("string", (0, 0.04, 0.45), 0.005, 0.60, mats["paper"], p, verts=4)
    # Arrow nocked
    cyl("arrow_shaft", (0, 0.04, 0.55), 0.012, 0.50, mats["wood"], p, verts=6, rot=(0.3, 0, 0))
    cone("arrow_tip", (0, 0.20, 0.78), 0.025, 0.0, 0.10, mats["steel"], p, verts=6, rot=(math.pi/2, 0, 0))
    return p

def icon_battleaxe(o):
    p = make_parent("icon_battleaxe", o); icon_plate(o, p)
    cyl("handle", (0, 0, 0.40), 0.04, 0.80, mats["wood"], p, verts=10)
    box("head_b", (0.10, 0, 0.78), (0.20, 0.04, 0.20), mats["steel"], p)
    box("blade_l", (0.20, 0, 0.85), (0.04, 0.06, 0.30), mats["steel"], p, rot=(0, 0.3, 0))
    box("blade_r", (-0.20, 0, 0.85), (0.04, 0.06, 0.30), mats["steel"], p, rot=(0, -0.3, 0))
    return p

def icon_dagger(o):
    p = make_parent("icon_dagger", o); icon_plate(o, p)
    cyl("handle", (0, 0, 0.20), 0.03, 0.15, mats["leather"], p, verts=8)
    box("guard", (0, 0, 0.30), (0.12, 0.03, 0.03), mats["gold"], p)
    box("blade", (0, 0, 0.50), (0.04, 0.02, 0.30), mats["steel"], p)
    cone("tip", (0, 0, 0.69), 0.04, 0.0, 0.10, mats["steel"], p, verts=6)
    return p

def icon_gauntlet(o):
    p = make_parent("icon_gauntlet", o); icon_plate(o, p)
    box("palm", (0, 0, 0.40), (0.18, 0.20, 0.20), mats["plate_grey"], p)
    # 4 fingers
    for i, fx in enumerate([-0.06, -0.02, 0.02, 0.06]):
        box(f"f_{i}", (fx, 0, 0.62), (0.03, 0.06, 0.18), mats["plate_grey"], p)
    # Thumb
    box("thumb", (0.12, 0, 0.50), (0.04, 0.06, 0.10), mats["plate_grey"], p, rot=(0, 0.5, 0))
    box("knuckle", (0, 0.10, 0.50), (0.18, 0.04, 0.04), mats["gold"], p)
    return p

# ============================================================
# MAGIC ICONS
# ============================================================
def icon_fireball(o):
    p = make_parent("icon_fireball", o); icon_plate(o, p)
    sph("core", (0, 0, 0.40), 0.18, mats["fire"], p, segs=20)
    sph("flame_l", (-0.10, 0, 0.55), 0.10, mats["fire"], p, segs=14)
    sph("flame_r", (0.10, 0, 0.55), 0.10, mats["fire"], p, segs=14)
    sph("flame_t", (0, 0, 0.65), 0.08, mats["fire"], p, segs=14)
    return p

def icon_frost(o):
    p = make_parent("icon_frost", o); icon_plate(o, p)
    sph("core", (0, 0, 0.40), 0.16, mats["frost"], p, segs=20)
    # 6 ice crystal spikes radiating
    for i in range(6):
        ang = i * (math.pi*2/6)
        x = math.cos(ang) * 0.20
        y = math.sin(ang) * 0.20
        cone(f"sp_{i}", (x, y, 0.40), 0.04, 0.0, 0.20, mats["frost"], p, verts=6,
             rot=(math.cos(ang)*1.5, math.sin(ang)*1.5, ang))
    return p

def icon_lightning(o):
    p = make_parent("icon_lightning", o); icon_plate(o, p)
    # Zigzag bolt: 4 cubes forming Z shape
    box("seg1", (0, 0, 0.65), (0.04, 0.04, 0.18), mats["lightning"], p)
    box("seg2", (-0.08, 0, 0.50), (0.16, 0.04, 0.04), mats["lightning"], p, rot=(0, 0.5, 0))
    box("seg3", (-0.04, 0, 0.30), (0.04, 0.04, 0.18), mats["lightning"], p)
    box("seg4", (0.04, 0, 0.20), (0.16, 0.04, 0.04), mats["lightning"], p, rot=(0, -0.5, 0))
    return p

def icon_void(o):
    p = make_parent("icon_void", o); icon_plate(o, p)
    sph("core", (0, 0, 0.40), 0.20, mats["void"], p, segs=24)
    tor("ring1", (0, 0, 0.40), 0.30, 0.025, mats["void"], p, ms=32, mn=8)
    tor("ring2", (0, 0, 0.40), 0.30, 0.025, mats["void"], p, ms=32, mn=8, rot=(math.pi/2, 0, 0))
    return p

def icon_light(o):
    p = make_parent("icon_light", o); icon_plate(o, p)
    sph("core", (0, 0, 0.40), 0.15, mats["light"], p, segs=20)
    # 8 ray cones
    for i in range(8):
        ang = i * math.pi/4
        x = math.cos(ang) * 0.25
        z = 0.40 + math.sin(ang) * 0.25
        cone(f"r_{i}", (x, 0, z), 0.04, 0.0, 0.15, mats["light"], p, verts=6,
              rot=(0, math.pi/2 + ang, 0))
    return p

def icon_hourglass(o):
    p = make_parent("icon_hourglass", o); icon_plate(o, p)
    cyl("top_b", (0, 0, 0.65), 0.10, 0.04, mats["brass"], p)
    cone("top_c", (0, 0, 0.50), 0.10, 0.02, 0.30, mats["frost"], p, verts=12)
    cone("bot_c", (0, 0, 0.30), 0.02, 0.10, 0.30, mats["frost"], p, verts=12)
    cyl("bot_b", (0, 0, 0.10), 0.10, 0.04, mats["brass"], p)
    return p

# ============================================================
# DEFENSE ICONS
# ============================================================
def icon_tower_shield(o):
    p = make_parent("icon_tower_shield", o); icon_plate(o, p)
    box("body", (0, 0, 0.45), (0.30, 0.06, 0.65), mats["plate_grey"], p)
    box("trim_t", (0, 0.04, 0.76), (0.30, 0.04, 0.04), mats["gold"], p)
    box("trim_b", (0, 0.04, 0.14), (0.30, 0.04, 0.04), mats["gold"], p)
    box("center_strip", (0, 0.05, 0.45), (0.04, 0.04, 0.55), mats["gold"], p)
    sph("emblem", (0, 0.06, 0.50), 0.06, mats["crystal_red"], p, segs=12)
    return p

def icon_plate_armor(o):
    p = make_parent("icon_plate", o); icon_plate(o, p)
    box("torso", (0, 0, 0.40), (0.30, 0.20, 0.40), mats["plate_b"], p)
    # Pauldrons
    sph("pl_l", (-0.25, 0, 0.55), 0.12, mats["plate_b"], p, segs=14)
    sph("pl_r", (0.25, 0, 0.55), 0.12, mats["plate_b"], p, segs=14)
    box("belt", (0, 0, 0.20), (0.32, 0.22, 0.06), mats["gold"], p)
    return p

def icon_rune_ward(o):
    p = make_parent("icon_rune_ward", o); icon_plate(o, p)
    cyl("disc", (0, 0, 0.30), 0.20, 0.04, mats["plate_grey"], p, verts=24)
    tor("ring", (0, 0, 0.32), 0.20, 0.015, mats["gold"], p, ms=32, mn=8)
    # 4 radial glyphs
    for i in range(4):
        ang = i * math.pi/2
        x = math.cos(ang) * 0.13
        y = math.sin(ang) * 0.13
        box(f"g_{i}", (x, y, 0.34), (0.06, 0.015, 0.015), mats["crystal_blue"], p, rot=(0, 0, ang))
    sph("center", (0, 0, 0.34), 0.04, mats["crystal_blue"], p, segs=10)
    return p

def icon_barrier(o):
    p = make_parent("icon_barrier", o); icon_plate(o, p)
    sph("dome", (0, 0, 0.30), 0.30, mats["frost"], p, segs=20)
    cyl("base", (0, 0, 0.06), 0.30, 0.02, mats["gold"], p, verts=24)
    return p

def icon_regen_heart(o):
    p = make_parent("icon_regen_heart", o); icon_plate(o, p)
    # Heart approximation: 2 spheres + cone
    sph("h_l", (-0.07, 0, 0.45), 0.10, mats["heart"], p, segs=14)
    sph("h_r", (0.07, 0, 0.45), 0.10, mats["heart"], p, segs=14)
    cone("h_b", (0, 0, 0.30), 0.10, 0.02, 0.20, mats["heart"], p, verts=10, rot=(math.pi, 0, 0))
    # Plus sign on heart
    box("plus_v", (0, 0.10, 0.45), (0.02, 0.02, 0.10), mats["paper"], p)
    box("plus_h", (0, 0.10, 0.45), (0.10, 0.02, 0.02), mats["paper"], p)
    return p

def icon_holy_ring(o):
    p = make_parent("icon_holy_ring", o); icon_plate(o, p)
    tor("ring", (0, 0, 0.40), 0.20, 0.04, mats["gold"], p, ms=32, mn=10)
    # 5 floating gems
    for i in range(5):
        ang = i * (math.pi*2/5)
        x = math.cos(ang) * 0.20
        y = math.sin(ang) * 0.20
        sph(f"gem_{i}", (x, y, 0.40), 0.04, mats["crystal_blue"], p, segs=12)
    return p

# ============================================================
# CLASS MODULE ICONS
# ============================================================
def icon_compiler_crystal(o):
    p = make_parent("icon_compiler", o); icon_plate(o, p)
    cone("body", (0, 0, 0.35), 0.20, 0.05, 0.50, mats["crystal_blue"], p, verts=8)
    sph("top", (0, 0, 0.62), 0.06, mats["light"], p, segs=12)
    # 4 base anchor cones
    for i in range(4):
        ang = i * math.pi/2
        x = math.cos(ang) * 0.18
        y = math.sin(ang) * 0.18
        cone(f"a_{i}", (x, y, 0.10), 0.04, 0.0, 0.15, mats["crystal_blue"], p, verts=6)
    return p

def icon_daemon_mask(o):
    p = make_parent("icon_daemon", o); icon_plate(o, p)
    sph("face", (0, 0, 0.35), 0.20, mats["plate_dark"], p, segs=18)
    # 2 horns
    cone("horn_l", (-0.10, 0.02, 0.55), 0.04, 0.0, 0.18, mats["plate_dark"], p, verts=6, rot=(-0.4, -0.4, 0))
    cone("horn_r", (0.10, 0.02, 0.55), 0.04, 0.0, 0.18, mats["plate_dark"], p, verts=6, rot=(-0.4, 0.4, 0))
    # Glowing eyes
    sph("eye_l", (-0.06, 0.18, 0.40), 0.03, mats["fire"], p, segs=10)
    sph("eye_r", (0.06, 0.18, 0.40), 0.03, mats["fire"], p, segs=10)
    return p

def icon_kernel_core(o):
    p = make_parent("icon_kernel", o); icon_plate(o, p)
    box("core", (0, 0, 0.40), (0.25, 0.25, 0.25), mats["plate_b"], p)
    # 6 pin connectors on top
    for i in range(2):
        for j in range(3):
            x = -0.08 + j * 0.08
            y = -0.05 + i * 0.10
            cyl(f"p_{i}_{j}", (x, y, 0.55), 0.01, 0.06, mats["gold"], p, verts=6)
    # Center glow chip
    box("chip", (0, 0, 0.53), (0.12, 0.12, 0.005), mats["lightning"], p)
    return p

def icon_sage_tome(o):
    p = make_parent("icon_sage", o); icon_plate(o, p)
    box("body", (0, 0, 0.30), (0.30, 0.40, 0.10), mats["leather"], p)
    box("pages", (0, 0, 0.36), (0.27, 0.36, 0.04), mats["paper"], p)
    box("bookmark", (0, 0.22, 0.40), (0.04, 0.10, 0.005), mats["gold"], p)
    sph("gem", (0, 0, 0.40), 0.04, mats["crystal_blue"], p, segs=12)
    return p

def icon_warden_lock(o):
    p = make_parent("icon_warden", o); icon_plate(o, p)
    box("body", (0, 0, 0.30), (0.18, 0.10, 0.20), mats["iron"], p)
    cyl("shackle", (0, 0, 0.50), 0.10, 0.04, mats["iron"], p, verts=14, rot=(math.pi/2, 0, 0))
    sph("kh", (0, 0.06, 0.30), 0.02, mats["gold"], p, segs=10)
    box("kh_slot", (0, 0.06, 0.27), (0.04, 0.005, 0.04), mats["plate_dark"], p)
    return p

def icon_root_heart(o):
    p = make_parent("icon_root", o); icon_plate(o, p)
    sph("core", (0, 0, 0.35), 0.18, mats["heart"], p, segs=18)
    # 5 root tendrils growing outward
    for i in range(5):
        ang = i * (math.pi*2/5)
        x = math.cos(ang) * 0.15
        y = math.sin(ang) * 0.15
        cyl(f"r_{i}", (x, y, 0.20), 0.025, 0.30, mats["bark"], p, verts=8,
             rot=(math.cos(ang)*0.6, math.sin(ang)*0.6, ang))
    return p

# ============================================================
# LAYOUT — 24 icons in 6×4 grid
# ============================================================
ICONS = [
    # Combat
    ("sword",       icon_sword,       "combat"),
    ("shield",      icon_shield,      "combat"),
    ("bow",         icon_bow,         "combat"),
    ("battleaxe",   icon_battleaxe,   "combat"),
    ("dagger",      icon_dagger,      "combat"),
    ("gauntlet",    icon_gauntlet,    "combat"),
    # Magic
    ("fireball",    icon_fireball,    "magic"),
    ("frost",       icon_frost,       "magic"),
    ("lightning",   icon_lightning,   "magic"),
    ("void",        icon_void,        "magic"),
    ("light",       icon_light,       "magic"),
    ("hourglass",   icon_hourglass,   "magic"),
    # Defense
    ("tower_shield", icon_tower_shield, "defense"),
    ("plate_armor",  icon_plate_armor,  "defense"),
    ("rune_ward",    icon_rune_ward,    "defense"),
    ("barrier",      icon_barrier,      "defense"),
    ("regen_heart",  icon_regen_heart,  "defense"),
    ("holy_ring",    icon_holy_ring,    "defense"),
    # Modules
    ("compiler",    icon_compiler_crystal, "modules"),
    ("daemon",      icon_daemon_mask,      "modules"),
    ("kernel",      icon_kernel_core,      "modules"),
    ("sage",        icon_sage_tome,        "modules"),
    ("warden",      icon_warden_lock,      "modules"),
    ("root",        icon_root_heart,       "modules"),
]

# 24 icons: 6 columns x 4 rows
parent = bpy.data.objects.new("v3_skill_icons", None); scene.collection.objects.link(parent)
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, -0.05))
fl = bpy.context.object; fl.name = "si_floor"; fl.scale = (16, 12, 0.10)
mat_floor = make_pbr("v3si_floor", (0.06, 0.06, 0.08), 0.30, 0.10,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.05)
fl.data.materials.append(mat_floor); add_subsurf_bevel(fl, levels=1, bevel=0.005)

COL_SP = 1.5
ROW_SP = 1.8
ICON_OBJS = []
for idx, (name, builder, cat) in enumerate(ICONS):
    col = idx % 6
    row = idx // 6
    x = -3.75 + col * COL_SP
    y = -2.7 + row * ROW_SP
    obj = builder(Vector((x, y, 0)))
    obj.parent = parent
    ICON_OBJS.append((name, cat, obj, Vector((x, y, 0))))

# ============================================================
# LIGHTING
# ============================================================
bpy.ops.object.light_add(type='AREA', location=(8, -10, 12))
key = bpy.context.object
key.data.energy = 2200; key.data.color = (1.0, 0.95, 0.85); key.data.size = 12

bpy.ops.object.light_add(type='AREA', location=(-8, 10, 10))
fill = bpy.context.object
fill.data.energy = 900; fill.data.color = (0.65, 0.78, 1.0); fill.data.size = 12

bpy.ops.object.light_add(type='AREA', location=(0, 12, 5))
rim = bpy.context.object
rim.data.energy = 600; rim.data.color = (1.0, 0.85, 0.55); rim.data.size = 10

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

cam_grid = add_cam("cam_grid", Vector((0, -10, 9)), Vector((0, 0, 0.4)), lens=35, dof_dist=12)

# Per-icon close-up cameras (small subjects)
ICON_CAMS = []
for name, cat, obj, origin in ICON_OBJS:
    cam = add_cam(f"cam_{name}", Vector((origin.x, origin.y - 1.6, 0.8)),
                   Vector((origin.x, origin.y, 0.40)), lens=85, dof_dist=1.6)
    ICON_CAMS.append((name, cam))

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render grid
scene.camera = cam_grid
scene.render.resolution_x = 1920; scene.render.resolution_y = 1080
scene.render.filepath = os.path.join(RENDER_DIR, "v3_skill_icons_grid.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# Render 24 individual icons at 512x512
scene.render.resolution_x = 512; scene.render.resolution_y = 512
for name, cam in ICON_CAMS:
    scene.camera = cam
    scene.render.filepath = os.path.join(ICON_DIR, f"v3_icon_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered icon: {scene.render.filepath}")

# Per-icon GLB exports
for name, cat, obj, _ in ICON_OBJS:
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    for child in obj.children_recursive:
        child.select_set(True)
    out_path = os.path.join(EXPORT_DIR, f"icon_{name}_v3.glb")
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=True
    )

print("=== V3 Epic 27 Skill Tree Icons complete ===")
