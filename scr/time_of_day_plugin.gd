tool
class_name TimeOfDayPlugin extends EditorPlugin

# **** Skydome ****

const _skydome_icon: Texture =\
preload("res://addons/jc.godot3.time-of-day/content/editor/icons/Skydome.svg")

const _skydome_script: Script =\
preload("res://addons/jc.godot3.time-of-day/scr/skydome/tod_skydome.gd")

# **** Clouds ****
const _clouds_panorama_icon: Texture =\
preload("res://addons/jc.godot3.time-of-day/content/editor/icons/Skydome.svg")

const _clouds_panorama_script: Script =\
preload("res://addons/jc.godot3.time-of-day/scr/skydome/tod_clouds_panorama.gd")

const _dynamic_clouds_icon: Texture =\
preload("res://addons/jc.godot3.time-of-day/content/editor/icons/Skydome.svg")

const _dynamic_clouds_script: Script =\
preload("res://addons/jc.godot3.time-of-day/scr/skydome/tod_dynamic_clouds.gd")

# **** Time Of Day Manager ****
const _tod_manager_icon: Texture =\
preload("res://addons/jc.godot3.time-of-day/content/editor/icons/Skydome.svg")

const _tod_manager_script: Script =\
preload("res://addons/jc.godot3.time-of-day/scr/time-of-day/tod_manager.gd")

func _enter_tree() -> void:
	add_custom_type("TOD_Skydome", "Spatial", _skydome_script, _skydome_icon)
	add_custom_type("TOD_CloudsPanorama", "Spatial", _clouds_panorama_script, _clouds_panorama_icon)
	add_custom_type("TOD_DynamicClouds", "Spatial", _dynamic_clouds_script, _dynamic_clouds_icon)
	add_custom_type("TOD_Manager", "Node", _tod_manager_script, _tod_manager_icon)

func _exit_tree() -> void:
	remove_custom_type("TOD_Skydome")
	remove_custom_type("TOD_CloudsPanorama")
	remove_custom_type("TOD_DynamicClouds")
	remove_custom_type("TOD_Manager")
