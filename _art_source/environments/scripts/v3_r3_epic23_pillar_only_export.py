"""
Re-export the pillar from v3_r3_pillar_diorama.blend WITHOUT the floor,
so the BossArena can instance 4 copies without stacking 4 floors.
"""
import bpy, os

INPUT_BLEND = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/v3_r3_pillar_diorama.blend"
EXPORT_DIR  = "C:/Users/hwash/Documents/enth-iteration/_art_source/environments/exports"
os.makedirs(EXPORT_DIR, exist_ok=True)

bpy.ops.wm.open_mainfile(filepath=INPUT_BLEND)

# Find pillar object
pillar = None
for obj in bpy.data.objects:
    if obj.name.startswith("boss_pillar_hp"):
        pillar = obj
        break

if pillar is None:
    raise RuntimeError("boss_pillar_hp not found in blend")

# Select just the pillar
bpy.ops.object.select_all(action='DESELECT')
pillar.select_set(True)
bpy.context.view_layer.objects.active = pillar

out_path = os.path.join(EXPORT_DIR, "boss_pillar_r3_v3.glb")
bpy.ops.export_scene.gltf(
    filepath=out_path,
    use_selection=True,
    export_format='GLB',
    export_apply=False,
    export_image_format='AUTO',
)
print(f"Exported pillar-only: {out_path}")
print(f"Pillar face count: {len(pillar.data.polygons)}")
