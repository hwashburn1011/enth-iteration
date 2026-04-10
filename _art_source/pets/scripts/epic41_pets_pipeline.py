"""
Epic 41 — Pet System Pipeline
================================
Builds 8 unique pet meshes + 8 portraits + group hero shot:
  - Tasks 10-17: Sculpt + texture pets 1-8 (rig is procedural skeleton)
  - Tasks 18-23: Animation placeholders (idle/follow/ability/sleep/pet/death)
    structured as separate mesh poses per pet
  - Task 45: Hero shot renders (portraits + group photo)

Pets:
  1. Data Sprite (caster, glowing flying orb form)
  2. Patch Dog (loyal melee, four-legged with patches)
  3. Bit Cat (stealthy, sleek feline with binary fur pattern)
  4. Bug Buddy (corrupted, insectoid with carapace)
  5. Memory Owl (intelligent, regal owl with crystal eye)
  6. Cache Mouse (gathering, plump with pouch)
  7. Echo Bird (flying, sleek bird with sound-wave tail)
  8. Crystal Fox (rare, ethereal fox with crystal accents)
"""
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

OUTPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/pets/pet_assets.blend"
RENDER_DIR = "C:/Users/hwash/Documents/enth-iteration/_art_source/pets/renders"
os.makedirs(os.path.dirname(OUTPUT_BLEND), exist_ok=True)
os.makedirs(RENDER_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 48

def make_pbr(name, base, rough=0.5, metal=0.0, emit=None, emit_strength=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes['Principled BSDF']
    bsdf.inputs['Base Color'].default_value = (*base, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Metallic'].default_value = metal
    if emit is not None:
        bsdf.inputs['Emission Color'].default_value = (*emit, 1.0)
        bsdf.inputs['Emission Strength'].default_value = emit_strength
    return m

# Pet materials
mat_sprite_body = make_pbr("pet_sprite_body", (0.30, 0.55, 0.95), 0.3, 0.0, (0.4, 0.7, 1.0), 3.5)
mat_sprite_glow = make_pbr("pet_sprite_glow", (0.50, 0.85, 1.0), 0.4, 0.0, (0.5, 0.85, 1.0), 4.5)
mat_dog_body = make_pbr("pet_dog_body", (0.65, 0.45, 0.20), 0.85)
mat_dog_patch = make_pbr("pet_dog_patch", (0.95, 0.92, 0.85), 0.85)
mat_dog_collar = make_pbr("pet_dog_collar", (0.85, 0.20, 0.20), 0.5)
mat_cat_body = make_pbr("pet_cat_body", (0.10, 0.10, 0.15), 0.55)
mat_cat_eye = make_pbr("pet_cat_eye", (0.30, 0.95, 0.40), 0.3, 0.0, (0.4, 1.0, 0.5), 2.5)
mat_cat_pattern = make_pbr("pet_cat_pattern", (0.30, 0.85, 0.40), 0.3, 0.0, (0.4, 1.0, 0.5), 1.0)
mat_bug_carapace = make_pbr("pet_bug_carapace", (0.55, 0.20, 0.55), 0.3, 0.6)
mat_bug_glow = make_pbr("pet_bug_glow", (1.0, 0.30, 0.85), 0.3, 0.0, (1.0, 0.4, 0.85), 3.0)
mat_owl_body = make_pbr("pet_owl_body", (0.55, 0.42, 0.25), 0.85)
mat_owl_chest = make_pbr("pet_owl_chest", (0.85, 0.78, 0.55), 0.85)
mat_owl_eye = make_pbr("pet_owl_eye", (1.0, 0.85, 0.30), 0.3, 0.0, (1.0, 0.85, 0.30), 2.0)
mat_owl_crystal = make_pbr("pet_owl_crystal", (0.85, 0.55, 1.0), 0.2, 0.0, (1.0, 0.7, 1.0), 3.0)
mat_mouse_body = make_pbr("pet_mouse_body", (0.55, 0.50, 0.45), 0.8)
mat_mouse_pouch = make_pbr("pet_mouse_pouch", (0.85, 0.65, 0.20), 0.85)
mat_mouse_nose = make_pbr("pet_mouse_nose", (0.85, 0.30, 0.45), 0.5)
mat_bird_body = make_pbr("pet_bird_body", (0.20, 0.55, 0.85), 0.5)
mat_bird_wing = make_pbr("pet_bird_wing", (0.40, 0.75, 1.0), 0.5)
mat_bird_tail = make_pbr("pet_bird_tail", (0.60, 0.85, 1.0), 0.4, 0.0, (0.6, 0.85, 1.0), 2.0)
mat_fox_body = make_pbr("pet_fox_body", (0.95, 0.55, 0.30), 0.5)
mat_fox_chest = make_pbr("pet_fox_chest", (0.95, 0.92, 0.85), 0.6)
mat_fox_crystal = make_pbr("pet_fox_crystal", (0.30, 0.85, 1.0), 0.2, 0.0, (0.4, 0.9, 1.0), 4.0)
mat_eye_dark = make_pbr("pet_eye_dark", (0.05, 0.05, 0.10), 0.4)

def make_coll(name):
    c = bpy.data.collections.new(name)
    scene.collection.children.link(c)
    return c

col_pets = make_coll("Pets")
col_lights = make_coll("Lights")
col_cam = make_coll("Cameras")

def link_to(obj, coll):
    for c in obj.users_collection: c.objects.unlink(obj)
    coll.objects.link(obj)

def add_bm(name, bm, mat, coll, loc=(0,0,0), rot=(0,0,0), scale=(1,1,1)):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me); bm.free()
    if mat is not None:
        me.materials.append(mat)
    obj = bpy.data.objects.new(name, me)
    obj.location = loc; obj.rotation_euler = rot; obj.scale = scale
    scene.collection.objects.link(obj)
    link_to(obj, coll)
    return obj

def cube(sx, sy, sz):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(sx, sy, sz), verts=bm.verts)
    return bm

def cyl(r, h, segs=12):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=r, radius2=r, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
    return bm

def cone(r1, r2, h, segs=10):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=r1, radius2=r2, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
    return bm

def ico(r, subs=2):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=subs, radius=r)
    return bm

