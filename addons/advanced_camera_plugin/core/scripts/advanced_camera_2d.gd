class_name AdvancedCamera2D extends Camera2D
## Base class for [AdvancedCamera2D], inherits from [Camera2D] [br]
## Exactly one [AdvancedCamera2D] should be within a scene, may throw an error if one is not present

## Signal used when camera has arrived at a target Node2D
signal camera_arrived_at_target
## Signal used when camera has arrived at a position
signal camera_arrived_at_pos
## Signal used when camera has completed a zoom change
signal camera_zoom_change_complete
## Signal used when camera has completed a camera shake
signal camera_shake_complete

@export_category("CameraDefaults")
## Cameras default target, may throw errors if "null"
@export var camera_default_target:Node2D
## Starting camera follow mode. Possible modes are SNAP,LAG
@export var camera_default_follow_type:G_Advanced_Cam.FOLLOW_TYPE = G_Advanced_Cam.FOLLOW_TYPE.LAG
## Camera default zoom
@export_custom(PROPERTY_HINT_LINK,"") var camera_default_zoom:Vector2 = Vector2(1.0,1.0):
	set(value):
		zoom = value
		camera_default_zoom = value
## Default speed the camera will travel
@export_range(0.0,1000.0,1.0,"or_greater") var camera_default_speed:float = 50.0
## Default "elasticity" of the camera in lag mode
@export_range(1.0,100.0,1.0,"or_greater") var camera_default_lag_elastic:float = 10.0

## Property holds the current camera tween
var current_tween:Tween
## Bool tracks if the camera has been given a movement command
var can_move_to_target:bool = true
## Bool temp tracks if target has changed
var camera_target_changed:bool = false
## Camera distance tolerance, the larger this is the more distance the camera can be from a point before it acknowledges it has arrived
var camera_distance_tolerance:float = 10.0
## Camera use multi target bool
var camera_use_multi_target:bool = false:
	get:
		return camera_use_multi_target
	set(value):
		camera_use_multi_target = value
# Camera shakevariables
## Amplitude is base multiplier for camera offset during shake
var camera_shake_amplitude:float = 40.0:
	get:
		return camera_shake_amplitude
	set(value):
		camera_shake_amplitude = value
## Camera shake strength, this value affects the offset strength alot so keep it small
var camera_shake_strength:float = 0.0
## Power value for camera shake strength
var camera_shake_strength_pow:float = 2.0
## Rate that camera shake is reduced
var camera_shake_decay:float = 0.5:
	get:
		return camera_shake_decay
	set(value):
		camera_shake_decay = value
## How jittery the camera shake is
var camera_shake_noise_speed:float = 5.0
## Progression of y point for sampling noise texture
var camera_shake_noise_y:float = 0.0
## If camera shake should only affect x axis
var camera_shake_x:bool = true
## If camera shake should only affect y axis
var camera_shake_y:bool = true
## Camera shake warm up value between 0.0 - 1.0
var camera_shake_warm_up:float = 0.0
## How quickly camera will reach max shake
var camera_warm_up_rate:float = 10.0
## Bool for changing if shake will be indef
var camera_shake_indefinitely:bool = false
## Lock camera to camera bounds
var _lock_camera_to_camera_bounds:bool = false
## Camera bounds stored as PackedVector2Array [0]NE [1]SE [2]NW [3]SW
var camera_bounds:PackedVector2Array:
	get:
		return camera_bounds
	set(value):
		camera_bounds = value
## Cameras current target
@onready var camera_target:Node2D = camera_default_target:
	get:
		return camera_target
	set(value):
		if camera_target != value:
			camera_target_changed = true
		camera_target = value
## Camera current multi target dictionary
@onready var camera_multi_targets:Dictionary[Node2D,float] = {camera_target:1.0}
## Camera current follow type
@onready var camera_follow_type:G_Advanced_Cam.FOLLOW_TYPE = camera_default_follow_type
## Camera current speed
@onready var camera_speed:float = camera_default_speed
## Camera current elasticity
@onready var camera_lag_elastic:float = camera_default_lag_elastic
## Camera perlin noise
@onready var camera_perlin_noise:FastNoiseLite = FastNoiseLite.new()

func _ready() -> void:
	_ready_checks()

func _physics_process(delta: float) -> void:
	follow_target(delta)
	if camera_shake_strength > 0.0:
		camera_shake_warm_up = min(camera_shake_warm_up + camera_warm_up_rate * delta ,1.0)
		if !camera_shake_indefinitely:
			camera_shake_strength = max(camera_shake_strength - camera_shake_decay * delta,0.0)
		camera_shake_noise_y += camera_shake_noise_speed * (1.0 / (camera_shake_strength+ 0.1))
		_camera_shake()
		if camera_shake_strength == 0.0:
			camera_shake_complete.emit()
			camera_shake_warm_up = 0.0

