extends Node

const JOBS := {
	"grill": {"title": "Grill Master", "desc": "Flip patties before they burn.", "rate": 6},
	"office": {"title": "Paper Pusher", "desc": "Stamp what deserves stamping.", "rate": 4},
	"mechanic": {"title": "Wrench Turner", "desc": "Tighten every bolt on the block.", "rate": 30},
	"cashier": {"title": "Checkout Champ", "desc": "Scan items before they roll off.", "rate": 3},
}

var money := 0
var day := 1
var shifts_done := {}
var best_scores := {}

signal changed

func job_ids() -> Array:
	return JOBS.keys()

func record_shift(job_id: String, score: int) -> int:
	var pay: int = score * JOBS[job_id].rate
	money += pay
	shifts_done[job_id] = shifts_done.get(job_id, 0) + 1
	best_scores[job_id] = maxi(best_scores.get(job_id, 0), score)
	if all_jobs_worked():
		for id in JOBS:
			shifts_done[id] = 0
		day += 1
	changed.emit()
	return pay

func all_jobs_worked() -> bool:
	for id in JOBS:
		if shifts_done.get(id, 0) == 0:
			return false
	return true

func shift_available(job_id: String) -> bool:
	return shifts_done.get(job_id, 0) == 0
