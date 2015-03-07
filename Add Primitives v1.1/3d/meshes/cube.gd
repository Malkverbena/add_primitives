extends "builder/mesh_builder.gd"

func build_plane_verts(width_dir, length_dir, offset = Vector3(0,0,0)):
	var verts = []
	verts.append(Vector3(0,0,0) + offset + length_dir)
	verts.append(Vector3(0,0,0) + offset + length_dir + width_dir)
	verts.append(Vector3(0,0,0) + offset + width_dir)
	verts.append(Vector3(0,0,0) + offset)
	return verts
	
func build_mesh(params, smooth = false, reverse = false):
	if params == 'default':
		params = [2, 2, 2]
	var foward_dir = Vector3(params[0],0,0)
	var rigth_dir = Vector3(0,0,params[1])
	var up_dir = Vector3(0,params[2],0)
	
	var offset = Vector3(-params[0]/2,-params[2]/2,-params[1]/2)
	
	begin(4)
	add_smooth_group(smooth)
	var uv_coords = [Vector2(1,1), Vector2(0,1), Vector2(0,0), Vector2(1,0)]
	
	add_quad(build_plane_verts(foward_dir, rigth_dir, offset), uv_coords, reverse)
	add_quad(build_plane_verts(rigth_dir, up_dir, offset), [uv_coords[2], uv_coords[3], uv_coords[0], uv_coords[1]], reverse)
	add_quad(build_plane_verts(up_dir, foward_dir, offset), [uv_coords[0], uv_coords[3], uv_coords[2], uv_coords[1]], reverse)
	add_quad(build_plane_verts(-rigth_dir, -foward_dir, -offset), [uv_coords[2], uv_coords[1], uv_coords[0], uv_coords[3]], reverse)
	add_quad(build_plane_verts(-up_dir, -rigth_dir, -offset), [uv_coords[3], uv_coords[0], uv_coords[1], uv_coords[2]], reverse)
	add_quad(build_plane_verts(-foward_dir, -up_dir, -offset), [uv_coords[0], uv_coords[1], uv_coords[2], uv_coords[3]], reverse)
	
	generate_normals()
	var mesh = commit()
	clear()
	
	return mesh
	
func add_tree_range(tree_item, text, value, _min = 1, _max = 100, step = 1):
    tree_item.set_text(0, text)
    tree_item.set_cell_mode(1, 2)
    tree_item.set_range(1, value)
    tree_item.set_range_config(1, _min, _max, step)
    tree_item.set_editable(1, true)

func mesh_parameters(settings, name = "Add Mesh"):
	var parameters = []
	parameters.append(settings.create_item())
	parameters[0].set_text(0, name)
	parameters.append(settings.create_item(parameters[0]))
	add_tree_range(parameters[1], 'Width', 2)
	parameters.append(settings.create_item(parameters[0]))
	add_tree_range(parameters[2], 'Length', 2)
	parameters.append(settings.create_item(parameters[0]))
	add_tree_range(parameters[3], 'Heigth', 2)