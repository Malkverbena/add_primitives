extends "builder/MeshBuilder.gd"

var radius = 1.0
var height = 2.0
var caps = true
var segments = 16
var height_segments = 8

static func get_name():
	return "Cylinder"
	
func set_parameter(name, value):
	if name == 'Radius':
		radius = value
		
	elif name == 'Height':
		height = value
		
	elif name == 'Caps':
		caps = value
		
	elif name == 'Segments':
		segments = value
		
	elif name == 'Height Segments':
		height_segments = value
		
func create(smooth = false, invert = false):
	var circle = build_circle_verts(Vector3(0,height/2,0), segments, radius)
	var circle_uv = build_circle_verts(Vector3(0.25,0,0.25), segments, 0.25)
	
	var h = height
	
	if invert:
		circle.invert()
		circle_uv.invert()
		
	var min_pos = Vector3(0, -h, 0)
	
	var uv
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(false)
	
	if caps:
		var top = Vector3(0, h/2, 0)
		
		var c1 = Vector2(0.25, 0.25)
		var c2 = Vector2(0.75, 0.25)
		
		for idx in range(segments):
			add_uv(c1)
			add_vertex(top)
			add_uv(Vector2(circle_uv[idx].x, circle_uv[idx].z))
			add_vertex(circle[idx])
			add_uv( Vector2(circle_uv[idx + 1].x, circle_uv[idx + 1].z))
			add_vertex(circle[idx + 1])
			
			add_uv(c2)
			add_vertex(min_pos/2)
			add_uv(Vector2(circle_uv[idx + 1].x + 0.5, circle_uv[idx + 1].z))
			add_vertex(circle[idx + 1] + min_pos)
			add_uv(Vector2(circle_uv[idx].x + 0.5, circle_uv[idx].z))
			add_vertex(circle[idx] + min_pos)
			
	var next_cut = min_pos + Vector3(0, h/height_segments, 0)
	
	h /= height_segments
	
	add_smooth_group(smooth)
	
	for i in range(height_segments):
		if i == height_segments - 1:
			next_cut.y = 0
			
		i = float(i)
		
		for idx in range(segments):
			idx = float(idx)
			
			var u1 = i/height_segments/2 + 0.5
			var u2 = (i+1)/height_segments/2 + 0.5
			
			add_uv(Vector2((idx+1)/segments, u1))
			add_vertex(circle[idx + 1] + min_pos)
			add_uv(Vector2((idx+1)/segments, u2))
			add_vertex(circle[idx + 1] + next_cut)
			add_uv(Vector2(idx/segments, u2))
			add_vertex(circle[idx] + next_cut)
			
			add_uv(Vector2(idx/segments, u2))
			add_vertex(circle[idx] + next_cut)
			add_uv(Vector2(idx/segments, u1))
			add_vertex(circle[idx] + min_pos)
			add_uv(Vector2((idx+1)/segments, u1))
			add_vertex(circle[idx + 1] + min_pos)
			
		min_pos = next_cut
		next_cut.y += h
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Radius', 1)
	add_tree_range(tree, 'Height', 2)
	add_tree_check(tree, 'Caps', true)
	add_tree_range(tree, 'Segments', 16, 1, 3, 64)
	add_tree_range(tree, 'Height Segments', 1, 1, 1, 64)
	

