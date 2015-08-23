extends "builder/mesh_builder.gd"
	
func build_mesh(params, smooth = false, reverse = false):
	var r = params[0]    #Radius
	var h = params[1]    #Height
	var s = params[2]    #Segments
	
	var center_top = Vector3(0, h/2, 0)
	var min_pos = Vector3(0, -h/2, 0)
	
	var circle = build_circle_verts(min_pos, s, r)
	var circle_uv = build_circle_verts(Vector3(0.25,0,0.25), s, 0.25)
	
	var uv_coords
	
	begin(VS.PRIMITIVE_TRIANGLES)
	add_smooth_group(smooth)
	
	for idx in range(s):
		uv_coords = [Vector2(0.25, 0.25), Vector2(circle_uv[idx].x, circle_uv[idx].z),
		             Vector2(circle_uv[idx + 1].x, circle_uv[idx + 1].z)]
		
		add_tri([center_top, circle[idx], circle[idx + 1]], uv_coords, reverse)
		
	add_smooth_group(false)
	
	for idx in range(s):
		uv_coords = [Vector2(0.5 + circle_uv[idx + 1].x, circle_uv[idx + 1].z),
		             Vector2(0.5 + circle_uv[idx].x, circle_uv[idx].z), Vector2(0.75, 0.25)]
		
		add_tri([circle[idx + 1], circle[idx], min_pos], uv_coords, reverse)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Radius', 1, 0.1, 0.1, 100)
	add_tree_range(tree, 'Heigth', 2, 0.1, 0.1, 100)
	add_tree_range(tree, 'Segments', 16, 1, 3, 50)
	

