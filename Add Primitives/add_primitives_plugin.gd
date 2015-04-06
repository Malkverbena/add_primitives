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
	
	func get_scripts_from_list(list_files):
		var scripts = []
		
		for file in list_files:
			if file.extension() == 'gd':
				scripts.append(file)
			
		return scripts
		
	func get_file_list(path):
		var list = []
		
		if dir_exists(path):
			open(path)
			list_dir_begin()
			
			while true:
				list.append(get_next())
				if list[list.size() - 1] != '.':
					continue
				else:
					list.append(get_next())
					break
					
			list_dir_end()
			
		return list
		
#End DirectoryUtilities

class TransformDialog:
	extends VBoxContainer
	
	var AXIS = {
		X = Vector3.AXIS_X,
		Y = Vector3.AXIS_Y,
		Z = Vector3.AXIS_Z
	}
	
	var TRANSFORM = {
		TRANSLATION = 0,
		ROTATION = 1,
		SCALE = 2
	}
	
	var translation = Vector3(0,0,0)
	var rotation = Vector3(0,0,0)
	var scale = Vector3(1,1,1)
	
	func get_translation():
		return translation
		
	func get_rotation():
		return rotation
		
	func get_scale():
		return scale
		
	func set_translation(value, axis):
		translation[axis] = value
		
		emit_signal("transform_changed", TRANSFORM.TRANSLATION)
		
	func set_rotation(value, axis):
		rotation[axis] = deg2rad(value)
		
		emit_signal("transform_changed", TRANSFORM.ROTATION)
		
	func set_scale(value, axis):
		scale[axis] = value
		
		emit_signal("transform_changed", TRANSFORM.SCALE)
		
	func add_spacer(parent):
		var c = Control.new()
		parent.add_child(c)
		c.set_h_size_flags(SIZE_EXPAND_FILL)
		c.set_v_size_flags(SIZE_EXPAND_FILL)
		
	func add_label(parent, label):
		var l = Label.new()
		l.set_text(label)
		l.set_align(l.ALIGN_LEFT)
		l.set_valign(l.VALIGN_FILL)
		
		parent.add_child(l)
		
	func add_row():
		var hb = HBoxContainer.new()
		add_child(hb)
		hb.set_h_size_flags(SIZE_EXPAND_FILL)
		
		return hb
		
	func add_spinbox(parent, label, value, step, _min, _max):
		var spin = SpinBox.new()
		spin.set_val(value)
		spin.set_step(step)
		spin.set_min(_min)
		spin.set_max(_max)
		parent.add_child(spin)
		
		return spin
		
	func _init():
		set_name("Transform")
		set_v_size_flags(SIZE_EXPAND_FILL)
		
		var hb = add_row()
		
		add_label(hb, 'Translation')
		
		hb = add_row()
		
		var tx = add_spinbox(hb, 'x', 0, 0.1, -500, 500)
		var ty = add_spinbox(hb, 'y', 0, 0.1, -500, 500)
		var tz = add_spinbox(hb, 'z', 0, 0.1, -500, 500)
		
		tx.connect("value_changed", self, "set_translation", [AXIS.X])
		ty.connect("value_changed", self, "set_translation", [AXIS.Y])
		tz.connect("value_changed", self, "set_translation", [AXIS.Z])
		
		add_spacer(self)
		hb = add_row()
		
		add_label(hb, 'Rotation')
		
		hb = add_row()
		
		var rx = add_spinbox(hb, 'x', 0, 1, -360, 360) 
		var ry = add_spinbox(hb, 'y', 0, 1, -360, 360) 
		var rz = add_spinbox(hb, 'z', 0, 1, -360, 360) 
		
		rx.connect("value_changed", self, "set_rotation", [AXIS.X])
		ry.connect("value_changed", self, "set_rotation", [AXIS.Y])
		rz.connect("value_changed", self, "set_rotation", [AXIS.Z])
		
		add_spacer(self)
		hb = add_row()
		
		add_label(hb, 'Scale')
		
		hb = add_row()
		
		var sx = add_spinbox(hb, 'x', 1, 0.1, -100, 100)
		var sy = add_spinbox(hb, 'y', 1, 0.1, -100, 100)
		var sz = add_spinbox(hb, 'z', 1, 0.1, -100, 100)
		
		sx.connect("value_changed", self, "set_scale", [AXIS.X])
		sy.connect("value_changed", self, "set_scale", [AXIS.Y])
		sz.connect("value_changed", self, "set_scale", [AXIS.Z])
		
		add_user_signal("transform_changed", [TRANSFORM])
		
