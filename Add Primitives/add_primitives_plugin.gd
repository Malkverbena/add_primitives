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
				scripts.push_back(file)
			
		return scripts
		
	func get_file_list(path):
		var list = []
		
		if dir_exists(path):
			open(path)
			
			list_dir_begin()
			
			var next = get_next()
			
			while next:
				list.push_back(next)
				
				next = get_next()
				
			list_dir_end()
			
		return list
		
# End DirectoryUtilities

class TransformDialog:
	extends VBoxContainer
	
	const Axis = {
		X = Vector3.AXIS_X,
		Y = Vector3.AXIS_Y,
		Z = Vector3.AXIS_Z
	}
	
	const Transform_ = {
		TRANSLATION = 0,
		ROTATION = 1,
		SCALE = 2
	}
	
	var emit = true
	
	var translation = Vector3(0,0,0)
	var rotation = Vector3(0,0,0)
	var scale = Vector3(1,1,1)
	
	var spin_boxes = []
	
	signal transform_changed(what)
	
	func get_translation():
		return translation
		
	func get_rotation():
		return rotation
		
	func get_scale():
		return scale
		
	func set_translation(value, axis):
		translation[axis] = value
		
		if emit:
			emit_signal("transform_changed", Transform_.TRANSLATION)
			
	func set_rotation(value, axis):
		rotation[axis] = deg2rad(value)
		
		if emit:
			emit_signal("transform_changed", Transform_.ROTATION)
			
	func set_scale(value, axis):
		scale[axis] = value
		
		if emit:
			emit_signal("transform_changed", Transform_.SCALE)
			
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
		
	func add_spinbox(parent, label, value, step, min_, max_):
		var spin = SpinBox.new()
		
		spin.set_val(value)
		spin.set_step(step)
		spin.set_min(min_)
		spin.set_max(max_)
		parent.add_child(spin)
		
		spin.set_meta('DEFAULT', value)
		spin_boxes.push_back(spin)
		
		return spin
		
	func update_from_instance(instance):
		var tns = instance.get_translation()
		var rot = instance.get_rotation()
		var scl = instance.get_scale()
		
		emit = false
		
		spin_boxes[0].set_val(tns[Axis.X])
		spin_boxes[1].set_val(tns[Axis.Y])
		spin_boxes[2].set_val(tns[Axis.Z])
		
		spin_boxes[3].set_val(rot[Axis.X])
		spin_boxes[4].set_val(rot[Axis.Y])
		spin_boxes[5].set_val(rot[Axis.Z])
		
		spin_boxes[6].set_val(scl[Axis.X])
		spin_boxes[7].set_val(scl[Axis.Y])
		spin_boxes[8].set_val(scl[Axis.Z])
		
		emit = true
		
	func default():
		emit = false
		
		for s in spin_boxes:
			s.set_val(s.get_meta('DEFAULT'))
			
		emit = true
		
	func clear():
		default()
		
	func _init():
		set_name("Transform")
		set_v_size_flags(SIZE_EXPAND_FILL)
		
		var hb = add_row()
		
		add_label(hb, 'Translation')
		
		hb = add_row()
		
		var tx = add_spinbox(hb, 'x', 0, 0.1, -500, 500)
		var ty = add_spinbox(hb, 'y', 0, 0.1, -500, 500)
		var tz = add_spinbox(hb, 'z', 0, 0.1, -500, 500)
		
		tx.connect("value_changed", self, "set_translation", [Axis.X])
		ty.connect("value_changed", self, "set_translation", [Axis.Y])
		tz.connect("value_changed", self, "set_translation", [Axis.Z])
		
		add_spacer(self)
		hb = add_row()
		
		add_label(hb, 'Rotation')
		
		hb = add_row()
		
		var rx = add_spinbox(hb, 'x', 0, 1, -360, 360) 
		var ry = add_spinbox(hb, 'y', 0, 1, -360, 360) 
		var rz = add_spinbox(hb, 'z', 0, 1, -360, 360) 
		
		rx.connect("value_changed", self, "set_rotation", [Axis.X])
		ry.connect("value_changed", self, "set_rotation", [Axis.Y])
		rz.connect("value_changed", self, "set_rotation", [Axis.Z])
		
		add_spacer(self)
		hb = add_row()
		
		add_label(hb, 'Scale')
		
		hb = add_row()
		
		var sx = add_spinbox(hb, 'x', 1, 0.1, -100, 100)
		var sy = add_spinbox(hb, 'y', 1, 0.1, -100, 100)
		var sz = add_spinbox(hb, 'z', 1, 0.1, -100, 100)
		
		sx.connect("value_changed", self, "set_scale", [Axis.X])
		sy.connect("value_changed", self, "set_scale", [Axis.Y])
		sz.connect("value_changed", self, "set_scale", [Axis.Z])
		
