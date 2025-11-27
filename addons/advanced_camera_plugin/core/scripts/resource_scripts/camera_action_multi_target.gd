@tool 
## [CameraAction] Extension class used to add or remove targets from the camera multi target array
class_name CameraActionMultiTarget extends CameraAction

const ADVANCED_CAMERA_MULTI_ICON = preload("res://addons/advanced_camera_plugin/icons/advanced_camera_multi_icon.png")

## Type of multi target camera action this is
enum MULTI_TARGET_MODE{
	## Adds this target to current camera multi targets
	ADD,
	## Removes this target from the camera multi targets
	REMOVE,
}

## Changes if multi target mode should be used by the camera
@export var camera_use_multi_target:bool = true
## Changes how the multi target dict is used, see ENUM for uses
@export var multi_target_mode:MULTI_TARGET_MODE = MULTI_TARGET_MODE.ADD
## Multi target dict with Node2D targets and float weights, weights are used to indicate how much pull the target should have on the camera
@export var multi_target_weight : float = 1.0

func _init() -> void:
	action_function = G_Advanced_Cam.CAMERA_ACTION.MULTI_TARGET
	icon = ADVANCED_CAMERA_MULTI_ICON.duplicate()
