"""
Epic 25 — Town Hub Expansion Blender Pipeline
==============================================
Builds all 14 hub expansion areas in one Blender background pass:
1. Underground Lounge (bar, stools, tables, stage, hanging lanterns)
2. Tower Top observation deck (already exists in epic22; add deeper interior)
3. Tower spiral staircase
4. Tower observation deck props (telescopes, railings)
5. Sage's tower study room (desk, bookshelves, candles, scrolls)
6. Sage's library (tall shelves, ladder, reading table)
7. Training arena hub (training dummies, target rings, weapon racks)
8. Farm plot area (plowed rows, scarecrow, fence, tool shed)
9. Fishing dock (planks, posts, rod rest, fish basket)
10. Cooking station (counter, stove, hanging pots, spice shelf)
11. Crafting workshop (forge, anvil, workbench, tool wall)
12. Pet hutch area (hutch + 4 pet beds + food trough)
13. Memorial gallery (9 plaques, candles, bench)
14. Trophy display hall (12 mount points, pedestals, banners)
15. Wardrobe room (mirror, 8 mannequins, chest, dye vat)
16. Hub of mysteries room (5 books, hidden door, treasure chest)
"""
import bpy, bmesh, math, random
from mathutils import Vector, Matrix

random.seed(2525)
OUTPUT = "C:/Users/hwash/Documents/enth-iteration/_art_source/world/town_hub_expansion.blend"

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'

def make_pbr(name, base, rough=0.7, metal=0.0, emit=None, emit_strength=0.0):
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

# Materials (shared palette)
mat_wood_dark = make_pbr("hub_wood_dark", (0.20, 0.12, 0.06), 0.85)
mat_wood_warm = make_pbr("hub_wood_warm", (0.40, 0.22, 0.10), 0.8)
mat_stone_floor = make_pbr("hub_stone", (0.32, 0.30, 0.27), 0.85)
mat_stone_dark = make_pbr("hub_stone_dark", (0.18, 0.18, 0.20), 0.9)
mat_iron = make_pbr("hub_iron", (0.30, 0.30, 0.32), 0.4, 0.85)
mat_brass = make_pbr("hub_brass", (0.55, 0.42, 0.18), 0.3, 0.95)
mat_steel = make_pbr("hub_steel", (0.55, 0.55, 0.60), 0.25, 0.9)
mat_paper = make_pbr("hub_paper", (0.85, 0.78, 0.65), 0.95)
mat_book_red = make_pbr("hub_book_red", (0.42, 0.10, 0.10), 0.8)
mat_book_blue = make_pbr("hub_book_blue", (0.10, 0.18, 0.42), 0.8)
mat_book_green = make_pbr("hub_book_green", (0.10, 0.32, 0.16), 0.8)
mat_lantern = make_pbr("hub_lantern", (0.20, 0.18, 0.08), 0.6, 0.5, (1.0, 0.7, 0.3), 5.0)
mat_candle = make_pbr("hub_candle", (1.0, 0.95, 0.85), 0.7, 0.0, (1.0, 0.85, 0.5), 4.0)
mat_glass = make_pbr("hub_glass", (0.85, 0.92, 1.0), 0.05, 0.0)
mat_water = make_pbr("hub_water", (0.10, 0.25, 0.40), 0.15, 0.0, (0.2, 0.4, 0.6), 0.4)
mat_dirt = make_pbr("hub_dirt", (0.28, 0.20, 0.13), 0.9)
mat_grass = make_pbr("hub_grass", (0.18, 0.32, 0.12), 0.85)
mat_velvet = make_pbr("hub_velvet", (0.35, 0.08, 0.18), 0.85)
mat_gold = make_pbr("hub_gold", (0.85, 0.65, 0.20), 0.2, 1.0)
mat_dye_red = make_pbr("hub_dye_red", (0.6, 0.1, 0.1), 0.4, 0.0, (0.8, 0.15, 0.15), 0.6)
mat_marble = make_pbr("hub_marble", (0.85, 0.83, 0.80), 0.3)

def make_coll(name):
    c = bpy.data.collections.new(name)
    bpy.context.scene.collection.children.link(c)
    return c

cols = {n: make_coll(n) for n in [
    "Lounge", "TowerStairs", "TowerDeck", "SageStudy", "SageLibrary",
    "TrainingArena", "FarmPlot", "FishingDock", "CookingStation",
    "CraftingWorkshop", "PetHutch", "MemorialGallery", "TrophyHall",
    "Wardrobe", "MysteriesRoom"
]}

