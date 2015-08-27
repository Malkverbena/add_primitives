extends "builder/MeshBuilder.gd"

var front_length = 2.0
var front_width = 1.0
var side_length = 2.0
var side_width = 1.0
var height = 1.0

static func get_name():
	return "L Box"
	
static func get_container():
	return "Extra Objects"
	
func set_parameter(name, value):
	if name == 'Front Length':
		front_length = value
		
	elif name == 'Front Width':
		front_width = value
		
	elif name == 'Side Length':
		side_length = value
		
	elif name == 'Side Width':
		side_width = value
		
	elif name == 'Height':
		height = value
		
func create(smooth = false, invert = false):
	var h = Vector3(0, height, 0)
	
	var v = [Vector3(0, 0, 0),
	         Vector3(front_width, 0, side_width),
	         Vector3(front_width, 0, front_length),
	         Vector3(0, 0, front_length),
	         Vector3(side_length, 0, 0),
	         Vector3(side_length, 0, side_width),
	         Vector3(front_width, 0, side_width)]
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(smooth)
	
	add_quad([v[0]+h, v[1]+h, v[2]+h, v[3]+h], [], invert)
	add_quad([v[0]+h, v[4]+h, v[5]+h, v[6]+h], [], invert)
	
	if h.y:
		add_quad([v[3], v[2], v[1], v[0]], [], invert)
		add_quad([v[1], v[5], v[4], v[0]], [], invert)
		
		add_quad([v[0]+h, v[3]+h, v[3], v[0]], [], invert)
		add_quad([v[0], v[4], v[4]+h, v[0]+h], [], invert)
		add_quad([v[5], v[5]+h, v[4]+h, v[4]], [], invert)
		add_quad([v[1], v[1]+h, v[5]+h, v[5]], [], invert)
		add_quad([v[2], v[2]+h, v[1]+h, v[1]], [], invert)
		add_quad([v[3], v[3]+h, v[2]+h, v[2]], [], invert)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Front Length', 2)
	add_tree_range(tree, 'Front Width', 1)
	add_tree_range(tree, 'Side Length', 2)
	add_tree_range(tree, 'Side Width', 1)
	add_tree_range(tree, 'Height', 1, 0.01, 0, 100)
	

