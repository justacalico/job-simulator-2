class_name JobBase
extends Node3D

signal finished(score: int, pay: int)

const SHIFT_SECONDS := 60.0

var time_left := SHIFT_SECONDS
var score := 0
var running := false
var job_id := ""

var _hud_time: Label
var _hud_score: Label
var _hud_info: Label
var _end_panel: Control
var _root_ui: Control

func start(id: String) -> void:
	job_id = id
	_build_world()
	_build_hud()
	build()
	running = true

func build() -> void:
	pass

func info_text() -> String:
	return ""

func _process(delta: float) -> void:
	if not running:
		return
	time_left -= delta
	if time_left <= 0.0:
		time_left = 0.0
		running = false
		_end_shift()
	_update_hud()
	tick(delta)

func tick(_delta: float) -> void:
	pass

func add_score(n: int) -> void:
	score += n
	_update_hud()

func set_info(text: String) -> void:
	if _hud_info != null:
		_hud_info.text = text

func _update_hud() -> void:
	_hud_time.text = "%02d" % int(ceil(time_left))
	_hud_score.text = "Score %d" % score

func _end_shift() -> void:
	var pay := GameState.record_shift(job_id, score)
	finished.emit(score, pay)

func _build_world() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.07, 0.08, 0.12)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.5, 0.55, 0.65)
	e.ambient_light_energy = 0.7
	env.environment = e
	add_child(env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -30, 0)
	sun.light_energy = 1.4
	sun.shadow_enabled = true
	add_child(sun)

	var floor_mesh := MeshInstance3D.new()
	var fm := BoxMesh.new()
	fm.size = Vector3(30, 0.2, 30)
	floor_mesh.mesh = fm
	floor_mesh.position = Vector3(0, -0.1, 0)
	floor_mesh.material_override = _mat(Color(0.16, 0.16, 0.19))
	add_child(floor_mesh)

	var wall := MeshInstance3D.new()
	var wm := BoxMesh.new()
	wm.size = Vector3(30, 8, 0.2)
	wall.mesh = wm
	wall.position = Vector3(0, 4, -6)
	wall.material_override = _mat(Color(0.22, 0.24, 0.3))
	add_child(wall)

	var cam := Camera3D.new()
	cam.position = Vector3(0, 2.6, 3.4)
	cam.rotation_degrees = Vector3(-30, 0, 0)
	cam.fov = 55.0
	add_child(cam)
	cam.make_current()

func table(pos: Vector3, size: Vector3, color := Color(0.45, 0.3, 0.18)) -> MeshInstance3D:
	var t := MeshInstance3D.new()
	var m := BoxMesh.new()
	m.size = size
	t.mesh = m
	t.position = pos
	t.material_override = _mat(color)
	add_child(t)
	return t

func model(path: String, pos: Vector3, scale := 1.0, rot_y := 0.0) -> Node3D:
	var res := load(path)
	var inst: Node3D
	if res is PackedScene:
		inst = res.instantiate()
	else:
		inst = Node3D.new()
	inst.position = pos
	inst.scale = Vector3.ONE * scale
	inst.rotation.y = rot_y
	add_child(inst)
	return inst

func tint(node: Node, color: Color, emission := false) -> void:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	if emission:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = 2.0
	for child in node.find_children("*", "MeshInstance3D", true, false):
		child.material_override = m
	if node is MeshInstance3D:
		node.material_override = m

func _mat(color: Color, emission := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	if emission:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = 1.6
	return m

func box_clickable(size: Vector3) -> Interactable:
	var shape := BoxShape3D.new()
	shape.size = size
	return Interactable.new(shape)

func _build_hud() -> void:
	_root_ui = Control.new()
	_root_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root_ui)

	var bar := HBoxContainer.new()
	bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bar.add_theme_constant_override("separation", 30)
	bar.offset_left = 20
	bar.offset_top = 12
	bar.offset_right = -20
	bar.offset_bottom = 56
	_root_ui.add_child(bar)

	var title := Label.new()
	title.text = GameState.JOBS[job_id].title
	title.add_theme_font_size_override("font_size", 28)
	bar.add_child(title)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(spacer)

	_hud_score = Label.new()
	_hud_score.add_theme_font_size_override("font_size", 28)
	bar.add_child(_hud_score)

	_hud_time = Label.new()
	_hud_time.add_theme_font_size_override("font_size", 34)
	bar.add_child(_hud_time)

	_hud_info = Label.new()
	_hud_info.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_hud_info.add_theme_font_size_override("font_size", 22)
	_hud_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hud_info.offset_bottom = -30
	_hud_info.text = info_text()
	_root_ui.add_child(_hud_info)

	_update_hud()
