@tool
extends EditorInspectorPlugin

var users_counter = preload("res://addons/resource-users-addon/users_counter.gd")

func _can_handle(object):
	if object is Resource:
		return true
	else:
		return false

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name == "resource_local_to_scene":
		add_property_editor(name, users_counter.new(), true, "Resource Users")
	return false
