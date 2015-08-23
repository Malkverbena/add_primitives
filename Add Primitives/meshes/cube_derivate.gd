extends "builder/mesh_builder.gd"

const Derivate = {
	C_SHAPE = 0,
	L_SHAPE = 1,
	CORNER = 2,
	REMOVE_UPPER_FACE = 3,
	REMOVE_CAPS = 4
}

func build_mesh(params, smooth = false, reverse = false):
	var drv = params[0]  #Derivate
	var w = params[1]    #Width
	var l = params[2]    #Length
	var h = params[3]    #Height
	
	var fd = Vector3(w,0,0)    #Foward Direction
	var rd = Vector3(0,0,l)    #Right Direction
	var ud = Vector3(0,h,0)    #Up Dir
	
	var offset = Vector3(-w/2,-h/2,-l/2)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	add_smooth_group(smooth)
	
	if drv == Derivate.C_SHAPE:
		add_quad(build_plane_verts(rd, ud, offset), plane_uv(l, h), reverse)
		add_quad(build_plane_verts(-rd, -fd, -offset), plane_uv(l, w), reverse)
		add_quad(build_plane_verts(-ud, -rd, -offset), plane_uv(h, l), reverse)
		
	elif drv == Derivate.L_SHAPE:
		add_quad(build_plane_verts(ud, rd, offset), plane_uv(h, l), reverse)
		add_quad(build_plane_verts(rd, fd, offset), plane_uv(l, w), reverse)
		
	elif drv == Derivate.CORNER:
		add_quad(build_plane_verts(-rd, -fd, -offset), plane_uv(l, w), reverse)
		add_quad(build_plane_verts(-ud, -rd, -offset), plane_uv(h, l), reverse)
		add_quad(build_plane_verts(-fd, -ud, -offset), plane_uv(w, h), reverse)
		
	elif drv == Derivate.REMOVE_UPPER_FACE:
		add_quad(build_plane_verts(fd, rd, offset), plane_uv(w, l), reverse)
		add_quad(build_plane_verts(rd, ud, offset), plane_uv(l, h), reverse)
		add_quad(build_plane_verts(ud, fd, offset), plane_uv(h, w), reverse)
		add_quad(build_plane_verts(-ud, -rd, -offset), plane_uv(h, l), reverse)
		add_quad(build_plane_verts(-fd, -ud, -offset), plane_uv(w, h), reverse)
		
	elif drv == Derivate.REMOVE_CAPS:
		add_quad(build_plane_verts(rd, ud, offset), plane_uv(l, h), reverse)
		add_quad(build_plane_verts(ud, fd, offset), plane_uv(h, w), reverse)
		add_quad(build_plane_verts(-ud, -rd, -offset), plane_uv(h, l), reverse)
		add_quad(build_plane_verts(-fd, -ud, -offset), plane_uv(w, h), reverse)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_combo(tree, 'Derivate', 'C Shape,L Shape,Corner,Remove Upper Face,Remove Caps')
	add_tree_range(tree, 'Width', 2, 0.1, 0.1, 100)
	add_tree_range(tree, 'Length', 2, 0.1, 0.1, 100)
	add_tree_range(tree, 'Heigth', 2, 0.1, 0.1, 100)
	
func container():
	return "Extra Objects"
	

