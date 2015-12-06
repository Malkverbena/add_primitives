extends "../Primitive.gd"

var radius = 1.0
var height = 2.0
var sides = 16
var slice = 0
var generate_bottom = true
var generate_ends = true

static func get_name():
	return "Cone"
	
func update():
	var top = Vector3(0, height/2, 0)
	var bottom = Vector3(0, -height/2, 0)
	var slice_angle = PI * 2 - deg2rad(slice)
	
	var circle = Utils.build_circle_verts(bottom, sides, radius, slice_angle)
	var circle_uv = Utils.build_circle_verts(Vector3(0.5, 0, 0.5), sides, radius, slice_angle)
	
	var uv
	
	begin()
	
	add_smooth_group(smooth)
	
	for idx in range(sides):
		uv = [Vector2(0.5, 0.5), Vector2(circle_uv[idx].x, circle_uv[idx].z),
		      Vector2(circle_uv[idx+1].x, circle_uv[idx+1].z)]
		
		add_tri([top, circle[idx], circle[idx+1]], uv)
		
	add_smooth_group(false)
	
	if generate_ends and slice > 0:
		uv = [Vector2(), Vector2(0, height), Vector2(radius, height)]
		
		add_tri([top, bottom, circle[0]], uv)
		add_tri([top, circle[sides], bottom], [uv[0], uv[2], uv[1]])
		
	if generate_bottom:
		for idx in range(sides):
			uv = [Vector2(0.5, 0.5), Vector2(circle_uv[idx+1].x, circle_uv[idx+1].z),
			      Vector2(circle_uv[idx].x, circle_uv[idx].z)]
			
			add_tri([bottom, circle[idx+1], circle[idx]], uv)
			
	commit()
	
func mesh_parameters(editor):
	editor.add_tree_range('Radius', radius)
	editor.add_tree_range('Height', height)
	editor.add_tree_range('Sides', sides, 3, 64, 1)
	editor.add_tree_range('Slice', slice, 0, 359, 1)
	editor.add_tree_empty()
	editor.add_tree_check('Generate Bottom', generate_bottom)
	editor.add_tree_check('Generate Ends', generate_ends)

