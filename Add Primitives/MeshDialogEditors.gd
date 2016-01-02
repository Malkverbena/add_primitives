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

# Base class for ParameterEditor and ModifierEditor
class TreeEditor extends VBoxContainer:
	
	var current = null
	
	var tree
	
	static func get_parameter_name(item):
		var name = item.get_text(0)
		
		name = name.replace(' ', '_').to_lower()
		
		return name
		
	static func get_parameter_value(item):
		var value
		
		var cell = item.get_cell_mode(1)
		
		if cell == TreeItem.CELL_MODE_CHECK:
			value = item.is_checked(1)
			
		elif cell == TreeItem.CELL_MODE_STRING:
			value = item.get_text(1)
			
		elif cell == TreeItem.CELL_MODE_RANGE:
			value = item.get_range(1)
			
		elif cell == TreeItem.CELL_MODE_CUSTOM:
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
		
	func add_empty():
		var item = tree.create_item(current)
		
		item.set_selectable(0, false)
		item.set_selectable(1, false)
		
	func add_numeric_parameter(text, value, min_ = 0.001, max_ = 100, step = 0.001):
		var item = tree.create_item(current)
		
		item.set_text(0, text.capitalize())
		
		if typeof(value) == TYPE_INT:
			item.set_icon(0, get_icon('Integer', 'EditorIcons'))
			
		else:
			item.set_icon(0, get_icon('Real', 'EditorIcons'))
			
		item.set_selectable(0, false)
		
		item.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
		item.set_range_config(1, min_, max_, step)
		item.set_range(1, value)
		item.set_editable(1, true)
		
	func add_enum_parameter(text, selected, items):
		var item = tree.create_item(current)
		
		item.set_text(0, text.capitalize())
		item.set_icon(0, get_icon('Enum', 'EditorIcons'))
		item.set_selectable(0, false)
		
		item.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
		item.set_text(1, items)
		item.set_range(1, selected)
		item.set_editable(1, true)
		
	func add_bool_parameter(text, checked = false):
		var item = tree.create_item(current)
		
		item.set_text(0, text.capitalize())
		item.set_icon(0, get_icon('Bool', 'EditorIcons'))
		item.set_selectable(0, false)
		
		item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
		item.set_checked(1, checked)
		item.set_text(1, 'On')
		item.set_editable(1, true)
		
	func add_string_parameter(text, string = ''):
		var item = tree.create_item(current)
		
		item.set_text(0, text.capitalize())
		item.set_icon(0, get_icon('String', 'EditorIcons'))
		item.set_selectable(0, false)
		
		item.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
		item.set_text(1, string)
		item.set_editable(1, true)
		
	func _init():
		tree = Tree.new()
		
# End TreeEditor

