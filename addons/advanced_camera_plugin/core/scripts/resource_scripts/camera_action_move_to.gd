@tool
class_name CameraActionMoveTo extends CameraAction

const ADVANCED_CAMERA_ICON = preload("res://addons/advanced_camera_plugin/icons/advanced_camera_icon.png")

enum MOVE_BY{
	TWEEN,
	CHANGE_TARGET,
}
@export var await_complete:bool = true
@export var move_by:MOVE_BY = MOVE_BY.TWEEN
@export_group("Tween","twn_")
@export_range(0.0,100.0,0.1) var twn_time_to_reach_target:float = 1.0
@export var twn_tween_easing:Tween.EaseType = Tween.EaseType.EASE_IN_OUT

func _init() -> void:
	action_function = G_Advanced_Cam.CAMERA_ACTION.MOVE_TO
	icon = ADVANCED_CAMERA_ICON.duplicate()
