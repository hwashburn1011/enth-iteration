"""
Expansion V3 — Epic 10 — Dungeon Entrance Hero Polish
=====================================================
4 themed dungeon entrances at trailer-grade quality. Each entrance is
its own hero shot:

  1. SERVER ROOM   — cyan/electric. Server-rack monolith framing a
                     digital portal with cable runs and emissive trim.
  2. MEMORY VAULTS — gold/brass. Ancient temple gate with broken
                     hieroglyph pillars + warm sunset light.
  3. CORRUPTED WILDS — purple/glitch. Twisted gnarled archway with
                       glitch shimmer and dripping corrupted sap.
  4. BOSS SANCTUM   — crimson/obsidian. Volcanic stone gate with
                      pillars of fire and lava trim.

Per entrance:
  - Themed ground tile + portal shimmer plane (refractive shader)
  - 2 monument pillars with weathered detail + capitals + bases
  - Glow ring on the ground beneath the portal
  - Banner cloth (subdivided plane curved + stitched edge)
  - Themed environmental particle clusters (10 small floating elements)
  - Per-entrance sun + 3-point cinematic lighting

Outputs: 4 hero shots @ 1920x1080 + 4 GLB exports.
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(7)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/v3_dungeon_entrances.blend"
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

scene.world = bpy.data.worlds.new("v3_de_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.02, 0.02, 0.04, 1)
bg.inputs["Strength"].default_value = 0.6

# ============================================================
# SHADER: V3 5-layer PBR helper
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
# PORTAL SHIMMER SHADER — animated wave + emission + transmission
# ============================================================
def make_portal_shader(name, color, secondary):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1600, 0)

    # Two-layer: emission disc + glassy wave
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1300, 0)
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Roughness"].default_value = 0.05
    bsdf.inputs["Transmission Weight"].default_value = 0.6
    bsdf.inputs["IOR"].default_value = 1.4
    bsdf.inputs["Emission Color"].default_value = (*secondary, 1)
    bsdf.inputs["Emission Strength"].default_value = 6.0

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1100, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-900, 0)
    mp.inputs["Scale"].default_value = (3,3,3)
    links.new(tc.outputs["Object"], mp.inputs["Vector"])

    # Concentric ring shimmer
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

    # alpha falloff via fresnel for soft edge
    fr = nodes.new("ShaderNodeFresnel"); fr.location = (300, -200)
    fr.inputs["IOR"].default_value = 1.4
    bsdf.inputs["Alpha"].default_value = 0.8
    m.blend_method = 'BLEND'
    links.new(bsdf.outputs[0], out.inputs[0])
    return m

# ============================================================
# UTIL
# ============================================================
def add_subsurf_bevel(obj, levels=2, bevel=0.025):
    s = obj.modifiers.new("Subsurf", 'SUBSURF'); s.levels = levels; s.render_levels = levels+1
    b = obj.modifiers.new("Bevel", 'BEVEL'); b.width = bevel; b.segments = 3; b.profile = 0.7
    for poly in obj.data.polygons: poly.use_smooth = True

def add_box(name, loc, scale, mat, parent=None, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.object; o.name = name; o.scale = scale; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o)
    if parent: o.parent = parent
    return o

def add_cyl(name, loc, r, depth, mat, verts=24, parent=None, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=r, depth=depth, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.015)
    if parent: o.parent = parent
    return o

def add_sphere(name, loc, r, mat, segs=24, parent=None):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segs, ring_count=segs//2, radius=r, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=2, bevel=0.005)
    if parent: o.parent = parent
    return o

def add_torus(name, loc, R, r, mat, ms=48, mn=16, parent=None):
    bpy.ops.mesh.primitive_torus_add(major_segments=ms, minor_segments=mn, major_radius=R, minor_radius=r, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.005)
    if parent: o.parent = parent
    return o

def add_plane(name, loc, sx, sy, mat, rot=(0,0,0)):
    bpy.ops.mesh.primitive_plane_add(size=1, location=loc)
    o = bpy.context.object; o.name = name; o.scale = (sx, sy, 1); o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.002)
    return o

def make_banner(name, loc, w, h, mat, parent=None):
    """Subdivided plane with cosine wave deformation simulating cloth drape."""
    bpy.ops.mesh.primitive_plane_add(size=1, location=loc)
    o = bpy.context.object; o.name = name; o.scale = (w, h, 1)
    o.rotation_euler = (math.pi/2, 0, 0)
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.subdivide(number_cuts=20)
    bpy.ops.mesh.subdivide(number_cuts=4)
    bpy.ops.object.mode_set(mode='OBJECT')
    # apply rotation so we can deform Z axis
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    for v in o.data.vertices:
        # wave by horizontal position
        v.co.x += math.sin(v.co.z * 4 + v.co.y * 0.2) * 0.05
        v.co.y += math.sin(v.co.x * 3) * 0.04
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=2, bevel=0.001)
    if parent: o.parent = parent
    return o

# ============================================================
# THEME-WIDE MATERIALS
# ============================================================
THEMES = {
    "server": {
        "ground": make_pbr("v3de_srv_ground", (0.10,0.13,0.18), 0.40, 0.10,
            noise_strength=0.20, voronoi_strength=0.40, voronoi_scale=14.0, bump_strength=0.20, bump_scale=20.0),
        "pillar": make_pbr("v3de_srv_pillar", (0.18,0.20,0.25), 0.30, 0.85,
            emission_color=(0.30,0.85,1.0), emission_strength=1.5,
            noise_strength=0.10, curvature_dirt=True, fresnel_rim=True, bump_strength=0.15, bump_scale=25.0),
        "trim":   make_pbr("v3de_srv_trim", (0.40,0.85,1.0), 0.10, 0.0,
            emission_color=(0.40,0.85,1.0), emission_strength=8.0,
            noise_strength=0.0, curvature_dirt=False, fresnel_rim=True),
        "ring":   make_pbr("v3de_srv_ring", (0.30,0.80,1.0), 0.10, 0.0,
            emission_color=(0.30,0.80,1.0), emission_strength=10.0,
            noise_strength=0.0, curvature_dirt=False, fresnel_rim=True),
        "banner": make_pbr("v3de_srv_banner", (0.10,0.20,0.35), 0.85, 0.0,
            emission_color=(0.30,0.85,1.0), emission_strength=0.6,
            noise_strength=0.30, curvature_dirt=True, fresnel_rim=True, bump_strength=0.20, bump_scale=40.0),
        "particle": make_pbr("v3de_srv_part", (0.45,0.90,1.0), 0.10, 0.0,
            emission_color=(0.50,0.95,1.0), emission_strength=12.0,
            noise_strength=0.0, curvature_dirt=False, fresnel_rim=True),
        "portal": make_portal_shader("v3de_srv_portal", (0.20,0.55,0.95), (0.55,0.95,1.0)),
        "key_color": (0.40, 0.85, 1.0),
        "key_energy": 1500,
    },
    "vault": {
        "ground": make_pbr("v3de_vlt_ground", (0.45,0.38,0.22), 0.85, 0.0,
            noise_strength=0.30, voronoi_strength=0.45, voronoi_scale=10.0, bump_strength=0.30, bump_scale=14.0),
        "pillar": make_pbr("v3de_vlt_pillar", (0.65,0.55,0.32), 0.65, 0.20,
            noise_strength=0.30, voronoi_strength=0.40, voronoi_scale=8.0, bump_strength=0.35, bump_scale=12.0),
        "trim":   make_pbr("v3de_vlt_trim", (0.95,0.75,0.25), 0.20, 0.95,
            emission_color=(1.0,0.80,0.30), emission_strength=2.5,
            noise_strength=0.10, curvature_dirt=True, fresnel_rim=True),
        "ring":   make_pbr("v3de_vlt_ring", (1.0,0.85,0.40), 0.20, 0.0,
            emission_color=(1.0,0.85,0.40), emission_strength=8.0,
            noise_strength=0.0, curvature_dirt=False, fresnel_rim=True),
        "banner": make_pbr("v3de_vlt_banner", (0.55,0.20,0.10), 0.85, 0.0,
            emission_color=(0.85,0.30,0.10), emission_strength=0.4,
            noise_strength=0.30, curvature_dirt=True, fresnel_rim=True, bump_strength=0.20, bump_scale=40.0),
        "particle": make_pbr("v3de_vlt_part", (1.0,0.85,0.40), 0.20, 0.0,
            emission_color=(1.0,0.85,0.40), emission_strength=10.0,
            noise_strength=0.0, curvature_dirt=False, fresnel_rim=True),
        "portal": make_portal_shader("v3de_vlt_portal", (0.95,0.65,0.20), (1.0,0.90,0.50)),
        "key_color": (1.0, 0.78, 0.40),
        "key_energy": 1700,
    },
    "wilds": {
        "ground": make_pbr("v3de_wld_ground", (0.18,0.10,0.22), 0.85, 0.0,
            noise_strength=0.40, voronoi_strength=0.55, voronoi_scale=12.0, bump_strength=0.40, bump_scale=18.0),
        "pillar": make_pbr("v3de_wld_pillar", (0.25,0.13,0.30), 0.85, 0.0,
            emission_color=(0.85,0.30,1.0), emission_strength=0.8,
            noise_strength=0.40, voronoi_strength=0.55, voronoi_scale=10.0,
            curvature_dirt=True, fresnel_rim=True, bump_strength=0.45, bump_scale=14.0),
        "trim":   make_pbr("v3de_wld_trim", (0.85,0.30,1.0), 0.20, 0.0,
            emission_color=(0.85,0.30,1.0), emission_strength=8.0,
            noise_strength=0.0, curvature_dirt=False, fresnel_rim=True),
        "ring":   make_pbr("v3de_wld_ring", (0.95,0.40,1.0), 0.10, 0.0,
            emission_color=(0.95,0.40,1.0), emission_strength=10.0,
            noise_strength=0.0, curvature_dirt=False, fresnel_rim=True),
        "banner": make_pbr("v3de_wld_banner", (0.30,0.10,0.40), 0.85, 0.0,
            emission_color=(0.85,0.30,1.0), emission_strength=0.7,
            noise_strength=0.40, curvature_dirt=True, fresnel_rim=True, bump_strength=0.20, bump_scale=40.0),
        "particle": make_pbr("v3de_wld_part", (1.0,0.50,1.0), 0.10, 0.0,
            emission_color=(1.0,0.50,1.0), emission_strength=12.0,
            noise_strength=0.0, curvature_dirt=False, fresnel_rim=True),
        "portal": make_portal_shader("v3de_wld_portal", (0.55,0.15,0.85), (1.0,0.50,1.0)),
        "key_color": (0.85, 0.40, 1.0),
        "key_energy": 1400,
    },
    "sanctum": {
        "ground": make_pbr("v3de_snc_ground", (0.10,0.05,0.05), 0.85, 0.0,
            noise_strength=0.30, voronoi_strength=0.55, voronoi_scale=12.0, bump_strength=0.40, bump_scale=18.0),
        "pillar": make_pbr("v3de_snc_pillar", (0.15,0.08,0.08), 0.65, 0.30,
            emission_color=(1.0,0.30,0.10), emission_strength=1.2,
            noise_strength=0.30, voronoi_strength=0.50, voronoi_scale=10.0,
            curvature_dirt=True, fresnel_rim=True, bump_strength=0.40, bump_scale=14.0),
        "trim":   make_pbr("v3de_snc_trim", (1.0,0.35,0.10), 0.10, 0.0,
            emission_color=(1.0,0.35,0.10), emission_strength=10.0,
            noise_strength=0.0, curvature_dirt=False, fresnel_rim=True),
        "ring":   make_pbr("v3de_snc_ring", (1.0,0.30,0.10), 0.10, 0.0,
            emission_color=(1.0,0.30,0.10), emission_strength=12.0,
            noise_strength=0.0, curvature_dirt=False, fresnel_rim=True),
        "banner": make_pbr("v3de_snc_banner", (0.55,0.10,0.08), 0.85, 0.0,
            emission_color=(1.0,0.30,0.10), emission_strength=0.8,
            noise_strength=0.30, curvature_dirt=True, fresnel_rim=True, bump_strength=0.20, bump_scale=40.0),
        "particle": make_pbr("v3de_snc_part", (1.0,0.55,0.20), 0.10, 0.0,
            emission_color=(1.0,0.45,0.10), emission_strength=14.0,
            noise_strength=0.0, curvature_dirt=False, fresnel_rim=True),
        "portal": make_portal_shader("v3de_snc_portal", (0.85,0.15,0.05), (1.0,0.55,0.20)),
        "key_color": (1.0, 0.45, 0.20),
        "key_energy": 1800,
    },
}

# ============================================================
# ENTRANCE BUILDER
# ============================================================
def build_entrance(name, theme, origin):
    parent = bpy.data.objects.new(f"de_{name}", None); scene.collection.objects.link(parent)
    parent.location = origin
    t = THEMES[theme]

    # Ground tile (8x8 themed plane)
    add_plane(f"{name}_floor", (0,0,0), 8, 8, t["ground"])

    # Glow ring on ground
    add_torus(f"{name}_ring", (0,0,0.05), 1.6, 0.08, t["ring"], parent=parent)
    add_torus(f"{name}_ring2", (0,0,0.04), 1.85, 0.04, t["ring"], parent=parent)

    # Portal shimmer plane (2.6 wide, 4.2 tall) — between pillars
    bpy.ops.mesh.primitive_circle_add(vertices=64, radius=1.5, fill_type='NGON', location=(0,0,2.5))
    portal = bpy.context.object; portal.name = f"{name}_portal"
    portal.scale = (1.0, 1.4, 1.0)
    portal.rotation_euler = (math.pi/2, 0, 0)
    portal.data.materials.append(t["portal"])

    # Two monument pillars (left & right of portal)
    for side, x in enumerate([-2.0, 2.0]):
        # Pillar base (wider stepped)
        add_box(f"{name}_p{side}_b1", (x, 0, 0.20), (1.2, 1.2, 0.40), t["pillar"], parent=parent)
        add_box(f"{name}_p{side}_b2", (x, 0, 0.55), (1.0, 1.0, 0.30), t["pillar"], parent=parent)
        # Pillar shaft
        shaft = add_cyl(f"{name}_p{side}_s", (x, 0, 2.7), 0.42, 4.2, t["pillar"], parent=parent, verts=20)
        # Pillar fluting (4 vertical strips)
        for f in range(4):
            ang = f * math.pi/2 + math.pi/4
            fx = x + math.cos(ang) * 0.42
            fy = math.sin(ang) * 0.42
            add_box(f"{name}_p{side}_f{f}", (fx, fy, 2.7), (0.04, 0.04, 4.0), t["trim"], parent=parent)
        # Capital
        add_box(f"{name}_p{side}_c1", (x, 0, 4.95), (1.0, 1.0, 0.30), t["pillar"], parent=parent)
        add_box(f"{name}_p{side}_c2", (x, 0, 5.30), (1.2, 1.2, 0.40), t["pillar"], parent=parent)
        # Glowing capital trim band
        add_torus(f"{name}_p{side}_tr", (x, 0, 5.10), 0.65, 0.04, t["trim"], parent=parent)

    # Lintel above (heavy beam connecting pillars)
    add_box(f"{name}_lintel", (0, 0, 5.75), (5.4, 1.2, 0.40), t["pillar"], parent=parent)
    add_box(f"{name}_lintel_top", (0, 0, 6.10), (5.6, 1.4, 0.30), t["pillar"], parent=parent)
    # Glowing trim runner along front of lintel
    add_box(f"{name}_lintel_trim", (0, -0.62, 5.75), (5.0, 0.04, 0.18), t["trim"], parent=parent)

    # Banner cloth hanging center, between pillars under lintel
    make_banner(f"{name}_banner", (0, -0.5, 4.0), 1.4, 2.4, t["banner"], parent=parent)
    # banner support rod
    add_cyl(f"{name}_banner_rod", (0, -0.5, 5.30), 0.05, 1.6, t["trim"], parent=parent, verts=12, rot=(0, math.pi/2, 0))

    # Themed environmental particles (10 emissive spheres floating)
    for i in range(10):
        ang = (i / 10.0) * math.pi * 2
        r = 2.5 + (i % 3) * 0.4
        px = math.cos(ang) * r
        py = math.sin(ang) * 0.6 - 0.3
        pz = 1.0 + (i % 4) * 0.7
        sz = 0.06 + (i % 3) * 0.02
        add_sphere(f"{name}_pt_{i}", (px, py, pz), sz, t["particle"], parent=parent)

    # Per-entrance lighting — strong key from front-left, accent from below portal
    sun_loc = (origin[0] + 6, origin[1] - 5, origin[2] + 8)
    bpy.ops.object.light_add(type='AREA', location=sun_loc)
    k = bpy.context.object; k.data.energy = t["key_energy"]
    k.data.color = t["key_color"]
    k.data.size = 6
    bpy.ops.object.light_add(type='AREA', location=(origin[0] - 4, origin[1] - 3, origin[2] + 4))
    f = bpy.context.object; f.data.energy = 500
    f.data.color = (0.50, 0.55, 0.85)
    f.data.size = 4
    # accent point under portal
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
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_dungeon_entrance_{name}_hero.png")
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
        out_path = os.path.join(EXPORT_DIR, f"dungeon_entrance_{name}_v3.glb")
        bpy.ops.export_scene.gltf(
            filepath=out_path, use_selection=True,
            export_format='GLB', export_apply=True
        )
        print(f"Exported: {out_path}")

print("=== V3 Epic 10 Dungeon Entrance Hero Polish complete ===")
