extends "builder/mesh_builder.gd"

func build_mesh(params, smooth = false, smooth = false):
	if params == DEFAULT:
		params = [10, 1, 0.2, 0.2, true, true]
		
	var steps = params[0]
	var width = params[1]
	var height = params[2]
	var length = params[3]
	var fill_end = params[4]
	var fill_bottom = params[5]
	
	begin(4)
	add_smooth_group(false)
	
	for i in range(steps):
		add_quad(build_plane_verts(Vector3(width, 0, 0), Vector3(0, 0, length), Vector3(0, (i+1) * height, i * length)), [], true)
		add_quad(build_plane_verts(Vector3(width, 0, 0), Vector3(0, height, 0), Vector3(0, i * height, i * length)), [], true)
		add_quad(build_plane_verts(Vector3(0, (i+1)*height, 0), Vector3(0, 0, length), Vector3(0, 0, i * length)), [], true)
		add_quad(build_plane_verts(Vector3(0, (i+1)*height, 0), Vector3(0, 0, length), Vector3(width, 0, i * length)))
		
	if fill_end:
		add_quad(build_plane_verts(Vector3(width, 0, 0), Vector3(0, steps * height, 0), Vector3(0, 0, steps*length)))
	if fill_bottom:
		add_quad(build_plane_verts(Vector3(width, 0, 0), Vector3(0, 0, steps * length)))
		
	generate_normals()
	var mesh = commit()
	clear()
	
	return mesh
	
func mesh_parameters(parameters):
	add_tree_range(parameters, 'Steps', 10, 1, 1, 100)
	add_tree_range(parameters, 'Step Width', 1, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Step Height', 0.2, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Step Length', 0.2, 0.1, 0.1, 100)
	add_tree_empty(parameters)
	add_tree_check(parameters, 'Fill End', true)
	add_tree_check(parameters, 'Fill Bottom', true)

func container():
	return "Add Stair"
