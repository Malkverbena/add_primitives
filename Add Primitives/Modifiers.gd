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

class Modifier extends MeshDataTool:
	
	static func get_name():
		return ""
		
	func modify(mesh, aabb):
		return mesh
		
	func modifier_parameters(editor):
		pass
		
# End Modifier

class TaperModifier extends Modifier:
	
	var value = -0.5
	var lock_x_axis = false
	var lock_z_axis = false
	
	static func get_name():
		return "Taper"
		
	static func taper(vector, value, height, axis):
		var vec = Vector3(1, 1, 1)
		
		for i in axis:
			vec[i] += vector.y / height * value
			
		return vec
		
	func modify(mesh, aabb):
		var new_mesh = Mesh.new()
		
		var c = aabb.size.y/2 
		
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
				
			commit_to_surface(new_mesh)
			
		clear()
		
		return new_mesh
		
	func modifier_parameters(editor):
		editor.add_tree_range('Value', value)
		editor.add_tree_check('Lock X Axis', lock_x_axis)
		editor.add_tree_check('Lock Z Axis', lock_z_axis)
		
# End TaperModifer

class ShearModifier extends Modifier:
	
	var shear_axis = Vector3.AXIS_X
	var value = 1
	
	static func get_name():
		return "Shear"
		
	func modify(mesh, aabb):
		var new_mesh = Mesh.new()
		
		var h_axis = int(shear_axis != Vector3.AXIS_Y)
		var c = aabb.size[h_axis]/2
		
		for surf in range(mesh.get_surface_count()):
			create_from_surface(mesh, surf)
			
			for i in range(get_vertex_count()):
				var v = get_vertex(i)
				
				v[shear_axis] += v[h_axis] / c * value
				
				set_vertex(i, v)
				
			commit_to_surface(new_mesh)
			
		clear()
		
		return new_mesh
		
	func modifier_parameters(editor):
		editor.add_tree_combo('Shear Axis', shear_axis, 'X,Y,Z')
		editor.add_tree_range('Value', value)
		
# End ShearModifier

class TwistModifier extends Modifier:
	
	var angle = 30
	
	static func get_name():
		return "Twist"
		
	func modify(mesh, aabb):
		var new_mesh = Mesh.new()
		
		var c = aabb.size.y/2
		
		for surf in range(mesh.get_surface_count()):
			create_from_surface(mesh, surf)
			
			for i in range(get_vertex_count()):
				var v = get_vertex(i)
				
				v = v.rotated(Vector3(0, 1, 0), deg2rad(v.y / c * angle))
				
				set_vertex(i, v)
				
			commit_to_surface(new_mesh)
			
		clear()
		
		return new_mesh
		
	func modifier_parameters(editor):
		editor.add_tree_range('Angle', angle, 1, -180, 180)
		
# End TwistModifier

class ArrayModifier extends Modifier:
	
	var count = 2
	var relative = true
	var x = 1.0
	var y = 0.0
	var z = 0.0
	
	static func get_name():
		return "Array"
		
	func modify(mesh, aabb):
		var new_mesh = Mesh.new()
		
		var ofs = Vector3(x, y, z)
		
		if relative:
			ofs *= aabb.size
			
		for surf in range(mesh.get_surface_count()):
			create_from_surface(mesh, surf)
			
			commit_to_surface(new_mesh)
			
			for c in range(count - 1):
				for i in range(get_vertex_count()):
					var v = get_vertex(i)
					
					v += ofs
					
					set_vertex(i, v)
					
				commit_to_surface(new_mesh)
				
		clear()
		
		return new_mesh
		
	func modifier_parameters(editor):
		editor.add_tree_range('Count', count, 1, 1, 100)
		editor.add_tree_check('Relative', relative)
		editor.add_tree_range('X', x)
		editor.add_tree_range('Y', y)
		editor.add_tree_range('Z', z)
		
# End ArrayModifier

class OffsetModifier extends Modifier:
	
	var relative = true
	var x = 0.0
	var y = 0.5
	var z = 0.0
	
	static func get_name():
		return "Offset"
		
	func modify(mesh, aabb):
		var new_mesh = Mesh.new()
		
		var ofs = Vector3(x, y, z)
		
		if relative:
			ofs *= aabb.size
			
		for surf in range(mesh.get_surface_count()):
			create_from_surface(mesh, surf)
			
			for i in range(get_vertex_count()):
				var v = get_vertex(i)
				
				v += ofs
				
				set_vertex(i, v)
				
			commit_to_surface(new_mesh)
			
		clear()
		
		return new_mesh
		
	func modifier_parameters(editor):
		editor.add_tree_check('Relative', relative)
		editor.add_tree_range('X', x)
		editor.add_tree_range('Y', y)
		editor.add_tree_range('Z', z)
		
# End OffsetModifier

class RandomModifier extends Modifier:
	
	var random_seed = 0
	var amount = 1
	
	static func get_name():
		return "Random"
		
	func modify(mesh, aabb):
		var new_mesh = Mesh.new()
		
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
				
			commit_to_surface(new_mesh)
			
		cache.clear()
		
		clear()
		
		return new_mesh
		
	func modifier_parameters(editor):
		editor.add_tree_range('Amount', amount)
		editor.add_tree_range('Random Seed', random_seed, 1, 0, 61)
		
# End RandomModifier

class UVTransformModifier extends Modifier:
	
	var translation_x = 0.0
	var translation_y = 0.0
	var rotation = 0
	var scale_x = 1.0
	var scale_y = 1.0
	
	static func get_name():
		return "UV Transform"
		
	func modify(mesh, aabb):
		var new_mesh = Mesh.new()
		
		var t = Matrix32(deg2rad(rotation), Vector2(translation_x, translation_y)).scaled(Vector2(scale_x, scale_y))
		
		for surf in range(mesh.get_surface_count()):
			if not mesh.surface_get_format(surf) & Mesh.ARRAY_FORMAT_TEX_UV:
				continue
				
			create_from_surface(mesh, surf)
			
			for i in range(get_vertex_count()):
				var uv = get_vertex_uv(i)
				
				uv = t.xform(uv)
				
				set_vertex_uv(i, uv)
				
			commit_to_surface(new_mesh)
			
		clear()
		
		if not new_mesh.get_surface_count():
			return mesh
			
		return new_mesh
		
	func modifier_parameters(editor):
		editor.add_tree_range('Translation X', translation_x)
		editor.add_tree_range('Translation Y', translation_y)
		editor.add_tree_range('Rotation', rotation, 1, -360, 360)
		editor.add_tree_range('Scale X', scale_x)
		editor.add_tree_range('Scale Y', scale_y)
		
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
	

