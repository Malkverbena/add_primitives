extends "builder/mesh_builder.gd"

func build_mesh(params, smooth = false, reverse = false):
	var r = params[0]
	var s = params[1]
	
	var c = Vector3(0,0,0)
	
	var circle = build_circle_verts(c, s, r)
	var circle_uv = build_circle_verts(Vector3(0.5,0,0.5), s, 0.5)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(smooth)
	
	for i in range(s):
		var uv = [Vector2(0.5,0.5), Vector2(circle_uv[i].x, circle_uv[i].z), 
		          Vector2(circle_uv[i+1].x, circle_uv[i+1].z)]
		
		add_tri([c, circle[i], circle[i+1]],uv, reverse)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Radius', 1, 0.1, -100, 100)
	add_tree_range(tree, 'Segments', 16, 1, 3, 50)
	

