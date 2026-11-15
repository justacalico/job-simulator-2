extends SceneTree

const PATHS := [
	["grill", "res://scripts/jobs/grill_job.gd"],
	["office", "res://scripts/jobs/office_job.gd"],
	["mechanic", "res://scripts/jobs/mechanic_job.gd"],
	["cashier", "res://scripts/jobs/cashier_job.gd"],
]

var idx := -1
var job: Node3D
var job_frames := 0
var clicks := 0

func _initialize() -> void:
	process_frame.connect(_tick)

func _next() -> bool:
	idx += 1
	if idx >= PATHS.size():
		return false
	job = load(PATHS[idx][1]).new()
	root.add_child(job)
	job.start(PATHS[idx][0])
	job_frames = 0
	clicks = 0
	return true

func _tick() -> void:
	if job == null:
		if not _next():
			return
	job_frames += 1
	if job_frames % 25 == 0:
		for c in job.find_children("*", "Interactable", true, false):
			if c.enabled:
				c.clicked.emit(c)
				clicks += 1
	if job_frames > 400:
		print("job ", PATHS[idx][0], " score=", job.score, " clicks=", clicks)
		job.queue_free()
		job = null
		if not _next():
			print("smoke ok")
			quit()
