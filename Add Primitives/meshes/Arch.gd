extends "builder/MeshBuilder.gd"

var radius = 1.0
var length = 2.0
var segments = 16
var fill_bottom = true

static func get_name():
	return "Arch"
	
static func get_container():
	return 'Extra Objects'
	
func set_parameter(name, value):
	if name == 'Radius':
		radius = value
		
	elif name == 'Length':
		length = value
		
	elif name == 'Segments':
		segments = value
		
	elif name == 'Fill Bottom':
		fill_bottom = value
		
func create(smooth = false, invert = false):
	var angle = PI/segments
	var r = Vector3(radius, radius, 1)
	
	var next_pos = Vector3(0, 0, -length)
	
	var uv
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(smooth)
	
	for i in range(segments):
		i = float(i)
		
		var v = Vector3(cos(angle*(i+1)), sin(angle*(i+1)), length/2) * r
		var v2 = Vector3(cos(angle*i), sin(angle*i), length/2) * r
		
		uv = [Vector2(i/segments, 0), Vector2(i/segments, 1),\
		      Vector2((i+1)/segments, 1), Vector2((i+1)/segments, 0)]
		
		add_quad([v2, v2 + next_pos, v + next_pos, v], uv, invert)
		
	add_smooth_group(false)
		
	if fill_bottom:
		uv = [Vector2(1, 1), Vector2(0, 1), Vector2(0, 0), Vector2(1, 0)]
		
		add_quad(build_plane_verts(Vector3(0, 0, length), Vector3(radius*2, 0, 0), -Vector3(radius, 0, length/2)), uv, invert)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Radius', radius)
	add_tree_range(tree, 'Length', length)
	add_tree_range(tree, 'Segments', segments, 1, 2, 64)
	add_tree_empty(tree)
	add_tree_check(tree, 'Fill Bottom', fill_bottom)
	

