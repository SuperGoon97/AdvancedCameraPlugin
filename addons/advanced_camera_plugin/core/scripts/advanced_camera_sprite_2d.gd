@tool
## [Sprite2D] extension class that is specialised for displaying [CameraAction] infomation
class_name AdvancedCameraTargetSprite2D extends Sprite2D
## Base scale for the sprite
var base_scale:Vector2 = Vector2(0.5,0.5)
## Viewport reference used to calculate the current zoom in the editor
var viewport:Viewport = null

## Icon setter
func set_icon(icon:CompressedTexture2D):
	texture = icon
## Visibility setter
func set_visibilty(state:bool):
	visible = state
## Color Setter
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

## Updates the scale of the sprite every process frame whilst in the editor
func update_scale():
	if viewport == null:
		viewport = get_viewport()
	var viewport_scale = viewport.get_final_transform().x.x
	scale = Vector2(clampf(base_scale.x * (1.0/viewport_scale),0.01,2.0),clampf(base_scale.y * (1.0/viewport_scale),0.01,2.0))
