import bpy
import math
import os
import sys

argv = sys.argv[sys.argv.index("--") + 1:]
OUT_DIR = os.path.abspath(argv[0])
MODELS = os.path.join(OUT_DIR, "models")
PREVIEWS = os.path.join(OUT_DIR, "previews")
os.makedirs(MODELS, exist_ok=True)
os.makedirs(PREVIEWS, exist_ok=True)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete()


def mat(name, r, g, b, rough=0.75, metal=0.0):
    m = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (r, g, b, 1.0)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metal
    return m


def root_empty(name):
    bpy.ops.object.empty_add(type="PLAIN_AXES", location=(0, 0, 0))
    e = bpy.context.active_object
    e.name = name
    return e


def cube(name, loc, scale, m, parent):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=loc)
    o = bpy.context.active_object
    o.name = name
    o.scale = scale
    bpy.ops.object.transform_apply(scale=True)
    if m:
        o.data.materials.append(m)
    o.parent = parent
    return o


def cyl(name, loc, radius, depth, m, parent, vertices=32, rot=None):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc)
    o = bpy.context.active_object
    o.name = name
    if rot:
        o.rotation_euler = rot
    if m:
        o.data.materials.append(m)
    o.parent = parent
    return o


def torus(name, loc, major, minor, m, parent, rot=None, scale=None):
    bpy.ops.mesh.primitive_torus_add(major_radius=major, minor_radius=minor,
                                     major_segments=32, minor_segments=10, location=loc)
    o = bpy.context.active_object
    o.name = name
    if rot:
        o.rotation_euler = rot
    if scale:
        o.scale = scale
        bpy.ops.object.transform_apply(scale=True)
    if m:
        o.data.materials.append(m)
    o.parent = parent
    return o


def sphere(name, loc, scale, m, parent):
    bpy.ops.mesh.primitive_uv_sphere_add(radius=1.0, segments=24, ring_count=16, location=loc)
    o = bpy.context.active_object
    o.name = name
    o.scale = scale
    bpy.ops.object.transform_apply(scale=True)
    bpy.ops.object.shade_smooth()
    if m:
        o.data.materials.append(m)
    o.parent = parent
    return o


WOOD = mat("wood", 0.45, 0.3, 0.18)
STEEL = mat("steel", 0.55, 0.58, 0.62, rough=0.35, metal=0.8)
DARKMETAL = mat("darkmetal", 0.12, 0.12, 0.14, rough=0.5, metal=0.6)
BLACK = mat("black", 0.05, 0.05, 0.06)
WHITE = mat("white", 0.95, 0.95, 0.92, rough=0.9)
BROWN = mat("patty", 0.35, 0.18, 0.08)
BUN = mat("bun", 0.85, 0.6, 0.3)
RED = mat("red", 0.8, 0.15, 0.12)
GREEN = mat("green", 0.2, 0.6, 0.25)
CARDBOARD = mat("cardboard", 0.65, 0.5, 0.3)
TAPE = mat("tape", 0.9, 0.85, 0.7)
SCREEN = mat("screen", 0.1, 0.15, 0.2, rough=0.2)
PLASTIC = mat("plastic", 0.2, 0.25, 0.3)


def make_patty():
    r = root_empty("patty")
    cyl("patty_meat", (0, 0, 0.015), 0.09, 0.03, BROWN, r)


def make_plate():
    r = root_empty("plate")
    cyl("plate_base", (0, 0, 0.008), 0.11, 0.014, WHITE, r)
    torus("plate_rim", (0, 0, 0.015), 0.105, 0.012, WHITE, r)


def make_spatula():
    r = root_empty("spatula")
    cube("spatula_blade", (0, 0.07, 0.004), (0.09, 0.12, 0.008), STEEL, r)
    cyl("spatula_handle", (0, -0.09, 0.012), 0.012, 0.2, BLACK, r, rot=(math.radians(90), 0, 0))


