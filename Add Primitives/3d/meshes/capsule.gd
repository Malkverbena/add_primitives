extends "builder/mesh_builder.gd"

func build_mesh(params, smooth = false, reverse = false):
	if params == 'default':
		params = [1, 1, 16, 8]
	else:
		params = [1] + params
	
	var rd = params[0]    #Sphere Radius
	var h = params[1]    #Height
	var s = params[2]    #Segments
	var c = params[3]    #Cuts
		
	var angle_inc = PI/c
	var cc = Vector3(0,(rd + h),0)    #Caps Center
	
	var circle = build_circle_verts(Vector3(0,0,0), s, rd)
	
	var r = Vector3(sin(angle_inc), 0, sin(angle_inc))    #Radius
	var p    #Positions
	
	begin(4)
	add_smooth_group(smooth)
	
	for idx in range(s):
		p = Vector3(0,-cos(angle_inc) - h,0) * rd
		add_tri([(circle[idx + 1] * r) + p, (circle[idx] * r) + p, -cc], [], reverse)
		p = Vector3(0,-cos(angle_inc * (c - 1)) + h,0) * rd
		add_tri([cc, (circle[idx] * r) + p, (circle[idx + 1] * r + p)], [], reverse)
		
	for i in range((c - 2)/2):
		r = Vector3(sin(angle_inc * (i + 1)), 0, sin(angle_inc * (i + 1)))
		var nr = Vector3(sin(angle_inc * (i + 2)), 0, sin(angle_inc * (i + 2)))    #Next Radius
		
		var np    #Next Pos
		
		np = Vector3(0, -cos(angle_inc * (i + 2)) - h, 0) * rd
		
		if i == 0:
			p = Vector3(0,-cos(angle_inc) - h,0) * rd
		
		for idx in range(s):
			add_quad([(circle[idx+1] * r) + p,\
			          (circle[idx+1] * nr) + np,\
			          (circle[idx] * nr) + np,\
			          (circle[idx] * r) + p], [], reverse)
		p = np
		
	for i in range(((c - 2)/2), c - 1):
		r = Vector3(sin(angle_inc * i), 0, sin(angle_inc * i))
		
		var nr = Vector3(sin(angle_inc * (i + 1)), 0, sin(angle_inc * (i + 1)))
		
		if i == ((c - 2)/2):
			r = Vector3(sin(angle_inc * (i + 1)), 0, sin(angle_inc * (i + 1)))
		
		var np = Vector3(0, -cos(angle_inc * (i + 1)) + h, 0) * rd
		
		for idx in range(s):
			add_quad([(circle[idx+1] * r) + p,\
			          (circle[idx+1] * nr) + np,\
			          (circle[idx] * nr) + np,\
			          (circle[idx] * r) + p], [], reverse)
		p = np
	
	generate_normals()
	var mesh = commit()
	clear()
	
	return mesh
	
func mesh_parameters(settings):
	add_tree_range(settings, 'C. Heigth', 1, 0.1, 0.1, 100)
	add_tree_range(settings, 'Segments', 16, 1, 3)
	add_tree_range(settings, 'Cuts', 8, 2, 4)
