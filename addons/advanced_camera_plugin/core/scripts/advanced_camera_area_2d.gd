@tool
## Area2D extension class specialised for executing [AdvancedCameraTarget] 
class_name AdvancedCameraArea2D extends Area2D

## Creates a new camera target that is a child of this area
@export_tool_button("Create Area Target","Callable") var create_target_action = create_target
## Destroys the last camera target in the [member area_targets]
@export_tool_button("Remove Last Area Target","Callable") var remove_last_target_action = remove_last_target

@export_category("AreaDefaults")
## Bool controls if the area is turned off permanently after overlap
@export var is_one_shot:bool = false
## Array holds all other [AdvancedCameraArea2D] that will be turned on after this one has been overlapped
@export var other_area_active_state:Array[AdvancedCameraArea2D]
## [color=red]VERY IMPORTANT BOOL[/color] Ensure this is only turned on for the players [AdvancedCameraArea2D]
@export var is_player_area:bool = false
## Bool controls if this area is active on _ready
@export var is_active_on_start:bool = true:
	set(value):
		is_active_on_start = value
		set_is_active(value)
## Bool controls if the area will become inactive after overlap
@export var deactivate_after_overlap:bool = true
## Array holds all camera targets that will be executed by this area upon overlap, note that targets not created by this area can also be executed by adding them to this array
@export var area_targets:Array[AdvancedCameraTarget]
## Private property used for one_shot logic
var _has_activated = false
## Time taken in seconds to become active after [method AdvancedCameraArea2D.set_is_active] is called
var activation_time:float = 1.0

func _ready() -> void:
	setup_build_lines()
	if !area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

## Creates a new target for the [memeber AdvancedCameraArea2D.area_targets]
func create_target():
	var new_target:AdvancedCameraTarget = AdvancedCameraTarget.new()
	add_child(new_target)
	new_target.name = "AdvancedCameraTarget %s" % area_targets.size()
	if area_targets.size() > 0:
		new_target.target_parent = area_targets.back()
	else:
		new_target.target_parent = self
	new_target.set_owner(get_tree().edited_scene_root)
	area_targets.push_back(new_target)
	setup_build_lines()

## Removes the last target from the [memeber AdvancedCameraArea2D.area_targets]
func remove_last_target():
	var last_area_target = area_targets.pop_back()
	if last_area_target:
		last_area_target.queue_free()

## Sets up lines that are used in editor, [u]Note the lines really dont work as intended at the moment[/u]
func setup_build_lines():
	for target in area_targets:
		target.setup()

## Controls logic on what happens when player area enters this area
func _on_area_entered(area: Area2D) -> void:
	if is_player_area: return
	if _has_activated == false:
		var advanced_camera_area_2d := area as AdvancedCameraArea2D
		if advanced_camera_area_2d and area.is_player_area:
			if area_targets.size() > 0:
				await execute_camera_area_targets()
				set_other_tarets_active()
		if is_one_shot:
			_has_activated = true
		if deactivate_after_overlap:
			set_is_active(false)

## Executes all camera actions within [memeber AdvancedCameraArea2D.area_targets]
func execute_camera_area_targets():
	for target in area_targets:
		target.execute_actions()
		await target.all_actions_complete

## Makes the area monitoring and monitorable for collisions, this uses the [member AdvancedCameraArea2D.activation_time] when in game
func set_is_active(state:bool):
	if state == true:
		if !Engine.is_editor_hint():
			if is_node_ready():
				await get_tree().create_timer(activation_time).timeout
				set_deferred("monitoring",state)
				set_deferred("monitorable",state)
		else:
			set_deferred("monitoring",state)
			set_deferred("monitorable",state)
	else:
		set_deferred("monitoring",state)
		set_deferred("monitorable",state)

## Sets targets in [member AdvancedCameraArea2D.other_area_active_state] to active
func set_other_tarets_active():
	for area in other_area_active_state:
		area.set_is_active(true)