#End TransformDialog

class ModifierDialog:
	extends VBoxContainer
	
	var TOOL = {
		ERASE = 0,
		MOVEUP = 1,
		MOVEDOWN = 2
	}
	
	var items = []
	
	var modifiers
	var menu
	var remove
	var move_up
	var move_down
	
	var modifiers_scripts
	
	func create_modifier(script):
		var root = modifiers.get_root()
		
		var item = modifiers.create_item(root)
		item.set_cell_mode(0, item.CELL_MODE_STRING)
		item.set_editable(0, true)
		item.set_text(0, script.get_name())
		
		item.set_cell_mode(1, item.CELL_MODE_CHECK)
		item.set_checked(1, true)
		item.set_text(1, 'On')
		item.set_editable(1, true)
		item.set_selectable(1, false)
		
		item.set_metadata(0, script.get_name())
		
		if script.has_method('modifier_parameters'):
			script.modifier_parameters(item, modifiers)
			
		items.append(item)
		
	func get_items():
		return items
		
	func get_modifier_values(item):
		var values = []
		
		var i = item.get_children()
		
		while true:
			var cell = i.get_cell_mode(1)
			
			if cell == i.CELL_MODE_STRING:
				values.append(i.get_text(1))
			elif cell == i.CELL_MODE_CHECK:
				values.append(i.is_checked(1))
			elif cell == i.CELL_MODE_RANGE:
				if i.get_text(1):
					var text = i.get_text(1)
					text = text.split(',')
					values.append(text[i.get_range(1)])
				else:
					values.append(i.get_range(1))
			
			i = i.get_next()
			
			if i == null:
				break
				
		return values
		
	func _add_modifier(id):
		var mod = menu.get_item_text(menu.get_item_index(id))
		
		create_modifier(modifiers_scripts[mod])
		
	func modifier_tools(what):
		var item = modifiers.get_selected()
		
		if what == TOOL.MOVEUP:
			if item.get_prev() != null:
				item.move_to_top()
				
		elif what == TOOL.MOVEDOWN:
			if item.get_next() != null:
				item.move_to_bottom()
				
		elif what == TOOL.ERASE:
			items.remove(items.find(item))
			item.get_parent().remove_child(item)
			
			remove.set_disabled(true)
			move_up.set_disabled(true)
			move_down.set_disabled(true)
			
		modifiers.grab_focus()
		
		emit_signal("modifier_edited")
		
	func update_menu(scripts):
		menu.clear()
		
		modifiers_scripts = scripts
		
		for m in modifiers_scripts:
			menu.add_item(m)
			
	func _item_edited():
		emit_signal("modifier_edited")
		
	func _item_selected():
		var item = modifiers.get_selected()
		
		if item.get_parent() == modifiers.get_root():
			remove.set_disabled(false)
			move_up.set_disabled(false)
			move_down.set_disabled(false)
			
		else:
			remove.set_disabled(true)
			move_up.set_disabled(true)
			move_down.set_disabled(true)
			
	func update():
		modifiers.clear()
		
		items = []		

		modifiers.set_hide_root(true)
		modifiers.set_columns(2)
		modifiers.set_column_min_width(0, 2)
		
		modifiers.create_item()
		
	func _init(base):
		set_name("Modifiers")
		
		modifiers = Tree.new()
		add_child(modifiers)
		modifiers.set_v_size_flags(SIZE_EXPAND_FILL)
		
		var hbox_tools = HBoxContainer.new()
		add_child(hbox_tools)
		hbox_tools.set_h_size_flags(SIZE_EXPAND_FILL)
		
		#Tools
		var add = MenuButton.new()
		add.set_button_icon(base.get_icon('Add', 'EditorIcons'))
		add.set_tooltip("Add Modifier")
		hbox_tools.add_child(add)
		menu = add.get_popup()
		
		menu.connect("item_pressed", self, "_add_modifier")
		
		remove = ToolButton.new()
		remove.set_button_icon(base.get_icon('Remove', 'EditorIcons'))
		remove.set_tooltip("Remove Modifier")
		remove.set_disabled(true)
		hbox_tools.add_child(remove)
		
		#Spacer
		var s = Control.new()
		hbox_tools.add_child(s)
		s.set_h_size_flags(SIZE_EXPAND_FILL)
		
		move_up = ToolButton.new()
		move_up.set_button_icon(base.get_icon('MoveUp', 'EditorIcons'))
		move_up.set_tooltip("Move to Top")
		move_up.set_disabled(true)
		hbox_tools.add_child(move_up)
		
		move_down = ToolButton.new()
		move_down.set_button_icon(base.get_icon('MoveDown', 'EditorIcons'))
		move_down.set_tooltip("Move to Bottom")
		move_down.set_disabled(true)
		hbox_tools.add_child(move_down)
		
		remove.connect("pressed", self, "modifier_tools", [TOOL.ERASE])
		move_up.connect("pressed", self, "modifier_tools", [TOOL.MOVEUP])
		move_down.connect("pressed", self, "modifier_tools", [TOOL.MOVEDOWN])
		
		modifiers.connect("item_edited", self, "_item_edited")
		modifiers.connect("cell_selected", self, "_item_selected")
		
		add_user_signal("modifier_edited")
		
