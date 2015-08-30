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
		
func create(smooth, invert):
	var ic = build_circle_verts(Vector3(), segments, inner_radius)
	var oc = build_circle_verts(Vector3(), segments, outer_radius)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	add_smooth_group(false)
	
	var ofs = Vector3(0, height/2, 0)
	
	for idx in range(segments):
		add_quad([oc[idx + 1] + ofs, ic[idx + 1] + ofs, ic[idx] + ofs, oc[idx] + ofs])
		add_quad([oc[idx] - ofs, ic[idx] - ofs, ic[idx + 1] - ofs, oc[idx + 1] - ofs])
		
	add_smooth_group(smooth)
	
	for idx in range(segments):
		add_quad([oc[idx + 1] + ofs, oc[idx] + ofs, oc[idx] - ofs, oc[idx + 1] -ofs])
		add_quad([ic[idx] + ofs, ic[idx + 1] + ofs, ic[idx + 1] - ofs, ic[idx] -ofs])
		
	var mesh = commit()
	
	return mesh

func mesh_parameters(tree):
	add_tree_range(tree, 'Height', height)
	add_tree_range(tree, 'Outer Radius', outer_radius)
	add_tree_range(tree, 'Inner Radius', inner_radius)
	add_tree_range(tree, 'Segments', segments, 1, 1, 50)
	

