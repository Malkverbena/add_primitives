extends "builder/MeshBuilder.gd"

var radius = 1.0
var height = 2.0
var sides = 16
var slice = 0
var generate_ends = true

static func get_name():
	return "Cone"
	
func set_parameter(name, value):
	if name == 'radius':
		radius = value
		
	elif name == 'height':
		height = value
		
	elif name == 'sides':
		sides = value
		
	elif name == 'slice':
		slice = deg2rad(value)
		
	elif name == 'generate_ends':
		generate_ends = value
		
func create(smooth, invert):
	var center_top = Vector3(0, height/2, 0)
	var min_pos = Vector3(0, -height/2, 0)
	
	var sa = PI * 2 - slice
	
	var circle = build_circle_verts(min_pos, sides, radius, sa)
	var circle_uv = build_circle_verts(Vector3(0.5,0,0.5), sides, radius, sa)
	
	var uv
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
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
		
	for idx in range(sides):
		uv = [Vector2(circle_uv[idx + 1].x, circle_uv[idx + 1].z),
		      Vector2(circle_uv[idx].x, circle_uv[idx].z), Vector2(0.5, 0.5)]
		
		add_tri([circle[idx + 1], circle[idx], min_pos], uv)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Radius', radius)
	add_tree_range(tree, 'Height', height)
	add_tree_range(tree, 'Sides', sides, 1, 3, 64)
	add_tree_range(tree, 'Slice', rad2deg(slice), 1, 0, 359)
	add_tree_empty(tree)
	add_tree_check(tree, 'Generate Ends', generate_ends)

