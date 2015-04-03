extends "modifier/modifier_base.gd"

static func get_name():
	return "Twist"

func modifier(params, aabb, mesh):
	var mesh_temp = Mesh.new()
	var val
	
	var h = aabb.get_endpoint(7).y - aabb.get_endpoint(0).y
	var c = h/2
	
	var m3 = Matrix3()
	
	for surf in range(mesh.get_surface_count()):
		create_from_surface(mesh, surf)
		
		for i in range(get_face_count()):
			val = params[0]
			
			var vert_1 = get_vertex(get_face_vertex(i, 0))
			var vert_2 = get_vertex(get_face_vertex(i, 1))
			var vert_3 = get_vertex(get_face_vertex(i, 2))
			
			vert_1 = m3.rotated(Vector3(0,1,0), deg2rad(val * (vert_1.y/c))) * vert_1
			vert_2 = m3.rotated(Vector3(0,1,0), deg2rad(val * (vert_2.y/c))) * vert_2
			vert_3 = m3.rotated(Vector3(0,1,0), deg2rad(val * (vert_3.y/c))) * vert_3
			
			set_vertex(0 + (i * 3), vert_1)
			set_vertex(1 + (i * 3), vert_2)
			set_vertex(2 + (i * 3), vert_3)
			
		commit_to_surface(mesh_temp)
		clear()
		
		
	return mesh_temp

func modifier_parameters(item, tree):
	add_tree_range(item, tree, "Angle", 0, 1, -180, 180)