extends "builder/mesh_builder.gd"

func build_mesh(params, smooth = false, reverse = false):
	if params == DEFAULT:
		params = [1, 2.0, 10, 1.0, 0.5]
		
	var spirals = params[0]
	var height = params[1]
	var segments = params[2]
	var angle_inc = (PI*2)/segments
	var outer = Vector3(params[3], 1, params[3])
	var inner = Vector3(params[4], 1, params[4])
	
	begin(4)
	add_smooth_group(false)
	
	for sp in range(spirals):
		var off = Vector3(0, height*sp, 0)
		
		var h = height/segments
		
		for i in range(segments):
			var vector = Vector3(cos(angle_inc*i), (i+1)*h, sin(angle_inc*i)) + off
			var vector_2 = Vector3(cos(angle_inc*(i+1)), (i+1)*h, sin(angle_inc*(i+1))) + off
			
			add_quad([vector*inner, vector*outer, vector_2*outer, vector_2*inner])
			add_quad([(vector*outer)+Vector3(0,-h,0), vector*outer, vector*inner, (vector*inner)+Vector3(0,-h,0)])
			add_quad([(vector_2*outer)+Vector3(0,-h,0), vector_2*outer, vector*outer, (vector*outer)+Vector3(0,-h,0)])
			add_quad([(vector*inner)+Vector3(0,-h,0), vector*inner, vector_2*inner, (vector_2*inner)+Vector3(0,-h,0)])
			add_quad([(vector_2*inner)+Vector3(0,-h,0), vector_2*inner, vector_2*outer, (vector_2*outer)+Vector3(0,-h,0)])
			
			vector.y -= h
			vector_2.y -= h
			
			add_quad([vector_2*inner, vector_2*outer,  vector*outer, vector*inner])
			
	generate_normals()
	var mesh = commit()
	clear()
	
	return mesh
	
func mesh_parameters(parameters):
	add_tree_range(parameters, 'Spirals', 1, 1, 1, 720)
	add_tree_range(parameters, 'Spiral Height', 2, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Steps per Spiral', 8, 1, 2, 100)
	add_tree_range(parameters, 'Outer Radius', 2, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Inner Radius', 1, 0.1, 0.1, 100)
	
func container():
	return "Add Stair"
	