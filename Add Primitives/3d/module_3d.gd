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

extends EditorPlugin

var hbox
var mesh_instance

var original_mesh
var meshes_to_modify = []

var mesh_scripts = {}
var modifier_scripts = {}
var extra_modules = {}

#Utilites
static func get_plugins_folder():
	var path = OS.get_data_dir()
	path = path.substr(0, path.find_last('/'))
	path = path.substr(0, path.find_last('/'))
	return path + '/plugins'
	
func message_popup(message):
	var window = AcceptDialog.new()
	window.set_title('Alert!')
	window.set_size(Vector2(180, 80))
	window.set_text(message)
	
	add_child(window)
	window.popup_centered(window.get_size())
	
func get_spatial_node():
	var root = get_tree().get_edited_scene_root()
	
	if root != null:
		if root.get_type() == 'Spatial':
			return root
		else:
			for node in root.get_children():
				if node.get_type() == 'Spatial':
					return node
	return null
	
func _enter_tree():
	print("3D MODULE INIT")
	
	extra_modules['directory_utilites'] =\
	              load(get_plugins_folder() + '/Add Primitives/extra modules/directory_utilites.gd').new()
	
	hbox = HBoxContainer.new()
	hbox.set_name("hbox")
	
	var separator = VSeparator.new()
	var spatial_menu = MenuButton.new()
	spatial_menu.set_name('spatial_toolbar_menu')
	
	var icon = load(get_plugins_folder() + '/Add Primitives/3d/icons/icon_mesh_instance_add.png')
	spatial_menu.set_button_icon(icon)
	spatial_menu.set_tooltip("Add New MeshInstance")
	
	hbox.add_child(spatial_menu)
	hbox.add_child(separator)
	
	update_menu()
	
	add_custom_control(CONTAINER_SPATIAL_EDITOR_MENU, hbox)
	
	hbox.get_parent().move_child(hbox, 6)
	
func update_menu():
	var popup_menu = hbox.get_node('spatial_toolbar_menu').get_popup()
	popup_menu.set_name('spatial_menu')
	
	popup_menu.clear()
	
	for i in popup_menu.get_children():
		if i.get_type() == 'PopupMenu':
			popup_menu.remove_and_delete_child(i)
	
	var dir = extra_modules['directory_utilites']
	
	var submenus = {}
	
	var path = get_plugins_folder() + '/Add Primitives/3d'
	
	if dir.dir_exists(path + '/meshes'):
		var scripts = dir.get_file_list(path + '/meshes')
		scripts = dir.get_scripts_from_list(scripts)
		
		for name in scripts:
			var key = 'Add ' + name.substr(0, name.find_last('.')).capitalize()
			mesh_scripts[key] = path + '/meshes/' + name
			
			var temp_script = load(mesh_scripts[key]).new()
			
			if temp_script.has_method('container'):
				var container = temp_script.container()
				if submenus.has(container):
					submenus[container].append(key)
				else:
					submenus[container] = [key]
			else:
				popup_menu.add_item(key)
				
	if submenus.size() != 0:
		popup_menu.add_separator()
	
	for i in submenus.keys():
		
		var submenu = PopupMenu.new()
		submenu.set_name(i)
		popup_menu.add_child(submenu)
		popup_menu.add_submenu_item(i, i)
		
		for j in submenus[i]:
			submenu.add_item(j)
		
	popup_menu.add_separator()
	popup_menu.add_item('Reload Menu')
	
	if not popup_menu.is_connected("item_pressed", self, "popup_signal"):
		popup_menu.connect("item_pressed", self, "popup_signal")
	
func popup_signal(id):
	var popup = hbox.get_node('spatial_toolbar_menu').get_popup()
	
	var command = popup.get_item_text(popup.get_item_index(id))
	
	if command == 'Reload Menu':
		update_menu()
		
	elif command == 'Heightmap':
		if get_spatial_node():
			extra_modules['heightmap_module'].heightmap()
		else:
			message_popup("You need one Spatial node\nto add the heightmap!")
		
	else:
		var script = load(mesh_scripts[command]).new()
		
		if script.has_method('build_mesh'):
			var mesh
			if get_spatial_node():
				if script.has_method('mesh_parameters'):
					mesh = script.build_mesh('default')
					add_mesh_popup(command)
				else:
					mesh = script.build_mesh()
					
				mesh.set_name(command.split(' ')[1])
			else:
				message_popup("You need one Spatial node\nto add the mesh!")
				
			if mesh != null:
				add_mesh_instance(mesh)
				
