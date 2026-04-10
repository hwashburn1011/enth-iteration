"""
Expansion V3 — Epic 05 — Pet Sculpts Texture Pass
=====================================================
8 hero pet models with species-appropriate materials:
  - Data Sprite: glowing flying orb (synthetic emission)
  - Patch Dog: 4-legged with fur (curvature dirt + bump fur noise)
  - Bit Cat: sleek black with binary pattern (voronoi tech)
  - Bug Buddy: insectoid with chitin carapace
  - Memory Owl: regal feathered with crystal eye
  - Cache Mouse: plump fur with cheek pouch
  - Echo Bird: sleek feathers with sound-wave tail
  - Crystal Fox: ethereal fur with crystal accents

Each pet:
  - Subdivision Surface (2 viewport / 3 render)
  - Bevel where applicable
  - Procedural PBR shader: noise + voronoi + curvature dirt + fresnel rim
  - Per-pet bump scale tuned to species (fur = high freq, chitin = mid)
  - Hero render at 1920x1080 + portrait at 720x960
  - Group hero shot showing all 8 pets in a row

Outputs:
  - 8 hero shot renders + 8 portraits + 1 group shot
  - 1 GLB export per pet
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/pets/v3_pets_hero.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/pets/renders"
EXPORT_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/pets/exports"
os.makedirs(RENDER_DIR, exist_ok=True)
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 96
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080

# ============================================================
# SHADER HELPER (V3 standard)
# ============================================================

def make_pbr_advanced(name, base_color, roughness=0.55, metallic=0.0,
                      emission_color=None, emission_strength=0.0,
                      noise_strength=0.18, voronoi_strength=0.0,
                      curvature_dirt=True, fresnel_rim=False,
                      bump_strength=0.10, bump_scale=35.0,
                      sss_amount=0.0):
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
    if sss_amount > 0:
        if "Subsurface Weight" in bsdf.inputs:
            bsdf.inputs["Subsurface Weight"].default_value = sss_amount
        if "Subsurface Radius" in bsdf.inputs:
            bsdf.inputs["Subsurface Radius"].default_value = (1.0, 0.4, 0.25)
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
        links.new(mapping.outputs["Vector"], noise.inputs["Vector"])
        ramp = nodes.new("ShaderNodeValToRGB")
        ramp.location = (-450, 200)
        ramp.color_ramp.elements[0].position = 0.40
        ramp.color_ramp.elements[0].color = (
            base_color[0] * 0.85, base_color[1] * 0.85, base_color[2] * 0.85, 1)
        ramp.color_ramp.elements[1].position = 0.65
        ramp.color_ramp.elements[1].color = (
            min(base_color[0] * 1.15, 1), min(base_color[1] * 1.15, 1),
            min(base_color[2] * 1.15, 1), 1)
        links.new(noise.outputs["Fac"], ramp.inputs["Fac"])
        mix = nodes.new("ShaderNodeMix")
        mix.data_type = 'RGBA'
        mix.location = (-200, 100)
        mix.inputs["Factor"].default_value = noise_strength
        mix.inputs[6].default_value = (*base_color, 1)
        links.new(ramp.outputs["Color"], mix.inputs[7])
        base_out = mix.outputs[2]
    else:
        rgb = nodes.new("ShaderNodeRGB")
        rgb.location = (-200, 100)
        rgb.outputs[0].default_value = (*base_color, 1)
        base_out = rgb.outputs[0]

    if voronoi_strength > 0:
        v = nodes.new("ShaderNodeTexVoronoi")
        v.location = (-700, -100)
        v.feature = 'F1'
        v.inputs["Scale"].default_value = 22.0
        links.new(mapping.outputs["Vector"], v.inputs["Vector"])
        v_ramp = nodes.new("ShaderNodeValToRGB")
        v_ramp.location = (-450, -100)
        v_ramp.color_ramp.elements[0].position = 0.05
        v_ramp.color_ramp.elements[1].position = 0.20
        links.new(v.outputs["Distance"], v_ramp.inputs["Fac"])
        mv = nodes.new("ShaderNodeMix")
        mv.data_type = 'RGBA'
        mv.location = (50, 50)
        mv.inputs["Factor"].default_value = voronoi_strength
        links.new(base_out, mv.inputs[6])
        links.new(v_ramp.outputs["Color"], mv.inputs[7])
        base_out = mv.outputs[2]

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
        md = nodes.new("ShaderNodeMix")
        md.data_type = 'RGBA'
        md.location = (300, 0)
        md.inputs["Factor"].default_value = 0.30
        links.new(base_out, md.inputs[6])
        links.new(ao_ramp.outputs["Color"], md.inputs[7])
        base_out = md.outputs[2]

    if fresnel_rim and emission_color is not None:
        fresnel = nodes.new("ShaderNodeFresnel")
        fresnel.location = (300, 300)
        fresnel.inputs["IOR"].default_value = 1.45
        rim_color = nodes.new("ShaderNodeRGB")
        rim_color.location = (300, 450)
        rim_color.outputs[0].default_value = (*emission_color, 1)
        mr = nodes.new("ShaderNodeMix")
        mr.data_type = 'RGBA'
        mr.location = (550, 350)
        mr.inputs[6].default_value = (0, 0, 0, 1)
        links.new(fresnel.outputs["Fac"], mr.inputs["Factor"])
        links.new(rim_color.outputs[0], mr.inputs[7])
        links.new(mr.outputs[2], bsdf.inputs["Emission Color"])
        bsdf.inputs["Emission Strength"].default_value = max(emission_strength, 1.5)

    bn = nodes.new("ShaderNodeTexNoise")
    bn.location = (-700, -550)
    bn.inputs["Scale"].default_value = bump_scale
    bn.inputs["Detail"].default_value = 8.0
    links.new(mapping.outputs["Vector"], bn.inputs["Vector"])
    bump = nodes.new("ShaderNodeBump")
    bump.location = (-450, -550)
    bump.inputs["Strength"].default_value = bump_strength
    links.new(bn.outputs["Fac"], bump.inputs["Height"])
    links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])

    links.new(base_out, bsdf.inputs["Base Color"])
    return m

# ============================================================
# PER-PET MATERIALS (species-appropriate)
# ============================================================

# Data Sprite (synthetic emission)
mat_sprite_core = make_pbr_advanced("v3_pet_sprite_core",
    base_color=(0.30, 0.55, 0.95), roughness=0.30, metallic=0.0,
    emission_color=(0.40, 0.70, 1.0), emission_strength=4.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mat_sprite_glow = make_pbr_advanced("v3_pet_sprite_glow",
    base_color=(0.50, 0.85, 1.0), roughness=0.40, metallic=0.0,
    emission_color=(0.50, 0.85, 1.0), emission_strength=5.5,
    noise_strength=0.0, curvature_dirt=False)

# Patch Dog (fur with bump + curvature)
mat_dog_body = make_pbr_advanced("v3_pet_dog_body",
    base_color=(0.65, 0.45, 0.20), roughness=0.85, metallic=0.0,
    noise_strength=0.30, curvature_dirt=True,
    bump_strength=0.30, bump_scale=80.0)
mat_dog_patch = make_pbr_advanced("v3_pet_dog_patch",
    base_color=(0.95, 0.92, 0.85), roughness=0.85, metallic=0.0,
    noise_strength=0.25, curvature_dirt=True,
    bump_strength=0.30, bump_scale=80.0)
mat_dog_collar = make_pbr_advanced("v3_pet_dog_collar",
    base_color=(0.85, 0.20, 0.20), roughness=0.40, metallic=0.20,
    noise_strength=0.15, curvature_dirt=True)
mat_dog_nose = make_pbr_advanced("v3_pet_dog_nose",
    base_color=(0.10, 0.08, 0.10), roughness=0.20, metallic=0.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=False)

# Bit Cat (sleek black + binary pattern)
mat_cat_body = make_pbr_advanced("v3_pet_cat_body",
    base_color=(0.10, 0.10, 0.15), roughness=0.55, metallic=0.0,
    noise_strength=0.20, voronoi_strength=0.18, curvature_dirt=True,
    bump_strength=0.20, bump_scale=70.0)
mat_cat_eye = make_pbr_advanced("v3_pet_cat_eye",
    base_color=(0.30, 0.95, 0.40), roughness=0.20, metallic=0.0,
    emission_color=(0.40, 1.0, 0.50), emission_strength=3.5,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)

# Bug Buddy (chitin + glow wings)
mat_bug_carapace = make_pbr_advanced("v3_pet_bug_carapace",
    base_color=(0.55, 0.20, 0.55), roughness=0.30, metallic=0.55,
    noise_strength=0.18, voronoi_strength=0.10, curvature_dirt=True,
    fresnel_rim=False, bump_strength=0.12)
mat_bug_glow = make_pbr_advanced("v3_pet_bug_glow",
    base_color=(1.0, 0.30, 0.85), roughness=0.30, metallic=0.0,
    emission_color=(1.0, 0.40, 0.85), emission_strength=4.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)

# Memory Owl (feathered + crystal)
mat_owl_body = make_pbr_advanced("v3_pet_owl_body",
    base_color=(0.55, 0.42, 0.25), roughness=0.85, metallic=0.0,
    noise_strength=0.30, voronoi_strength=0.20, curvature_dirt=True,
    bump_strength=0.25, bump_scale=60.0)
mat_owl_chest = make_pbr_advanced("v3_pet_owl_chest",
    base_color=(0.85, 0.78, 0.55), roughness=0.85, metallic=0.0,
    noise_strength=0.30, voronoi_strength=0.18, curvature_dirt=True,
    bump_strength=0.25, bump_scale=60.0)
mat_owl_eye = make_pbr_advanced("v3_pet_owl_eye",
    base_color=(1.0, 0.85, 0.30), roughness=0.20, metallic=0.0,
    emission_color=(1.0, 0.85, 0.30), emission_strength=3.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mat_owl_crystal = make_pbr_advanced("v3_pet_owl_crystal",
    base_color=(0.85, 0.55, 1.0), roughness=0.10, metallic=0.0,
    emission_color=(1.0, 0.70, 1.0), emission_strength=4.0,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)

# Cache Mouse (plump fur)
mat_mouse_body = make_pbr_advanced("v3_pet_mouse_body",
    base_color=(0.55, 0.50, 0.45), roughness=0.85, metallic=0.0,
    noise_strength=0.30, curvature_dirt=True,
    bump_strength=0.30, bump_scale=80.0)
mat_mouse_pouch = make_pbr_advanced("v3_pet_mouse_pouch",
    base_color=(0.85, 0.65, 0.20), roughness=0.85, metallic=0.0,
    noise_strength=0.25, curvature_dirt=True,
    bump_strength=0.25, bump_scale=70.0)
mat_mouse_nose = make_pbr_advanced("v3_pet_mouse_nose",
    base_color=(0.85, 0.30, 0.45), roughness=0.40, metallic=0.0,
    noise_strength=0.0, curvature_dirt=False)

# Echo Bird (sleek + sound waves)
mat_bird_body = make_pbr_advanced("v3_pet_bird_body",
    base_color=(0.20, 0.55, 0.85), roughness=0.55, metallic=0.0,
    noise_strength=0.20, voronoi_strength=0.15, curvature_dirt=True,
    bump_strength=0.18, bump_scale=55.0)
mat_bird_wing = make_pbr_advanced("v3_pet_bird_wing",
    base_color=(0.40, 0.75, 1.0), roughness=0.50, metallic=0.0,
    noise_strength=0.18, voronoi_strength=0.20, curvature_dirt=True,
    bump_strength=0.18, bump_scale=55.0)
mat_bird_tail = make_pbr_advanced("v3_pet_bird_tail",
    base_color=(0.60, 0.85, 1.0), roughness=0.40, metallic=0.0,
    emission_color=(0.65, 0.90, 1.0), emission_strength=2.5,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)
mat_bird_beak = make_pbr_advanced("v3_pet_bird_beak",
    base_color=(0.95, 0.78, 0.30), roughness=0.40, metallic=0.10,
    noise_strength=0.10, curvature_dirt=True)

# Crystal Fox (ethereal fur + crystal)
mat_fox_body = make_pbr_advanced("v3_pet_fox_body",
    base_color=(0.95, 0.55, 0.30), roughness=0.55, metallic=0.0,
    noise_strength=0.25, curvature_dirt=True,
    bump_strength=0.30, bump_scale=80.0)
mat_fox_chest = make_pbr_advanced("v3_pet_fox_chest",
    base_color=(0.95, 0.92, 0.85), roughness=0.65, metallic=0.0,
    noise_strength=0.25, curvature_dirt=True,
    bump_strength=0.30, bump_scale=80.0)
mat_fox_crystal = make_pbr_advanced("v3_pet_fox_crystal",
    base_color=(0.30, 0.85, 1.0), roughness=0.10, metallic=0.0,
    emission_color=(0.40, 0.90, 1.0), emission_strength=4.5,
    noise_strength=0.0, curvature_dirt=False, fresnel_rim=True)

mat_eye_dark = make_pbr_advanced("v3_pet_eye_dark",
    base_color=(0.05, 0.05, 0.10), roughness=0.40, metallic=0.0,
    noise_strength=0.0, curvature_dirt=False)

# ============================================================
# COLLECTIONS
# ============================================================

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_pets = make_coll("V3_Pets")
col_lights = make_coll("Lights")
col_cam = make_coll("Cameras")

def link_to(obj, coll):
    for c in obj.users_collection: c.objects.unlink(obj)
    coll.objects.link(obj)

def add_object(name, mesh, mat, coll=col_pets, loc=(0,0,0), rot=(0,0,0), scale=(1,1,1),
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
        ss = obj.modifiers.new("Subdivision", 'SUBSURF')
        ss.levels = subdiv_levels
        ss.render_levels = render_levels
    if bevel_width > 0:
        bv = obj.modifiers.new("Bevel", 'BEVEL')
        bv.width = bevel_width
        bv.segments = 3
    return obj

def build_sphere(name, r, subs=2):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=subs, radius=r)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    return me

def build_uvsphere(name, r, u=24, v=14, scale=(1,1,1)):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=u, v_segments=v, radius=r)
    bmesh.ops.scale(bm, vec=scale, verts=bm.verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    return me

def build_cylinder(name, r, h, segs=20):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=r, radius2=r, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    return me

def build_cone(name, r1, r2, h, segs=12):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=r1, radius2=r2, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    return me

# ============================================================
# PET BUILDERS — each pet gets its own collection-tagged objects
# ============================================================

PET_OBJ_TAG = {}  # pet_name -> list of obj names

def tag(name, *obj_names):
    PET_OBJ_TAG.setdefault(name, []).extend(obj_names)

def build_data_sprite(x_off):
    """Glowing flying orb + 4 sub-orbs + tail wisp."""
    objs = []
    o = add_object("v3_sprite_core", build_sphere("sprite_c", 0.30, subs=4),
                   mat_sprite_core, loc=(x_off, 0, 0.55), subdiv_levels=2)
    objs.append(o.name)
    for i in range(4):
        ang = (i / 4) * math.tau
        o = add_object(f"v3_sprite_sub_{i}", build_sphere(f"ss_{i}", 0.10, subs=2),
                       mat_sprite_glow,
                       loc=(x_off + math.cos(ang)*0.45, math.sin(ang)*0.45, 0.55),
                       subdiv_levels=1)
        objs.append(o.name)
    for i in range(3):
        o = add_object(f"v3_sprite_tail_{i}", build_sphere(f"st_{i}", 0.12 - i*0.025, subs=2),
                       mat_sprite_glow,
                       loc=(x_off, 0.30 + i*0.18, 0.45 - i*0.06),
                       subdiv_levels=1)
        objs.append(o.name)
    tag("data_sprite", *objs)

def build_patch_dog(x_off):
    """Stocky 4-legged dog with white patches + collar."""
    objs = []
    o = add_object("v3_dog_body", build_uvsphere("dog_body", 0.30, scale=(1.6, 0.9, 0.9)),
                   mat_dog_body, loc=(x_off, 0, 0.40), subdiv_levels=2)
    objs.append(o.name)
    o = add_object("v3_dog_head", build_sphere("dog_head", 0.22, subs=3),
                   mat_dog_body, loc=(x_off + 0.40, 0, 0.55), subdiv_levels=2)
    objs.append(o.name)
    # Snout
    o = add_object("v3_dog_snout", build_uvsphere("dog_snout", 0.10, scale=(1.2, 1.4, 0.7)),
                   mat_dog_patch, loc=(x_off + 0.55, 0, 0.50), subdiv_levels=1)
    objs.append(o.name)
    # Nose
    o = add_object("v3_dog_nose", build_sphere("dog_nose", 0.04, subs=2),
                   mat_dog_nose, loc=(x_off + 0.65, 0, 0.52), subdiv_levels=1)
    objs.append(o.name)
    # Ears (cones angled)
    for side in [-1, 1]:
        o = add_object(f"v3_dog_ear_{side}",
                       build_cone(f"de_{side}", 0.06, 0.0, 0.16),
                       mat_dog_body,
                       loc=(x_off + 0.36, side*0.12, 0.72),
                       rot=(side*math.radians(15), 0, 0), subdiv_levels=1)
        objs.append(o.name)
    # 4 legs
    for sx in [-0.20, 0.20]:
        for sy in [-0.18, 0.18]:
            o = add_object(f"v3_dog_leg_{sx}_{sy}",
                           build_cylinder(f"dl_{sx}_{sy}", 0.06, 0.32),
                           mat_dog_body,
                           loc=(x_off + sx, sy, -0.06), subdiv_levels=1)
            objs.append(o.name)
    # Tail
    o = add_object("v3_dog_tail", build_cone("dog_tail", 0.05, 0.0, 0.30),
                   mat_dog_body,
                   loc=(x_off - 0.45, 0, 0.55),
                   rot=(math.radians(-45), 0, 0), subdiv_levels=1)
    objs.append(o.name)
    # 3 white patches
    for i in range(3):
        o = add_object(f"v3_dog_patch_{i}", build_sphere(f"dp_{i}", 0.08, subs=2),
                       mat_dog_patch,
                       loc=(x_off - 0.20 + i*0.20, -0.30, 0.45), subdiv_levels=1)
        objs.append(o.name)
    # Collar
    o = add_object("v3_dog_collar", build_cylinder("dog_collar", 0.18, 0.04, segs=16),
                   mat_dog_collar,
                   loc=(x_off + 0.30, 0, 0.50),
                   rot=(0, math.radians(90), 0), subdiv_levels=1)
    objs.append(o.name)
    tag("patch_dog", *objs)

def build_bit_cat(x_off):
    """Sleek black cat with binary pattern + glowing eyes."""
    objs = []
    o = add_object("v3_cat_body", build_uvsphere("cat_body", 0.25, scale=(1.7, 0.7, 0.8)),
                   mat_cat_body, loc=(x_off, 0, 0.35), subdiv_levels=2)
    objs.append(o.name)
    o = add_object("v3_cat_head", build_uvsphere("cat_head", 0.18, scale=(1, 0.9, 1)),
                   mat_cat_body, loc=(x_off + 0.38, 0, 0.50), subdiv_levels=2)
    objs.append(o.name)
    # Triangular ears
    for side in [-1, 1]:
        o = add_object(f"v3_cat_ear_{side}",
                       build_cone(f"ce_{side}", 0.07, 0.0, 0.18),
                       mat_cat_body,
                       loc=(x_off + 0.34, side*0.10, 0.70), subdiv_levels=1)
        objs.append(o.name)
    # Glowing eyes
    for side in [-1, 1]:
        o = add_object(f"v3_cat_eye_{side}", build_sphere(f"cey_{side}", 0.04, subs=2),
                       mat_cat_eye,
                       loc=(x_off + 0.50, side*0.08, 0.52), subdiv_levels=1)
        objs.append(o.name)
    # 4 thin legs
    for sx in [-0.18, 0.18]:
        for sy in [-0.15, 0.15]:
            o = add_object(f"v3_cat_leg_{sx}_{sy}",
                           build_cylinder(f"cl_{sx}_{sy}", 0.04, 0.32),
                           mat_cat_body,
                           loc=(x_off + sx, sy, -0.05), subdiv_levels=1)
            objs.append(o.name)
    # Long tail (3 segments)
    for i in range(3):
        o = add_object(f"v3_cat_tail_{i}",
                       build_cylinder(f"ct_{i}", 0.04 - i*0.005, 0.18),
                       mat_cat_body,
                       loc=(x_off - 0.40 - i*0.10, 0, 0.40 + i*0.10),
                       rot=(0, math.radians(45 - i*15), 0), subdiv_levels=1)
        objs.append(o.name)
    tag("bit_cat", *objs)

def build_bug_buddy(x_off):
    """Insectoid with carapace + glowing wings + 6 legs."""
    objs = []
    # 3-segment body
    for i, (r, dx) in enumerate([(0.18, 0.30), (0.20, 0), (0.24, -0.30)]):
        o = add_object(f"v3_bug_seg_{i}", build_sphere(f"bs_{i}", r, subs=3),
                       mat_bug_carapace,
                       loc=(x_off + dx, 0, 0.40 + (0 if i != 0 else 0.05)),
                       subdiv_levels=2)
        objs.append(o.name)
    # Glowing wings (2)
    for side in [-1, 1]:
        o = add_object(f"v3_bug_wing_{side}",
                       build_uvsphere(f"bw_{side}", 0.20, scale=(0.5, 1.5, 0.05)),
                       mat_bug_glow,
                       loc=(x_off, side*0.30, 0.55), subdiv_levels=2)
        objs.append(o.name)
    # 6 legs
    for i in range(3):
        for side in [-1, 1]:
            o = add_object(f"v3_bug_leg_{i}_{side}",
                           build_cylinder(f"bl_{i}_{side}", 0.025, 0.25),
                           mat_bug_carapace,
                           loc=(x_off - 0.20 + i*0.20, side*0.18, 0.10),
                           rot=(0, side*math.radians(20), 0), subdiv_levels=1)
            objs.append(o.name)
    # Antennae
    for side in [-1, 1]:
        o = add_object(f"v3_bug_antenna_{side}",
                       build_cylinder(f"ba_{side}", 0.015, 0.20),
                       mat_bug_carapace,
                       loc=(x_off + 0.36, side*0.05, 0.60),
                       rot=(0, math.radians(-15), 0), subdiv_levels=1)
        objs.append(o.name)
    # Tail glow
    o = add_object("v3_bug_glow", build_sphere("bg", 0.10, subs=3),
                   mat_bug_glow,
                   loc=(x_off - 0.55, 0, 0.40), subdiv_levels=1)
    objs.append(o.name)
    tag("bug_buddy", *objs)

def build_memory_owl(x_off):
    """Regal owl with feathered chest + crystal forehead."""
    objs = []
    o = add_object("v3_owl_body",
                   build_uvsphere("owl_body", 0.30, scale=(1, 1, 1.4)),
                   mat_owl_body, loc=(x_off, 0, 0.50), subdiv_levels=2)
    objs.append(o.name)
    o = add_object("v3_owl_chest",
                   build_uvsphere("owl_chest", 0.20, scale=(0.7, 1, 1.1)),
                   mat_owl_chest, loc=(x_off, -0.20, 0.50), subdiv_levels=2)
    objs.append(o.name)
    o = add_object("v3_owl_head", build_sphere("owl_head", 0.26, subs=3),
                   mat_owl_body, loc=(x_off, 0, 0.95), subdiv_levels=2)
    objs.append(o.name)
    # 2 large eye discs
    for side in [-1, 1]:
        o = add_object(f"v3_owl_eye_disc_{side}",
                       build_cylinder(f"oed_{side}", 0.10, 0.04, segs=16),
                       mat_owl_eye,
                       loc=(x_off + side*0.10, -0.20, 0.95),
                       rot=(math.radians(90), 0, 0), subdiv_levels=1)
        objs.append(o.name)
        o = add_object(f"v3_owl_pupil_{side}", build_sphere(f"op_{side}", 0.04, subs=2),
                       mat_eye_dark,
                       loc=(x_off + side*0.10, -0.24, 0.95), subdiv_levels=1)
        objs.append(o.name)
    # Crystal forehead
    o = add_object("v3_owl_crystal", build_cone("oc", 0.08, 0.0, 0.16),
                   mat_owl_crystal,
                   loc=(x_off, -0.10, 1.18), subdiv_levels=1)
    objs.append(o.name)
    # Beak
    o = add_object("v3_owl_beak", build_cone("ob", 0.05, 0.0, 0.10),
                   mat_owl_chest,
                   loc=(x_off, -0.25, 0.85),
                   rot=(math.radians(90), 0, 0), subdiv_levels=1)
    objs.append(o.name)
    # Folded wings
    for side in [-1, 1]:
        o = add_object(f"v3_owl_wing_{side}",
                       build_uvsphere(f"ow_{side}", 0.15, scale=(0.4, 1.2, 1)),
                       mat_owl_body,
                       loc=(x_off + side*0.30, 0, 0.45), subdiv_levels=2)
        objs.append(o.name)
    # Talons
    for sx in [-0.10, 0.10]:
        o = add_object(f"v3_owl_talon_{sx}",
                       build_cylinder(f"ot_{sx}", 0.04, 0.10),
                       mat_owl_chest,
                       loc=(x_off + sx, 0, 0.05), subdiv_levels=1)
        objs.append(o.name)
    tag("memory_owl", *objs)

def build_cache_mouse(x_off):
    """Plump mouse with bulging cheek pouch."""
    objs = []
    o = add_object("v3_mouse_body",
                   build_uvsphere("ms_body", 0.25, scale=(1.2, 1, 1)),
                   mat_mouse_body, loc=(x_off, 0, 0.30), subdiv_levels=2)
    objs.append(o.name)
    o = add_object("v3_mouse_head", build_sphere("ms_head", 0.18, subs=3),
                   mat_mouse_body, loc=(x_off + 0.32, 0, 0.40), subdiv_levels=2)
    objs.append(o.name)
    # Cheek pouch
    o = add_object("v3_mouse_pouch", build_sphere("ms_pouch", 0.14, subs=2),
                   mat_mouse_pouch,
                   loc=(x_off + 0.36, 0.18, 0.32), subdiv_levels=1)
    objs.append(o.name)
    # Round ears
    for side in [-1, 1]:
        o = add_object(f"v3_mouse_ear_{side}",
                       build_cylinder(f"me_{side}", 0.08, 0.02, segs=16),
                       mat_mouse_body,
                       loc=(x_off + 0.30, side*0.13, 0.55), subdiv_levels=1)
        objs.append(o.name)
    o = add_object("v3_mouse_nose", build_sphere("ms_nose", 0.04, subs=2),
                   mat_mouse_nose,
                   loc=(x_off + 0.46, 0, 0.38), subdiv_levels=1)
    objs.append(o.name)
    # Eyes
    for side in [-1, 1]:
        o = add_object(f"v3_mouse_eye_{side}",
                       build_sphere(f"meye_{side}", 0.025, subs=2),
                       mat_eye_dark,
                       loc=(x_off + 0.42, side*0.08, 0.45), subdiv_levels=1)
        objs.append(o.name)
    # Long tail (4 segments)
    for i in range(4):
        o = add_object(f"v3_mouse_tail_{i}",
                       build_cylinder(f"mt_{i}", 0.02, 0.10),
                       mat_mouse_nose,
                       loc=(x_off - 0.30 - i*0.08, 0, 0.30 + i*0.03), subdiv_levels=1)
        objs.append(o.name)
    tag("cache_mouse", *objs)

def build_echo_bird(x_off):
    """Sleek bird with sound-wave tail."""
    objs = []
    o = add_object("v3_bird_body",
                   build_uvsphere("eb_body", 0.20, scale=(1.5, 0.8, 0.8)),
                   mat_bird_body, loc=(x_off, 0, 0.50), subdiv_levels=2)
    objs.append(o.name)
    o = add_object("v3_bird_head", build_sphere("eb_head", 0.15, subs=3),
                   mat_bird_body, loc=(x_off + 0.30, 0, 0.60), subdiv_levels=2)
    objs.append(o.name)
    o = add_object("v3_bird_beak", build_cone("eb_beak", 0.04, 0.0, 0.12),
                   mat_bird_beak,
                   loc=(x_off + 0.42, 0, 0.58),
                   rot=(math.radians(90), 0, math.radians(90)), subdiv_levels=1)
    objs.append(o.name)
    # Eyes
    for side in [-1, 1]:
        o = add_object(f"v3_bird_eye_{side}",
                       build_sphere(f"be_{side}", 0.025, subs=2),
                       mat_eye_dark,
                       loc=(x_off + 0.36, side*0.08, 0.62), subdiv_levels=1)
        objs.append(o.name)
    # Spread wings
    for side in [-1, 1]:
        o = add_object(f"v3_bird_wing_{side}",
                       build_uvsphere(f"bw_{side}", 0.18, scale=(0.5, 1.6, 0.1)),
                       mat_bird_wing,
                       loc=(x_off, side*0.30, 0.50), subdiv_levels=2)
        objs.append(o.name)
    # 3 sound wave tail rings
    for i in range(3):
        o = add_object(f"v3_bird_wave_{i}",
                       build_cylinder(f"bwv_{i}", 0.10 + i*0.06, 0.02, segs=20),
                       mat_bird_tail,
                       loc=(x_off - 0.30 - i*0.10, 0, 0.50),
                       rot=(0, math.radians(90), 0), subdiv_levels=1)
        objs.append(o.name)
    # Legs
    for side in [-1, 1]:
        o = add_object(f"v3_bird_leg_{side}",
                       build_cylinder(f"bl_{side}", 0.025, 0.20),
                       mat_bird_beak,
                       loc=(x_off + side*0.05, 0, 0.20), subdiv_levels=1)
        objs.append(o.name)
    tag("echo_bird", *objs)

def build_crystal_fox(x_off):
    """Ethereal fox with chest crystal + crystal-tipped tail."""
    objs = []
    o = add_object("v3_fox_body",
                   build_uvsphere("fox_body", 0.28, scale=(1.5, 0.8, 0.85)),
                   mat_fox_body, loc=(x_off, 0, 0.40), subdiv_levels=2)
    objs.append(o.name)
    o = add_object("v3_fox_chest",
                   build_uvsphere("fox_chest", 0.18, scale=(0.8, 1, 1)),
                   mat_fox_chest, loc=(x_off + 0.10, -0.16, 0.40), subdiv_levels=2)
    objs.append(o.name)
    o = add_object("v3_fox_head",
                   build_uvsphere("fox_head", 0.22, scale=(1.1, 0.9, 1)),
                   mat_fox_body, loc=(x_off + 0.42, 0, 0.55), subdiv_levels=2)
    objs.append(o.name)
    # Snout
    o = add_object("v3_fox_snout", build_cone("fs", 0.10, 0.04, 0.16),
                   mat_fox_chest,
                   loc=(x_off + 0.55, 0, 0.50),
                   rot=(math.radians(90), 0, math.radians(90)), subdiv_levels=1)
    objs.append(o.name)
    # Triangular ears
    for side in [-1, 1]:
        o = add_object(f"v3_fox_ear_{side}",
                       build_cone(f"fe_{side}", 0.08, 0.0, 0.20),
                       mat_fox_body,
                       loc=(x_off + 0.40, side*0.10, 0.78), subdiv_levels=1)
        objs.append(o.name)
    # Eyes (crystal blue glow)
    for side in [-1, 1]:
        o = add_object(f"v3_fox_eye_{side}",
                       build_sphere(f"fey_{side}", 0.04, subs=2),
                       mat_fox_crystal,
                       loc=(x_off + 0.50, side*0.08, 0.58), subdiv_levels=1)
        objs.append(o.name)
    # Chest crystal
    o = add_object("v3_fox_chest_crystal", build_cone("fcc", 0.08, 0.02, 0.18),
                   mat_fox_crystal,
                   loc=(x_off + 0.10, -0.30, 0.42), subdiv_levels=1)
    objs.append(o.name)
    # Bushy tail
    o = add_object("v3_fox_tail",
                   build_uvsphere("ft", 0.15, scale=(2, 1, 1)),
                   mat_fox_body,
                   loc=(x_off - 0.40, 0, 0.50),
                   rot=(0, math.radians(20), 0), subdiv_levels=2)
    objs.append(o.name)
    o = add_object("v3_fox_tail_crystal", build_cone("ftc", 0.08, 0.0, 0.18),
                   mat_fox_crystal,
                   loc=(x_off - 0.65, 0, 0.55), subdiv_levels=1)
    objs.append(o.name)
    # 4 legs
    for sx in [-0.18, 0.18]:
        for sy in [-0.16, 0.16]:
            o = add_object(f"v3_fox_leg_{sx}_{sy}",
                           build_cylinder(f"fl_{sx}_{sy}", 0.05, 0.30),
                           mat_fox_body,
                           loc=(x_off + sx, sy, 0.0), subdiv_levels=1)
            objs.append(o.name)
    tag("crystal_fox", *objs)

# ============================================================
# BUILD ALL 8 PETS — laid out in a row
# ============================================================

print("=== Building 8 hero pets ===")
PETS = [
    ("data_sprite", build_data_sprite),
    ("patch_dog", build_patch_dog),
    ("bit_cat", build_bit_cat),
    ("bug_buddy", build_bug_buddy),
    ("memory_owl", build_memory_owl),
    ("cache_mouse", build_cache_mouse),
    ("echo_bird", build_echo_bird),
    ("crystal_fox", build_crystal_fox),
]
for i, (name, builder) in enumerate(PETS):
    x_off = (i - 3.5) * 2.5
    builder(x_off)

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

# Per-pet portrait + hero cams
portrait_cams = {}
hero_cams = {}
for i, (name, _) in enumerate(PETS):
    x_off = (i - 3.5) * 2.5
    portrait_cams[name] = add_camera(f"Cam_Portrait_{name}",
        (x_off, -2.0, 0.6), (math.radians(85), 0, 0), 85)
    hero_cams[name] = add_camera(f"Cam_Hero_{name}",
        (x_off + 0.8, -2.5, 0.7), (math.radians(82), 0, math.radians(15)), 75)

group_cam = add_camera("Cam_Group", (0, -8, 2.5), (math.radians(78), 0, 0), 50)

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

add_area_light("Key", (-3, -5, 5), (1.0, 0.95, 0.85), 1500, 6,
              rot=(math.radians(45), math.radians(-25), 0))
add_area_light("Fill", (4, -3, 4), (0.65, 0.78, 1.0), 400, 7,
              rot=(math.radians(50), math.radians(20), 0))
add_area_light("Rim", (0, 4, 4), (1.0, 0.85, 0.65), 700, 5,
              rot=(math.radians(120), 0, 0))

world = bpy.data.worlds.new("World_Pets")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.02, 0.03, 0.06, 1.0)
bg.inputs['Strength'].default_value = 0.4

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# ============================================================
# RENDERS
# ============================================================

def hide_all_pets_except(visible_pet_name):
    for pet_name, obj_names in PET_OBJ_TAG.items():
        for n in obj_names:
            obj = bpy.data.objects.get(n)
            if obj is not None:
                obj.hide_render = (pet_name != visible_pet_name)

print("=== Rendering 8 pet hero shots ===")
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.render.film_transparent = False
for name, _ in PETS:
    hide_all_pets_except(name)
    scene.camera = hero_cams[name]
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_pet_{name}_hero.png")
    bpy.ops.render.render(write_still=True)

print("=== Rendering 8 pet portraits ===")
scene.render.resolution_x = 720
scene.render.resolution_y = 960
for name, _ in PETS:
    hide_all_pets_except(name)
    scene.camera = portrait_cams[name]
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_pet_{name}_portrait.png")
    bpy.ops.render.render(write_still=True)

print("=== Rendering group hero shot ===")
scene.render.resolution_x = 1920
scene.render.resolution_y = 720
# Show all pets
for pet_name, obj_names in PET_OBJ_TAG.items():
    for n in obj_names:
        obj = bpy.data.objects.get(n)
        if obj is not None:
            obj.hide_render = False
scene.camera = group_cam
scene.render.filepath = os.path.join(RENDER_DIR, "v3_pets_group_hero.png")
bpy.ops.render.render(write_still=True)

# ============================================================
# EXPORT GLBs
# ============================================================

print("=== Exporting 8 pet GLBs ===")
for name, _ in PETS:
    bpy.ops.object.select_all(action='DESELECT')
    for obj_name in PET_OBJ_TAG[name]:
        obj = bpy.data.objects.get(obj_name)
        if obj is not None:
            obj.hide_render = False
            obj.select_set(True)
    glb_path = os.path.join(EXPORT_DIR, f"pet_{name}_v3.glb")
    bpy.ops.export_scene.gltf(
        filepath=glb_path, export_format='GLB',
        use_selection=True, export_apply=True, export_yup=True,
    )
    print(f"Exported: {glb_path}")
    for obj_name in PET_OBJ_TAG[name]:
        obj = bpy.data.objects.get(obj_name)
        if obj is not None:
            obj.select_set(False)

print("=== V3 Epic 05 Pet Sculpts Texture Pass complete ===")
