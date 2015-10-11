extends "../Primitive.gd"

var radius = 1.0
var height = 2.0
var sides = 16
var slice = 0
var generate_bottom = true
var generate_ends = true

static func get_name():
	return "Cone"
	
func create():
	var center_top = Vector3(0, height/2, 0)
	var min_pos = Vector3(0, -height/2, 0)
	
	var sa = PI * 2 - deg2rad(slice)
	
	var circle = Utils.build_circle_verts(min_pos, sides, radius, sa)
	var circle_uv = Utils.build_circle_verts(Vector3(0.5, 0, 0.5), sides, radius, sa)
	
	var uv
	
	begin()
	
	add_smooth_group(smooth)
	
	for idx in range(sides):
		uv = [Vector2(0.5, 0.5), Vector2(circle_uv[idx].x, circle_uv[idx].z),
		      Vector2(circle_uv[idx + 1].x, circle_uv[idx + 1].z)]
		
		add_tri([center_top, circle[idx], circle[idx + 1]], uv)
		
	add_smooth_group(false)
	
	if generate_ends and slice:
		uv = [Vector2(), Vector2(0, height), Vector2(radius, height)]
		
		add_tri([center_top, min_pos, circle[0]], uv)
		add_tri([center_top, circle[sides], min_pos], [uv[0], uv[2], uv[1]])
		
	if generate_bottom:
		for idx in range(sides):
			uv = [Vector2(circle_uv[idx + 1].x, circle_uv[idx + 1].z),
			      Vector2(circle_uv[idx].x, circle_uv[idx].z), Vector2(0.5, 0.5)]
			
			add_tri([circle[idx + 1], circle[idx], min_pos], uv)
			
	commit()
	
func mesh_parameters(editor):
	editor.add_tree_range('Radius', radius)
	editor.add_tree_range('Height', height)
	editor.add_tree_range('Sides', sides, 1, 3, 64)
	editor.add_tree_range('Slice', slice, 1, 0, 359)
	editor.add_tree_empty()
	editor.add_tree_check('Generate Bottom', generate_bottom)
	editor.add_tree_check('Generate Ends', generate_ends)

