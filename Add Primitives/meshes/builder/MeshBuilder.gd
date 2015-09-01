#==============================================================================#
# Copyright (c) 2015 Franklin Sobrinho.                                        # #                                                                              #
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

var invert = false

static func get_name():
	return ""
	
static func get_container():
	return ""
	
func set_invert(val):
	invert = val
	
func commit():
	var mesh = Mesh.new()
	
	generate_normals()
	index()
	
	.commit(mesh)
	
	var regen_normalmaps = true
	
	for i in range(mesh.get_surface_count()):
		if not mesh.surface_get_format(i) & mesh.ARRAY_FORMAT_TEX_UV:
			regen_normalmaps = false
			
			break
			
	if regen_normalmaps:
		mesh.regen_normalmaps()
	
	clear()
	
	return mesh
	
func add_tri(vertex = [], uv = []):
	assert( vertex.size() == 3 )
	
	if invert:
		vertex.invert()
		uv.invert()
		
	if uv.size():
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
		
func add_quad(vertex = [], uv = []):
	assert( vertex.size() == 4 )
	
	if invert:
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
		
func build_plane(start, end, offset = Vector3(0,0,0)):
	var verts = []
	verts.resize(4)
	
	verts[0] = offset + end
	verts[1] = offset + end + start
	verts[2] = offset + start
	verts[3] = offset
	
	var uv = []
	uv.resize(4)
	
	var w = verts[3].distance_to(verts[2])
	var h = verts[3].distance_to(verts[0])
	
	uv[0] = Vector2(0, h)
	uv[1] = Vector2(w, h)
	uv[2] = Vector2(w, 0)
	uv[3] = Vector2(0, 0)
	
	add_quad(verts, uv)
	
static func build_plane_verts(start, end, offset = Vector3(0,0,0)):
	var verts = []
	
	verts.push_back(offset + end)
	verts.push_back(offset + end + start)
	verts.push_back(offset + start)
	verts.push_back(offset)
	
	return verts
	
static func build_circle_verts(pos, segments, radius = 1, angle = PI * 2):
	var circle_verts = []
	circle_verts.resize(segments + 1)
	
	var s_angle = angle/segments
	
	for i in range(segments):
		var a = s_angle * i
		
		var vector = Vector3(cos(a), 0, sin(a)) * radius + pos
		
		circle_verts[i] = vector
		
	if rad2deg(angle) != 360:
		circle_verts[segments] = Vector3(cos(angle), 0, sin(angle)) * radius + pos
		
	else:
		circle_verts[segments] = circle_verts[0]
		
	return circle_verts
	
static func build_circle_verts_rot(pos, segments, radius = 1, rotation = [], axis = []):
	var circle_verts = []
	circle_verts.resize(segments + 1)
	
	var angle = PI * 2 / segments
	
	for i in range(segments):
		var a = angle * i
		
		var vector = Vector3(cos(a), 0, sin(a)) * radius
		
		for i in range(rotation.size()):
			vector = vector.rotated(axis[i], rotation[i])
			
		vector += pos
		
		circle_verts[i] = vector
		
	circle_verts[segments] = circle_verts[0]
	
	return circle_verts
	
static func build_ellipse_verts(pos, segments, radius = Vector2(1,1), angle = PI * 2):
	var ellipse_verts = []
	ellipse_verts.resize(segments + 1)
	
	var s_angle = angle / segments
	
	for i in range(segments):
		var a = s_angle * i
		
		var vector = Vector3(sin(a) * radius.x, 0, cos(a) * radius.y)
		
		vector += pos
		
		ellipse_verts[i] = vector
		
	if rad2deg(angle) != 360:
		ellipse_verts[segments] = Vector3(sin(angle) * radius.x, 0, cos(angle) * radius.y) + pos
		
	else:
		ellipse_verts[segments] = ellipse_verts[0]
		
	return ellipse_verts
	
static func plane_uv(start, end, last = true):
	var uv = [Vector2(start, end), Vector2(0, end), Vector2(0, 0), Vector2(start, 0)]
	
	if not last:
		uv.remove(3)
		
	return uv
	
# Tree Item helper functions
static func _create_item(tree):
	var root = tree.get_root()
	
	if not root:
		root = tree.create_item()
		
	var item = tree.create_item(root)
	
	return item
	
static func add_tree_empty(tree):
	var tree_item = _create_item(tree)
	
	tree_item.set_selectable(0, false)
	tree_item.set_selectable(1, false)
	
static func add_tree_range(tree, text, value, step = 0.01, min_ = 0.01, max_ = 100):
	var tree_item = _create_item(tree)
	
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
	
static func add_tree_combo(tree, text, items, selected = 0):
	var tree_item = _create_item(tree)
	
	tree_item.set_text(0, text)
	tree_item.set_icon(0, tree.get_icon('Enum', 'EditorIcons'))
	tree_item.set_selectable(0, false)
	tree_item.set_cell_mode(1, 2)
	tree_item.set_text(1, items)
	tree_item.set_range(1, selected)
	tree_item.set_editable(1, true)
	
static func add_tree_check(tree, text, checked = false):
	var tree_item = _create_item(tree)
	
	tree_item.set_text(0, text)
	tree_item.set_icon(0, tree.get_icon('Bool', 'EditorIcons'))
	tree_item.set_selectable(0, false)
	tree_item.set_cell_mode(1, 1)
	tree_item.set_checked(1, checked)
	tree_item.set_text(1, 'On')
	tree_item.set_editable(1, true)
	
static func add_tree_entry(tree, text, string = ''):
	var tree_item = _create_item(tree)
	
	tree_item.set_text(0, text)
	tree_item.set_icon(0, tree.get_icon('String', 'EditorIcons'))
	tree_item.set_selectable(0, false)
	tree_item.set_cell_mode(1, 0)
	tree_item.set_text(1, string)
	tree_item.set_editable(1, true)
	

