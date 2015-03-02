# Copyright (c) 2015 Franklin Sobrinho.                 
                                                                       
# Permission is hereby granted, free of charge, to any person obtaining 
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without 
# limitation the rights to use, copy, modify, merge, publish,   
# distribute, sublicense, and/or sell copies of the Software, and to    
# permit persons to whom the Software is furnished to do so, subject to 
# the following conditions:                                             
                                                                       
# The above copyright notice and this permission notice shall be        
# included in all copies or substantial portions of the Software.       
                                                                       
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,       
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF    
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY  
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE     
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

tool
extends SurfaceTool

func add_tri(vertex_array, uv_array = null, reverse = false):
	if vertex_array.size() != 3:
		pass
	else:
		var face_index = [0,2,1]
		if reverse:
			face_index.invert()
		
		for idx in face_index:
			if uv_array != null:
				add_uv(uv_array[idx])
			add_vertex(vertex_array[idx])
	
func add_quad(vertex_array, uv_array = null, reverse = false):
	if vertex_array.size() != 4:
		pass
	else:
		var face_index = [0,2,1,3,0,1]
		if reverse:
			face_index.invert()
		for idx in face_index:
			if uv_array != null:
				add_uv(uv_array[idx])
			add_vertex(vertex_array[idx])