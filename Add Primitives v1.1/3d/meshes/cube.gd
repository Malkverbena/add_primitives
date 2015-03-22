extends "builder/mesh_builder.gd"
	
func build_mesh(params, smooth = false, reverse = false):
	if params == 'default':
		params = [2, 2, 2]
		
	var w = params[0]    #Width
	var l = params[1]    #Length
	var h = params[2]    #Height
		
	var fd = Vector3(w,0,0)    #Foward Direction
	var rd = Vector3(0,0,l)    #Right Direction
	var ud = Vector3(0,h,0)    #Up Dir
	
	var offset = Vector3(-w/2,-h/2,-l/2)
	
	begin(4)
	add_smooth_group(smooth)
	var uv = [Vector2(1,1), Vector2(0,1), Vector2(0,0), Vector2(1,0)]
	
	add_quad(build_plane_verts(fd, rd, offset), uv, reverse)
	add_quad(build_plane_verts(rd, ud, offset), [uv[2], uv[3], uv[0], uv[1]], reverse)
	add_quad(build_plane_verts(ud, fd, offset), [uv[0], uv[3], uv[2], uv[1]], reverse)
	add_quad(build_plane_verts(-rd, -fd, -offset), [uv[2], uv[1], uv[0], uv[3]], reverse)
	add_quad(build_plane_verts(-ud, -rd, -offset), [uv[3], uv[0], uv[1], uv[2]], reverse)
	add_quad(build_plane_verts(-fd, -ud, -offset), [uv[0], uv[1], uv[2], uv[3]], reverse)
	
	generate_normals()
	var mesh = commit()
	clear()
	
	return mesh
	
func mesh_parameters(settings):
	add_tree_range(settings, 'Width', 2, 0.1, 100, 0.1)
	add_tree_range(settings, 'Length', 2, 0.1, 100, 0.1)
	add_tree_range(settings, 'Heigth', 2, 0.1, 100, 0.1)
