extends "builder/MeshBuilder.gd"

var width = 2.0
var length = 2.0
var height = 2.0

static func get_name():
	return "Box"
	
func set_parameter(name, value):
	if name == 'Width':
		width = value
		
	elif name == 'Length':
		length = value
		
	elif name == 'Height':
		height = value
		
func create(smooth = false, invert = false):
	var fd = Vector3(width,0,0)    #Foward Direction
	var rd = Vector3(0,0,length)    #Right Direction
	var ud = Vector3(0,height,0)    #Up Dir
	
	var offset = Vector3(-width/2,-height/2,-length/2)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	add_smooth_group(smooth)
	
	add_quad(build_plane_verts(fd, rd, offset), plane_uv(width, length), invert)
	add_quad(build_plane_verts(rd, ud, offset), plane_uv(length, height), invert)
	add_quad(build_plane_verts(ud, fd, offset), plane_uv(height, width), invert)
	add_quad(build_plane_verts(-rd, -fd, -offset), plane_uv(length, width), invert)
	add_quad(build_plane_verts(-ud, -rd, -offset), plane_uv(height, length), invert)
	add_quad(build_plane_verts(-fd, -ud, -offset), plane_uv(width, height), invert)
	
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Width', 2)
	add_tree_range(tree, 'Length', 2)
	add_tree_range(tree, 'Height', 2)
	

