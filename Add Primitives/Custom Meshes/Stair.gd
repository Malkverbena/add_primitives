extends "StaticMeshBuilder.gd"

func build_plane(start, end, offset = Vector3(0, 0, 0)):
	var verts = []
	verts.append(Vector3(0,0,0) + offset)
	verts.append(Vector3(0,0,0) + start + end + offset)
	verts.append(Vector3(0,0,0) + end + offset)
	verts.append(Vector3(0,0,0) + start + offset)

	return verts

func add_to_menu(menu, name):
	var submenu = menu.get_node('custom_meshes')
	submenu.add_item('Add ' + name)

func _add_tree_range(tree_item, text, value, _min = 1, _max = 100, step = 1):
	tree_item.set_text(0, text)
	tree_item.set_cell_mode(1, 2)
	tree_item.set_range(1, value)
	tree_item.set_range_config(1, _min, _max, step)
	tree_item.set_editable(1, true)

func mesh_parameters(settings):
	var parameters = []
	parameters.append(settings.create_item())
	parameters[0].set_text(0, "Custom Mesh")
	parameters.append(settings.create_item(parameters[0]))
	_add_tree_range(parameters[1], "Steps", 10)
	parameters.append(settings.create_item(parameters[0]))
	_add_tree_range(parameters[2], "Width", 5)
	parameters.append(settings.create_item(parameters[0]))
	_add_tree_range(parameters[3], "Step Heigth", 1, 0.1, 100, 0.1)
	parameters.append(settings.create_item(parameters[0]))
	_add_tree_range(parameters[4], "Step Length", 1, 0.1, 100, 0.1)
	
	return parameters

func build_mesh(params, smooth = false, reverse = false):
	if params == 'default':
		params = [10, 5, 1, 1]
	begin(4)
	add_smooth_group(smooth)
	for i in range(0 , params[0]):
		add_quad(build_plane(Vector3(params[1], 0, 0), Vector3(0, 0, params[3]),\
		                     Vector3(0, float(i*params[2]) + params[2], i * params[3])), null, not reverse)
		add_quad(build_plane(Vector3(params[1], 0, 0), Vector3(0,  float(-params[2]),  0),\
		                     Vector3(0, float(i*params[2]) + params[2], i * params[3])), null, reverse)
		add_quad(build_plane(Vector3(0, 0, params[3]), Vector3(0,  float(-i * params[2]) - params[2],  0),\
		                     Vector3(0, float(i*params[2]) + params[2], i * params[3])), null, not reverse)
		add_quad(build_plane(Vector3(0, 0, params[3]), Vector3(0,  float(-i * params[2]) - params[2],  0),\
		                     Vector3(params[1], float(i*params[2]) + params[2], i * params[3])), null, reverse)
	generate_normals()
	var mesh = commit()
	clear()
	
	return mesh
	
func register():
	print('register')
