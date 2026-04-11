"""
Expansion V3 — Epic 28 — VFX Material Library Showcase
======================================================
Visual showcase scene demonstrating 8 VFX shader patterns. The
runtime equivalents live as Godot 4.4 .gdshader files in
assets/shaders/vfx/. This script renders representative Blender
approximations of each effect for the design doc / Steam page.

VFX showcased:
  1. DISSOLVE       — noise threshold dissolve with edge glow
  2. ENERGY BEAM    — animated UV scroll core+edge beam
  3. HIT FLASH      — white flash overlay on a base mesh
  4. STATUS POISON  — green ripple SSS overlay
  5. STATUS BURN    — orange flicker emission
  6. STATUS FREEZE  — cyan still frost wrap
  7. AURA HALO      — pulsing radial billboard
  8. PORTAL SWIRL   — spiral arms swirling on disc
  + SHOCKWAVE RING  — expanding impact ring
  + TRAIL GRADIENT  — head→tail color trail

Each VFX has a host mesh (sphere/cube/disc) showing the effect.

Outputs:
  - 1 grid hero render @ 1920x1080
  - 8 individual close-ups @ 1024x1024
"""
import bpy, bmesh, math, os
from mathutils import Vector

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/v3_vfx_library.blend"
RENDER_DIR   = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/renders"
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 96
scene.cycles.use_denoising = True
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.view_settings.look = 'AgX - High Contrast'

scene.world = bpy.data.worlds.new("v3_vfx_world")
scene.world.use_nodes = True
bg = scene.world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.02, 0.02, 0.04, 1)
bg.inputs["Strength"].default_value = 0.4

# ============================================================
# SHADER HELPERS — Blender approximations of each Godot VFX
# ============================================================
def make_dissolve():
    """Approximate dissolve via voronoi mask + edge glow."""
    m = bpy.data.materials.new("v3vfx_dissolve")
    m.use_nodes = True
    nt = m.node_tree; nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1200, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (900, 0)
    bsdf.inputs["Base Color"].default_value = (0.78, 0.62, 0.40, 1)
    bsdf.inputs["Roughness"].default_value = 0.6
    bsdf.inputs["Emission Color"].default_value = (1.0, 0.55, 0.10, 1)
    bsdf.inputs["Emission Strength"].default_value = 8.0
    links.new(bsdf.outputs[0], out.inputs[0])
    # Use noise for emission edge band — drives alpha-like glow
    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-700, 0)
    n = nodes.new("ShaderNodeTexNoise"); n.location = (-500, 0)
    n.inputs["Scale"].default_value = 8.0
    n.inputs["Detail"].default_value = 6.0
    links.new(tc.outputs["Generated"], n.inputs["Vector"])
    ramp = nodes.new("ShaderNodeValToRGB"); ramp.location = (-250, 0)
    ramp.color_ramp.elements[0].position = 0.45
    ramp.color_ramp.elements[0].color = (0, 0, 0, 1)
    ramp.color_ramp.elements[1].position = 0.55
    ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
    links.new(n.outputs["Fac"], ramp.inputs["Fac"])
    em_mix = nodes.new("ShaderNodeMix"); em_mix.data_type='RGBA'; em_mix.location = (50, 200)
    em_mix.inputs[6].default_value = (0, 0, 0, 1)
    em_mix.inputs[7].default_value = (1.0, 0.55, 0.10, 1)
    links.new(ramp.outputs["Color"], em_mix.inputs["Factor"])
    links.new(em_mix.outputs[2], bsdf.inputs["Emission Color"])
    return m

def make_energy_beam():
    m = bpy.data.materials.new("v3vfx_beam")
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (0.30, 0.85, 1.0, 1)
    bs.inputs["Roughness"].default_value = 0.05
    bs.inputs["Emission Color"].default_value = (0.45, 0.95, 1.0, 1)
    bs.inputs["Emission Strength"].default_value = 14.0
    return m

def make_hit_flash():
    m = bpy.data.materials.new("v3vfx_hit_flash")
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (0.85, 0.20, 0.20, 1)
    bs.inputs["Roughness"].default_value = 0.4
    bs.inputs["Emission Color"].default_value = (1.0, 0.95, 0.85, 1)
    bs.inputs["Emission Strength"].default_value = 6.0
    return m

