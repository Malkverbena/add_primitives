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
			
			for i in range(get_vertex_count()):
				var val = params[0]
				
				var v1 = get_vertex(i)
				
				v1 = m3.scaled(taper(v1, val, c, axis)) * v1
				
				set_vertex(i, v1)
				
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
			
			for i in range(get_vertex_count()):
				var val = params[1]
				
				var vert_1 = get_vertex(i)
				
				vert_1[s_axis] += val * (vert_1[b_axis]/c)
				
				set_vertex(i, vert_1)
				
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
			
			for i in range(get_vertex_count()):
				val = params[0]
				
				var vert_1 = get_vertex(i)
				
				vert_1 = m3.rotated(Vector3(0,1,0), deg2rad(val * (vert_1.y/c))) * vert_1
				
				set_vertex(i, vert_1)
				
			commit_to_surface(mesh_temp)
			clear()
			
		return mesh_temp
		
	func modifier_parameters(item, tree):
		add_tree_range(item, tree, "Angle", 0, 1, -180, 180)
		
#End TwistModifier

class ArrayModifier:
	extends Modifier
	
	static func get_name():
		return "Array"
		
	func modifier(params, aabb, mesh):
		var mesh_temp = Mesh.new()
		var offset = Vector3(params[2], params[3], params[4])
		
		if params[1]:
			var x = aabb.get_endpoint(0).x - aabb.get_endpoint(7).x
			var y = aabb.get_endpoint(0).y - aabb.get_endpoint(7).y
			var z = aabb.get_endpoint(0).z - aabb.get_endpoint(7).z
			
			offset *= Vector3(x, y, z).abs()
			
		for surf in range(mesh.get_surface_count()):
			create_from_surface(mesh, surf)
			
			commit_to_surface(mesh_temp)
			
			for c in range(params[0]):
				for i in range(get_vertex_count()):
					var v = get_vertex(i)
					
					v += offset
					
					set_vertex(i, v)
					
				commit_to_surface(mesh_temp)
				
			clear()
			
		return mesh_temp
		
	func modifier_parameters(item, tree):
		add_tree_range(item, tree, "Count", 0, 1, 0, 100)
		add_tree_check(item, tree, "Relative", false)
		add_tree_range(item, tree, "Offset X", 0, 0.1, -1000, 1000)
		add_tree_range(item, tree, "Offset Y", 0, 0.1, -1000, 1000)
		add_tree_range(item, tree, "Offset Z", 0, 0.1, -1000, 1000)
		
#End ArrayModifier

class OffsetModifier:
	extends Modifier
	
	static func get_name():
		return 'Offset'
		
	func modifier(params, aabb, mesh):
		var mesh_temp = Mesh.new()
		
		var offset = Vector3(params[1], params[2], params[3])
		if params[0]:
			var x = aabb.get_endpoint(0).x - aabb.get_endpoint(7).x
			var y = aabb.get_endpoint(0).y - aabb.get_endpoint(7).y
			var z = aabb.get_endpoint(0).z - aabb.get_endpoint(7).z
			
			offset *= Vector3(x,y,z).abs()
			
		for surf in range(mesh.get_surface_count()):
			create_from_surface(mesh, surf)
			
			for i in range(get_vertex_count()):
				var v = get_vertex(i)
				
				v += offset
				
				set_vertex(i, v)
				
			commit_to_surface(mesh_temp)
			
		clear()
		
		return mesh_temp
		
	func modifier_parameters(item, tree):
		add_tree_check(item, tree, 'Relative', false)
		add_tree_range(item, tree, 'X', 0, 0.1, -1000, 100)
		add_tree_range(item, tree, 'Y', 0, 0.1, -1000, 100)
		add_tree_range(item, tree, 'Z', 0, 0.1, -1000, 100)
		
#End OffsetArray
#############################################################################################

func get_modifiers():
	return {"Taper":TaperModifier,
	        "Shear":ShearModifier,
	        "Twist":TwistModifier,
	        "Array":ArrayModifier, 
	        "Offset":OffsetModifier}