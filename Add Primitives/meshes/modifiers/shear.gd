extends "modifier/modifier_base.gd"

static func get_name():
	return "Shear"
	
func modifier(params, aabb, mesh):
	var mesh_temp = Mesh.new()
	var axis = params[0]
	
	var h
	var c
	
	if axis == 'x':
		h = aabb.get_endpoint(7).y - aabb.get_endpoint(0).y
	elif axis == 'y':
		h = aabb.get_endpoint(7).x - aabb.get_endpoint(0).x
	c = h/2
	
	for surf in range(mesh.get_surface_count()):
		create_from_surface(mesh, surf)
		
		for i in range(get_face_count()):
			var val = params[1]
			
			var vert_1 = get_vertex(get_face_vertex(i, 0))
			var vert_2 = get_vertex(get_face_vertex(i, 1))
			var vert_3 = get_vertex(get_face_vertex(i, 2))
			
			if axis == 'x':
				vert_1.x += val * (vert_1.y/c)
				vert_2.x += val * (vert_2.y/c)
				vert_3.x += val * (vert_3.y/c)
				
				set_vertex(0 + (i * 3), vert_1)
				set_vertex(1 + (i * 3), vert_2)
				set_vertex(2 + (i * 3), vert_3)
				
				continue
				
			elif axis == 'y':
				vert_1.y += val * (vert_1.x/c)
				vert_2.y += val * (vert_2.x/c)
				vert_3.y += val * (vert_3.x/c)
				
				set_vertex(0 + (i * 3), vert_1)
				set_vertex(1 + (i * 3), vert_2)
				set_vertex(2 + (i * 3), vert_3)
				
				continue
				
		commit_to_surface(mesh_temp)
		clear()
		
	return mesh_temp
	
func modifier_parameters(item, tree):
	add_tree_combo(item, tree, 'Shear Axis', 'x,y')
	add_tree_range(item, tree, 'Shear', 0, 0.01, -50)
