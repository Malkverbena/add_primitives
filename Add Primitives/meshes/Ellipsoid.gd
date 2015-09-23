extends "../Primitive.gd"

var width = 1.0
var length = 1.0
var height = 1.0
var segments = 16
var height_segments = 8
var slice = 0
var hemisphere = 0.0
var generate_ends = true
var generate_cap = true

static func get_name():
	return "Ellipsoid"
	
static func get_container():
	return "Extra Objects"
	
func create():
	var cc = Vector3(0,-height,0)
	
	var ellipse = Utils.build_ellipse_verts(Vector3(), segments, Vector2(width, length), deg2rad(360 - slice))
	
	var h_val = 1.0 - hemisphere
	
	var angle = PI * h_val / height_segments
	
	var pos = Vector3(0, -cos(angle) * height, 0)
	var rd = Vector3(sin(angle), 0, sin(angle))
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	if slice and generate_ends:
		add_smooth_group(false)
		
		var center = Vector3(0, cos(angle * height_segments) * height, 0)
		
		for i in range(height_segments):
			var rp = sin(angle * i)
			var rn = sin(angle * (i + 1))
			
			rp = Vector3(rp, 0, rp)
			rn = Vector3(rn, 0, rn)
			
			var p = Vector3(0, cos(angle * i) * height, 0)
			var n = Vector3(0, cos(angle * (i+1)) * height, 0)
			
			add_tri([center, ellipse[0] * rp + p, ellipse[0] * rn + n])
			add_tri([center, ellipse[segments] * rn + n, ellipse[segments] * rp + p])
			
	if hemisphere > 0.0:
		pos.y = cos(angle * height_segments) * height
		rd.x = sin(angle * height_segments)
		rd.z = rd.x
		
		if generate_cap:
			if not slice:
				add_smooth_group(false)
				
			for idx in range(segments):
				add_tri([pos, ellipse[idx] * rd + pos, ellipse[idx+1] * rd + pos])
				
			add_smooth_group(smooth)
			
	else:
		add_smooth_group(smooth)
		
		for idx in range(segments):
			add_tri([Vector3(0, -height, 0), ellipse[idx] * rd + pos, ellipse[idx+1] * rd + pos])
			
	for i in range(height_segments, 1, -1):
		var next_pos = Vector3(0, cos(angle * (i-1)) * height, 0)
		var next_radius = Vector3(sin(angle * (i-1)), 0, sin(angle * (i-1)))
		
		for idx in range(segments):
			add_quad([ellipse[idx] * rd + pos,
			          ellipse[idx] * next_radius + next_pos,
			          ellipse[idx+1] * next_radius + next_pos,
			          ellipse[idx+1] * rd + pos])
			
		pos = next_pos
		rd = next_radius
		
	pos = Vector3(0, cos(angle) * height, 0)
	
	for idx in range(segments):
		add_tri([ellipse[idx+1] * rd + pos, ellipse[idx] * rd + pos, Vector3(0, height, 0)])
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(editor):
	editor.add_tree_range('Width', width)
	editor.add_tree_range('Length', length)
	editor.add_tree_range('Height', height)
	editor.add_tree_range('Segments', segments, 1, 3, 64)
	editor.add_tree_range('Height Segments', height_segments, 1, 3, 64)
	editor.add_tree_range('Slice', slice, 1, 0, 359)
	editor.add_tree_range('Hemisphere', hemisphere, 0.01, 0, 0.99)
	editor.add_tree_empty()
	editor.add_tree_check('Generate Ends', generate_ends)
	editor.add_tree_check('Generate Cap', generate_cap)
	

