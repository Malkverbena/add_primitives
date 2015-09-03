extends "builder/MeshBuilder.gd"

var radius = 1
var height = 1
var segments = 16
var height_segments = 8
var slice = 0
var fill_ends = true

static func get_name():
	return "Capsule"
	
func set_parameter(name, value):
	if name == 'Radius':
		radius = value
		
	elif name == 'Height':
		height = value
		
	elif name == 'Segments':
		segments = value
		
	elif name == 'Height Segments':
		height_segments = value
		
	elif name == 'Slice':
		slice = deg2rad(value)
		
	elif name == 'Fill Ends':
		fill_ends = value
		
func create(smooth, invert):
	var angle = PI/height_segments
	
	var cc = Vector3(0,radius + height,0)
	
	var sa = PI * 2 - slice
	
	var circle = build_circle_verts(Vector3(), segments, radius, sa)
	
	var r = Vector3(sin(angle), 0, sin(angle))
	var p
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	add_smooth_group(smooth)
	
	for idx in range(segments):
		p = Vector3(0,-cos(angle) * radius - height, 0)
		add_tri([(circle[idx + 1] * r) + p, (circle[idx] * r) + p, -cc])
		
		p = Vector3(0,-cos(angle * (height_segments - 1)) * radius + height,0)
		add_tri([cc, (circle[idx] * r) + p, (circle[idx + 1] * r + p)])
		
	p = Vector3(0,-cos(angle) * radius - height,0)
	
	for i in range((height_segments - 2)/2):
		var np = Vector3(0, -cos(angle * (i + 2)) * radius - height, 0)
		var nr = Vector3(sin(angle * (i + 2)), 0, sin(angle * (i + 2)))
		
		for idx in range(segments):
			add_quad([circle[idx+1] * r + p, circle[idx+1] * nr + np, circle[idx] * nr + np, circle[idx] * r + p])
			add_quad([circle[idx] * r - p, circle[idx] * nr - np, circle[idx+1] * nr - np, circle[idx+1] * r - p])
			
		p = np
		r = nr
		
	var h = Vector3(0, height, 0)
	
	for idx in range(segments):
		add_quad([circle[idx+1] + h, circle[idx] + h, circle[idx] - h, circle[idx+1] - h])
		
	if fill_ends and slice:
		add_smooth_group(false)
		
		add_quad([Vector3(radius, h.y, 0), Vector3(0, h.y, 0), Vector3(0, -h.y, 0), Vector3(radius, -h.y, 0)])
		add_quad([Vector3(0, h.y, 0), circle[segments] + h, circle[segments] - h, Vector3(0, -h.y, 0)])
		
		var axis = Vector3(0,1,0)
		
		var pos1 = Vector3(0, -(height + radius), 0)
		
		for i in range(height_segments/2):
			var y = -cos(angle * (i+1)) * radius - height
			var x = sin(angle * (i+1)) * radius
			
			var pos2 = Vector3(x, y, 0)
			
			add_tri([-h, pos1, pos2])
			add_tri([h, Vector3(x, -y, 0), Vector3(pos1.x, -pos1.y, 0)])
			add_tri([-h, pos2.rotated(axis, sa), pos1.rotated(axis, sa)])
			add_tri([h, Vector3(pos1.x, -pos1.y, 0).rotated(axis, sa), Vector3(x, -y, 0).rotated(axis, sa)])
			
			pos1 = pos2
			
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Radius', radius)
	add_tree_range(tree, 'Height', height)
	add_tree_range(tree, 'Segments', segments, 1, 3, 64)
	add_tree_range(tree, 'Height Segments', height_segments, 2, 4, 64)
	add_tree_range(tree, 'Slice', rad2deg(slice), 1, 0, 359)
	add_tree_empty(tree)
	add_tree_check(tree, 'Fill Ends', fill_ends)
	

