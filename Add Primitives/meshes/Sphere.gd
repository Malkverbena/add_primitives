extends 'builder/MeshBuilder.gd'

var radius = 1.0
var segments = 16
var height_segments = 8
var height_slice = 1.0
var fill_cap = true

static func get_name():
	return "Sphere"
	
func set_parameter(name, value):
	if name == 'Radius':
		radius = value
		
	elif name == 'Segments':
		segments = value
		
	elif name == 'Height Segments':
		height_segments = value
		
	elif name == 'Height Slice':
		height_slice = value
		
	elif name == 'Fill Cap':
		fill_cap = value
		
func create(smooth, invert):
	var circle = build_circle_verts(Vector3(), segments, radius)
	
	var h = height_segments - 1
	
	var angle = PI * height_slice / h
	
	var pos = Vector3(0, -cos(angle * h) * radius, 0)
	var rd = Vector3(sin(angle * h), 0, sin(angle * h))
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	
	if height_slice == 1.0:
		pos.y = cos(angle)
		rd = Vector3(sin(angle), 0, sin(angle))
		
		add_smooth_group(smooth)
		
		for idx in range(segments):
			add_tri([Vector3(0, radius, 0), circle[idx] * rd + pos, circle[idx + 1] * rd + pos])
			
	else:
		if fill_cap:
			add_smooth_group(false)
			
			for idx in range(segments):
				add_tri([pos, circle[idx] * rd + pos, circle[idx + 1] * rd + pos])
				
		add_smooth_group(smooth)
		
	h -= 1
	
	for i in range(height_segments - 1, 1, -1):
		var next_pos = Vector3(0, -cos(angle * (i-1)) * radius, 0)
		var next_radius = Vector3(sin(angle * (i-1)), 0, sin(angle * (i-1)))
		
		for idx in range(segments):
			add_quad([circle[idx] * rd + pos,
			          circle[idx] * next_radius + next_pos,
			          circle[idx+1] * next_radius + next_pos,
			          circle[idx+1] * rd + pos])
			
		pos = next_pos
		rd = next_radius
		
	pos = Vector3(0, -cos(angle) * radius, 0)
	
	for idx in range(segments):
		add_tri([circle[idx + 1] * rd + pos, circle[idx] * rd + pos, Vector3(0, -radius, 0)])
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Radius', radius)
	add_tree_range(tree, 'Segments', segments, 1, 3, 64)
	add_tree_range(tree, 'Height Segments', height_segments, 1, 3, 64)
	add_tree_range(tree, 'Height Slice', height_slice, 0.01, 0.01, 1)
	add_tree_empty(tree)
	add_tree_check(tree, 'Fill Cap', fill_cap)

