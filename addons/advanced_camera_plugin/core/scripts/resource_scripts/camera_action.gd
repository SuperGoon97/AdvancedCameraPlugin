@tool
## [Resource] extension class that holds base data useful for camera related actions
class_name CameraAction extends Resource
## Signal used by icon setter, tells [AdvancedCameraTarget] to change [AdvancedCameraTargetSprite2D] icon
signal request_icon(_icon:CompressedTexture2D)
## Signal used by visibility setter, tells [AdvancedCameraTarget] to change [AdvancedCameraTargetSprite2D] icon visibility
signal request_icon_visibility_change(state:bool)
## Signal used by color setter, tells [AdvancedCameraTarget] to change [AdvancedCameraTargetSprite2D] color
signal request_color_change(_color:Color)

@export_group("Defaults")
## Time to wait before executing this camera action in seconds
@export_custom(PROPERTY_HINT_RANGE,"0.0,3.0,0.05,or_greater,suffix:s") var pre_wait:float = 0.0
## Time to wait after executing this camera action in seconds
@export_custom(PROPERTY_HINT_RANGE,"0.0,3.0,0.05,or_greater,suffix:s") var post_wait:float = 0.0
## Use this bool to cause the action to emit [signal G_Advanced_Cam.camera_action_lock_player]
@export var lock_player:bool = false
## Hold the camera after this action until the [signal G_Advanced_Cam.move_camera_on] is emitted
@export var hold_camera_until_move_camera_on_emitted : bool = false
## Icon to draw
@export var icon:CompressedTexture2D:
	set(value):
		icon = value
		request_icon.emit(icon)
## Draw the icon
@export var draw_icon:bool = true:
	set(value):
		draw_icon = value
		request_icon_visibility_change.emit(draw_icon)
## Draw Color
@export var draw_color:Color = Color(1.0,1.0,1.0,1.0):
	set(value):
		draw_color = value
		request_color_change.emit(draw_color)

## Private enum used by [G_Advanced_Cam] to determine what to do with the action
var action_function:G_Advanced_Cam.CAMERA_ACTION

## Method is invoked from [AdvancedCameraTarget] on resource creation to give [AdvancedCameraTargetSprite2D] required information
func setup():
	if icon:
		request_icon.emit(icon)
	request_icon_visibility_change.emit(draw_icon)
	request_color_change.emit(draw_color)
