extends "../Primitive.gd"

var radius = 1
var height = 1
var sides = 16
var height_segments = 8
var slice = 0
var generate_ends = true

static func get_name():
	return "Capsule"
	
func update():
	var angle = PI/height_segments
	var slice_angle = PI * 2 - deg2rad(slice)
	
	var cc = Vector3(0, radius + height, 0)
	var r = Vector3(sin(angle), 0, sin(angle))
	var p = -Vector3(0, cos(angle) * radius + height, 0)
	
	var circle = Utils.build_circle_verts(Vector3(), sides, radius, slice_angle)
	
	begin()
	
	add_smooth_group(smooth)
	
	for idx in range(sides):
		add_tri([circle[idx + 1] * r + p, circle[idx] * r + p, -cc])
		add_tri([cc, circle[idx] * r - p, circle[idx + 1] * r - p])
		
	for i in range((height_segments - 2)/2):
		var np = -Vector3(0, cos(angle * (i + 2)) * radius + height, 0)
		var nr = Vector3(sin(angle * (i + 2)), 0, sin(angle * (i + 2)))
		
		for idx in range(sides):
			add_quad([circle[idx+1] * r + p, circle[idx+1] * nr + np, circle[idx] * nr + np, circle[idx] * r + p])
			add_quad([circle[idx] * r - p, circle[idx] * nr - np, circle[idx+1] * nr - np, circle[idx+1] * r - p])
			
		p = np
		r = nr
		
	var h = Vector3(0, height, 0)
	
	for idx in range(sides):
		add_quad([circle[idx+1] + h, circle[idx] + h, circle[idx] - h, circle[idx+1] - h])
		
	if generate_ends and slice > 0:
		add_smooth_group(false)
		
		add_quad([Vector3(radius, h.y, 0), Vector3(0, h.y, 0), Vector3(0, -h.y, 0), Vector3(radius, -h.y, 0)])
		add_quad([Vector3(0, h.y, 0), circle[sides] + h, circle[sides] - h, Vector3(0, -h.y, 0)])
		
		var m3 = Matrix3(Vector3(0, 1, 0), slice_angle)
		
		var pos1 = Vector3(0, -(height + radius), 0)
		
		for i in range(height_segments/2):
			var y = -cos(angle * (i+1)) * radius - height
			var x = sin(angle * (i+1)) * radius
			
			var pos2 = Vector3(x, y, 0)
			
			add_tri([-h, pos1, pos2])
			add_tri([h, Vector3(x, -y, 0), Vector3(pos1.x, -pos1.y, 0)])
			add_tri([-h, m3.xform(pos2), m3.xform(pos1)])
			add_tri([h, m3.xform(Vector3(pos1.x, -pos1.y, 0)), m3.xform(Vector3(x, -y, 0))])
			
			pos1 = pos2
			
	commit()
	
func mesh_parameters(editor):
	editor.add_numeric_parameter('radius', radius)
	editor.add_numeric_parameter('height', height)
	editor.add_numeric_parameter('sides', sides, 3, 64, 1)
	editor.add_numeric_parameter('height_segments', height_segments, 2, 64, 2)
	editor.add_numeric_parameter('slice', slice, 0, 359, 1)
	editor.add_empty()
	editor.add_bool_parameter('generate_ends', generate_ends)
	

