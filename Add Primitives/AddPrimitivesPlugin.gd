#==============================================================================#
# Copyright (c) 2015 Franklin Sobrinho.                                        #
#                                                                              #
# Permission is hereby granted, free of charge, to any person obtaining        #
# a copy of this software and associated documentation files (the "Software"), #
# to deal in the Software without restriction, including without               #
# limitation the rights to use, copy, modify, merge, publish,                  #
# distribute, sublicense, and/or sell copies of the Software, and to           #
# permit persons to whom the Software is furnished to do so, subject to        #
# the following conditions:                                                    #
#                                                                              #
# The above copyright notice and this permission notice shall be               #
# included in all copies or substantial portions of the Software.              #
#                                                                              #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,              #
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF           #
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.       #
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY         #
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,         #
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE            #
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                       #
#==============================================================================#

tool
extends EditorPlugin

class DirectoryUtilities:
	extends Directory
	
	# Get plugin folder path
	func get_data_dir():
		var path
		
		# X11 and OSX
		if OS.has_environment('HOME'):
			path = OS.get_environment('HOME').plus_file('.godot')
			 
		# Windows
		elif OS.has_environment('APPDATA'):
			path = OS.get_environment('APPDATA').plus_file('Godot')
			
		path = path.plus_file('plugins/Add Primitives')
		
		return path
		
	func get_file_list(path, extension = ''):
		var list = []
		
		if dir_exists(path):
			open(path)
			
			list_dir_begin()
			
			var next = get_next()
			
			while next:
				if not current_is_dir():
					if not extension:
						list.push_back(next)
						
					elif next.extension() == extension:
						list.push_back(next)
						
				next = get_next()
				
			list_dir_end()
			
		return list
		
# End DirectoryUtilities

