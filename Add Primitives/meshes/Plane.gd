extends "builder/MeshBuilder.gd"

var length = 2.0
var width = 2.0
var start_heigth = 0.0
var end_heigth = 0.0

static func get_name():
	return "Plane"
	
func set_parameter(name, value):
	if name == 'Length':
		length = value
		
	elif name == 'Width':
		width = value
		
	elif name == 'Start H.':
		start_heigth = value
		
	elif name == 'End H.':
		end_heigth = value
		
func create(smooth = false, invert = false):
	var verts = [Vector3(-width/2, end_heigth, -length/2),
	             Vector3(width/2, end_heigth, -length/2),
	             Vector3(width/2, start_heigth, length/2),
	             Vector3(-width/2, start_heigth, length/2)]
	             
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(smooth)
	
	add_quad(verts, plane_uv(verts[0].distance_to(verts[1]), verts[0].distance_to(verts[3])), invert)
	
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, "Length", length)
	add_tree_range(tree, "Width", width)
	add_tree_range(tree, "Start H.", start_heigth, 0.01, -100, 100)
	add_tree_range(tree, "End H.", end_heigth, 0.01, -100, 100)
	

