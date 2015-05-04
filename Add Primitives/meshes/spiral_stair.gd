extends "builder/mesh_builder.gd"

func build_mesh(params, smooth = false, reverse = false):
	var spirals = params[0]
	var height = params[1]
	var segments = params[2]
	var angle_inc = (PI*2)/segments
	var outer = Vector3(params[3], 1, params[3])
	var inner = Vector3(params[4], 1, params[4])
	var eh = params[5]    #Extra Parameters
	
	begin(VS.PRIMITIVE_TRIANGLES)
	add_smooth_group(smooth)
	
	for sp in range(spirals):
		var off = Vector3(0, height*sp, 0)
		
		var s = height/segments
		var h = Vector3(0,-(s + eh),0)
		
		for i in range(segments):
			var vector = Vector3(cos(angle_inc*i), (i+1)*s + eh, sin(angle_inc*i)) + off
			var vector_2 = Vector3(cos(angle_inc*(i+1)), (i+1)*s + eh, sin(angle_inc*(i+1))) + off
			
			add_quad([vector*inner, vector*outer, vector_2*outer, vector_2*inner], [], reverse)
			add_quad([(vector*outer) + h, vector*outer, vector*inner, (vector*inner) + h], [], reverse)
			add_quad([(vector_2*outer) + h, vector_2*outer, vector*outer, (vector*outer) + h], [], reverse)
			add_quad([(vector*inner) + h, vector*inner, vector_2*inner, (vector_2*inner) + h], [], reverse)
			add_quad([(vector_2*inner) + h, vector_2*inner, vector_2*outer, (vector_2*outer) + h], [], reverse)
			
			vector += h
			vector_2 += h
			
			add_quad([vector_2*inner, vector_2*outer,  vector*outer, vector*inner], [], reverse)
			
	generate_normals()
	index()
	
	var mesh = commit()
	clear()
	
	return mesh
	
func mesh_parameters(parameters):
	add_tree_range(parameters, 'Spirals', 1, 1, 1, 720)
	add_tree_range(parameters, 'Spiral Height', 2, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Steps per Spiral', 8, 1, 2, 100)
	add_tree_range(parameters, 'Outer Radius', 2, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Inner Radius', 1, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Extra Step Height', 0, 0.01, -100, 100)
	
func container():
	return "Add Stair"
	