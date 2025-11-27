@tool
## Holds alot of Setters and Getters for interfacing with the [AdvancedCamera2D], Go through this class if you want to get the camera to do things safely
extends Node
## Emits when the camera has completed a given task such as movement to a point
signal camera_function_complete
## Call this signal from other classes to get the camera to move on when held indefinitely via [member CameraAction.hold_camera_until_move_camera_on_emitted]
@warning_ignore("unused_signal")
signal move_camera_on
## Signals to the camera that it can move towards its target again
signal camera_can_move_to_target(state:bool)
## Bind to this signal to lock the player when [CameraAction] lock player is used
signal camera_action_lock_player(state:bool)

## Camera follow types
enum FOLLOW_TYPE{
	## Camera follows the target setting its location every physics frame
	SNAP,
	## Camera chases the target increasing in speed the further away it is
	LAG,
}

## Camera action types
enum CAMERA_ACTION{
	## Direcects camera to move to a position
	MOVE_TO,
	## Enforces bounds for the camera that it cannot leave
	STAY_IN_AREA,
	## Allows the camera to look at multiple things at once
	MULTI_TARGET,
	## Directs the camera to shake
	SHAKE,
	## Releases camera to default target
	RELEASE,
	## Zooms the camera to desired size
	ZOOM,
	## Clears the camera multi targets
	CLEAR_CAMERA_MULTI,
}
## SetGet for [member advanced_camera]
var advanced_camera:AdvancedCamera2D:
	set(value):
		if value == null:
			print("error setting advanced camera")
		advanced_camera = value
		camera_can_move_to_target.connect(advanced_camera.camera_can_move_to_target_state)
	get:
		return advanced_camera
## Private [AdvancedCamera2D] member used when @tool needs a reference
var temp_advanced_camera:AdvancedCamera2D


## Sets the camera follow type
func set_camera_follow_type(type:FOLLOW_TYPE):
	if advanced_camera:
		advanced_camera.set("camera_follow_type",type)

## Gets the camera follow type
func get_camera_follow_type():
	if advanced_camera:
		return advanced_camera.get("camera_follow_type")

## Sets the camera speed, only matters for Lag follow type
func set_camera_speed(speed:float):
	if advanced_camera:
		advanced_camera.set("camera_speed",speed)

## Gets the camera speed
func get_camera_speed():
	if advanced_camera:
		return advanced_camera.get("camera_speed")

## Sets the cameras main target
func set_camera_target(target:Node2D):
	if advanced_camera:
		advanced_camera.set("camera_target",target)

## Gets the cameras main target
func get_camera_target():
	if advanced_camera:
		return advanced_camera.get("camera_target")

## Gets the cameras screen transform
func get_camera_screen() -> Transform2D:
	if advanced_camera:
		return advanced_camera.get_screen_transform()
	else:
		return _get_temp_advanced_cam().get_screen_transform()

## Sets the camera_zoom
func set_camera_zoom(value:float):
	if advanced_camera:
		advanced_camera.set("zoom",value)

## Gets the cameras zoom
func get_camera_zoom():
	if advanced_camera:
		return advanced_camera.get("zoom")
	else:
		return _get_temp_advanced_cam().zoom

## Sets camera bound state, if value == true the camera will be bound to the area last set in set_camera_bounds
func set_camera_is_bound(value:bool):
	if advanced_camera:
		advanced_camera.set("_lock_camera_to_camera_bounds",value)

## Gets camera bound state
func get_camera_is_bound() -> bool:
	if advanced_camera:
		return advanced_camera.lock_camera_to_camera_bounds
	else: return false

## Sets the cameras bounds
func set_camera_bounds(bounds:PackedVector2Array):
	if advanced_camera:
		advanced_camera.set("camera_bounds",bounds)

## Gets the camera bounds
func get_camera_bounds():
	if advanced_camera:
		return advanced_camera.camera_bounds
	else: return false

## Sets the camera multi target mode state. value == true will turn multi target on
func set_camera_multi_target_mode(value:bool):
	if advanced_camera:
		advanced_camera.set("camera_use_multi_target",value)

## Gets the camera multi target mode
func get_camera_multi_target_mode() -> bool:
	if advanced_camera:
		return advanced_camera.camera_use_multi_target
	else: return false

## Adds camera multi targets. Note does not allow duplicates
func add_camera_multi_targets(target:Node2D,weight:float):
	if advanced_camera:
		advanced_camera.add_camera_multi_target(target,weight)
## Removes a specific target from the camera multi target dict
func remove_camera_multi_target(target:Node2D):
	if advanced_camera:
		advanced_camera.remove_camera_multi_target(target)

## Gets the camera shake indefinitely state on the camera
func get_camera_shake_indefinitely() -> bool:
	if advanced_camera:
		return advanced_camera.camera_shake_indefinitely
	else: return false

## Sets the camera shake indefinitely state on the camera
func set_camera_shake_indefinitely(value:bool):
	if advanced_camera:
		advanced_camera.set("camera_shake_indefinitely",value)

## Tweens the camera to target
func tween_camera_to_target(target:Node2D,time_to_reach_target:float = 0.5,tween_easing:Tween.EaseType = Tween.EaseType.EASE_IN):
	if advanced_camera:
		advanced_camera.call("tween_to_target",target,time_to_reach_target,tween_easing)

