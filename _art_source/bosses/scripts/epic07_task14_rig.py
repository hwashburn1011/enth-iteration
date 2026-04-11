"""Epic 07 task 14 — build 50-bone Compiler boss rig.

Bone budget per phase form bible:
  Base + tethers       8 (root + 4 tether anchors + 3 base segments)
  Spine                3 (lower / mid / upper)
  Neck + head          2
  Core                 1 (chest emblem heart anchor)
  P1 arms (4 × 4 seg)  16
  P2 fragmented arms   12 (3 segments × 2 BR/BL arms × 2 includes connectors)
  P3 energy arms       8 (4 arms × 2 segments — energy is shorter)
  Heart cavity strands 0 (handled by GPUParticles, not bones)
  ───────────────────────
  Total ~50 bones

Bones are unified — phase 2 uses P1 bones + P2 fragment bones, phase 3
uses P1 + P2 + P3 bones. Phase visibility hides the corresponding mesh
collections but the bones stay rigged.

Run via:
    blender.exe --background _art_source/bosses/compiler_boss_master.blend --python _art_source/bosses/scripts/epic07_task14_rig.py
"""
import bpy
from mathutils import Vector
import math

scene = bpy.context.scene

# === Cleanup any prior armature ===
for name in ("Armature_Compiler", "Compiler_Armature"):
    obj = bpy.data.objects.get(name)
    if obj is not None:
        bpy.data.objects.remove(obj, do_unlink=True)
arm_data = bpy.data.armatures.get("Compiler_Armature")
if arm_data is not None:
    bpy.data.armatures.remove(arm_data)

# === Create armature ===
arm_data = bpy.data.armatures.new("Compiler_Armature")
arm_obj = bpy.data.objects.new("Armature_Compiler", arm_data)
bpy.context.scene.collection.objects.link(arm_obj)
arm_obj.location = (0, 0, 0)
arm_obj.show_in_front = True

bpy.context.view_layer.objects.active = arm_obj
bpy.ops.object.mode_set(mode='EDIT')
eb = arm_data.edit_bones


def add_bone(name, head, tail, parent=None, connect=False):
    b = eb.new(name)
    b.head = Vector(head)
    b.tail = Vector(tail)
    if parent is not None:
        b.parent = parent
        b.use_connect = connect
    return b


# === BASE + TETHERS (8 bones) ===
root = add_bone("root", (0, 0, 0), (0, 0, 0.30))  # 1
base_lower = add_bone("base_lower", (0, 0, 0.30), (0, 0, 0.60), root)  # 2
base_mid = add_bone("base_mid", (0, 0, 0.60), (0, 0, 0.90), base_lower, True)  # 3
base_upper = add_bone("base_upper", (0, 0, 0.90), (0, 0, 1.05), base_mid, True)  # 4
# 4 tether anchors
for i, angle in enumerate([0, math.pi/2, math.pi, 3*math.pi/2]):
    head = (math.cos(angle) * 0.95, math.sin(angle) * 0.95, 0.05)
    tail = (math.cos(angle) * 1.55, math.sin(angle) * 1.55, -0.50)
    add_bone(f"tether_{i+1}", head, tail, root)  # 5,6,7,8

# === SPINE (3 bones) — 9, 10, 11 ===
spine_lower = add_bone("spine_lower", (0, 0, 1.05), (0, 0, 1.50), base_upper, True)
spine_mid = add_bone("spine_mid", (0, 0, 1.50), (0, 0, 2.00), spine_lower, True)
spine_upper = add_bone("spine_upper", (0, 0, 2.00), (0, 0, 2.65), spine_mid, True)

# === NECK + HEAD (2 bones) — 12, 13 ===
neck = add_bone("neck", (0, 0, 2.65), (0, 0, 3.40), spine_upper, True)
head = add_bone("head", (0, 0, 3.40), (0, 0, 3.95), neck, True)

# === CORE (1 bone) — 14 ===
add_bone("core", (0, -0.40, 1.95), (0, -0.85, 1.95), spine_mid)

# === P1 ARMS — 4 arms × 4 segments = 16 bones (15..30) ===
arm_anchors = [
    ("UR", ( 1.55, 0,  3.20),  1),
    ("UL", (-1.55, 0,  3.20), -1),
    ("LR", ( 1.55, 0,  2.50),  1),
    ("LL", (-1.55, 0,  2.50), -1),
]
for label, anchor, side in arm_anchors:
    parent = spine_upper
    pos = Vector(anchor)
    for seg_idx in range(4):
        next_pos = pos + Vector((side * 0.20, -0.25, -0.30))
        b = add_bone(f"arm_{label}_seg{seg_idx+1}", tuple(pos), tuple(next_pos), parent,
                     seg_idx > 0)
        parent = b
        pos = next_pos