def link_to(obj, coll):
    for c in obj.users_collection: c.objects.unlink(obj)
    coll.objects.link(obj)

def add_bm(name, bm, mat, coll, loc=(0,0,0), rot=(0,0,0), scale=(1,1,1)):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me); bm.free()
    me.materials.append(mat)
    obj = bpy.data.objects.new(name, me)
    obj.location = loc; obj.rotation_euler = rot; obj.scale = scale
    bpy.context.scene.collection.objects.link(obj)
    link_to(obj, coll)
    return obj

def cube(sx, sy, sz):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(sx, sy, sz), verts=bm.verts)
    return bm

def cyl(r, h, segs=8):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, segments=segs, radius1=r, radius2=r, depth=h)
    bmesh.ops.translate(bm, vec=(0,0,h/2), verts=bm.verts)
    return bm

def ico(r, subs=2):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=subs, radius=r)
    return bm

# ==================== 1. Underground Lounge ====================
print("=== Lounge ===")
LX, LY = -50, 0
# Floor
add_bm("Lounge_Floor", cube(6, 6, 0.1), mat_wood_warm, cols["Lounge"], loc=(LX, LY, 0))
# Walls (4)
for i, (px, py, sx, sy) in enumerate([(0,-6,6,0.2),(0,6,6,0.2),(-6,0,0.2,6),(6,0,0.2,6)]):
    add_bm(f"Lounge_Wall_{i}", cube(sx, sy, 2), mat_stone_dark, cols["Lounge"],
           loc=(LX+px, LY+py, 2))
# Bar counter L-shape
add_bm("Lounge_Bar1", cube(4, 0.4, 1.0), mat_wood_dark, cols["Lounge"], loc=(LX-2, LY+3, 1))
add_bm("Lounge_Bar2", cube(0.4, 2.5, 1.0), mat_wood_dark, cols["Lounge"], loc=(LX+1.6, LY+1.5, 1))
# Bar shelf (bottles)
for i in range(6):
    add_bm(f"Lounge_Bottle_{i}", cyl(0.08, 0.4), mat_glass, cols["Lounge"],
           loc=(LX-3 + i*0.5, LY+5.5, 2.3))
# Stools (4)
for i in range(4):
    add_bm(f"Lounge_Stool_{i}", cyl(0.25, 0.9), mat_wood_dark, cols["Lounge"],
           loc=(LX-3 + i*1.2, LY+1.8, 0.45))
# Tables (3) with chairs
for ti, (tx, ty) in enumerate([(-3,-3),(0,-3),(3,-3)]):
    add_bm(f"Lounge_Table_{ti}", cyl(0.7, 0.05, 12), mat_wood_warm, cols["Lounge"],
           loc=(LX+tx, LY+ty, 1.0))
    add_bm(f"Lounge_TableLeg_{ti}", cyl(0.1, 1.0), mat_wood_dark, cols["Lounge"],
           loc=(LX+tx, LY+ty, 0.5))
    for j in range(3):
        ang = j * 2.09
        add_bm(f"Lounge_Chair_{ti}_{j}", cube(0.4, 0.4, 0.1), mat_wood_dark, cols["Lounge"],
               loc=(LX+tx+math.cos(ang)*1.2, LY+ty+math.sin(ang)*1.2, 0.5))
# Stage
add_bm("Lounge_Stage", cube(2.5, 1.5, 0.3), mat_wood_dark, cols["Lounge"], loc=(LX+4, LY-4, 0.25))
# Hanging lanterns (4)
for i in range(4):
    add_bm(f"Lounge_Lantern_{i}", cube(0.3, 0.3, 0.4), mat_lantern, cols["Lounge"],
           loc=(LX-3+i*2, LY, 3.2))

# ==================== 2-4. Tower Stairs + Deck ====================
print("=== Tower Stairs/Deck ===")
TX, TY = -30, 0
# Spiral staircase (12 steps)
for i in range(12):
    ang = i * math.radians(30)
    px = math.cos(ang) * 1.5
    py = math.sin(ang) * 1.5
    pz = i * 0.4
    add_bm(f"TowerStair_{i}", cube(0.8, 0.6, 0.15), mat_stone_floor, cols["TowerStairs"],
           loc=(TX+px, TY+py, pz), rot=(0,0,ang))
