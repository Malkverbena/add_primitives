extends "builder/MeshBuilder.gd"

static func get_name():
	return "Tube"
	
func build_mesh(params, smooth = false, reverse = false):
	var height = params[0]
	var radius_inner = params[1]
	var radius_outer = params[2]
	var steps = params[3]
	
	var inner_circle = build_circle_verts(Vector3(0,0,0), steps, radius_inner)
	var outer_circle = build_circle_verts(Vector3(0,0,0), steps, radius_outer)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	add_smooth_group(false)
	
	var off = Vector3(0, height/2, 0)
	
	for idx in range(steps):
		add_quad([outer_circle[idx + 1] + off, inner_circle[idx + 1] + off, inner_circle[idx] + off, outer_circle[idx] + off], [], reverse)
		add_quad([outer_circle[idx] - off, inner_circle[idx] - off, inner_circle[idx + 1] - off, outer_circle[idx + 1] - off], [], reverse)
	
	add_smooth_group(smooth)
	
	for idx in range(steps):
		add_quad([outer_circle[idx + 1] + off, outer_circle[idx] + off, outer_circle[idx] - off, outer_circle[idx + 1] -off], [], reverse)
		add_quad([inner_circle[idx] + off, inner_circle[idx + 1] + off, inner_circle[idx + 1] - off, inner_circle[idx] -off], [], reverse)
		
	var mesh = commit()
	
	return mesh

func mesh_parameters(tree):
	add_tree_range(tree, 'Height', 2, 0.1, 0.1, 100)
	add_tree_range(tree, 'Inner Radius', 0.5, 0.1, 0.1, 100)
	add_tree_range(tree, 'Outer Radius', 1, 0.1, 0.1, 100)
	add_tree_range(tree, 'Steps', 16, 1, 1, 50)
	