# End TransformDialog

class ModifierDialog:
	extends VBoxContainer
	
	const Tool = {
		ERASE = 0,
		MOVEUP = 1,
		MOVEDOWN = 2
	}
	
	var modifiers
	var menu
	var remove
	var move_up
	var move_down
	
	var items = []
	
	var modifiers_scripts = {}
	
	signal modifier_edited
	
	func get_items():
		return items
		
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
			
		items.push_back(item)
		
	func get_modifier_values(item):
		var values = []
		
		var i = item.get_children()
		
		while i:
			var cell = i.get_cell_mode(1)
			
			if cell == i.CELL_MODE_STRING:
				values.push_back(i.get_text(1))
				
			elif cell == i.CELL_MODE_CHECK:
				values.push_back(i.is_checked(1))
				
			elif cell == i.CELL_MODE_RANGE:
				values.push_back(i.get_range(1))
				
			elif cell == i.CELL_MODE_CUSTOM:
				values.push_back(i.get_metadata(1))
				
			i = i.get_next()
			
		return values
		
	func modifier_tools(what):
		var item = modifiers.get_selected()
		
		if what == Tool.MOVEUP:
			if item.get_prev() != null:
				item.move_to_top()
				
		elif what == Tool.MOVEDOWN:
			if item.get_next() != null:
				item.move_to_bottom()
				
		elif what == Tool.ERASE:
			items.erase(item)
			item.get_parent().remove_child(item)
			
			remove.set_disabled(true)
			move_up.set_disabled(true)
			move_down.set_disabled(true)
			
		modifiers.update()
		
		emit_signal("modifier_edited")
		
	func update():
		modifiers.clear()
		
		items.clear()
		
		modifiers.set_hide_root(true)
		modifiers.set_columns(2)
		modifiers.set_column_min_width(0, 2)
		
		modifiers.create_item()
		
	func update_menu(scripts):
		menu.clear()
		
		modifiers_scripts = scripts
		
		var keys = modifiers_scripts.keys()
		keys.sort()
		
		for m in keys:
			menu.add_item(m)
			
	func clear():
		items.clear()
		modifiers.clear()
		
		modifiers_scripts.clear()
		
	func _add_modifier(id):
		var mod = menu.get_item_text(menu.get_item_index(id))
		
		create_modifier(modifiers_scripts[mod])
		
		emit_signal("modifier_edited")
		
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
			
	func _init(base):
		set_name("Modifiers")
		
		var hbox_tools = HBoxContainer.new()
		add_child(hbox_tools)
		hbox_tools.set_h_size_flags(SIZE_EXPAND_FILL)
		
		modifiers = Tree.new()
		add_child(modifiers)
		modifiers.set_v_size_flags(SIZE_EXPAND_FILL)
		
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
		
		remove.connect("pressed", self, "modifier_tools", [Tool.ERASE])
		move_up.connect("pressed", self, "modifier_tools", [Tool.MOVEUP])
		move_down.connect("pressed", self, "modifier_tools", [Tool.MOVEDOWN])
		
		modifiers.connect("item_edited", self, "_item_edited")
		modifiers.connect("cell_selected", self, "_item_selected")
		
# End ModifierDialog

class ParameterDialog:
	extends VBoxContainer
	
	var parameters
	var smooth_button
	var reverse_button
	
	signal parameter_edited
	
	func get_smooth():
		return smooth_button.is_pressed()
		
	func get_reverse():
		return reverse_button.is_pressed()
		
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
		var values = []
		
		var item = parameters.get_root().get_children()
		
		while item:
			var cell = item.get_cell_mode(1)
			
			var val
			
			if cell == item.CELL_MODE_CHECK:
				val = item.is_checked(1)
				
			elif cell == item.CELL_MODE_STRING:
				val = item.get_text(1)
				
			elif cell == item.CELL_MODE_RANGE:
				val = item.get_range(1)
				
			elif cell == item.CELL_MODE_CUSTOM:
				val = item.get_metadata(1)
				
			if item.is_selectable(1):
				values.push_back(val)
				
			item = item.get_next()
			
		return values
		
	func clear():
		parameters.clear()
		
	func _item_edited():
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
		