def make_status_poison():
    m = bpy.data.materials.new("v3vfx_poison")
    m.use_nodes = True
    nt = m.node_tree; nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1200, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (900, 0)
    bsdf.inputs["Base Color"].default_value = (0.20, 0.45, 0.18, 1)
    bsdf.inputs["Roughness"].default_value = 0.55
    bsdf.inputs["Subsurface Weight"].default_value = 0.4
    bsdf.inputs["Subsurface Radius"].default_value = (0.4, 1.4, 0.4)
    bsdf.inputs["Subsurface Scale"].default_value = 0.4
    bsdf.inputs["Emission Color"].default_value = (0.30, 0.95, 0.30, 1)
    bsdf.inputs["Emission Strength"].default_value = 4.0
    links.new(bsdf.outputs[0], out.inputs[0])
    fr = nodes.new("ShaderNodeFresnel"); fr.location = (-200, 0)
    fr.inputs["IOR"].default_value = 1.4
    em_mult = nodes.new("ShaderNodeMath"); em_mult.location = (200, 100)
    em_mult.operation = 'MULTIPLY'
    em_mult.inputs[1].default_value = 6.0
    links.new(fr.outputs["Fac"], em_mult.inputs[0])
    em_color = nodes.new("ShaderNodeMix"); em_color.data_type='RGBA'; em_color.location = (450, 100)
    em_color.inputs[6].default_value = (0, 0, 0, 1)
    em_color.inputs[7].default_value = (0.30, 0.95, 0.30, 1)
    links.new(em_mult.outputs[0], em_color.inputs["Factor"])
    links.new(em_color.outputs[2], bsdf.inputs["Emission Color"])
    return m

def make_status_burn():
    m = bpy.data.materials.new("v3vfx_burn")
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (0.20, 0.10, 0.06, 1)
    bs.inputs["Roughness"].default_value = 0.85
    bs.inputs["Emission Color"].default_value = (1.0, 0.45, 0.10, 1)
    bs.inputs["Emission Strength"].default_value = 8.0
    return m

def make_status_freeze():
    m = bpy.data.materials.new("v3vfx_freeze")
    m.use_nodes = True
    nt = m.node_tree; nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1200, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (900, 0)
    bsdf.inputs["Base Color"].default_value = (0.55, 0.85, 1.0, 1)
    bsdf.inputs["Roughness"].default_value = 0.05
    bsdf.inputs["Coat Weight"].default_value = 0.95
    bsdf.inputs["Coat Roughness"].default_value = 0.05
    bsdf.inputs["Emission Color"].default_value = (0.65, 0.95, 1.0, 1)
    bsdf.inputs["Emission Strength"].default_value = 3.0
    links.new(bsdf.outputs[0], out.inputs[0])
    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-500, -200)
    v = nodes.new("ShaderNodeTexVoronoi"); v.location = (-300, -200)
    v.feature = 'F1'; v.inputs["Scale"].default_value = 14.0
    links.new(tc.outputs["Generated"], v.inputs["Vector"])
    bp = nodes.new("ShaderNodeBump"); bp.location = (0, -200)
    bp.inputs["Strength"].default_value = 0.40
    links.new(v.outputs["Distance"], bp.inputs["Height"])
    links.new(bp.outputs["Normal"], bsdf.inputs["Normal"])
    return m

def make_aura_halo():
    m = bpy.data.materials.new("v3vfx_aura")
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (1.0, 0.85, 0.40, 1)
    bs.inputs["Roughness"].default_value = 0.05
    bs.inputs["Emission Color"].default_value = (1.0, 0.65, 0.20, 1)
    bs.inputs["Emission Strength"].default_value = 12.0
    return m