class ModifierEditor extends TreeEditor:
	
	const Tool = {
		ERASE = 0,
		MOVE_UP = 1,
		MOVE_DOWN = 2
	}
	
	var edited_modifier = null
	
	var menu
	var remove
	var move_up
	var move_down
	
	var items = []
	
	var modifiers = {}
	
	signal modifier_edited
	
	static func get_signal():
		return "modifier_edited"
		
	func get_items():
		return items
		
	func get_edited_modifier():
		if not edited_modifier:
			return null
			
		return instance_from_id(edited_modifier)
		
	func create_modifiers():
		items.clear()
		
		menu.clear()
		tree.clear()
		
		var keys = modifiers.keys()
		keys.sort()
		
		for k in keys:
			menu.add_item(k)
			
		tree.create_item()
		
	func create_modifier(script):
		var root = tree.get_root()
		
		current = tree.create_item(root)
		current.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
		current.set_text(0, script.get_name())
		
		current.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
		current.set_checked(1, true)
		current.set_text(1, 'On')
		current.set_editable(1, true)
		current.set_selectable(1, false)
		
		current.set_custom_bg_color(0, get_color('prop_category', 'Editor'))
		current.set_custom_bg_color(1, get_color('prop_category', 'Editor'))
		
		var mod = script.new()
		
		current.set_metadata(0, mod.get_instance_ID())
		
		mod.modifier_parameters(self)
		
		items.push_back(mod)
		
	func generate_state():
		var state = []
		
		var root = tree.get_root()
		
		var item = root.get_children()
		
		while item:
			var item_state = {
				name = item.get_text(0),
				metadata = item.get_metadata(0),
				selected = item.is_selected(0),
				checked = item.is_checked(1),
				collapsed = item.is_collapsed()
			}
			
			state.append(item_state)
			
			item = item.get_next()
			
		return state
		
	func clear():
		items.clear()
		tree.clear()
		
		modifiers.clear()
		
	func _modifier_tools(what):
		var item = tree.get_selected()
		
		if what == Tool.ERASE:
			var id = item.get_metadata(0)
			
			if id == edited_modifier:
				edited_modifier = null
				
			items.erase(instance_from_id(id))
			
			item.get_parent().remove_child(item)
			
			remove.set_disabled(true)
			move_up.set_disabled(true)
			move_down.set_disabled(true)
			
		if what == Tool.MOVE_UP or what == Tool.MOVE_DOWN:
			var mod = instance_from_id(item.get_metadata(0))
			
			var first = items.find(mod)
			var second = first
			
			if what == Tool.MOVE_UP:
				second -= 1
				
			elif what == Tool.MOVE_DOWN:
				second += 1
				
			var temp = items[first]
			items[first] = items[second]
			items[second] = temp
			
			var state = generate_state()
			
			temp = state[first]
			state[first] = state[second]
			state[second] = temp
			
			_rebuild_tree(state)
			_item_selected()
			
			state.clear()
			
		tree.update()
		
		emit_signal("modifier_edited")
		
	func _add_modifier(index):
		var mod = menu.get_item_text(index)
		
		create_modifier(modifiers[mod])
		
		emit_signal("modifier_edited")
		
	func _rebuild_tree(state):
		tree.clear()
		
		var root = tree.create_item()
		
		for i in range(items.size()):
			current = tree.create_item(root)
			current.set_collapsed(state[i].collapsed)
			
			current.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
			current.set_text(0, state[i].name)
			
			if state[i].selected:
				current.select(0)
				
			current.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
			current.set_text(1, 'On')
			current.set_editable(1, true)
			current.set_checked(1, state[i].checked)
			current.set_selectable(1, false)
			
			current.set_custom_bg_color(0, get_color('prop_category', 'Editor'))
			current.set_custom_bg_color(1, get_color('prop_category', 'Editor'))
			
			current.set_metadata(0, state[i].metadata)
			
			if items[i].has_method('modifier_parameters'):
				items[i].modifier_parameters(self)
				
	func _item_edited():
		var item = tree.get_edited()
		
		var parent = item.get_parent()
		
		if parent == tree.get_root():
			edited_modifier = item.get_metadata(0)
			
			emit_signal("modifier_edited")
			
			return
			
		edited_modifier = parent.get_metadata(0)
		
		var name = get_parameter_name(item)
		var value = get_parameter_value(item)
		
		var mod = instance_from_id(edited_modifier)
		
		if mod:
			mod.set(name, value)
			
		emit_signal("modifier_edited")
		
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
		
		# Load modifiers
		var temp = preload("Modifiers.gd")
		modifiers = temp.get_modifiers()
		
		var hbox_tools = HBoxContainer.new()
		hbox_tools.set_h_size_flags(SIZE_EXPAND_FILL)
		add_child(hbox_tools)
		
		var add = MenuButton.new()
		add.set_button_icon(base.get_icon('Add', 'EditorIcons'))
		add.set_tooltip("Add New Modifier")
		hbox_tools.add_child(add)
		
		menu = add.get_popup()
		menu.connect("item_pressed", self, "_add_modifier")
		
		remove = ToolButton.new()
		remove.set_button_icon(base.get_icon('Remove', 'EditorIcons'))
		remove.set_tooltip("Remove Modifier")
		remove.set_disabled(true)
		hbox_tools.add_child(remove)
		remove.connect("pressed", self, "_modifier_tools", [Tool.ERASE])
		
		# Spacer
		var s = Control.new()
		s.set_h_size_flags(SIZE_EXPAND_FILL)
		hbox_tools.add_child(s)
		
		move_up = ToolButton.new()
		move_up.set_button_icon(base.get_icon('MoveUp', 'EditorIcons'))
		move_up.set_disabled(true)
		hbox_tools.add_child(move_up)
		move_up.connect("pressed", self, "_modifier_tools", [Tool.MOVE_UP])
		
		move_down = ToolButton.new()
		move_down.set_button_icon(base.get_icon('MoveDown', 'EditorIcons'))
		move_down.set_disabled(true)
		hbox_tools.add_child(move_down)
		move_down.connect("pressed", self, "_modifier_tools", [Tool.MOVE_DOWN])
		
		tree.set_hide_root(true)
		tree.set_columns(2)
		tree.set_column_expand(0, true)
		tree.set_column_min_width(0, 30)
		tree.set_column_expand(1, true)
		tree.set_column_min_width(1, 15)
		
		tree.set_v_size_flags(SIZE_EXPAND_FILL)
		add_child(tree)
		
		tree.connect("item_edited", self, "_item_edited")
		tree.connect("cell_selected", self, "_item_selected")
		
# End ModifierEditor

class ParameterEditor extends TreeEditor:
	
	var builder
	
	var smooth_button
	var flip_button
	
	signal parameter_edited
	
	static func get_signal():
		return "parameter_edited"
		
	func edit(object):
		builder = object
		
		tree.clear()
		
		if not builder:
			return
			
		current = tree.create_item()
		
		for child in tree.get_children():
			if child extends VScrollBar:
				child.set_value(0)
				
				break
				
		builder.mesh_parameters(self)
		
		smooth_button.set_pressed(false)
		flip_button.set_pressed(false)
		
	func clear():
		tree.clear()
		
	func _check_box_pressed(pressed, name):
		builder.set(name, pressed)
		
		emit_signal("parameter_edited")
		
	func _item_edited():
		var item = tree.get_edited()
		
		var name = get_parameter_name(item)
		var value = get_parameter_value(item)
		
		if builder:
			builder.set(name, value)
			
		emit_signal("parameter_edited")
		
	func _init():
		set_name("parameters")
		
		tree.set_hide_root(true)
		tree.set_columns(2)
		tree.set_column_expand(0, true)
		tree.set_column_min_width(0, 30)
		tree.set_column_expand(1, true)
		tree.set_column_min_width(1, 15)
		
		tree.set_v_size_flags(SIZE_EXPAND_FILL)
		add_child(tree)
		
		tree.connect("item_edited", self, "_item_edited")
		
		var hb = HBoxContainer.new()
		hb.set_h_size_flags(SIZE_EXPAND_FILL)
		add_child(hb)
		
		smooth_button = CheckBox.new()
		smooth_button.set_text('Smooth')
		smooth_button.set_h_size_flags(SIZE_EXPAND_FILL)
		hb.add_child(smooth_button)
		
		flip_button = CheckBox.new()
		flip_button.set_text('Flip Normals')
		flip_button.set_h_size_flags(SIZE_EXPAND_FILL)
		hb.add_child(flip_button)
		
		smooth_button.connect("toggled", self, "_check_box_pressed", ['smooth'])
		flip_button.connect("toggled", self, "_check_box_pressed", ['flip_normals'])
		
# End ParameterEditor

