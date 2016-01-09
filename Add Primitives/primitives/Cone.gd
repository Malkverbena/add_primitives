extends "../Primitive.gd"

var radius = 1.0
var height = 2.0
var sides = 16
var slice_from = 0
var slice_to = 0
var generate_bottom = true
var generate_ends = true

static func get_name():
	return "Cone"
	
func update():
	var slice_angle = Utils.TWO_PI - deg2rad(slice_to)
	
	var top = Vector3(0, height/2, 0)
	var bottom = Vector3(0, -height/2, 0)
	var center_uv = Vector2(0.5, 0.5)
	
	var circle = Utils.build_circle(bottom, sides, radius, deg2rad(slice_from), slice_angle)
	var uv = Utils.ellipse_uv(center_uv, sides, Vector2(radius, radius), slice_angle)
	
	begin()
	
	add_smooth_group(smooth)
	
	for i in range(sides):
		add_tri([top, circle[i], circle[i + 1]], [center_uv, uv[i], uv[i + 1]])
		
	add_smooth_group(false)
	
	if generate_ends and slice_to > 0:
		var uv = [Vector2(radius, height), Vector2(), Vector2(0, height)]
	
		add_tri([circle[0], top, bottom], uv)
		
		if not flip_normals:
			uv.invert()
		
		add_tri([bottom, top, circle[sides]], uv)
		
	if generate_bottom:
		for i in range(sides):
			add_tri([bottom, circle[i + 1], circle[i]], [center_uv, uv[i + 1], uv[i]])
			
	commit()
	
func mesh_parameters(editor):
	editor.add_numeric_parameter('radius', radius)
	editor.add_numeric_parameter('height', height)
	editor.add_numeric_parameter('sides', sides, 3, 64, 1)
	editor.add_numeric_parameter('slice_from', slice_from, 0, 360, 1)
	editor.add_numeric_parameter('slice_to', slice_to, 0, 359, 1)
	editor.add_empty()
	editor.add_bool_parameter('generate_bottom', generate_bottom)
	editor.add_bool_parameter('generate_ends', generate_ends)