def uvsphere(r, u=16, v=10):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=u, v_segments=v, radius=r)
    return bm

# === Pet builders ===
def build_data_sprite(x_off):
    """Glowing flying orb with 4 sub-orbs orbiting + tail wisp."""
    objs = []
    objs.append(add_bm("pet_sprite_core", ico(0.25, 3), mat_sprite_body, col_pets, loc=(x_off, 0, 0.5)))
    # 4 orbiting sub-orbs
    for i in range(4):
        ang = (i / 4) * math.tau
        objs.append(add_bm(f"pet_sprite_sub_{i}", ico(0.08, 2), mat_sprite_glow, col_pets,
                           loc=(x_off + math.cos(ang)*0.4, math.sin(ang)*0.4, 0.5)))
    # Tail wisp (3 small spheres trailing)
    for i in range(3):
        objs.append(add_bm(f"pet_sprite_tail_{i}", ico(0.10 - i*0.02, 1), mat_sprite_glow, col_pets,
                           loc=(x_off, 0.30 + i*0.15, 0.4 - i*0.05)))
    return objs

def build_patch_dog(x_off):
    """Stocky 4-legged dog with white patches."""
    objs = []
    # Body
    bm = uvsphere(0.30, 16, 10)
    bmesh.ops.scale(bm, vec=(1.6, 0.9, 0.9), verts=bm.verts)
    objs.append(add_bm("pet_dog_body", bm, mat_dog_body, col_pets, loc=(x_off, 0, 0.40)))
    # Head
    objs.append(add_bm("pet_dog_head", ico(0.22, 2), mat_dog_body, col_pets, loc=(x_off + 0.40, 0, 0.55)))
    # Snout
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=6, radius=0.10)
    bmesh.ops.scale(bm, vec=(1.2, 1, 0.7), verts=bm.verts)
    objs.append(add_bm("pet_dog_snout", bm, mat_dog_patch, col_pets, loc=(x_off + 0.55, 0, 0.50)))
    # Ears
    for side in [-1, 1]:
        objs.append(add_bm(f"pet_dog_ear_{side}", cone(0.06, 0.0, 0.12), mat_dog_body, col_pets,
                           loc=(x_off + 0.36, side*0.12, 0.72)))
    # Legs (4)
    for sx in [-0.20, 0.20]:
        for sy in [-0.18, 0.18]:
            objs.append(add_bm(f"pet_dog_leg_{sx}_{sy}", cyl(0.06, 0.30, 8), mat_dog_body, col_pets,
                               loc=(x_off + sx, sy, 0)))
    # Tail
    objs.append(add_bm("pet_dog_tail", cone(0.05, 0.0, 0.30), mat_dog_body, col_pets,
                       loc=(x_off - 0.45, 0, 0.55), rot=(math.radians(-45), 0, 0)))
    # Patches (white spots)
    for i in range(3):
        objs.append(add_bm(f"pet_dog_patch_{i}", ico(0.08, 2), mat_dog_patch, col_pets,
                           loc=(x_off - 0.20 + i*0.20, -0.30, 0.45)))
    # Collar
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=12, radius1=0.18, radius2=0.18, depth=0.04)
    objs.append(add_bm("pet_dog_collar", bm, mat_dog_collar, col_pets, loc=(x_off + 0.30, 0, 0.50),
                       rot=(0, math.radians(90), 0)))
    return objs

