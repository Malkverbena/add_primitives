extends Reference

class ModifierBase:
	extends MeshDataTool
	
	# In case of modifier not have parameters
	func set_parameter(name, value):
		pass
		
	# Tree Item helper functions
	func _create_item(item, tree):
		item = tree.create_item(item)
		
		return item
		
	func add_tree_range(item, tree, text, value, step = 0.01, min_ = -100, max_ = 100):
		var tree_item = _create_item(item, tree)
		
		tree_item.set_text(0, text)
		
		if typeof(step) == TYPE_INT:
			tree_item.set_icon(0, tree.get_icon('Integer', 'EditorIcons'))
		else:
			tree_item.set_icon(0, tree.get_icon('Real', 'EditorIcons'))
		tree_item.set_selectable(0, false)
		
		tree_item.set_cell_mode(1, 2)
		tree_item.set_range_config(1, min_, max_, step)
		tree_item.set_range(1, value)
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
		
# End Modifier

class TaperModifier:
	extends ModifierBase
	
	var value = -0.5
	var lock_x_axis = false
	var lock_z_axis = false
	
	static func get_name():
		return "Taper"
		
	func set_parameter(name, val):
		if name == 'Value':
			value = val
			
		elif name == 'Lock X Axis':
			lock_x_axis = val
			
		elif name == 'Lock Z Axis':
			lock_z_axis = val
			
	static func taper(vector, val, c, axis):
		var vec = Vector3(1,1,1)
		
		for i in axis:
			vec[i] += val * (vector.y/c)
			
		return vec
		
	func modifier(mesh, aabb):
		var mesh_temp = Mesh.new()
		
		var h = aabb.get_endpoint(7).y - aabb.get_endpoint(0).y
		var c = h/2 
		
		var m3 = Matrix3()
		
		var axis = []
		
		if not lock_x_axis:
			axis.push_back(Vector3.AXIS_X)
			
		if not lock_z_axis:
			axis.push_back(Vector3.AXIS_Z)
			
		for surf in range(mesh.get_surface_count()):
			create_from_surface(mesh, surf)
			
			for i in range(get_vertex_count()):
				var v = get_vertex(i)
				
				v = m3.scaled(taper(v, value, c, axis)).xform(v)
				
				set_vertex(i, v)
				
			commit_to_surface(mesh_temp)
			
		clear()
		
		return mesh_temp
		
	func modifier_parameters(item, tree):
		add_tree_range(item, tree, 'Value', value)
		add_tree_check(item, tree, 'Lock X Axis', lock_x_axis)
		add_tree_check(item, tree, 'Lock Z Axis', lock_z_axis)
		
# End TaperModifer

class ShearModifier:
	extends ModifierBase
	
	var shear_axis = Vector3.AXIS_X
	var value = 1
	
	static func get_name():
		return "Shear"
		
	func set_parameter(name, val):
		if name == 'Shear Axis':
			shear_axis = val
			
		elif name == 'Value':
			value = val
			
	func modifier(mesh, aabb):
		var mesh_temp = Mesh.new()
		
		var h
		var c
		
		var s_axis
		var b_axis
		
		if shear_axis == Vector3.AXIS_X or shear_axis == Vector3.AXIS_Y:
			h = aabb.get_endpoint(7).y - aabb.get_endpoint(0).y
			
			if shear_axis == Vector3.AXIS_X:
				s_axis = Vector3.AXIS_X
				
			elif shear_axis == Vector3.AXIS_Y:
				s_axis = Vector3.AXIS_Z
				
			b_axis = Vector3.AXIS_Y
			
		elif shear_axis == Vector3.AXIS_Z:
			h = aabb.get_endpoint(7).x - aabb.get_endpoint(0).x
			
			s_axis = Vector3.AXIS_Y
			b_axis = Vector3.AXIS_X
			
		c = h/2
		
		for surf in range(mesh.get_surface_count()):
			create_from_surface(mesh, surf)
			
			for i in range(get_vertex_count()):
				var v = get_vertex(i)
				
				v[s_axis] += value * (v[b_axis]/c)
				
				set_vertex(i, v)
				
			commit_to_surface(mesh_temp)
			
		clear()
		
		return mesh_temp
		
	func modifier_parameters(item, tree):
		add_tree_combo(item, tree, 'Shear Axis', 'x,y,z', shear_axis)
		add_tree_range(item, tree, 'Value', value)
		