def make_paper():
    r = root_empty("paper")
    cube("paper_sheet", (0, 0, 0.002), (0.21, 0.297, 0.004), WHITE, r)


def make_stamp():
    r = root_empty("stamp")
    cube("stamp_base", (0, 0, 0.012), (0.07, 0.05, 0.024), BLACK, r)
    cyl("stamp_neck", (0, 0, 0.045), 0.012, 0.045, WOOD, r)
    sphere("stamp_handle", (0, 0, 0.085), (0.028, 0.028, 0.035), WOOD, r)


def make_wrench():
    r = root_empty("wrench")
    cube("wrench_handle", (0, 0, 0.008), (0.035, 0.17, 0.014), STEEL, r)
    torus("wrench_head", (0, 0.115, 0.008), 0.032, 0.014, STEEL, r)
    torus("wrench_tail", (0, -0.11, 0.008), 0.022, 0.011, STEEL, r)


def make_bolt():
    r = root_empty("bolt")
    cyl("bolt_head", (0, 0, 0.05), 0.035, 0.028, STEEL, r, vertices=6)
    cyl("bolt_shaft", (0, 0, 0.018), 0.016, 0.04, STEEL, r)


def make_mug():
    r = root_empty("mug")
    cyl("mug_body", (0, 0, 0.05), 0.042, 0.1, RED, r)
    cyl("mug_top", (0, 0, 0.098), 0.036, 0.006, DARKMETAL, r)
    torus("mug_handle", (0.055, 0, 0.05), 0.028, 0.009, RED, r, rot=(math.radians(90), 0, 0))


def make_monitor():
    r = root_empty("monitor")
    cube("monitor_screen", (0, 0, 0.24), (0.5, 0.035, 0.3), BLACK, r)
    cube("monitor_face", (0, -0.019, 0.24), (0.46, 0.004, 0.26), SCREEN, r)
    cyl("monitor_neck", (0, 0, 0.07), 0.02, 0.12, DARKMETAL, r)
    cube("monitor_foot", (0, 0, 0.008), (0.16, 0.12, 0.015), DARKMETAL, r)


def make_can():
    r = root_empty("can")
    cyl("can_body", (0, 0, 0.06), 0.033, 0.115, RED, r)
    cyl("can_top", (0, 0, 0.118), 0.03, 0.005, STEEL, r)


def make_box():
    r = root_empty("box")
    cube("box_body", (0, 0, 0.06), (0.14, 0.14, 0.12), CARDBOARD, r)
    cube("box_tape", (0, 0, 0.121), (0.14, 0.03, 0.004), TAPE, r)


def make_grill():
    r = root_empty("grill")
    cube("grill_body", (0, 0, 0.06), (0.9, 0.6, 0.12), DARKMETAL, r)
    for i in range(6):
        cyl("grate_%d" % i, (-0.35 + i * 0.14, 0, 0.125), 0.012, 0.55, STEEL, r,
            rot=(math.radians(90), 0, 0))
    cube("grill_tray", (0, 0.32, 0.05), (0.5, 0.1, 0.06), BLACK, r)


def make_conveyor():
    r = root_empty("conveyor")
    cube("conv_frame", (0, 0, 0.05), (1.9, 0.56, 0.1), PLASTIC, r)
    cyl("conv_roll_a", (-0.92, 0, 0.1), 0.05, 0.52, STEEL, r, rot=(math.radians(90), 0, 0))
    cyl("conv_roll_b", (0.92, 0, 0.1), 0.05, 0.52, STEEL, r, rot=(math.radians(90), 0, 0))
    for x in (-0.85, 0.85):
        for y in (-0.2, 0.2):
            cyl("conv_leg", (x, y, -0.05), 0.02, 0.1, DARKMETAL, r)


