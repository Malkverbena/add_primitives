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

extends Reference

class TransformEditor:
	extends VBoxContainer
	
	var emit = true
	
	var translation = Vector3(0,0,0)
	var rotation = Vector3(0,0,0)
	var scale = Vector3(1,1,1)
	
	var spin_boxes = []
	
	signal transform_changed(what)
	
	static func get_signal():
		return "transform_changed"
		
	func set_translation(value, axis):
		translation[axis] = value
		
		if emit:
			emit_signal("transform_changed", 0)
			
	func set_rotation(value, axis):
		rotation[axis] = deg2rad(value)
		
		if emit:
			emit_signal("transform_changed", 1)
			
	func set_scale(value, axis):
		scale[axis] = value
		
		if emit:
			emit_signal("transform_changed", 2)
			
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
		
	func add_spinbox(parent, value, step, min_, max_):
		var spin = SpinBox.new()
		
		spin.set_val(value)
		spin.set_step(step)
		spin.set_min(min_)
		spin.set_max(max_)
		parent.add_child(spin)
		
		spin_boxes.push_back(spin)
		
		spin.set_h_size_flags(SIZE_EXPAND)
		
		return spin
		
	func update_from_instance(instance):
		var tns = instance.get_translation()
		var rot = instance.get_rotation()
		var scl = instance.get_scale()
		
		emit = false
		
		spin_boxes[0].set_val(tns[Vector3.AXIS_X])
		spin_boxes[1].set_val(tns[Vector3.AXIS_Y])
		spin_boxes[2].set_val(tns[Vector3.AXIS_Z])
		
		spin_boxes[3].set_val(rot[Vector3.AXIS_X])
		spin_boxes[4].set_val(rot[Vector3.AXIS_Y])
		spin_boxes[5].set_val(rot[Vector3.AXIS_Z])
		
		spin_boxes[6].set_val(scl[Vector3.AXIS_X])
		spin_boxes[7].set_val(scl[Vector3.AXIS_Y])
		spin_boxes[8].set_val(scl[Vector3.AXIS_Z])
		
		emit = true
		
	func clear():
		spin_boxes.clear()
		
	func _init():
		set_name("transform")
		set_v_size_flags(SIZE_EXPAND_FILL)
		
		var hb = add_row()
		
		add_label(hb, 'Translation:')
		
		hb = add_row()
		
		var tx = add_spinbox(hb, 0, 0.01, -500, 500)
		var ty = add_spinbox(hb, 0, 0.01, -500, 500)
		var tz = add_spinbox(hb, 0, 0.01, -500, 500)
		
		tx.connect("value_changed", self, "set_translation", [Vector3.AXIS_X])
		ty.connect("value_changed", self, "set_translation", [Vector3.AXIS_Y])
		tz.connect("value_changed", self, "set_translation", [Vector3.AXIS_Z])
		
		add_spacer(self)
		
		hb = add_row()
		
		add_label(hb, 'Rotation:')
		
		hb = add_row()
		
		var rx = add_spinbox(hb, 0, 1, -360, 360) 
		var ry = add_spinbox(hb, 0, 1, -360, 360) 
		var rz = add_spinbox(hb, 0, 1, -360, 360) 
		
		rx.connect("value_changed", self, "set_rotation", [Vector3.AXIS_X])
		ry.connect("value_changed", self, "set_rotation", [Vector3.AXIS_Y])
		rz.connect("value_changed", self, "set_rotation", [Vector3.AXIS_Z])
		
		add_spacer(self)
		
		hb = add_row()
		
		add_label(hb, 'Scale:')
		
		hb = add_row()
		
		var sx = add_spinbox(hb, 1, 0.01, -100, 100)
		var sy = add_spinbox(hb, 1, 0.01, -100, 100)
		var sz = add_spinbox(hb, 1, 0.01, -100, 100)
		
		sx.connect("value_changed", self, "set_scale", [Vector3.AXIS_X])
		sy.connect("value_changed", self, "set_scale", [Vector3.AXIS_Y])
		sz.connect("value_changed", self, "set_scale", [Vector3.AXIS_Z])
		
