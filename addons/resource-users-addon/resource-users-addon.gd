@tool
extends EditorPlugin


# A class member to hold the dock during the plugin life cycle.
#var dock
var inspector


func _enter_tree():
	# Initialization of the plugin goes here.
	inspector = preload("res://addons/resource-users-addon/inspector_plugin.gd").new()
	add_inspector_plugin(inspector)


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_inspector_plugin(inspector)
