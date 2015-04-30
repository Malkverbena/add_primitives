extends "builder/mesh_builder.gd"

func build_mesh(params, smooth = false, reverse = false):
	var r = params[0]    #Radius
	var h = params[1]    #Height
	var caps = params[2]
	var s = params[3]    #Segments
	#  1 cut means no cut
	var c = float(params[4])    #Rings
	
	var circle = build_circle_verts(Vector3(0,h/2,0), s, r)
	var circle_uv = build_circle_verts(Vector3(0.25,0,0.25), s, 0.25)
	
	var min_pos = Vector3(0,h * -1,0)
	
	var uv
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(false)
	
	if caps:
		for idx in range(s):
			uv = [Vector2(0.25, 0.25),
			      Vector2(circle_uv[idx].x, circle_uv[idx].z),
			      Vector2(circle_uv[idx + 1].x, circle_uv[idx + 1].z)]
			
			add_tri([Vector3(0,h/2,0), circle[idx], circle[idx + 1]], uv, reverse)
			
			uv = [Vector2(0.75, 0.25),
			      Vector2(circle_uv[idx + 1].x + 0.5, circle_uv[idx + 1].z),
			      Vector2(circle_uv[idx].x + 0.5, circle_uv[idx].z)]
			             
			add_tri([min_pos/2, circle[idx + 1] + min_pos, circle[idx] + min_pos], uv, reverse)
			
	var next_cut = min_pos + Vector3(0, h/c, 0)
	var uv_offset = Vector2(0, 0.5)
	
	add_smooth_group(smooth)
	
	for i in range(c):
		if i == c -1:
			next_cut.y = 0
			
		for idx in range(s):
			uv = [Vector2(float(idx+1)/s, (float(i)/c)/2)  + uv_offset, Vector2(float(idx+1)/s, (float(i+1)/c)/2) + uv_offset,
			      Vector2(float(idx)/s, (float(i+1)/c)/2)  + uv_offset, Vector2(float(idx)/s, (float(i)/c)/2) + uv_offset]
			
			add_quad([circle[idx + 1] + min_pos, circle[idx + 1] + next_cut,\
			          circle[idx] + next_cut, circle[idx] + min_pos], uv, reverse)
			
		min_pos = next_cut
		next_cut.y += h/c
		
	generate_normals()
	index()
	
	var mesh = commit()
	clear()
	
	return mesh
	
func mesh_parameters(settings):
	add_tree_range(settings, 'Radius', 1, 0.1, 0.1, 100)
	add_tree_range(settings, 'Heigth', 2, 0.1, 0.1, 100)
	add_tree_check(settings, 'Caps', true)
	add_tree_range(settings, 'Segments', 16)
	add_tree_range(settings, 'Rings', 1, 1, 1, 50)
