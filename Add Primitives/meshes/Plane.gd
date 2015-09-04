extends "builder/MeshBuilder.gd"

var length = 2.0
var width = 2.0
var start_height = 0.0
var end_height = 0.0

static func get_name():
	return "Plane"
	
func set_parameter(name, value):
	if name == 'length':
		length = value
		
	elif name == 'width':
		width = value
		
	elif name == 'start_height':
		start_height = value
		
	elif name == 'end_height':
		end_height = value
		
func create(smooth, invert):
	var verts = [Vector3(-width/2, end_height, -length/2),
	             Vector3(width/2, end_height, -length/2),
	             Vector3(width/2, start_height, length/2),
	             Vector3(-width/2, start_height, length/2)]
	             
	var w = verts[0].distance_to(verts[1])
	var l = verts[0].distance_to(verts[3])
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	add_smooth_group(smooth)
	
	add_quad(verts, plane_uv(w, l))
	
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, "Length", length)
	add_tree_range(tree, "Width", width)
	add_tree_range(tree, "Start Height", start_height, 0.01, -100, 100)
	add_tree_range(tree, "End Height", end_height, 0.01, -100, 100)
	

