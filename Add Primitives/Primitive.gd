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

const Utils = preload("Utils.gd")

var smooth = false
var flip_normals = false

static func get_name():
	return ""
	
static func get_container():
	return ""
	
func add_tri(vertex = [], uv = []):
	assert( vertex.size() == 3 )
	
	if flip_normals:
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
	
	if flip_normals:
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
		
func add_plane(start, end, offset = Vector3()):
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
	
func commit():
	var mesh = Mesh.new()
	
	generate_normals()
	index()
	
	.commit(mesh)
	
	#if mesh.get_surface_count() and mesh.surface_get_format(0) & mesh.ARRAY_FORMAT_TEX_UV:
	#	mesh.regen_normalmaps()
	#	
	clear()
	
	return mesh
	

