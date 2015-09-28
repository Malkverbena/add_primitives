#==============================================================================#
# Copyright (c) 2015 Franklin Sobrinho.                                        #
#                                                                              #
# Permission is hereby granted, free of charge, to any person obtaining        #
# a copy of this software and associated documentation files (the "Software"), #
# to deal in the Software without restriction, including without               #
# limitation the rights to use, copy, modify, merge, publish,                  #
# distribute, sublicense, and/or sell copies of the Software, and to           #
# permit persons to whom the Software is furnished to do so, subject to        #
# the following conditions:                                                    #
#                                                                              #
# The above copyright notice and this permission notice shall be               #
# included in all copies or substantial portions of the Software.              #
#                                                                              #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,              #
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF           #
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.       #
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY         #
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,         #
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE            #
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                       #
#==============================================================================#

extends Reference

class ModifierBase:
	extends MeshDataTool
	
	static func get_name():
		return ""
		
	func modifier_parameters(editor):
		pass
		
# End Modifier

class TaperModifier:
	extends ModifierBase
	
	var value = -0.5
	var lock_x_axis = false
	var lock_z_axis = false
	
	static func get_name():
		return "Taper"
		
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
		
	func modifier_parameters(editor):
		editor.add_tree_range('Value', value)
		editor.add_tree_check('Lock X Axis', lock_x_axis)
		editor.add_tree_check('Lock Z Axis', lock_z_axis)
		
# End TaperModifer

class ShearModifier:
	extends ModifierBase
	
	var shear_axis = Vector3.AXIS_X
	var value = 1
	
	static func get_name():
		return "Shear"
		
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
		
	func modifier_parameters(editor):
		editor.add_tree_combo('Shear Axis', shear_axis, 'x,y,z')
		editor.add_tree_range('Value', value)
		
# End ShearModifier

class TwistModifier:
	extends ModifierBase
	
	var angle = 30
	
	static func get_name():
		return "Twist"
		
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
		
	func modifier_parameters(editor):
		editor.add_tree_range('Angle', angle, 1, -180, 180)
		
# End TwistModifier

class ArrayModifier:
	extends ModifierBase
	
	var count = 2
	var relative = true
	var offset = Vector3(1,0,0)
	
	static func get_name():
		return "Array"
		
	func _set(name, value):
		if name.begins_with('offset'):
			var axis = name.split('_')[1]
			
			if axis == 'x':
				offset.x = value
				
			elif axis == 'y':
				offset.y = value
				
			elif axis == 'z':
				offset.z = value
				
	func modifier(mesh, aabb):
		var mesh_temp = Mesh.new()
		
		var ofs = offset
		
		if relative:
			var vec = aabb.get_endpoint(0) - aabb.get_endpoint(7)
			
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
		
	func modifier_parameters(editor):
		editor.add_tree_range('Count', count, 1, 1, 100)
		editor.add_tree_check('Relative', relative)
		editor.add_tree_range('Offset X', offset.x)
		editor.add_tree_range('Offset Y', offset.y)
		editor.add_tree_range('Offset Z', offset.z)
		
# End ArrayModifier

class OffsetModifier:
	extends ModifierBase
	
	var relative = true
	var offset = Vector3(0,0.5,0)
	
	static func get_name():
		return "Offset"
		
	func _set(name, value):
		if name == 'x':
			offset.x = value
			
			return true
			
		elif name == 'y':
			offset.y = value
			
			return true
			
		elif name == 'z':
			offset.z = value
			
			return true
			
		return false
		
	func modifier(mesh, aabb):
		var mesh_temp = Mesh.new()
		
		var ofs = offset
		
		if relative:
			var vec = aabb.get_endpoint(0) - aabb.get_endpoint(7)
			
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
		
	func modifier_parameters(editor):
		editor.add_tree_check('Relative', relative)
		editor.add_tree_range('X', offset.x)
		editor.add_tree_range('Y', offset.y)
		editor.add_tree_range('Z', offset.z)
		
# End OffsetModifier

class RandomModifier:
	extends ModifierBase
	
	var random_seed = 0
	var amount = 1
	
	static func get_name():
		return "Random"
		
	func modifier(mesh, aabb):
		var mesh_temp = Mesh.new()
		
		seed(random_seed + 1)
		
		var cache = {}
		
		for surf in range(mesh.get_surface_count()):
			create_from_surface(mesh, surf)
			
			for i in range(get_vertex_count()):
				var v = get_vertex(i)
				
				if not cache.has(v):
					cache[v] = Vector3(rand_range(-1,1) ,\
					                   rand_range(-1,1) ,\
					                   rand_range(-1,1)) * amount
					
				v += cache[v]
				
				set_vertex(i, v)
				
			commit_to_surface(mesh_temp)
			
		cache.clear()
		
		clear()
		
		return mesh_temp
		
	func modifier_parameters(editor):
		editor.add_tree_range('Amount', amount)
		editor.add_tree_range('Random Seed', random_seed, 1, 0, 61)
		
# End RandomModifier

class UVTransformModifier:
	extends ModifierBase
	
	var translation = Vector2()
	var rotation = 0
	var scale = Vector2(1,1)
	
	static func get_name():
		return "UV Transform"
		
	func _set(name, value):
		if name.begins_with('translation'):
			var axis = name.split('_')[1]
			
			if axis == 'x':
				translation.x = value
				
				return true
				
			elif axis == 'y':
				translation.y = value
				
				return true
				
		elif name.begins_with('scale'):
			var axis = name.split('_')[1]
			
			if axis == 'x':
				scale.x = value
				
				return true
				
			elif axis == 'y':
				scale.y = value
				
				return true
				
		return false
		
	func modifier(mesh, aabb):
		var mesh_temp = Mesh.new()
		
		var m32 = Matrix32()
		
		if translation != Vector2():
			m32 = m32.translated(translation)
			
		if rotation:
			m32 = m32.rotated(deg2rad(rotation))
			
		if scale != Vector2(1, 1):
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
		
	func modifier_parameters(editor):
		editor.add_tree_range('Translation X', translation.x, 0.01, 0, 100)
		editor.add_tree_range('Translation Y', translation.y, 0.01, 0, 100)
		editor.add_tree_range('Rotation', rotation, 1, 0, 360)
		editor.add_tree_range('Scale X', scale.x, 0.01, 0.01, 100)
		editor.add_tree_range('Scale Y', scale.y, 0.01, 0.01, 100)
		
# End UVTransformModifier 

################################################################################
################################################################################
################################################################################

static func get_modifiers():
	var modifiers = {
		"Taper"  : TaperModifier,
		"Shear"  : ShearModifier,
		"Twist"  : TwistModifier,
		"Array"  : ArrayModifier, 
		"Offset" : OffsetModifier,
		"Random" : RandomModifier,
		"UV Transform" : UVTransformModifier 
	}
	
	return modifiers
	

