@tool
class_name CameraActionBounds extends CameraAction

signal request_bounds_changed()

const ADVANCED_CAMERA_BOUNDS_ICON = preload("res://addons/advanced_camera_plugin/icons/advanced_camera_bounds_icon.png")


enum CLOSEST_POINT_TYPE{
	NONE,
	SNAP,
	TWEEN,
}

## Binds the camera to area
@export var bind_camera:bool = false
## Controls the north bound for the camera
@export_range(0.0,100.0,1.0,"or_greater","hide_slider") var north_bound:float = 0.0:
	set(value):
		north_bound = value
		_bounds_changed()
## Controls the south bound for the camera
@export_range(0.0,100.0,1.0,"or_greater","hide_slider") var south_bound:float = 0.0:
	set(value):
		south_bound = value
		_bounds_changed()
## Controls the east bound for the camera
@export_range(0.0,100.0,1.0,"or_greater","hide_slider") var east_bound:float = 0.0:
	set(value):
		east_bound = value
		_bounds_changed()
## Controls the west bound for the camera
@export_range(0.0,100.0,1.0,"or_greater","hide_slider") var west_bound:float = 0.0:
	set(value):
		west_bound = value
		_bounds_changed()
@export var move_camera_to_closest_point:CLOSEST_POINT_TYPE = CLOSEST_POINT_TYPE.NONE
@export var await_complete:bool = true
@export_group("Tween","twn_")
@export var twn_time_to_reach_target:float = 0.5
@export var twn_tween_easing:Tween.EaseType = Tween.EaseType.EASE_IN_OUT

func _init() -> void:
	action_function = G_Advanced_Cam.CAMERA_ACTION.STAY_IN_AREA
	icon = ADVANCED_CAMERA_BOUNDS_ICON.duplicate()

func _bounds_changed():
	request_bounds_changed.emit()

func get_bounds() -> PackedVector2Array:
	return PackedVector2Array([Vector2(east_bound,-north_bound),Vector2(east_bound,south_bound),Vector2(-west_bound,-north_bound),Vector2(-west_bound,south_bound)])