# Central column
add_bm("Tower_Column", cyl(0.4, 5.0), mat_stone_dark, cols["TowerStairs"], loc=(TX, TY, 0))
# Observation deck
add_bm("Tower_DeckFloor", cyl(3.5, 0.3, 16), mat_stone_floor, cols["TowerDeck"], loc=(TX, TY, 5))
# Railing posts
for i in range(8):
    ang = i * 0.785
    add_bm(f"Tower_RailPost_{i}", cyl(0.08, 1.0), mat_iron, cols["TowerDeck"],
           loc=(TX+math.cos(ang)*3.3, TY+math.sin(ang)*3.3, 5.7))
# Railing top ring (segments)
for i in range(8):
    ang = i * 0.785 + 0.39
    add_bm(f"Tower_RailRing_{i}", cube(1.3, 0.05, 0.05), mat_iron, cols["TowerDeck"],
           loc=(TX+math.cos(ang)*3.3, TY+math.sin(ang)*3.3, 6.2),
           rot=(0,0,ang+1.57))
# 2 telescopes
for i, (tx, ty) in enumerate([(2.0, 1.5), (-1.5, 2.0)]):
    add_bm(f"Tower_Tripod_{i}", cyl(0.06, 1.0), mat_brass, cols["TowerDeck"],
           loc=(TX+tx, TY+ty, 5.6))
    add_bm(f"Tower_Scope_{i}", cyl(0.15, 0.8), mat_brass, cols["TowerDeck"],
           loc=(TX+tx, TY+ty, 6.4), rot=(math.radians(60), 0, 0))
# Wind whip pole
add_bm("Tower_Spire", cyl(0.05, 3.0), mat_iron, cols["TowerDeck"], loc=(TX, TY, 6))

# ==================== 5. Sage's Study Room ====================
print("=== Sage Study ===")
SX, SY = -15, -15
# Floor and walls (small room)
add_bm("Study_Floor", cube(3, 3, 0.1), mat_wood_warm, cols["SageStudy"], loc=(SX, SY, 0))
for i, (px, py, sx, sy) in enumerate([(0,-3,3,0.15),(0,3,3,0.15),(-3,0,0.15,3),(3,0,0.15,3)]):
    add_bm(f"Study_Wall_{i}", cube(sx, sy, 1.5), mat_wood_dark, cols["SageStudy"],
           loc=(SX+px, SY+py, 1.5))
# Desk
add_bm("Study_Desk", cube(2, 0.8, 0.1), mat_wood_warm, cols["SageStudy"], loc=(SX, SY, 0.85))
add_bm("Study_DeskLeg1", cube(0.1, 0.1, 0.8), mat_wood_dark, cols["SageStudy"], loc=(SX-0.9, SY-0.35, 0.4))
add_bm("Study_DeskLeg2", cube(0.1, 0.1, 0.8), mat_wood_dark, cols["SageStudy"], loc=(SX+0.9, SY-0.35, 0.4))
add_bm("Study_DeskLeg3", cube(0.1, 0.1, 0.8), mat_wood_dark, cols["SageStudy"], loc=(SX-0.9, SY+0.35, 0.4))
add_bm("Study_DeskLeg4", cube(0.1, 0.1, 0.8), mat_wood_dark, cols["SageStudy"], loc=(SX+0.9, SY+0.35, 0.4))
# Books on desk (3)
for i in range(3):
    add_bm(f"Study_Book_{i}", cube(0.2, 0.3, 0.06), [mat_book_red, mat_book_blue, mat_book_green][i],
           cols["SageStudy"], loc=(SX-0.5+i*0.4, SY+0.1, 0.95))
# Quill + scroll
add_bm("Study_Scroll", cyl(0.08, 0.4, 8), mat_paper, cols["SageStudy"],
       loc=(SX+0.5, SY-0.2, 0.95), rot=(math.radians(90), 0, 0))
