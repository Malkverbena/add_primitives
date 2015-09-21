extends "../Primitive.gd"

var radius = 1.0
var height = 2.0
var sides = 16
var height_segments = 1
var generate_caps = true

static func get_name():
	return "Cylinder"
	
func create():
	var circumference = PI * 2 * radius 
	var h = height
	
	var circle = Utils.build_circle_verts(Vector3(0, h/2, 0), sides, radius)
	var circle_uv = Utils.build_circle_verts(Vector3(0.5, 0, 0.5), sides, radius)
	
	if invert:
		circle.invert()
		circle_uv.invert()
		
	var min_pos = Vector3(0, -h, 0)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(false)
	
	if generate_caps:
		var top = Vector3(0, h/2, 0)
		
		var c = Vector2(0.5, 0.5)
		
		for idx in range(sides):
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
		
		for idx in range(sides):
			idx = float(idx)
			
			var u1 = idx/sides * circumference
			var u2 = (idx+1)/sides * circumference
			
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
	
func mesh_parameters(editor):
	editor.add_tree_range('Radius', radius)
	editor.add_tree_range('Height', height)
	editor.add_tree_range('Sides', sides, 1, 3, 64)
	editor.add_tree_range('Height Segments', height_segments, 1, 1, 64)
	editor.add_tree_empty()
	editor.add_tree_check('Generate Caps', generate_caps)
	