def make_portal_swirl():
    m = bpy.data.materials.new("v3vfx_portal")
    m.use_nodes = True
    nt = m.node_tree; nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1200, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (900, 0)
    bsdf.inputs["Roughness"].default_value = 0.10
    bsdf.inputs["Emission Strength"].default_value = 14.0
    links.new(bsdf.outputs[0], out.inputs[0])
    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-700, 0)
    mp = nodes.new("ShaderNodeMapping"); mp.location = (-500, 0)
    mp.inputs["Scale"].default_value = (3, 3, 3)
    links.new(tc.outputs["Object"], mp.inputs["Vector"])
    wave = nodes.new("ShaderNodeTexWave"); wave.location = (-250, 0)
    wave.wave_type = 'RINGS'
    wave.inputs["Scale"].default_value = 6.0
    wave.inputs["Distortion"].default_value = 4.0
    wave.inputs["Detail"].default_value = 2.0
    links.new(mp.outputs["Vector"], wave.inputs["Vector"])
    ramp = nodes.new("ShaderNodeValToRGB"); ramp.location = (0, 0)
    ramp.color_ramp.elements[0].position = 0.30
    ramp.color_ramp.elements[0].color = (0.55, 0.20, 0.85, 1)
    ramp.color_ramp.elements[1].position = 0.70
    ramp.color_ramp.elements[1].color = (0.30, 0.85, 1.0, 1)
    links.new(wave.outputs["Color"], ramp.inputs["Fac"])
    links.new(ramp.outputs["Color"], bsdf.inputs["Base Color"])
    links.new(ramp.outputs["Color"], bsdf.inputs["Emission Color"])
    return m

def make_shockwave_ring():
    m = bpy.data.materials.new("v3vfx_shockwave")
    m.use_nodes = True
    bs = m.node_tree.nodes["Principled BSDF"]
    bs.inputs["Base Color"].default_value = (1.0, 0.85, 0.45, 1)
    bs.inputs["Roughness"].default_value = 0.05
    bs.inputs["Emission Color"].default_value = (1.0, 0.85, 0.45, 1)
    bs.inputs["Emission Strength"].default_value = 16.0
    return m

def make_trail():
    m = bpy.data.materials.new("v3vfx_trail")
    m.use_nodes = True
    nt = m.node_tree; nodes = nt.nodes; links = nt.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (1200, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (900, 0)
    bsdf.inputs["Roughness"].default_value = 0.10
    bsdf.inputs["Emission Strength"].default_value = 8.0
    links.new(bsdf.outputs[0], out.inputs[0])
    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-500, 0)
    sep = nodes.new("ShaderNodeSeparateXYZ"); sep.location = (-300, 0)
    links.new(tc.outputs["Generated"], sep.inputs["Vector"])
    ramp = nodes.new("ShaderNodeValToRGB"); ramp.location = (-100, 0)
    ramp.color_ramp.elements[0].position = 0.0
    ramp.color_ramp.elements[0].color = (0.85, 0.20, 0.10, 1)
    ramp.color_ramp.elements[1].position = 1.0
    ramp.color_ramp.elements[1].color = (1.0, 0.95, 0.45, 1)
    links.new(sep.outputs["X"], ramp.inputs["Fac"])
    links.new(ramp.outputs["Color"], bsdf.inputs["Base Color"])
    links.new(ramp.outputs["Color"], bsdf.inputs["Emission Color"])
    return m

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

def cone(name, loc, r1, r2, depth, mat, parent, verts=14, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.012)
    o.parent = parent
    return o

def disc(name, loc, r, mat, parent, verts=32, rot=(0,0,0)):
    bpy.ops.mesh.primitive_circle_add(vertices=verts, radius=r, fill_type='NGON', location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.002)
    o.parent = parent
    return o

def tor(name, loc, R, r, mat, parent, ms=48, mn=14, rot=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_segments=ms, minor_segments=mn, major_radius=R, minor_radius=r, location=loc)
    o = bpy.context.object; o.name = name; o.rotation_euler = rot
    o.data.materials.append(mat); add_subsurf_bevel(o, levels=1, bevel=0.005)
    o.parent = parent
    return o

# ============================================================
# MATERIALS
# ============================================================
mats = {
    "dissolve": make_dissolve(),
    "beam":     make_energy_beam(),
    "hit":      make_hit_flash(),
    "poison":   make_status_poison(),
    "burn":     make_status_burn(),
    "freeze":   make_status_freeze(),
    "aura":     make_aura_halo(),
    "portal":   make_portal_swirl(),
    "shockwave": make_shockwave_ring(),
    "trail":    make_trail(),
}

