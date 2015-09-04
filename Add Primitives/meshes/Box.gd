extends "builder/MeshBuilder.gd"

var width = 2.0
var length = 2.0
var height = 2.0

static func get_name():
	return "Box"
	
func set_parameter(name, value):
	if name == 'width':
		width = value
		
	elif name == 'length':
		length = value
		
	elif name == 'height':
		height = value
		
func create(smooth, invert):
	var fd = Vector3(width,0,0)
	var rd = Vector3(0,0,length)
	var ud = Vector3(0,height,0)
	
	var ofs = Vector3(-width/2,-height/2,-length/2)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	add_smooth_group(smooth)
	
	build_plane(fd, rd, ofs)
	build_plane(rd, ud, ofs)
	build_plane(ud, fd, ofs)
	build_plane(-rd, -fd, -ofs)
	build_plane(-ud, -rd, -ofs)
	build_plane(-fd, -ud, -ofs)
	
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Width', width)
	add_tree_range(tree, 'Length', length)
	add_tree_range(tree, 'Height', height)
	

