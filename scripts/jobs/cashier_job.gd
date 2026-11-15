extends JobBase

const ITEMS := ["res://assets/models/can.glb", "res://assets/models/box.glb", "res://assets/models/mug.glb"]
const BELT_Y := 1.12
const SPEED := 0.55

var items := []
var spawn_timer := 0.0
var missed := 0

func build() -> void:
	table(Vector3(0, 0.5, 0), Vector3(3.4, 1.0, 1.4), Color(0.25, 0.3, 0.32))
	model("res://assets/models/conveyor.glb", Vector3(0, 1.0, 0))
	model("res://assets/models/register.glb", Vector3(-1.35, 1.0, -0.55), 1.0, 0.35)
	var belt := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(3.2, 0.04, 0.5)
	belt.mesh = bm
	belt.position = Vector3(0, 1.1, 0)
	belt.material_override = _mat(Color(0.1, 0.1, 0.12))
	add_child(belt)

func info_text() -> String:
	return "Click items to scan them before they fall off the belt."

func tick(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = randf_range(0.9, 1.7)
		_spawn_item()
	for c in items.duplicate():
		c.position.x -= SPEED * delta
		if c.position.x < -1.85:
			items.erase(c)
			c.queue_free()
			missed += 1
			set_info("Missed %d" % missed)

func _spawn_item() -> void:
	var it := model(ITEMS.pick_random(), Vector3(1.8, BELT_Y, 0), 1.0, randf() * TAU)
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.16, 0.2, 0.16)
	var c := Interactable.wrap(it, shape)
	c.clicked.connect(_on_item)
	items.append(c)

func _on_item(c: Interactable) -> void:
	c.enabled = false
	items.erase(c)
	add_score(1)
	Sfx.play(get_tree(), "ding")
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(c, "scale", Vector3.ONE * 0.01, 0.2)
	tw.tween_property(c, "position:y", c.position.y + 0.25, 0.2)
	tw.chain().tween_callback(c.queue_free)