# Floor
mat_floor = bpy.data.materials.new("v3vfx_floor")
mat_floor.use_nodes = True
fb = mat_floor.node_tree.nodes["Principled BSDF"]
fb.inputs["Base Color"].default_value = (0.06, 0.06, 0.08, 1)
fb.inputs["Roughness"].default_value = 0.30
fb.inputs["Metallic"].default_value = 0.10

# ============================================================
# SCENE LAYOUT — 10 demo cells in 5x2 grid
# ============================================================
parent = bpy.data.objects.new("v3_vfx_library", None); scene.collection.objects.link(parent)

bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, -0.05))
fl = bpy.context.object; fl.name = "vfx_floor"; fl.scale = (16, 8, 0.10)
fl.data.materials.append(mat_floor); add_subsurf_bevel(fl, levels=1, bevel=0.005)

# Each cell: a host mesh demonstrating the effect
DEMOS = []

def cell_dissolve(o):
    p = make_parent("vfx_dissolve", o); p.parent = parent
    s = sph("ds_body", (0, 0, 0.45), 0.40, mats["dissolve"], p)
    return p

def cell_beam(o):
    p = make_parent("vfx_beam", o); p.parent = parent
    # Beam tube
    cyl("beam", (0, 0, 0.45), 0.10, 1.20, mats["beam"], p, verts=16, rot=(0, math.pi/2, 0))
    cone("beam_t", (0.65, 0, 0.45), 0.16, 0.0, 0.20, mats["beam"], p, verts=12, rot=(0, math.pi/2, 0))
    cone("beam_b", (-0.65, 0, 0.45), 0.16, 0.0, 0.20, mats["beam"], p, verts=12, rot=(0, -math.pi/2, 0))
    return p

def cell_hit_flash(o):
    p = make_parent("vfx_hit", o); p.parent = parent
    sph("body", (0, 0, 0.40), 0.35, mats["hit"], p)
    return p

def cell_poison(o):
    p = make_parent("vfx_poison", o); p.parent = parent
    body = sph("body", (0, 0, 0.45), 0.35, mats["poison"], p)
    body.scale = (1.0, 0.85, 1.2)
    return p

def cell_burn(o):
    p = make_parent("vfx_burn", o); p.parent = parent
    body = sph("body", (0, 0, 0.45), 0.35, mats["burn"], p)
    # 3 flame puffs above
    sph("flame1", (0, 0, 0.85), 0.10, mats["burn"], p, segs=14)
    sph("flame2", (-0.07, 0, 0.95), 0.07, mats["burn"], p, segs=12)
    sph("flame3", (0.07, 0, 1.00), 0.06, mats["burn"], p, segs=12)
    return p

def cell_freeze(o):
    p = make_parent("vfx_freeze", o); p.parent = parent
    body = sph("body", (0, 0, 0.45), 0.35, mats["freeze"], p)
    # Ice spikes
    for i in range(6):
        ang = i * (math.pi*2/6)
        x = math.cos(ang) * 0.32
        y = math.sin(ang) * 0.32
        cone(f"sp_{i}", (x, y, 0.55), 0.04, 0.0, 0.18, mats["freeze"], p, verts=6,
             rot=(math.cos(ang)*1.5, math.sin(ang)*1.5, ang))
    return p

def cell_aura(o):
    p = make_parent("vfx_aura", o); p.parent = parent
    # Center sphere (the entity being aura'd)
    sph("body", (0, 0, 0.40), 0.18, mats["dissolve"], p)
    # Aura halo torus rings
    tor("h1", (0, 0, 0.40), 0.45, 0.05, mats["aura"], p, ms=64, mn=14)
    tor("h2", (0, 0, 0.40), 0.40, 0.04, mats["aura"], p, ms=64, mn=14, rot=(math.pi/4, 0, 0))
    return p

def cell_portal(o):
    p = make_parent("vfx_portal", o); p.parent = parent
    # Portal disc (front-facing)
    bpy.ops.mesh.primitive_circle_add(vertices=64, radius=0.50, fill_type='NGON', location=(o.x, o.y, 0.50))
    d = bpy.context.object; d.name = "portal_disc"
    d.rotation_euler = (math.pi/2, 0, 0)
    d.data.materials.append(mats["portal"])
    add_subsurf_bevel(d, levels=1, bevel=0.002)
    d.parent = p
    # Portal frame ring
    tor("frame", (0, 0, 0.50), 0.55, 0.03, mats["aura"], p, ms=48, mn=12, rot=(math.pi/2, 0, 0))
    return p

