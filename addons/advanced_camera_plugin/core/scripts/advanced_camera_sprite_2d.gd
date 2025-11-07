@tool
class_name AdvancedCameraTargetSprite2D extends Sprite2D

var base_scale:Vector2 = Vector2(0.5,0.5)
var viewport:Viewport = null


func set_icon(icon:CompressedTexture2D):
	texture = icon

func set_visibilty(state:bool):
	visible = state

func set_color(color:Color):
	self_modulate = color

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_scale()

func _ready() -> void:
	if Engine.is_editor_hint():
		visible = true
		if viewport == null:
			viewport = get_viewport()
		update_scale()
	else:
		visible = false

func update_scale():
	if viewport == null:
		viewport = get_viewport()
	var viewport_scale = viewport.get_final_transform().x.x
	scale = Vector2(clampf(base_scale.x * (1.0/viewport_scale),0.01,2.0),clampf(base_scale.y * (1.0/viewport_scale),0.01,2.0))
