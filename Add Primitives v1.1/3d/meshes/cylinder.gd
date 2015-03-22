extends "builder/mesh_builder.gd"
	
func build_mesh(params, smooth = false, reverse = false):
	if params == 'default':
		params = [1, 2, 16, 1]
		
	var r = params[0]    #Radius
	var h = params[1]    #Height
	var s = params[2]    #Segments
	var c = params[3]    #Cuts
	
	#cuts = 1 means no cut
	var circle = build_circle_verts(Vector3(0,float(h)/2,0), s, r)
	var circle_uv = build_circle_verts(Vector3(0,0,0), s, 1)
	var min_pos = Vector3(0,h * -1,0)
	
	var uv
	
	begin(4)
	
	add_smooth_group(false)
	for idx in range(s - 1):
		uv = [Vector2(0.25, 0.25),\
		             Vector2(0.25 + (circle_uv[idx].x * 0.25), 0.25 + (circle_uv[idx].z * 0.25)),\
		             Vector2(0.25 + (circle_uv[idx + 1].x * 0.25), 0.25 + (circle_uv[idx + 1].z * 0.25))]
		
		add_tri([Vector3(0,float(h)/2,0), circle[idx], circle[idx + 1]], uv, reverse)
		
		uv = [Vector2(0.75, 0.25),\
		             Vector2(0.75 + (circle_uv[idx].x * 0.25), 0.25 + (circle_uv[idx].z * 0.25)),\
		             Vector2(0.75 + (circle_uv[idx + 1].x * 0.25), 0.25 + (circle_uv[idx + 1].z * 0.25))]
		             
		add_tri([min_pos * 0.5, circle[idx + 1] + min_pos, circle[idx] + min_pos], uv, reverse)
		
	uv = [Vector2(0.25, 0.25),\
	             Vector2(0.25 + (circle_uv[0].x * 0.25), 0.25 + (circle_uv[0].z * 0.25)),\
	             Vector2(0.25 + (circle_uv[s - 1].x * 0.25), 0.25 + (circle_uv[s - 1].z * 0.25))]
	
	add_tri([Vector3(0,float(h)/2,0), circle[s - 1], circle[0]], uv, reverse)
	
	uv = [Vector2(0.75, 0.25),\
	             Vector2(0.75 + (circle_uv[0].x * 0.25), 0.25 + (circle_uv[0].z * 0.25)),\
	             Vector2(0.75 + (circle_uv[s - 1].x * 0.25), 0.25 + (circle_uv[s - 1].z * 0.25))]
	
	add_tri([min_pos * 0.5, circle[0] + min_pos, circle[s - 1] + min_pos], uv, reverse)
	
	var next_cut = Vector3(0, float(h)/c, 0) + min_pos
	var uv_offset = Vector2(0, 0.5)
	
	add_smooth_group(smooth)
	
	for i in range(c):
		for idx in range(s - 1):
			uv = [Vector2(float(idx+1)/s, (float(i)/c)/2)  + uv_offset,\
			             Vector2(float(idx+1)/s, (float(i+1)/c)/2) + uv_offset,\
			             Vector2(float(idx)/s, (float(i+1)/c)/2)  + uv_offset,\
			             Vector2(float(idx)/s, (float(i)/c)/2) + uv_offset]
			
			add_quad([circle[idx + 1] + min_pos, circle[idx + 1] + next_cut,\
			          circle[idx] + next_cut, circle[idx] + min_pos], uv, reverse)
			
			
		uv = [(Vector2(1.0, (float(i)/c)/2) + uv_offset),\
		             (Vector2(1.0, (float(i+1)/c)/2) + uv_offset),\
		             (Vector2(float(s - 1)/params[2], (float(i+1)/c)/2) + uv_offset),\
		             (Vector2(float(params[2] - 1)/params[2], (float(i)/c)/2) + uv_offset)]
		             
		add_quad([circle[0] + min_pos, circle[0] + next_cut,\
		          circle[params[2] - 1] + next_cut, circle[params[2] - 1] + min_pos], uv, reverse)
		
		
		min_pos = next_cut
		next_cut.y += float(h)/c
		
	generate_normals()
	var mesh = commit()
	clear()
	
	return mesh
	
func mesh_parameters(settings):
	add_tree_range(settings, 'Radius', 1, 0.1, 100, 0.1)
	add_tree_range(settings, 'Heigth', 2, 0.1, 100, 0.1)
	add_tree_range(settings, 'Segments', 16)
	add_tree_range(settings, 'Cuts', 1)
