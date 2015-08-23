extends "builder/mesh_builder.gd"

func build_mesh(params, smooth = false, reverse = false):
	var steps = params[0]
	var width = params[1]
	var height = params[2]
	var length = params[3]
	var fill_end = params[4]
	var fill_bottom = params[5]
	
	begin(VS.PRIMITIVE_TRIANGLES)
	add_smooth_group(smooth)
	
	for i in range(steps):
		add_quad(build_plane_verts(Vector3(0, 0, length), Vector3(width, 0, 0), Vector3(0, (i+1) * height, i * length)), [], reverse)
		add_quad(build_plane_verts(Vector3(0, height, 0), Vector3(width, 0, 0), Vector3(0, i * height, i * length)), [], reverse)
		add_quad(build_plane_verts(Vector3(0, 0, length), Vector3(0, (i+1)*height, 0), Vector3(0, 0, i * length)), [], reverse)
		add_quad(build_plane_verts(Vector3(0, (i+1)*height, 0), Vector3(0, 0, length), Vector3(width, 0, i * length)), [], reverse)
		
	if fill_end:
		add_quad(build_plane_verts(Vector3(width, 0, 0), Vector3(0, steps * height, 0), Vector3(0, 0, steps*length)), [], reverse)
	if fill_bottom:
		add_quad(build_plane_verts(Vector3(width, 0, 0), Vector3(0, 0, steps * length)), [], reverse)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Steps', 10, 1, 1, 100)
	add_tree_range(tree, 'Step Width', 1, 0.1, 0.1, 100)
	add_tree_range(tree, 'Step Height', 0.2, 0.1, 0.1, 100)
	add_tree_range(tree, 'Step Length', 0.2, 0.1, 0.1, 100)
	add_tree_empty(tree)
	add_tree_check(tree, 'Fill End', true)
	add_tree_check(tree, 'Fill Bottom', true)

func container():
	return "Add Stair"
	