def cell_shockwave(o):
    p = make_parent("vfx_shockwave", o); p.parent = parent
    # Expanding ring on ground
    tor("ring1", (0, 0, 0.05), 0.30, 0.02, mats["shockwave"], p, ms=64, mn=10)
    tor("ring2", (0, 0, 0.05), 0.45, 0.015, mats["shockwave"], p, ms=64, mn=10)
    # Source impact sphere at center
    sph("impact", (0, 0, 0.10), 0.10, mats["shockwave"], p, segs=14)
    return p

def cell_trail(o):
    p = make_parent("vfx_trail", o); p.parent = parent
    # Trail "ribbon" — flat plane sliced into segments
    for i in range(8):
        x = -0.50 + i * 0.14
        y = 0
        z = 0.40 + math.sin(i*0.5) * 0.08
        h = 0.06 - i * 0.005
        bpy.ops.mesh.primitive_cube_add(size=1, location=(x, y, z))
        b = bpy.context.object; b.name = f"trail_seg_{i}"
        b.scale = (0.13, 0.04, h)
        b.data.materials.append(mats["trail"]); add_subsurf_bevel(b, levels=1, bevel=0.005)
        b.parent = p
    # Projectile head
    sph("proj", (0.55, 0, 0.40), 0.08, mats["trail"], p, segs=14)
    return p

DEMO_BUILDERS = [
    ("dissolve",  cell_dissolve),
    ("beam",      cell_beam),
    ("hit_flash", cell_hit_flash),
    ("poison",    cell_poison),
    ("burn",      cell_burn),
    ("freeze",    cell_freeze),
    ("aura",      cell_aura),
    ("portal",    cell_portal),
    ("shockwave", cell_shockwave),
    ("trail",     cell_trail),
]

COL_SP = 2.6
ROW_SP = 3.0
ALL_DEMOS = []
for idx, (name, builder) in enumerate(DEMO_BUILDERS):
    col = idx % 5
    row = idx // 5
    x = -5.2 + col * COL_SP
    y = -1.5 + row * ROW_SP
    obj = builder(Vector((x, y, 0)))
    ALL_DEMOS.append((name, obj, Vector((x, y, 0))))

# ============================================================
# LIGHTING
# ============================================================
bpy.ops.object.light_add(type='AREA', location=(8, -10, 12))
key = bpy.context.object
key.data.energy = 1500; key.data.color = (1.0, 0.92, 0.82); key.data.size = 12

bpy.ops.object.light_add(type='AREA', location=(-8, 8, 10))
fill = bpy.context.object
fill.data.energy = 600; fill.data.color = (0.55, 0.65, 0.95); fill.data.size = 12

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

cam_grid = add_cam("cam_grid", Vector((0, -10, 9)), Vector((0, 0, 0.5)), lens=32, dof_dist=14)
DEMO_CAMS = []
for name, obj, origin in ALL_DEMOS:
    cam = add_cam(f"cam_{name}", Vector((origin.x, origin.y - 2, 1.2)),
                   Vector((origin.x, origin.y, 0.5)), lens=85, dof_dist=2)
    DEMO_CAMS.append((name, cam))

# Save
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# Render grid
scene.camera = cam_grid
scene.render.resolution_x = 1920; scene.render.resolution_y = 1080
scene.render.filepath = os.path.join(RENDER_DIR, "v3_vfx_library_grid.png")
bpy.ops.render.render(write_still=True)
print(f"Rendered: {scene.render.filepath}")

# Render individual VFX close-ups
scene.render.resolution_x = 1024; scene.render.resolution_y = 1024
for name, cam in DEMO_CAMS:
    scene.camera = cam
    scene.render.filepath = os.path.join(RENDER_DIR, f"v3_vfx_{name}.png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {scene.render.filepath}")

print("=== V3 Epic 28 VFX Library complete ===")
