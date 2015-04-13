extends "builder/mesh_builder.gd"
	
func build_mesh(params, smooth = false, reverse = false):
	if params == DEFAULT:
		params = [2,2,0,0]
		
	var l = params[0]    #Lenght
	var w = params[1]    #Width
	var sh = params[2]    #Start H.
	var eh = params[3]    #End H.
	
	var verts = []
	verts.append(Vector3(-w/2,eh,-l/2))
	verts.append(Vector3(w/2,eh,-l/2))
	verts.append(Vector3(w/2,sh,l/2))
	verts.append(Vector3(-w/2,sh,l/2))
	
	begin(4)
	add_smooth_group(smooth)
	add_quad(verts, plane_uv(verts[0].distance_to(verts[1]), verts[0].distance_to(verts[3])), reverse)
	generate_normals()
	index()
	
	var mesh = commit()
	clear()
	
	return mesh
	
	
func mesh_parameters(settings):
	add_tree_range(settings, "Length", 2, 0.1, 0.1, 100)
	add_tree_range(settings, "Width", 2, 0.1, 0.1, 100)
	add_tree_range(settings, "Start H.", 0, 0.1, -100, 100)
	add_tree_range(settings, "End H.", 0, 0.1, -100, 100)