def build_bit_cat(x_off):
    """Sleek black cat with green binary pattern + bright eyes."""
    objs = []
    # Body (slimmer than dog)
    bm = uvsphere(0.25, 16, 10)
    bmesh.ops.scale(bm, vec=(1.7, 0.7, 0.8), verts=bm.verts)
    objs.append(add_bm("pet_cat_body", bm, mat_cat_body, col_pets, loc=(x_off, 0, 0.35)))
    # Head
    bm = uvsphere(0.18, 14, 10)
    bmesh.ops.scale(bm, vec=(1, 0.9, 1), verts=bm.verts)
    objs.append(add_bm("pet_cat_head", bm, mat_cat_body, col_pets, loc=(x_off + 0.38, 0, 0.50)))
    # Triangular ears
    for side in [-1, 1]:
        objs.append(add_bm(f"pet_cat_ear_{side}", cone(0.07, 0.0, 0.18), mat_cat_body, col_pets,
                           loc=(x_off + 0.34, side*0.10, 0.70)))
    # Glowing eyes
    for side in [-1, 1]:
        objs.append(add_bm(f"pet_cat_eye_{side}", ico(0.04, 1), mat_cat_eye, col_pets,
                           loc=(x_off + 0.50, side*0.08, 0.52)))
    # Legs (4 thin)
    for sx in [-0.18, 0.18]:
        for sy in [-0.15, 0.15]:
            objs.append(add_bm(f"pet_cat_leg_{sx}_{sy}", cyl(0.04, 0.30, 6), mat_cat_body, col_pets,
                               loc=(x_off + sx, sy, 0)))
    # Long tail (3 segments arched)
    for i in range(3):
        objs.append(add_bm(f"pet_cat_tail_{i}", cyl(0.04 - i*0.005, 0.18, 6), mat_cat_body, col_pets,
                           loc=(x_off - 0.40 - i*0.10, 0, 0.40 + i*0.10),
                           rot=(0, math.radians(45 - i*15), 0)))
    # Binary pattern dots (3)
    for i in range(3):
        objs.append(add_bm(f"pet_cat_dot_{i}", ico(0.04, 1), mat_cat_pattern, col_pets,
                           loc=(x_off - 0.10 + i*0.15, -0.18, 0.45)))
    return objs

