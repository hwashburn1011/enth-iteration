"""
Expansion V3 — Epic 24 — Crafting Materials & Items Texture Pass
================================================================
20 hero crafting material/item samples, each on its own pedestal,
each with bespoke PBR + (where appropriate) refraction or SSS.

Items (5 columns x 4 rows = 20):
  Row 1 (ores):     iron, copper, gold, silver, mithril
  Row 2 (gems):     crystal_blue, crystal_red, crystal_green, quartz, obsidian_chip
  Row 3 (organics): herb_green, herb_red, herb_purple, mushroom, wood_log
  Row 4 (refined):  iron_ingot, copper_ingot, gold_ingot, leather_strip, cloth_bolt

Each material:
  - Bespoke PBR (correct metalness per material)
  - Voronoi vein patterns on ores
  - Crystal: 0.6 transmission + 1.5 IOR + emission glow
  - Herbs: 0.5 SSS w/ green/red/purple radius tints
  - Wood: voronoi grain
  - Leather/cloth: high-frequency bump

Outputs:
  - 1 grid hero render @ 1920x1080
  - 4 row close-ups @ 1280x720
  - 20 GLB exports (one per item)
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(24)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/buildings/v3_crafting_materials.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/buildings/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/buildings/exports"
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

scene.world = bpy.data.worlds.new("v3_cm_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.06, 0.06, 0.08, 1)
bg.inputs["Strength"].default_value = 0.6

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

def make_ore(name, host_color, vein_color, vein_metalness=0.95, vein_emission=None):
    """Stone ore with metallic veins driven by voronoi DISTANCE_TO_EDGE."""
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1100, 0)
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (4, 4, 4)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Host stone noise base
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
    n.inputs["Scale"].default_value = 8.0
    n.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])
    host_ramp = nodes.new("ShaderNodeValToRGB"); host_ramp.location = (-450, 200)
    host_ramp.color_ramp.elements[0].position = 0.30
    host_ramp.color_ramp.elements[0].color = (host_color[0]*0.6, host_color[1]*0.6, host_color[2]*0.6, 1)
    host_ramp.color_ramp.elements[1].position = 0.70
    host_ramp.color_ramp.elements[1].color = (host_color[0]*1.1, host_color[1]*1.1, host_color[2]*1.1, 1)
    links.new(n.outputs["Fac"], host_ramp.inputs["Fac"])

    # Vein voronoi
    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-700, -100)
    v.feature = 'DISTANCE_TO_EDGE'
    v.inputs["Scale"].default_value = 5.0
    links.new(mp.outputs["Vector"], v.inputs["Vector"])
    vein_ramp = nodes.new("ShaderNodeValToRGB"); vein_ramp.location = (-450, -100)
    vein_ramp.color_ramp.elements[0].position = 0.0
    vein_ramp.color_ramp.elements[0].color = (1, 1, 1, 1)
    vein_ramp.color_ramp.elements[1].position = 0.10
    vein_ramp.color_ramp.elements[1].color = (0, 0, 0, 1)
    links.new(v.outputs["Distance"], vein_ramp.inputs["Fac"])

    # Mix host with vein color where vein mask is high
    mix = nodes.new("ShaderNodeMix"); mix.data_type='RGBA'; mix.location = (-200, 0)
    links.new(vein_ramp.outputs["Color"], mix.inputs["Factor"])
    links.new(host_ramp.outputs["Color"], mix.inputs[6])
    mix.inputs[7].default_value = (*vein_color, 1)
    links.new(mix.outputs[2], bsdf.inputs["Base Color"])

    # Metalness modulated by vein mask
    metal_mix = nodes.new("ShaderNodeMath"); metal_mix.location = (-200, -200)
    metal_mix.operation = 'MULTIPLY'
    metal_mix.inputs[1].default_value = vein_metalness
    links.new(vein_ramp.outputs["Color"], metal_mix.inputs[0])
    links.new(metal_mix.outputs[0], bsdf.inputs["Metallic"])

    # Roughness modulated (smooth on metal veins, rough on host stone)
    rough_inv = nodes.new("ShaderNodeMath"); rough_inv.location = (-200, -350)
    rough_inv.operation = 'SUBTRACT'
    rough_inv.inputs[0].default_value = 0.85
    rough_scale = nodes.new("ShaderNodeMath"); rough_scale.location = (0, -350)
    rough_scale.operation = 'MULTIPLY'
    rough_scale.inputs[1].default_value = 0.50
    links.new(vein_ramp.outputs["Color"], rough_scale.inputs[0])
    links.new(rough_scale.outputs[0], rough_inv.inputs[1])
    links.new(rough_inv.outputs[0], bsdf.inputs["Roughness"])

    # Optional vein emission
    if vein_emission:
        em_mix = nodes.new("ShaderNodeMix"); em_mix.data_type='RGBA'; em_mix.location = (200, -150)
        em_mix.inputs[6].default_value = (0, 0, 0, 1)
        em_mix.inputs[7].default_value = (*vein_emission, 1)
        links.new(vein_ramp.outputs["Color"], em_mix.inputs["Factor"])
        links.new(em_mix.outputs[2], bsdf.inputs["Emission Color"])
        bsdf.inputs["Emission Strength"].default_value = 3.0

    # Bump from host noise
    bp = nodes.new("ShaderNodeBump"); bp.location = (200, -500)
    bp.inputs["Strength"].default_value = 0.40
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_crystal(name, color, ior=1.5):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (*color, 1)
    bs.inputs["Roughness"].default_value = 0.05
    bs.inputs["Transmission Weight"].default_value = 0.7
    bs.inputs["IOR"].default_value = ior
    bs.inputs["Emission Color"].default_value = (color[0]*1.2, color[1]*1.2, color[2]*1.2, 1)
    bs.inputs["Emission Strength"].default_value = 4.0
    return m

def make_herb(name, color, sss_radius):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (*color, 1)
    bs.inputs["Roughness"].default_value = 0.85
    bs.inputs["Subsurface Weight"].default_value = 0.5
    bs.inputs["Subsurface Radius"].default_value = sss_radius
    bs.inputs["Subsurface Scale"].default_value = 0.30
    bs.inputs["Emission Color"].default_value = (color[0]*1.3, color[1]*1.5, color[2]*1.3, 1)
    bs.inputs["Emission Strength"].default_value = 0.4
    return m

# ============================================================
# 20 MATERIALS
# ============================================================
mats = {}
# Row 1 — ores
mats["iron"]    = make_ore("v3cm_iron",    (0.45, 0.40, 0.36), (0.65, 0.62, 0.60), 0.95)
mats["copper"]  = make_ore("v3cm_copper",  (0.40, 0.32, 0.25), (0.85, 0.45, 0.20), 0.92)
mats["gold"]    = make_ore("v3cm_gold",    (0.45, 0.40, 0.30), (0.95, 0.78, 0.20), 1.0)
mats["silver"]  = make_ore("v3cm_silver",  (0.40, 0.42, 0.45), (0.85, 0.88, 0.92), 0.95)
mats["mithril"] = make_ore("v3cm_mithril", (0.30, 0.32, 0.42), (0.55, 0.75, 0.95), 1.0,
                            vein_emission=(0.55, 0.75, 1.0))
# Row 2 — gems
mats["crystal_blue"]  = make_crystal("v3cm_cry_b", (0.30, 0.55, 0.95))
mats["crystal_red"]   = make_crystal("v3cm_cry_r", (0.95, 0.20, 0.30))
mats["crystal_green"] = make_crystal("v3cm_cry_g", (0.30, 0.95, 0.45))
mats["quartz"]        = make_crystal("v3cm_quartz", (0.92, 0.92, 0.95), ior=1.55)
mats["obsidian"]      = make_pbr("v3cm_obs", (0.04, 0.03, 0.06), 0.10, 0.30,
    emission_color=(0.30, 0.20, 0.65), emission_strength=0.6,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True, bump_strength=0.10, bump_scale=22.0)
# Row 3 — organics
mats["herb_green"]   = make_herb("v3cm_herb_g", (0.18, 0.45, 0.12), (1.5, 0.5, 0.3))
mats["herb_red"]     = make_herb("v3cm_herb_r", (0.65, 0.20, 0.20), (1.2, 0.4, 0.4))
mats["herb_purple"]  = make_herb("v3cm_herb_p", (0.45, 0.20, 0.65), (0.8, 0.6, 1.4))
mats["mushroom"]     = make_pbr("v3cm_mush", (0.85, 0.18, 0.18), 0.65,
    emission_color=(0.95, 0.30, 0.25), emission_strength=0.5,
    noise_strength=0.20, voronoi_strength=0.30, voronoi_scale=80.0,
    curvature_dirt=False, fresnel_rim=True, bump_strength=0.20, bump_scale=80.0)
mats["wood_log"]     = make_pbr("v3cm_wood", (0.42, 0.26, 0.13), 0.85,
    noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=8.0, bump_strength=0.30, bump_scale=12.0)
# Row 4 — refined
mats["iron_ingot"]   = make_pbr("v3cm_iron_ing", (0.55, 0.55, 0.58), 0.30, 0.95,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.05, bump_scale=22.0)
mats["copper_ingot"] = make_pbr("v3cm_copper_ing", (0.85, 0.45, 0.20), 0.30, 0.92,
    emission_color=(1.0, 0.55, 0.25), emission_strength=0.4,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True, bump_strength=0.05, bump_scale=22.0)
mats["gold_ingot"]   = make_pbr("v3cm_gold_ing", (0.95, 0.78, 0.20), 0.10, 1.0,
    emission_color=(1.0, 0.85, 0.40), emission_strength=1.5,
    noise_strength=0.05, curvature_dirt=True, fresnel_rim=True)
mats["leather"]      = make_pbr("v3cm_leather", (0.30, 0.16, 0.08), 0.55,
    noise_strength=0.25, voronoi_strength=0.25, voronoi_scale=80.0, bump_strength=0.30, bump_scale=80.0)
mats["cloth"]        = make_pbr("v3cm_cloth", (0.55, 0.30, 0.55), 0.85,
    noise_strength=0.30, voronoi_strength=0.30, voronoi_scale=60.0, bump_strength=0.25, bump_scale=60.0)

# Pedestal/floor materials
mat_pedestal = make_pbr("v3cm_pedestal", (0.32, 0.30, 0.28), 0.30, 0.10,
    noise_strength=0.20, voronoi_strength=0.30, voronoi_scale=8.0, bump_strength=0.10, bump_scale=14.0)
mat_floor    = make_pbr("v3cm_floor", (0.10, 0.10, 0.12), 0.30, 0.10,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.05)

# ============================================================
# UTIL
# ============================================================
def add_subsurf_bevel(obj, levels=2, bevel=0.025):
    s = obj.modifiers.new("Subsurf", 'SUBSURF'); s.levels = levels; s.render_levels = levels+1
    b = obj.modifiers.new("Bevel", 'BEVEL'); b.width = bevel; b.segments = 3; b.profile = 0.7
    for poly in obj.data.polygons: poly.use_smooth = True

def make_ore_chunk(name, loc, mat, parent):
    """Distorted icosphere — looks like a rough ore chunk."""
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.25, location=loc)
    o = bpy.context.object; o.name = name
    bm = bmesh.new()
    bm.from_mesh(o.data)
    for v in bm.verts:
        v.co += v.co.normalized() * random.uniform(-0.05, 0.10)
    bm.to_mesh(o.data)
    bm.free()
    o.scale = (random.uniform(0.9, 1.2), random.uniform(0.9, 1.2), random.uniform(0.7, 1.0))
    o.rotation_euler = (random.uniform(0, math.pi*2), random.uniform(0, math.pi*2), random.uniform(0, math.pi*2))
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=2, bevel=0.005)
    o.parent = parent
    return o

def make_crystal_cluster(name, loc, mat, parent, count=5):
    """Cluster of pointed cones forming a crystal."""
    sub = bpy.data.objects.new(name, None); sub.location = loc
    sub.parent = parent
    scene.collection.objects.link(sub)
    for i in range(count):
        ang = i * (math.pi*2/count)
        x = math.cos(ang) * 0.06
        y = math.sin(ang) * 0.06
        h = random.uniform(0.20, 0.40)
        bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.06, radius2=0.015, depth=h, location=(loc[0]+x, loc[1]+y, loc[2]+h/2))
        c = bpy.context.object
        c.name = f"{name}_c{i}"
        c.data.materials.append(mat)
        add_subsurf_bevel(c, levels=1, bevel=0.005)
        c.rotation_euler = (random.uniform(-0.2, 0.2), random.uniform(-0.2, 0.2), 0)
        c.parent = sub
    # Central tall crystal
    bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=0.10, radius2=0.02, depth=0.50, location=(loc[0], loc[1], loc[2]+0.25))
    c = bpy.context.object
    c.name = f"{name}_main"
    c.data.materials.append(mat)
    add_subsurf_bevel(c, levels=1, bevel=0.005)
    c.parent = sub
    return sub

def make_herb_sprig(name, loc, mat, parent):
    """Stem + 3 leaf spheres."""
    sub = bpy.data.objects.new(name, None); sub.location = loc
    sub.parent = parent
    scene.collection.objects.link(sub)
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.015, depth=0.35, location=(loc[0], loc[1], loc[2]+0.18))
    s = bpy.context.object; s.name = f"{name}_stem"
    s.data.materials.append(mat); add_subsurf_bevel(s, levels=0, bevel=0.005)
    s.parent = sub
    for i, (dx, dy, dz) in enumerate([(0.06, 0.05, 0.05), (-0.06, 0.05, 0.10), (0.0, -0.04, 0.20)]):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.10, location=(loc[0]+dx, loc[1]+dy, loc[2]+0.10+dz))
        l = bpy.context.object; l.name = f"{name}_leaf{i}"
        l.scale = (1.0, 0.5, 0.3)
        l.rotation_euler = (random.uniform(-0.3,0.3), random.uniform(-0.3,0.3), random.uniform(0,math.pi))
        l.data.materials.append(mat); add_subsurf_bevel(l, levels=2, bevel=0.005)
        l.parent = sub
    return sub

def make_mushroom(name, loc, mat, parent):
    sub = bpy.data.objects.new(name, None); sub.location = loc
    sub.parent = parent
    scene.collection.objects.link(sub)
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.06, depth=0.20, location=(loc[0], loc[1], loc[2]+0.10))
    s = bpy.context.object; s.name = f"{name}_stem"
    stem_mat = bpy.data.materials.new(f"{name}_stem_mat")
    stem_mat.use_nodes = True
    sb = stem_mat.node_tree.nodes["Principled BSDF"]
    sb.inputs["Base Color"].default_value = (0.85, 0.78, 0.65, 1)
    sb.inputs["Roughness"].default_value = 0.85
    s.data.materials.append(stem_mat)
    add_subsurf_bevel(s, levels=1, bevel=0.005)
    s.parent = sub
    bpy.ops.mesh.primitive_uv_sphere_add(segments=18, ring_count=10, radius=0.16, location=(loc[0], loc[1], loc[2]+0.30))
    cap = bpy.context.object; cap.name = f"{name}_cap"
    cap.scale.z = 0.7
    cap.data.materials.append(mat); add_subsurf_bevel(cap, levels=2, bevel=0.005)
    cap.parent = sub
    # White spots
    for i, (dx, dy) in enumerate([(0.06, 0), (-0.06, 0), (0, 0.06), (0.04, 0.04), (-0.04, -0.04)]):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.02, location=(loc[0]+dx, loc[1]+dy, loc[2]+0.40))
        sp = bpy.context.object; sp.name = f"{name}_sp{i}"
        sp.scale.z = 0.4
        white_mat = bpy.data.materials.new(f"{name}_white_{i}")
        white_mat.use_nodes = True
        wb = white_mat.node_tree.nodes["Principled BSDF"]
        wb.inputs["Base Color"].default_value = (0.95, 0.95, 0.92, 1)
        wb.inputs["Roughness"].default_value = 0.6
        sp.data.materials.append(white_mat); add_subsurf_bevel(sp, levels=1, bevel=0.005)
        sp.parent = sub
    return sub

def make_log(name, loc, mat, parent):
    bpy.ops.mesh.primitive_cylinder_add(vertices=14, radius=0.18, depth=0.50, location=(loc[0], loc[1], loc[2]+0.18))
    o = bpy.context.object; o.name = name
    o.rotation_euler = (math.pi/2, 0, 0)
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    return o

def make_ingot(name, loc, mat, parent):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(loc[0], loc[1], loc[2]+0.06))
    o = bpy.context.object; o.name = name
    o.scale = (0.40, 0.18, 0.10)
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=2, bevel=0.018)
    o.parent = parent
    return o

def make_leather_strip(name, loc, mat, parent):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(loc[0], loc[1], loc[2]+0.04))
    o = bpy.context.object; o.name = name
    o.scale = (0.40, 0.20, 0.04)
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=2, bevel=0.005)
    o.parent = parent
    # Roll one end
    bpy.ops.mesh.primitive_cylinder_add(vertices=14, radius=0.06, depth=0.20, location=(loc[0]-0.20, loc[1], loc[2]+0.08))
    r = bpy.context.object; r.name = f"{name}_roll"
    r.rotation_euler = (math.pi/2, 0, 0)
    r.data.materials.append(mat); add_subsurf_bevel(r, levels=1, bevel=0.005)
    r.parent = parent
    return o

def make_cloth_bolt(name, loc, mat, parent):
    bpy.ops.mesh.primitive_cylinder_add(vertices=14, radius=0.10, depth=0.30, location=(loc[0], loc[1], loc[2]+0.10))
    o = bpy.context.object; o.name = name
    o.rotation_euler = (math.pi/2, 0, 0)
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    # Loose draped end
    bpy.ops.mesh.primitive_cube_add(size=1, location=(loc[0]+0.18, loc[1], loc[2]+0.04))
    d = bpy.context.object; d.name = f"{name}_drape"
    d.scale = (0.20, 0.18, 0.02)
    d.data.materials.append(mat); add_subsurf_bevel(d, levels=2, bevel=0.005)
    d.parent = parent
    return o

# ============================================================
# LAYOUT — 5 cols × 4 rows of pedestals
# ============================================================
parent = bpy.data.objects.new("v3_crafting_materials", None); scene.collection.objects.link(parent)

# Floor
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, -0.05))
fl = bpy.context.object; fl.name = "cm_floor"; fl.scale = (16, 14, 0.10)
fl.data.materials.append(mat_floor); add_subsurf_bevel(fl, levels=1, bevel=0.005)

# 20 items in 5x4 grid
ITEMS = [
    # (row, col, name, builder, material)
    (0, 0, "iron",          "ore",      mats["iron"]),
    (0, 1, "copper",        "ore",      mats["copper"]),
    (0, 2, "gold",          "ore",      mats["gold"]),
    (0, 3, "silver",        "ore",      mats["silver"]),
    (0, 4, "mithril",       "ore",      mats["mithril"]),
    (1, 0, "crystal_blue",  "crystal",  mats["crystal_blue"]),
    (1, 1, "crystal_red",   "crystal",  mats["crystal_red"]),
    (1, 2, "crystal_green", "crystal",  mats["crystal_green"]),
    (1, 3, "quartz",        "crystal",  mats["quartz"]),
    (1, 4, "obsidian",      "ore",      mats["obsidian"]),
    (2, 0, "herb_green",    "herb",     mats["herb_green"]),
    (2, 1, "herb_red",      "herb",     mats["herb_red"]),
    (2, 2, "herb_purple",   "herb",     mats["herb_purple"]),
    (2, 3, "mushroom",      "mushroom", mats["mushroom"]),
    (2, 4, "wood_log",      "log",      mats["wood_log"]),
    (3, 0, "iron_ingot",    "ingot",    mats["iron_ingot"]),
    (3, 1, "copper_ingot",  "ingot",    mats["copper_ingot"]),
    (3, 2, "gold_ingot",    "ingot",    mats["gold_ingot"]),
    (3, 3, "leather",       "leather",  mats["leather"]),
    (3, 4, "cloth",         "cloth",    mats["cloth"]),
]

COL_SPACING = 1.5
ROW_SPACING = 1.5
GRID_OBJS = []
for row, col, name, builder_type, mat in ITEMS:
    x = -3.0 + col * COL_SPACING
    y = -2.25 + row * ROW_SPACING
    # Pedestal
    bpy.ops.mesh.primitive_cylinder_add(vertices=18, radius=0.45, depth=0.30, location=(x, y, 0.10))
    pd = bpy.context.object; pd.name = f"{name}_pedestal"
    pd.data.materials.append(mat_pedestal); add_subsurf_bevel(pd, levels=1, bevel=0.012)
    pd.parent = parent
    # Label plaque (small box on front of pedestal)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, y - 0.42, 0.18))
    lb = bpy.context.object; lb.name = f"{name}_label"; lb.scale = (0.30, 0.04, 0.10)
    label_mat = bpy.data.materials.new(f"{name}_label_mat")
    label_mat.use_nodes = True
    lbs = label_mat.node_tree.nodes["Principled BSDF"]
    lbs.inputs["Base Color"].default_value = (0.85, 0.65, 0.20, 1)
    lbs.inputs["Roughness"].default_value = 0.20
    lbs.inputs["Metallic"].default_value = 0.92
    lbs.inputs["Emission Color"].default_value = (1.0, 0.85, 0.30, 1)
    lbs.inputs["Emission Strength"].default_value = 0.8
    lb.data.materials.append(label_mat); add_subsurf_bevel(lb, levels=2, bevel=0.008)
    lb.parent = parent

    # Item
    item_loc = (x, y, 0.30)
    if builder_type == "ore":
        obj = make_ore_chunk(f"item_{name}", item_loc, mat, parent)
    elif builder_type == "crystal":
        obj = make_crystal_cluster(f"item_{name}", item_loc, mat, parent)
    elif builder_type == "herb":
        obj = make_herb_sprig(f"item_{name}", item_loc, mat, parent)
    elif builder_type == "mushroom":
        obj = make_mushroom(f"item_{name}", item_loc, mat, parent)
    elif builder_type == "log":
        obj = make_log(f"item_{name}", item_loc, mat, parent)
    elif builder_type == "ingot":
        obj = make_ingot(f"item_{name}", item_loc, mat, parent)
    elif builder_type == "leather":
        obj = make_leather_strip(f"item_{name}", item_loc, mat, parent)
    elif builder_type == "cloth":
        obj = make_cloth_bolt(f"item_{name}", item_loc, mat, parent)
    GRID_OBJS.append((name, obj))

# ============================================================
# LIGHTING
# ============================================================
bpy.ops.object.light_add(type='AREA', location=(8, -10, 12))
key = bpy.context.object
key.data.energy = 1800; key.data.color = (1.0, 0.95, 0.85); key.data.size = 12

bpy.ops.object.light_add(type='AREA', location=(-8, 10, 10))
fill = bpy.context.object
fill.data.energy = 700; fill.data.color = (0.65, 0.78, 1.0); fill.data.size = 12

bpy.ops.object.light_add(type='AREA', location=(0, 12, 5))
rim = bpy.context.object
rim.data.energy = 500; rim.data.color = (1.0, 0.85, 0.55); rim.data.size = 10

# ============================================================
# CAMERAS
# ============================================================
def add_cam(name, loc, target, lens=50, dof_dist=4):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = 5.6
    c.data.dof.focus_distance = dof_dist
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_grid = add_cam("cam_grid", Vector((0, -10, 7)), Vector((0, 0, 0.4)), lens=35, dof_dist=12)

# Per-row close-ups
ROW_CAMS = []
for row in range(4):
    y = -2.25 + row * ROW_SPACING
    cam = add_cam(f"cam_row_{row}", Vector((0, y - 3, 1.5)), Vector((0, y, 0.3)), lens=70, dof_dist=4)
    ROW_CAMS.append((row, cam))

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render
scene.camera = cam_grid
scene.render.resolution_x = 1920; scene.render.resolution_y = 1080
scene.render.filepath = os.path.join(RENDER_DIR, "v3_materials_grid.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

scene.render.resolution_x = 1280; scene.render.resolution_y = 720
ROW_NAMES = ["ores", "gems", "organics", "refined"]
for row, cam in ROW_CAMS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_materials_{ROW_NAMES[row]}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Per-item GLB exports
for name, obj in GRID_OBJS:
    bpy.ops.object.select_all(action='DESELECT')
    if obj is None:
        continue
    obj.select_set(True)
    for child in obj.children_recursive:
        child.select_set(True)
    out_path = os.path.join(EXPORT_DIR, f"material_{name}_v3.glb")
    bpy.ops.export_scene.gltf(
        filepath=out_path, use_selection=True,
        export_format='GLB', export_apply=True
    )
    print(f"Exported: {out_path}")

print("=== V3 Epic 24 Crafting Materials complete ===")
