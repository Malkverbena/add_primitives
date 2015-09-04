extends "builder/MeshBuilder.gd"

var major_radius = 0.8
var minor_radius = 0.2
var torus_segments = 16
var segments = 8
var slice = 0
var generate_ends = true

static func get_name():
	return "Torus"
	
func set_parameter(name, value):
	if name == 'major_radius':
		major_radius = value
		
	elif name == 'minor_radius':
		minor_radius = value
		
	elif name == 'torus_segments':
		torus_segments = value
		
	elif name == 'segments':
		segments = value
		
	elif name == 'slice':
		slice = deg2rad(value)
		
	elif name == 'generate_ends':
		generate_ends = value
		
func create(smooth, invert):
	var sa = PI * 2 - slice
	var bend_radius = major_radius/sa
	
	var angle = sa/torus_segments
	
	var s = build_circle_verts(Vector3(), torus_segments, major_radius, sa)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	add_smooth_group(smooth)
	
	var temp_circle
	
	var c = build_circle_verts_rot(s[0], segments, minor_radius, Matrix3(Vector3(1,0,0), PI/2))
	var c2 = []
	
	if not slice:
		c2.resize(segments + 1)
		
	for i in range(s.size() - 1):
		var m1 = Matrix3(Vector3(0,1,0), angle * i)
		
		if i < s.size() - 2 or slice:
			var m2 = Matrix3(Vector3(0,1,0), angle * (i+1))
			
			for idx in range(segments):
				add_quad([m1.xform(c[idx]), m2.xform(c[idx]), m2.xform(c[idx + 1]), m1.xform(c[idx + 1])])
				
		else:
			for idx in range(segments + 1):
				c2[idx] = m1.xform(c[idx])
				
	if not slice:
		for idx in range(segments):
			add_quad([c2[idx], c[idx], c[idx + 1], c2[idx + 1]])
			
	elif generate_ends:
		var m = Matrix3(Vector3(0,1,0), sa)
		
		add_smooth_group(false)
		
		for idx in range(segments):
			add_tri([s[0], c[idx], c[idx+1]])
			add_tri([m.xform(c[idx+1]), m.xform(c[idx]), s[torus_segments]])
			
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, "Major Radius", major_radius)
	add_tree_range(tree, "Minor Radius", minor_radius)
	add_tree_range(tree, "Torus Segments", torus_segments, 1, 3, 64)
	add_tree_range(tree, "Segments", segments, 1, 3, 64)
	add_tree_range(tree, "Slice", rad2deg(slice), 1, 0, 359)
	add_tree_empty(tree)
	add_tree_check(tree, "Generate Ends", generate_ends)
	