def make_register():
    r = root_empty("register")
    cube("reg_base", (0, 0, 0.07), (0.36, 0.3, 0.14), PLASTIC, r)
    cube("reg_drawer", (0, 0.13, 0.06), (0.3, 0.05, 0.08), BLACK, r)
    cube("reg_stem", (0, -0.1, 0.2), (0.05, 0.05, 0.12), DARKMETAL, r)
    cube("reg_display", (0, -0.1, 0.3), (0.22, 0.04, 0.12), SCREEN, r)
    for i in range(3):
        for j in range(3):
            cube("reg_key", (-0.08 + i * 0.08, 0.02 + j * 0.07, 0.145),
                 (0.05, 0.05, 0.012), WHITE, r)


MODELS_LIST = [
    ("patty", make_patty), ("plate", make_plate), ("spatula", make_spatula),
    ("paper", make_paper), ("stamp", make_stamp), ("wrench", make_wrench),
    ("bolt", make_bolt), ("mug", make_mug), ("monitor", make_monitor),
    ("can", make_can), ("box", make_box), ("grill", make_grill),
    ("conveyor", make_conveyor), ("register", make_register),
]

VIEW_SCALE = {
    "patty": 0.35, "plate": 0.4, "spatula": 0.45, "paper": 0.45,
    "stamp": 0.35, "wrench": 0.45, "bolt": 0.25, "mug": 0.35,
    "monitor": 0.7, "can": 0.3, "box": 0.35, "grill": 1.3,
    "conveyor": 2.4, "register": 0.7,
}

HIDDEN = set()

for idx, (name, fn) in enumerate(MODELS_LIST):
    fn()
    root = bpy.data.objects[name]
    bpy.ops.object.select_all(action="DESELECT")
    root.select_set(True)
    for child in root.children_recursive:
        child.select_set(True)
    path = os.path.join(MODELS, name + ".glb")
    bpy.ops.export_scene.gltf(filepath=path, use_selection=True, export_format="GLB")
    root.hide_render = True
    for child in root.children_recursive:
        child.hide_render = True
    HIDDEN.add(name)
    print("exported", name)


def build_previews():
    import mathutils

    bpy.ops.mesh.primitive_plane_add(size=40, location=(0, 0, -0.12))
    ground = bpy.context.active_object
    ground.data.materials.append(mat("ground", 0.16, 0.17, 0.2))

    bpy.ops.object.light_add(type="AREA", location=(1.5, -1.5, 3.0))
    key = bpy.context.active_object
    key.data.energy = 60
    key.data.size = 2.0
    bpy.ops.object.light_add(type="AREA", location=(-2.0, 1.5, 1.5))
    fill = bpy.context.active_object
    fill.data.energy = 40
    fill.data.size = 2.0

    sc = bpy.context.scene
    sc.world.use_nodes = True
    bg = sc.world.node_tree.nodes["Background"]
    bg.inputs[0].default_value = (0.04, 0.05, 0.07, 1.0)
    bg.inputs[1].default_value = 1.0

    bpy.ops.object.camera_add()
    cam = bpy.context.active_object
    cam.data.type = "ORTHO"
    sc.camera = cam

    sc.render.engine = "CYCLES"
    sc.cycles.samples = 48
    sc.cycles.use_denoising = True
    sc.render.resolution_x = 480
    sc.render.resolution_y = 480

    for name, scale in VIEW_SCALE.items():
        root = bpy.data.objects[name]
        root.hide_render = False
        for child in root.children_recursive:
            child.hide_render = False
        root.location = (0, 0, 0)

        target = mathutils.Vector((0, 0, 0.12))
        cam.location = target + mathutils.Vector((0.55, -0.75, 0.55)) * scale * 3.0
        d = target - cam.location
        cam.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()
        cam.data.ortho_scale = scale

        sc.render.filepath = os.path.join(PREVIEWS, name + ".png")
        bpy.ops.render.render(write_still=True)

        root.hide_render = True
        for child in root.children_recursive:
            child.hide_render = True
        print("rendered", name)


build_previews()
print("done")
