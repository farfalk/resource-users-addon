@tool
extends EditorProperty

const DEBUG_MODE = false

const NEWLY_ADDED = "(newly added, save the scene!)"
const UNIQUE = "UNIQUE"

var property_control: Label = Label.new()
var current_value: String = ""

var _latest_path: String = ""


func _init():
	add_child(property_control)
	_refresh_control_text()
	property_control.modulate = Color.WHITE
	read_only = true


func _process(_delta):
	if get_edited_object():
		var resource_path = get_edited_object().resource_path
		if !resource_path && (current_value != NEWLY_ADDED):
			current_value = NEWLY_ADDED
			_refresh_control_text()
		elif _latest_path != resource_path:
			_update_property()


func _update_property():
	var resource: Resource = get_edited_object()
	var resource_path = resource.resource_path
	if not(resource_path):
		return
	else:
		_latest_path = resource_path
	var current_scene_users = 0
	var global_users = 0
	var nested_users = 0
	if resource_path.contains("tscn::"):
		# local resource (saved in scene)
		var scene_path = resource_path.split("::")[0]
		var resource_id = resource_path.split("::")[1]
		var scene_file = FileAccess.open(scene_path, FileAccess.READ)
		var as_text = scene_file.get_as_text()
		current_scene_users += as_text.count(resource_id)-1  # -1 because it ignores the resource definition
	elif resource_path.contains("tres::"):
		# local sub-resource (saved in resource)
		var main_resource_path = resource_path.split("::")[0]
		var resource_id = resource_path.split("::")[1]
		var scene_file = FileAccess.open(main_resource_path, FileAccess.READ)
		var as_text = scene_file.get_as_text()
		nested_users += as_text.count(resource_id)-1  # -1 because it ignores the resource definition
	else:
		var resource_id = ResourceUID.id_to_text(ResourceLoader.get_resource_uid(resource_path))
		#var all_tscns = _get_all_files("res://", '.tscn')
		#var all_tres = _get_all_files("res://", '.tres')
		#var all_files = all_tscns + all_tres
		var all_files = _get_all_resource_files("res://")
		for file_path in all_files:
			var file = FileAccess.open(file_path, FileAccess.READ)
			var as_text = file.get_as_text()
			var resource_loading_step_index = as_text.find(resource_id)
			var next_square_bracket_subindex = as_text.substr(resource_loading_step_index, 1000).find("]")
			var count = -1  # -1 because it ignores the resource definition
			var split_text = as_text.substr(resource_loading_step_index, next_square_bracket_subindex).split("id=")
			if len(split_text)>1:
				var resource_local_id = split_text[1].lstrip("\"").rstrip("\"")
				count += as_text.count(resource_local_id)
			if count>0:
				_log("found {0} occurrences in {1}".format([count, file_path]))
				if file_path==get_tree().edited_scene_root.scene_file_path:
					# the local scene is one of the scenes that contain the resource!
					current_scene_users += count
				elif file_path.contains('.tres'):
					nested_users += count
				else:
					global_users += count
	var internal_users = current_scene_users+nested_users
	var total_users = global_users+internal_users
	var totals = "{0}".format([total_users])
	var lp = "(" if (internal_users>0) else ""
	var locals = "{0} in current".format([current_scene_users]) if current_scene_users>0 else ""
	var c = ", " if (current_scene_users>0) else ""
	var nested = "{0} nested".format([nested_users]) if nested_users>0 else ""
	var rp = ")" if (internal_users>0) else ""
	if total_users>0:
		if (total_users == 1 && current_scene_users==1) || (total_users == 1 && nested_users==1):
			current_value = UNIQUE
		else:
			current_value = "{0} {1}{2}{3}{4}{5}".format([totals, lp, locals, c, nested, rp])
	else:
		current_value = ""
	_refresh_control_text()


func _refresh_control_text():
	if !current_value:
		return
	_log("REFRESH: {0}".format([current_value]))
	property_control.text = current_value


func _get_all_resource_files(path):
	var resources = Array(ResourceLoader.list_directory(path))
	var dir = DirAccess.open(path)
	if dir:
		for d in dir.get_directories():
			resources += _get_all_resource_files(d)
	var len = len(resources)
	for i in range(1, len+1):
		var res = resources[len-i]
		if res.begins_with(".") || res.ends_with("/"):
			resources.remove_at(len-i)
		else:
			resources[len-i] = path+"/"+res
	return resources


func _log(log_string: String):
	if DEBUG_MODE:
		print_debug("[resource-users-addon] ", log_string)
