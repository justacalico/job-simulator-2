extends JobBase

const BLUE := Color(0.25, 0.45, 0.95)
const RED := Color(0.9, 0.25, 0.2)
const PAPER_POS := Vector3(0, 1.06, 0.1)
const PAPER_IN := Vector3(-2.4, 1.06, 0.1)
const PAPER_OUT := Vector3(2.4, 1.06, 0.1)

var current: Interactable
var busy := false

func build() -> void:
	table(Vector3(0, 0.5, 0.15), Vector3(3.2, 1.0, 1.4), Color(0.35, 0.26, 0.2))
	model("res://assets/models/monitor.glb", Vector3(-0.9, 1.0, -0.45), 1.0, 0.5)
	model("res://assets/models/mug.glb", Vector3(1.05, 1.0, -0.4))
	_make_stamp(Vector3(-0.9, 1.02, 0.45), BLUE, true)
	_make_stamp(Vector3(0.9, 1.02, 0.45), RED, false)
	_next_paper()

func info_text() -> String:
	return "Stamp BLUE for approved seals, RED for rejected seals."

func _make_stamp(pos: Vector3, color: Color, approve: bool) -> void:
	var s := model("res://assets/models/stamp.glb", pos)
	tint(s, color)
	var shape := CylinderShape3D.new()
	shape.radius = 0.12
	shape.height = 0.16
	var c := Interactable.wrap(s, shape)
	c.data = approve
	c.clicked.connect(_on_stamp)

func _next_paper() -> void:
	busy = true
	var approve: bool = randf() < 0.5
	var paper := model("res://assets/models/paper.glb", PAPER_IN)
	var seal := MeshInstance3D.new()
	var sm := CylinderMesh.new()
	sm.top_radius = 0.028
	sm.bottom_radius = 0.028
	sm.height = 0.006
	seal.mesh = sm
	seal.position = Vector3(0.055, 0.006, -0.09)
	seal.material_override = _mat(BLUE if approve else RED, true)
	paper.add_child(seal)
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.24, 0.05, 0.32)
	var c := Interactable.wrap(paper, shape)
	c.data = approve
	current = c
	var tw := create_tween()
	tw.tween_property(c, "position", PAPER_POS, 0.35).set_trans(Tween.TRANS_QUAD)
	tw.tween_callback(func(): busy = false)

func _on_stamp(stamp: Interactable) -> void:
	if busy or current == null:
		return
	busy = true
	var want_approve: bool = current.data
	var chose_approve: bool = stamp.data
	Sfx.play(get_tree(), "stamp")
	var tw := create_tween()
	tw.tween_property(stamp, "position:y", stamp.position.y - 0.06, 0.08)
	tw.tween_property(stamp, "position:y", stamp.position.y, 0.12)
	var done_paper := current
	current = null
	if chose_approve == want_approve:
		add_score(1)
		Sfx.play(get_tree(), "ding")
	else:
		Sfx.play(get_tree(), "error")
	var tw2 := create_tween()
	tw2.tween_interval(0.2)
	tw2.tween_property(done_paper, "position", PAPER_OUT, 0.35).set_trans(Tween.TRANS_QUAD)
	tw2.tween_callback(done_paper.queue_free)
	tw2.tween_callback(_next_paper)
