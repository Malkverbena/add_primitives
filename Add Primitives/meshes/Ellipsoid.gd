extends 'builder/MeshBuilder.gd'

var width = 1.0
var length = 1.0
var height = 1.0
var segments = 16
var height_segments = 8
var height_slice = 1.0

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
		
	elif name == 'Height Slice':
		height_slice = value
		
func create(smooth, invert):
	var cc = Vector3(0,-height,0)
	
	var ellipse = build_ellipse_verts(Vector3(), segments, Vector2(width, length))
	
	var h = height_segments - 1
	
	var angle = PI * height_slice / h
	
	var pos = Vector3(0, cos(angle), 0)
	var rd = Vector3(sin(angle), 0, sin(angle))
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	
	if height_slice < 1.0:
		pos.y = -cos(angle * h)
		rd = Vector3(sin(angle * h), 0, sin(angle * h))
		
		if true:
			add_smooth_group(false)
			
			for idx in range(segments):
				add_tri([pos, ellipse[idx + 1] * rd + pos, ellipse[idx] * rd + pos])
				
			add_smooth_group(smooth)
			
	else:
		#if fill_cap:
		#	add_smooth_group(false)
		#	
		add_smooth_group(smooth)
		
		for idx in range(segments):
			add_tri([Vector3(0, height, 0), ellipse[idx + 1] * rd + pos, ellipse[idx] * rd + pos])
			
			
	h -= 1
	
	#add_smooth_group(smooth)
	
	#for idx in range(segments):
	#	#pos = Vector3(0, -cos(angle) * height, 0)
	#	add_tri([ellipse[idx] * rd + pos, ellipse[idx + 1] * rd + pos, cc])
	#	
	#	#pos = Vector3(0, -cos(angle * (height_segments - 1)) * height, 0)
	#	#add_tri([-cc, ellipse[idx + 1] * rd + pos, ellipse[idx] * rd + pos])
	#	
	#pos = Vector3(0, -cos(angle) * height, 0)
	
	for i in range(height_segments - 1, 1, -1):
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
	add_tree_range(tree, 'Height Slice', height_slice, 0.01, 0, 1)
	

