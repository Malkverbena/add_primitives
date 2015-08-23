extends "builder/mesh_builder.gd"
	
func build_mesh(params, smooth = false, reverse = false):
	var l = params[0]     #Lenght
	var w = params[1]     #Width
	var sh = params[2]    #Start H.
	var eh = params[3]    #End H.
	
	var verts = []
	
	verts.push_back(Vector3(-w/2,eh,-l/2))
	verts.push_back(Vector3(w/2,eh,-l/2))
	verts.push_back(Vector3(w/2,sh,l/2))
	verts.push_back(Vector3(-w/2,sh,l/2))
	
	begin(VS.PRIMITIVE_TRIANGLES)
	add_smooth_group(smooth)
	
	add_quad(verts, plane_uv(verts[0].distance_to(verts[1]), verts[0].distance_to(verts[3])), reverse)
	
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, "Length", 2, 0.1, 0.1, 100)
	add_tree_range(tree, "Width", 2, 0.1, 0.1, 100)
	add_tree_range(tree, "Start H.", 0, 0.1, -100, 100)
	add_tree_range(tree, "End H.", 0, 0.1, -100, 100)
	