## Shakes the camera
func shake_camera(strength:float = 2.0,strength_pow:float = 2.0,decay_rate:float = 0.5,shake_x:bool = true ,shake_y:bool = true,camera_shake_indef:bool = false,add_strength = true):
	if advanced_camera:
		advanced_camera.call("add_camera_shake",strength,strength_pow,decay_rate,shake_x,shake_y,camera_shake_indef,add_strength)

## Sets the camera back to default settings and target. Also kills any active tweens
func set_camera_to_default():
	if advanced_camera:
		advanced_camera.call("camera_to_default")
		camera_function_complete.emit()

## Forces the camera to a Vector2 position, camera will not stay there
func force_camera_to_vector(vec:Vector2):
	if advanced_camera:
		advanced_camera.call("force_to_vector",vec)

## Converts bounds local space to global space 
func make_global_bounds(g_pos:Vector2,bounds:PackedVector2Array) -> PackedVector2Array:
	var return_packed_array:PackedVector2Array
	for vector in bounds:
		var global_vec = Vector2(vector.x + g_pos.x,vector.y + g_pos.y)
		return_packed_array.append(global_vec)
	return_packed_array.append(g_pos)
	return return_packed_array

## Gets the closest point with bounds to the target [Node2D]
func get_closest_point_within_bounds(target:Node2D,action:CameraActionBounds) -> PackedVector2Array:
	var cam_pos = get_camera_target().global_position
	var g_bounds:PackedVector2Array = make_global_bounds(target.global_position,action.get_bounds())
	var vec1:Vector2 = Vector2(0.0,0.0)
	var vec2:Vector2 = Vector2(0.0,0.0)
	if cam_pos.x < g_bounds[2].x:
		vec1 = g_bounds[2]
		vec2 = g_bounds[3]
	elif cam_pos.x > g_bounds[0].x:
		vec1 = g_bounds[0]
		vec2 = g_bounds[1]
	elif cam_pos.y > g_bounds[1].y:
		vec1 = g_bounds[1]
		vec2 = g_bounds[3]
	elif cam_pos.y < g_bounds[0].y:
		vec1 = g_bounds[2]
		vec2 = g_bounds[0]
	var intersect_point:PackedVector2Array = Geometry2D.get_closest_points_between_segments(vec1,vec2,cam_pos,target.global_position)
	return intersect_point

## Gets advanced cam for use in @tool scripts
func _get_temp_advanced_cam():
	return get_tree().get_first_node_in_group("AdvancedCamera2D")

## Camera target move to logic
func _move_to(target:Node2D,action:CameraActionMoveTo):
	match action.move_by:
		action.MOVE_BY.TWEEN:
			camera_can_move_to_target.emit(false)
			tween_camera_to_target(target,action.twn_time_to_reach_target,action.twn_tween_easing)
		action.MOVE_BY.CHANGE_TARGET:
			camera_can_move_to_target.emit(true)
			set_camera_target(target)
	if action.await_complete:
		await advanced_camera.camera_arrived_at_target
	camera_function_complete.emit()

## Camera target stay in area logic
func _stay_in_area(target:Node2D,action:CameraActionBounds):
	set_camera_bounds(make_global_bounds(target.global_position,action.get_bounds()))
	set_camera_is_bound(action.bind_camera)
	var intersection_point = get_closest_point_within_bounds(target,action)
	match action.move_camera_to_closest_point:
		action.CLOSEST_POINT_TYPE.NONE:
			pass
		action.CLOSEST_POINT_TYPE.SNAP:
			force_camera_to_vector(intersection_point[0])
		action.CLOSEST_POINT_TYPE.TWEEN:
			advanced_camera.tween_to_target_position(intersection_point[0],action.twn_time_to_reach_target,action.twn_tween_easing)
			if action.await_complete:
				await advanced_camera.camera_arrived_at_pos
	camera_can_move_to_target.emit(true)
	await get_tree().process_frame
	camera_function_complete.emit()

## Camera target multi target logic
func _multi_target(target:Node2D,action:CameraActionMultiTarget):
	set_camera_multi_target_mode(action.camera_use_multi_target)
	match action.multi_target_mode:
		action.MULTI_TARGET_MODE.ADD:
			add_camera_multi_targets(target, action.multi_target_weight)
		action.MULTI_TARGET_MODE.REMOVE:
			remove_camera_multi_target(target)
	await get_tree().process_frame
	camera_function_complete.emit()

## Camera target shake logic 
func _shake(action:CameraActionShake):
	if action.stop_shake:
		set_camera_shake_indefinitely(false)
		return
	match action.shake_mode:
		action.SHAKE_MODE.ADD:
			shake_camera(action.strength,action.strength_power,action.decay,action.shake_x,action.shake_y,action.shake_indefinitely,true)
		action.SHAKE_MODE.SET:
			shake_camera(action.strength,action.strength_power,action.decay,action.shake_x,action.shake_y,action.shake_indefinitely,false)
	await get_tree().process_frame
	camera_function_complete.emit()

## Calls the camera change zoom method
func _zoom(action:CameraActionZoom):
	advanced_camera.change_camera_zoom(action.camera_zoom_at_target,action.zoom_type,action.time_to_reach_zoom)
	if action.await_complete:
		await advanced_camera.camera_zoom_change_complete
	camera_function_complete.emit.call_deferred()

## Clears the cameras multi targets, readds the default target
func _clear_camera_multi_targets():
	advanced_camera.clear_camera_multi_targets()
	await get_tree().process_frame
	camera_function_complete.emit()
