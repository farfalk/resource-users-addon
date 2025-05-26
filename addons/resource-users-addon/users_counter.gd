@tool
extends EditorProperty


var property_control = Label.new()
var current_value = ""


func _init():
	# Add the control as a direct child of EditorProperty node.
	add_child(property_control)
	refresh_control_text()
	read_only = true


func _update_property():
	var resource: Resource = get_edited_object()
	var resource_path = resource.resource_path
	var local_users = 0
	var global_users = 0
	if resource_path.contains("tscn::"):
		# local resource (saved in scene)
		var scene_path = resource_path.split("::")[0]
		var resource_id = resource_path.split("::")[1]
		var scene_file = FileAccess.open(scene_path, FileAccess.READ)
		var as_text = scene_file.get_as_text()
		local_users += as_text.count(resource_id)-1 # -1 because it ignores the resource definition
	else:
		var resource_id = ResourceUID.id_to_text(ResourceLoader.get_resource_uid(resource_path))
		var all_tscns = get_all_files("res://", '.tscn')
		for scene_path in all_tscns:
			var scene_file = FileAccess.open(scene_path, FileAccess.READ)
			var as_text = scene_file.get_as_text()
			var count = as_text.count(resource_id)
			if count>0:
				if scene_path==get_tree().edited_scene_root.scene_file_path:
					# the local scene is one of the scenes that contain the resource!
					local_users += 1
			global_users += count
	var total_users = local_users+global_users
	var locals = "({0} local)".format([local_users])
	var unique = " - UNIQUE" if total_users==1 else ""
	if total_users>0:
		current_value = "{0} {1} {2}".format([total_users, locals, unique])
	else:
		current_value = ""
	refresh_control_text()

func refresh_control_text():
	property_control.text = current_value


## https://gist.github.com/hiulit/772b8784436898fd7f942750ad99e33e?permalink_comment_id=5196503#gistcomment-5196503
## (with some personal edits)
func get_all_files(path: String, file_ext := "", files : Array[String] = []) -> Array[String]:
	var dir : = DirAccess.open(path)
	if file_ext.begins_with("."): # get rid of starting dot if we used, for example ".tscn" instead of "tscn"
		file_ext = file_ext.substr(1,file_ext.length()-1)
	if DirAccess.get_open_error() == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				# recursion
				files = get_all_files(dir.get_current_dir() +"/"+ file_name, file_ext, files)
			else:
				if file_ext and file_name.get_extension() != file_ext:
					file_name = dir.get_next()
					continue
				if dir.get_current_dir() == "res://":
					files.append(dir.get_current_dir() + file_name)
				else:
					files.append(dir.get_current_dir() +"/"+ file_name)
			file_name = dir.get_next()
	else:
		print("[get_all_files()] An error occurred when trying to access %s." % path)
	return files
