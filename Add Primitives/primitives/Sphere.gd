extends "../Primitive.gd"

var radius = 1.0
var segments = 16
var height_segments = 8
var slice = 0
var hemisphere = 0.0
var generate_ends = true
var generate_cap = true

static func get_name():
	return "Sphere"
	
func update():
	var angle = PI * (1 - hemisphere) / height_segments
	
	var pos = Vector3(0, -cos(angle) * radius, 0)
	var rd = Vector3(sin(angle), 0, sin(angle))
	
	var circle = Utils.build_circle_verts(Vector3(), segments, radius, deg2rad(360 - slice))
	
	begin()
	
	if generate_ends and slice > 0:
		add_smooth_group(false)
		
		var center = Vector3(0, cos(angle * height_segments) * radius, 0)
		
		for i in range(height_segments):
			var rp = sin(angle * i)
			var rn = sin(angle * (i + 1))
			
			rp = Vector3(rp, 0, rp)
			rn = Vector3(rn, 0, rn)
			
			var p = Vector3(0, cos(angle * i) * radius, 0)
			var n = Vector3(0, cos(angle * (i+1)) * radius, 0)
			
			add_tri([center, circle[0] * rn + n, circle[0] * rp + p])
			add_tri([center, circle[segments] * rp + p, circle[segments] * rn + n])
			
	if hemisphere > 0:
		pos.y = cos(angle * height_segments) * radius
		rd.x = sin(angle * height_segments)
		rd.z = rd.x
		
		if generate_cap:
			if not slice:
				add_smooth_group(false)
				
			for idx in range(segments):
				add_tri([pos, circle[idx+1] * rd + pos, circle[idx] * rd + pos])
				
		add_smooth_group(smooth)
		
	else:
		add_smooth_group(smooth)
		
		for idx in range(segments):
			add_tri([Vector3(0, -radius, 0), circle[idx+1] * rd + pos, circle[idx] * rd + pos])
			
	for i in range(height_segments, 1, -1):
		var n = i - 1
		
		var np = Vector3(0, cos(angle * n) * radius, 0)
		var nr = Vector3(sin(angle * n), 0, sin(angle * n))
		
		for idx in range(segments):
			add_quad([circle[idx] * rd + pos, circle[idx+1] * rd + pos,
			          circle[idx+1] * nr + np, circle[idx] * nr + np])
			
		pos = np
		rd = nr
		
		
	pos = Vector3(0, cos(angle) * radius, 0)
	
	for idx in range(segments):
		add_tri([circle[idx] * rd + pos, circle[idx+1] * rd + pos, Vector3(0, radius, 0)])
		
	commit()
	
func mesh_parameters(editor):
	editor.add_numeric_parameter('radius', radius)
	editor.add_numeric_parameter('segments', segments, 3, 64, 1)
	editor.add_numeric_parameter('height_segments', height_segments, 3, 64, 1)
	editor.add_numeric_parameter('slice', slice, 0, 359, 1)
	editor.add_numeric_parameter('hemisphere', hemisphere, 0, 0.999)
	editor.add_empty()
	editor.add_bool_parameter('generate_ends', generate_ends)
	editor.add_bool_parameter('generate_cap', generate_cap)

