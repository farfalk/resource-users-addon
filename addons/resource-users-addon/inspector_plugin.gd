@tool
extends EditorInspectorPlugin

var users_counter = preload("res://addons/resource-users-addon/users_counter.gd")

func _can_handle(object):
	if object is Resource:
		return true
	else:
		return false

func _parse_begin(object):
	add_property_editor("resource_users", users_counter.new(), false, "Resource Users")