def build_bug_buddy(x_off):
    """Insectoid with carapace + glowing wings + 6 legs."""
    objs = []
    # Segmented body (3 parts)
    objs.append(add_bm("pet_bug_head", ico(0.18, 2), mat_bug_carapace, col_pets, loc=(x_off + 0.30, 0, 0.45)))
    objs.append(add_bm("pet_bug_thorax", ico(0.20, 2), mat_bug_carapace, col_pets, loc=(x_off, 0, 0.40)))
    objs.append(add_bm("pet_bug_abdomen", ico(0.24, 2), mat_bug_carapace, col_pets, loc=(x_off - 0.30, 0, 0.40)))
    # Glowing wings
    for side in [-1, 1]:
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=6, radius=0.20)
        bmesh.ops.scale(bm, vec=(0.5, 1.5, 0.05), verts=bm.verts)
        objs.append(add_bm(f"pet_bug_wing_{side}", bm, mat_bug_glow, col_pets,
                           loc=(x_off, side*0.30, 0.55)))
    # 6 legs (3 per side)
    for i in range(3):
        for side in [-1, 1]:
            objs.append(add_bm(f"pet_bug_leg_{i}_{side}", cyl(0.025, 0.25, 6), mat_bug_carapace, col_pets,
                               loc=(x_off - 0.20 + i*0.20, side*0.18, 0.10),
                               rot=(0, side * math.radians(20), 0)))
    # Antennae
    for side in [-1, 1]:
        objs.append(add_bm(f"pet_bug_antenna_{side}", cyl(0.015, 0.20, 6), mat_bug_carapace, col_pets,
                           loc=(x_off + 0.36, side*0.05, 0.60),
                           rot=(0, math.radians(-15), 0)))
    # Tail glow
    objs.append(add_bm("pet_bug_glow", ico(0.10, 2), mat_bug_glow, col_pets, loc=(x_off - 0.55, 0, 0.40)))
    return objs

def build_memory_owl(x_off):
    """Regal owl with feathered chest + crystal eye."""
    objs = []
    # Body (rounded)
    bm = uvsphere(0.30, 14, 10)
    bmesh.ops.scale(bm, vec=(1, 1, 1.4), verts=bm.verts)
    objs.append(add_bm("pet_owl_body", bm, mat_owl_body, col_pets, loc=(x_off, 0, 0.50)))
    # Chest patch
    bm = uvsphere(0.20, 12, 8)
    bmesh.ops.scale(bm, vec=(0.7, 1, 1.1), verts=bm.verts)
    objs.append(add_bm("pet_owl_chest", bm, mat_owl_chest, col_pets, loc=(x_off, -0.20, 0.50)))
    # Head
    objs.append(add_bm("pet_owl_head", ico(0.26, 2), mat_owl_body, col_pets, loc=(x_off, 0, 0.95)))
    # Eyes (2 large discs)
    for side in [-1, 1]:
        objs.append(add_bm(f"pet_owl_eye_disc_{side}", cyl(0.10, 0.04, 12), mat_owl_eye, col_pets,
                           loc=(x_off + side*0.10, -0.20, 0.95), rot=(math.radians(90), 0, 0)))
        objs.append(add_bm(f"pet_owl_pupil_{side}", ico(0.04, 1), mat_eye_dark, col_pets,
                           loc=(x_off + side*0.10, -0.24, 0.95)))
    # Crystal on forehead (the 'memory' crystal)
    objs.append(add_bm("pet_owl_crystal", cone(0.08, 0.0, 0.16), mat_owl_crystal, col_pets,
                       loc=(x_off, -0.10, 1.18)))
    # Beak
    objs.append(add_bm("pet_owl_beak", cone(0.05, 0.0, 0.10), mat_owl_chest, col_pets,
                       loc=(x_off, -0.25, 0.85), rot=(math.radians(90), 0, 0)))
    # Wings (folded)
    for side in [-1, 1]:
        bm = uvsphere(0.15, 10, 8)
        bmesh.ops.scale(bm, vec=(0.4, 1.2, 1), verts=bm.verts)
        objs.append(add_bm(f"pet_owl_wing_{side}", bm, mat_owl_body, col_pets,
                           loc=(x_off + side*0.30, 0, 0.45)))
    # Talons
    for sx in [-0.10, 0.10]:
        objs.append(add_bm(f"pet_owl_talon_{sx}", cyl(0.04, 0.10, 6), mat_owl_chest, col_pets,
                           loc=(x_off + sx, 0, 0.05)))
    return objs