# Candles (2)
add_bm("Study_Candle1", cyl(0.06, 0.3, 6), mat_candle, cols["SageStudy"], loc=(SX-0.8, SY+0.3, 1.05))
add_bm("Study_Candle2", cyl(0.06, 0.3, 6), mat_candle, cols["SageStudy"], loc=(SX+0.8, SY+0.3, 1.05))
# Bookshelf wall
add_bm("Study_Shelf", cube(2.5, 0.3, 1.8), mat_wood_dark, cols["SageStudy"], loc=(SX, SY+2.7, 1.7))
for i in range(8):
    add_bm(f"Study_ShelfBook_{i}", cube(0.18, 0.2, 0.3), [mat_book_red, mat_book_blue, mat_book_green][i%3],
           cols["SageStudy"], loc=(SX-1+i*0.3, SY+2.55, 1.5+(i%2)*0.6))

# ==================== 6. Sage's Library ====================
print("=== Sage Library ===")
LBX, LBY = 0, -15
# Floor (larger)
add_bm("Lib_Floor", cube(5, 5, 0.1), mat_wood_warm, cols["SageLibrary"], loc=(LBX, LBY, 0))
# Tall bookshelves (3 walls)
for wall_i, (wx, wy, sx, sy) in enumerate([(-5,0,0.3,5),(5,0,0.3,5),(0,-5,5,0.3)]):
    add_bm(f"Lib_Shelf_{wall_i}", cube(sx, sy, 2.5), mat_wood_dark, cols["SageLibrary"],
           loc=(LBX+wx, LBY+wy, 2.5))
    # Books along shelves
    for shelf in range(4):
        for bk in range(10):
            if sx > sy:  # horizontal wall
                px = LBX + wx - 2.3 + bk * 0.5
                py = LBY + wy + (-0.2 if wy > 0 else 0.2)
            else:  # vertical wall
                py = LBY + wy - 2.3 + bk * 0.5
                px = LBX + wx + (-0.2 if wx > 0 else 0.2)
            add_bm(f"Lib_Book_{wall_i}_{shelf}_{bk}",
                   cube(0.18, 0.2, 0.32),
                   [mat_book_red, mat_book_blue, mat_book_green][bk%3],
                   cols["SageLibrary"], loc=(px, py, 0.8 + shelf*0.7))
# Reading table (round)
add_bm("Lib_Table", cyl(1.0, 0.1, 16), mat_wood_warm, cols["SageLibrary"], loc=(LBX, LBY+1, 1.0))
add_bm("Lib_TableLeg", cyl(0.2, 1.0), mat_wood_dark, cols["SageLibrary"], loc=(LBX, LBY+1, 0.5))
# Chair
add_bm("Lib_Chair", cube(0.5, 0.5, 0.1), mat_wood_warm, cols["SageLibrary"], loc=(LBX, LBY+2.2, 0.6))
add_bm("Lib_ChairBack", cube(0.5, 0.05, 0.6), mat_wood_warm, cols["SageLibrary"], loc=(LBX, LBY+2.45, 0.95))
# Ladder against shelf
add_bm("Lib_Ladder", cube(0.6, 0.05, 2.8), mat_wood_dark, cols["SageLibrary"],
       loc=(LBX-4.5, LBY, 1.5), rot=(math.radians(15), 0, 0))

# ==================== 7. Training Arena Hub ====================
print("=== Training Arena ===")
TAX, TAY = 15, -15
# Floor (sand circle)
add_bm("Train_Floor", cyl(5, 0.1, 20), mat_dirt, cols["TrainingArena"], loc=(TAX, TAY, 0))
# 6 training dummies
for i in range(6):
    ang = i * 1.047
    px = TAX + math.cos(ang) * 3
    py = TAY + math.sin(ang) * 3
    add_bm(f"Train_DummyPost_{i}", cyl(0.15, 1.8), mat_wood_dark, cols["TrainingArena"], loc=(px, py, 0))
    add_bm(f"Train_DummyHead_{i}", ico(0.4, 1), mat_wood_warm, cols["TrainingArena"], loc=(px, py, 2.0))
    add_bm(f"Train_DummyTorso_{i}", cube(0.6, 0.3, 0.7), mat_wood_warm, cols["TrainingArena"], loc=(px, py, 1.4))
# Weapon rack
add_bm("Train_RackBase", cube(2.0, 0.4, 0.1), mat_wood_dark, cols["TrainingArena"], loc=(TAX-4, TAY+2, 0.05))
add_bm("Train_RackFrame", cube(2.0, 0.05, 1.5), mat_wood_dark, cols["TrainingArena"], loc=(TAX-4, TAY+2.2, 0.8))
for i in range(4):
    add_bm(f"Train_Weapon_{i}", cube(0.05, 0.05, 1.2), mat_iron, cols["TrainingArena"],
           loc=(TAX-4.6+i*0.4, TAY+2.1, 0.7))
