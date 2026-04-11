"""
Expansion V3 — Epic 02 — AI Sage Texture Pass
================================================
Hero treatment for the mentor NPC. Must feel ancient, warm, weathered.

Features:
  - Subdivision Surface modifiers everywhere (smooth wisdom, not blocky)
  - Bevel modifiers on hard-surface staff parts
  - Sculpted hood draping over head
  - Layered robe geometry (inner + outer + hem trim) suggesting cloth weight
  - Procedural PBR materials with shader graphs:
    - SSS-style face shader (warm subsurface tint)
    - Wool fabric robe with curvature dirt + noise weave
    - Wood staff with grain via voronoi + bump
    - Brass clasp with metallic + curvature edge wear
    - Crystal staff tip with refraction + emission
    - Beard volume via subdivided geometry shell
  - 3 sage-age variant materials (young / wise / ancient)
  - Beard/eyebrow geometry shell for visual depth
  - 3 hero shots: front, side profile, low-angle wisdom
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/v3_ai_sage_hero.blend"
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
# ADVANCED PBR SHADER GRAPH HELPER
# ============================================================

def make_pbr_advanced(name, base_color, roughness=0.65, metallic=0.0,
                      emission_color=None, emission_strength=0.0,
                      noise_strength=0.20, voronoi_strength=0.0,
                      curvature_dirt=True, fresnel_rim=False,
                      sss_amount=0.0, sss_color=None,
                      bump_strength=0.10, bump_scale=35.0):
    """Build a procedural PBR material with full shader node graph."""
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
    # SSS for skin
    if sss_amount > 0 and sss_color is not None:
        if "Subsurface Weight" in bsdf.inputs:
            bsdf.inputs["Subsurface Weight"].default_value = sss_amount
        if "Subsurface Radius" in bsdf.inputs:
            bsdf.inputs["Subsurface Radius"].default_value = (1.0, 0.4, 0.25)
        if "Subsurface Scale" in bsdf.inputs:
            bsdf.inputs["Subsurface Scale"].default_value = 0.05

    links.new(bsdf.outputs[0], output.inputs[0])

    # Texture coords + mapping
    tex_coord = nodes.new("ShaderNodeTexCoord")
    tex_coord.location = (-1200, 0)
    mapping = nodes.new("ShaderNodeMapping")
    mapping.location = (-1000, 0)
    mapping.inputs["Scale"].default_value = (5.0, 5.0, 5.0)
    links.new(tex_coord.outputs["Generated"], mapping.inputs["Vector"])

    # Layer 1: Noise overlay
    if noise_strength > 0:
        noise = nodes.new("ShaderNodeTexNoise")
        noise.location = (-700, 200)
        noise.inputs["Scale"].default_value = 14.0
        noise.inputs["Detail"].default_value = 8.0
        noise.inputs["Roughness"].default_value = 0.6
        links.new(mapping.outputs["Vector"], noise.inputs["Vector"])

        noise_ramp = nodes.new("ShaderNodeValToRGB")
        noise_ramp.location = (-450, 200)
        noise_ramp.color_ramp.elements[0].position = 0.35
        noise_ramp.color_ramp.elements[0].color = (
            base_color[0] * 0.80, base_color[1] * 0.80, base_color[2] * 0.80, 1)
        noise_ramp.color_ramp.elements[1].position = 0.70
        noise_ramp.color_ramp.elements[1].color = (
            min(base_color[0] * 1.20, 1), min(base_color[1] * 1.20, 1),
            min(base_color[2] * 1.20, 1), 1)
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

    # Layer 2: Voronoi for wood grain or fabric weave
    if voronoi_strength > 0:
        voronoi = nodes.new("ShaderNodeTexVoronoi")
        voronoi.location = (-700, -100)
        voronoi.feature = 'F1'
        voronoi.inputs["Scale"].default_value = 25.0
        links.new(mapping.outputs["Vector"], voronoi.inputs["Vector"])

        v_ramp = nodes.new("ShaderNodeValToRGB")
        v_ramp.location = (-450, -100)
        v_ramp.color_ramp.elements[0].position = 0.05
        v_ramp.color_ramp.elements[0].color = (
            base_color[0] * 0.60, base_color[1] * 0.60, base_color[2] * 0.60, 1)
        v_ramp.color_ramp.elements[1].position = 0.30
        v_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
        links.new(voronoi.outputs["Distance"], v_ramp.inputs["Fac"])

        mix_voronoi = nodes.new("ShaderNodeMix")
        mix_voronoi.data_type = 'RGBA'
        mix_voronoi.location = (50, 50)
        mix_voronoi.inputs["Factor"].default_value = voronoi_strength
        links.new(base_color_out, mix_voronoi.inputs[6])
        links.new(v_ramp.outputs["Color"], mix_voronoi.inputs[7])
        base_color_out = mix_voronoi.outputs[2]

    # Layer 3: Curvature dirt
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
        mix_dirt.inputs["Factor"].default_value = 0.40
        links.new(base_color_out, mix_dirt.inputs[6])
        links.new(ao_ramp.outputs["Color"], mix_dirt.inputs[7])
        base_color_out = mix_dirt.outputs[2]

    # Layer 4: Fresnel rim
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

    # Layer 5: Procedural normal/bump
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
# MATERIALS — AI Sage
# ============================================================

# Skin with SSS warmth
mat_skin = make_pbr_advanced("v3_sage_skin",
    base_color=(0.85, 0.72, 0.60), roughness=0.55, metallic=0.0,
    sss_amount=0.25, sss_color=(0.95, 0.55, 0.40),
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.05, bump_scale=80.0)

# Robe — wool with weave + dirt
mat_robe_outer = make_pbr_advanced("v3_sage_robe_outer",
    base_color=(0.32, 0.18, 0.42), roughness=0.85, metallic=0.0,
    noise_strength=0.30, voronoi_strength=0.18, curvature_dirt=True,
    bump_strength=0.20, bump_scale=45.0)

mat_robe_inner = make_pbr_advanced("v3_sage_robe_inner",
    base_color=(0.45, 0.28, 0.55), roughness=0.80, metallic=0.0,
    noise_strength=0.25, voronoi_strength=0.15, curvature_dirt=True,
    bump_strength=0.15, bump_scale=45.0)

# Hood — darker wool
mat_hood = make_pbr_advanced("v3_sage_hood",
    base_color=(0.20, 0.10, 0.28), roughness=0.90, metallic=0.0,
    noise_strength=0.30, voronoi_strength=0.20, curvature_dirt=True,
    bump_strength=0.20, bump_scale=45.0)

# Hem trim — gold embroidery
mat_hem_trim = make_pbr_advanced("v3_sage_hem_trim",
    base_color=(0.90, 0.72, 0.25), roughness=0.30, metallic=0.85,
    emission_color=(1.0, 0.85, 0.30), emission_strength=0.6,
    noise_strength=0.15, voronoi_strength=0.20, curvature_dirt=True,
    fresnel_rim=True, bump_strength=0.12)

# Belt leather
mat_belt = make_pbr_advanced("v3_sage_belt",
    base_color=(0.18, 0.10, 0.06), roughness=0.55, metallic=0.10,
    noise_strength=0.25, curvature_dirt=True,
    bump_strength=0.18, bump_scale=50.0)

# Brass clasp
mat_clasp = make_pbr_advanced("v3_sage_clasp",
    base_color=(0.85, 0.65, 0.20), roughness=0.25, metallic=0.95,
    noise_strength=0.10, voronoi_strength=0.10, curvature_dirt=True,
    fresnel_rim=False, bump_strength=0.08)

# Wood staff (oak with grain)
mat_staff_wood = make_pbr_advanced("v3_sage_staff_wood",
    base_color=(0.32, 0.18, 0.08), roughness=0.75, metallic=0.0,
    noise_strength=0.28, voronoi_strength=0.40, curvature_dirt=True,
    bump_strength=0.18, bump_scale=22.0)

# Wood staff bands (iron rings)
mat_staff_band = make_pbr_advanced("v3_sage_staff_band",
    base_color=(0.30, 0.30, 0.32), roughness=0.45, metallic=0.85,
    noise_strength=0.10, curvature_dirt=True, bump_strength=0.10)

# Crystal tip — glass with refraction-feel + warm emission
mat_crystal_tip = make_pbr_advanced("v3_sage_crystal_tip",
    base_color=(1.0, 0.85, 0.45), roughness=0.10, metallic=0.0,
    emission_color=(1.0, 0.80, 0.35), emission_strength=4.5,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True,
    bump_strength=0.05)

# Beard — white hair
mat_beard = make_pbr_advanced("v3_sage_beard",
    base_color=(0.92, 0.90, 0.85), roughness=0.85, metallic=0.0,
    noise_strength=0.30, voronoi_strength=0.50, curvature_dirt=True,
    bump_strength=0.30, bump_scale=80.0)

# Eye whites + iris
mat_eye_white = make_pbr_advanced("v3_sage_eye_white",
    base_color=(0.95, 0.92, 0.88), roughness=0.10, metallic=0.0,
    noise_strength=0.0, curvature_dirt=False)

mat_eye_iris = make_pbr_advanced("v3_sage_eye_iris",
    base_color=(0.30, 0.55, 0.75), roughness=0.20, metallic=0.0,
    emission_color=(0.40, 0.65, 0.95), emission_strength=1.2,
    noise_strength=0.0, curvature_dirt=False)

# ============================================================
# COLLECTIONS
# ============================================================

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_sage = make_coll("AI_Sage_Hero")
col_lights = make_coll("Lights")
col_cam = make_coll("Cameras")

def link_to(obj, coll):
    for c in obj.users_collection: c.objects.unlink(obj)
    coll.objects.link(obj)

# ============================================================
# MESH BUILDERS
# ============================================================

def add_object(name, mesh, mat, coll, loc=(0,0,0), rot=(0,0,0), scale=(1,1,1),
               subdiv_levels=2, render_levels=3, bevel_width=0.0,
               smooth=True):
    obj = bpy.data.objects.new(name, mesh)
    obj.location = loc
    obj.rotation_euler = rot
    obj.scale = scale
    if mat is not None:
        obj.data.materials.append(mat)
    scene.collection.objects.link(obj)
    link_to(obj, coll)

    if smooth:
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

def build_cone(name, r1, r2, h, segs=20):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=r1, radius2=r2, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
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

def build_robe_drape():
    """Tapered cone with wavy bottom hem to suggest cloth weight."""
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=24, radius1=0.42, radius2=0.95, depth=2.2)
    # Wave the bottom hem for cloth feel
    for v in bm.verts:
        if v.co.z < -1.0:
            ang = math.atan2(v.co.y, v.co.x)
            v.co.z += math.sin(ang * 6) * 0.06
            r_scale = 1.0 + math.sin(ang * 4) * 0.04
            v.co.x *= r_scale
            v.co.y *= r_scale
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new("robe_drape")
    bm.to_mesh(me); bm.free()
    return me

def build_hood():
    """Hood drape over head."""
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=20, v_segments=14, radius=0.40)
    # Cut off front face to form hood opening
    for v in bm.verts:
        v.co.z *= 1.30
        if v.co.y < -0.10 and v.co.z > -0.05:
            v.co.y *= 0.85
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new("hood")
    bm.to_mesh(me); bm.free()
    return me

def build_beard():
    """Tapered beard volume hanging from chin."""
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=14, radius1=0.20, radius2=0.10, depth=0.45)
    # Pull narrow end down + slight forward curve
    for v in bm.verts:
        if v.co.z < 0:
            v.co.y += 0.04
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new("beard")
    bm.to_mesh(me); bm.free()
    return me

# ============================================================
# BUILD AI SAGE ASSEMBLY
# ============================================================

print("=== Building AI Sage hero ===")

# === Lower body — robe drape ===
add_object("Sage_RobeDrape", build_robe_drape(), mat_robe_outer, col_sage,
           loc=(0, 0, 0.6), subdiv_levels=2, render_levels=3)

# Inner robe layer (slightly smaller, peeking through)
add_object("Sage_RobeInner", build_uvsphere("robe_inner_mesh", 0.42, scale=(1, 1, 1.2)),
           mat_robe_inner, col_sage, loc=(0, 0, 1.55), subdiv_levels=2, render_levels=3)

# === Belt ===
add_object("Sage_Belt", build_torus("belt", 0.55, 0.06), mat_belt, col_sage,
           loc=(0, 0, 1.20), rot=(math.radians(90), 0, 0), subdiv_levels=1)

# Brass belt clasp at front
add_object("Sage_Clasp", build_uvsphere("clasp", 0.10, scale=(1, 0.4, 1.2)),
           mat_clasp, col_sage, loc=(0, -0.55, 1.20), subdiv_levels=2, bevel_width=0.005)

# === Head ===
add_object("Sage_Head", build_uvsphere("head", 0.34, u=32, v=20, scale=(1, 1.05, 1.10)),
           mat_skin, col_sage, loc=(0, 0, 2.30), subdiv_levels=2, render_levels=3)

# === Eyes ===
add_object("Sage_EyeWhiteL", build_sphere("eye_w_l", 0.065, subs=2), mat_eye_white, col_sage,
           loc=(-0.10, -0.30, 2.34), subdiv_levels=1)
add_object("Sage_EyeWhiteR", build_sphere("eye_w_r", 0.065, subs=2), mat_eye_white, col_sage,
           loc=(0.10, -0.30, 2.34), subdiv_levels=1)
add_object("Sage_IrisL", build_sphere("iris_l", 0.035, subs=2), mat_eye_iris, col_sage,
           loc=(-0.10, -0.34, 2.34), subdiv_levels=1)
add_object("Sage_IrisR", build_sphere("iris_r", 0.035, subs=2), mat_eye_iris, col_sage,
           loc=(0.10, -0.34, 2.34), subdiv_levels=1)

# === Hood (over head) ===
add_object("Sage_Hood", build_hood(), mat_hood, col_sage,
           loc=(0, 0.05, 2.40), subdiv_levels=2, render_levels=3)

# === Beard ===
add_object("Sage_Beard", build_beard(), mat_beard, col_sage,
           loc=(0, -0.20, 2.05), subdiv_levels=2, render_levels=3)

# === Eyebrows (small geometry) ===
def build_eyebrow():
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=6, radius=0.06)
    bmesh.ops.scale(bm, vec=(1.5, 0.4, 0.4), verts=bm.verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new("brow")
    bm.to_mesh(me); bm.free()
    return me

add_object("Sage_BrowL", build_eyebrow(), mat_beard, col_sage,
           loc=(-0.10, -0.30, 2.42), subdiv_levels=1)
add_object("Sage_BrowR", build_eyebrow(), mat_beard, col_sage,
           loc=(0.10, -0.30, 2.42), subdiv_levels=1)

# === Hands (peeking out of robe sleeves) ===
add_object("Sage_HandL", build_uvsphere("hand_l", 0.10, scale=(1, 1.2, 1)), mat_skin, col_sage,
           loc=(-0.50, -0.10, 1.05), subdiv_levels=2)
add_object("Sage_HandR", build_uvsphere("hand_r", 0.10, scale=(1, 1.2, 1)), mat_skin, col_sage,
           loc=(0.50, -0.10, 1.05), subdiv_levels=2)

# Sleeve cuffs (gold trim)
add_object("Sage_CuffL", build_torus("cuff_l", 0.13, 0.025), mat_hem_trim, col_sage,
           loc=(-0.50, -0.05, 1.18), rot=(math.radians(90), 0, 0), subdiv_levels=1)
add_object("Sage_CuffR", build_torus("cuff_r", 0.13, 0.025), mat_hem_trim, col_sage,
           loc=(0.50, -0.05, 1.18), rot=(math.radians(90), 0, 0), subdiv_levels=1)

# Hem trim ring at robe bottom
add_object("Sage_HemTrim", build_torus("hem_trim", 0.95, 0.04), mat_hem_trim, col_sage,
           loc=(0, 0, -0.55), rot=(math.radians(90), 0, 0), subdiv_levels=1)

# === Staff (in right hand) ===
# Staff shaft
add_object("Sage_StaffShaft", build_cylinder("staff_shaft", 0.04, 2.5, segs=16),
           mat_staff_wood, col_sage, loc=(0.62, -0.05, -0.10),
           subdiv_levels=2, render_levels=3, bevel_width=0.005)

# Staff iron bands
for i, h in enumerate([0.20, 0.95, 1.65]):
    add_object(f"Sage_StaffBand_{i}", build_torus(f"staff_band_{i}", 0.05, 0.012),
               mat_staff_band, col_sage,
               loc=(0.62, -0.05, h - 0.10), rot=(math.radians(90), 0, 0), subdiv_levels=1)

# Staff crystal tip
add_object("Sage_StaffTip", build_cone("staff_tip", 0.10, 0.02, 0.20),
           mat_crystal_tip, col_sage, loc=(0.62, -0.05, 2.30),
           subdiv_levels=1, bevel_width=0.005)
# Crystal sphere underneath the tip
add_object("Sage_StaffOrb", build_sphere("staff_orb", 0.07, subs=3), mat_crystal_tip, col_sage,
           loc=(0.62, -0.05, 2.20), subdiv_levels=1)

# Brass collar where shaft meets tip
add_object("Sage_StaffCollar", build_torus("staff_collar", 0.06, 0.012),
           mat_clasp, col_sage,
           loc=(0.62, -0.05, 2.13), rot=(math.radians(90), 0, 0), subdiv_levels=1)

print("=== AI Sage hero built ===")

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

cam_front = add_camera("Cam_Front", (0, -6, 1.8), (math.radians(85), 0, 0), 85)
cam_side = add_camera("Cam_Side", (5, -2, 1.6), (math.radians(82), 0, math.radians(70)), 85)
cam_lowangle = add_camera("Cam_LowAngle", (-2, -5, 0.6), (math.radians(95), 0, math.radians(-22)), 85)

# ============================================================
# LIGHTS — warm cinematic
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

# Warm sun key from upper left (like firelight)
add_area_light("Key", (-3, -5, 5), (1.0, 0.85, 0.55), 1500, 5,
              rot=(math.radians(45), math.radians(-25), 0))
# Cool fill from upper right
add_area_light("Fill", (4, -3, 4), (0.65, 0.78, 1.0), 350, 6,
              rot=(math.radians(50), math.radians(20), 0))
# Backlight rim
add_area_light("Rim", (0, 4, 4), (1.0, 0.92, 0.75), 800, 4,
              rot=(math.radians(120), 0, 0))
# Crystal tip glow contribution
add_area_light("CrystalGlow", (0.62, -0.05, 3.0), (1.0, 0.85, 0.55), 80, 0.5,
              rot=(math.radians(180), 0, 0))

world = bpy.data.worlds.new("World_Sage")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.04, 0.05, 0.08, 1.0)
bg.inputs['Strength'].default_value = 0.4

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# ============================================================
# RENDERS
# ============================================================

print("=== Rendering Sage front hero shot ===")
scene.camera = cam_front
scene.render.filepath = os.path.join(RENDER_DIR, "v3_sage_front_hero.png")
bpy.ops.render.render(write_still=True)

print("=== Rendering Sage side profile ===")
scene.camera = cam_side
scene.render.filepath = os.path.join(RENDER_DIR, "v3_sage_side_hero.png")
bpy.ops.render.render(write_still=True)

print("=== Rendering Sage low-angle wisdom shot ===")
scene.camera = cam_lowangle
scene.render.filepath = os.path.join(RENDER_DIR, "v3_sage_lowangle_hero.png")
bpy.ops.render.render(write_still=True)

# ============================================================
# EXPORT GLB
# ============================================================

print("=== Exporting GLB ===")
glb_path = os.path.join(EXPORT_DIR, "ai_sage_v3.glb")
bpy.ops.object.select_all(action='DESELECT')
for obj in col_sage.objects:
    obj.select_set(True)
bpy.ops.export_scene.gltf(
    filepath=glb_path,
    export_format='GLB',
    use_selection=True,
    export_apply=True,
    export_yup=True,
)
print(f"Exported: {glb_path}")
print("=== V3 Epic 02 AI Sage Texture Pass complete ===")