# === P2 FRAGMENTED ARMS — 2 arms × 6 bones = 12 bones (31..42) ===
# 6 bones per arm: shoulder anchor + 3 segments + 2 fragment connectors
p2_anchors = [
    ("BR", ( 0.80, 0.60, 2.80),  1),
    ("BL", (-0.80, 0.60, 2.80), -1),
]
for label, anchor, side in p2_anchors:
    parent = spine_mid
    pos = Vector(anchor)
    # Shoulder anchor
    b = add_bone(f"p2_arm_{label}_anchor", tuple(pos), tuple(pos + Vector((0, 0.25, 0))), parent)
    parent = b
    pos = pos + Vector((0, 0.25, 0))
    # 3 main segments
    for seg_idx in range(3):
        next_pos = pos + Vector((side * 0.15, 0.30, -0.10))
        b = add_bone(f"p2_arm_{label}_seg{seg_idx+1}", tuple(pos), tuple(next_pos), parent,
                     seg_idx > 0)
        parent = b
        pos = next_pos
    # 2 fragment connectors (floating tip)
    for frag_idx in range(2):
        next_pos = pos + Vector((side * 0.10, 0.20, 0.05))
        b = add_bone(f"p2_arm_{label}_frag{frag_idx+1}", tuple(pos), tuple(next_pos), parent)
        # Don't chain — each fragment is independent so the floaty effect works
        pos = next_pos

# === P3 ENERGY ARMS — 4 arms × 2 bones = 8 bones (43..50) ===
# 2 bones per arm: pivot anchor + extending tip
p3_anchors = [
    ("UR", ( 1.20, 0,  3.40),  1.5,  0.5),
    ("UL", (-1.20, 0,  3.40), -1.5,  0.5),
    ("LR", ( 1.20, 0,  2.20),  1.8, -0.3),
    ("LL", (-1.20, 0,  2.20), -1.8, -0.3),
]
for label, anchor, dx, dz in p3_anchors:
    pivot = add_bone(f"p3_energy_{label}_pivot", anchor,
                     (anchor[0] + dx * 0.5, anchor[1] - 0.2, anchor[2] + dz * 0.5),
                     spine_upper)
    add_bone(f"p3_energy_{label}_tip",
             (anchor[0] + dx * 0.5, anchor[1] - 0.2, anchor[2] + dz * 0.5),
             (anchor[0] + dx * 1.5, anchor[1] - 0.5, anchor[2] + dz * 1.5),
             pivot, True)

bpy.ops.object.mode_set(mode='OBJECT')

bone_count = len(arm_data.bones)
print(f"Total bone count: {bone_count}")
print(f"Bones: {sorted([b.name for b in arm_data.bones])}")

# === SKIN ALL MESHES VIA ENVELOPE BINDING ===
# Each phase collection is bound to the armature with envelope skinning.
# This is the cheapest way to skin procedural blockout geometry without
# per-vertex weight painting.
def bind_collection(col_name):
    col = bpy.data.collections.get(col_name)
    if col is None:
        return
    for obj in col.objects:
        if obj.type != 'MESH':
            continue
        for mod in list(obj.modifiers):
            if mod.type == 'ARMATURE':
                obj.modifiers.remove(mod)
        world_mat = obj.matrix_world.copy()
        obj.parent = arm_obj
        obj.matrix_world = world_mat
        mod = obj.modifiers.new("Armature", 'ARMATURE')
        mod.object = arm_obj
        mod.use_bone_envelopes = True
        mod.use_vertex_groups = False

bind_collection("Compiler_Shared")
bind_collection("Compiler_P2_Overlay")
bind_collection("Compiler_P3_Overlay")

# Set generous envelopes so the procedural mesh is captured
for bone in arm_data.bones:
    bone.envelope_distance = 0.70
    bone.envelope_weight = 1.0
    bone.head_radius = 0.30
    bone.tail_radius = 0.30

# Tighter envelopes on small parts
for tight in ("core", "head", "neck"):
    b = arm_data.bones.get(tight)
    if b is not None:
        b.envelope_distance = 0.40
        b.head_radius = 0.20
        b.tail_radius = 0.20

bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
print(f"Compiler boss rig built. {bone_count} bones, 3 phase collections bound.")
