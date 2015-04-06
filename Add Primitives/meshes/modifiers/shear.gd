extends "modifier/modifier_base.gd"

static func get_name():
	return "Shear"
	
func modifier(params, aabb, mesh):
	var mesh_temp = Mesh.new()
	var axis = params[0]
	
	var h
	var c
	
	var s_axis
	var b_axis
	
	if axis == 'x' or axis == 'z':
		h = aabb.get_endpoint(7).y - aabb.get_endpoint(0).y
		
		if axis == 'x':
			s_axis = Vector3.AXIS_X
		elif axis == 'z':
			s_axis = Vector3.AXIS_Z
		b_axis = Vector3.AXIS_Y
		
	elif axis == 'y':
		h = aabb.get_endpoint(7).x - aabb.get_endpoint(0).x
		
		s_axis = Vector3.AXIS_Y
		b_axis = Vector3.AXIS_X
		
	c = h/2
	
	for surf in range(mesh.get_surface_count()):
		create_from_surface(mesh, surf)
		
		for i in range(get_face_count()):
			var val = params[1]
			
			var vert_1 = get_vertex(get_face_vertex(i, 0))
			var vert_2 = get_vertex(get_face_vertex(i, 1))
			var vert_3 = get_vertex(get_face_vertex(i, 2))
			
			vert_1[s_axis] += val * (vert_1[b_axis]/c)
			vert_2[s_axis] += val * (vert_2[b_axis]/c)
			vert_3[s_axis] += val * (vert_3[b_axis]/c)
			
			set_vertex(0 + (i * 3), vert_1)
			set_vertex(1 + (i * 3), vert_2)
			set_vertex(2 + (i * 3), vert_3)
			
		commit_to_surface(mesh_temp)
		clear()
		
	return mesh_temp
	
func modifier_parameters(item, tree):
	add_tree_combo(item, tree, 'Shear Axis', 'x,y,z')
	add_tree_range(item, tree, 'Shear', 0, 0.1, -50)