# End TransformEditor

#Base class for ParameterEditor and ModifierEditor
class TreeEditor:
	extends VBoxContainer
	
	var last = null
	
	var tree
	
	static func get_parameter_name(item):
		var name = item.get_text(0)
		
		name = name.replace(' ', '_').to_lower()
		
		return name
		
	static func get_parameter_value(item):
		var value
		
		var cell = item.get_cell_mode(1)
		
		if cell == item.CELL_MODE_CHECK:
			value = item.is_checked(1)
			
		elif cell == item.CELL_MODE_STRING:
			value = item.get_text(1)
			
		elif cell == item.CELL_MODE_RANGE:
			value = item.get_range(1)
			
		elif cell == item.CELL_MODE_CUSTOM:
			value = item.get_metadata(1)
			
		return value
		
	func tree_items(parent = null):
		var iterable = []
		
		var root = tree.get_root()
		
		if not root:
			return iterable
			
		if not parent:
			parent = root
			
		var item = parent.get_children()
		
		while item:
			iterable.push_back(item)
			
			item = item.get_next()
			
		return iterable
		
	func add_tree_empty():
		var item = tree.create_item(last)
		
		item.set_selectable(0, false)
		item.set_selectable(1, false)
		
	func add_tree_range(text, value, step = 0.01, min_ = -100, max_ = 100):
		var item = tree.create_item(last)
		
		item.set_text(0, text)
		
		if typeof(step) == TYPE_INT:
			item.set_icon(0, tree.get_icon('Integer', 'EditorIcons'))
		else:
			item.set_icon(0, tree.get_icon('Real', 'EditorIcons'))
		item.set_selectable(0, false)
		
		item.set_cell_mode(1, item.CELL_MODE_RANGE)
		item.set_range_config(1, min_, max_, step)
		item.set_range(1, value)
		item.set_editable(1, true)
		
	func add_tree_combo(text, selected, items):
		var item = tree.create_item(last)
		
		item.set_text(0, text)
		item.set_icon(0, tree.get_icon('Enum', 'EditorIcons'))
		item.set_selectable(0, false)
		
		item.set_cell_mode(1, item.CELL_MODE_RANGE)
		item.set_text(1, items)
		item.set_range(1, selected)
		item.set_editable(1, true)
		
	func add_tree_check(text, checked = false):
		var item = tree.create_item(last)
		
		item.set_text(0, text)
		item.set_icon(0, tree.get_icon('Bool', 'EditorIcons'))
		item.set_selectable(0, false)
		
		item.set_cell_mode(1, item.CELL_MODE_CHECK)
		item.set_checked(1, checked)
		item.set_text(1, 'On')
		item.set_editable(1, true)
		
	func add_tree_entry(text, string = ''):
		var item = tree.create_item(last)
		
		item.set_text(0, text)
		item.set_icon(0, tree.get_icon('String', 'EditorIcons'))
		item.set_selectable(0, false)
		
		item.set_cell_mode(1, item.CELL_MODE_STRING)
		item.set_text(1, string)
		item.set_editable(1, true)
		
	func _init():
		tree = Tree.new()
		
# End TreeEditor