#End ModifierDialog

class ParameterDialog:
	extends VBoxContainer
	
	var values
	
	var parameters
	var smooth_button
	var reverse_button
	
	func create_parameters(script):
		parameters.clear()
		
		parameters.set_hide_root(true)
		parameters.set_columns(2)
		parameters.set_column_titles_visible(true)
		parameters.set_column_title(0, 'Parameter')
		parameters.set_column_title(1, 'Value')
		parameters.set_column_min_width(0, 2)
		
		script.mesh_parameters(parameters)
		
		smooth_button.set_pressed(false)
		reverse_button.set_pressed(false)
		
	func get_parameters_values(script):
		var par = script.get_parameters()
		
		values = []
		
		for p in par:
			var cell = p.get_cell_mode(1)
			
			if cell == 0:
				values.append(p.get_text(1))
			elif cell == 1:
				values.append(p.is_checked(1))
			elif cell == 2:
				if p.get_text(1):
					var text = p.get_text(1)
					text = text.split(',')
					values.append(text[p.get_range(1)])
				else:
					values.append(p.get_range(1))
					
		return values
		
	func get_smooth():
		return smooth_button.is_pressed()
		
	func get_reverse():
		return reverse_button.is_pressed()
		
	func _item_edited():
		print('_-_')		
		
		emit_signal("parameter_edited")
		
	func _init():
		set_name("Parameters")
		
		parameters = Tree.new()
		add_child(parameters)
		parameters.set_v_size_flags(SIZE_EXPAND_FILL)
		
		smooth_button = CheckBox.new()
		smooth_button.set_text('Smooth')
		add_child(smooth_button)
		
		reverse_button = CheckBox.new()
		reverse_button.set_text('Reverse Normals')
		add_child(reverse_button)
		
		smooth_button.connect("pressed", self, "_item_edited")
		reverse_button.connect("pressed", self, "_item_edited")
		parameters.connect("item_edited", self, "_item_edited")
		
		add_user_signal("parameter_edited")
		
#End ParameterDialog

class MeshPopup:
	extends AcceptDialog
	
	var index = 0
	
	#Containers
	var main_vbox
	var main_panel
	
	var options
	var parameter_dialog
	var modifier_dialog
	var transform_dialog
	
	func get_parameter_dialog():
		return parameter_dialog
		
	func get_modifier_dialog():
		return modifier_dialog
		
	func get_transform_dialog():
		return transform_dialog
		
	func set_current_dialog(id):
		if not main_panel.get_child(id).is_visible():
			main_panel.get_child(index).hide()
			main_panel.get_child(id).show()
			
			options.select(id)
			index = id
			
	func update_options():
		for i in main_panel.get_children():
			options.add_item(i.get_name())
			
	func _init(base):
		main_vbox = VBoxContainer.new()
		add_child(main_vbox)
		main_vbox.set_area_as_parent_rect(get_constant('margin', 'Dialogs'))
		main_vbox.set_margin(MARGIN_BOTTOM, get_constant("button_margin","Dialogs")+10)
		
		var hb = HBoxContainer.new()
		main_vbox.add_child(hb)
		hb.set_h_size_flags(SIZE_EXPAND_FILL)
		options = OptionButton.new()
		hb.add_child(options)
		options.connect("item_selected", self, "set_current_dialog")
		
		main_panel = PanelContainer.new()
		main_vbox.add_child(main_panel)
		main_panel.set_v_size_flags(SIZE_EXPAND_FILL)
		
		parameter_dialog = ParameterDialog.new()
		main_panel.add_child(parameter_dialog)
		
		modifier_dialog = ModifierDialog.new(base)
		main_panel.add_child(modifier_dialog)
		modifier_dialog.hide()
		
		transform_dialog = TransformDialog.new()
		main_panel.add_child(transform_dialog)
		transform_dialog.hide()
		
		update_options()
		
