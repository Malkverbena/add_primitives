extends "builder/MeshBuilder.gd"

static func get_name():
	return "Pyramid"
	
static func get_container():
	return "Extra Objects"
	
func build_mesh(params, smooth = false, reverse = false):
	var width = params[0]
	var length = params[1]
	var height = params[2]
	
	var offset = Vector3(width/2, height/2, length/2)
	
	var plane = build_plane_verts(Vector3(width,0,0), Vector3(0,0,length), -offset)
	
	var uv = [Vector2(1, 1), Vector2(0, 1), Vector2(0, 0), Vector2(1, 0)]
	
	begin(VS.PRIMITIVE_TRIANGLES)
	add_smooth_group(smooth)
	
	add_quad(plane, uv, reverse)
	
	plane.push_back(plane[0])
	
	for idx in range(4):
		uv = [uv[0], uv[1], Vector2(0.5, 0.5)]
		add_tri([plane[idx+1], plane[idx], Vector3(0, height, 0)], uv, reverse)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Width', 2, 0.1, 0.1, 100)
	add_tree_range(tree, 'Length', 2, 0.1, 0.1, 100)
	add_tree_range(tree, 'Height', 1, 0.1, 0.1, 100)
	

