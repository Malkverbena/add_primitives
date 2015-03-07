extends "builder/mesh_builder.gd"
	
func build_mesh(params, smooth = false, reverse = false):
	if params == 'default':
		params = [2,2,0,0]
	var verts = []
	verts.append(Vector3(-params[1]/2,params[3],-params[0]/2))
	verts.append(Vector3(params[1]/2,params[3],-params[0]/2))
	verts.append(Vector3(params[1]/2,params[2],params[0]/2))
	verts.append(Vector3(-params[1]/2,params[2],params[0]/2))
	
	var uv = []
	uv.append(Vector2(1, 1))
	uv.append(Vector2(0, 1))
	uv.append(Vector2(0, 0))
	uv.append(Vector2(1, 0))
	
	begin(4)
	add_smooth_group(smooth)
	add_quad(verts, uv, reverse)
	generate_normals()
	
	var mesh = commit()
	clear()
	return mesh
	
func add_tree_range(tree_item, text, value, _min = 1, _max = 100, step = 1):
	tree_item.set_text(0, text)
	tree_item.set_cell_mode(1, 2)
	tree_item.set_range(1, value)
	tree_item.set_range_config(1, _min, _max, step)
	tree_item.set_editable(1, true)

func mesh_parameters(settings, name = 'Add Mesh'):
	var parameters = []
	parameters.append(settings.create_item())
	parameters[0].set_text(0, name)
	parameters.append(settings.create_item(parameters[0]))
	add_tree_range(parameters[1], "Length", 2)
	parameters.append(settings.create_item(parameters[0]))
	add_tree_range(parameters[2], "Width", 2)
	parameters.append(settings.create_item(parameters[0]))
	add_tree_range(parameters[3], "Start H.", 0, -100, 100)
	parameters.append(settings.create_item(parameters[0]))
	add_tree_range(parameters[4], "End H.", 0, -100, 100)
	