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
	var exec_time = 0
	
	var popup_menu
	var mesh_dialog
	
	var node
	var mesh_instance
	
	var builder
	var base_mesh
	
	var mesh_scripts = {}
	var modules = {}
	
	# Utilites
	var dir
	
	static func module_call(object, method, args=[]):
		if not object:
			return null
			
		if not object.has_method(method):
			return null
			
		var vr = object.callv(method, args)
		
		return vr
		
	func get_object():
		return node
		
	func get_mesh_instance():
		return mesh_instance
		
	func get_mesh_dialog():
		return mesh_dialog
		
	func edit(object):
		node = object
		
	func update_menu():
		popup_menu.clear()
		mesh_scripts.clear()
		
		for c in popup_menu.get_children():
			if c extends PopupMenu:
				c.free()
				
		var submenus = {}
		
		var path = dir.get_data_dir()
		
		var scripts = dir.get_file_list(path.plus_file('meshes'), 'gd')
		scripts.sort()
		
		for f_name in scripts:
			var p = path.plus_file('meshes'.plus_file(f_name))
			
			var temp = load(p)
			
			var name = temp.get_name()
			
			if not name:
				continue
				
			var container = temp.get_container()
			
			if container:
				container = container.replace(' ', '_').to_lower()
				
				if not submenus.has(container):
					submenus[container] = []
					
				submenus[container].push_back(name)
				
			else:
				popup_menu.add_item(name)
				
			mesh_scripts[name] = p
			
		if submenus.size():
			popup_menu.add_separator()
			
			for sub in submenus.keys():
				var submenu = PopupMenu.new()
				submenu.set_name(sub)
				
				popup_menu.add_child(submenu)
				
				var n = sub.replace('_', ' ').capitalize()
				
				popup_menu.add_submenu_item(n, sub)
				
				if not submenu.is_connected("item_pressed", self, "popup_signal"):
					submenu.connect("item_pressed", self, "popup_signal", [submenu])
					
				for name in submenus[sub]:
					submenu.add_item(name)
					
		if not modules.empty():
			popup_menu.add_separator()
			
			for m in modules:
				popup_menu.add_item(m)
				
		popup_menu.add_separator()
		
		popup_menu.add_icon_item(get_icon('Edit', 'EditorIcons'), 'Edit Primitive')
		
		if not mesh_instance:
			popup_menu.set_item_disabled(popup_menu.get_item_count() - 1, true)
			
		popup_menu.add_icon_item(get_icon('Reload', 'EditorIcons'), 'Reload')
		
		if not popup_menu.is_connected("item_pressed", self, "popup_signal"):
			popup_menu.connect("item_pressed", self, "popup_signal", [popup_menu])
			
	func load_modules():
		var path = dir.get_data_dir().plus_file('modules')
		
		var mods = dir.get_file_list(path, 'gd')
		
		for m in mods:
			var temp = load(path.plus_file(m))
			
			if temp.can_instance():
				temp = temp.new(self)
				
				modules[temp.get_name()] = temp
				
		mods.clear()
		
	func popup_signal(id, menu):
		popup_menu.hide()
		
		var command = menu.get_item_text(menu.get_item_index(id))
		
		if command == 'Edit Primitive':
			if not mesh_instance:
				return
				
			if last_module:
				module_call(modules[last_module], "edit_primitive")
				
				return
				
			mesh_dialog.show_dialog()
			
			update_mesh()
			
		elif command == 'Reload':
			update_menu()
			
		elif modules.has(command):
			mesh_instance = module_call(modules[command], "create", [node])
			
			last_module = command
			
			_set_edit_disabled(mesh_instance == null)
			
		else:
			if last_module:
				module_call(modules[last_module], "clear")
				
			last_module = ""
			
			builder = load(mesh_scripts[command]).new()
			
			if builder.has_method('create'):
				add_mesh_instance()
				mesh_instance.set_name(command)
				
				if builder.has_method('mesh_parameters'):
					mesh_dialog.edit(mesh_instance, builder)
					_set_edit_disabled(false)
					
					update_mesh()
					
					mesh_dialog.show_dialog()
					
				else:
					base_mesh = builder.create()
					
				mesh_instance.set_mesh(base_mesh)
				base_mesh.set_name(command.to_lower())
				
	func add_mesh_instance():
		mesh_instance = MeshInstance.new()
		
		var root = get_tree().get_edited_scene_root()
		node.add_child(mesh_instance)
		mesh_instance.set_owner(root)
		
	func remove_mesh_instace():
		if mesh_instance.is_inside_tree():
			mesh_instance.queue_free()
			
	func update_mesh():
		var start = OS.get_ticks_msec()
		
		base_mesh = builder.create()
		
		assert( base_mesh != null )
		
		mesh_instance.set_mesh(base_mesh)
		
		modify_mesh()
		
		exec_time = OS.get_ticks_msec() - start
		mesh_dialog.display_text("Generation time: " + str(exec_time) + " ms")
		
	func modify_mesh():
		var start = OS.get_ticks_msec()
		
		var modifier = mesh_dialog.get_editor("modifiers")
		
		var mesh_buffer = []
		
		var count = 0
		
		if mesh_instance.get_mesh() != base_mesh:
			mesh_instance.set_mesh(base_mesh)
			
		assert( mesh_instance.get_mesh() )
		
		for item in modifier.tree_items():
			if not item.is_checked(1):
				continue
				
			var obj = instance_from_id(item.get_metadata(0))
			
			var mesh
			var aabb = mesh_instance.get_aabb()
			
			if count:
				mesh = obj.modifier(mesh_buffer[count - 1], aabb)
				
			else:
				mesh = obj.modifier(base_mesh, aabb)
				
			mesh_buffer.push_back(mesh)
			mesh_instance.set_mesh(mesh)
			
			count += 1
			
		exec_time = OS.get_ticks_msec() - start
		mesh_dialog.display_text("Generation time: " + str(exec_time) + " ms")
		
	func transform_mesh(what):
		if what == 0:
			var value = mesh_dialog.get("transform/translation")
			
			mesh_instance.set_translation(value)
			
		elif what == 1:
			var value = mesh_dialog.get("transform/rotation")
			
			mesh_instance.set_rotation(value)
			
		elif what == 2:
			var value = mesh_dialog.get("transform/scale")
			
			mesh_instance.set_scale(value)
			
	func _set_edit_disabled(disable):
		var count = popup_menu.get_item_count()
		
		if not count:
			return
			
		popup_menu.set_item_disabled(count - 2, disable)
		
	func _node_removed(node):
		if node == mesh_instance:
			_set_edit_disabled(true)
			
			if mesh_dialog.is_visible():
				mesh_dialog.hide()
				
	func _enter_tree():
		load_modules()
		
		update_menu()
		
		var base = get_node("/root/EditorNode").get_gui_base()
		
		mesh_dialog = preload("MeshDialog.gd").new(base)
		base.add_child(mesh_dialog)
		
		# Load modifiers
		var m_path = dir.get_data_dir().plus_file('Modifiers.gd')
		var temp = load(m_path).new()
		
		var modifiers = temp.get_modifiers()
		
		mesh_dialog.set("modifiers/modifiers", modifiers)
		
		mesh_dialog.connect_editor("parameters", self, "update_mesh")
		mesh_dialog.connect_editor("modifiers", self, "modify_mesh")
		mesh_dialog.connect_editor("transform", self, "transform_mesh")
		
		mesh_dialog.connect("cancel", self, "remove_mesh_instace")
		
		get_tree().connect("node_removed", self, "_node_removed")
		
	func _exit_tree():
		popup_menu.clear()
		mesh_dialog.clear()
		
		base_mesh = null
		
		mesh_scripts.clear()
		modules.clear()
		
	func _init():
		dir = DirectoryUtilities.new()
		
		var separator = VSeparator.new()
		add_child(separator)
		
		var spatial_menu = MenuButton.new()
		var icon = preload('icon_mesh_instance_add.png')
		spatial_menu.set_button_icon(icon)
		spatial_menu.set_tooltip("Add New Primitive")
		
		popup_menu = spatial_menu.get_popup()
		popup_menu.set_custom_minimum_size(Vector2(140, 0))
		
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
	