func load_modifiers(tree):
	var dir = extra_modules['directory_utilites']
	var path = get_plugins_folder() + '/Add Primitives/3d/meshes/modifiers'

	if dir.dir_exists(path):
		var modifiers = dir.get_file_list(path)
		modifiers = dir.get_scripts_from_list(modifiers)
		
		for mod in modifiers:
			var name = mod.substr(0, mod.find_last('.')).capitalize()
			modifier_scripts[name] = path + '/' + mod
			
			var temp = load(modifier_scripts[name]).new()
			
			if temp.has_method('modifier_parameters'):
				tree.set_hide_root(true)
				tree.set_columns(2)
				tree.set_column_min_width(0, 2)
				
				var root = tree.get_root()
				if not root:
					root = tree.create_item()
					
				var item = tree.create_item(root)
				item.set_text(0, temp.get_name())
				item.set_cell_mode(1, 1)
				item.set_checked(1, false)
				item.set_editable(1, true)
				item.set_text(1, 'On')
				
				temp.modifier_parameters(item, tree)
				
func transform_dialog(tree):
	tree.clear()
	tree.set_hide_root(true)
	tree.set_columns(2)
	tree.set_column_min_width(0, 3)
	tree.set_column_titles_visible(true)
	tree.set_column_title(0, 'Axis')
	tree.set_column_title(1, 'Value')
	
	var root = tree.create_item()
	
	var translate = tree.create_item(root)
	translate.set_text(0, 'Translation')
	var rotate = tree.create_item(root)
	rotate.set_text(0, 'Rotation')
	var scale = tree.create_item(root)
	scale.set_text(0, 'Scale')
	
	var axis = ['x', 'y', 'z']
	
	var item = root.get_children()
	
	while true:
		for a in axis:
			var i = tree.create_item(item)
			i.set_text(0, a)
			i.set_cell_mode(1, 2)
			if item.get_text(0) != 'Scale':
				i.set_range(1, 0)
			else:
				i.set_range(1, 1)
			i.set_range_config(1, -100, 100, 0.1)
			i.set_editable(1, true)
		item = item.get_next()
		
		if not item:
			break
			
func add_mesh_popup(key):
	var dir = extra_modules['directory_utilites']
	
	original_mesh = null
	
	if dir.file_exists(get_plugins_folder() + '/Add Primitives/3d/gui/AddMeshPopup.xml'):
		var window = load(get_plugins_folder() + '/Add Primitives/3d/gui/AddMeshPopup.xml').instance()
		window.set_title(key)
		
		var settings = window.get_node('tab/Parameters/Settings')
		var modifier = window.get_node('tab/Modifiers/Modifier')
		settings.clear()
		settings.set_hide_root(true)
		settings.set_columns(2)
		settings.set_column_title(0, 'Parameter')
		settings.set_column_title(1, 'Value')
		settings.set_column_titles_visible(true)
		
		settings.set_column_min_width(0, 2)
		
		var smooth_button = window.get_node('tab/Parameters/Smooth')
		var reverse_button = window.get_node('tab/Parameters/Reverse')
		
		if not settings.is_connected('item_edited', self, 'update_mesh'):
			settings.connect('item_edited', self, 'update_mesh', [key, settings, modifier, smooth_button, reverse_button])
		if not smooth_button.is_connected('pressed', self, 'update_mesh'):
			smooth_button.connect('pressed', self, 'update_mesh', [key, settings, modifier, smooth_button, reverse_button])
		if not reverse_button.is_connected('pressed', self, 'update_mesh'):
			reverse_button.connect('pressed', self, 'update_mesh', [key, settings, modifier, smooth_button, reverse_button])
		
		load_modifiers(modifier)
		
		if not modifier.is_connected("item_edited", self, 'modify_mesh'):
			modifier.connect("item_edited", self, 'modify_mesh', [modifier])
			
		var dialog = window.get_node('tab/Transform/Dialog')
		
		transform_dialog(dialog)
		
		if not dialog.is_connected('item_edited', self, 'transform_mesh'):
			dialog.connect('item_edited', self, 'transform_mesh', [dialog])
		
		var script = load(mesh_scripts[key]).new()
		
		script.mesh_parameters(settings)
		
		if not window.is_inside_tree():
			add_child(window)
		else:
			window.free()
			add_child(window)
			
		window.popup_centered(window.get_size())
		
