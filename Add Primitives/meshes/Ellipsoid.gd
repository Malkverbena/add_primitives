extends 'builder/MeshBuilder.gd'

var width = 1.0
var length = 1.0
var height = 1.0
var segments = 16
var height_segments = 8

static func get_name():
	return "Ellipsoid"
	
static func get_container():
	return "Extra Objects"
	
func set_parameter(name, value):
	if name == 'Width':
		width = value
		
	elif name == 'Length':
		length = value
		
	elif name == 'Height':
		height = value
		
	elif name == 'Segments':
		segments = value
		
	elif name == 'Height Segments':
		height_segments = value
		
func create(smooth, invert):
	var angle = PI/height_segments
	var cc = Vector3(0,-height,0)
	
	var ellipse = build_ellipse_verts(Vector3(), segments, Vector2(width, length))
	
	var rd = Vector3(sin(angle), 0, sin(angle))
	var pos
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	add_smooth_group(smooth)
	
	for idx in range(segments):
		pos = Vector3(0, -cos(angle) * height, 0)
		add_tri([ellipse[idx] * rd + pos, ellipse[idx + 1] * rd + pos, cc])
		
		pos = Vector3(0, -cos(angle * (height_segments - 1)) * height, 0)
		add_tri([-cc, ellipse[idx + 1] * rd + pos, ellipse[idx] * rd + pos])
		
	pos = Vector3(0, -cos(angle) * height, 0)
	
	for i in range(1, height_segments - 1):
		var next_pos = Vector3(0, -cos(angle * (i+1)) * height, 0)
		var next_radius = Vector3(sin(angle * (i+1)), 0, sin(angle * (i+1)))
		
		for idx in range(segments):
			add_quad([ellipse[idx] * rd + pos,
			          ellipse[idx] * next_radius + next_pos,
			          ellipse[idx + 1] * next_radius + next_pos,
			          ellipse[idx + 1] * rd + pos])
			
		pos = next_pos
		rd = next_radius
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Width', width)
	add_tree_range(tree, 'Length', length)
	add_tree_range(tree, 'Height', height)
	add_tree_range(tree, 'Segments', segments, 1, 3, 64)
	add_tree_range(tree, 'Height Segments', height_segments, 1, 3, 64)
	

