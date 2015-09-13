extends "../MeshBuilder.gd"

const Derivate = {
	C_SHAPE = 0,
	L_SHAPE = 1,
	CORNER = 2,
	REMOVE_UPPER_FACE = 3,
	REMOVE_CAPS = 4
}

var derivate = Derivate.C_SHAPE
var width = 2.0
var length = 2.0
var height = 2.0

static func get_name():
	return "Box Derivate"
	
static func get_container():
	return "Extra Objects"
	
func create(smooth, invert):
	var fd = Vector3(width,0,0)     #Foward Direction
	var rd = Vector3(0,0,length)    #Right Direction
	var ud = Vector3(0,height,0)    #Up Dir
	
	var ofs = Vector3(-width/2,-height/2,-length/2)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	add_smooth_group(smooth)
	
	if derivate == Derivate.C_SHAPE:
		build_plane(rd, ud, ofs)
		build_plane(-rd, -fd, -ofs)
		build_plane(-ud, -rd, -ofs)
		
	elif derivate == Derivate.L_SHAPE:
		build_plane(ud, rd, ofs)
		build_plane(rd, fd, ofs)
		
	elif derivate == Derivate.CORNER:
		build_plane(-rd, -fd, -ofs)
		build_plane(-ud, -rd, -ofs)
		build_plane(-fd, -ud, -ofs)
		
	elif derivate == Derivate.REMOVE_UPPER_FACE:
		build_plane(fd, rd, ofs)
		build_plane(rd, ud, ofs)
		build_plane(ud, fd, ofs)
		build_plane(-ud, -rd, -ofs)
		build_plane(-fd, -ud, -ofs)
		
	elif derivate == Derivate.REMOVE_CAPS:
		build_plane(rd, ud, ofs)
		build_plane(ud, fd, ofs)
		build_plane(-ud, -rd, -ofs)
		build_plane(-fd, -ud, -ofs)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(editor):
	editor.add_tree_combo('Derivate', derivate, 'C Shape,L Shape,Corner,Remove Upper Face,Remove Caps')
	editor.add_tree_range('Width', width)
	editor.add_tree_range('Length', length)
	editor.add_tree_range('Height', height)
	