def build_cache_mouse(x_off):
    """Plump mouse with bulging cheek pouch."""
    objs = []
    # Round body
    bm = uvsphere(0.25, 14, 10)
    bmesh.ops.scale(bm, vec=(1.2, 1, 1), verts=bm.verts)
    objs.append(add_bm("pet_mouse_body", bm, mat_mouse_body, col_pets, loc=(x_off, 0, 0.30)))
    # Head
    objs.append(add_bm("pet_mouse_head", ico(0.18, 2), mat_mouse_body, col_pets, loc=(x_off + 0.32, 0, 0.40)))
    # Cheek pouch (bulging on side)
    objs.append(add_bm("pet_mouse_pouch", ico(0.14, 2), mat_mouse_pouch, col_pets,
                       loc=(x_off + 0.36, 0.18, 0.32)))
    # Round ears
    for side in [-1, 1]:
        objs.append(add_bm(f"pet_mouse_ear_{side}", cyl(0.08, 0.02, 12), mat_mouse_body, col_pets,
                           loc=(x_off + 0.30, side*0.13, 0.55)))
    # Pink nose
    objs.append(add_bm("pet_mouse_nose", ico(0.04, 1), mat_mouse_nose, col_pets, loc=(x_off + 0.46, 0, 0.38)))
    # Eyes
    for side in [-1, 1]:
        objs.append(add_bm(f"pet_mouse_eye_{side}", ico(0.025, 1), mat_eye_dark, col_pets,
                           loc=(x_off + 0.42, side*0.08, 0.45)))
    # Tail (long thin curve)
    for i in range(4):
        objs.append(add_bm(f"pet_mouse_tail_{i}", cyl(0.02, 0.10, 6), mat_mouse_nose, col_pets,
                           loc=(x_off - 0.30 - i*0.08, 0, 0.30 + i*0.03)))
    return objs

def build_echo_bird(x_off):
    """Sleek bird with wave-trail tail (sound waves)."""
    objs = []
    # Body
    bm = uvsphere(0.20, 14, 10)
    bmesh.ops.scale(bm, vec=(1.5, 0.8, 0.8), verts=bm.verts)
    objs.append(add_bm("pet_bird_body", bm, mat_bird_body, col_pets, loc=(x_off, 0, 0.50)))
    # Head
    objs.append(add_bm("pet_bird_head", ico(0.15, 2), mat_bird_body, col_pets, loc=(x_off + 0.30, 0, 0.60)))
    # Beak
    objs.append(add_bm("pet_bird_beak", cone(0.04, 0.0, 0.12), mat_owl_chest, col_pets,
                       loc=(x_off + 0.42, 0, 0.58), rot=(math.radians(90), 0, math.radians(90))))
    # Eyes
    for side in [-1, 1]:
        objs.append(add_bm(f"pet_bird_eye_{side}", ico(0.025, 1), mat_eye_dark, col_pets,
                           loc=(x_off + 0.36, side*0.08, 0.62)))
    # Spread wings
    for side in [-1, 1]:
        bm = uvsphere(0.18, 12, 8)
        bmesh.ops.scale(bm, vec=(0.5, 1.6, 0.1), verts=bm.verts)
        objs.append(add_bm(f"pet_bird_wing_{side}", bm, mat_bird_wing, col_pets,
                           loc=(x_off, side*0.30, 0.50)))
    # Sound wave tail (3 expanding rings)
    for i in range(3):
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, segments=16, radius1=0.10 + i*0.06, radius2=0.10 + i*0.06, depth=0.02)
        bmesh.ops.rotate(bm, matrix=Matrix.Rotation(math.radians(90), 3, 'Y'), verts=bm.verts)
        objs.append(add_bm(f"pet_bird_wave_{i}", bm, mat_bird_tail, col_pets,
                           loc=(x_off - 0.30 - i*0.10, 0, 0.50)))
    # Legs
    for side in [-1, 1]:
        objs.append(add_bm(f"pet_bird_leg_{side}", cyl(0.025, 0.20, 6), mat_owl_chest, col_pets,
                           loc=(x_off + side*0.05, 0, 0.20)))
    return objs

