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
