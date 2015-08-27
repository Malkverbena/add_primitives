extends "builder/MeshBuilder.gd"

var height = 2.0
var outer_radius = 1.0
var inner_radius = 0.5
var segments = 16

static func get_name():
	return "Tube"
	
func set_parameter(name, value):
	if name == 'Height':
		height = value
		
	elif name == 'Outer Radius':
		outer_radius = value
		
	elif name == 'Inner Radius':
		inner_radius = value
		
	elif name == 'Segments':
		segments = value
		
func create(smooth = false, invert = false):
	var ic = build_circle_verts(Vector3(0,0,0), segments, inner_radius)
	var oc = build_circle_verts(Vector3(0,0,0), segments, outer_radius)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(false)
	
	var off = Vector3(0, height/2, 0)
	
	for idx in range(segments):
		add_quad([oc[idx + 1] + off, ic[idx + 1] + off, ic[idx] + off, oc[idx] + off], [], invert)
		add_quad([oc[idx] - off, ic[idx] - off, ic[idx + 1] - off, oc[idx + 1] - off], [], invert)
	
	add_smooth_group(smooth)
	
	for idx in range(segments ):
		add_quad([oc[idx + 1] + off, oc[idx] + off, oc[idx] - off, oc[idx + 1] -off], [], invert)
		add_quad([ic[idx] + off, ic[idx + 1] + off, ic[idx + 1] - off, ic[idx] -off], [], invert)
		
	var mesh = commit()
	
	return mesh

func mesh_parameters(tree):
	add_tree_range(tree, 'Height', 2)
	add_tree_range(tree, 'Outer Radius', 1)
	add_tree_range(tree, 'Inner Radius', 0.5)
	add_tree_range(tree, 'Segments', 16, 1, 1, 50)
	

