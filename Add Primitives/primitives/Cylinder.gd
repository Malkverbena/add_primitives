extends "../Primitive.gd"

var radius = 1.0
var height = 2.0
var sides = 16
var height_segments = 1
var slice = 0
var generate_top = true
var generate_bottom = true
var generate_ends = true

static func get_name():
	return "Cylinder"
	
func update():
	var angle = 360 - slice	
	var slice_angle = deg2rad(angle)
	var circumference = (angle * PI * radius) / 180
	
	var top = Vector3(0, height/2, 0)
	var bottom = Vector3(0, -height/2, 0)
	
	var circle = Utils.build_circle_verts(Vector3(), sides, radius, slice_angle)
	var uv = Utils.build_circle_verts(Vector3(0.5, 0, 0.5), sides, radius, slice_angle)
	
	begin()
	
	add_smooth_group(false)
	
	if generate_top or generate_bottom:
		var c = Vector2(0.5, 0.5)
		
		for idx in range(sides):
			if generate_top:
				add_tri([top, circle[idx] + top, circle[idx + 1] + top],\
				        [c, Vector2(uv[idx].x, uv[idx].z), Vector2(uv[idx + 1].x, uv[idx + 1].z)])
				
			if generate_bottom:
				add_tri([bottom, circle[idx + 1] + bottom, circle[idx] + bottom],\
				        [c, Vector2(uv[idx + 1].x, uv[idx + 1].z), Vector2(uv[idx].x, uv[idx].z)])
				
	if generate_ends and slice > 0:
		var p = bottom
		
		for i in range(height_segments):
			var n = bottom.linear_interpolate(top, (i+1)/height_segments)
			
			var v1 = i/height_segments * height
			var v2 = (i + 1)/height_segments * height
			
			var uv = [Vector2(0, v1),
			          Vector2(radius, v1),
			          Vector2(radius, v2),
			          Vector2(0, v2)]
			
			add_quad([p, circle[0] + p, circle[0] + n, n], uv)
			
			if not flip_normals:
				uv.invert()
				
			add_quad([n, circle[sides] + n, circle[sides] + p, p], uv)
			
			p = n
			
	add_smooth_group(smooth)
	
	var p = bottom
	
	for i in range(height_segments):
		var n = bottom.linear_interpolate(top, (i+1)/height_segments)
		
		var v1 = lerp(height, 0, i/height_segments)
		var v2 = lerp(height, 0, (i+1)/height_segments)
		
		for idx in range(sides):
			var u1 = idx/sides * circumference
			var u2 = (idx+1)/sides * circumference
			
			add_quad([circle[idx] + p, circle[idx + 1] + p, circle[idx + 1] + n, circle[idx] + n],\
			         [Vector2(u1, v1), Vector2(u2, v1), Vector2(u2, v2), Vector2(u1, v2)])
			
		p = n
		
	commit()
	
func mesh_parameters(editor):
	editor.add_tree_range('Radius', radius)
	editor.add_tree_range('Height', height)
	editor.add_tree_range('Sides', sides, 3, 64, 1)
	editor.add_tree_range('Height Segments', height_segments, 1, 64, 1)
	editor.add_tree_range('Slice', slice, 0, 359, 1)
	editor.add_tree_empty()
	editor.add_tree_check('Generate Top', generate_top)
	editor.add_tree_check('Generate Bottom', generate_bottom)
	editor.add_tree_check('Generate Ends', generate_ends)
	

