extends "../Primitive.gd"

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
	
func create():
	var fd = Vector3(width,0,0)     #Foward Direction
	var rd = Vector3(0,0,length)    #Right Direction
	var ud = Vector3(0,height,0)    #Up Dir
	
	var ofs = Vector3(-width/2,-height/2,-length/2)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(smooth)
	
	if derivate == Derivate.C_SHAPE:
		add_plane(rd, ud, ofs)
		add_plane(-rd, -fd, -ofs)
		add_plane(-ud, -rd, -ofs)
		
	elif derivate == Derivate.L_SHAPE:
		add_plane(ud, rd, ofs)
		add_plane(rd, fd, ofs)
		
	elif derivate == Derivate.CORNER:
		add_plane(-rd, -fd, -ofs)
		add_plane(-ud, -rd, -ofs)
		add_plane(-fd, -ud, -ofs)
		
	elif derivate == Derivate.REMOVE_UPPER_FACE:
		add_plane(fd, rd, ofs)
		add_plane(rd, ud, ofs)
		add_plane(ud, fd, ofs)
		add_plane(-ud, -rd, -ofs)
		add_plane(-fd, -ud, -ofs)
		
	elif derivate == Derivate.REMOVE_CAPS:
		add_plane(rd, ud, ofs)
		add_plane(ud, fd, ofs)
		add_plane(-ud, -rd, -ofs)
		add_plane(-fd, -ud, -ofs)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(editor):
	editor.add_tree_combo('Derivate', derivate, 'C Shape,L Shape,Corner,Remove Upper Face,Remove Caps')
	editor.add_tree_range('Width', width)
	editor.add_tree_range('Length', length)
	editor.add_tree_range('Height', height)
	