## Match statement to decide which follow type is in use
func follow_target(delta: float):
	if can_move_to_target == true:
		match camera_follow_type:
			G_Advanced_Cam.FOLLOW_TYPE.SNAP:
				_snap_to_target()
			G_Advanced_Cam.FOLLOW_TYPE.LAG:
				_lag_to_target(delta,camera_speed)

## Snaps camera to camera target
func _snap_to_target():
	if _lock_camera_to_camera_bounds:
		if _check_position_within_bounds(camera_target.global_position):
			global_position = camera_target.global_position
	else:
		global_position = camera_target.global_position

## Camera moves towards camera target
func _lag_to_target(delta:float ,speed_modifier:float = 100.0):
	var direction:Vector2 = _calculate_direction()
	var distance:float = _calculate_distance()
	var rubber_banding:float = distance/camera_lag_elastic
	if _lock_camera_to_camera_bounds:
		var target_distance_to_bounds:float = camera_target.global_position.distance_to(camera_bounds[4])

		if _check_position_within_bounds(global_position +((direction * speed_modifier * rubber_banding) * delta)):
			global_position += (direction * speed_modifier * rubber_banding) * delta
		elif distance > target_distance_to_bounds:
			#print("camera oob next position is closer")
			global_position += (direction * speed_modifier * rubber_banding) * delta
		elif _check_position_within_x_bounds(Vector2(global_position.x +((direction.x * speed_modifier * rubber_banding) * delta),global_position.y)):
			#print("camera oob next x is closer")
			global_position.x += (direction.x * speed_modifier * rubber_banding) * delta
		elif _check_position_within_y_bounds(Vector2(global_position.x,global_position.y+((direction.y * speed_modifier * rubber_banding) * delta))):
			#print("camera oob next y is closer")
			global_position.y += (direction.y * speed_modifier * rubber_banding) * delta
	else:
		global_position += (direction * speed_modifier * rubber_banding) * delta
	if camera_target_changed:
		if global_position.distance_to(camera_target.global_position) < camera_distance_tolerance:
			camera_arrived_at_target.emit(camera_target)
			camera_target_changed = false

## Tweens the camera to target [Node2D], if no target provided to method defaults to camera default target
func tween_to_target(target:Node2D = camera_default_target,time_to_reach_target:float = 0.5,tween_easing_type:Tween.EaseType = Tween.EaseType.EASE_IN): 
	_kill_tween()
	current_tween = get_tree().create_tween()
	var tween_target:Node2D = target
	if !target:
		tween_target = camera_target
	current_tween.set_ease(tween_easing_type)
	current_tween.tween_property(self,"global_position",tween_target.global_position,time_to_reach_target)
	await current_tween.finished
	camera_arrived_at_target.emit(target)

## Tweens the camera to target position [Vector2] 
func tween_to_target_position(pos:Vector2,time_to_reach_target:float = 0.5,tween_easing_type:Tween.EaseType = Tween.EaseType.EASE_IN):
	_kill_tween()
	current_tween = get_tree().create_tween()
	current_tween.set_ease(tween_easing_type)
	current_tween.tween_property(self,"global_position",pos,time_to_reach_target)
	await current_tween.finished
	camera_arrived_at_pos.emit()

## Forces camera to target Node2D
func force_to_target(target:Node2D = camera_target):
	global_position = target.global_position
	camera_arrived_at_target.emit(target)

## Forces camera to target Vector2D
func force_to_vector(vec:Vector2):
	if vec:
		global_position = vec

## Kills any active tween
func _kill_tween():
	if current_tween:
		if current_tween.is_running():
			current_tween.kill()

## Changes state of camera_can_move_to_target
func camera_can_move_to_target_state(state:bool):
	can_move_to_target = state

## Resets camera focusing back on the default target
func camera_to_default():
	camera_target = camera_default_target
	camera_speed = camera_default_speed
	camera_follow_type = camera_default_follow_type
	camera_lag_elastic = camera_default_lag_elastic
	_kill_tween()
	camera_can_move_to_target_state(true)

## Calculates the direction from camera to target
func _calculate_direction() -> Vector2:
	var ret_direction:Vector2
	if !camera_use_multi_target:
		ret_direction = Vector2(camera_target.global_position - global_position).normalized()
	elif camera_use_multi_target:
		ret_direction = Vector2(_calculate_multi_target_point() - global_position).normalized()
	return ret_direction

## Calculates the distance from camera to target
func _calculate_distance(calc_position:Vector2 = global_position) -> float:
	var ret_distance:float
	if !camera_use_multi_target:
		ret_distance = calc_position.distance_to(camera_target.global_position)
	elif camera_use_multi_target:
		ret_distance = calc_position.distance_to(_calculate_multi_target_point())
	return ret_distance

## Simple summ function
func _sum(accum:float, number:float) -> float:
	return accum+number

