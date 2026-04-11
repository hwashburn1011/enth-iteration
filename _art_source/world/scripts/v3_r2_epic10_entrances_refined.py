"""
Expansion V3 — ROUND 2 — Epic R2-10 — Dungeon Entrance Refinement
=================================================================
FINAL Round 2 epic. Round 2 of V3-10 Dungeon Entrance Hero Polish.
4 themed portal entrances with full Round 2 stack (Smart UV unwrap +
vertex color paint + multires + 5-seg bevel + vertex-color-aware
shaders).

Themes:
  SERVER ROOM   — cyan/electric
  MEMORY VAULTS — gold/brass
  CORRUPTED WILDS — purple/glitch
  BOSS SANCTUM  — crimson/obsidian

Each entrance: ground tile + 2 monument pillars w/ glow trim + lintel
+ portal shimmer disc + glow ring + banner cloth + 10 ember motes.

Outputs: 5 hero shots @ 1920x1080 + 4 GLB exports.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(110)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/v3_r2_entrances.blend"
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

scene.world = bpy.data.worlds.new("v3r2e_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.02, 0.02, 0.04, 1)
bg.inputs["Strength"].default_value = 0.4

# ============================================================
# REFINED VC-AWARE SHADER (architectural)
# ============================================================
def make_arch_shader(name, base_color, accent_color, roughness=0.85,
                     metallic=0.0, voronoi_scale=10.0, bump_strength=0.30,
                     emission_color=None, emission_strength=0.0, fresnel_rim=False):
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

def make_portal_shader(name, color, secondary):
    """Portal shimmer: concentric ring gradient + emission."""
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1300, 0)
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Roughness"].default_value = 0.05
    bsdf.inputs["Transmission Weight"].default_value = 0.6
    bsdf.inputs["IOR"].default_value = 1.4
    bsdf.inputs["Emission Color"].default_value = (*secondary, 1)
    bsdf.inputs["Emission Strength"].default_value = 6.0
    bsdf.inputs["Alpha"].default_value = 0.85
    m.blend_method = 'BLEND'
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1100, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-900, 0)
    mp.inputs["Scale"].default_value = (3, 3, 3)
    links.new(tc.outputs["Object"], mp.inputs["Vector"])

    grad = nodes.new("ShaderNodeTexGradient"); grad.location = (-650, 200)
    grad.gradient_type = 'SPHERICAL'
    links.new(mp.outputs["Vector"], grad.inputs["Vector"])
    wave = nodes.new("ShaderNodeTexWave"); wave.location = (-650, -100)
    wave.wave_type = 'RINGS'
    wave.inputs["Scale"].default_value = 6.0
    wave.inputs["Distortion"].default_value = 4.0
    wave.inputs["Detail"].default_value = 2.0
    links.new(mp.outputs["Vector"], wave.inputs["Vector"])
    mix1 = nodes.new("ShaderNodeMixRGB"); mix1.location = (-400, 50)
    mix1.blend_type = 'ADD'
    mix1.inputs["Fac"].default_value = 0.6
    links.new(grad.outputs["Color"], mix1.inputs[1])
    links.new(wave.outputs["Color"], mix1.inputs[2])
    ramp = nodes.new("ShaderNodeValToRGB"); ramp.location = (-150, 50)
    ramp.color_ramp.elements[0].position = 0.20
    ramp.color_ramp.elements[0].color = (*color, 1)
    ramp.color_ramp.elements[1].position = 0.65
    ramp.color_ramp.elements[1].color = (*secondary, 1)
    links.new(mix1.outputs["Color"], ramp.inputs["Fac"])
    links.new(ramp.outputs["Color"], bsdf.inputs["Emission Color"])
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

# ============================================================
# THEME PALETTES
# ============================================================
THEMES = {
    "server": {
        "ground": make_arch_shader("v3r2e_srv_ground", (0.10, 0.13, 0.18), (0.18, 0.22, 0.30),
                                    roughness=0.40, metallic=0.10, voronoi_scale=14.0, bump_strength=0.20),
        "pillar": make_arch_shader("v3r2e_srv_pillar", (0.18, 0.20, 0.25), (0.28, 0.32, 0.40),
                                    roughness=0.30, metallic=0.85, voronoi_scale=12.0, bump_strength=0.15,
                                    emission_color=(0.30, 0.85, 1.0), emission_strength=1.5),
        "trim":   make_emit("v3r2e_srv_trim", (0.40, 0.85, 1.0), 8.0),
        "ring":   make_emit("v3r2e_srv_ring", (0.30, 0.80, 1.0), 10.0),
        "banner": make_arch_shader("v3r2e_srv_banner", (0.10, 0.20, 0.35), (0.18, 0.30, 0.45),
                                    roughness=0.85, voronoi_scale=40.0, bump_strength=0.20,
                                    emission_color=(0.30, 0.85, 1.0), emission_strength=0.6),
        "particle": make_emit("v3r2e_srv_part", (0.45, 0.90, 1.0), 12.0),
        "portal": make_portal_shader("v3r2e_srv_portal", (0.20, 0.55, 0.95), (0.55, 0.95, 1.0)),
        "key_color": (0.40, 0.85, 1.0),
        "key_energy": 1500,
    },
    "vault": {
        "ground": make_arch_shader("v3r2e_vlt_ground", (0.45, 0.38, 0.22), (0.55, 0.48, 0.30),
                                    roughness=0.85, voronoi_scale=10.0, bump_strength=0.30),
        "pillar": make_arch_shader("v3r2e_vlt_pillar", (0.65, 0.55, 0.32), (0.78, 0.65, 0.42),
                                    roughness=0.65, metallic=0.20, voronoi_scale=8.0, bump_strength=0.35),
        "trim":   make_arch_shader("v3r2e_vlt_trim", (0.95, 0.75, 0.25), (1.0, 0.88, 0.40),
                                    roughness=0.20, metallic=0.95,
                                    emission_color=(1.0, 0.80, 0.30), emission_strength=2.5),
        "ring":   make_emit("v3r2e_vlt_ring", (1.0, 0.85, 0.40), 8.0),
        "banner": make_arch_shader("v3r2e_vlt_banner", (0.55, 0.20, 0.10), (0.68, 0.30, 0.18),
                                    roughness=0.85, voronoi_scale=40.0, bump_strength=0.20,
                                    emission_color=(0.85, 0.30, 0.10), emission_strength=0.4),
        "particle": make_emit("v3r2e_vlt_part", (1.0, 0.85, 0.40), 10.0),
        "portal": make_portal_shader("v3r2e_vlt_portal", (0.95, 0.65, 0.20), (1.0, 0.90, 0.50)),
        "key_color": (1.0, 0.78, 0.40),
        "key_energy": 1700,
    },
    "wilds": {
        "ground": make_arch_shader("v3r2e_wld_ground", (0.18, 0.10, 0.22), (0.28, 0.18, 0.32),
                                    roughness=0.85, voronoi_scale=12.0, bump_strength=0.40),
        "pillar": make_arch_shader("v3r2e_wld_pillar", (0.25, 0.13, 0.30), (0.38, 0.20, 0.42),
                                    roughness=0.85, voronoi_scale=10.0, bump_strength=0.45,
                                    emission_color=(0.85, 0.30, 1.0), emission_strength=0.8),
        "trim":   make_emit("v3r2e_wld_trim", (0.85, 0.30, 1.0), 8.0),
        "ring":   make_emit("v3r2e_wld_ring", (0.95, 0.40, 1.0), 10.0),
        "banner": make_arch_shader("v3r2e_wld_banner", (0.30, 0.10, 0.40), (0.42, 0.18, 0.55),
                                    roughness=0.85, voronoi_scale=40.0, bump_strength=0.20,
                                    emission_color=(0.85, 0.30, 1.0), emission_strength=0.7),
        "particle": make_emit("v3r2e_wld_part", (1.0, 0.50, 1.0), 12.0),
        "portal": make_portal_shader("v3r2e_wld_portal", (0.55, 0.15, 0.85), (1.0, 0.50, 1.0)),
        "key_color": (0.85, 0.40, 1.0),
        "key_energy": 1400,
    },
    "sanctum": {
        "ground": make_arch_shader("v3r2e_snc_ground", (0.10, 0.05, 0.05), (0.18, 0.10, 0.08),
                                    roughness=0.85, voronoi_scale=12.0, bump_strength=0.40),
        "pillar": make_arch_shader("v3r2e_snc_pillar", (0.15, 0.08, 0.08), (0.25, 0.14, 0.12),
                                    roughness=0.65, metallic=0.30, voronoi_scale=10.0, bump_strength=0.40,
                                    emission_color=(1.0, 0.30, 0.10), emission_strength=1.2),
        "trim":   make_emit("v3r2e_snc_trim", (1.0, 0.35, 0.10), 10.0),
        "ring":   make_emit("v3r2e_snc_ring", (1.0, 0.30, 0.10), 12.0),
        "banner": make_arch_shader("v3r2e_snc_banner", (0.55, 0.10, 0.08), (0.68, 0.18, 0.12),
                                    roughness=0.85, voronoi_scale=40.0, bump_strength=0.20,
                                    emission_color=(1.0, 0.30, 0.10), emission_strength=0.8),
        "particle": make_emit("v3r2e_snc_part", (1.0, 0.55, 0.20), 14.0),
        "portal": make_portal_shader("v3r2e_snc_portal", (0.85, 0.15, 0.05), (1.0, 0.55, 0.20)),
        "key_color": (1.0, 0.45, 0.20),
        "key_energy": 1800,
    },
}

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

def r_cyl(name, loc, r, depth, mat, parent, vc_red=0.5, vc_var=0.4, verts=20, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_cylinder_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     vertices=verts, radius=r, depth=depth, location=loc)
    o.rotation_euler = rot
    return o

def r_sphere(name, loc, r, mat, parent, vc_red=0.5, vc_var=0.4, segs=20, multires=1):
    return refined_part(name, bpy.ops.mesh.primitive_uv_sphere_add, mat, parent,
                        vc_red=vc_red, vc_var=vc_var, multires=multires,
                        segments=segs, ring_count=segs//2, radius=r, location=loc)

def r_torus(name, loc, R, r, mat, parent, vc_red=0.5, vc_var=0.4, ms=48, mn=14, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_torus_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     major_segments=ms, minor_segments=mn,
                     major_radius=R, minor_radius=r, location=loc)
    o.rotation_euler = rot
    return o

def r_cone(name, loc, r1, r2, depth, mat, parent, vc_red=0.5, vc_var=0.4, verts=14, rot=(0,0,0), multires=1):
    o = refined_part(name, bpy.ops.mesh.primitive_cone_add, mat, parent,
                     vc_red=vc_red, vc_var=vc_var, multires=multires,
                     vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o.rotation_euler = rot
    return o

def make_banner(name, loc, w, h, mat, parent):
    """Subdivided plane with cosine wave deformation."""
    bpy.ops.mesh.primitive_plane_add(size=1, location=loc)
    o = bpy.context.object; o.name = name
    o.scale = (w, h, 1)
    o.rotation_euler = (math.pi/2, 0, 0)
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.subdivide(number_cuts=20)
    bpy.ops.mesh.subdivide(number_cuts=4)
    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    for v in o.data.vertices:
        v.co.x += math.sin(v.co.z * 4 + v.co.y * 0.2) * 0.05
        v.co.y += math.sin(v.co.x * 3) * 0.04
    o.data.materials.append(mat)
    uv_unwrap(o)
    paint_vertex_color(o, base_red=0.55, variation=0.30)
    bv = o.modifiers.new("Bevel", 'BEVEL'); bv.width = 0.005; bv.segments = 3
    for poly in o.data.polygons: poly.use_smooth = True
    o.parent = parent
    return o

# ============================================================
# ENTRANCE BUILDER
# ============================================================
def build_entrance(name, theme, origin):
    parent = bpy.data.objects.new(f"de_{name}", None); scene.collection.objects.link(parent)
    parent.location = origin
    t = THEMES[theme]

    # Ground tile
    bpy.ops.mesh.primitive_plane_add(size=1, location=(0, 0, 0))
    fl = bpy.context.object; fl.name = f"{name}_floor"; fl.scale = (8, 8, 1)
    fl.data.materials.append(t["ground"])
    uv_unwrap(fl); paint_vertex_color(fl, base_red=0.55, variation=0.30)
    bv = fl.modifiers.new("Bevel", 'BEVEL'); bv.width = 0.005; bv.segments = 3
    for poly in fl.data.polygons: poly.use_smooth = True
    fl.parent = parent

    # Glow ring on ground
    r_torus(f"{name}_ring",  (0, 0, 0.05), 1.6, 0.08, t["ring"], parent, ms=64, mn=14)
    r_torus(f"{name}_ring2", (0, 0, 0.04), 1.85, 0.04, t["ring"], parent, ms=48, mn=12)

    # Portal disc (refined: NGON circle + portal shader)
    bpy.ops.mesh.primitive_circle_add(vertices=64, radius=1.5, fill_type='NGON', location=(0, 0, 2.5))
    portal = bpy.context.object; portal.name = f"{name}_portal"
    portal.scale = (1.0, 1.4, 1.0)
    portal.rotation_euler = (math.pi/2, 0, 0)
    portal.data.materials.append(t["portal"])
    uv_unwrap(portal); paint_vertex_color(portal, base_red=0.5, variation=0.10)
    portal.parent = parent

    # 2 monument pillars
    for side, x in enumerate([-2.0, 2.0]):
        r_box(f"{name}_p{side}_b1", (x, 0, 0.20), (1.2, 1.2, 0.40), t["pillar"], parent,
               vc_red=0.55, vc_var=0.30)
        r_box(f"{name}_p{side}_b2", (x, 0, 0.55), (1.0, 1.0, 0.30), t["pillar"], parent,
               vc_red=0.55, vc_var=0.30)
        r_cyl(f"{name}_p{side}_s", (x, 0, 2.7), 0.42, 4.2, t["pillar"], parent,
               vc_red=0.55, vc_var=0.30, verts=24)
        # Fluting (4 strips)
        for f in range(4):
            ang = f * math.pi/2 + math.pi/4
            fx = x + math.cos(ang) * 0.42
            fy = math.sin(ang) * 0.42
            r_box(f"{name}_p{side}_f{f}", (fx, fy, 2.7), (0.04, 0.04, 4.0), t["trim"], parent)
        # Capital
        r_box(f"{name}_p{side}_c1", (x, 0, 4.95), (1.0, 1.0, 0.30), t["pillar"], parent,
               vc_red=0.55, vc_var=0.30)
        r_box(f"{name}_p{side}_c2", (x, 0, 5.30), (1.2, 1.2, 0.40), t["pillar"], parent,
               vc_red=0.55, vc_var=0.30)
        # Glowing capital trim band
        r_torus(f"{name}_p{side}_tr", (x, 0, 5.10), 0.65, 0.04, t["trim"], parent, ms=32, mn=10)

    # Lintel beam connecting pillars
    r_box(f"{name}_lintel", (0, 0, 5.75), (5.4, 1.2, 0.40), t["pillar"], parent,
           vc_red=0.55, vc_var=0.30)
    r_box(f"{name}_lintel_top", (0, 0, 6.10), (5.6, 1.4, 0.30), t["pillar"], parent,
           vc_red=0.55, vc_var=0.30)
    r_box(f"{name}_lintel_trim", (0, -0.62, 5.75), (5.0, 0.04, 0.18), t["trim"], parent)

    # Banner cloth hanging center
    make_banner(f"{name}_banner", (0, -0.5, 4.0), 1.4, 2.4, t["banner"], parent)
    r_cyl(f"{name}_banner_rod", (0, -0.5, 5.30), 0.05, 1.6, t["trim"], parent, verts=12, rot=(0, math.pi/2, 0))

    # 10 themed environmental particles
    for i in range(10):
        ang = (i / 10.0) * math.pi * 2
        r = 2.5 + (i % 3) * 0.4
        px = math.cos(ang) * r
        py = math.sin(ang) * 0.6 - 0.3
        pz = 1.0 + (i % 4) * 0.7
        sz = 0.06 + (i % 3) * 0.02
        r_sphere(f"{name}_pt_{i}", (px, py, pz), sz, t["particle"], parent, segs=14)

    # Per-entrance lighting
    sun_loc = (origin[0] + 6, origin[1] - 5, origin[2] + 8)
    bpy.ops.object.light_add(type='AREA', location=sun_loc)
    k = bpy.context.object; k.data.energy = t["key_energy"]
    k.data.color = t["key_color"]; k.data.size = 6
    bpy.ops.object.light_add(type='AREA', location=(origin[0] - 4, origin[1] - 3, origin[2] + 4))
    f = bpy.context.object; f.data.energy = 500
    f.data.color = (0.50, 0.55, 0.85); f.data.size = 4
    bpy.ops.object.light_add(type='POINT', location=(origin[0], origin[1], origin[2] + 2.5))
    a = bpy.context.object; a.data.energy = 250
    a.data.color = t["key_color"]
    return parent

# ============================================================
# LAYOUT — 4 entrances widely spaced
# ============================================================
ENTRANCES = [
    ("server",  "server",  (0,    0,   0)),
    ("vault",   "vault",   (40,   0,   0)),
    ("wilds",   "wilds",   (0,    40,  0)),
    ("sanctum", "sanctum", (40,   40,  0)),
]

CAMERAS = []
for name, theme, origin in ENTRANCES:
    build_entrance(name, theme, Vector(origin))
    bpy.ops.object.camera_add(location=(origin[0]+2, origin[1]-7, origin[2]+3.0))
    cam = bpy.context.object; cam.name = f"cam_{name}"
    cam.data.lens = 50
    cam.data.dof.use_dof = True
    cam.data.dof.aperture_fstop = 4.0
    target = Vector(origin) + Vector((0, 0, 3.0))
    direction = target - cam.location
    cam.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    CAMERAS.append((name, cam))

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render
for name, cam in CAMERAS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_r2_entrance_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# GLB exports
for name, _, origin in ENTRANCES:
    bpy.ops.object.select_all(action='DESELECT')
    parent = bpy.data.objects.get(f"de_{name}")
    if parent:
        parent.select_set(True)
        for child in parent.children_recursive:
            child.select_set(True)
        out_path = os.path.join(EXPORT_DIR, f"entrance_{name}_r2_v3.glb")
        bpy.ops.export_scene.gltf(
            filepath=out_path, use_selection=True,
            export_format='GLB', export_apply=True
        )
        print(f"Exported: {out_path}")

print("=== V3 Round 2 Epic R2-10 Dungeon Entrance Refinement complete ===")
print("=== ALL 40 V3 EPICS COMPLETE (30 R1 + 10 R2) ===")
