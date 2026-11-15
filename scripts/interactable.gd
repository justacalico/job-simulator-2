class_name Interactable
extends StaticBody3D

signal clicked(who: Interactable)

var enabled := true
var data: Variant = null

func _init(shape: Shape3D = null) -> void:
	if shape != null:
		var col := CollisionShape3D.new()
		col.shape = shape
		add_child(col)

func _ready() -> void:
	input_event.connect(_on_input)

func _on_input(_cam: Camera3D, event: InputEvent, _pos: Vector3, _n: Vector3, _idx: int) -> void:
	if not enabled:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)

static func wrap(node: Node3D, shape: Shape3D) -> Interactable:
	var area := Interactable.new(shape)
	var parent := node.get_parent()
	var pos := node.position
	if parent != null:
		parent.remove_child(node)
		parent.add_child(area)
	area.add_child(node)
	node.position = Vector3.ZERO
	area.position = pos
	return area
