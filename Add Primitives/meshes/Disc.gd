extends "builder/MeshBuilder.gd"

var outer_radius = 1.0
var inner_radius = 0.5
var segments = 16

static func get_name():
	return "Disc"
	
func set_parameter(name, value):
	if name == 'Outer Radius':
		outer_radius = value
		
	elif name == 'Inner Radius':
		inner_radius = value
		
	elif name == 'Segments':
		segments = value
		
func create(smooth = false, invert = false):
	var circle = build_circle_verts(Vector3(), segments, 1)
	var c_uv = build_circle_verts(Vector3(), segments, 1)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(smooth)
	
	for i in range(segments):
		var uv = [Vector2(c_uv[i].x, c_uv[i].z) * inner_radius,
		          Vector2(c_uv[i].x, c_uv[i].z) * outer_radius,
		          Vector2(c_uv[i+1].x, c_uv[i+1].z) * outer_radius,
		          Vector2(c_uv[i+1].x, c_uv[i+1].z) * inner_radius]
		
		add_quad([circle[i] * inner_radius, circle[i] * outer_radius,
		          circle[i+1] * outer_radius, circle[i+1] * inner_radius], uv, invert)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Outer Radius', 1)
	add_tree_range(tree, 'Inner Radius', 0.5)
	add_tree_range(tree, 'Segments', 16, 1, 3, 64)
	

