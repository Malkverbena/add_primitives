extends 'builder/MeshBuilder.gd'

var width = 1.0
var length = 1.0
var height = 1.0
var segments = 16
var height_segments = 8
var hemisphere = 0.0
var generate_cap = true

static func get_name():
	return "Ellipsoid"
	
static func get_container():
	return "Extra Objects"
	
func set_parameter(name, value):
	if name == 'width':
		width = value
		
	elif name == 'length':
		length = value
		
	elif name == 'height':
		height = value
		
	elif name == 'segments':
		segments = value
		
	elif name == 'height_segments':
		height_segments = value
		
	elif name == 'hemisphere':
		hemisphere = value
		
	elif name == 'generate_cap':
		generate_cap = value
		
func create(smooth, invert):
	var cc = Vector3(0,-height,0)
	
	var ellipse = build_ellipse_verts(Vector3(), segments, Vector2(width, length))
	
	var h = height_segments - 1
	
	var h_val = 1.0 - hemisphere
	
	var angle = PI * h_val / h
	
	var pos = Vector3(0, cos(angle) * height, 0)
	var rd = Vector3(sin(angle), 0, sin(angle))
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	
	if hemisphere > 0.0:
		pos.y = -cos(angle * h) * height
		rd = Vector3(sin(angle * h), 0, sin(angle * h))
		
		if generate_cap:
			add_smooth_group(false)
			
			for idx in range(segments):
				add_tri([pos, ellipse[idx + 1] * rd + pos, ellipse[idx] * rd + pos])
				
			add_smooth_group(smooth)
			
	else:
		add_smooth_group(smooth)
		
		for idx in range(segments):
			add_tri([Vector3(0, height, 0), ellipse[idx + 1] * rd + pos, ellipse[idx] * rd + pos])
			
		h -= 1
		
	for i in range(h, 1, -1):
		var next_pos = Vector3(0, -cos(angle * (i-1)) * height, 0)
		var next_radius = Vector3(sin(angle * (i-1)), 0, sin(angle * (i-1)))
		
		for idx in range(segments):
			add_quad([ellipse[idx + 1] * rd + pos,
			          ellipse[idx + 1] * next_radius + next_pos,
			          ellipse[idx] * next_radius + next_pos,
			          ellipse[idx] * rd + pos])
			
		pos = next_pos
		rd = next_radius
		
	pos = Vector3(0, -cos(angle) * height, 0)
	
	for idx in range(segments):
		add_tri([ellipse[idx] * rd + pos, ellipse[idx + 1] * rd + pos, Vector3(0, -height, 0)])
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Width', width)
	add_tree_range(tree, 'Length', length)
	add_tree_range(tree, 'Height', height)
	add_tree_range(tree, 'Segments', segments, 1, 3, 64)
	add_tree_range(tree, 'Height Segments', height_segments, 1, 3, 64)
	add_tree_range(tree, 'Hemisphere', hemisphere, 0.01, 0, 1)
	add_tree_empty(tree)
	add_tree_check(tree, 'Generate Cap', generate_cap)
	

