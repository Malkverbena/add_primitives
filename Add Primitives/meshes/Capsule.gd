extends "builder/MeshBuilder.gd"

var radius = 1
var height = 1
var segments = 16
var height_segments = 8

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
		
func create(smooth = false, invert = false):
	var angle = PI/height_segments
	
	var cc = Vector3(0,radius + height,0)
	
	var circle = build_circle_verts(Vector3(0,0,0), segments, radius)
	
	var r = Vector3(sin(angle), 0, sin(angle))    #Radius
	var p    #Positions
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(smooth)
	
	for idx in range(segments):
		p = Vector3(0,-cos(angle) * radius - height, 0)
		add_tri([(circle[idx + 1] * r) + p, (circle[idx] * r) + p, -cc], [], invert)
		
		p = Vector3(0,-cos(angle * (height_segments - 1)) * radius + height,0)
		add_tri([cc, (circle[idx] * r) + p, (circle[idx + 1] * r + p)], [], invert)
		
	for i in range((height_segments - 2)/2):
		r = Vector3(sin(angle * (i + 1)), 0, sin(angle * (i + 1)))
		var nr = Vector3(sin(angle * (i + 2)), 0, sin(angle * (i + 2)))    #Next Radius
		
		var np = Vector3(0, -cos(angle * (i + 2)) * radius - height, 0)
		
		if i == 0:
			p = Vector3(0,-cos(angle) * radius - height,0)
		
		for idx in range(segments):
			add_quad([circle[idx+1] * r + p, circle[idx+1] * nr + np, circle[idx] * nr + np, circle[idx] * r + p], [], invert)
		p = np
		
	for i in range(((height_segments - 2)/2), height_segments - 1):
		r = Vector3(sin(angle * i), 0, sin(angle * i))
		
		var nr = Vector3(sin(angle * (i + 1)), 0, sin(angle * (i + 1)))
		
		if i == ((height_segments - 2)/2):
			r = Vector3(sin(angle * (i + 1)), 0, sin(angle * (i + 1)))
			
		var np = Vector3(0, -cos(angle * (i + 1)) * radius + height, 0)
		
		for idx in range(segments):
			add_quad([circle[idx+1] * r + p, circle[idx+1] * nr + np, circle[idx] * nr + np, circle[idx] * r + p], [], invert)
			
		p = np
	
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Radius', radius)
	add_tree_range(tree, 'Height', height)
	add_tree_range(tree, 'Segments', segments, 1, 3, 64)
	add_tree_range(tree, 'Height Segments', height_segments, 2, 4, 64)
	

