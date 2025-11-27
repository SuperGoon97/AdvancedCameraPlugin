@tool 
## [CameraAction] Extension class used to clear all multi targets then readd the default target
class_name CameraActionClearMultiTargets extends CameraAction

const ADVANCED_CAMERA_MULTI_ICON = preload("res://addons/advanced_camera_plugin/icons/advanced_camera_multi_icon.png")

func _init() -> void:
	action_function = G_Advanced_Cam.CAMERA_ACTION.CLEAR_CAMERA_MULTI
	icon = ADVANCED_CAMERA_MULTI_ICON.duplicate()
	draw_color = Color.ORANGE_RED
