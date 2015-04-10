extends "modifier/modifier_base.gd"

static func get_name():
	return "Taper"
	
func taper(vector, val, c, axis):
	var vec = Vector3(1,1,1)
	for i in axis:
		vec[i] = 1 + val * (vector.y/c)
	return vec
	
func modifier(params, aabb, mesh):
	var mesh_temp = Mesh.new()
	
	var h = aabb.get_endpoint(7).y - aabb.get_endpoint(0).y
	var c = h/2 
	
	var m3 = Matrix3()

	var axis = []
	
	#params[1] = AXIS_X
	if not params[1]:
		axis.append(Vector3.AXIS_X)
		
	#params[2] = AXIS_Z
	if not params[2]:
		axis.append(Vector3.AXIS_Z)
		
	for surf in range(mesh.get_surface_count()):
		create_from_surface(mesh, surf)
		
		for i in range(get_face_count()):
			var val = params[0]
			
			var v1 = get_vertex(get_face_vertex(i, 0))
			var v2 = get_vertex(get_face_vertex(i, 1))
			var v3 = get_vertex(get_face_vertex(i, 2))
			
			v1 = m3.scaled(taper(v1, val, c, axis)) * v1
			v2 = m3.scaled(taper(v2, val, c, axis)) * v2
			v3 = m3.scaled(taper(v3, val, c, axis)) * v3
			
			set_vertex(0 + (i * 3), v1)
			set_vertex(1 + (i * 3), v2)
			set_vertex(2 + (i * 3), v3)
			
		commit_to_surface(mesh_temp)
		clear()
		
	return mesh_temp
	
func modifier_parameters(item, tree):
	add_tree_range(item, tree, 'Value', 0, 0.1, -100, 100)
	add_tree_check(item, tree, 'Lock X Axis', false)
	add_tree_check(item, tree, 'Lock Z Axis', false)
