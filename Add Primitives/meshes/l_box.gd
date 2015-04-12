extends "builder/mesh_builder.gd"

func build_mesh(params, smooth = false, reverse = false):
	if params == DEFAULT:
		params = [1, 0.5, 1, 0.5, 1]
		
	var forward_l = params[0]
	var forward_w = params[1]
	var side_l = params[2]
	var side_w = params[3]
	
	var h = params[4]
	
	var center = Vector3(0,0,0)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	add_smooth_group(smooth)
	
	add_quad([Vector3(0, 0, forward_l), Vector3(forward_w, 0, forward_l), Vector3(forward_w, 0, side_w), center], [], reverse)
	add_quad([Vector3(forward_w, 0, side_w), Vector3(side_l, 0, side_w), Vector3(side_l, 0, 0), center], [], reverse)
	
	add_quad([center + Vector3(0,h,0), Vector3(0, h, forward_l), Vector3(0, 0, forward_l), center], [], reverse)
	add_quad([center, Vector3(side_l,0,0), Vector3(side_l,h,0), center + Vector3(0,h,0)], [], reverse)
	add_quad([Vector3(side_l,0,side_w), Vector3(side_l,h,side_w), Vector3(side_l,h,0), Vector3(side_l,0,0)], [], reverse)
	add_quad([Vector3(forward_w,0,side_w), Vector3(forward_w,h,side_w), Vector3(side_l,h,side_w), Vector3(side_l,0,side_w)], [], reverse)
	add_quad([Vector3(forward_w,0,forward_l), Vector3(forward_w,h,forward_l), Vector3(forward_w,h,side_w), Vector3(forward_w,0,side_w)], [], reverse)
	add_quad([Vector3(0,0,forward_l), Vector3(0,h,forward_l), Vector3(forward_w,h,forward_l), Vector3(forward_w,0,forward_l)], [], reverse)
	
	center.y = h
	add_quad([center, Vector3(forward_w, h, side_w), Vector3(forward_w, h, forward_l), Vector3(0, h, forward_l)], [], reverse)
	add_quad([center, Vector3(side_l, h, 0), Vector3(side_l, h, side_w), Vector3(forward_w, h, side_w)], [], reverse)
	
	generate_normals()
	var mesh = commit()
	clear()
	
	return mesh
	
func mesh_parameters(parameters):
	add_tree_range(parameters, 'Front Length', 3, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Front Width', 2, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Side Length', 4, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Side Width', 2, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Height', 2, 0.1, 0.1, 100)
	
func container():
	return "Extra Objects"