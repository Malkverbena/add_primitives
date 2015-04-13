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

extends SurfaceTool

var parameters = []

const DEFAULT = 1

func add_tri(vertex = [], uv = [], reverse = false):
	assert( vertex.size() == 3 )
	
	if reverse:
		vertex.invert()
		uv.invert()
		
	if uv.size() == 3:
		add_uv(uv[0])
		add_vertex(vertex[0])
		add_uv(uv[1])
		add_vertex(vertex[1])
		add_uv(uv[2])
		add_vertex(vertex[2])
		
	else:
		add_vertex(vertex[0])
		add_vertex(vertex[1])
		add_vertex(vertex[2])
		
func add_quad(vertex = [], uv = [], reverse = false):
	assert( vertex.size() == 4 )
	
	if reverse:
		vertex.invert()
		uv.invert()
		
	if uv.size() == 4:
		add_uv(uv[0])
		add_vertex(vertex[0])
		add_uv(uv[1])
		add_vertex(vertex[1])
		add_uv(uv[2])
		add_vertex(vertex[2])
		add_uv(uv[2])
		add_vertex(vertex[2])
		add_uv(uv[3])
		add_vertex(vertex[3])
		add_uv(uv[0])
		add_vertex(vertex[0])
		
	else:
		add_vertex(vertex[0])
		add_vertex(vertex[1])
		add_vertex(vertex[2])
		add_vertex(vertex[2])
		add_vertex(vertex[3])
		add_vertex(vertex[0])
		
static func build_plane_verts(start, end, offset = Vector3(0,0,0)):
	var verts = []
	verts.append(Vector3(0,0,0) + offset + end)
	verts.append(Vector3(0,0,0) + offset + end + start)
	verts.append(Vector3(0,0,0) + offset + start)
	verts.append(Vector3(0,0,0) + offset)
	return verts
	
static func build_circle_verts(pos, segments, radius = 1, rotation = [], axis = []):
	var radians_circle = PI * 2
	var _radius = Vector3(radius, 1, radius)
	
	var circle_verts = []
	
	var m3 = Matrix3()
	
	for i in range(segments):
		var angle = radians_circle * i/segments
		var x = cos(angle)
		var z = sin(angle)
		
		var vector = Vector3(x, 0, z) * Vector3(radius, 1, radius)
		
		if not rotation.empty():
			assert( axis.size() == rotation.size())
			
			for i in range(rotation.size()):
				vector = m3.rotated(axis[i], rotation[i]) * vector
				
		circle_verts.push_back(vector + pos)
		
	circle_verts.push_back(circle_verts[0])
	
	return circle_verts
	
static func plane_uv(start, end, last = true):
	var u = 1
	var v = 1
	
	if start < end:
		u = start/end
	elif end < start:
		v = end/start
		
	var uv = [Vector2(u, v), Vector2(0, v), Vector2(0, 0), Vector2(u, 0)]
	
	if not last:
		uv.remove(3)
		
	return uv
	
#Tree Item helper functions
static func _create_item(tree):
	var root = tree.get_root()
	if not root:
		root = tree.create_item()
		
	var item = tree.create_item(root)
	return item
	
static func add_tree_empty(tree):
	var tree_item = _create_item(tree)
	
	tree_item.set_collapsed(true)
	tree_item.set_selectable(0, false)
	tree_item.set_selectable(1, false)
	
func add_tree_range(tree, text, value, step = 1, _min = 1, _max = 50):
	var tree_item = _create_item(tree)
	
	tree_item.set_text(0, text)
	
	if typeof(step) == TYPE_INT:
		tree_item.set_icon(0, tree.get_icon('Integer', 'EditorIcons'))
	else:
		tree_item.set_icon(0, tree.get_icon('Real', 'EditorIcons'))
	tree_item.set_selectable(0, false)
	
	tree_item.set_cell_mode(1, 2)
	tree_item.set_range_config(1, _min, _max, step)
	tree_item.set_range(1, value)
	tree_item.set_editable(1, true)
	
	parameters.append(tree_item)
	
func add_tree_combo(tree, text, items, selected = 0):
	var tree_item = _create_item(tree)
	
	tree_item.set_text(0, text)
	tree_item.set_icon(0, tree.get_icon('Enum', 'EditorIcons'))
	tree_item.set_selectable(0, false)
	tree_item.set_cell_mode(1, 2)
	tree_item.set_text(1, items)
	tree_item.set_range(1, selected)
	tree_item.set_editable(1, true)
	
	parameters.append(tree_item)
	
func add_tree_check(tree, text, checked = false):
	var tree_item = _create_item(tree)
	
	tree_item.set_text(0, text)
	tree_item.set_icon(0, tree.get_icon('Bool', 'EditorIcons'))
	tree_item.set_selectable(0, false)
	tree_item.set_cell_mode(1, 1)
	tree_item.set_checked(1, checked)
	tree_item.set_text(1, 'On')
	tree_item.set_editable(1, true)
	
	parameters.append(tree_item)
	
func add_tree_entry(tree, text, string = ''):
	var tree_item = _create_item(tree)
	
	tree_item.set_text(0, text)
	tree_item.set_icon(0, tree.get_icon('String', 'EditorIcons'))
	tree_item.set_selectable(0, false)
	tree_item.set_cell_mode(1, 0)
	tree_item.set_text(1, string)
	tree_item.set_editable(1, true)
	
	parameters.append(tree_item)
	
func get_parameters():
	return parameters