## calculates the weighted barycentre of the targets in camera_multi_targets
func _calculate_multi_target_point() -> Vector2:
	#print(camera_multi_targets)
	var sum_vec:Vector2 = Vector2(0.0,0.0)
	var ret_vec:Vector2
	var sum_weight:float = camera_multi_targets.values().reduce(_sum,0.0)
	for key in camera_multi_targets:
		sum_vec = Vector2(sum_vec.x + (key.global_position.x * camera_multi_targets[key]),sum_vec.y + (key.global_position.y * camera_multi_targets[key]))
	
	ret_vec = Vector2(sum_vec.x/sum_weight,sum_vec.y/sum_weight)
	return ret_vec
	
## Adds a new target to camera multi target, default weight is 1.0
func add_camera_multi_target(target:Node2D,weight:float = 1.0):
	camera_multi_targets[target] = weight

## Removes specific node from the multi target dict
func remove_camera_multi_target(target:Node2D):
	if camera_multi_targets.has(target):
		camera_multi_targets.erase(target)

## Removes every node from the multi target dict then re adds the current camera target
func clear_camera_multi_targets():
	camera_multi_targets = {camera_target:1.0}

## Adds camera shake, if no arguments will auto shake
func add_camera_shake(strength:float = 2.0,strength_pow:float = 2.0,decay_rate:float = 0.5,shake_x:bool = true ,shake_y:bool = true,camera_shake_indef:bool = false,add_strength:bool = true):
	if add_strength:
		camera_shake_strength += strength
	else:
		camera_shake_strength = strength
	camera_shake_strength_pow = strength_pow
	camera_shake_decay = decay_rate
	camera_shake_x = shake_x
	camera_shake_y = shake_y
	camera_shake_indefinitely = camera_shake_indef

## Changes the camera zoom
func change_camera_zoom(new_zoom:Vector2,zoom_type:CameraActionZoom.ZOOM_TYPE,time_to_reach_zoom:float = 0.5):
	match zoom_type:
		CameraActionZoom.ZOOM_TYPE.SET:
			zoom = new_zoom
		CameraActionZoom.ZOOM_TYPE.TWEEN:
			var zoom_tween:Tween = create_tween()
			zoom_tween.tween_property(self,"zoom",new_zoom,time_to_reach_zoom)
			await zoom_tween.finished
	
	camera_zoom_change_complete.emit.call_deferred()

## Shakes the camera
func _camera_shake():
	var strength = pow(camera_shake_strength,camera_shake_strength_pow)
	if camera_shake_x:
		offset.x = (camera_shake_amplitude * strength * _sample_camera_noise(Vector2(camera_perlin_noise.seed,camera_shake_noise_y))* camera_shake_warm_up)
	if camera_shake_y:
		offset.y = (camera_shake_amplitude * strength * _sample_camera_noise(Vector2(camera_perlin_noise.seed*2.0,camera_shake_noise_y))* camera_shake_warm_up)
	
## Checks if the position is within the cameras y bound
func _check_position_within_y_bounds(pos:Vector2) -> bool:
	if pos.y > camera_bounds[0].y:
		if pos.y < camera_bounds[1].y:
			return true
	return false

## Checks if the position is within the cameras x bound
func _check_position_within_x_bounds(pos:Vector2) -> bool:
	if pos.x < camera_bounds[1].x:
		if pos.x > camera_bounds[2].x:
			return true
	return false

## Checks if the position is withing the cameras bounds
func _check_position_within_bounds(pos:Vector2) -> bool:
	if _check_position_within_x_bounds(pos):
		if _check_position_within_y_bounds(pos):
			return true
	return false

## Sets camera defaults to the current camera settings
func set_camera_defaults_to_current():
	camera_default_target = camera_target
	camera_default_speed = camera_speed
	camera_default_follow_type = camera_follow_type
	camera_default_lag_elastic = camera_lag_elastic
	camera_default_zoom = zoom
	
## Runs all "check" functions
func _ready_checks():
	_check_valid_target()
	_check_multiple_cameras()
	_set_g_advanced_cam_var()
	_setup_camera_noise()

## Creates the camera perlin noise
func _setup_camera_noise():
	camera_perlin_noise.set("noise_type",3)
	camera_perlin_noise.set("seed",randi() % 1000 + 1)

## Returns a value from the camera perlin noise
func _sample_camera_noise(sample_position:Vector2) -> float:
	return camera_perlin_noise.get_noise_2d(sample_position.x,sample_position.y)

## Sets the [member G_Advanced_Cam.advanced_camera] reference
func _set_g_advanced_cam_var():
	G_Advanced_Cam.set("advanced_camera",self)

## Checks the cameras target is valid
func _check_valid_target():
	if !camera_default_target:
		push_warning("No default Node2D set for AdvancedCamera2D")

## Checks if multiple cameras are present in the scene
func _check_multiple_cameras():
	if get_tree().get_nodes_in_group("AdvancedCamera2D").size() > 1:
		push_warning("Multiple AdvancedCamera2D's in scene!")
