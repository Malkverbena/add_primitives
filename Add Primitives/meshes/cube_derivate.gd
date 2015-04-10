extends "builder/mesh_builder.gd"
	
func build_mesh(params, smooth = false, reverse = false):
	if params == DEFAULT:
		params = ['C Shape',2, 2, 2]
		
	var shape = params[0]
	var w = params[1]    #Width
	var l = params[2]    #Length
	var h = params[3]    #Height
	
	var fd = Vector3(w,0,0)    #Foward Direction
	var rd = Vector3(0,0,l)    #Right Direction
	var ud = Vector3(0,h,0)    #Up Dir
	
	var offset = Vector3(-w/2,-h/2,-l/2)
	
	begin(4)
	add_smooth_group(smooth)
	var uv = [Vector2(1,1), Vector2(0,1), Vector2(0,0), Vector2(1,0)]
	
	if shape == 'C Shape':
		add_quad(build_plane_verts(rd, ud, offset), [uv[2], uv[3], uv[0], uv[1]], reverse)
		add_quad(build_plane_verts(-rd, -fd, -offset), [uv[2], uv[1], uv[0], uv[3]], reverse)
		add_quad(build_plane_verts(-ud, -rd, -offset), [uv[3], uv[0], uv[1], uv[2]], reverse)
		
	if shape == 'Corner':
		add_quad(build_plane_verts(-rd, -fd, -offset), [uv[2], uv[1], uv[0], uv[3]], reverse)
		add_quad(build_plane_verts(-ud, -rd, -offset), [uv[3], uv[0], uv[1], uv[2]], reverse)
		add_quad(build_plane_verts(-fd, -ud, -offset), [uv[0], uv[1], uv[2], uv[3]], reverse)
		
	elif shape == 'Remove Upper Face':
		add_quad(build_plane_verts(fd, rd, offset), uv, reverse)
		add_quad(build_plane_verts(rd, ud, offset), [uv[2], uv[3], uv[0], uv[1]], reverse)
		add_quad(build_plane_verts(ud, fd, offset), [uv[0], uv[3], uv[2], uv[1]], reverse)
		add_quad(build_plane_verts(-ud, -rd, -offset), [uv[3], uv[0], uv[1], uv[2]], reverse)
		add_quad(build_plane_verts(-fd, -ud, -offset), [uv[0], uv[1], uv[2], uv[3]], reverse)
		
	elif shape == 'Remove Caps':
		add_quad(build_plane_verts(rd, ud, offset), [uv[2], uv[3], uv[0], uv[1]], reverse)
		add_quad(build_plane_verts(ud, fd, offset), [uv[0], uv[3], uv[2], uv[1]], reverse)
		add_quad(build_plane_verts(-ud, -rd, -offset), [uv[3], uv[0], uv[1], uv[2]], reverse)
		add_quad(build_plane_verts(-fd, -ud, -offset), [uv[0], uv[1], uv[2], uv[3]], reverse)
		
	generate_normals()
	var mesh = commit()
	clear()
	
	return mesh
	
func mesh_parameters(settings):
	add_tree_combo(settings, 'Derivate', 'C Shape,Corner,Remove Upper Face,Remove Caps')
	add_tree_range(settings, 'Width', 2, 0.1, 0.1, 100)
	add_tree_range(settings, 'Length', 2, 0.1, 0.1, 100)
	add_tree_range(settings, 'Heigth', 2, 0.1, 0.1, 100)
	
func container():
	return "Extra Objects"