# Lever (training reset)
add_bm("Train_LeverBase", cube(0.3, 0.3, 0.4), mat_iron, cols["TrainingArena"], loc=(TAX+4.5, TAY-1, 0.2))
add_bm("Train_LeverArm", cyl(0.05, 0.7), mat_brass, cols["TrainingArena"],
       loc=(TAX+4.5, TAY-1, 0.6), rot=(math.radians(30), 0, 0))

# ==================== 8. Farm Plot ====================
print("=== Farm Plot ===")
FX, FY = -15, 15
# Plowed soil rows (5)
for i in range(5):
    add_bm(f"Farm_Row_{i}", cube(4, 0.6, 0.1), mat_dirt, cols["FarmPlot"],
           loc=(FX, FY-2+i*1, 0.05))
# Crop sprouts (random per row)
for i in range(5):
    for j in range(8):
        add_bm(f"Farm_Sprout_{i}_{j}", cyl(0.05, 0.25, 6), mat_grass, cols["FarmPlot"],
               loc=(FX-1.8+j*0.5, FY-2+i*1, 0.22))
# Fence posts
for i in range(5):
    add_bm(f"Farm_FencePost_{i}", cyl(0.1, 1.2), mat_wood_dark, cols["FarmPlot"],
           loc=(FX-2.5+i*1.25, FY-3, 0.6))
    add_bm(f"Farm_FencePost2_{i}", cyl(0.1, 1.2), mat_wood_dark, cols["FarmPlot"],
           loc=(FX-2.5+i*1.25, FY+3, 0.6))
# Scarecrow
add_bm("Farm_ScarecrowPole", cyl(0.08, 2.0), mat_wood_dark, cols["FarmPlot"], loc=(FX, FY, 1.0))
add_bm("Farm_ScarecrowArm", cube(1.2, 0.05, 0.05), mat_wood_dark, cols["FarmPlot"], loc=(FX, FY, 1.6))
add_bm("Farm_ScarecrowHead", ico(0.3, 1), mat_paper, cols["FarmPlot"], loc=(FX, FY, 2.1))
# Tool shed
add_bm("Farm_Shed", cube(1.2, 1.0, 1.5), mat_wood_warm, cols["FarmPlot"], loc=(FX+4, FY+2, 0.75))
add_bm("Farm_ShedRoof", cube(1.4, 1.2, 0.1), mat_wood_dark, cols["FarmPlot"], loc=(FX+4, FY+2, 1.55))

# ==================== 9. Fishing Dock ====================
print("=== Fishing Dock ===")
FDX, FDY = 0, 15
# Water plane
add_bm("Dock_Water", cube(8, 4, 0.05), mat_water, cols["FishingDock"], loc=(FDX, FDY+3, -0.1))
# Dock planks (6 long)
for i in range(6):
    add_bm(f"Dock_Plank_{i}", cube(0.5, 4, 0.1), mat_wood_warm, cols["FishingDock"],
           loc=(FDX-1.5+i*0.6, FDY, 0.5))
# Dock posts
for x in [-1.7, 1.7]:
    for y in [-1.5, 1.5]:
        add_bm(f"Dock_Post_{x}_{y}", cyl(0.15, 1.5), mat_wood_dark, cols["FishingDock"],
               loc=(FDX+x, FDY+y, -0.25))
# Rod rest
add_bm("Dock_RodRestBase", cube(0.2, 0.2, 0.3), mat_wood_dark, cols["FishingDock"], loc=(FDX+1, FDY+1.5, 0.7))
add_bm("Dock_Rod", cyl(0.04, 2.5, 6), mat_wood_dark, cols["FishingDock"],
       loc=(FDX+1, FDY+2.5, 1.5), rot=(math.radians(45), 0, 0))
# Fish basket
add_bm("Dock_Basket", cyl(0.4, 0.5, 12), mat_wood_warm, cols["FishingDock"], loc=(FDX-1, FDY+1.5, 0.8))

