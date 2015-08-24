extends "builder/MeshBuilder.gd"

static func get_name():
	return "Cylinder"
	
func build_mesh(params, smooth = false, reverse = false):
	var r = params[0]    #Radius
	var h = params[1]    #Height
	var caps = params[2]
	var s = params[3]    #Segments
	#  1 cut means no cut
	var c = float(params[4])    #Cuts
	
	var circle = build_circle_verts(Vector3(0,h/2,0), s, r)
	var circle_uv = build_circle_verts(Vector3(0.25,0,0.25), s, 0.25)
	
	if reverse:
		circle.invert()
		circle_uv.invert()
		
	var min_pos = Vector3(0,h * -1,0)
	
	var uv
	
	var seg = range(s)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(false)
	
	if caps:
		var top = Vector3(0,h/2,0)
		
		var c1 = Vector2(0.25, 0.25)
		var c2 = Vector2(0.75, 0.25)
		
		for idx in seg:
			add_uv(c1)
			add_vertex(top)
			add_uv(Vector2(circle_uv[idx].x, circle_uv[idx].z))
			add_vertex(circle[idx])
			add_uv( Vector2(circle_uv[idx + 1].x, circle_uv[idx + 1].z))
			add_vertex(circle[idx + 1])
			
			add_uv(c2)
			add_vertex(min_pos/2)
			add_uv(Vector2(circle_uv[idx + 1].x + 0.5, circle_uv[idx + 1].z))
			add_vertex(circle[idx + 1] + min_pos)
			add_uv(Vector2(circle_uv[idx].x + 0.5, circle_uv[idx].z))
			add_vertex(circle[idx] + min_pos)
			
	var next_cut = min_pos + Vector3(0, h/c, 0)
	
	h /= c
	
	add_smooth_group(smooth)
	
	for i in range(c):
		if i == c -1:
			next_cut.y = 0
			
		i = float(i)
		
		for idx in seg:
			idx = float(idx)
			
			var u1 = i/c/2 + 0.5
			var u2 = (i+1)/c/2 + 0.5
			
			add_uv(Vector2((idx+1)/s, u1))
			add_vertex(circle[idx + 1] + min_pos)
			add_uv(Vector2((idx+1)/s, u2))
			add_vertex(circle[idx + 1] + next_cut)
			add_uv(Vector2(idx/s, u2))
			add_vertex(circle[idx] + next_cut)
			
			add_uv(Vector2(idx/s, u2))
			add_vertex(circle[idx] + next_cut)
			add_uv(Vector2(idx/s, u1))
			add_vertex(circle[idx] + min_pos)
			add_uv(Vector2((idx+1)/s, u1))
			add_vertex(circle[idx + 1] + min_pos)
			
		min_pos = next_cut
		next_cut.y += h
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Radius', 1, 0.1, 0.1, 100)
	add_tree_range(tree, 'Heigth', 2, 0.1, 0.1, 100)
	add_tree_check(tree, 'Caps', true)
	add_tree_range(tree, 'Segments', 16)
	add_tree_range(tree, 'Rings', 1, 1, 1, 50)
	

