@tool
## [CameraAction] Extension class used to make the camera change zoom
class_name CameraActionZoom extends CameraAction
## Signal emitted to request zoom change used for [AdvancedCameraTarget]
signal request_zoom_changed()

const ADVANCED_CAMERA_ZOOM_ICON = preload("res://addons/advanced_camera_plugin/icons/advanced_camera_zoom_icon.png")

## Method of zoom
enum ZOOM_TYPE{
	## Camera will tween to the desired zoom
	TWEEN,
	## Camera will be set the desiredd zoom
	SET,
}
## Bool determines if the action must be complete before the next action attemps to execute
@export var await_complete:bool = true
## Desired camera zoom at the end of the action, contains a setter that calls [signal request_zoom_changed]
@export_custom(PROPERTY_HINT_LINK,"") var camera_zoom_at_target:Vector2 = Vector2(1.0,1.0):
	set(value):
		camera_zoom_at_target = value
		request_zoom_changed.emit()
## Member that holds used [enum ZOOM_TYPE]
@export var zoom_type :ZOOM_TYPE = ZOOM_TYPE.TWEEN
## If [enum ZOOM_TYPE.TWEEN] this will control the time it takes to reach desired zoom
@export_range(0.0,10.0,0.1,"or_greater") var time_to_reach_zoom:float = 1.0

func _init() -> void:
	action_function = G_Advanced_Cam.CAMERA_ACTION.ZOOM
	icon = ADVANCED_CAMERA_ZOOM_ICON.duplicate()
