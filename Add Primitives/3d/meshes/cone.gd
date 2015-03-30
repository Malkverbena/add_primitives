extends "builder/mesh_builder.gd"
	
func build_mesh(params, smooth = false, reverse = false):
	if params == 'default':
		params = [1, 2, 16]
		
	var r = params[0]    #Radius
	var h = params[1]    #Height
	var s = params[2]    #Segments
	
	var center_top = Vector3(0, h * 0.5, 0)
	var min_pos = Vector3(0, h * -0.5, 0)
	
	var circle = build_circle_verts(min_pos, s, r)
	var circle_uv = build_circle_verts(min_pos, s, 1)
	
	var uv_coords
	
	begin(4)
	
	add_smooth_group(smooth)
	for idx in range(s - 1):
		uv_coords = [Vector2(0.25, 0.5),\
			         Vector2(0.25 + (circle_uv[idx].x * 0.25), 0.5 + (circle_uv[idx].z * 0.25)),\
			         Vector2(0.25 + (circle_uv[idx + 1].x * 0.25), 0.5 + (circle_uv[idx + 1].z * 0.25))]
			
		add_tri([center_top, circle[idx], circle[idx + 1]], uv_coords, reverse)
		
	uv_coords = [Vector2(0.25, 0.5),\
			     Vector2(0.25 + (circle_uv[s - 1].x * 0.25), 0.5 + (circle_uv[s - 1].z * 0.25)),\
			     Vector2(0.25 + (circle_uv[0].x * 0.25), 0.5 + (circle_uv[0].z * 0.25))]
			
	add_tri([center_top, circle[s - 1], circle[0]], uv_coords, reverse)
	
	add_smooth_group(false)
	for idx in range(s - 1):
		uv_coords = [Vector2(0.75 + (circle_uv[idx + 1].x * 0.25), 0.5 + (circle_uv[idx + 1].z * 0.25)),\
		             Vector2(0.75 + (circle_uv[idx].x * 0.25), 0.5 + (circle_uv[idx].z * 0.25)),\
		             Vector2(0.75, 0.5)]
		add_tri([circle[idx + 1], circle[idx], min_pos], uv_coords, reverse)
		
	uv_coords = [Vector2(0.75 + (circle_uv[0].x * 0.25), 0.5 + (circle_uv[0].z * 0.25)),\
	             Vector2(0.75 + (circle_uv[s - 1].x * 0.25), 0.5 + (circle_uv[s - 1].z * 0.25)),\
	             Vector2(0.75, 0.5)]
	             
	add_tri([circle[0], circle[s - 1], min_pos], uv_coords, reverse)
	
	generate_normals()
	var mesh = commit()
	clear()
	
	return mesh
	
func mesh_parameters(settings):
	add_tree_range(settings, 'Radius', 1, 0.1, 0.1, 100)
	add_tree_range(settings, 'Heigth', 2, 0.1, 0.1, 100)
	add_tree_range(settings, 'Segments', 16, 1, 3)