# End ShearModifier

class TwistModifier:
	extends ModifierBase
	
	var angle = 30
	
	static func get_name():
		return "Twist"
		
	func set_parameter(name, value):
		if name == 'Angle':
			angle = value
			
	func modifier(mesh, aabb):
		var mesh_temp = Mesh.new()
		
		var h = aabb.get_endpoint(7).y - aabb.get_endpoint(0).y
		var c = h/2
		
		for surf in range(mesh.get_surface_count()):
			create_from_surface(mesh, surf)
			
			for i in range(get_vertex_count()):
				var v = get_vertex(i)
				
				v = v.rotated(Vector3(0,1,0), deg2rad(angle * (v.y/c)))
				
				set_vertex(i, v)
				
			commit_to_surface(mesh_temp)
			
		clear()
		
		return mesh_temp
		
	func modifier_parameters(item, tree):
		add_tree_range(item, tree, 'Angle', angle, 1, -180, 180)
		
# End TwistModifier

class ArrayModifier:
	extends ModifierBase
	
	var count = 2
	var relative = true
	var offset = Vector3(1,0,0)
	
	static func get_name():
		return "Array"
		
	func set_parameter(name, value):
		if name == 'Count':
			count = value
			
		elif name == 'Relative':
			relative = value
			
		elif name == 'Offset X':
			offset.x = value
			
		elif name == 'Offset Y':
			offset.y = value
			
		elif name == 'Offset Z':
			offset.z = value
			
	func modifier(mesh, aabb):
		var mesh_temp = Mesh.new()
		
		var ofs = offset
		
		if relative:
			var vec = Vector3()
			
			vec.x = aabb.get_endpoint(0).x - aabb.get_endpoint(7).x
			vec.y = aabb.get_endpoint(0).y - aabb.get_endpoint(7).y
			vec.z = aabb.get_endpoint(0).z - aabb.get_endpoint(7).z
			
			ofs *= vec.abs()
			
		for surf in range(mesh.get_surface_count()):
			create_from_surface(mesh, surf)
			
			commit_to_surface(mesh_temp)
			
			for c in range(count - 1):
				for i in range(get_vertex_count()):
					var v = get_vertex(i)
					
					v += ofs
					
					set_vertex(i, v)
					
				commit_to_surface(mesh_temp)
				
		clear()
		
		return mesh_temp
		
	func modifier_parameters(item, tree):
		add_tree_range(item, tree, 'Count', count, 1, 1, 100)
		add_tree_check(item, tree, 'Relative', relative)
		add_tree_range(item, tree, 'Offset X', offset.x)
		add_tree_range(item, tree, 'Offset Y', offset.y)
		add_tree_range(item, tree, 'Offset Z', offset.z)
		
# End ArrayModifier

class OffsetModifier:
	extends ModifierBase
	
	var relative = true
	var offset = Vector3(0,0.5,0)
	
	static func get_name():
		return "Offset"
		
	func set_parameter(name, value):
		if name == 'Relative':
			relative = value
			
		elif name == 'X':
			offset.x = value
			
		elif name == 'Y':
			offset.y = value
			
		elif name == 'Z':
			offset.z = value
			
	func modifier(mesh, aabb):
		var mesh_temp = Mesh.new()
		
		var ofs = offset
		
		if relative:
			var vec = Vector3()
			
			vec.x = aabb.get_endpoint(0).x - aabb.get_endpoint(7).x
			vec.y = aabb.get_endpoint(0).y - aabb.get_endpoint(7).y
			vec.z = aabb.get_endpoint(0).z - aabb.get_endpoint(7).z
			
			ofs *= vec.abs()
			
		for surf in range(mesh.get_surface_count()):
			create_from_surface(mesh, surf)
			
			for i in range(get_vertex_count()):
				var v = get_vertex(i)
				
				v += ofs
				
				set_vertex(i, v)
				
			commit_to_surface(mesh_temp)
			
		clear()
		
		return mesh_temp
		
	func modifier_parameters(item, tree):
		add_tree_check(item, tree, 'Relative', relative)
		add_tree_range(item, tree, 'X', offset.x)
		add_tree_range(item, tree, 'Y', offset.y)
		add_tree_range(item, tree, 'Z', offset.z)
		
