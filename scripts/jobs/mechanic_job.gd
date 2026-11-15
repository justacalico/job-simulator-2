extends JobBase

const LOOSE := Color(1.0, 0.55, 0.1)
const TIGHT := Color(0.55, 0.6, 0.65)
const BOLTS_PER_BLOCK := 6

var bolts := []
var respawn_timer := -1.0

func build() -> void:
	table(Vector3(0, 0.55, 0), Vector3(2.6, 1.1, 1.5), Color(0.3, 0.3, 0.34))
	model("res://assets/models/wrench.glb", Vector3(-1.0, 1.12, 0.4), 1.0, 1.2)
	var block := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(1.4, 0.7, 0.9)
	block.mesh = bm
	block.position = Vector3(0.15, 1.47, -0.1)
	block.material_override = _mat(Color(0.38, 0.4, 0.45))
	add_child(block)
	_spawn_bolts()

func info_text() -> String:
	return "Click every glowing bolt to tighten it. Finish a block to score."

func tick(delta: float) -> void:
	if respawn_timer >= 0.0:
		respawn_timer -= delta
		if respawn_timer <= 0.0:
			respawn_timer = -1.0
			_spawn_bolts()
	else:
		for b in bolts:
			b.rotate_y(delta * 2.0)

func _spawn_bolts() -> void:
	bolts.clear()
	var spots := [
		Vector3(-0.45, 1.86, -0.35), Vector3(0.15, 1.86, -0.35), Vector3(0.75, 1.86, -0.35),
		Vector3(-0.45, 1.86, 0.15), Vector3(0.15, 1.86, 0.15), Vector3(0.75, 1.86, 0.15),
	]
	spots.shuffle()
	for i in BOLTS_PER_BLOCK:
		var b := model("res://assets/models/bolt.glb", spots[i])
		tint(b, LOOSE, true)
		var shape := CylinderShape3D.new()
		shape.radius = 0.07
		shape.height = 0.1
		var c := Interactable.wrap(b, shape)
		c.clicked.connect(_on_bolt)
		bolts.append(c)

func _on_bolt(c: Interactable) -> void:
	c.enabled = false
	bolts.erase(c)
	Sfx.play(get_tree(), "click")
	tint(c, TIGHT)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(c, "rotation:y", c.rotation.y + TAU * 2.0, 0.4)
	tw.tween_property(c, "position:y", c.position.y - 0.03, 0.4)
	tw.chain().tween_callback(c.queue_free)
	if bolts.is_empty():
		add_score(1)
		Sfx.play(get_tree(), "ding")
		respawn_timer = 0.7
