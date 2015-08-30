extends "builder/MeshBuilder.gd"

var radius = 1.0
var height = 2.0
var segments = 16

static func get_name():
	return "Cone"
	
func set_parameter(name, value):
	if name == 'Radius':
		radius = value
		
	elif name == 'Height':
		height = value
		
	elif name == 'Segments':
		segments = value
		
func create(smooth, invert):
	var center_top = Vector3(0, height/2, 0)
	var min_pos = Vector3(0, -height/2, 0)
	
	var circle = build_circle_verts(min_pos, segments, radius)
	var circle_uv = build_circle_verts(Vector3(0.5,0,0.5), segments, radius)
	
	var uv
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	add_smooth_group(smooth)
	
	for idx in range(segments):
		uv = [Vector2(0.5, 0.5), Vector2(circle_uv[idx].x, circle_uv[idx].z),
		      Vector2(circle_uv[idx + 1].x, circle_uv[idx + 1].z)]
		
		add_tri([center_top, circle[idx], circle[idx + 1]], uv)
		
	add_smooth_group(false)
	
	for idx in range(segments):
		uv = [Vector2(circle_uv[idx + 1].x, circle_uv[idx + 1].z),
		      Vector2(circle_uv[idx].x, circle_uv[idx].z), Vector2(0.5, 0.5)]
		
		add_tri([circle[idx + 1], circle[idx], min_pos], uv)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Radius', radius)
	add_tree_range(tree, 'Height', height)
	add_tree_range(tree, 'Segments', segments, 1, 3, 64)
	

