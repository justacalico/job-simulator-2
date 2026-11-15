extends Node

const JOB_SCRIPTS := {
	"grill": "res://scripts/jobs/grill_job.gd",
	"office": "res://scripts/jobs/office_job.gd",
	"mechanic": "res://scripts/jobs/mechanic_job.gd",
	"cashier": "res://scripts/jobs/cashier_job.gd",
}

var _screen: Node

func _ready() -> void:
	GameState.changed.connect(_refresh_select)
	_show_menu()

func _swap(node: Node) -> void:
	if _screen != null:
		_screen.queue_free()
	_screen = node
	add_child(node)

func _ui() -> Control:
	var c := Control.new()
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	return c

func _title(text: String, size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

func _show_menu() -> void:
	var ui := _ui()
	var bg := ColorRect.new()
	bg.color = Color(0.07, 0.08, 0.12)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.add_child(bg)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.add_theme_constant_override("separation", 24)
	box.custom_minimum_size = Vector2(420, 0)
	box.position -= Vector2(210, 140)
	ui.add_child(box)

	var t := _title("JOB SIMULATOR 2", 64)
	box.add_child(t)
	var sub := _title("The sequel to working.", 20)
	sub.modulate = Color(0.7, 0.75, 0.85)
	box.add_child(sub)

	var play := Button.new()
	play.text = "Clock In"
	play.add_theme_font_size_override("font_size", 30)
	play.pressed.connect(_show_select)
	box.add_child(play)

	var quit := Button.new()
	quit.text = "Quit"
	quit.add_theme_font_size_override("font_size", 22)
	quit.pressed.connect(func(): get_tree().quit())
	box.add_child(quit)

	_swap(ui)

var _select_box: VBoxContainer

func _show_select() -> void:
	var ui := _ui()
	var bg := ColorRect.new()
	bg.color = Color(0.07, 0.08, 0.12)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.add_child(bg)

	_select_box = VBoxContainer.new()
	_select_box.set_anchors_preset(Control.PRESET_CENTER)
	_select_box.add_theme_constant_override("separation", 14)
	_select_box.custom_minimum_size = Vector2(560, 0)
	_select_box.position -= Vector2(280, 230)
	ui.add_child(_select_box)

	_refresh_select()
	_swap(ui)

func _refresh_select() -> void:
	if _select_box == null or not is_instance_valid(_select_box):
		return
	for ch in _select_box.get_children():
		ch.queue_free()

	var head := _title("Day %d  |  $%d" % [GameState.day, GameState.money], 36)
	_select_box.add_child(head)
	var hint := _title("Pick a shift. Work all four to end the day.", 18)
	hint.modulate = Color(0.7, 0.75, 0.85)
	_select_box.add_child(hint)

	for id in GameState.job_ids():
		var job: Dictionary = GameState.JOBS[id]
		var b := Button.new()
		var best: int = GameState.best_scores.get(id, 0)
		b.text = "%s  -  %s%s" % [job.title, job.desc, "  (best %d)" % best if best > 0 else ""]
		b.add_theme_font_size_override("font_size", 22)
		b.custom_minimum_size = Vector2(0, 56)
		var avail := GameState.shift_available(id)
		b.disabled = not avail
		if not avail:
			b.text = "%s  -  shift done" % job.title
		b.pressed.connect(_start_job.bind(id))
		_select_box.add_child(b)

	var back := Button.new()
	back.text = "Back"
	back.pressed.connect(_show_menu)
	_select_box.add_child(back)

func _start_job(id: String) -> void:
	var job: JobBase = load(JOB_SCRIPTS[id]).new()
	job.finished.connect(_on_job_done.bind(id))
	_swap(job)
	job.start(id)

func _on_job_done(score: int, pay: int, id: String) -> void:
	var job: Dictionary = GameState.JOBS[id]
	var ui := _ui()
	var bg := ColorRect.new()
	bg.color = Color(0.07, 0.08, 0.12)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.add_child(bg)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.add_theme_constant_override("separation", 18)
	box.custom_minimum_size = Vector2(440, 0)
	box.position -= Vector2(220, 120)
	ui.add_child(box)

	box.add_child(_title("Shift over: %s" % job.title, 40))
	box.add_child(_title("Score %d  -  earned $%d" % [score, pay], 26))
	var line := _title("Day %d  |  $%d total" % [GameState.day, GameState.money], 22)
	line.modulate = Color(0.7, 0.75, 0.85)
	box.add_child(line)

	var next := Button.new()
	next.text = "Next shift"
	next.add_theme_font_size_override("font_size", 26)
	next.pressed.connect(_show_select)
	box.add_child(next)

	_swap(ui)
