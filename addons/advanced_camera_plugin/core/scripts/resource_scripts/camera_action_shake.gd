@tool
## [CameraAction] Extension class used to shake shake shake
class_name CameraActionShake extends CameraAction

const ADVANCED_CAMERA_VIBRATE_ICON = preload("res://addons/advanced_camera_plugin/icons/advanced_camera_vibrate_icon.png")

## Method of shake
enum SHAKE_MODE{
	## Adds strength to the current camera shake strength
	ADD,
	## Sets the cameras shake strength
	SET,
}
## Bool will cause an indefinite shake to stop if currently active
@export var stop_shake:bool = false
## Amplitude is the base for the shake
@export_range(0.0,100.0,1.0,"or_greater") var amplitude:float = 40.0
## Changes if strength will be added or set, adding strength can get very shakey very quickly. Note all other properties are treat as set
@export var shake_mode:SHAKE_MODE = SHAKE_MODE.SET
## Strength is the multiplier for the amplitude, it decays as the shake progresses
@export_range(1.0,10.0,0.1,"or_greater") var strength:float = 1.0
## Strength power is the amount strengh is pow() by
## [codeblock]
## func _foo() -> float:
##     var strength:float = 1.0
##     var strength_pow:float = 2.0
##     return pow(strength,strength_pow)
@export_range(1.0,4.0,0.1,"or_greater") var strength_power:float = 2.0
## Decay changes the amount strength is decreased by, higher decay means the camera will come to a stop quicker. If you want the camera to shake indefintely use the "shake indefinitely" bool
@export_range(0.1,10.0,0.1,"or_less","or_greater") var decay:float = 0.5
## Changes if the shake will move the camera on the x axis
@export var shake_x:bool = true
## Changes if the shake will move the camera on the y axis
@export var shake_y:bool = true
## Makes it so the strength will never decay until stop shake is used
@export var shake_indefinitely:bool = false

func _init() -> void:
	action_function = G_Advanced_Cam.CAMERA_ACTION.SHAKE
	icon = ADVANCED_CAMERA_VIBRATE_ICON.duplicate()