class ModifierEditor:
	extends TreeEditor
	
	const Tool = {
		ERASE = 0,
		MOVE_UP = 1,
		MOVE_DOWN = 2,
		RELOAD = 3
	}
	
	var edited_modifier = null
	
	var menu
	var remove
	var move_up
	var move_down
	var reload
	
	var items = []
	
	var modifiers = {}
	
	signal modifier_edited(name, value)
	
	static func get_signal():
		return "modifier_edited"
		
	func get_items():
		return items
		
	func get_edited_modifier():
		if not edited_modifier:
			return null
			
		return instance_from_id(edited_modifier)
		
	func create_modifiers():
		tree.clear()
		items.clear()
		
		menu.clear()
		
		var keys = modifiers.keys()
		keys.sort()
		
		for k in keys:
			menu.add_item(k)
			
		_create_root()
		
	func create_modifier(script):
		var root = tree.get_root()
		
		last = tree.create_item(root)
		last.set_cell_mode(0, last.CELL_MODE_STRING)
		last.set_text(0, script.get_name())
		
		last.set_cell_mode(1, last.CELL_MODE_CHECK)
		last.set_checked(1, true)
		last.set_text(1, 'On')
		last.set_editable(1, true)
		last.set_selectable(1, false)
		
		last.set_custom_bg_color(0, get_color('prop_category', 'Editor'))
		last.set_custom_bg_color(1, get_color('prop_category', 'Editor'))
		
		var obj = script.new()
		
		last.set_metadata(0, obj.get_instance_ID())
		
		if obj.has_method('modifier_parameters'):
			obj.modifier_parameters(self)
			
		items.push_back(obj)
		
	func generate_cache():
		var cache = []
		
		var root = tree.get_root()
		
		var item = root.get_children()
		
		while item:
			var data = {
				name = item.get_text(0),
				metadata = item.get_metadata(0),
				is_checked = item.is_checked(1),
				is_collapsed = item.is_collapsed(),
				is_selected = item.is_selected(0)
			}
			
			cache.append(data)
			
			item = item.get_next()
			
		return cache
		
	func clear():
		items.clear()
		tree.clear()
		
		modifiers.clear()
		
	func _create_root():
		tree.clear()
		
		tree.set_hide_root(true)
		tree.set_columns(2)
		tree.set_column_min_width(0, 2)
		
		var root = tree.create_item()
		
		return root
		
	func _modifier_tools(what):
		var item = tree.get_selected()
		
		if what == Tool.ERASE:
			var id = item.get_metadata(0)
			
			if id == edited_modifier:
				edited_modifier = null
				
			items.erase(instance_from_id(id))
			
			item.get_parent().remove_child(item)
			
			if items.empty() and not reload.is_disabled():
				reload.set_disabled(true)
				
			remove.set_disabled(true)
			
		if what == Tool.MOVE_UP or what == Tool.MOVE_DOWN:
			var obj = instance_from_id(item.get_metadata(0))
			
			var first = items.find(obj)
			var second
			
			if what == Tool.MOVE_UP:
				second = first - 1
				
			elif what == Tool.MOVE_DOWN:
				second = first + 1
				
			var temp = items[second]
			items[second] = items[first]
			items[first] = temp
			
			var cache = generate_cache()
			
			temp = cache[second]
			cache[second] = cache[first]
			cache[first] = temp
			
			_rebuild_tree(cache)
			
			_item_selected()
			
			cache.clear()
			
		tree.update()
		
		emit_signal("modifier_edited", "", null)
		
	func _add_modifier(id):
		var mod = menu.get_item_text(menu.get_item_index(id))
		
		create_modifier(modifiers[mod])
		
		if items.size() and reload.is_disabled():
			reload.set_disabled(false)
			
		emit_signal("modifier_edited", "", null)
		
	func _rebuild_tree(cache):
		var root = _create_root()
		
		for i in range(items.size()):
			last = tree.create_item(root)
			last.set_collapsed(cache[i].is_collapsed)
			
			last.set_cell_mode(0, last.CELL_MODE_STRING)
			last.set_text(0, cache[i].name)
			
			if cache[i].is_selected:
				last.select(0)
				
			last.set_cell_mode(1, last.CELL_MODE_CHECK)
			last.set_checked(1, cache[i].is_checked)
			last.set_text(1, 'On')
			last.set_editable(1, true)
			last.set_selectable(1, false)
			
			last.set_custom_bg_color(0, get_color('prop_category', 'Editor'))
			last.set_custom_bg_color(1, get_color('prop_category', 'Editor'))
			
			last.set_metadata(0, cache[i].metadata)
			
			if items[i].has_method('modifier_parameters'):
				items[i].modifier_parameters(self)
				
	func _item_edited():
		var item = tree.get_edited()
		
		var parent = item.get_parent()
		
		if parent == tree.get_root():
			edited_modifier = item.get_metadata(0)
			
			emit_signal("modifier_edited", "", null)
			
		edited_modifier = parent.get_metadata(0)
		
		var name = get_parameter_name(item)
		var value = get_parameter_value(item)
		
		emit_signal("modifier_edited", name, value)
		
	func _item_selected():
		var item = tree.get_selected()
		
		if item.get_parent() == tree.get_root():
			remove.set_disabled(false)
			move_up.set_disabled(item.get_prev() == null)
			move_down.set_disabled(item.get_next() == null)
			
		else:
			remove.set_disabled(true)
			move_up.set_disabled(true)
			move_down.set_disabled(true)
			
	func _init(base):
		set_name("modifiers")
		
		var hbox_tools = HBoxContainer.new()
		add_child(hbox_tools)
		hbox_tools.set_h_size_flags(SIZE_EXPAND_FILL)
		
		add_child(tree)
		tree.set_v_size_flags(SIZE_EXPAND_FILL)
		
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
		move_up.set_disabled(true)
		hbox_tools.add_child(move_up)
		
		move_down = ToolButton.new()
		move_down.set_button_icon(base.get_icon('MoveDown', 'EditorIcons'))
		move_down.set_disabled(true)
		hbox_tools.add_child(move_down)
		
		reload = ToolButton.new()
		reload.set_button_icon(base.get_icon('Reload', 'EditorIcons'))
		reload.set_tooltip("Reload Modifiers")
		reload.set_disabled(true)
		hbox_tools.add_child(reload)
		
		remove.connect("pressed", self, "_modifier_tools", [Tool.ERASE])
		move_up.connect("pressed", self, "_modifier_tools", [Tool.MOVE_UP])
		move_down.connect("pressed", self, "_modifier_tools", [Tool.MOVE_DOWN])
		reload.connect("pressed", self, "_modifier_tools", [Tool.RELOAD])
		
		tree.connect("item_edited", self, "_item_edited")
		tree.connect("cell_selected", self, "_item_selected")
		
