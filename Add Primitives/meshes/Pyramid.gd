extends "builder/MeshBuilder.gd"

var width = 2.0
var length = 2.0
var height = 1.0

static func get_name():
	return "Pyramid"
	
static func get_container():
	return "Extra Objects"
	
func set_parameter(name, value):
	if name == 'width':
		width = value
		
	elif name == 'length':
		length = value
		
	elif name == 'height':
		height = value
		
func create(smooth, invert):
	var ofs = Vector3(width/2, height/2, length/2)
	
	var plane = build_plane_verts(Vector3(width,0,0), Vector3(0,0,length), -ofs)
	
	var ch = Vector3(0, height, 0)
	
	var hl = sqrt(pow(length/2, 2) + pow(height, 2))
	var hw = sqrt(pow(width/2, 2) + pow(height, 2))
	
	var uv = [Vector2(width/2, 0), Vector2(width, hl), Vector2(0, hl)]
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	add_smooth_group(smooth)
	
	build_plane(Vector3(width,0,0), Vector3(0,0,length), -ofs)
	
	add_tri([ch, plane[1], plane[0]], uv)
	add_tri([ch, plane[3], plane[2]], uv)
	
	uv[0].x = length/2
	uv[1] = Vector2(length, hw)
	uv[2].y = hw
	
	add_tri([ch, plane[2], plane[1]], uv)
	add_tri([ch, plane[0], plane[3]], uv)
	
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Width', width)
	add_tree_range(tree, 'Length', length)
	add_tree_range(tree, 'Height', height)
	

