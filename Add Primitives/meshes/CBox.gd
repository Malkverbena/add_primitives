extends "builder/MeshBuilder.gd"

var center_length = 2
var center_width = 1
var side_length = 2
var side_width = 0.5
var height = 1

static func get_name():
	return "C Box"
	
static func get_container():
	return "Extra Objects"
	
func set_parameter(name, value):
	if name == 'Center Length':
		center_length = value
		
	elif name == 'Center Width':
		center_width = value
		
	elif name == 'Side Length':
		side_length = value
		
	elif name == 'Side Width':
		side_width = value
		
	elif name == 'Height':
		height = value
		
func create(smooth = false, invert = false):
	var h = Vector3(0, height, 0)
	
	var v = [Vector3(side_width,0,center_width), Vector3(0,0,0),
	         Vector3(0,0,side_length), Vector3(side_width,0, side_length),
	         Vector3(center_length-side_width,0,side_length), Vector3(center_length,0,side_length),
	         Vector3(center_length,0,0), Vector3(center_length-side_width,0,center_width)]
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(smooth)
	
	#Caps
	add_quad([v[3]+h, v[2]+h, v[1]+h, v[0]+h],[], invert)
	add_quad([v[7]+h, v[6]+h, v[5]+h, v[4]+h],[], invert)
	add_quad([v[6]+h, v[7]+h, v[0]+h, v[1]+h], [], invert)
	
	if h.y:
		add_quad([v[0], v[1], v[2], v[3]],[], invert)
		add_quad([v[4], v[5], v[6], v[7]],[], invert)
		add_quad([v[1], v[0], v[7], v[6]], [], invert)
		
		add_quad([v[1],v[1]+h,v[2]+h,v[2]],[],invert)
		add_quad([v[2],v[2]+h,v[3]+h,v[3]],[],invert)
		add_quad([v[3],v[3]+h,v[0]+h,v[0]],[],invert)
		add_quad([v[0],v[0]+h,v[7]+h,v[7]],[],invert)
		add_quad([v[7],v[7]+h,v[4]+h,v[4]],[],invert)
		add_quad([v[4],v[4]+h,v[5]+h,v[5]],[],invert)
		add_quad([v[5],v[5]+h,v[6]+h,v[6]],[],invert)
		add_quad([v[6],v[6]+h,v[1]+h,v[1]],[],invert)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Center Length', 2)
	add_tree_range(tree, 'Center Width', 1)
	add_tree_range(tree, 'Side Length', 2)
	add_tree_range(tree, 'Side Width', 0.5)
	add_tree_range(tree, 'Height', 1, 0.01, 0.0, 100)
	

