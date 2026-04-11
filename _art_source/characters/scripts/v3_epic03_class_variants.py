"""
Expansion V3 — Epic 03 — Class Variants Texture Pass
========================================================
Compiler / Daemon / Kernel — three hero variants with distinct silhouettes,
materials, and accent colors. Each must read instantly from across the
screen and feel like a real character class, not a recolor.

Per class:
  - Subdivided body shell with class-specific bevel pattern
  - Class-specific shoulder rig (pad / spike / plate)
  - Class-specific weapon (sword+shield / twin daggers / tower shield)
  - Class-specific glyph hovering above head (gear / blade / fortress)
  - Class-themed aura ring at feet
  - Procedural PBR materials with full shader graph (noise + voronoi +
    curvature dirt + fresnel rim + procedural normal)
  - Per-class color identity from V2 ClassSystemDatabase

Outputs:
  - 3 hero shot renders (one per class) at 1920x1080
  - 3 portrait renders at 720x960
  - GLB export per class
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/v3_class_variants_hero.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/renders"
EXPORT_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/exports"
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 96
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080

# ============================================================
# SHADER GRAPH HELPER (same as V3-01/02)
# ============================================================

def make_pbr_advanced(name, base_color, roughness=0.5, metallic=0.0,
                      emission_color=None, emission_strength=0.0,
                      noise_strength=0.18, voronoi_strength=0.10,
                      curvature_dirt=True, fresnel_rim=False,
                      bump_strength=0.10, bump_scale=35.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes
    links = nt.links
    nodes.clear()

    output = nodes.new("ShaderNodeOutputMaterial")
    output.location = (1400, 0)

    bsdf = nodes.new("ShaderNodeBsdfPrincipled")
    bsdf.location = (1100, 0)
    bsdf.inputs["Base Color"].default_value = (*base_color, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    if emission_color is not None:
        bsdf.inputs["Emission Color"].default_value = (*emission_color, 1.0)
        bsdf.inputs["Emission Strength"].default_value = emission_strength

    links.new(bsdf.outputs[0], output.inputs[0])

    tex_coord = nodes.new("ShaderNodeTexCoord")
    tex_coord.location = (-1200, 0)
    mapping = nodes.new("ShaderNodeMapping")
    mapping.location = (-1000, 0)
    mapping.inputs["Scale"].default_value = (5.0, 5.0, 5.0)
    links.new(tex_coord.outputs["Generated"], mapping.inputs["Vector"])

    if noise_strength > 0:
        noise = nodes.new("ShaderNodeTexNoise")
        noise.location = (-700, 200)
        noise.inputs["Scale"].default_value = 14.0
        noise.inputs["Detail"].default_value = 6.0
        noise.inputs["Roughness"].default_value = 0.6
        links.new(mapping.outputs["Vector"], noise.inputs["Vector"])

        noise_ramp = nodes.new("ShaderNodeValToRGB")
        noise_ramp.location = (-450, 200)
        noise_ramp.color_ramp.elements[0].position = 0.40
        noise_ramp.color_ramp.elements[0].color = (
            base_color[0] * 0.85, base_color[1] * 0.85, base_color[2] * 0.85, 1)
        noise_ramp.color_ramp.elements[1].position = 0.65
        noise_ramp.color_ramp.elements[1].color = (
            min(base_color[0] * 1.15, 1), min(base_color[1] * 1.15, 1),
            min(base_color[2] * 1.15, 1), 1)
        links.new(noise.outputs["Fac"], noise_ramp.inputs["Fac"])

        mix_noise = nodes.new("ShaderNodeMix")
        mix_noise.data_type = 'RGBA'
        mix_noise.location = (-200, 100)
        mix_noise.inputs["Factor"].default_value = noise_strength
        mix_noise.inputs[6].default_value = (*base_color, 1)
        links.new(noise_ramp.outputs["Color"], mix_noise.inputs[7])
        base_color_out = mix_noise.outputs[2]
    else:
        rgb = nodes.new("ShaderNodeRGB")
        rgb.location = (-200, 100)
        rgb.outputs[0].default_value = (*base_color, 1)
        base_color_out = rgb.outputs[0]

    if voronoi_strength > 0:
        voronoi = nodes.new("ShaderNodeTexVoronoi")
        voronoi.location = (-700, -100)
        voronoi.feature = 'F1'
        voronoi.inputs["Scale"].default_value = 22.0
        links.new(mapping.outputs["Vector"], voronoi.inputs["Vector"])

        v_ramp = nodes.new("ShaderNodeValToRGB")
        v_ramp.location = (-450, -100)
        v_ramp.color_ramp.elements[0].position = 0.05
        v_ramp.color_ramp.elements[1].position = 0.20
        links.new(voronoi.outputs["Distance"], v_ramp.inputs["Fac"])

        mix_voronoi = nodes.new("ShaderNodeMix")
        mix_voronoi.data_type = 'RGBA'
        mix_voronoi.location = (50, 50)
        mix_voronoi.inputs["Factor"].default_value = voronoi_strength
        links.new(base_color_out, mix_voronoi.inputs[6])
        links.new(v_ramp.outputs["Color"], mix_voronoi.inputs[7])
        base_color_out = mix_voronoi.outputs[2]

    if curvature_dirt:
        geo = nodes.new("ShaderNodeNewGeometry")
        geo.location = (-700, -350)
        ao_ramp = nodes.new("ShaderNodeValToRGB")
        ao_ramp.location = (-450, -350)
        ao_ramp.color_ramp.elements[0].position = 0.30
        ao_ramp.color_ramp.elements[0].color = (0.15, 0.10, 0.06, 1)
        ao_ramp.color_ramp.elements[1].position = 0.70
        ao_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
        links.new(geo.outputs["Pointiness"], ao_ramp.inputs["Fac"])

        mix_dirt = nodes.new("ShaderNodeMix")
        mix_dirt.data_type = 'RGBA'
        mix_dirt.location = (300, 0)
        mix_dirt.inputs["Factor"].default_value = 0.30
        links.new(base_color_out, mix_dirt.inputs[6])
        links.new(ao_ramp.outputs["Color"], mix_dirt.inputs[7])
        base_color_out = mix_dirt.outputs[2]

    if fresnel_rim and emission_color is not None:
        fresnel = nodes.new("ShaderNodeFresnel")
        fresnel.location = (300, 300)
        fresnel.inputs["IOR"].default_value = 1.45
        rim_color = nodes.new("ShaderNodeRGB")
        rim_color.location = (300, 450)
        rim_color.outputs[0].default_value = (*emission_color, 1)
        mix_rim = nodes.new("ShaderNodeMix")
        mix_rim.data_type = 'RGBA'
        mix_rim.location = (550, 350)
        mix_rim.inputs[6].default_value = (0, 0, 0, 1)
        links.new(fresnel.outputs["Fac"], mix_rim.inputs["Factor"])
        links.new(rim_color.outputs[0], mix_rim.inputs[7])
        links.new(mix_rim.outputs[2], bsdf.inputs["Emission Color"])
        bsdf.inputs["Emission Strength"].default_value = max(emission_strength, 1.5)

    bump_noise = nodes.new("ShaderNodeTexNoise")
    bump_noise.location = (-700, -550)
    bump_noise.inputs["Scale"].default_value = bump_scale
    bump_noise.inputs["Detail"].default_value = 8.0
    links.new(mapping.outputs["Vector"], bump_noise.inputs["Vector"])
    bump = nodes.new("ShaderNodeBump")
    bump.location = (-450, -550)
    bump.inputs["Strength"].default_value = bump_strength
    links.new(bump_noise.outputs["Fac"], bump.inputs["Height"])
    links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])

    links.new(base_color_out, bsdf.inputs["Base Color"])
    return m

# ============================================================
# CLASS PALETTES (from V2 ClassSystemDatabase)
# ============================================================
CLASSES = {
    "compiler": {
        "shell": (0.18, 0.42, 0.65),
        "accent": (1.0, 0.85, 0.35),
        "weapon": "sword_shield",
        "shoulder": "pad",
        "glyph": "gear",
        "metallic_shell": 0.30,
    },
    "daemon": {
        "shell": (0.62, 0.10, 0.20),
        "accent": (1.0, 0.30, 0.45),
        "weapon": "twin_daggers",
        "shoulder": "spike",
        "glyph": "blade",
        "metallic_shell": 0.25,
    },
    "kernel": {
        "shell": (0.15, 0.30, 0.30),
        "accent": (0.30, 0.85, 0.85),
        "weapon": "tower_shield",
        "shoulder": "plate",
        "glyph": "fortress",
        "metallic_shell": 0.40,
    },
}

# Build per-class material library
class_mats = {}
for cid, c in CLASSES.items():
    class_mats[cid] = {
        "shell": make_pbr_advanced(f"v3_{cid}_shell",
            base_color=c["shell"], roughness=0.40, metallic=c["metallic_shell"],
            noise_strength=0.18, voronoi_strength=0.10, curvature_dirt=True),
        "accent": make_pbr_advanced(f"v3_{cid}_accent",
            base_color=c["accent"], roughness=0.20, metallic=0.92,
            emission_color=c["accent"], emission_strength=2.5,
            voronoi_strength=0.15, fresnel_rim=True),
        "metal": make_pbr_advanced(f"v3_{cid}_metal",
            base_color=(0.55, 0.55, 0.60), roughness=0.30, metallic=0.95,
            noise_strength=0.10, curvature_dirt=True),
        "dark": make_pbr_advanced(f"v3_{cid}_dark",
            base_color=(0.05, 0.05, 0.08), roughness=0.65, metallic=0.10,
            noise_strength=0.20, curvature_dirt=True),
        "aura": make_pbr_advanced(f"v3_{cid}_aura",
            base_color=c["accent"], roughness=0.5, metallic=0.0,
            emission_color=c["accent"], emission_strength=3.5,
            noise_strength=0.0, curvature_dirt=False, fresnel_rim=True),
        "visor": make_pbr_advanced(f"v3_{cid}_visor",
            base_color=(0.05, 0.10, 0.20), roughness=0.08, metallic=0.3,
            emission_color=c["accent"], emission_strength=4.0,
            fresnel_rim=True, curvature_dirt=False, noise_strength=0),
    }

# Skin material (shared)
mat_skin = make_pbr_advanced("v3_class_skin",
    base_color=(0.85, 0.72, 0.60), roughness=0.55, metallic=0.0,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.05, bump_scale=80.0)

# ============================================================
# COLLECTIONS
# ============================================================

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_compiler = make_coll("Class_Compiler")
col_daemon = make_coll("Class_Daemon")
col_kernel = make_coll("Class_Kernel")
col_lights = make_coll("Lights")
col_cam = make_coll("Cameras")

class_colls = {"compiler": col_compiler, "daemon": col_daemon, "kernel": col_kernel}

def link_to(obj, coll):
    for c in obj.users_collection: c.objects.unlink(obj)
    coll.objects.link(obj)

def add_object(name, mesh, mat, coll, loc=(0,0,0), rot=(0,0,0), scale=(1,1,1),
               subdiv_levels=2, render_levels=3, bevel_width=0.0):
    obj = bpy.data.objects.new(name, mesh)
    obj.location = loc
    obj.rotation_euler = rot
    obj.scale = scale
    if mat is not None:
        obj.data.materials.append(mat)
    scene.collection.objects.link(obj)
    link_to(obj, coll)
    for poly in obj.data.polygons:
        poly.use_smooth = True
    if subdiv_levels > 0:
        subsurf = obj.modifiers.new("Subdivision", 'SUBSURF')
        subsurf.levels = subdiv_levels
        subsurf.render_levels = render_levels
    if bevel_width > 0:
        bevel = obj.modifiers.new("Bevel", 'BEVEL')
        bevel.width = bevel_width
        bevel.segments = 3
        bevel.profile = 0.7
    return obj

# ============================================================
# MESH BUILDERS
# ============================================================

def build_class_body():
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.55, 0.55, 0.70), verts=bm.verts)
    bmesh.ops.bevel(bm, geom=bm.edges[:]+bm.verts[:], offset=0.18, segments=4, profile=0.5, affect='EDGES')
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new("class_body")
    bm.to_mesh(me); bm.free()
    return me

def build_sphere(name, radius, subs=2):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=subs, radius=radius)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me); bm.free()
    return me

def build_uvsphere(name, radius, u=24, v=14, scale=(1,1,1)):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=u, v_segments=v, radius=radius)
    bmesh.ops.scale(bm, vec=scale, verts=bm.verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me); bm.free()
    return me

def build_cylinder(name, radius, height, segs=20):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=radius, radius2=radius, depth=height)
    bmesh.ops.translate(bm, vec=(0,0,height/2), verts=bm.verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me); bm.free()
    return me

def build_cone(name, r1, r2, h, segs=12):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=r1, radius2=r2, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me); bm.free()
    return me

def build_cube(name, sx, sy, sz, bevel_offset=0.0):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(sx, sy, sz), verts=bm.verts)
    if bevel_offset > 0:
        bmesh.ops.bevel(bm, geom=bm.edges[:]+bm.verts[:], offset=bevel_offset, segments=3, profile=0.5, affect='EDGES')
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me); bm.free()
    return me

def build_torus(name, major, minor, segs=32):
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, segments=segs, radius=major, cap_ends=False)
    bm.verts.ensure_lookup_table()
    inner = bm.verts[:]
    bmesh.ops.create_circle(bm, segments=segs, radius=major - minor*2, cap_ends=False)
    bm.verts.ensure_lookup_table()
    outer = bm.verts[segs:segs*2]
    for j in range(segs):
        bm.faces.new([inner[j], inner[(j+1)%segs], outer[(j+1)%segs], outer[j]])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me); bm.free()
    return me

# ============================================================
# BUILD A CLASS VARIANT
# ============================================================

def build_class(class_id, x_off):
    c = CLASSES[class_id]
    m = class_mats[class_id]
    coll = class_colls[class_id]

    # Body
    add_object(f"{class_id}_Body", build_class_body(), m["shell"], coll,
               loc=(x_off, 0, 0.7), subdiv_levels=2, render_levels=3, bevel_width=0.02)

    # Head
    add_object(f"{class_id}_Head", build_uvsphere(f"{class_id}_head", 0.32, scale=(1, 0.95, 1.05)),
               m["shell"], coll, loc=(x_off, 0, 1.55), subdiv_levels=2, render_levels=3)

    # Visor
    add_object(f"{class_id}_Visor", build_uvsphere(f"{class_id}_visor", 0.22, u=24, v=14, scale=(1, 0.4, 0.5)),
               m["visor"], coll, loc=(x_off, -0.18, 1.60), subdiv_levels=1)

    # Eyes
    add_object(f"{class_id}_EyeL", build_sphere(f"{class_id}_eye_l", 0.04), m["accent"], coll,
               loc=(x_off-0.08, -0.22, 1.62), subdiv_levels=1)
    add_object(f"{class_id}_EyeR", build_sphere(f"{class_id}_eye_r", 0.04), m["accent"], coll,
               loc=(x_off+0.08, -0.22, 1.62), subdiv_levels=1)

    # Chest emblem (with accent)
    add_object(f"{class_id}_ChestEmblem", build_sphere(f"{class_id}_chest", 0.18, subs=3), m["accent"], coll,
               loc=(x_off, -0.35, 0.95), subdiv_levels=1)
    add_object(f"{class_id}_ChestRing", build_torus(f"{class_id}_chest_ring", 0.27, 0.04),
               m["accent"], coll, loc=(x_off, -0.36, 0.95), rot=(math.radians(90), 0, 0), subdiv_levels=1)

    # ===== Per-class shoulder rig =====
    shoulder = c["shoulder"]
    if shoulder == "pad":  # Compiler — flat broad pads
        for side in [-1, 1]:
            add_object(f"{class_id}_Shoulder_{side}",
                       build_cube(f"{class_id}_pad_{side}", 0.22, 0.32, 0.18, bevel_offset=0.04),
                       m["metal"], coll,
                       loc=(x_off + side*0.55, 0, 1.25), subdiv_levels=1, bevel_width=0.005)
    elif shoulder == "spike":  # Daemon — sharp upward spikes
        for side in [-1, 1]:
            add_object(f"{class_id}_Spike_{side}",
                       build_cone(f"{class_id}_spike_{side}", 0.18, 0.02, 0.5),
                       m["metal"], coll,
                       loc=(x_off + side*0.55, 0, 1.25),
                       rot=(0, side*math.radians(15), 0), subdiv_levels=1)
    elif shoulder == "plate":  # Kernel — heavy stacked plates
        for side in [-1, 1]:
            add_object(f"{class_id}_Plate1_{side}",
                       build_cube(f"{class_id}_plate1_{side}", 0.28, 0.4, 0.1, bevel_offset=0.02),
                       m["metal"], coll,
                       loc=(x_off + side*0.6, 0, 1.3), subdiv_levels=1, bevel_width=0.005)
            add_object(f"{class_id}_Plate2_{side}",
                       build_cube(f"{class_id}_plate2_{side}", 0.32, 0.42, 0.08, bevel_offset=0.02),
                       m["metal"], coll,
                       loc=(x_off + side*0.62, 0, 1.18), subdiv_levels=1, bevel_width=0.005)

    # Arms
    for side in [-1, 1]:
        add_object(f"{class_id}_Arm_{side}", build_cylinder(f"{class_id}_arm_{side}", 0.13, 0.7),
                   m["shell"], coll, loc=(x_off + side*0.55, 0, 0.5), subdiv_levels=1)
        add_object(f"{class_id}_ArmBand_{side}", build_torus(f"{class_id}_band_{side}", 0.14, 0.025),
                   m["accent"], coll, loc=(x_off + side*0.55, 0, 0.85),
                   rot=(math.radians(90), 0, 0), subdiv_levels=1)
        add_object(f"{class_id}_Hand_{side}", build_sphere(f"{class_id}_hand_{side}", 0.13, subs=2),
                   m["shell"], coll, loc=(x_off + side*0.55, 0, 0.18), subdiv_levels=1)

    # Legs
    for side in [-1, 1]:
        add_object(f"{class_id}_Leg_{side}", build_cylinder(f"{class_id}_leg_{side}", 0.15, 0.6),
                   m["shell"], coll, loc=(x_off + side*0.22, 0, 0.0), subdiv_levels=1)
        add_object(f"{class_id}_Boot_{side}",
                   build_cube(f"{class_id}_boot_{side}", 0.18, 0.26, 0.10, bevel_offset=0.02),
                   m["dark"], coll, loc=(x_off + side*0.22, 0, -0.25), subdiv_levels=1, bevel_width=0.005)

    # ===== Per-class weapon =====
    weapon = c["weapon"]
    if weapon == "sword_shield":  # Compiler
        # Sword hilt + blade in right hand
        add_object(f"{class_id}_SwordHilt",
                   build_cube(f"{class_id}_sword_hilt", 0.07, 0.07, 0.18, bevel_offset=0.01),
                   m["dark"], coll, loc=(x_off + 0.62, -0.05, 0.30), subdiv_levels=1)
        add_object(f"{class_id}_SwordGuard",
                   build_cube(f"{class_id}_sword_guard", 0.22, 0.05, 0.05, bevel_offset=0.01),
                   m["metal"], coll, loc=(x_off + 0.62, -0.05, 0.45), subdiv_levels=1)
        add_object(f"{class_id}_SwordBlade",
                   build_cube(f"{class_id}_sword_blade", 0.04, 0.05, 0.55, bevel_offset=0.005),
                   m["metal"], coll, loc=(x_off + 0.62, -0.05, 0.85), subdiv_levels=1)
        add_object(f"{class_id}_SwordRune", build_sphere(f"{class_id}_sword_rune", 0.05),
                   m["accent"], coll, loc=(x_off + 0.62, -0.10, 1.0), subdiv_levels=1)
        # Rune disk on left
        add_object(f"{class_id}_RuneDisk",
                   build_torus(f"{class_id}_rune_disk", 0.22, 0.04),
                   m["accent"], coll, loc=(x_off - 0.62, -0.18, 0.55),
                   rot=(math.radians(90), 0, 0), subdiv_levels=1)
        add_object(f"{class_id}_RuneCenter", build_sphere(f"{class_id}_rune_center", 0.10, subs=2),
                   m["accent"], coll, loc=(x_off - 0.62, -0.18, 0.55), subdiv_levels=1)

    elif weapon == "twin_daggers":  # Daemon
        for side, offset in [(-1, -0.65), (1, 0.65)]:
            add_object(f"{class_id}_Dagger_Hilt_{side}",
                       build_cube(f"{class_id}_dh_{side}", 0.05, 0.05, 0.15, bevel_offset=0.005),
                       m["dark"], coll, loc=(x_off + offset, -0.05, 0.25), subdiv_levels=1)
            add_object(f"{class_id}_Dagger_Blade_{side}",
                       build_cone(f"{class_id}_db_{side}", 0.04, 0.0, 0.35),
                       m["metal"], coll, loc=(x_off + offset, -0.05, 0.50), subdiv_levels=1)
            add_object(f"{class_id}_Dagger_Glow_{side}",
                       build_cylinder(f"{class_id}_dg_{side}", 0.02, 0.32, segs=8),
                       m["accent"], coll, loc=(x_off + offset, -0.04, 0.40), subdiv_levels=1)

    elif weapon == "tower_shield":  # Kernel
        add_object(f"{class_id}_ShieldBody",
                   build_cube(f"{class_id}_shield_body", 0.08, 0.55, 1.0, bevel_offset=0.02),
                   m["metal"], coll, loc=(x_off - 0.7, -0.25, 0.55), subdiv_levels=1, bevel_width=0.005)
        add_object(f"{class_id}_ShieldRing", build_torus(f"{class_id}_shield_ring", 0.32, 0.04),
                   m["accent"], coll, loc=(x_off - 0.66, -0.25, 0.55),
                   rot=(0, math.radians(90), 0), subdiv_levels=1)
        add_object(f"{class_id}_ShieldCore", build_sphere(f"{class_id}_shield_core", 0.14, subs=3),
                   m["accent"], coll, loc=(x_off - 0.62, -0.25, 0.55), subdiv_levels=1)

    # ===== Aura ring at feet =====
    add_object(f"{class_id}_AuraRing", build_torus(f"{class_id}_aura_ring", 0.85, 0.05),
               m["aura"], coll, loc=(x_off, 0, -0.32), rot=(math.radians(90), 0, 0), subdiv_levels=1)

    # ===== Glyph hovering above head =====
    glyph = c["glyph"]
    glyph_loc = (x_off, 0, 2.4)
    if glyph == "gear":
        for i in range(8):
            ang = (i / 8) * math.tau
            add_object(f"{class_id}_GearTooth_{i}",
                       build_cube(f"{class_id}_gear_tooth_{i}", 0.06, 0.06, 0.12, bevel_offset=0.01),
                       m["accent"], coll,
                       loc=(glyph_loc[0] + math.cos(ang)*0.22, glyph_loc[1] + math.sin(ang)*0.22, glyph_loc[2]),
                       rot=(0, 0, ang), subdiv_levels=1)
        add_object(f"{class_id}_GearCenter", build_cylinder(f"{class_id}_gear_center", 0.12, 0.04, segs=16),
                   m["accent"], coll, loc=glyph_loc, subdiv_levels=1)
    elif glyph == "blade":
        for i in range(3):
            ang = (i / 3) * math.tau
            add_object(f"{class_id}_BladeArm_{i}",
                       build_cube(f"{class_id}_blade_arm_{i}", 0.18, 0.025, 0.04, bevel_offset=0.005),
                       m["accent"], coll,
                       loc=(glyph_loc[0] + math.cos(ang)*0.15, glyph_loc[1] + math.sin(ang)*0.15, glyph_loc[2]),
                       rot=(0, 0, ang), subdiv_levels=1)
        add_object(f"{class_id}_BladeHub", build_sphere(f"{class_id}_blade_hub", 0.07, subs=2),
                   m["accent"], coll, loc=glyph_loc, subdiv_levels=1)
    elif glyph == "fortress":
        add_object(f"{class_id}_FortBase",
                   build_cube(f"{class_id}_fort_base", 0.18, 0.18, 0.06, bevel_offset=0.01),
                   m["accent"], coll, loc=glyph_loc, subdiv_levels=1)
        for x_off2 in [-0.10, 0.10]:
            for y_off in [-0.10, 0.10]:
                add_object(f"{class_id}_FortMerlon_{x_off2}_{y_off}",
                           build_cube(f"{class_id}_merlon_{x_off2}_{y_off}", 0.04, 0.04, 0.08, bevel_offset=0.005),
                           m["accent"], coll,
                           loc=(glyph_loc[0]+x_off2, glyph_loc[1]+y_off, glyph_loc[2]+0.07),
                           subdiv_levels=1)


# ============================================================
# BUILD ALL 3 CLASSES
# ============================================================

print("=== Building 3 class variants ===")
for i, cid in enumerate(["compiler", "daemon", "kernel"]):
    x_off = (i - 1) * 3.5
    build_class(cid, x_off)

# ============================================================
# CAMERAS
# ============================================================

def add_camera(name, loc, rot, lens=85):
    cd = bpy.data.cameras.new(name)
    cd.lens = lens
    cd.dof.use_dof = True
    cd.dof.aperture_fstop = 1.8
    cd.dof.focus_distance = 5.5
    co = bpy.data.objects.new(name, cd)
    co.location = loc
    co.rotation_euler = rot
    scene.collection.objects.link(co)
    link_to(co, col_cam)
    return co

# Per-class hero cams (75mm tight)
class_cams = {}
for i, cid in enumerate(["compiler", "daemon", "kernel"]):
    x_off = (i - 1) * 3.5
    class_cams[cid] = add_camera(f"Cam_{cid}_Hero", (x_off + 1.0, -4.5, 1.6),
                                  (math.radians(82), 0, math.radians(15)), 75)

# Group cam wide
group_cam = add_camera("Cam_Group", (0, -8, 2.4), (math.radians(82), 0, 0), 50)

# Per-class portrait cams (85mm tall)
portrait_cams = {}
for i, cid in enumerate(["compiler", "daemon", "kernel"]):
    x_off = (i - 1) * 3.5
    portrait_cams[cid] = add_camera(f"Cam_{cid}_Portrait", (x_off, -3.0, 1.5),
                                     (math.radians(85), 0, 0), 85)

# ============================================================
# LIGHTS
# ============================================================

def add_area_light(name, loc, color, energy, size, rot=(math.radians(45), 0, 0)):
    ld = bpy.data.lights.new(name, type='AREA')
    ld.energy = energy
    ld.size = size
    ld.color = color
    obj = bpy.data.objects.new(name, ld)
    obj.location = loc
    obj.rotation_euler = rot
    scene.collection.objects.link(obj)
    link_to(obj, col_lights)
    return obj

add_area_light("Key", (-3, -5, 5), (1.0, 0.95, 0.85), 1500, 5,
              rot=(math.radians(45), math.radians(-25), 0))
add_area_light("Fill", (4, -3, 4), (0.65, 0.78, 1.0), 400, 6,
              rot=(math.radians(50), math.radians(20), 0))
add_area_light("Rim", (0, 4, 4), (1.0, 0.85, 0.65), 800, 4,
              rot=(math.radians(120), 0, 0))

world = bpy.data.worlds.new("World_Class")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.02, 0.03, 0.06, 1.0)
bg.inputs['Strength'].default_value = 0.3

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# ============================================================
# RENDERS
# ============================================================

print("=== Rendering 3 class hero shots ===")
for cid, coll in class_colls.items():
    # Hide other classes
    for k2, c2 in class_colls.items():
        for obj in c2.objects:
            obj.hide_render = (k2 != cid)
    scene.camera = class_cams[cid]
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_class_{cid}_hero.png")
    bpy.ops.render.render(write_still=True)

# Group shot
print("=== Rendering group shot ===")
for cid, coll in class_colls.items():
    for obj in coll.objects:
        obj.hide_render = False
scene.camera = group_cam
scene.render.filepath = os.path.join(RENDER_DIR, "v3_class_group_hero.png")
bpy.ops.render.render(write_still=True)

# Portraits
print("=== Rendering 3 class portraits ===")
scene.render.resolution_x = 720
scene.render.resolution_y = 960
for cid, coll in class_colls.items():
    for k2, c2 in class_colls.items():
        for obj in c2.objects:
            obj.hide_render = (k2 != cid)
    scene.camera = portrait_cams[cid]
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_class_{cid}_portrait.png")
    bpy.ops.render.render(write_still=True)

# ============================================================
# EXPORT GLB PER CLASS
# ============================================================

print("=== Exporting 3 class GLBs ===")
for cid, coll in class_colls.items():
    bpy.ops.object.select_all(action='DESELECT')
    for k2, c2 in class_colls.items():
        for obj in c2.objects:
            obj.hide_render = False
            obj.select_set(k2 == cid)
    glb_path = os.path.join(EXPORT_DIR, f"class_{cid}_v3.glb")
    bpy.ops.export_scene.gltf(
        filepath=glb_path,
        export_format='GLB',
        use_selection=True,
        export_apply=True,
        export_yup=True,
    )
    print(f"Exported: {glb_path}")

print("=== V3 Epic 03 Class Variants Texture Pass complete ===")
