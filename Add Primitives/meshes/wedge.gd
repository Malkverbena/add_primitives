extends "builder/mesh_builder.gd"

func build_mesh(params, smooth = false, reverse = false):
	if params == DEFAULT:
		params = [1.0, 1.0, 2.0]
		
	var width = params[0]
	var height = params[1]
	var length = params[2]
	
	var forward_dir = Vector3(0, 0, length)
	var right_dir = Vector3(width, 0, 0)
	var up_dir = Vector3(0, height, 0)
	
	var offset = Vector3(width/2, height/2, length/2) * -1
	
	begin(VS.PRIMITIVE_TRIANGLES)
	add_smooth_group(smooth)
	
	add_quad(build_plane_verts(right_dir, forward_dir, offset), [], reverse)
	add_quad(build_plane_verts(up_dir, right_dir, offset), [], reverse)
	
	offset.y += height
	add_quad([offset, offset + right_dir, offset + Vector3(width, -height, length), offset + Vector3(0, -height, length)], [], reverse)
	add_tri([offset, offset + Vector3(0, -height, length), offset - up_dir], [], reverse)
	add_tri([offset + right_dir, (offset + right_dir) - up_dir, offset + Vector3(width, -height, length)], [], reverse)
	
	generate_normals()
	var mesh = commit()
	clear()
	
	return mesh
	
func mesh_parameters(parameters):
	add_tree_range(parameters, 'Width', 1, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Height', 1, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Length', 2, 0.1, 0.1, 100)
	
func container():
	return "Extra Objects"
