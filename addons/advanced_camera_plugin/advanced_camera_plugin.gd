@tool
extends EditorPlugin

const ADVANCED_CAMERA_ICON = preload("res://addons/advanced_camera_plugin/icons/advanced_camera_icon.png")
const script_path:String = "res://addons/advanced_camera_plugin/core/scripts/"
const resource_path:String = "res://addons/advanced_camera_plugin/core/scripts/resource_scripts/"
const camera_action:String = "CameraAction"


func _enable_plugin() -> void:
	add_autoload_singleton("G_Advanced_Cam","res://addons/advanced_camera_plugin/core/scripts/global_advanced_camera.gd")


func _disable_plugin() -> void:
	remove_autoload_singleton("G_Advanced_Cam")

func _enter_tree() -> void:
	await get_tree().process_frame
	# MainScripts
	add_custom_type("AdvancedCamera2D","Camera2D",preload(script_path + "advanced_camera_2d.gd"),ADVANCED_CAMERA_ICON)
	add_custom_type("AdvancedCameraTarget","Node2D",preload(script_path + "advanced_camera_target.gd"),ADVANCED_CAMERA_ICON)
	add_custom_type("AdvancedCameraSprite2D","Sprite2D",preload(script_path + "advanced_camera_sprite_2d.gd"),ADVANCED_CAMERA_ICON)
	add_custom_type("AdvancedCameraArea2D","Area2D",preload(script_path + "advanced_camera_area_2d.gd"),ADVANCED_CAMERA_ICON)
	# Resources
	add_custom_type(camera_action,"Resource",preload(resource_path + "camera_action.gd"), ADVANCED_CAMERA_ICON)
	add_custom_type(camera_action + "Bounds",camera_action,preload(resource_path + "camera_action_bounds.gd"),preload("res://addons/advanced_camera_plugin/icons/advanced_camera_bounds_icon.png"))
	add_custom_type(camera_action + "ClearMultiTargets",camera_action,preload(resource_path + "camera_action_clear_multi_targets.gd"), preload("res://addons/advanced_camera_plugin/icons/advanced_camera_multi_icon.png"))
	add_custom_type(camera_action + "MoveTo",camera_action,preload(resource_path + "camera_action_move_to.gd"),ADVANCED_CAMERA_ICON)
	add_custom_type(camera_action + "MultiTarget",camera_action,preload(resource_path + "camera_action_multi_target.gd"),preload("res://addons/advanced_camera_plugin/icons/advanced_camera_multi_icon.png"))
	add_custom_type(camera_action + "Release",camera_action,preload(resource_path + "camera_action_release.gd"),ADVANCED_CAMERA_ICON)
	add_custom_type(camera_action + "Shake",camera_action,preload(resource_path + "camera_action_shake.gd"),preload("res://addons/advanced_camera_plugin/icons/advanced_camera_vibrate_icon.png"))
	add_custom_type(camera_action + "Zoom",camera_action,preload(resource_path + "camera_action_zoom.gd"),preload("res://addons/advanced_camera_plugin/icons/advanced_camera_zoom_icon.png"))
	
	#ToolScripts
	add_custom_type("ToolLine2D","Line2D",preload("res://addons/advanced_camera_plugin/core/scripts/tool_line2d.gd"),ADVANCED_CAMERA_ICON)


func _exit_tree() -> void:
	# MainScripts
	remove_custom_type("AdvancedCamera2D")
	remove_custom_type("AdvancedCameraTarget")
	remove_custom_type("AdvancedCameraSprite2D")
	remove_custom_type("AdvancedCameraArea2D")
	# Resources
	remove_custom_type(camera_action)
	remove_custom_type(camera_action + "Bounds")
	remove_custom_type(camera_action + "ClearMultiTargets")
	remove_custom_type(camera_action + "MoveTo")
	remove_custom_type(camera_action + "MultiTarget")
	remove_custom_type(camera_action + "Release")
	remove_custom_type(camera_action + "Shake")
	remove_custom_type(camera_action + "Zoom")
