extends "builder/mesh_builder.gd"

func build_mesh(params, smooth = false, reverse = false):
	var angle = deg2rad(params[0])
	var segments = params[2]
	var height = params[1]/segments
	var outer = Vector3(params[3], 1, params[3])
	var inner = Vector3(params[4], 1, params[4])
	
	var fill_bottom = params[5]
	var fill_end = params[6]
	
	var angle_inc = angle/segments
	
	begin(VS.PRIMITIVE_TRIANGLES)
	add_smooth_group(smooth)
	
	for i in range(segments):
		var vector = Vector3(cos(angle_inc*i), (i+1)*height, sin(angle_inc*i))
		var vector_2 = Vector3(cos(angle_inc*(i+1)), (i+1)*height, sin(angle_inc*(i+1)))
		
		var h = Vector3(0, -height, 0)
		
		add_quad([vector*inner, vector*outer, vector_2*outer, vector_2*inner], [], reverse)
		add_quad([(vector*outer) + h, vector*outer, vector*inner, (vector*inner) + h], [], reverse)
		
		h.y *= i + 1
		
		add_quad([(vector_2*outer) + h, vector_2*outer, vector*outer, (vector*outer) + h], [], reverse)
		add_quad([(vector*inner) + h, vector*inner, vector_2*inner, (vector_2*inner) + h], [], reverse)
		
		if fill_bottom:
			vector.y = 0
			vector_2.y = 0
			
			add_quad([vector_2*inner, vector_2*outer,  vector*outer, vector*inner], [], reverse)
			
	if fill_end:
		var i = segments
		
		var vector = Vector3(cos(angle_inc*i), i*height, sin(angle_inc*i))
		var vector_2 = Vector3(cos(angle_inc*(i+1)), i*height, sin(angle_inc*(i+1)))
		
		add_quad([(vector*inner)+Vector3(0,-height*i,0), vector*inner, vector*outer, (vector*outer)+Vector3(0,-height*i,0)], [], reverse)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Angle', 90, 1, 1, 360)
	add_tree_range(tree, 'Stair Height', 2, 0.1, 0.1, 100)
	add_tree_range(tree, 'Steps', 8, 1, 2, 100)
	add_tree_range(tree, 'Outer Radius', 2, 0.1, 0.1, 100)
	add_tree_range(tree, 'Inner Radius', 1, 0.1, 0.1, 100)
	add_tree_empty(tree)
	add_tree_check(tree, 'Fill Bottom', true)
	add_tree_check(tree, 'Fill End', true)
	
func container():
	return "Add Stair"
	

