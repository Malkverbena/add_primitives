extends SurfaceTool

func add_tri(vertex_array, uv_array = null, reverse = false):
	if vertex_array.size() == 3:
		var face_index = [0,1,2]
		
		if reverse:
			face_index.invert()
		
		for idx in face_index:
			if uv_array != null:
				add_uv(uv_array[idx])
			add_vertex(vertex_array[idx])
			
func add_quad(vertex_array, uv_array = null, reverse = false):
	if vertex_array.size() == 4:
		var face_index = [0,1,2,0,2,3]
		
		if reverse:
			face_index.invert()
		
		for idx in face_index:
			if uv_array != null:
				add_uv(uv_array[idx])
			add_vertex(vertex_array[idx])
			
func build_plane_verts(start, end, offset = Vector3(0,0,0)):
	var verts = []
	verts.append(Vector3(0,0,0) + offset + end)
	verts.append(Vector3(0,0,0) + offset + end + start)
	verts.append(Vector3(0,0,0) + offset + start)
	verts.append(Vector3(0,0,0) + offset)
	return verts
	
func build_circle_verts(pos, segments, radius = 1, rotation = null):
	var radians_circle = PI * 2
	var _radius = Vector3(radius, 1, radius)
	
	var circle_verts = []
	
	for i in range(segments):
		var angle = radians_circle * i/segments
		var x = cos(angle)
		var z = sin(angle)
		
		var vector = Vector3(x, 0, z)
		
		circle_verts.append((vector * _radius) + pos)
	
	return circle_verts
	
#Tree Item helper functions
func _create_item(tree):
	var root = tree.get_root()
	if not root:
		root = tree.create_item()
		
	var item = tree.create_item(root)
	return item
	
func add_tree_range(tree, text, value, _min = 1, _max = 100, step = 1):
	var tree_item = _create_item(tree)
	
	tree_item.set_text(0, text)
	tree_item.set_cell_mode(1, 2)
	tree_item.set_range(1, value)
	tree_item.set_range_config(1, _min, _max, step)
	tree_item.set_editable(1, true)
	
func add_tree_check(tree, text, checked = false):
	var tree_item = _create_item(tree)
	
	tree_item.set_text(0, text)
	tree_item.set_cell_mode(1, 1)
	tree_item.set_checked(1, checked)
	tree_item.set_editable(1, true)
	
func add_tree_entry(tree, text, string = ''):
	var tree_item = _create_item(tree)
	
	tree_item.set_text(0, text)
	tree_item.set_cell_mode(1, 0)
	tree_item.set_text(1, string)
	tree_item.set_editable(1, true)