func get_tree_children(root):
	var items = []
	
	var item = root.get_children()
	while true:
		items.append(item)
		
		item = item.get_next()
		if item == null:
			break
			
	return items
	
func update_mesh(key, settings, modifier, smooth_button = null, reverse_button = null):
	var values = []
	var root = settings.get_root()
	
	var smooth = false
	var reverse = false
	
	if smooth_button:
		smooth = smooth_button.is_pressed()
	
	if reverse_button:
		reverse = reverse_button.is_pressed()
	
	var next_item = root.get_children()
	
	while true:
		var cell = next_item.get_cell_mode(1)
		if cell == 0:
			values.append(next_item.get_text(1))
		elif cell == 1:
			values.append(next_item.is_checked(1))
		elif cell == 2:
			if next_item.get_text(1):
				var text = next_item.get_text(1)
				text = text.split(',')
				values.append(text[next_item.get_range(1)])
			else:
				values.append(next_item.get_range(1))
				
		next_item = next_item.get_next()
		if next_item == null:
			break
			
	var script_temp = load(mesh_scripts[key]).new()
	var mesh = script_temp.build_mesh(values, smooth, reverse)
	#center geometry######
	mesh.center_geometry()
	######################
	
	if mesh.get_type() == 'Mesh':
		mesh_instance.set_mesh(mesh)
		
		original_mesh = mesh
		
		modify_mesh(modifier)
		
func modify_mesh(tree):
	var root = tree.get_root()
	var item = root.get_children()
	
	meshes_to_modify.clear()
	
	var count = 0
	
	if original_mesh == null:
		original_mesh = mesh_instance.get_mesh()
		
	while true:
		var values = []
		
		var script
		
		if item.is_checked(1):
			script = load(modifier_scripts[item.get_text(0)]).new()
			count += 1
			
			var par = get_tree_children(item)
			
			assert( not par.empty() )
			
			for p in par:
				var  cell = p.get_cell_mode(1)
				if cell == 0:
					values.append(p.get_text(1))
				elif cell == 1:
					values.append(p.get_checked(1))
				elif cell == 2:
					if p.get_text(1):
						var text = p.get_text(1)
						text = text.split(',')
						values.append(text[p.get_range(1)])
					else:
						values.append(p.get_range(1))
						
			assert( mesh_instance.get_mesh() )
			
			if count == 1:
				mesh_instance.set_mesh(original_mesh)
				mesh_instance.set_mesh(script.modifier(values, mesh_instance.get_aabb(), original_mesh))
				
			elif count > 1:
				meshes_to_modify.resize(count - 1)
				meshes_to_modify[count - 2] = mesh_instance.get_mesh()
				
				mesh_instance.set_mesh(meshes_to_modify[count - 2])
				mesh_instance.set_mesh(script.modifier(values, mesh_instance.get_aabb(), meshes_to_modify[count - 2]))
				
			values.clear()
			
		if count == 0:
			mesh_instance.set_mesh(original_mesh)
			
		item = item.get_next()
		
		if item == null:
			break
			
func transform_mesh(dialog):
	var val = []
	var transform = {}
	
	var root = dialog.get_root()
	
	var item = root.get_children()
	
	while true:
		var child = item.get_children()
		
		for i in range(3):
			val.append(child.get_range(1))
			
			child = child.get_next()
		
		transform[item.get_text(0)] = Vector3(val[0], val[1], val[2])
		val.clear()
		
		item = item.get_next()
		
		if not item:
			break
			
	mesh_instance.set_translation(transform['Translation'])
	mesh_instance.set_rotation(transform['Rotation']/rad2deg(1))
	mesh_instance.set_scale(transform['Scale'])
	
func add_mesh_instance(mesh):
	mesh_instance = MeshInstance.new()
	#center geometry######
	mesh.center_geometry()
	######################
	mesh_instance.set_mesh(mesh)
	mesh_instance.set_name(mesh.get_name())
	
	#root and node can be the same
	var root = get_tree().get_edited_scene_root()
	var node = get_spatial_node()
	
	node.add_child(mesh_instance)
	mesh_instance.set_owner(root)
	
func _exit_tree():
	if hbox != null:
		hbox.free()
	mesh_scripts = null
	modifier_scripts = null
	extra_modules = null
