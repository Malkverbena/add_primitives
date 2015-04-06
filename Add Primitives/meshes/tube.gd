extends "builder/mesh_builder.gd"

func build_mesh(params, smooth = false, reverse = false):
	if params == DEFAULT:
		params = [2, 0.5, 1.0, 16]
	var height = params[0]
	var radius_inner = params[1]
	var radius_outer = params[2]
	var steps = params[3]
	
	var inner_circle = build_circle_verts(Vector3(0,0,0), steps, radius_inner)
	var outer_circle = build_circle_verts(Vector3(0,0,0), steps, radius_outer)
	
	begin(4)
	add_smooth_group(false)
	
	var off = Vector3(0, height/2, 0)
	
	for idx in range(steps):
		add_quad([outer_circle[idx + 1] + off, inner_circle[idx + 1] + off, inner_circle[idx] + off, outer_circle[idx] + off], [], reverse)
		add_quad([outer_circle[idx] - off, inner_circle[idx] - off, inner_circle[idx + 1] - off, outer_circle[idx + 1] - off], [], reverse)
	
	add_smooth_group(smooth)
	
	for idx in range(steps):
		add_quad([outer_circle[idx + 1] + off, outer_circle[idx] + off, outer_circle[idx] - off, outer_circle[idx + 1] -off], [], reverse)
		add_quad([inner_circle[idx] + off, inner_circle[idx + 1] + off, inner_circle[idx + 1] - off, inner_circle[idx] -off], [], reverse)
		
	generate_normals()
	var mesh = commit()
	clear()
	
	return mesh

func mesh_parameters(parameters):
	add_tree_range(parameters, 'Height', 2, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Inner Radius', 0.5, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Outer Radius', 1, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Steps', 16, 1, 1, 50)
