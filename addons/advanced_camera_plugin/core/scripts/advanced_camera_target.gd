@tool
class_name AdvancedCameraTarget extends Node2D

## Emitted when the camera has arrived this target
@warning_ignore("unused_signal")
signal all_actions_complete

const NEXA_CUSTOM_FONT = preload("res://addons/advanced_camera_plugin/core/fonts/nexa_custom_font.tres")

@export_storage var camera_action_ui:Dictionary[CameraAction,AdvancedCameraTargetSprite2D]

@export var camera_actions:Array[CameraAction]:
	set(value):
		if Engine.is_editor_hint():
			camera_action_ui.clear()
			call_deferred("setup_camera_actions")
		camera_actions = value

## Change this to the parent node of this ACTarget for things like multi target
@export var target_node:Node2D = self
## Toggle if the viewport rect is drawn, only works if a move to action is present
@export var _draw_viewport_rect:bool = true
## Toggle if the bounds rect is drawn, only works if a bounds rect is present
@export var _draw_bounds:bool = true
@export var _draw_color:Color = Color.WHITE:
	set(value):
		_draw_color = value
		if line2d:
			line2d.color = _draw_color

var camera_line:ToolLine2D
var one_over_camera_zoom:Vector2
@export_custom(PROPERTY_HINT_NODE_TYPE,"Node2D",PROPERTY_USAGE_STORAGE) var target_parent:Node2D
var screen_position:Vector2
var half_viewport_x:float
var half_viewport_y:float
var has_zoom_action:bool = false
var zoom_action:CameraActionZoom = null
var zoom:Vector2 = Vector2(1.0,1.0)
var has_bounds_action:bool = false
var bounds_action:CameraActionBounds = null
var packed_array:PackedVector2Array
var line2d:ToolLine2D

func _draw() -> void:
	if Engine.is_editor_hint():
		if _draw_viewport_rect && has_zoom_action:
			draw_viewport_rect()
		if _draw_bounds && has_bounds_action:
			draw_camera_bounds_rect()

## Draws the area the viewport will use, also draws the text above the box
func draw_viewport_rect():
	if !half_viewport_x:
		half_viewport_x = (ProjectSettings.get_setting("display/window/size/viewport_width"))/2.0
		half_viewport_y = (ProjectSettings.get_setting("display/window/size/viewport_height"))/2.0
	
	if !one_over_camera_zoom:
		update_action_zoom()
	
	var dx = Vector2(half_viewport_x*one_over_camera_zoom.x,half_viewport_y*one_over_camera_zoom.y)
	var dxx = Vector2(-half_viewport_x*one_over_camera_zoom.x,half_viewport_y*one_over_camera_zoom.y)
	var dy = Vector2(half_viewport_x*one_over_camera_zoom.x,-half_viewport_y*one_over_camera_zoom.y)
	var dyy = Vector2(-half_viewport_x*one_over_camera_zoom.x,-half_viewport_y*one_over_camera_zoom.y)

	draw_line(dx,dy,_draw_color)
	draw_line(dxx,dyy,_draw_color)
	draw_line(dxx,dx,_draw_color)
	draw_line(dyy,dy,_draw_color)
	
	draw_string(NEXA_CUSTOM_FONT,Vector2(-75.0,(-(half_viewport_y*1.01)*one_over_camera_zoom.y)),"VIEWPORT SIZE")

## Draws the bounds area
func draw_camera_bounds_rect():
	if packed_array.is_empty():
		update_packed_bound_array()
	draw_line(packed_array[0],packed_array[1],_draw_color)
	draw_line(packed_array[2],packed_array[3],_draw_color)
	draw_line(packed_array[2],packed_array[0],_draw_color)
	draw_line(packed_array[3],packed_array[1],_draw_color)

## Creates the tool line 2d and adds it as a child (could also use a viewport draw instead)
func setup():
	camera_line = ToolLine2D.new()
	add_child(camera_line)
	line2d = camera_line
	line2d.color = _draw_color
	camera_line.width = 2.0
	camera_line.global_position = Vector2(0,0)
	camera_line.add_point(global_position,0)
	camera_line.add_point(target_parent.global_position,1)

