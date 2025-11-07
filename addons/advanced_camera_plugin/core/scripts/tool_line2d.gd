@tool
class_name ToolLine2D extends Line2D

func _ready() -> void:
	if Engine.is_editor_hint():
		visible = true
	else:
		visible = false
