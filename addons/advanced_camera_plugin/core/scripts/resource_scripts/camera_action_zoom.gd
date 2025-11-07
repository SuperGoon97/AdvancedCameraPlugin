@tool
class_name CameraActionZoom extends CameraAction

signal request_zoom_changed()

const ADVANCED_CAMERA_ZOOM_ICON = preload("res://addons/advanced_camera_plugin/icons/advanced_camera_zoom_icon.png")

enum ZOOM_TYPE{
	TWEEN,
	SET,
}
@export var await_complete:bool = true
@export_custom(PROPERTY_HINT_LINK,"") var camera_zoom_at_target:Vector2 = Vector2(1.0,1.0):
	set(value):
		camera_zoom_at_target = value
		request_zoom_changed.emit()
@export var zoom_type :ZOOM_TYPE = ZOOM_TYPE.TWEEN
@export_range(0.0,10.0,0.1,"or_greater") var time_to_reach_zoom:float = 1.0

func _init() -> void:
	action_function = G_Advanced_Cam.CAMERA_ACTION.ZOOM
	icon = ADVANCED_CAMERA_ZOOM_ICON.duplicate()