func setup_camera_actions():
	has_zoom_action = false
	has_bounds_action = false
	var n: int = camera_actions.size()
	var spacing:float = 100.0
	var i:int = 0
	for action in camera_actions:
		if action == null: continue
		if action.action_function == G_Advanced_Cam.CAMERA_ACTION.ZOOM:
			has_zoom_action = true
			zoom_action = action
			if !zoom_action.request_zoom_changed.is_connected(update_action_zoom):
				zoom_action.request_zoom_changed.connect(update_action_zoom)
		if action.action_function == G_Advanced_Cam.CAMERA_ACTION.STAY_IN_AREA:
			has_bounds_action = true
			bounds_action = action
			if !bounds_action.request_bounds_changed.is_connected(update_packed_bound_array):
				bounds_action.request_bounds_changed.connect(update_packed_bound_array)

		var new_acsprite2d:AdvancedCameraTargetSprite2D = AdvancedCameraTargetSprite2D.new()
		add_child(new_acsprite2d)
		new_acsprite2d.name = action.get_script().get_global_name()
		new_acsprite2d.position = Vector2(spacing * (1.0 - n / 2.0 + i),0.0)
		action.request_icon.connect(new_acsprite2d.set_icon)
		action.request_icon_visibility_change.connect(new_acsprite2d.set_visibilty)
		action.request_color_change.connect(new_acsprite2d.set_color)
		
		camera_action_ui[action] = new_acsprite2d
		action.setup()
		i += 1
	
	var t_children = get_children()
	var ui_values = camera_action_ui.values()
	for t in t_children:
		if t is AdvancedCameraTargetSprite2D:
			if !ui_values.has(t):
				clear_camera_actiun_ui(t)

func clear_camera_actiun_ui(acsprite:AdvancedCameraTargetSprite2D):
	await get_tree().create_timer(1.0).timeout
	acsprite.queue_free()

func execute_actions():
	for action in camera_actions:
		if action.pre_wait > 0.0:
			await get_tree().create_timer(action.pre_wait).timeout
		G_Advanced_Cam.camera_action_lock_player.emit(action.lock_player)
		match action.action_function:
			G_Advanced_Cam.CAMERA_ACTION.MOVE_TO:
				G_Advanced_Cam._move_to(target_node,action)
			G_Advanced_Cam.CAMERA_ACTION.SHAKE:
				G_Advanced_Cam._shake(action)
			G_Advanced_Cam.CAMERA_ACTION.RELEASE:
				G_Advanced_Cam.set_camera_to_default()
			G_Advanced_Cam.CAMERA_ACTION.MULTI_TARGET:
				G_Advanced_Cam._multi_target(target_node,action)
			G_Advanced_Cam.CAMERA_ACTION.ZOOM:
				G_Advanced_Cam._zoom(action)
			G_Advanced_Cam.CAMERA_ACTION.STAY_IN_AREA:
				G_Advanced_Cam._stay_in_area(target_node,action)
			G_Advanced_Cam.CAMERA_ACTION.CLEAR_CAMERA_MULTI:
				G_Advanced_Cam._clear_camera_multi_targets()
			_:
				pass
		await G_Advanced_Cam.camera_function_complete
		if action.hold_camera_until_move_camera_on_emitted:
			await G_Advanced_Cam.move_camera_on
		if action.post_wait > 0.0:
			await get_tree().create_timer(action.post_wait).timeout
		
	G_Advanced_Cam.camera_can_move_to_target.emit(true)
	all_actions_complete.emit()

func update_action_icon(cam_action:CameraAction,_icon:CompressedTexture2D):
	camera_action_ui[cam_action].icon = _icon

func update_action_icon_visibility(cam_action:CameraAction,state:bool):
	camera_action_ui[cam_action].do_draw_icon = state

func update_action_color(cam_action:CameraAction,_color:Color):
	camera_action_ui[cam_action].draw_color = _color

func update_packed_bound_array():
	packed_array = G_Advanced_Cam.make_global_bounds(Vector2(0.0,0.0),bounds_action.get_bounds())

func update_action_zoom():
	zoom = zoom_action.camera_zoom_at_target
	one_over_camera_zoom = Vector2(1.0/zoom.x,1.0/zoom.y)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		if camera_line:
			if camera_line.points.size() == 2:
				camera_line.global_position = Vector2(0,0)
				camera_line.set_point_position(0,global_position)
				camera_line.set_point_position(1,target_parent.global_position)
