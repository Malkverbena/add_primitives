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

extends EditorPlugin

#Utilites
func get_plugins_folder():
	var path = OS.get_data_dir()
	path = path.substr(0, path.find_last('/'))
	path = path.substr(0, path.find_last('/'))
	return path + '/plugins'
	
func get_spatial_node():
	var root = get_tree().get_edited_scene_root()
	
	if root != null:
		if root.get_type() == 'Spatial':
			return root
		else:
			for node in root.get_children():
				if node.get_type() == 'Spatial':
					return node
	return null
	
#main function
func heightmap():
	var heightmap_script
	var mesh_builder
	
	heightmap_script = load(get_plugins_folder() + '/Add Primitives v1.1/3d/heightmap/heightmap.gd').new()
	mesh_builder = load(get_plugins_folder() + '/Add Primitives v1.1/3d/heightmap/mesh.gd').new()
	
	var mesh
	
	if mesh_builder.has_method('build_mesh'):
		mesh = mesh_builder.build_mesh(null, 50, 32, 5)
		
		heightmap_script.set_mesh(mesh)
		
		#root and node can be the same
		if is_inside_tree():
			var root = get_tree().get_edited_scene_root()
			var node = get_spatial_node()
			
			if node:
				node.add_child(heightmap_script)
				heightmap_script.set_owner(root)
				heightmap_script.set_name('Heigthmap')
				heightmap_script.create_trimesh_collision()
