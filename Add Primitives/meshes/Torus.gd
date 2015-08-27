extends "builder/MeshBuilder.gd"

var major_radius = 0.8
var minor_radius = 0.2
var steps = 16
var segments = 8

static func get_name():
	return "Torus"
	
func set_parameter(name, value):
	if name == 'Major Radius':
		major_radius = value
		
	elif name == 'Minor Radius':
		minor_radius = value
		
	elif name == 'Torus Segments':
		steps = value
		
	elif name == 'Segments':
		segments = value
		
func create(smooth = false, invert = false):
	var radians = PI*2
	var bend_radius = major_radius/radians
	
	var angle = radians/steps
	
	var s = build_circle_verts(Vector3(0,0,0), steps, major_radius)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(smooth)
	
	var c
	var c2
	var temp_circle
	
	for i in range(s.size() - 2):
		c = build_circle_verts_rot(s[i], segments, minor_radius, [PI/2, angle * i], [Vector3(1,0,0), Vector3(0,1,0)])
		c2 = build_circle_verts_rot(s[i + 1], segments, minor_radius, [PI/2, angle * (i+1)], [Vector3(1,0,0), Vector3(0,1,0)])
		if i == s.size() - 3:
			temp_circle = c2
			
		for idx in range(segments):
			add_quad([c[idx], c2[idx], c2[idx + 1], c[idx + 1]], [], invert)
			
	c2 = build_circle_verts_rot(s[0], segments, minor_radius, [PI/2, angle * 0], [Vector3(1,0,0), Vector3(0,1,0)])
	
	for idx in range(segments):
		add_quad([temp_circle[idx], c2[idx], c2[idx + 1], temp_circle[idx + 1]], [], invert)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, "Major Radius", major_radius)
	add_tree_range(tree, "Minor Radius", minor_radius)
	add_tree_range(tree, "Torus Segments", steps, 1, 3, 64)
	add_tree_range(tree, "Segments", segments, 1, 3, 64)
	

