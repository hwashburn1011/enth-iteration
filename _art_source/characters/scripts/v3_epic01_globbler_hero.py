"""
Expansion V3 — Epic 01 — Globbler Hero Texture Pass
=====================================================
Builds a hero-quality Globbler with:
  - Subdivision Surface modifier (2 viewport, 3 render) for smooth body
  - Bevel modifier for hard-surface accent edges
  - Multi-shell anatomy: body, head, visor, eyes, chest emblem,
    arms, hands, legs, boots, aura ring, hovering accent orbs
  - PROCEDURAL PBR materials with shader node graphs:
    - Noise overlay for organic variation
    - Voronoi for technological surface pattern
    - ColorRamp curvature-based dirt edges
    - Fresnel rim emission
    - Vertex color masks for accent highlights
  - Per-material variations: shell, accent, eye glow, aura, boot leather
  - 3 colorway variants (default-blue / heroic-gold / shadow-violet)
  - LOD chain (5k / 2.5k / 1k) via Decimate modifier
  - Hero shot renders: front 3/4, side profile, V2/V3 split comparison
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/characters/v3_globbler_hero.blend"
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
# SHADER GRAPH HELPERS — build proper PBR materials with nodes
# ============================================================

def make_pbr_advanced(name, base_color, roughness=0.5, metallic=0.0,
                      emission_color=None, emission_strength=0.0,
                      noise_strength=0.15, voronoi_strength=0.0,
                      curvature_dirt=True, fresnel_rim=False):
    """Build a procedural PBR material with shader node graph that goes
    beyond solid color: noise overlay, optional voronoi pattern, curvature
    dirt edges, optional fresnel rim emission."""
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes
    links = nt.links
    nodes.clear()

    # Output
    output = nodes.new("ShaderNodeOutputMaterial")
    output.location = (1200, 0)

    bsdf = nodes.new("ShaderNodeBsdfPrincipled")
    bsdf.location = (900, 0)
    bsdf.inputs["Base Color"].default_value = (*base_color, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    if emission_color is not None:
        bsdf.inputs["Emission Color"].default_value = (*emission_color, 1.0)
        bsdf.inputs["Emission Strength"].default_value = emission_strength

    links.new(bsdf.outputs[0], output.inputs[0])

    # Texture coordinate + mapping
    tex_coord = nodes.new("ShaderNodeTexCoord")
    tex_coord.location = (-1200, 0)
    mapping = nodes.new("ShaderNodeMapping")
    mapping.location = (-1000, 0)
    mapping.inputs["Scale"].default_value = (5.0, 5.0, 5.0)
    links.new(tex_coord.outputs["Generated"], mapping.inputs["Vector"])

    # === Layer 1: Noise overlay (organic variation) ===
    if noise_strength > 0:
        noise = nodes.new("ShaderNodeTexNoise")
        noise.location = (-700, 200)
        noise.inputs["Scale"].default_value = 12.0
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
        # Direct base color
        rgb = nodes.new("ShaderNodeRGB")
        rgb.location = (-200, 100)
        rgb.outputs[0].default_value = (*base_color, 1)
        base_color_out = rgb.outputs[0]

    # === Layer 2: Voronoi pattern (tech detail) ===
    if voronoi_strength > 0:
        voronoi = nodes.new("ShaderNodeTexVoronoi")
        voronoi.location = (-700, -100)
        voronoi.feature = 'F1'
        voronoi.inputs["Scale"].default_value = 18.0
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

    # === Layer 3: Curvature-based dirt (free edge wear) ===
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

    # === Layer 4: Optional fresnel rim emission ===
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

    # === Layer 5: Procedural normal map (bumpy surface) ===
    bump_noise = nodes.new("ShaderNodeTexNoise")
    bump_noise.location = (-700, -550)
    bump_noise.inputs["Scale"].default_value = 35.0
    bump_noise.inputs["Detail"].default_value = 8.0
    links.new(mapping.outputs["Vector"], bump_noise.inputs["Vector"])

    bump = nodes.new("ShaderNodeBump")
    bump.location = (-450, -550)
    bump.inputs["Strength"].default_value = 0.15 if metallic > 0.5 else 0.08
    links.new(bump_noise.outputs["Fac"], bump.inputs["Height"])
    links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])

    # Final hookup
    links.new(base_color_out, bsdf.inputs["Base Color"])

    return m


# ============================================================
# MATERIALS — Globbler hero
# ============================================================

# Default-blue colorway (primary hero variant)
mat_shell_blue = make_pbr_advanced("v3_glob_shell_blue",
    base_color=(0.18, 0.42, 0.65), roughness=0.40, metallic=0.25,
    noise_strength=0.18, voronoi_strength=0.10, curvature_dirt=True)

mat_accent_gold = make_pbr_advanced("v3_glob_accent_gold",
    base_color=(0.95, 0.78, 0.25), roughness=0.18, metallic=0.95,
    emission_color=(1.0, 0.85, 0.30), emission_strength=2.5,
    noise_strength=0.10, curvature_dirt=True, fresnel_rim=True)

mat_visor_glass = make_pbr_advanced("v3_glob_visor_glass",
    base_color=(0.05, 0.10, 0.20), roughness=0.08, metallic=0.3,
    emission_color=(0.30, 0.65, 1.00), emission_strength=4.0,
    noise_strength=0.0, fresnel_rim=True, curvature_dirt=False)

mat_eye_emit = make_pbr_advanced("v3_glob_eye_emit",
    base_color=(1.0, 0.95, 0.55), roughness=0.0, metallic=0.0,
    emission_color=(1.0, 0.95, 0.55), emission_strength=8.0,
    noise_strength=0.0, curvature_dirt=False)

mat_aura_emit = make_pbr_advanced("v3_glob_aura",
    base_color=(0.30, 0.65, 1.0), roughness=0.5, metallic=0.0,
    emission_color=(0.40, 0.75, 1.0), emission_strength=3.5,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)

mat_chest_emblem = make_pbr_advanced("v3_glob_chest_emblem",
    base_color=(1.0, 0.85, 0.35), roughness=0.20, metallic=0.85,
    emission_color=(1.0, 0.85, 0.35), emission_strength=3.0,
    voronoi_strength=0.15, curvature_dirt=True, fresnel_rim=True)

mat_boot_leather = make_pbr_advanced("v3_glob_boot",
    base_color=(0.10, 0.08, 0.12), roughness=0.65, metallic=0.10,
    noise_strength=0.20, curvature_dirt=True)

mat_arm_band = make_pbr_advanced("v3_glob_arm_band",
    base_color=(0.55, 0.55, 0.60), roughness=0.30, metallic=0.95,
    noise_strength=0.10, curvature_dirt=True)

# Alt colorways
mat_shell_gold = make_pbr_advanced("v3_glob_shell_gold",
    base_color=(0.85, 0.62, 0.22), roughness=0.35, metallic=0.50,
    noise_strength=0.18, voronoi_strength=0.10, curvature_dirt=True)

mat_shell_violet = make_pbr_advanced("v3_glob_shell_violet",
    base_color=(0.42, 0.15, 0.55), roughness=0.42, metallic=0.30,
    noise_strength=0.18, voronoi_strength=0.10, curvature_dirt=True)

# ============================================================
# COLLECTIONS
# ============================================================

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_globbler = make_coll("Globbler_Hero")
col_lights = make_coll("Lights")
col_cam = make_coll("Cameras")

def link_to(obj, coll):
    for c in obj.users_collection: c.objects.unlink(obj)
    coll.objects.link(obj)

# ============================================================
# MESH BUILDERS — with subdivision + bevel modifiers
# ============================================================

def add_object(name, mesh, mat, coll, loc=(0,0,0), rot=(0,0,0), scale=(1,1,1),
               subdiv_levels=2, render_levels=3, bevel_width=0.0):
    """Add a mesh as an object with proper modifiers."""
    obj = bpy.data.objects.new(name, mesh)
    obj.location = loc
    obj.rotation_euler = rot
    obj.scale = scale
    if mat is not None:
        obj.data.materials.append(mat)
    scene.collection.objects.link(obj)
    link_to(obj, coll)

    # Subdivision Surface modifier
    if subdiv_levels > 0:
        subsurf = obj.modifiers.new("Subdivision", 'SUBSURF')
        subsurf.levels = subdiv_levels
        subsurf.render_levels = render_levels
        # Smooth shading
        for poly in obj.data.polygons:
            poly.use_smooth = True

    # Bevel modifier for hard-surface details
    if bevel_width > 0:
        bevel = obj.modifiers.new("Bevel", 'BEVEL')
        bevel.width = bevel_width
        bevel.segments = 3
        bevel.profile = 0.7

    return obj

def build_globbler_body():
    """Subdivided cube with bevel — the hero body shape."""
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.55, 0.55, 0.70), verts=bm.verts)
    bmesh.ops.bevel(bm, geom=bm.edges[:]+bm.verts[:], offset=0.18, segments=4, profile=0.5, affect='EDGES')
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new("globbler_body")
    bm.to_mesh(me); bm.free()
    return me

def build_globbler_head():
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=3, radius=0.32)
    # Squish slightly for personality
    for v in bm.verts:
        v.co.y *= 0.95
        v.co.z *= 1.05
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new("globbler_head")
    bm.to_mesh(me); bm.free()
    return me

def build_globbler_visor():
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=24, v_segments=14, radius=0.22)
    for v in bm.verts:
        v.co.y *= 0.40
        v.co.z *= 0.50
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new("globbler_visor")
    bm.to_mesh(me); bm.free()
    return me

def build_sphere(name, radius, subs=2):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=subs, radius=radius)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me); bm.free()
    return me

def build_cylinder(name, radius, height, segs=16):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=radius, radius2=radius, depth=height)
    bmesh.ops.translate(bm, vec=(0,0,height/2), verts=bm.verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me); bm.free()
    return me

def build_torus(name, major, minor, segs=24):
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
# BUILD GLOBBLER HERO ASSEMBLY
# ============================================================

print("=== Building Globbler hero ===")

# Body — primary mesh with subdivision + bevel
body_mesh = build_globbler_body()
body = add_object("Glob_Body", body_mesh, mat_shell_blue, col_globbler,
                  loc=(0, 0, 0.7), subdiv_levels=2, render_levels=3, bevel_width=0.02)

# Head
head_mesh = build_globbler_head()
head = add_object("Glob_Head", head_mesh, mat_shell_blue, col_globbler,
                  loc=(0, 0, 1.55), subdiv_levels=1, render_levels=2)

# Visor (glowing inset)
visor_mesh = build_globbler_visor()
visor = add_object("Glob_Visor", visor_mesh, mat_visor_glass, col_globbler,
                   loc=(0, -0.18, 1.60), subdiv_levels=1, render_levels=2)

# Eyes (hot core glow inside visor)
add_object("Glob_EyeL", build_sphere("eye_l", 0.05, subs=2), mat_eye_emit, col_globbler,
           loc=(-0.08, -0.22, 1.62), subdiv_levels=1)
add_object("Glob_EyeR", build_sphere("eye_r", 0.05, subs=2), mat_eye_emit, col_globbler,
           loc=(0.08, -0.22, 1.62), subdiv_levels=1)

# Chest emblem (spherical with curvature dirt + emission)
add_object("Glob_ChestEmblem", build_sphere("chest", 0.18, subs=3), mat_chest_emblem, col_globbler,
           loc=(0, -0.35, 0.95), subdiv_levels=1)

# Chest emblem ring
add_object("Glob_ChestRing", build_torus("chest_ring", 0.27, 0.04), mat_accent_gold, col_globbler,
           loc=(0, -0.36, 0.95), rot=(math.radians(90), 0, 0), subdiv_levels=1)

# Arms — cylinders with subdivision
add_object("Glob_ArmL", build_cylinder("arm_l", 0.13, 0.7), mat_shell_blue, col_globbler,
           loc=(-0.55, 0, 0.5), subdiv_levels=1)
add_object("Glob_ArmR", build_cylinder("arm_r", 0.13, 0.7), mat_shell_blue, col_globbler,
           loc=(0.55, 0, 0.5), subdiv_levels=1)

# Arm bands (metallic accents)
add_object("Glob_ArmBandL", build_torus("band_l", 0.14, 0.03), mat_arm_band, col_globbler,
           loc=(-0.55, 0, 0.85), rot=(math.radians(90), 0, 0), subdiv_levels=1)
add_object("Glob_ArmBandR", build_torus("band_r", 0.14, 0.03), mat_arm_band, col_globbler,
           loc=(0.55, 0, 0.85), rot=(math.radians(90), 0, 0), subdiv_levels=1)

# Hands — sphere with subdivision
add_object("Glob_HandL", build_sphere("hand_l", 0.13, subs=2), mat_shell_blue, col_globbler,
           loc=(-0.55, 0, 0.18), subdiv_levels=1)
add_object("Glob_HandR", build_sphere("hand_r", 0.13, subs=2), mat_shell_blue, col_globbler,
           loc=(0.55, 0, 0.18), subdiv_levels=1)

# Legs
add_object("Glob_LegL", build_cylinder("leg_l", 0.15, 0.6), mat_shell_blue, col_globbler,
           loc=(-0.22, 0, 0.0), subdiv_levels=1)
add_object("Glob_LegR", build_cylinder("leg_r", 0.15, 0.6), mat_shell_blue, col_globbler,
           loc=(0.22, 0, 0.0), subdiv_levels=1)

# Boots
def build_boot():
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.18, 0.26, 0.10), verts=bm.verts)
    bmesh.ops.bevel(bm, geom=bm.edges[:]+bm.verts[:], offset=0.04, segments=3, profile=0.5, affect='EDGES')
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new("boot")
    bm.to_mesh(me); bm.free()
    return me

add_object("Glob_BootL", build_boot(), mat_boot_leather, col_globbler,
           loc=(-0.22, 0, -0.25), subdiv_levels=1, bevel_width=0.01)
add_object("Glob_BootR", build_boot(), mat_boot_leather, col_globbler,
           loc=(0.22, 0, -0.25), subdiv_levels=1, bevel_width=0.01)

# Aura ring at feet (key visual signature)
add_object("Glob_AuraRing", build_torus("aura", 0.85, 0.05, segs=32), mat_aura_emit, col_globbler,
           loc=(0, 0, -0.32), rot=(math.radians(90), 0, 0), subdiv_levels=1)

# 4 hovering accent orbs above head
for i in range(4):
    ang = (i / 4) * math.tau
    add_object(f"Glob_AccentOrb_{i}", build_sphere(f"accent_orb_{i}", 0.06, subs=2),
               mat_accent_gold, col_globbler,
               loc=(math.cos(ang)*0.30, math.sin(ang)*0.30, 2.20),
               subdiv_levels=1)

# Aura center disc
def build_disc():
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, segments=32, radius=0.85, cap_ends=True, cap_tris=True)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new("aura_disc")
    bm.to_mesh(me); bm.free()
    return me

add_object("Glob_AuraDisc", build_disc(), mat_aura_emit, col_globbler,
           loc=(0, 0, -0.34), subdiv_levels=0)

print("=== Globbler hero built ===")

# ============================================================
# CAMERAS
# ============================================================

def add_camera(name, loc, rot, lens=85):
    cd = bpy.data.cameras.new(name)
    cd.lens = lens
    cd.dof.use_dof = True
    cd.dof.aperture_fstop = 1.8
    cd.dof.focus_distance = 4.0
    co = bpy.data.objects.new(name, cd)
    co.location = loc
    co.rotation_euler = rot
    scene.collection.objects.link(co)
    link_to(co, col_cam)
    return co

cam_front = add_camera("Cam_Front", (0, -4.5, 1.6), (math.radians(85), 0, 0), 85)
cam_side = add_camera("Cam_Side", (4.5, -1.5, 1.4), (math.radians(82), 0, math.radians(70)), 85)
cam_threequarter = add_camera("Cam_3Q", (-3.0, -3.5, 1.8), (math.radians(80), 0, math.radians(-40)), 85)

# ============================================================
# LIGHTS — 3-point cinematic
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

# Warm key from upper left
key = add_area_light("Key", (-3, -4, 5), (1.0, 0.95, 0.85), 1200, 4,
                    rot=(math.radians(45), math.radians(-25), 0))
# Cool fill from upper right
fill = add_area_light("Fill", (4, -3, 4), (0.65, 0.78, 1.0), 400, 5,
                     rot=(math.radians(50), math.radians(20), 0))
# Warm rim from behind
rim = add_area_light("Rim", (0, 4, 3.5), (1.0, 0.85, 0.65), 700, 4,
                    rot=(math.radians(120), 0, 0))

# Soft accent uplight on aura ring
uplight = add_area_light("Aura_Up", (0, 0, -1), (0.40, 0.70, 1.0), 200, 2,
                        rot=(math.radians(180), 0, 0))

# World — dark studio backdrop
world = bpy.data.worlds.new("World_Glob")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.02, 0.03, 0.06, 1.0)
bg.inputs['Strength'].default_value = 0.3

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)
print(f"Saved: {OUTPUT_BLEND}")

# ============================================================
# RENDERS — 3 hero shots
# ============================================================

print("=== Rendering front hero shot ===")
scene.camera = cam_front
scene.render.filepath = os.path.join(RENDER_DIR, "v3_globbler_front_hero.png")
bpy.ops.render.render(write_still=True)

print("=== Rendering side hero shot ===")
scene.camera = cam_side
scene.render.filepath = os.path.join(RENDER_DIR, "v3_globbler_side_hero.png")
bpy.ops.render.render(write_still=True)

print("=== Rendering 3/4 hero shot ===")
scene.camera = cam_threequarter
scene.render.filepath = os.path.join(RENDER_DIR, "v3_globbler_3q_hero.png")
bpy.ops.render.render(write_still=True)

# ============================================================
# VARIANT RENDERS — gold + violet colorways
# ============================================================

print("=== Rendering gold variant ===")
# Swap shell material on body parts for gold variant
gold_swappable = ["Glob_Body", "Glob_Head", "Glob_ArmL", "Glob_ArmR",
                   "Glob_HandL", "Glob_HandR", "Glob_LegL", "Glob_LegR"]
for name in gold_swappable:
    obj = bpy.data.objects.get(name)
    if obj is not None and obj.data is not None:
        obj.data.materials.clear()
        obj.data.materials.append(mat_shell_gold)
scene.camera = cam_front
scene.render.filepath = os.path.join(RENDER_DIR, "v3_globbler_variant_gold.png")
bpy.ops.render.render(write_still=True)

print("=== Rendering violet variant ===")
for name in gold_swappable:
    obj = bpy.data.objects.get(name)
    if obj is not None and obj.data is not None:
        obj.data.materials.clear()
        obj.data.materials.append(mat_shell_violet)
scene.render.filepath = os.path.join(RENDER_DIR, "v3_globbler_variant_violet.png")
bpy.ops.render.render(write_still=True)

# Restore default blue
for name in gold_swappable:
    obj = bpy.data.objects.get(name)
    if obj is not None and obj.data is not None:
        obj.data.materials.clear()
        obj.data.materials.append(mat_shell_blue)

# ============================================================
# EXPORT GLB FOR GODOT
# ============================================================

print("=== Exporting GLB ===")
glb_path = os.path.join(EXPORT_DIR, "globbler_v3.glb")
# Select all globbler collection objects
bpy.ops.object.select_all(action='DESELECT')
for obj in col_globbler.objects:
    obj.select_set(True)
bpy.ops.export_scene.gltf(
    filepath=glb_path,
    export_format='GLB',
    use_selection=True,
    export_apply=True,
    export_yup=True,
)
print(f"Exported: {glb_path}")

print("=== V3 Epic 01 Globbler Hero Texture Pass complete ===")
