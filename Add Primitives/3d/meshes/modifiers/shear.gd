extends "modifier/modifier_base.gd"

static func get_name():
	return "Shear"
	
func modifier(params, aabb, mesh):
	var mesh_temp = Mesh.new()
	var axis = params[0]
	var val = params[1]
	
	var low_point = aabb.get_endpoint(0)
	var high_point = aabb.get_endpoint(7)
	
	for surf in range(mesh.get_surface_count()):
		create_from_surface(mesh, surf)
		
		for i in range(get_vertex_count()):
			var vert = get_vertex(i)
			
			var per
			if axis == 'x':
				if vert.y >= 0:
					per = vert.y/high_point.y
					
				elif vert.y < 0:
					per = vert.y/low_point.y * -1
					
				vert.x += val * per
				
			elif axis == 'y':
				if vert.x >= 0:
					per = vert.x/high_point.x
					
				elif vert.x < 0:
					per = vert.x/low_point.x * -1
					
				vert.y += val * per
				
			set_vertex(i, vert)
			
		commit_to_surface(mesh_temp)
		clear()
	
	return mesh_temp
	
func modifier_parameters(item, tree):
	add_tree_combo(item, tree, 'Shear Axis', 'x,y')
	add_tree_range(item, tree, 'Shear', 0, 0.01, -50)