extends "builder/MeshBuilder.gd"

var radius = 1.0
var height = 2.0
var caps = true
var segments = 16
var height_segments = 1

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
		
func create(smooth, invert):
	var circumference = PI * 2 * radius 
	var h = height
	
	var circle = build_circle_verts(Vector3(0, h/2, 0), segments, radius)
	var circle_uv = build_circle_verts(Vector3(0.5, 0, 0.5), segments, radius)
	
	if invert:
		circle.invert()
		circle_uv.invert()
		
	var min_pos = Vector3(0, -h, 0)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(false)
	
	if caps:
		var top = Vector3(0, h/2, 0)
		
		var c = Vector2(0.5, 0.5)
		
		for idx in range(segments):
			add_uv(c)
			add_vertex(top)
			add_uv(Vector2(circle_uv[idx].x, circle_uv[idx].z))
			add_vertex(circle[idx])
			add_uv( Vector2(circle_uv[idx + 1].x, circle_uv[idx + 1].z))
			add_vertex(circle[idx + 1])
			
			add_uv(c)
			add_vertex(min_pos/2)
			add_uv(Vector2(circle_uv[idx + 1].x, circle_uv[idx + 1].z))
			add_vertex(circle[idx + 1] + min_pos)
			add_uv(Vector2(circle_uv[idx].x, circle_uv[idx].z))
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
			
			var u1 = idx/segments * circumference
			var u2 = (idx+1)/segments * circumference
			
			var v1 = i/height_segments * height
			var v2 = (i+1)/height_segments * height
			
			add_uv(Vector2(u2, v1))
			add_vertex(circle[idx + 1] + min_pos)
			add_uv(Vector2(u2, v2))
			add_vertex(circle[idx + 1] + next_cut)
			add_uv(Vector2(u1, v2))
			add_vertex(circle[idx] + next_cut)
			
			add_uv(Vector2(u1, v2))
			add_vertex(circle[idx] + next_cut)
			add_uv(Vector2(u1, v1))
			add_vertex(circle[idx] + min_pos)
			add_uv(Vector2(u2, v1))
			add_vertex(circle[idx + 1] + min_pos)
			
		min_pos = next_cut
		next_cut.y += h
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Radius', radius)
	add_tree_range(tree, 'Height', height)
	add_tree_check(tree, 'Caps', caps)
	add_tree_range(tree, 'Segments', segments, 1, 3, 64)
	add_tree_range(tree, 'Height Segments', height_segments, 1, 1, 64)
	