# ==================== 10. Cooking Station ====================
print("=== Cooking Station ===")
CKX, CKY = 15, 15
# Counter
add_bm("Cook_Counter", cube(3, 0.8, 0.1), mat_marble, cols["CookingStation"], loc=(CKX, CKY, 1.0))
add_bm("Cook_CounterBase", cube(3, 0.8, 0.95), mat_wood_warm, cols["CookingStation"], loc=(CKX, CKY, 0.475))
# Stove
add_bm("Cook_Stove", cube(0.8, 0.6, 0.6), mat_iron, cols["CookingStation"], loc=(CKX-0.8, CKY, 1.4))
add_bm("Cook_Burner1", cyl(0.18, 0.05, 12), mat_iron, cols["CookingStation"], loc=(CKX-1.0, CKY, 1.73))
add_bm("Cook_Burner2", cyl(0.18, 0.05, 12), mat_iron, cols["CookingStation"], loc=(CKX-0.6, CKY, 1.73))
# Pot on stove
add_bm("Cook_Pot", cyl(0.25, 0.3, 12), mat_iron, cols["CookingStation"], loc=(CKX-0.8, CKY, 1.85))
# Hanging pots (3)
for i in range(3):
    add_bm(f"Cook_HangPot_{i}", cyl(0.2, 0.25, 12), mat_iron, cols["CookingStation"],
           loc=(CKX+0.5+i*0.5, CKY+0.3, 2.5))
# Spice shelf
add_bm("Cook_SpiceShelf", cube(2.0, 0.2, 0.05), mat_wood_dark, cols["CookingStation"], loc=(CKX, CKY+0.5, 2.0))
for i in range(6):
    add_bm(f"Cook_Spice_{i}", cyl(0.1, 0.2, 8), mat_glass, cols["CookingStation"],
           loc=(CKX-0.8+i*0.32, CKY+0.5, 2.15))

# ==================== 11. Crafting Workshop ====================
print("=== Crafting Workshop ===")
CFX, CFY = 30, 15
# Forge (stone block + opening + chimney)
add_bm("Craft_Forge", cube(1.5, 1.5, 1.5), mat_stone_dark, cols["CraftingWorkshop"], loc=(CFX, CFY, 0.75))
add_bm("Craft_Chimney", cube(0.8, 0.8, 2.0), mat_stone_dark, cols["CraftingWorkshop"], loc=(CFX, CFY, 2.5))
add_bm("Craft_ForgeFire", cube(0.6, 0.6, 0.4), mat_lantern, cols["CraftingWorkshop"], loc=(CFX, CFY-0.6, 1.0))
# Anvil
add_bm("Craft_AnvilBase", cyl(0.4, 0.6, 8), mat_wood_dark, cols["CraftingWorkshop"], loc=(CFX-2, CFY, 0.3))
add_bm("Craft_AnvilTop", cube(0.7, 0.3, 0.3), mat_iron, cols["CraftingWorkshop"], loc=(CFX-2, CFY, 0.75))
add_bm("Craft_AnvilHorn", cyl(0.15, 0.4, 8), mat_iron, cols["CraftingWorkshop"],
       loc=(CFX-2.4, CFY, 0.85), rot=(0, math.radians(90), 0))
# Workbench
add_bm("Craft_BenchTop", cube(2.5, 0.7, 0.1), mat_wood_warm, cols["CraftingWorkshop"], loc=(CFX, CFY+2.5, 0.95))
add_bm("Craft_BenchBase", cube(2.5, 0.7, 0.85), mat_wood_dark, cols["CraftingWorkshop"], loc=(CFX, CFY+2.5, 0.475))
# Tool wall
add_bm("Craft_ToolWall", cube(2.5, 0.05, 1.5), mat_wood_dark, cols["CraftingWorkshop"], loc=(CFX, CFY+3.0, 1.5))
for i in range(5):
    add_bm(f"Craft_Tool_{i}", cube(0.05, 0.05, 0.8), mat_iron, cols["CraftingWorkshop"],
           loc=(CFX-1+i*0.5, CFY+2.95, 1.5))

# ==================== 12. Pet Hutch Area ====================
print("=== Pet Hutch ===")
PHX, PHY = -30, 15
# Hutch (small wooden house)
add_bm("Pet_Hutch", cube(2.0, 1.2, 1.0), mat_wood_warm, cols["PetHutch"], loc=(PHX, PHY, 0.5))
add_bm("Pet_HutchRoof", cube(2.2, 1.4, 0.1), mat_wood_dark, cols["PetHutch"], loc=(PHX, PHY, 1.05))
# 4 pet beds (round pillows)
for i, (px, py) in enumerate([(-1.8,0),(-1.8,1.5),(-1.8,-1.5),(-1.8,3)]):
    add_bm(f"Pet_Bed_{i}", cyl(0.4, 0.15, 12), mat_velvet, cols["PetHutch"],
           loc=(PHX+px, PHY+py, 0.075))
