extends JobBase

const SLOTS := [
	Vector3(-0.45, 1.16, -0.2), Vector3(0, 1.16, -0.2), Vector3(0.45, 1.16, -0.2),
	Vector3(-0.45, 1.16, 0.35), Vector3(0, 1.16, 0.35), Vector3(0.45, 1.16, 0.35),
]
const RAW_COLOR := Color(0.85, 0.35, 0.3)
const DONE_COLOR := Color(0.4, 0.22, 0.1)
const BURNT_COLOR := Color(0.08, 0.06, 0.05)
const COOK_TIME := 6.0
const BURN_TIME := 4.0

var patties := {}
var spawn_timer := 0.0

func build() -> void:
	table(Vector3(0, 0.5, 0), Vector3(2.4, 1.0, 1.6))
	model("res://assets/models/grill.glb", Vector3(0, 1.0, 0.08))
	model("res://assets/models/plate.glb", Vector3(1.15, 1.02, 0.4))
	model("res://assets/models/spatula.glb", Vector3(-1.0, 1.03, 0.3), 1.0, 0.6)

func info_text() -> String:
	return "Click a browned patty to serve it. Burnt patties go in the trash."

func tick(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = randf_range(1.4, 2.6)
		_spawn_patty()
	for slot in patties.keys():
		var p: Interactable = patties[slot]
		var d: Dictionary = p.data
		d.t += delta
		if d.state == 0 and d.t >= COOK_TIME:
			d.state = 1
			d.t = 0.0
			tint(p, DONE_COLOR)
		elif d.state == 1 and d.t >= BURN_TIME:
			d.state = 2
			tint(p, BURNT_COLOR)

func _spawn_patty() -> void:
	var free_slots := []
	for i in SLOTS.size():
		if not patties.has(i):
			free_slots.append(i)
	if free_slots.is_empty():
		return
	var slot: int = free_slots.pick_random()
	var p := model("res://assets/models/patty.glb", SLOTS[slot])
	tint(p, RAW_COLOR)
	var shape := CylinderShape3D.new()
	shape.radius = 0.11
	shape.height = 0.08
	var c := Interactable.wrap(p, shape)
	c.data = {"t": 0.0, "state": 0, "slot": slot}
	c.clicked.connect(_on_patty)
	patties[slot] = c

func _on_patty(p: Interactable) -> void:
	var d: Dictionary = p.data
	p.enabled = false
	patties.erase(d.slot)
	match d.state:
		0:
			p.enabled = true
			patties[d.slot] = p
			return
		1:
			add_score(1)
			Sfx.play(get_tree(), "serve")
			var tw := create_tween()
			tw.tween_property(p, "global_position", Vector3(1.15, 1.35, 0.4), 0.25)
			tw.tween_callback(p.queue_free)
		2:
			add_score(-1)
			Sfx.play(get_tree(), "error")
			var tw := create_tween()
			tw.tween_property(p, "global_position", p.global_position + Vector3(-0.8, -0.6, 0.4), 0.3)
			tw.tween_callback(p.queue_free)