# End ParameterDialog

class MeshPopup:
	extends AcceptDialog
	
	var index = 0
	
	# Containers
	var main_vbox
	var main_panel
	var color_hb
	
	var options
	var color
	var parameter_dialog
	var modifier_dialog
	var transform_dialog
	
	signal cancel
	signal display_changed(color)
	
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
			
	func update():
		color.set_color(Color(0,1,0))
		
		set_current_dialog(0)
		
		popup_centered(Vector2(220, 240))
		
	func update_options():
		options.clear()
		
		for i in main_panel.get_children():
			options.add_item(i.get_name())
			
	func hide_color_button():
		color_hb.hide()
		
	func clear(dialogs = false):
		if dialogs:
			parameter_dialog.clear()
			modifier_dialog.clear()
			transform_dialog.clear()
			
	func _color_changed(color):
		emit_signal("display_changed", color)
		
	func _cancel():
		emit_signal("cancel")
		
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
		options.set_custom_minimum_size(Vector2(100,0))
		options.connect("item_selected", self, "set_current_dialog")
		
		var s = Control.new()
		hb.add_child(s)
		s.set_h_size_flags(SIZE_EXPAND_FILL)
		
		color_hb = HBoxContainer.new()
		hb.add_child(color_hb)
		
		var l = Label.new()
		l.set_text("Display")
		color_hb.add_child(l)
		
		color = ColorPickerButton.new()
		color.set_color(Color(0,1,0))
		color.set_edit_alpha(false)
		color_hb.add_child(color)
		
		var s = color.get_minimum_size()
		
		color.set_custom_minimum_size(Vector2(s.y, s.y))
		
		color.connect("color_changed", self, "_color_changed")
		
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
		
		var cancel = add_cancel("Cancel")
		
		cancel.connect("pressed", self, "_cancel")
		
# End MeshPopup

