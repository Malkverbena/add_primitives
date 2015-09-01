extends "builder/MeshBuilder.gd"

var outer_radius = 1.0
var inner_radius = 0.5
var segments = 16
var slice = 0

static func get_name():
	return "Disc"
	
static func get_container():
	return "Extra Objects"
	
func set_parameter(name, value):
	if name == 'Outer Radius':
		outer_radius = value
		
	elif name == 'Inner Radius':
		inner_radius = value
		
	elif name == 'Segments':
		segments = value
		
	elif name == 'Slice':
		slice = deg2rad(value)
		
func create(smooth, invert):
	var sa = PI * 2 - slice
	
	var circle = build_circle_verts(Vector3(), segments, 1, sa)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	add_smooth_group(smooth)
	
	for i in range(segments):
		var uv = [Vector2(circle[i].x, circle[i].z) * inner_radius,
		          Vector2(circle[i].x, circle[i].z) * outer_radius,
		          Vector2(circle[i+1].x, circle[i+1].z) * outer_radius,
		          Vector2(circle[i+1].x, circle[i+1].z) * inner_radius]
		
		add_quad([circle[i] * inner_radius, circle[i] * outer_radius,
		          circle[i+1] * outer_radius, circle[i+1] * inner_radius], uv)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Outer Radius', outer_radius)
	add_tree_range(tree, 'Inner Radius', inner_radius)
	add_tree_range(tree, 'Segments', segments, 1, 3, 64)
	add_tree_range(tree, 'Slice', deg2rad(slice), 1, 0, 359)
	

