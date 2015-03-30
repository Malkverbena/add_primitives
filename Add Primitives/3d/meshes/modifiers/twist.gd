extends "modifier/modifier_base.gd"

static func get_name():
	return "Twist"

func modifier(params, aabb, mesh):
	var mesh_temp = Mesh.new()
	var val = params[0]
	
	var high_point = aabb.get_endpoint(7).y
	var low_point = aabb.get_endpoint(0).y
	
	for surf in range(mesh.get_surface_count()):
		create_from_surface(mesh, surf)
		
		for i in range(get_vertex_count()):
			var vert = get_vertex(i)
			
			var per
			
			if vert.y > 0:
				per = vert.y/high_point
			elif vert.y == 0:
				per = 0
			elif vert.y < 0:
				per = vert.y/low_point * -1
				
			var m3 = Matrix3(Vector3(0,1,0), deg2rad(val*per))
			vert = m3 * vert
			
			set_vertex(i, vert)
		commit_to_surface(mesh_temp)
		clear()
		
	return mesh_temp

func modifier_parameters(item, tree):
	add_tree_range(item, tree, "Angle", 0, 1, -90, 90)