extends "../Primitive.gd"

var width = 2.0
var length = 2.0
var height = 2.0

static func get_name():
	return "Box"
	
func create():
	var fd = Vector3(width, 0, 0)
	var rd = Vector3(0, 0, length)
	var ud = Vector3(0, height, 0)
	
	var ofs = Vector3(-width/2,-height/2,-length/2)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(smooth)
	
	add_plane(fd, rd, ofs)
	add_plane(rd, ud, ofs)
	add_plane(ud, fd, ofs)
	add_plane(-rd, -fd, -ofs)
	add_plane(-ud, -rd, -ofs)
	add_plane(-fd, -ud, -ofs)
	
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(editor):
	editor.add_tree_range('Width', width)
	editor.add_tree_range('Length', length)
	editor.add_tree_range('Height', height)
	

