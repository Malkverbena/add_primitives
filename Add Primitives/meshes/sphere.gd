extends 'builder/mesh_builder.gd'
	
func build_mesh(params, smooth = false, reverse = false):
	var r = params[0]    #Radius
	var s = params[1]    #Segments
	var c = params[2]    #Rings
		
	var angle_inc = PI/c
	var cc = Vector3(0,-r,0)    #Caps Center
	
	var circle = build_circle_verts(Vector3(0,0,0), s, r)
	
	var rd = Vector3(sin(angle_inc), 0, sin(angle_inc))    #Cuts Radius
	var pos
	
	begin(4)
	add_smooth_group(smooth)
	
	for idx in range(s):
		pos = Vector3(0,-cos(angle_inc) * r,0)
		add_tri([circle[idx + 1] * rd + pos, circle[idx] * rd + pos, cc], [], reverse)
		
		pos = Vector3(0,-cos(angle_inc * (c - 1)) * r,0)
		add_tri([ -cc, circle[idx] * rd + pos, circle[idx + 1] * rd + pos], [], reverse)
	
	pos = Vector3(0,-cos(angle_inc) * r,0)
	
	for i in range(c - 2):
		rd = Vector3(sin(angle_inc * (i + 1)), 0, sin(angle_inc * (i + 1)))
		var next_radius = Vector3(sin(angle_inc * (i + 2)), 0, sin(angle_inc * (i + 2)))
		
		var next_pos = Vector3(0,-cos(angle_inc * (i + 2)) * r, 0)
		
		for idx in range(s):
			
			add_quad([circle[idx + 1] * rd + pos, circle[idx + 1] * next_radius + next_pos,\
			          circle[idx] * next_radius + next_pos,\
			          circle[idx] * rd + pos], [], reverse)
			
		pos = next_pos
	
	generate_normals()
	index()
	
	var mesh = commit()
	clear()
	
	return mesh
	
func mesh_parameters(settings):
		add_tree_range(settings, 'Radius', 1, 0.1, 0.1, 100)
		add_tree_range(settings, 'Segments', 16, 1, 3, 50)
		add_tree_range(settings, 'Rings', 8, 1, 3, 50)