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

extends MeshDataTool

#Tree Item helper functions
func _create_item(item, tree):
	item = tree.create_item(item)
	
	return item
	
func add_tree_range(item, tree, text, value, step = 1, _min = 1, _max = 50):
	var tree_item = _create_item(item, tree)
	
	tree_item.set_text(0, text)
	tree_item.set_cell_mode(1, 2)
	tree_item.set_range(1, value)
	tree_item.set_range_config(1, _min, _max, step)
	tree_item.set_editable(1, true)
	
func add_tree_combo(item, tree, text, items, selected = 0):
	var tree_item = _create_item(item, tree)
	
	tree_item.set_text(0, text)
	tree_item.set_cell_mode(1, 2)
	tree_item.set_text(1, items)
	tree_item.set_range(1, selected)
	tree_item.set_editable(1, true)
	
func add_tree_check(item, tree, text, checked = false):
	var tree_item = _create_item(item, tree)
	
	tree_item.set_text(0, text)
	tree_item.set_cell_mode(1, 1)
	tree_item.set_checked(1, checked)
	tree_item.set_text(1, 'On')
	tree_item.set_editable(1, true)
	
func add_tree_entry(item, tree, text, string = ''):
	var tree_item = _create_item(item, tree)
	
	tree_item.set_text(0, text)
	tree_item.set_cell_mode(1, 0)
	tree_item.set_text(1, string)
	tree_item.set_editable(1, true)