#End MeshPopup

class AddPrimitives:
	extends HBoxContainer
	
	var start
	var index = 0
	
	var hbox
	var add_mesh_popup
	
	var node
	var mesh_instance
	
	var original_mesh
	var meshes_to_modify = []
	
	var current_script
	var mesh_scripts = {}
	var modifier_scripts = {}
	var extra_modules = {}
	
	#Utilites
	static func get_plugins_folder():
		var path = OS.get_data_dir()
		path = path.substr(0, path.find_last('/'))
		path = path.substr(0, path.find_last('/'))
		return path + '/plugins'
		
	func edit(object):
		node = object
		
	func update_menu():
		var popup_menu = get_node('spatial_toolbar_menu').get_popup()
		popup_menu.set_name('spatial_menu')
		
		popup_menu.clear()
		
		for i in popup_menu.get_children():
			if i.get_type() == 'PopupMenu':
				popup_menu.remove_and_delete_child(i)
		
		var dir = extra_modules['directory_utilites']
		
		var submenus = {}
		
		var path = get_plugins_folder() + '/Add Primitives'
		
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
		current_script = null
		
		var popup = get_node('spatial_toolbar_menu').get_popup()
		
		var command = popup.get_item_text(popup.get_item_index(id))
		
		if command == 'Reload Menu':
			update_menu()
			
		else:
			current_script = load(mesh_scripts[command]).new()
			
			if current_script.has_method('build_mesh'):
				var mesh
				if current_script.has_method('mesh_parameters'):
					start = OS.get_ticks_msec()
					mesh = current_script.build_mesh(1)
					print('built in: ', OS.get_ticks_msec() - start, ' milisecs')
					print('====================================================')
					mesh_popup(command)
				else:
					start = OS.get_ticks_msec()
					mesh = current_script.build_mesh()
					print('built in: ', OS.get_ticks_msec() - start, ' milisecs')
					print('====================================================')
					
				mesh.set_name(command.split(' ')[1])
				
				if mesh != null:
					add_mesh_instance(mesh)
					
	func mesh_popup(key):
		var dir = extra_modules['directory_utilites']
		var path = get_plugins_folder() + '/Add Primitives/meshes/modifiers'
		
		add_mesh_popup.set_title(key)
		
		add_mesh_popup.set_current_dialog(0)
		add_mesh_popup.show()
		add_mesh_popup.popup_centered(Vector2(220, 240))
		
		add_mesh_popup.get_parameter_dialog().create_parameters(current_script)
		
		if dir.dir_exists(path):
			var modifiers = dir.get_file_list(path)
			modifiers = dir.get_scripts_from_list(modifiers)
			
			for mod in modifiers:
				var name = mod.substr(0, mod.find_last('.')).capitalize()
				modifier_scripts[name] = load(path + '/' + mod).new()
				
		add_mesh_popup.get_modifier_dialog().update_menu(modifier_scripts)
		add_mesh_popup.get_modifier_dialog().update()
		
	func update_mesh():
		var values = add_mesh_popup.get_parameter_dialog().get_parameters_values(current_script)
		var smooth = add_mesh_popup.get_parameter_dialog().get_smooth()
		var reverse = add_mesh_popup.get_parameter_dialog().get_reverse()
		
		start = OS.get_ticks_msec()
		var mesh = current_script.build_mesh(values, smooth, reverse)
		print(' built in: ', OS.get_ticks_msec() - start, ' milisecs')
		print('====================================================')
		#center geometry######
		mesh.center_geometry()
		######################
		
		assert( mesh.get_type() == 'Mesh' )
		
		mesh_instance.set_mesh(mesh)
		
		original_mesh = mesh

		modify_mesh()
		
	func modify_mesh():
		var modifier = add_mesh_popup.get_modifier_dialog()
		
		meshes_to_modify.clear()
		
		var count = 0
		
		mesh_instance.set_mesh(original_mesh)
		
		for item in modifier.get_items():
			var script
			
			if item.is_checked(1):
				script = modifier_scripts[item.get_metadata(0)]
				count += 1
				
				var values = modifier.get_modifier_values(item)
				
				assert( not values.empty() )
				
				assert( mesh_instance.get_mesh() )
				
				if count == 1:
					mesh_instance.set_mesh(script.modifier(values, mesh_instance.get_aabb(), original_mesh))
					
				elif count > 1:
					meshes_to_modify.resize(count - 1)
					meshes_to_modify[count - 2] = mesh_instance.get_mesh()
					
					mesh_instance.set_mesh(meshes_to_modify[count - 2])
					mesh_instance.set_mesh(script.modifier(values, mesh_instance.get_aabb(), meshes_to_modify[count - 2]))
					
				values.clear()
				
			if count == 0:
				mesh_instance.set_mesh(original_mesh)
		
	func transform_mesh(what):
		if what == 0:
			var val = add_mesh_popup.get_transform_dialog().get_translation()
			
			mesh_instance.set_translation(val)
			
		elif what == 1:
			var val = add_mesh_popup.get_transform_dialog().get_rotation()
			
			mesh_instance.set_rotation(val)
			
		elif what == 2:
			var val = add_mesh_popup.get_transform_dialog().get_scale()
			
			mesh_instance.set_scale(val)
			
	func add_mesh_instance(mesh):
		mesh_instance = MeshInstance.new()
		#center geometry######
		mesh.center_geometry()
		######################
		mesh_instance.set_mesh(mesh)
		mesh_instance.set_name(mesh.get_name())
		
		var root
		
		if is_inside_tree():
			root = get_tree().get_edited_scene_root()
			
			node.add_child(mesh_instance)
			mesh_instance.set_owner(root)
			
			original_mesh = mesh
			
	func _init(editor_plugin, base):
		extra_modules['directory_utilites'] = DirectoryUtilities.new()
		
		var separator = VSeparator.new()
		var spatial_menu = MenuButton.new()
		spatial_menu.set_name('spatial_toolbar_menu')
		
		var icon = load(get_plugins_folder() + '/Add Primitives/icon_mesh_instance_add.png')
		spatial_menu.set_button_icon(icon)
		spatial_menu.set_tooltip("Add New MeshInstance")
		
		add_child(separator)
		add_child(spatial_menu)
		
		editor_plugin.add_custom_control(CONTAINER_SPATIAL_EDITOR_MENU, self)
		
		update_menu()
		
		add_mesh_popup = MeshPopup.new(base)
		add_child(add_mesh_popup)
		add_mesh_popup.hide()
		
		add_mesh_popup.get_parameter_dialog().connect("parameter_edited", self, "update_mesh")
		add_mesh_popup.get_modifier_dialog().connect("modifier_edited", self, "modify_mesh")
		add_mesh_popup.get_transform_dialog().connect("transform_changed", self, "transform_mesh")
		
#End AddPrimitives

var add_primitives
var gui_base

static func get_name():
	return "Add Primitives"
	
func edit(object):
	add_primitives.edit(object)
	
func handles(object):
	return object.is_type('Spatial')
	
func make_visible(visible):
	if visible:
		add_primitives.show()
	else:
		add_primitives.hide()
		add_primitives.edit(null)
		
func _init():
	print("ADD PRIMITIVES INIT")
	
func _enter_tree():
	gui_base = get_node("/root/EditorNode").get_gui_base()
	
	add_primitives = AddPrimitives.new(self, gui_base)
	
	if not add_primitives.is_inside_tree():
		add_child(add_primitives)
		
	add_primitives.hide()
	
func _exit_tree():
	add_primitives.free()
	