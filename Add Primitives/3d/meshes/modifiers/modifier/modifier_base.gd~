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