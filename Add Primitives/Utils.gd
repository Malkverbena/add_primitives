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

extends Reference

static func build_plane_verts(dir1, dir2, offset = Vector3(0,0,0)):
	var verts = []
	verts.resize(4)
	
	verts[0] = offset
	verts[1] = offset + dir2
	verts[2] = offset + dir2 + dir1
	verts[3] = offset + dir1
	
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
	
static func build_circle_verts_rot(pos, segments, radius = 1, matrix = Matrix3()):
	var circle_verts = []
	circle_verts.resize(segments + 1)
	
	var s_angle = PI * 2 / segments
	
	for i in range(segments):
		var a = s_angle * i
		
		var vector = Vector3(cos(a), 0, sin(a)) * radius
		vector = matrix.xform(vector)
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
	
static func plane_uv(width, height, last = true):
	var uv = []
	uv.resize(4)
	
	uv[0] = Vector2(0, 0)
	uv[1] = Vector2(0, height)
	uv[2] = Vector2(width, height)
	uv[3] = Vector2(width, 0)
	
	if not last:
		uv.remove(3)
		
	return uv
	