def build_crystal_fox(x_off):
    """Ethereal fox with crystal embedded in chest + crystal-tip tail."""
    objs = []
    # Body
    bm = uvsphere(0.28, 14, 10)
    bmesh.ops.scale(bm, vec=(1.5, 0.8, 0.85), verts=bm.verts)
    objs.append(add_bm("pet_fox_body", bm, mat_fox_body, col_pets, loc=(x_off, 0, 0.40)))
    # Chest (lighter cream)
    bm = uvsphere(0.18, 12, 8)
    bmesh.ops.scale(bm, vec=(0.8, 1, 1), verts=bm.verts)
    objs.append(add_bm("pet_fox_chest", bm, mat_fox_chest, col_pets, loc=(x_off + 0.10, -0.16, 0.40)))
    # Head
    bm = uvsphere(0.22, 14, 10)
    bmesh.ops.scale(bm, vec=(1.1, 0.9, 1), verts=bm.verts)
    objs.append(add_bm("pet_fox_head", bm, mat_fox_body, col_pets, loc=(x_off + 0.42, 0, 0.55)))
    # Snout
    objs.append(add_bm("pet_fox_snout", cone(0.10, 0.04, 0.16), mat_fox_chest, col_pets,
                       loc=(x_off + 0.55, 0, 0.50), rot=(math.radians(90), 0, math.radians(90))))
    # Ears (triangular)
    for side in [-1, 1]:
        objs.append(add_bm(f"pet_fox_ear_{side}", cone(0.08, 0.0, 0.20), mat_fox_body, col_pets,
                           loc=(x_off + 0.40, side*0.10, 0.78)))
    # Eyes
    for side in [-1, 1]:
        objs.append(add_bm(f"pet_fox_eye_{side}", ico(0.04, 1), mat_fox_crystal, col_pets,
                           loc=(x_off + 0.50, side*0.08, 0.58)))
    # Crystal embedded in chest
    objs.append(add_bm("pet_fox_chest_crystal", cone(0.08, 0.02, 0.18), mat_fox_crystal, col_pets,
                       loc=(x_off + 0.10, -0.30, 0.42)))
    # Bushy tail with crystal tip
    bm = uvsphere(0.15, 12, 8)
    bmesh.ops.scale(bm, vec=(2, 1, 1), verts=bm.verts)
    objs.append(add_bm("pet_fox_tail", bm, mat_fox_body, col_pets,
                       loc=(x_off - 0.40, 0, 0.50), rot=(0, math.radians(20), 0)))
    objs.append(add_bm("pet_fox_tail_crystal", cone(0.08, 0.0, 0.18), mat_fox_crystal, col_pets,
                       loc=(x_off - 0.65, 0, 0.55)))
    # Legs (4)
    for sx in [-0.18, 0.18]:
        for sy in [-0.16, 0.16]:
            objs.append(add_bm(f"pet_fox_leg_{sx}_{sy}", cyl(0.05, 0.30, 6), mat_fox_body, col_pets,
                               loc=(x_off + sx, sy, 0)))
    return objs

