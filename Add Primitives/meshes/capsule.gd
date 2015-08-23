extends "builder/mesh_builder.gd"

func build_mesh(params, smooth = false, reverse = false):
	var sr = params[0]   #Sphere Radius
	var h = params[1]    #Height
	var s = params[2]    #Segments
	var c = params[3]    #Cuts
		
	var angle_inc = PI/c
	var cc = Vector3(0,sr + h,0)    #Caps Center
	
	var circle = build_circle_verts(Vector3(0,0,0), s, sr)
	
	var r = Vector3(sin(angle_inc), 0, sin(angle_inc))    #Radius
	var p    #Positions
	
	begin(VS.PRIMITIVE_TRIANGLES)
	add_smooth_group(smooth)
	
	for idx in range(s):
		p = Vector3(0,-cos(angle_inc) * sr - h,0)
		add_tri([(circle[idx + 1] * r) + p, (circle[idx] * r) + p, -cc], [], reverse)
		
		p = Vector3(0,-cos(angle_inc * (c - 1)) * sr + h,0)
		add_tri([cc, (circle[idx] * r) + p, (circle[idx + 1] * r + p)], [], reverse)
		
	for i in range((c - 2)/2):
		r = Vector3(sin(angle_inc * (i + 1)), 0, sin(angle_inc * (i + 1)))
		var nr = Vector3(sin(angle_inc * (i + 2)), 0, sin(angle_inc * (i + 2)))    #Next Radius
		
		var np = Vector3(0, -cos(angle_inc * (i + 2)) * sr - h, 0)
		
		if i == 0:
			p = Vector3(0,-cos(angle_inc) * sr - h,0)
		
		for idx in range(s):
			add_quad([circle[idx+1] * r + p, circle[idx+1] * nr + np, circle[idx] * nr + np, circle[idx] * r + p], [], reverse)
		p = np
		
	for i in range(((c - 2)/2), c - 1):
		r = Vector3(sin(angle_inc * i), 0, sin(angle_inc * i))
		
		var nr = Vector3(sin(angle_inc * (i + 1)), 0, sin(angle_inc * (i + 1)))
		
		if i == ((c - 2)/2):
			r = Vector3(sin(angle_inc * (i + 1)), 0, sin(angle_inc * (i + 1)))
			
		var np = Vector3(0, -cos(angle_inc * (i + 1)) * sr + h, 0)
		
		for idx in range(s):
			add_quad([circle[idx+1] * r + p, circle[idx+1] * nr + np, circle[idx] * nr + np, circle[idx] * r + p], [], reverse)
			
		p = np
	
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'S. Radius', 1, 0.1, 0.1, 100)
	add_tree_range(tree, 'C. Heigth', 1, 0.1, 0.1, 100)
	add_tree_range(tree, 'Segments', 16, 1, 3, 50)
	add_tree_range(tree, 'Cuts', 8, 2, 4, 50)
	

