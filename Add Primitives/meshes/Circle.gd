extends "builder/MeshBuilder.gd"

var radius = 1
var segments = 16

static func get_name():
	return "Circle"
	
func set_parameter(name, value):
	if name == 'Radius':
		radius = value
		
	elif name == 'Segments':
		segments = value
		
func create(smooth, invert):
	var c = Vector3(0,0,0)
	
	var circle = build_circle_verts(c, segments, radius)
	var circle_uv = build_circle_verts(Vector3(0.5,0,0.5), segments, radius)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	add_smooth_group(smooth)
	
	for i in range(segments):
		var uv = [Vector2(0.5,0.5), Vector2(circle_uv[i].x, circle_uv[i].z), 
		          Vector2(circle_uv[i+1].x, circle_uv[i+1].z)]
		
		add_tri([c, circle[i], circle[i+1]], uv)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Radius', radius)
	add_tree_range(tree, 'Segments', segments, 1, 3, 64)
	