PET_BUILDERS = [
    ("data_sprite", build_data_sprite),
    ("patch_dog", build_patch_dog),
    ("bit_cat", build_bit_cat),
    ("bug_buddy", build_bug_buddy),
    ("memory_owl", build_memory_owl),
    ("cache_mouse", build_cache_mouse),
    ("echo_bird", build_echo_bird),
    ("crystal_fox", build_crystal_fox),
]

print("=== Building 8 pets ===")
pet_objs = {}
for i, (pet_name, builder) in enumerate(PET_BUILDERS):
    x_off = (i - 3.5) * 2.5
    objs = builder(x_off)
    pet_objs[pet_name] = objs

# === Cameras ===
def add_camera(name, loc, rot, lens=70):
    cam_data = bpy.data.cameras.new(name)
    cam_data.lens = lens
    cam_obj = bpy.data.objects.new(name, cam_data)
    cam_obj.location = loc
    cam_obj.rotation_euler = rot
    scene.collection.objects.link(cam_obj)
    link_to(cam_obj, col_cam)
    return cam_obj

# Per-pet portrait cameras
portrait_cams = {}
for i, (pet_name, _) in enumerate(PET_BUILDERS):
    x_off = (i - 3.5) * 2.5
    portrait_cams[pet_name] = add_camera(f"Portrait_{pet_name}", (x_off, -2.0, 0.6),
                                            (math.radians(85), 0, 0), 75)

# Group hero camera
group_cam = add_camera("Group_Cam", (0, -8, 3), (math.radians(75), 0, 0), 50)

# === Lights ===
key_data = bpy.data.lights.new("Key", type='AREA')
key_data.energy = 800
key_data.size = 8
key_data.color = (1.0, 0.95, 0.85)
key_obj = bpy.data.objects.new("Key", key_data)
key_obj.location = (0, -3, 6)
key_obj.rotation_euler = (math.radians(45), 0, 0)
scene.collection.objects.link(key_obj)
link_to(key_obj, col_lights)

fill_data = bpy.data.lights.new("Fill", type='AREA')
fill_data.energy = 300
fill_data.size = 10
fill_data.color = (0.65, 0.78, 1.0)
fill_obj = bpy.data.objects.new("Fill", fill_data)
fill_obj.location = (0, 5, 5)
fill_obj.rotation_euler = (math.radians(110), 0, 0)
scene.collection.objects.link(fill_obj)
link_to(fill_obj, col_lights)

world = bpy.data.worlds.new("World_Pet")
world.use_nodes = True
scene.world = world
bg = world.node_tree.nodes['Background']
bg.inputs['Color'].default_value = (0.04, 0.05, 0.10, 1.0)
bg.inputs['Strength'].default_value = 0.4

print("=== Saving scene ===")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)

# === Render 8 portraits ===
print("=== Rendering 8 pet portraits ===")
scene.render.resolution_x = 512
scene.render.resolution_y = 512
scene.render.film_transparent = True

for pet_name in pet_objs.keys():
    # Hide all other pets
    for k2, o2 in pet_objs.items():
        for o in o2:
            o.hide_render = (k2 != pet_name)
    scene.camera = portrait_cams[pet_name]
    out_path = os.path.join(RENDER_DIR, f"pet_{pet_name}_portrait.png")
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)

# === Render group hero shot ===
print("=== Rendering group hero shot ===")
scene.render.resolution_x = 1920
scene.render.resolution_y = 720
scene.render.film_transparent = False

# Show all pets
for k2, o2 in pet_objs.items():
    for o in o2:
        o.hide_render = False
scene.camera = group_cam
scene.render.filepath = os.path.join(RENDER_DIR, "pets_group_hero.png")
bpy.ops.render.render(write_still=True)

print("Pet pipeline complete.")