# End ModifierEditor

class ParameterEditor:
	extends TreeEditor
	
	var smooth = false
	var invert = false
	
	var smooth_button
	var invert_button
	
	signal parameter_edited(name, value)
	
	static func get_signal():
		return "parameter_edited"
		
	func create_parameters(script):
		tree.clear()
		
		tree.set_hide_root(true)
		tree.set_columns(2)
		tree.set_column_titles_visible(true)
		tree.set_column_title(0, 'Parameter')
		tree.set_column_title(1, 'Value')
		tree.set_column_min_width(0, 2)
		
		last = tree.create_item()
		
		script.mesh_parameters(self)
		
		smooth = false
		invert = false
		
		smooth_button.set_pressed(false)
		invert_button.set_pressed(false)
		
	func clear():
		tree.clear()
		
	func _check_box_pressed(pressed, name):
		set(name, pressed)
		
		emit_signal("parameter_edited", "", null)
		
	func _item_edited():
		var item = tree.get_edited()
		
		var name = get_parameter_name(item)
		var value = get_parameter_value(item)
		
		emit_signal("parameter_edited", name, value)
		
	func _init():
		set_name("parameters")
		
		add_child(tree)
		tree.set_v_size_flags(SIZE_EXPAND_FILL)
		
		var hb = HBoxContainer.new()
		add_child(hb)
		hb.set_h_size_flags(SIZE_EXPAND_FILL)
		
		smooth_button = CheckBox.new()
		smooth_button.set_text('Smooth')
		hb.add_child(smooth_button)
		smooth_button.set_h_size_flags(SIZE_EXPAND_FILL)
		
		invert_button = CheckBox.new()
		invert_button.set_text('Invert Normals')
		hb.add_child(invert_button)
		invert_button.set_h_size_flags(SIZE_EXPAND_FILL)
		
		smooth_button.connect("toggled", self, "_check_box_pressed", ['smooth'])
		invert_button.connect("toggled", self, "_check_box_pressed", ['invert'])
		
		tree.connect("item_edited", self, "_item_edited")
		
# End ParameterEditor