class AddPrimitives:
	extends HBoxContainer
	
	var last_module = ""
	
	var popup_menu
	var mesh_dialog
	
	var node
	var mesh_instance
	
	var builder
	var base_mesh
	
	var primitives = {}
	var modules = {}
	
	# Utilites
	var Dir = DirectoryUtilities.new()
	
	static func module_call(object, method, args=[]):
		if object and object.has_method(method):
			return object.callv(method, args)
			
		return null
		
	func edit(object):
		node = object
		
	func load_modules():
		var path = Dir.get_data_dir().plus_file('modules')
		var mods = Dir.get_file_list(path, 'gd')
		
		for m in mods:
			var temp = load(path.plus_file(m))
			
			if temp.can_instance():
				temp = temp.new(self)
				
				modules[temp.get_name()] = temp
				
	func add_mesh_instance():
		mesh_instance = MeshInstance.new()
		
		var root = get_tree().get_edited_scene_root()
		node.add_child(mesh_instance)
		mesh_instance.set_owner(root)
		
	func remove_mesh_instace():
		if mesh_instance.is_inside_tree():
			mesh_instance.queue_free()
			
	func update_mesh():
		base_mesh = builder.create()
		
		assert( base_mesh != null )
		
		base_mesh.set_name(builder.get_name().to_lower())
		mesh_instance.set_mesh(base_mesh)
		
		var mesh = modify_mesh()
		
		return mesh
		
	func modify_mesh():
		var modifier = mesh_dialog.get_editor("modifiers")
		
		if mesh_instance.get_mesh() != base_mesh:
			mesh_instance.set_mesh(base_mesh)
			
		assert( mesh_instance.get_mesh() )
		
		var mesh = base_mesh.duplicate()
		
		for item in modifier.tree_items():
			if not item.is_checked(1):
				continue
				
			var obj = instance_from_id(item.get_metadata(0))
			
			var aabb = mesh_instance.get_aabb()
			
			mesh = obj.modifier(mesh, aabb)
			mesh_instance.set_mesh(mesh)
			
		return mesh
		
	func _update_mesh():
		var start = OS.get_ticks_msec()
		_display_info(update_mesh(), start)
		
	func _modify_mesh():
		var start = OS.get_ticks_msec()
		_display_info(modify_mesh(), start)
		
	func _display_info(mesh, start = 0):
		var exec_time = OS.get_ticks_msec() - start
		
		var vertex_count = 0
		var face_count = 0
		
		for i in range(mesh.get_surface_count()):
			var surf_v = mesh.surface_get_array_len(i)
			
			vertex_count += surf_v
			
			if mesh.surface_get_format(i) & VS.ARRAY_FORMAT_INDEX:
				face_count += mesh.surface_get_array_index_len(i)/3
				
			else:
				face_count += surf_v/3
				
		var text = "Verts: " + str(vertex_count) + " | Triangles: " + str(face_count) +\
		           "\nGeneration time: " + str(exec_time) + " ms"
		
		mesh_dialog.display_text(text)
		
	func _popup_signal(id, menu):
		popup_menu.hide()
		
		var command = menu.get_item_text(menu.get_item_index(id))
		
		if command == 'Reload':
			_update_menu()
			
		elif command == 'Edit Primitive':
			_edit_primitive()
			
		else:
			_create_primitive(command)
			
	func _update_menu():
		builder = null
		
		popup_menu.clear()
		primitives.clear()
		
		for c in popup_menu.get_children():
			if c extends PopupMenu:
				c.free()
				
		var submenus = {}
		
		var path = Dir.get_data_dir()
		
		var scripts = Dir.get_file_list(path.plus_file('meshes'), 'gd')
		scripts.sort()
		
		for f_name in scripts:
			var p = path.plus_file('meshes'.plus_file(f_name))
			
			var script = load(p)
			var name = script.get_name()
			
			if not name:
				continue
				
			var container = script.get_container()
			
			if container:
				container = container.replace(' ', '_').to_lower()
				
				if not submenus.has(container):
					submenus[container] = []
					
				submenus[container].push_back(name)
				
			else:
				popup_menu.add_item(name)
				
			primitives[name] = script
			
		if submenus.size():
			popup_menu.add_separator()
			
			for sub in submenus.keys():
				var submenu = PopupMenu.new()
				submenu.set_name(sub)
				
				popup_menu.add_child(submenu)
				
				var n = sub.replace('_', ' ').capitalize()
				
				popup_menu.add_submenu_item(n, sub)
				
				submenu.connect("item_pressed", self, "_popup_signal", [submenu])
				
				for name in submenus[sub]:
					submenu.add_item(name)
					
		if not modules.empty():
			popup_menu.add_separator()
			
			for m in modules:
				popup_menu.add_item(m)
				
		popup_menu.add_separator()
		
		popup_menu.add_icon_item(get_icon('Edit', 'EditorIcons'), 'Edit Primitive', -1, KEY_MASK_SHIFT + KEY_E)
		popup_menu.add_icon_item(get_icon('Reload', 'EditorIcons'), 'Reload')
		
		_set_edit_disabled(true)
		
		if not popup_menu.is_connected("item_pressed", self, "_popup_signal"):
			popup_menu.connect("item_pressed", self, "_popup_signal", [popup_menu])
			
	func _create_primitive(name):
		if modules.has(name):
			last_module = name
			mesh_instance = module_call(modules[name], "create", [node])
			
			_set_edit_disabled(mesh_instance == null)
			
			return
			
		if last_module:
			module_call(modules[last_module], "clear")
			
			last_module = ""
			
		builder = primitives[name].new()
		
		if builder.has_method('create'):
			add_mesh_instance()
			mesh_instance.set_name(name)
			
			var start = OS.get_ticks_msec()
			
			base_mesh = builder.create()
			
			assert( base_mesh != null )
			
			base_mesh.set_name(name.to_lower())
			mesh_instance.set_mesh(base_mesh)
			
			_display_info(base_mesh, start)
			
			if builder.has_method('mesh_parameters'):
				mesh_dialog.edit(mesh_instance, builder)
				_set_edit_disabled(false)
				
				mesh_dialog.show_dialog()
				
	func _set_edit_disabled(disable):
		var count = popup_menu.get_item_count()
		
		if not count:
			return
			
		popup_menu.set_item_disabled(count - 2, disable)
		set_process_unhandled_key_input(not disable)
		
	func _edit_primitive():
		if not mesh_instance:
			return
			
		if last_module:
			module_call(modules[last_module], "edit_primitive")
			
			return
			
		if mesh_dialog.is_hidden():
			mesh_dialog.show_dialog()
			
	func _unhandled_key_input(key_event):
		if key_event.pressed and not key_event.echo:
			if key_event.scancode == KEY_E and key_event.shift:
				_edit_primitive()
				
				get_tree().set_input_as_handled()
				
	func _node_removed(node):
		if node == mesh_instance:
			_set_edit_disabled(true)
			
			if last_module:
				module_call(modules[last_module], "node_removed")
				
				last_module = ""
				
			if mesh_dialog.is_visible():
				mesh_dialog.hide()
				
			mesh_instance = null
			
	func _enter_tree():
		load_modules()
		
		_update_menu()
		
		var base = get_node("/root/EditorNode").get_gui_base()
		
		mesh_dialog = preload("MeshDialog.gd").new(base)
		base.add_child(mesh_dialog)
		
		mesh_dialog.connect_editor("parameters", self, "_update_mesh")
		mesh_dialog.connect_editor("modifiers", self, "_modify_mesh")
		
		mesh_dialog.connect("cancel", self, "remove_mesh_instace")
		
		get_tree().connect("node_removed", self, "_node_removed")
		
	func _exit_tree():
		popup_menu.clear()
		mesh_dialog.clear()
		
		builder = null
		base_mesh = null
		
		primitives.clear()
		modules.clear()
		
	func _init():
		var separator = VSeparator.new()
		add_child(separator)
		
		var spatial_menu = MenuButton.new()
		var icon = preload('icon_mesh_instance_add.png')
		spatial_menu.set_button_icon(icon)
		spatial_menu.set_tooltip("Add New Primitive")
		
		popup_menu = spatial_menu.get_popup()
		
		add_child(spatial_menu)
		
# End AddPrimitives

var add_primitives

static func get_name():
	return "Add Primitives"
	
func edit(object):
	add_primitives.edit(object)
	
func handles(object):
	return object.get_type() == 'Spatial'
	
func make_visible(visible):
	if visible:
		add_primitives.show()
	else:
		add_primitives.hide()
		add_primitives.edit(null)
		
func _enter_tree():
	add_primitives = AddPrimitives.new()
	add_custom_control(CONTAINER_SPATIAL_EDITOR_MENU, add_primitives)
	add_primitives.hide()
	
	print("ADD PRIMITIVES INIT")
	
func _exit_tree():
	edit(null)
	

