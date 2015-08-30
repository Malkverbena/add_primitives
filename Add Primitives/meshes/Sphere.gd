extends 'builder/MeshBuilder.gd'

var radius = 1.0
var segments = 16
var height_segments = 8

static func get_name():
	return "Sphere"
	
func set_parameter(name, value):
	if name == 'Radius':
		radius = value
		
	elif name == 'Segments':
		segments = value
		
	elif name == 'Height Segments':
		height_segments = value
		
func create(smooth, invert):
	var angle = PI/height_segments
	var cc = Vector3(0,-radius,0)
	
	var circle = build_circle_verts(Vector3(), segments, radius)
	
	var rd = Vector3(sin(angle), 0, sin(angle))
	var pos
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	add_smooth_group(smooth)
	
	for idx in range(segments):
		pos = Vector3(0, -cos(angle) * radius, 0)
		add_tri([circle[idx + 1] * rd + pos, circle[idx] * rd + pos, cc])
		
		pos = Vector3(0, -cos(angle * (height_segments - 1)) * radius, 0)
		add_tri([-cc, circle[idx] * rd + pos, circle[idx + 1] * rd + pos])
		
	pos = Vector3(0, -cos(angle) * radius, 0)
	
	for i in range(1, height_segments - 1):
		var next_pos = Vector3(0, -cos(angle * (i+1)) * radius, 0)
		var next_radius = Vector3(sin(angle * (i+1)), 0, sin(angle * (i+1)))
		
		for idx in range(segments):
			add_quad([circle[idx + 1] * rd + pos,
			          circle[idx + 1] * next_radius + next_pos,
			          circle[idx] * next_radius + next_pos,
			          circle[idx] * rd + pos])
			
		pos = next_pos
		rd = next_radius
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Radius', radius)
	add_tree_range(tree, 'Segments', segments, 1, 3, 64)
	add_tree_range(tree, 'Height Segments', height_segments, 1, 3, 64)
	

