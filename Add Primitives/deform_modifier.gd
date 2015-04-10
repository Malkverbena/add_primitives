extends Node

class Modifier:
	extends MeshDataTool
	
	#Tree Item helper functions
	func _create_item(item, tree):
		item = tree.create_item(item)
		
		return item
		
	func add_tree_range(item, tree, text, value, step = 1, _min = 1, _max = 50):
		var tree_item = _create_item(item, tree)
		
		tree_item.set_text(0, text)
		
		if typeof(step) == TYPE_INT:
			tree_item.set_icon(0, tree.get_icon('Integer', 'EditorIcons'))
		else:
			tree_item.set_icon(0, tree.get_icon('Real', 'EditorIcons'))
		tree_item.set_selectable(0, false)
		
		tree_item.set_cell_mode(1, 2)
		tree_item.set_range(1, value)
		tree_item.set_range_config(1, _min, _max, step)
		tree_item.set_editable(1, true)
		
	func add_tree_combo(item, tree, text, items, selected = 0):
		var tree_item = _create_item(item, tree)
		
		tree_item.set_text(0, text)
		tree_item.set_icon(0, tree.get_icon('Enum', 'EditorIcons'))
		tree_item.set_selectable(0, false)
		tree_item.set_cell_mode(1, 2)
		tree_item.set_text(1, items)
		tree_item.set_range(1, selected)
		tree_item.set_editable(1, true)
		
	func add_tree_check(item, tree, text, checked = false):
		var tree_item = _create_item(item, tree)
		
		tree_item.set_text(0, text)
		tree_item.set_icon(0, tree.get_icon('Bool', 'EditorIcons'))
		tree_item.set_selectable(0, false)
		tree_item.set_cell_mode(1, 1)
		tree_item.set_checked(1, checked)
		tree_item.set_text(1, 'On')
		tree_item.set_editable(1, true)
		
	func add_tree_entry(item, tree, text, string = ''):
		var tree_item = _create_item(item, tree)
		
		tree_item.set_text(0, text)
		tree_item.set_icon(0, tree.get_icon('String', 'EditorIcons'))
		tree_item.set_selectable(0, false)
		tree_item.set_cell_mode(1, 0)
		tree_item.set_text(1, string)
		tree_item.set_editable(1, true)
		
#End Modifier

class TaperModifier:
	extends Modifier
	
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
		
#End TaperModifer

class ShearModifier:
	extends Modifier
	
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
		
#End ShearModifier

class TwistModifier:
	extends Modifier
	
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
		
#End TwistModifier

#############################################################################################

func get_modifiers():
	return {"Taper":TaperModifier, "Shear":ShearModifier, "Twist":TwistModifier}