class AddPrimitives:
	extends HBoxContainer
	
	var last_module = ""
	
	var popup_menu
	var mesh_popup
	
	var node
	var mesh_instance
	
	var original_mesh
	var meshes_to_modify = []
	
	var current_script
	
	var mesh_scripts = {}
	var modifiers = {}
	var extra_modules = {}
	
	# Utilites
	var dir 
	
	# Get plugin folder path
	static func get_data_dir():
		var path
		
		# X11 and OSX
		if OS.has_environment('HOME'):
			path = OS.get_environment('HOME') + '/.godot'
			 
		# Windows
		elif OS.has_environment('APPDATA'):
			path = OS.get_environment('APPDATA') + '/Godot'
			
		path += '/plugins/Add Primitives'
		
		return path
		
	func get_object():
		return node
		
	func get_mesh_instance():
		return mesh_instance
		
	func get_mesh_popup():
		return mesh_popup
		
	func edit(object):
		node = object
		
	func update_menu():
		popup_menu.clear()
		
		for c in popup_menu.get_children():
			if c.get_type() == 'PopupMenu':
				c.queue_free()
				
		var submenus = {}
		
		var path = get_data_dir()
		
		var scripts = dir.get_file_list(path + '/meshes')
		
		scripts = dir.get_scripts_from_list(scripts)
		scripts.sort()
		
		for name in scripts:
			var key = name.basename().replace('_', ' ').capitalize()
			
			mesh_scripts[key] = path + '/meshes/' + name
			
			var temp_script = load(mesh_scripts[key]).new()
			
			if temp_script.has_method('container'):
				var container = temp_script.container()
				
				container = container.replace(' ', '_').to_lower()
				
				if not submenus.has(container):
					submenus[container] = []
					
				submenus[container].push_back(key)
				
			else:
				popup_menu.add_item(key)
				
		if submenus.size():
			popup_menu.add_separator()
			
			for i in submenus.keys():
				var submenu = PopupMenu.new()
				submenu.set_name(i)
				popup_menu.add_child(submenu)
				
				var n = i.replace('_', ' ')
				n = n.capitalize()
				
				popup_menu.add_submenu_item(n, i)
				
				if not submenu.is_connected("item_pressed", self, "popup_signal"):
					submenu.connect("item_pressed", self, "popup_signal", [submenu])
					
				for j in submenus[i]:
					submenu.add_item(j)
					
		load_modules()
		
		if not extra_modules.empty():
			popup_menu.add_separator()
			
			for module in extra_modules:
				popup_menu.add_item(module)
				
		popup_menu.add_separator()
		
		popup_menu.add_icon_item(get_icon('Edit', 'EditorIcons'), 'Edit Primitive')
		
		if not mesh_instance:
			popup_menu.set_item_disabled(popup_menu.get_item_count() - 1, true)
			
		popup_menu.add_icon_item(get_icon('Reload', 'EditorIcons'), 'Reload')
		
		if not popup_menu.is_connected("item_pressed", self, "popup_signal"):
			popup_menu.connect("item_pressed", self, "popup_signal", [popup_menu])
			
	func load_modules():
		extra_modules.clear()
		
		var path = get_data_dir() + '/modules'
		
		var modules = dir.get_file_list(path)
		modules = dir.get_scripts_from_list(modules)
		
		for mod in modules:
			var temp = load(path + '/' + mod)
			
			if temp.can_instance():
				temp = temp.new(self)
				
				extra_modules[temp.get_name()] = temp
				
		modules.clear()
		
	func popup_signal(id, menu):
		popup_menu.hide()
		
		var command = menu.get_item_text(menu.get_item_index(id))
		
		if command == 'Edit Primitive':
			if last_module:
				module_call(extra_modules[last_module], "edit_primitive")
				
				return
				
			if not mesh_instance:
				return
				
			mesh_popup.get_transform_dialog().update_from_instance(mesh_instance)
			
			mesh_popup.update()
			
			if mesh_instance.get_material_override():
				mesh_popup.hide_color_button()
				
			else:
				create_diplay_material(mesh_instance)
				
			update_mesh()
			
		elif command == 'Reload':
			update_menu()
			
		elif extra_modules.has(command):
			module_call(extra_modules[command], "exec", node)
			
			last_module = command
			
			_set_edit_disabled(false)
			
		else:
			if last_module:
				module_call(extra_modules[last_module], "clear")
				
			last_module = ""
			
			current_script = load(mesh_scripts[command]).new()
			
			if current_script.has_method('build_mesh'):
				add_mesh_instance()
				mesh_instance.set_name(command)
				
				if current_script.has_method('mesh_parameters'):
					mesh_popup(command)
					
					update_mesh()
					
				else:
					var mesh = current_script.build_mesh()
					
					mesh_instance.set_mesh(mesh)
					mesh.set_name(mesh_instance.get_name().to_lower())
					
	func module_call(object, method, arg=null):
		if not object:
			return
			
		if object.has_method(method):
			if arg:
				object.call(method, arg)
			else:
				object.call(method)
				
	func mesh_popup(key):
		mesh_popup.set_title('New ' + key)
		
		mesh_popup.update()
		mesh_popup.get_parameter_dialog().create_parameters(current_script)
		
		mesh_popup.get_modifier_dialog().update_menu(modifiers)
		mesh_popup.get_modifier_dialog().update()
		
		create_diplay_material(mesh_instance)
		
	func add_mesh_instance():
		mesh_instance = MeshInstance.new()
		
		var root = get_tree().get_edited_scene_root()
		node.add_child(mesh_instance)
		mesh_instance.set_owner(root)
		
		# Update transform dialog to default
		mesh_popup.get_transform_dialog().default()
		
		_set_edit_disabled(false)
		
	func remove_mesh_instace():
		if mesh_instance.is_inside_tree():
			_set_edit_disabled(true)
			
			mesh_instance.queue_free()
			
	func update_mesh():
		var values = mesh_popup.get_parameter_dialog().get_parameters_values(current_script)
		var smooth = mesh_popup.get_parameter_dialog().get_smooth()
		var reverse = mesh_popup.get_parameter_dialog().get_reverse()
		
		original_mesh = current_script.build_mesh(values, smooth, reverse)
		
		assert( original_mesh.is_type('Mesh') )
		
		original_mesh.set_name(mesh_instance.get_name().to_lower())
		mesh_instance.set_mesh(original_mesh)
		
		modify_mesh()
		
	func modify_mesh():
		var modifier = mesh_popup.get_modifier_dialog()
		
		meshes_to_modify.clear()
		
		var count = 0
		
		mesh_instance.set_mesh(original_mesh)
		
		for item in modifier.get_items():
			if item.is_checked(1):
				count += 1
				
				var script = modifiers[item.get_metadata(0)]
				
				var values = modifier.get_modifier_values(item)
				
				assert( not values.empty() or mesh_instance.get_mesh() )
				
				var aabb = mesh_instance.get_aabb()
				
				if count == 1:
					mesh_instance.set_mesh(script.modifier(values, aabb, original_mesh))
					
				elif count > 1:
					meshes_to_modify.resize(count - 1)
					meshes_to_modify[count - 2] = mesh_instance.get_mesh()
					
					mesh_instance.set_mesh(meshes_to_modify[count - 2])
					mesh_instance.set_mesh(script.modifier(values, aabb, meshes_to_modify[count - 2]))
					
			if count == 0:
				mesh_instance.set_mesh(original_mesh)
				
		mesh_instance.get_mesh().set_name(mesh_instance.get_name().to_lower())
		
	func transform_mesh(what):
		if what == 0:
			var val = mesh_popup.get_transform_dialog().get_translation()
			
			mesh_instance.set_translation(val)
			
		elif what == 1:
			var val = mesh_popup.get_transform_dialog().get_rotation()
			
			mesh_instance.set_rotation(val)
			
		elif what == 2:
			var val = mesh_popup.get_transform_dialog().get_scale()
			
			mesh_instance.set_scale(val)
			
	func create_diplay_material(instance):
		var fixed_material = FixedMaterial.new()
		fixed_material.set_parameter(fixed_material.PARAM_DIFFUSE, Color(0,1,0))
		
		instance.set_material_override(fixed_material)
		
		return fixed_material
		
	func set_display_color(color):
		if mesh_popup.is_visible() and mesh_instance.is_type("MeshInstance"):
			var mat = mesh_instance.get_material_override()
			
			if mat:
				mat.set_parameter(mat.PARAM_DIFFUSE, color)
				
	func _set_edit_disabled(disable):
		popup_menu.set_item_disabled(popup_menu.get_item_count() - 2, disable)
		
	func _mesh_popup_hide():
		if mesh_instance:
			if mesh_instance.get_material_override():
				mesh_instance.set_material_override(null)
				
		original_mesh = null
		meshes_to_modify.clear()
		
	func _exit_tree():
		popup_menu.clear()
		
		mesh_popup.clear(true)
		
		original_mesh = null
		meshes_to_modify.clear()
		
		mesh_scripts.clear()
		extra_modules.clear()
		modifiers.clear()
		
	func _init(editor_plugin, base):
		dir = DirectoryUtilities.new()
		
		var separator = VSeparator.new()
		add_child(separator)
		
		var spatial_menu = MenuButton.new()
		popup_menu = spatial_menu.get_popup()
		popup_menu.set_custom_minimum_size(Vector2(140, 0))
		var icon = preload('icon_mesh_instance_add.png')
		spatial_menu.set_button_icon(icon)
		spatial_menu.set_tooltip("Add New Primitive")
		
		add_child(spatial_menu)
		
		editor_plugin.add_custom_control(CONTAINER_SPATIAL_EDITOR_MENU, self)
		
		update_menu()
		
		mesh_popup = MeshPopup.new(base)
		base.add_child(mesh_popup)
		
		mesh_popup.connect("cancel", self, "remove_mesh_instace")
		mesh_popup.connect("display_changed", self, "set_display_color")
		mesh_popup.connect("popup_hide", self, "_mesh_popup_hide")
		
		mesh_popup.get_parameter_dialog().connect("parameter_edited", self, "update_mesh")
		mesh_popup.get_modifier_dialog().connect("modifier_edited", self, "modify_mesh")
		mesh_popup.get_transform_dialog().connect("transform_changed", self, "transform_mesh")
		
		# Load modifiers
		var m_path = get_data_dir() + '/modifiers.gd'
		
		var temp = load(m_path).new()
		var t_mod = temp.get_modifiers()
		
		for m in t_mod:
			modifiers[m] = t_mod[m].new()
			
# End AddPrimitives

var add_primitives
var gui_base

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
	gui_base = get_node("/root/EditorNode").get_gui_base()
	
	add_primitives = AddPrimitives.new(self, gui_base)
	
	add_primitives.hide()
	
func _exit_tree():
	edit(null)
	add_primitives.get_mesh_popup().queue_free()
	add_primitives.queue_free()
	
func _init():
	print("ADD PRIMITIVES INIT")
	
