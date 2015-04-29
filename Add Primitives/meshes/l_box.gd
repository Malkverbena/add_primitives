extends "builder/mesh_builder.gd"

func build_mesh(params, smooth = false, reverse = false):
	var fl = params[0]
	var fw = params[1]
	var sl = params[2]
	var sw = params[3]
	
	var h = params[4]
	
	var center = Vector3(0,0,0)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	add_smooth_group(smooth)
	
	add_quad([Vector3(0, 0, fl), Vector3(fw, 0, fl), Vector3(fw, 0, sw), center], [], reverse)
	add_quad([Vector3(fw, 0, sw), Vector3(sl, 0, sw), Vector3(sl, 0, 0), center], [], reverse)
	
	add_quad([center + Vector3(0,h,0), Vector3(0, h, fl), Vector3(0, 0, fl), center], [], reverse)
	add_quad([center, Vector3(sl,0,0), Vector3(sl,h,0), center + Vector3(0,h,0)], [], reverse)
	add_quad([Vector3(sl,0,sw), Vector3(sl,h,sw), Vector3(sl,h,0), Vector3(sl,0,0)], [], reverse)
	add_quad([Vector3(fw,0,sw), Vector3(fw,h,sw), Vector3(sl,h,sw), Vector3(sl,0,sw)], [], reverse)
	add_quad([Vector3(fw,0,fl), Vector3(fw,h,fl), Vector3(fw,h,sw), Vector3(fw,0,sw)], [], reverse)
	add_quad([Vector3(0,0,fl), Vector3(0,h,fl), Vector3(fw,h,fl), Vector3(fw,0,fl)], [], reverse)
	
	center.y = h
	add_quad([center, Vector3(fw, h, sw), Vector3(fw, h, fl), Vector3(0, h, fl)], [], reverse)
	add_quad([center, Vector3(sl, h, 0), Vector3(sl, h, sw), Vector3(fw, h, sw)], [], reverse)
	
	generate_normals()
	index()
	
	var mesh = commit()
	clear()
	
	return mesh
	
func mesh_parameters(parameters):
	add_tree_range(parameters, 'Front Length', 2, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Front Width', 1, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Side Length', 2, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Side Width', 1, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Height', 1, 0.1, 0.1, 100)
	
func container():
	return "Extra Objects"
