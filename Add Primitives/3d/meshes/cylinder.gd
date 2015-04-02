extends "builder/mesh_builder.gd"

func build_mesh(params, smooth = false, reverse = false):
	if params == 'default':
		params = [1, 2.0, 16, 0]
		
	var r = params[0]    #Radius
	var h = params[1]    #Height
	var s = params[2]    #Segments
	#  1 cut means no cut
	var c = float(params[3]) + 1    #Cuts
	
	var circle = build_circle_verts(Vector3(0,h/2,0), s, r)
	var circle_uv = build_circle_verts(Vector3(0,0,0), s, 1)
	
	var min_pos = Vector3(0,h * -1,0)
	
	var uv
	
	begin(4)
	
	add_smooth_group(false)
	
	for idx in range(s):
		uv = [Vector2(0.25, 0.25),
		      Vector2(0.25 + (circle_uv[idx].x * 0.25), 0.25 + (circle_uv[idx].z * 0.25)),
		      Vector2(0.25 + (circle_uv[idx + 1].x * 0.25), 0.25 + (circle_uv[idx + 1].z * 0.25))]
		
		add_tri([Vector3(0,h/2,0), circle[idx], circle[idx + 1]], uv, reverse)
		
		uv = [Vector2(0.75, 0.25),
		      Vector2(0.75 + (circle_uv[idx + 1].x * 0.25), 0.25 + (circle_uv[idx + 1].z * 0.25)),
		      Vector2(0.75 + (circle_uv[idx].x * 0.25), 0.25 + (circle_uv[idx].z * 0.25))]
		             
		add_tri([min_pos * 0.5, circle[idx + 1] + min_pos, circle[idx] + min_pos], uv, reverse)
		
	var next_cut = min_pos + Vector3(0, h/c, 0)
	var uv_offset = Vector2(0, 0.5)
	
	add_smooth_group(smooth)
	
	for i in range(c):
		if i == c -1:
			next_cut.y = 0
			
		for idx in range(s):
			uv = [Vector2(float(idx+1)/s, (float(i)/c)/2)  + uv_offset,\
			      Vector2(float(idx+1)/s, (float(i+1)/c)/2) + uv_offset,\
			      Vector2(float(idx)/s, (float(i+1)/c)/2)  + uv_offset,\
			      Vector2(float(idx)/s, (float(i)/c)/2) + uv_offset]
			
			add_quad([circle[idx + 1] + min_pos, circle[idx + 1] + next_cut,\
			          circle[idx] + next_cut, circle[idx] + min_pos], uv, reverse)
			
		min_pos = next_cut
		next_cut.y += h/c
		
	generate_normals()
	var mesh = commit()
	clear()
	
	return mesh
	
func mesh_parameters(settings):
	add_tree_range(settings, 'Radius', 1, 0.1, 0.1, 100)
	add_tree_range(settings, 'Heigth', 2, 0.1, 0.1, 100)
	add_tree_range(settings, 'Segments', 16)
	add_tree_range(settings, 'Cuts', 0, 1, 0)