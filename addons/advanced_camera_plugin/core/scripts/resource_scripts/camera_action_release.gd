@tool
class_name CameraActionRelease extends CameraAction

const ADVANCED_CAMERA_ICON = preload("res://addons/advanced_camera_plugin/icons/advanced_camera_icon.png")

func _init() -> void:
	action_function = G_Advanced_Cam.CAMERA_ACTION.RELEASE
	icon = ADVANCED_CAMERA_ICON.duplicate()
	draw_color = Color.CADET_BLUE
