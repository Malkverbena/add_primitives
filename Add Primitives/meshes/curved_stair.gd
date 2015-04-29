extends "builder/mesh_builder.gd"

func build_mesh(params, smooth = false, reverse = false):
	var angle = deg2rad(params[0])
	var segments = params[2]
	var height = params[1]/segments
	var angle_inc = angle/segments
	var outer = Vector3(params[3], 1, params[3])
	var inner = Vector3(params[4], 1, params[4])
	
	var fill_bottom = params[5]
	var fill_end = params[6]
	
	begin(4)
	add_smooth_group(false)
	
	for i in range(segments):
		var vector = Vector3(cos(angle_inc*i), (i+1)*height, sin(angle_inc*i))
		var vector_2 = Vector3(cos(angle_inc*(i+1)), (i+1)*height, sin(angle_inc*(i+1)))
		
		add_quad([vector*inner, vector*outer, vector_2*outer, vector_2*inner])
		add_quad([(vector*outer)+Vector3(0,-height,0), vector*outer, vector*inner, (vector*inner)+Vector3(0,-height,0)])
		add_quad([(vector_2*outer)+Vector3(0,-height*(i+1),0), vector_2*outer, vector*outer, (vector*outer)+Vector3(0,-height*(i+1),0)])
		add_quad([(vector*inner)+Vector3(0,-height*(i+1),0), vector*inner, vector_2*inner, (vector_2*inner)+Vector3(0,-height*(i+1),0)])
		
		if fill_bottom:
			vector.y = 0
			vector_2.y = 0
			
			add_quad([vector_2*inner, vector_2*outer,  vector*outer, vector*inner])
			
	if fill_end:
		var i = segments
		var vector = Vector3(cos(angle_inc*i), i*height, sin(angle_inc*i))
		var vector_2 = Vector3(cos(angle_inc*(i+1)), i*height, sin(angle_inc*(i+1)))
		
		add_quad([(vector*inner)+Vector3(0,-height*i,0), vector*inner, vector*outer, (vector*outer)+Vector3(0,-height*i,0)])
		
	generate_normals()
	index()
	
	var mesh = commit()
	clear()
	
	return mesh
	
func mesh_parameters(parameters):
	add_tree_range(parameters, 'Angle', 90, 1, 1, 360)
	add_tree_range(parameters, 'Stair Height', 2, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Steps', 8, 1, 2, 100)
	add_tree_range(parameters, 'Outer Radius', 2, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Inner Radius', 1, 0.1, 0.1, 100)
	add_tree_empty(parameters)
	add_tree_check(parameters, 'Fill Bottom', true)
	add_tree_check(parameters, 'Fill End', true)
	
func container():
	return "Add Stair"
	
