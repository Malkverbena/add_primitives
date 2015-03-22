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
extends EditorPlugin

var module_3d
var module_2d

#Utilites
func get_plugins_folder():
	var path = OS.get_data_dir()
	path = path.substr(0, path.find_last('/'))
	path = path.substr(0, path.find_last('/'))
	return path + "/plugins"
	
func _init():
	print("PLUGIN INIT")

func _enter_tree():
	var dir = Directory.new()
	
	var path = get_plugins_folder() + '/Add Primitives v1.1'
	
	if dir.dir_exists(path + '/3d'):
		if dir.file_exists(path + '/3d/module_3d.gd'):
			#register 3d module
			module_3d = weakref(load(path + '/3d/module_3d.gd').new())
			module_3d.get_ref().set_name('module_3d')
			
			if not module_3d.get_ref().is_inside_tree():
				add_child(module_3d.get_ref())
				
func _exit_tree():
	module_3d.get_ref()._end()