# End OffsetModifier

class RandomModifier:
	extends ModifierBase
	
	var x = 0.1
	var y = 0.1
	var z = 0.1
	
	static func get_name():
		return "Random"
		
	func set_parameter(name, value):
		if name == 'X':
			x = value
			
		elif name == 'Y':
			y = value
			
		elif name == 'Z':
			z = value
			
	func modifier(mesh, aabb):
		var mesh_temp = Mesh.new()
		
		var cache = {}
		
		for surf in range(mesh.get_surface_count()):
			create_from_surface(mesh, surf)
			
			for i in range(get_vertex_count()):
				var v = get_vertex(i)
				
				if not cache.has(v):
					cache[v] = Vector3(rand_range(-1,1) * x,\
					                   rand_range(-1,1) * y,\
					                   rand_range(-1,1) * z)
					
				v += cache[v]
				
				set_vertex(i, v)
				
			commit_to_surface(mesh_temp)
			
		cache.clear()
		
		clear()
		
		return mesh_temp
		
	func modifier_parameters(item, tree):
		add_tree_range(item, tree, 'X', x, 0.01, 0, 100)
		add_tree_range(item, tree, 'Y', y, 0.01, 0, 100)
		add_tree_range(item, tree, 'Z', z, 0.01, 0, 100)
		
# End RandomModifier

class UVTransformModifier:
	extends ModifierBase
	
	var translation = Vector2()
	var rotation = 0
	var scale = Vector2(1,1)
	
	static func get_name():
		return "UV Transform"
		
	func set_parameter(name, value):
		if name == 'Translation X':
			translation.x = value
			
		elif name == 'Translation Y':
			translation.y = value
			
		elif name == 'Rotation':
			rotation = deg2rad(value)
			
		elif name == 'Scale X':
			scale.x = value
			
		elif name == 'Scale Y':
			scale.y = value
			
	func modifier(mesh, aabb):
		var mesh_temp = Mesh.new()
		
		var m32 = Matrix32()
		
		if translation != Vector2():
			m32 = m32.translated(translation)
			
		if rotation:
			m32 = m32.rotated(rotation)
			
		if scale != Vector2():
			m32 = m32.scaled(scale)
			
		for surf in range(mesh.get_surface_count()):
			if not mesh.surface_get_format(surf) & mesh.ARRAY_FORMAT_TEX_UV:
				continue
				
			create_from_surface(mesh, surf)
			
			for i in range(get_vertex_count()):
				var uv = get_vertex_uv(i)
				
				uv = m32.xform(uv)
				
				set_vertex_uv(i, uv)
				
			commit_to_surface(mesh_temp)
			
		clear()
		
		if not mesh_temp.get_surface_count():
			return mesh
			
		return mesh_temp
		
	func modifier_parameters(item, tree):
		add_tree_range(item, tree, 'Translation X', translation.x, 0.01, 0, 100)
		add_tree_range(item, tree, 'Translation Y', translation.y, 0.01, 0, 100)
		add_tree_range(item, tree, 'Rotation', rad2deg(rotation), 1, 0, 360)
		add_tree_range(item, tree, 'Scale X', scale.x, 0.01, 0.01, 100)
		add_tree_range(item, tree, 'Scale Y', scale.y, 0.01, 0.01, 100)
		
# End UVTransformModifier 

################################################################################

func get_modifiers():
	var modifiers = {
		"Taper"  :TaperModifier,
		"Shear"  :ShearModifier,
		"Twist"  :TwistModifier,
		"Array"  :ArrayModifier, 
		"Offset" :OffsetModifier,
		"Random" :RandomModifier,
		"UV Transform" :UVTransformModifier 
	}
	
	return modifiers
	