# Food trough (4 slots)
add_bm("Pet_TroughBase", cube(2.0, 0.4, 0.2), mat_wood_dark, cols["PetHutch"], loc=(PHX+2, PHY, 0.1))
for i in range(4):
    add_bm(f"Pet_TroughBowl_{i}", cyl(0.2, 0.1, 12), mat_iron, cols["PetHutch"],
           loc=(PHX+1.3+i*0.45, PHY, 0.25))

# ==================== 13. Memorial Gallery ====================
print("=== Memorial Gallery ===")
MGX, MGY = -45, -15
# Floor (long)
add_bm("Mem_Floor", cube(8, 3, 0.1), mat_marble, cols["MemorialGallery"], loc=(MGX, MGY, 0))
# 9 plaques (one per iteration)
for i in range(9):
    px = MGX - 3.5 + i * 0.875
    add_bm(f"Mem_Plaque_{i}", cube(0.6, 0.1, 0.8), mat_brass, cols["MemorialGallery"],
           loc=(px, MGY+1.4, 1.2))
    # Candle below each
    add_bm(f"Mem_Candle_{i}", cyl(0.05, 0.2, 6), mat_candle, cols["MemorialGallery"],
           loc=(px, MGY+1.2, 0.2))
# Bench
add_bm("Mem_Bench", cube(3, 0.4, 0.1), mat_wood_warm, cols["MemorialGallery"], loc=(MGX, MGY-1.0, 0.5))
add_bm("Mem_BenchLeg1", cube(0.1, 0.4, 0.4), mat_wood_dark, cols["MemorialGallery"], loc=(MGX-1.3, MGY-1.0, 0.2))
add_bm("Mem_BenchLeg2", cube(0.1, 0.4, 0.4), mat_wood_dark, cols["MemorialGallery"], loc=(MGX+1.3, MGY-1.0, 0.2))

