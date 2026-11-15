class_name Sfx

static var _players := {}

static func _tone(freq: float, dur: float, vol := 0.25, slide_to := 0.0) -> AudioStreamWAV:
	var rate := 22050
	var n := int(rate * dur)
	var data := PackedByteArray()
	data.resize(n * 2)
	var phase := 0.0
	for i in n:
		var t := float(i) / rate
		var f := freq if slide_to <= 0.0 else lerpf(freq, slide_to, t / dur)
		phase += TAU * f / rate
		var s := sin(phase) * vol * (1.0 - t / dur)
		var v := int(clampf(s, -1.0, 1.0) * 32767.0)
		data[i * 2] = v & 0xff
		data[i * 2 + 1] = (v >> 8) & 0xff
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = rate
	w.data = data
	return w

static func play(tree: SceneTree, kind: String) -> void:
	if tree == null:
		return
	var stream: AudioStreamWAV
	match kind:
		"ding":
			stream = _tone(880.0, 0.12, 0.25, 1320.0)
		"click":
			stream = _tone(420.0, 0.06, 0.2)
		"error":
			stream = _tone(160.0, 0.25, 0.3, 110.0)
		"stamp":
			stream = _tone(240.0, 0.09, 0.35, 120.0)
		"serve":
			stream = _tone(660.0, 0.15, 0.25, 990.0)
		_:
			return
	var p: AudioStreamPlayer = _players.get(tree)
	if p == null or not is_instance_valid(p):
		p = AudioStreamPlayer.new()
		_players[tree] = p
		tree.root.add_child(p)
	p.stream = stream
	p.play()
