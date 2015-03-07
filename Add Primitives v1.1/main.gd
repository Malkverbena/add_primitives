tool
extends EditorPlugin

var module_3d
var module_2d

#Utilites
func get_plugins_folder():
	var path = OS.get_data_dir()
	path = path.substr(0, path.find_last('/'))
	path = path.substr(0, path.find_last('/'))
	return path + "/plugins"
	
func _init():
	print("PLUGIN INIT")

func _enter_tree():
	var dir = Directory.new()
	
	var path = get_plugins_folder() + '/Add Primitives v1.1'
	
	if dir.dir_exists(path + '/3d'):
		if dir.file_exists(path + '/3d/module_3d.gd'):
			#register 3d module
			module_3d = weakref(load(path + '/3d/module_3d.gd').new())
			module_3d.get_ref().set_name('module_3d')
			
			if not module_3d.get_ref().is_inside_tree():
				add_child(module_3d.get_ref())
				
func _exit_tree():
	module_3d.get_ref()._end()