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

#Base class for ParameterEditor and ModifierEditor
class TreeEditor extends VBoxContainer:
	
	var last = null
	
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
		
	func add_tree_empty():
		var item = tree.create_item(last)
		
		item.set_selectable(0, false)
		item.set_selectable(1, false)
		
	func add_tree_range(text, value, step = 0.001, min_ = -100, max_ = 100):
		var item = tree.create_item(last)
		
		item.set_text(0, text)
		
		if typeof(step) == TYPE_INT:
			item.set_icon(0, tree.get_icon('Integer', 'EditorIcons'))
			
		else:
			item.set_icon(0, tree.get_icon('Real', 'EditorIcons'))
			
		item.set_selectable(0, false)
		
		item.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
		item.set_range_config(1, min_, max_, step)
		item.set_range(1, value)
		item.set_editable(1, true)
		
	func add_tree_combo(text, selected, items):
		var item = tree.create_item(last)
		
		item.set_text(0, text)
		item.set_icon(0, tree.get_icon('Enum', 'EditorIcons'))
		item.set_selectable(0, false)
		
		item.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
		item.set_text(1, items)
		item.set_range(1, selected)
		item.set_editable(1, true)
		
	func add_tree_check(text, checked = false):
		var item = tree.create_item(last)
		
		item.set_text(0, text)
		item.set_icon(0, tree.get_icon('Bool', 'EditorIcons'))
		item.set_selectable(0, false)
		
		item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
		item.set_checked(1, checked)
		item.set_text(1, 'On')
		item.set_editable(1, true)
		
	func add_tree_entry(text, string = ''):
		var item = tree.create_item(last)
		
		item.set_text(0, text)
		item.set_icon(0, tree.get_icon('String', 'EditorIcons'))
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
			
		tree.clear()
		tree.create_item()
		
	func create_modifier(script):
		var root = tree.get_root()
		
		last = tree.create_item(root)
		last.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
		last.set_text(0, script.get_name())
		
		last.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
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
			var obj = instance_from_id(item.get_metadata(0))
			
			var first = items.find(obj)
			var second
			
			if what == Tool.MOVE_UP:
				second = first - 1
				
			elif what == Tool.MOVE_DOWN:
				second = first + 1
				
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
		
	func _add_modifier(id):
		var mod = menu.get_item_text(menu.get_item_index(id))
		
		create_modifier(modifiers[mod])
		
		emit_signal("modifier_edited")
		
	func _rebuild_tree(state):
		tree.clear()
		
		var root = tree.create_item()
		
		for i in range(items.size()):
			last = tree.create_item(root)
			last.set_collapsed(state[i].collapsed)
			
			last.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
			last.set_text(0, state[i].name)
			
			if state[i].selected:
				last.select(0)
				
			last.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
			last.set_text(1, 'On')
			last.set_editable(1, true)
			last.set_checked(1, state[i].checked)
			last.set_selectable(1, false)
			
			last.set_custom_bg_color(0, get_color('prop_category', 'Editor'))
			last.set_custom_bg_color(1, get_color('prop_category', 'Editor'))
			
			last.set_metadata(0, state[i].metadata)
			
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
		
		var obj = instance_from_id(edited_modifier)
		
		if obj:
			obj.set(name, value)
			
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
		add_child(hbox_tools)
		hbox_tools.set_h_size_flags(SIZE_EXPAND_FILL)
		
		tree.set_hide_root(true)
		tree.set_columns(2)
		tree.set_column_expand(0, true)
		tree.set_column_min_width(0, 30)
		tree.set_column_expand(1, true)
		tree.set_column_min_width(1, 15)
		
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
		
		# Spacer
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
		
		remove.connect("pressed", self, "_modifier_tools", [Tool.ERASE])
		move_up.connect("pressed", self, "_modifier_tools", [Tool.MOVE_UP])
		move_down.connect("pressed", self, "_modifier_tools", [Tool.MOVE_DOWN])
		
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
		
		if builder == null:
			return
			
		last = tree.create_item()
		
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
		
		add_child(tree)
		tree.set_v_size_flags(SIZE_EXPAND_FILL)
		
		var hb = HBoxContainer.new()
		add_child(hb)
		hb.set_h_size_flags(SIZE_EXPAND_FILL)
		
		smooth_button = CheckBox.new()
		smooth_button.set_text('Smooth')
		hb.add_child(smooth_button)
		smooth_button.set_h_size_flags(SIZE_EXPAND_FILL)
		
		flip_button = CheckBox.new()
		flip_button.set_text('Flip Normals')
		hb.add_child(flip_button)
		flip_button.set_h_size_flags(SIZE_EXPAND_FILL)
		
		smooth_button.connect("toggled", self, "_check_box_pressed", ['smooth'])
		flip_button.connect("toggled", self, "_check_box_pressed", ['flip_normals'])
		
		tree.connect("item_edited", self, "_item_edited")
		
# End ParameterEditor

