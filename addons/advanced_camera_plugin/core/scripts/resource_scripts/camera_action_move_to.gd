@tool
## [CameraAction] Extension class used to move the camera to a new target or change the current target
class_name CameraActionMoveTo extends CameraAction

const ADVANCED_CAMERA_ICON = preload("res://addons/advanced_camera_plugin/icons/advanced_camera_icon.png")

## Method of moving to target
enum MOVE_BY{
	## Camera will temporarily tween to the target before returning to the default target
	TWEEN,
	## Camera will use this new node as the target for the camera
	CHANGE_TARGET,
}
## Bool determines if the action must be complete before the next action attemps to execute
@export var await_complete:bool = true
## Enum member for MOVE_BY type [enum MOVE_BY]
@export var move_by:MOVE_BY = MOVE_BY.TWEEN
@export_group("Tween","twn_")
## If [enum MOVE_BY.TWEEN] this will control the time it takes to reach the target
@export_range(0.0,100.0,0.1) var twn_time_to_reach_target:float = 1.0
## Controls the tween easing type used defaults to [Tween.EaseType.EASE_IN_OUT]
@export var twn_tween_easing:Tween.EaseType = Tween.EaseType.EASE_IN_OUT

func _init() -> void:
	action_function = G_Advanced_Cam.CAMERA_ACTION.MOVE_TO
	icon = ADVANCED_CAMERA_ICON.duplicate()
