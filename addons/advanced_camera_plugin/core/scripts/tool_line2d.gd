@tool
class_name ToolLine2D extends Line2D

@export_storage var color:Color:
	set(value):
		color = value
		self_modulate = color
		

func _ready() -> void:
	if Engine.is_editor_hint():
		visible = true
	else:
		visible = false
