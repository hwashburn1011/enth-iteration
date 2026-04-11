"""
Expansion V3 — Epic 21 — Original Compiler Boss Hero Pass
==========================================================
Iteration 1 boss — The Compiler — pushed to trailer-grade.

Anatomy:
  - Massive central obsidian core sphere with cracked seam glow
    (Voronoi DISTANCE_TO_EDGE crack mask drives orange emission)
  - 6 orbital crystal shards rotating around the core
  - 4 floating sub-arms (jagged shard tendrils) reaching outward
  - 2 large back wings made of shattered code fragments
  - Crown of 8 vertical rune-spires above the core
  - Outer aura ring (large emissive torus halo)
  - Floor sigil array beneath (3 nested rune circles)
  - 12 floating code-rune cubes orbiting at varying heights
  - 3-phase indicator: amber/cyan/magenta torus rings around base
  - Heavy 6500W cyan key + amber back rim + cool ground fill

Outputs:
  - 1 hero render @ 1920x1080
  - 1 portrait close-up @ 1280x1280
  - 1 GLB export
"""
import bpy, bmesh, math, os, random
from mathutils import Vector

random.seed(21)

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/v3_compiler_boss.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/renders"
EXPORT_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/enemies/exports"
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

scene.world = bpy.data.worlds.new("v3_cb_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.02, 0.02, 0.04, 1)
bg.inputs["Strength"].default_value = 0.4

# ============================================================
# CORE SHADER — cracked obsidian with emissive code-rune seams
# ============================================================
def make_compiler_core():
    m = bpy.data.materials.new("v3cb_core")
    m.use_nodes = True
    nt = m.node_tree
    nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (1300, 0)
    bsdf.inputs["Roughness"].default_value = 0.20
    bsdf.inputs["Metallic"].default_value = 0.40
    bsdf.inputs["Coat Weight"].default_value = 0.5
    bsdf.inputs["Coat Roughness"].default_value = 0.05
    links.new(bsdf.outputs[0], out.inputs[0])

    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-1200, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-1000, 0)
    mp.inputs["Scale"].default_value = (3, 3, 3)
    links.new(tc.outputs["Generated"], mp.inputs["Vector"])

    # Obsidian noise
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-700, 200)
    n.inputs["Scale"].default_value = 8.0
    n.inputs["Detail"].default_value = 8.0
    links.new(mp.outputs["Vector"], n.inputs["Vector"])
    obs_ramp = nodes.new("ShaderNodeValToRGB"); obs_ramp.location = (-450, 200)
    obs_ramp.color_ramp.elements[0].position = 0.30
    obs_ramp.color_ramp.elements[0].color = (0.04, 0.03, 0.06, 1)
    obs_ramp.color_ramp.elements[1].position = 0.70
    obs_ramp.color_ramp.elements[1].color = (0.10, 0.08, 0.14, 1)
    links.new(n.outputs["Fac"], obs_ramp.inputs["Fac"])

    # Voronoi crack mask (the rune seams)
    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-700, -100)
    v.feature = 'DISTANCE_TO_EDGE'
    v.inputs["Scale"].default_value = 4.0
    links.new(mp.outputs["Vector"], v.inputs["Vector"])
    crack_ramp = nodes.new("ShaderNodeValToRGB"); crack_ramp.location = (-450, -100)
    crack_ramp.color_ramp.elements[0].position = 0.0
    crack_ramp.color_ramp.elements[0].color = (1, 1, 1, 1)
    crack_ramp.color_ramp.elements[1].position = 0.06
    crack_ramp.color_ramp.elements[1].color = (0, 0, 0, 1)
    links.new(v.outputs["Distance"], crack_ramp.inputs["Fac"])

    # Mix obsidian with crack mask -> dark cracks
    mix = nodes.new("ShaderNodeMix"); mix.data_type='RGBA'; mix.location = (-200, 100)
    links.new(crack_ramp.outputs["Color"], mix.inputs["Factor"])
    links.new(obs_ramp.outputs["Color"], mix.inputs[6])
    mix.inputs[7].default_value = (0.01, 0.01, 0.02, 1)
    links.new(mix.outputs[2], bsdf.inputs["Base Color"])

    # Crack emission glow (cyan-to-orange gradient via second voronoi for color variation)
    v2 = nodes.new("ShaderNodeTexVoronoi"); v2.location = (-700, -300)
    v2.feature = 'F1'
    v2.inputs["Scale"].default_value = 2.0
    links.new(mp.outputs["Vector"], v2.inputs["Vector"])
    color_ramp = nodes.new("ShaderNodeValToRGB"); color_ramp.location = (-450, -300)
    color_ramp.color_ramp.elements[0].position = 0.20
    color_ramp.color_ramp.elements[0].color = (0.30, 0.85, 1.0, 1)  # cyan
    color_ramp.color_ramp.elements[1].position = 0.70
    color_ramp.color_ramp.elements[1].color = (1.0, 0.45, 0.10, 1)  # orange
    links.new(v2.outputs["Distance"], color_ramp.inputs["Fac"])

    glow = nodes.new("ShaderNodeMix"); glow.data_type='RGBA'; glow.location = (100, -200)
    links.new(crack_ramp.outputs["Color"], glow.inputs["Factor"])
    glow.inputs[6].default_value = (0, 0, 0, 1)
    links.new(color_ramp.outputs["Color"], glow.inputs[7])
    links.new(glow.outputs[2], bsdf.inputs["Emission Color"])
    bsdf.inputs["Emission Strength"].default_value = 12.0

    # Bump from obsidian noise
    bp = nodes.new("ShaderNodeBump"); bp.location = (-200, -500)
    bp.inputs["Strength"].default_value = 0.30
    links.new(n.outputs["Fac"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_pbr_simple(name, color, rough=0.6, metal=0.0, em=None, em_str=0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (*color, 1)
    bs.inputs["Roughness"].default_value = rough
    bs.inputs["Metallic"].default_value = metal
    if em:
        bs.inputs["Emission Color"].default_value = (*em, 1)
        bs.inputs["Emission Strength"].default_value = em_str
    return m

# ============================================================
# MATERIALS
# ============================================================
mat_core         = make_compiler_core()
mat_obsidian     = make_pbr_simple("v3cb_obsidian", (0.06, 0.05, 0.10), 0.30, 0.50,
                                    em=(0.30, 0.45, 1.0), em_str=0.6)
mat_shard_cyan   = make_pbr_simple("v3cb_shard_c", (0.30, 0.85, 1.0), 0.10, 0.0,
                                    em=(0.40, 0.95, 1.0), em_str=10.0)
mat_shard_amber  = make_pbr_simple("v3cb_shard_a", (1.0, 0.55, 0.20), 0.10, 0.0,
                                    em=(1.0, 0.65, 0.20), em_str=10.0)
mat_shard_magenta = make_pbr_simple("v3cb_shard_m", (1.0, 0.30, 0.85), 0.10, 0.0,
                                     em=(1.0, 0.40, 0.85), em_str=10.0)
mat_rune_glow    = make_pbr_simple("v3cb_rune", (1.0, 0.78, 0.30), 0.05, 0.0,
                                    em=(1.0, 0.78, 0.30), em_str=14.0)
mat_aura_ring    = make_pbr_simple("v3cb_aura", (0.30, 0.85, 1.0), 0.05, 0.0,
                                    em=(0.30, 0.85, 1.0), em_str=8.0)
mat_floor        = make_pbr_simple("v3cb_floor", (0.05, 0.05, 0.07), 0.30, 0.10)
mat_floor_sigil  = make_pbr_simple("v3cb_floor_sigil", (1.0, 0.55, 0.20), 0.05, 0.0,
                                    em=(1.0, 0.55, 0.20), em_str=12.0)

# ============================================================
# UTIL
# ============================================================
def add_subsurf_bevel(obj, levels=2, bevel=0.025):
    s = obj.modifiers.new("Subsurf", 'SUBSURF'); s.levels = levels; s.render_levels = levels+1
    b = obj.modifiers.new("Bevel", 'BEVEL'); b.width = bevel; b.segments = 3; b.profile = 0.7
    for poly in obj.data.polygons: poly.use_smooth = True

def sph(name, loc, r, mat, parent, segs=24):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segs, ring_count=segs//2, radius=r, location=loc)
    o = bpy.context.object; o.name = name
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=2, bevel=0.005)
    o.parent = parent
    return o

def cyl(name, loc, r, depth, mat, parent, verts=16, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=r, depth=depth, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    return o

def cone(name, loc, r1, r2, depth, mat, parent, verts=12, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    return o

def box(name, loc, scale, mat, parent, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.object; o.name = name; o.scale = scale; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o)
    o.parent = parent
    return o

def tor(name, loc, R, r, mat, parent, ms=48, mn=14, rot=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_segments=ms, minor_segments=mn, major_radius=R, minor_radius=r, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.005)
    o.parent = parent
    return o

# ============================================================
# BUILD COMPILER BOSS
# ============================================================
parent = bpy.data.objects.new("v3_compiler_boss", None); scene.collection.objects.link(parent)

# === Floor plinth ===
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, -0.05))
fl = bpy.context.object; fl.name = "cb_floor"; fl.scale = (12, 12, 0.10)
fl.data.materials.append(mat_floor); add_subsurf_bevel(fl, levels=1, bevel=0.005)

# === Floor sigil array (3 nested glowing rune circles) ===
tor("cb_sigil_outer", (0, 0, 0.06), 4.5, 0.06, mat_floor_sigil, parent, ms=80, mn=12)
tor("cb_sigil_mid",   (0, 0, 0.06), 3.5, 0.05, mat_floor_sigil, parent, ms=72, mn=12)
tor("cb_sigil_inner", (0, 0, 0.06), 2.4, 0.04, mat_floor_sigil, parent, ms=64, mn=12)
# 8 radial sigil glyphs at outer ring
for i in range(8):
    ang = i * math.pi/4
    gx = math.cos(ang) * 4.0
    gy = math.sin(ang) * 4.0
    box(f"cb_glyph_{i}", (gx, gy, 0.07), (0.30, 0.04, 0.04), mat_floor_sigil, parent, rot=(0, 0, ang))
    box(f"cb_glyph2_{i}", (gx, gy, 0.07), (0.04, 0.30, 0.04), mat_floor_sigil, parent, rot=(0, 0, ang))

# === Central core sphere (the Compiler) ===
core = sph("cb_core", (0, 0, 3.0), 1.4, mat_core, parent, segs=48)

# === Crown of 8 vertical rune-spires above core ===
for i in range(8):
    ang = i * math.pi/4
    sx = math.cos(ang) * 0.85
    sy = math.sin(ang) * 0.85
    sz = 4.4
    cone(f"cb_spire_{i}", (sx, sy, sz), 0.10, 0.02, 1.4, mat_obsidian, parent, verts=8)
    # Glow tip
    sph(f"cb_spire_t_{i}", (sx, sy, sz + 0.75), 0.08, mat_shard_cyan, parent, segs=12)

# === 6 orbital crystal shards rotating around core ===
for i in range(6):
    ang = i * (math.pi*2/6)
    x = math.cos(ang) * 2.4
    y = math.sin(ang) * 2.4
    z = 3.0 + math.sin(i*1.5) * 0.6
    color_choice = [mat_shard_cyan, mat_shard_amber, mat_shard_magenta][i % 3]
    cone(f"cb_shard_{i}", (x, y, z), 0.20, 0.0, 0.8, color_choice, parent, verts=8,
         rot=(ang, ang*0.5, ang*0.3))
    # Glow ring around shard
    tor(f"cb_shard_r_{i}", (x, y, z), 0.30, 0.025, color_choice, parent, ms=24, mn=8,
        rot=(ang*0.5, ang, 0))

# === 4 floating sub-arms (jagged shard tendrils) ===
def sub_arm(name, ang, parent):
    """Arm reaching outward from core in 4 segments getting smaller."""
    base_x = math.cos(ang) * 1.4
    base_y = math.sin(ang) * 1.4
    base_z = 3.0
    for i in range(4):
        d = 0.5 + i * 0.45
        x = math.cos(ang) * (1.4 + d)
        y = math.sin(ang) * (1.4 + d)
        z = base_z + math.sin(i * 0.8 + ang) * 0.30
        r = 0.18 - i * 0.025
        sph(f"{name}_seg_{i}", (x, y, z), r, mat_obsidian, parent, segs=14)
        # Joint glow at each segment
        if i > 0:
            sph(f"{name}_glow_{i}", (x, y, z), r * 0.4, mat_shard_cyan, parent, segs=10)
    # End spike at the tip
    tip_d = 0.5 + 4 * 0.45
    tx = math.cos(ang) * (1.4 + tip_d)
    ty = math.sin(ang) * (1.4 + tip_d)
    cone(f"{name}_tip", (tx, ty, base_z), 0.10, 0.0, 0.40, mat_shard_amber, parent, verts=8,
         rot=(0, math.pi/2 - ang, ang))

for i, a in enumerate([0.4, 1.97, 3.54, 5.11]):
    sub_arm(f"cb_arm_{i}", a, parent)

# === 2 large back wings (shattered code fragments) ===
def back_wing(name, side, parent):
    """side = -1 for left, +1 for right."""
    sx = side * 0.6
    sz = 3.5
    # 6 cube fragments fanning back at upward angles
    for i in range(6):
        ang_offset = i * 0.25
        x = sx + side * (0.5 + i * 0.30)
        y = -0.5 - i * 0.30
        z = sz + i * 0.25
        scale = 0.35 - i * 0.04
        b = box(f"{name}_f_{i}", (x, y, z), (scale, scale*0.4, scale), mat_obsidian, parent,
                 rot=(ang_offset * side, ang_offset * 0.5, ang_offset * side))
    # Glow trim along inner edge
    for i in range(4):
        x = sx + side * (0.4 + i * 0.50)
        y = -0.5 - i * 0.30
        z = sz + i * 0.25
        sph(f"{name}_g_{i}", (x, y, z), 0.07, mat_shard_cyan, parent, segs=10)

back_wing("cb_wing_l", -1, parent)
back_wing("cb_wing_r",  1, parent)

# === Outer aura ring (massive emissive halo) ===
tor("cb_aura_h", (0, 0, 3.0), 3.2, 0.10, mat_aura_ring, parent, ms=96, mn=14)
tor("cb_aura_v1", (0, 0, 3.0), 3.2, 0.08, mat_aura_ring, parent, ms=80, mn=12, rot=(math.pi/2, 0, 0))
tor("cb_aura_v2", (0, 0, 3.0), 3.2, 0.08, mat_aura_ring, parent, ms=80, mn=12, rot=(0, math.pi/2, 0))

# === 12 floating code-rune cubes orbiting at varying heights ===
for i in range(12):
    ang = i * (math.pi*2/12)
    r = 4.0 + (i % 3) * 0.4
    x = math.cos(ang) * r
    y = math.sin(ang) * r
    z = 1.5 + (i % 4) * 0.6
    color = [mat_shard_cyan, mat_shard_amber, mat_shard_magenta][i % 3]
    box(f"cb_rune_{i}", (x, y, z), (0.18, 0.18, 0.18), color, parent,
        rot=(ang, ang * 0.5, ang * 0.3))

# === 3-phase indicator: amber/cyan/magenta torus rings around base ===
tor("cb_phase_1", (0, 0, 0.40), 1.8, 0.05, mat_shard_amber, parent, ms=48, mn=10)
tor("cb_phase_2", (0, 0, 0.60), 1.6, 0.05, mat_shard_cyan, parent, ms=48, mn=10)
tor("cb_phase_3", (0, 0, 0.80), 1.4, 0.05, mat_shard_magenta, parent, ms=48, mn=10)

# === Strong central core point light ===
bpy.ops.object.light_add(type='POINT', location=(0, 0, 3.0))
cp = bpy.context.object
cp.data.energy = 3500
cp.data.color = (1.0, 0.55, 0.20)

# === Cyan key from front-above ===
bpy.ops.object.light_add(type='SPOT', location=(8, -10, 12))
key = bpy.context.object
key.data.energy = 6500
key.data.color = (0.40, 0.85, 1.0)
key.data.spot_size = math.radians(80)
key.data.spot_blend = 0.4
direction = Vector((0, 0, 3.0)) - key.location
key.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

# === Amber back rim ===
bpy.ops.object.light_add(type='AREA', location=(-6, 10, 8))
rim = bpy.context.object
rim.data.energy = 1500
rim.data.color = (1.0, 0.55, 0.20)
rim.data.size = 8

# === Cool ground fill ===
bpy.ops.object.light_add(type='AREA', location=(0, 0, 0.5))
gf = bpy.context.object
gf.data.energy = 600
gf.data.color = (0.45, 0.65, 1.0)
gf.data.size = 12
gf.rotation_euler = (math.pi, 0, 0)

# ============================================================
# CAMERAS
# ============================================================
def add_cam(name, loc, target, lens=35, dof_dist=10):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object; c.name = name
    c.data.lens = lens
    c.data.dof.use_dof = True
    c.data.dof.aperture_fstop = 4.0
    c.data.dof.focus_distance = dof_dist
    direction = Vector(target) - c.location
    c.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return c

cam_main     = add_cam("cam_compiler", Vector((10, -12, 5.5)), Vector((0, 0, 3.0)), lens=35, dof_dist=14)
cam_portrait = add_cam("cam_portrait", Vector((4, -6, 3.5)),    Vector((0, 0, 3.0)), lens=85, dof_dist=7)

CAMERAS = [
    ("compiler", cam_main,     (1920, 1080)),
    ("portrait", cam_portrait, (1280, 1280)),
]

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render
for name, cam, (w, h) in CAMERAS:
    scene.camera = cam
    scene.render.resolution_x = w
    scene.render.resolution_y = h
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_compiler_boss_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

# Export GLB
bpy.ops.object.select_all(action='DESELECT')
parent.select_set(True)
for child in parent.children_recursive:
    child.select_set(True)
out_path = os.path.join(EXPORT_DIR, "v3_compiler_boss_v3.glb")
bpy.ops.export_scene.gltf(
    filepath=out_path, use_selection=True,
    export_format='GLB', export_apply=True
)
print(f"Exported: {out_path}")

print("=== V3 Epic 21 Original Compiler Boss complete ===")