# ==================== 14. Trophy Display Hall ====================
print("=== Trophy Hall ===")
THX, THY = 45, -15
# Floor
add_bm("Tro_Floor", cube(6, 4, 0.1), mat_stone_floor, cols["TrophyHall"], loc=(THX, THY, 0))
# 12 mount pedestals
for i in range(12):
    px = THX - 2.5 + (i % 6) * 1.0
    py = THY - 1.0 + (i // 6) * 2.0
    add_bm(f"Tro_Pedestal_{i}", cyl(0.4, 0.8, 8), mat_stone_dark, cols["TrophyHall"], loc=(px, py, 0.4))
    # Trophy item (varies)
    if i < 6:  # boss heads — icospheres
        add_bm(f"Tro_BossHead_{i}", ico(0.35, 1), mat_iron, cols["TrophyHall"], loc=(px, py, 1.05))
    elif i < 9:  # rare fish — cylinders
        add_bm(f"Tro_Fish_{i}", cube(0.4, 0.15, 0.15), mat_brass, cols["TrophyHall"], loc=(px, py, 0.95))
    else:  # treasures — gold cubes
        add_bm(f"Tro_Treasure_{i}", cube(0.25, 0.25, 0.25), mat_gold, cols["TrophyHall"], loc=(px, py, 0.95))
# Banner pair
add_bm("Tro_Banner1", cube(0.05, 0.5, 2.0), mat_velvet, cols["TrophyHall"], loc=(THX-3.2, THY, 1.6))
add_bm("Tro_Banner2", cube(0.05, 0.5, 2.0), mat_velvet, cols["TrophyHall"], loc=(THX+3.2, THY, 1.6))

# ==================== 15. Wardrobe Room ====================
print("=== Wardrobe ===")
WRX, WRY = 30, -15
# Floor + walls
add_bm("Ward_Floor", cube(4, 4, 0.1), mat_wood_warm, cols["Wardrobe"], loc=(WRX, WRY, 0))
# Mirror (frame + glass)
add_bm("Ward_MirrorFrame", cube(1.0, 0.1, 2.0), mat_brass, cols["Wardrobe"], loc=(WRX, WRY+3.9, 1.0))
add_bm("Ward_MirrorGlass", cube(0.85, 0.05, 1.85), mat_glass, cols["Wardrobe"], loc=(WRX, WRY+3.85, 1.0))
# 8 mannequins (2 rows of 4)
for i in range(8):
    px = WRX - 1.5 + (i % 4) * 1.0
    py = WRY - 1.0 + (i // 4) * 2.0
    add_bm(f"Ward_MannequinBase_{i}", cyl(0.2, 0.1, 8), mat_wood_dark, cols["Wardrobe"], loc=(px, py, 0.05))
    add_bm(f"Ward_MannequinPole_{i}", cyl(0.04, 1.2), mat_wood_dark, cols["Wardrobe"], loc=(px, py, 0.7))
    add_bm(f"Ward_MannequinTorso_{i}", cube(0.4, 0.2, 0.6), mat_paper, cols["Wardrobe"], loc=(px, py, 1.6))
    add_bm(f"Ward_MannequinHead_{i}", ico(0.18, 1), mat_paper, cols["Wardrobe"], loc=(px, py, 2.0))
# Chest
add_bm("Ward_Chest", cube(1.0, 0.5, 0.5), mat_wood_dark, cols["Wardrobe"], loc=(WRX-2.5, WRY-2.5, 0.25))
# Dye station (vat + bottles)
add_bm("Ward_DyeVat", cyl(0.4, 0.6, 12), mat_iron, cols["Wardrobe"], loc=(WRX+2.5, WRY-2.5, 0.3))
add_bm("Ward_DyeLiquid", cyl(0.35, 0.05, 12), mat_dye_red, cols["Wardrobe"], loc=(WRX+2.5, WRY-2.5, 0.55))
for i in range(4):
    add_bm(f"Ward_DyeBottle_{i}", cyl(0.07, 0.25, 8), mat_glass, cols["Wardrobe"],
           loc=(WRX+1.7+i*0.2, WRY-2.5, 0.17))

# ==================== 16. Mysteries Room ====================
print("=== Mysteries Room ===")
MRX, MRY = 0, 30
# Floor + walls (small dark room)
add_bm("Mys_Floor", cube(3, 3, 0.1), mat_stone_dark, cols["MysteriesRoom"], loc=(MRX, MRY, 0))
for i, (px, py, sx, sy) in enumerate([(0,-3,3,0.15),(0,3,3,0.15),(-3,0,0.15,3),(3,0,0.15,3)]):
    add_bm(f"Mys_Wall_{i}", cube(sx, sy, 2.5), mat_stone_dark, cols["MysteriesRoom"],
           loc=(MRX+px, MRY+py, 1.25))
# 5 books on a stone shelf (puzzle)
add_bm("Mys_Shelf", cube(2, 0.3, 0.1), mat_stone_floor, cols["MysteriesRoom"], loc=(MRX, MRY+2.7, 1.5))
for i in range(5):
    add_bm(f"Mys_Book_{i}", cube(0.18, 0.2, 0.32),
           [mat_book_red, mat_book_blue, mat_book_green, mat_book_red, mat_book_blue][i],
           cols["MysteriesRoom"], loc=(MRX-0.8+i*0.4, MRY+2.65, 1.71))
# Hidden door (hint outline on wall)
add_bm("Mys_DoorOutline", cube(0.05, 0.8, 1.6), mat_brass, cols["MysteriesRoom"], loc=(MRX-2.95, MRY-1, 1.3))
# Treasure chest (locked)
add_bm("Mys_Chest", cube(1.0, 0.6, 0.5), mat_wood_dark, cols["MysteriesRoom"], loc=(MRX, MRY, 0.3))
add_bm("Mys_ChestGold", cube(0.9, 0.55, 0.05), mat_gold, cols["MysteriesRoom"], loc=(MRX, MRY, 0.55))
# Floor candles for atmosphere (4)
for ang in [0.785, 2.356, 3.926, 5.495]:
    add_bm(f"Mys_Candle_{ang:.1f}", cyl(0.05, 0.3, 6), mat_candle, cols["MysteriesRoom"],
           loc=(MRX+math.cos(ang)*1.2, MRY+math.sin(ang)*1.2, 0.25))

# ---------- save ----------
total = sum(1 for o in bpy.data.objects if o.type == 'MESH')
print(f"Hub expansion pipeline complete. Total mesh objects: {total}")
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT)
print(f"Saved: {OUTPUT}")
