extends 'builder/MeshBuilder.gd'

var width = 1.0
var length = 1.0
var segments = 16

static func get_name():
	return "Ellipse"
	
static func get_container():
	return "Extra Objects"
	
func set_parameter(name, value):
	if name == 'Width':
		width = value
		
	elif name == 'Length':
		length = value
		
	elif name == 'Segments':
		segments = value
		
func create(smooth, invert):
	var c = Vector3(0,0,0)
	var r = Vector2(width, length)
	
	var ellipse = build_ellipse_verts(c, segments, r)
	var ellipse_uv = build_ellipse_verts(Vector3(0.5,0,0.5), segments, r)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	add_smooth_group(smooth)
	
	for i in range(segments):
		var uv = [Vector2(0.5,0.5), Vector2(ellipse_uv[i+1].x, ellipse_uv[i+1].z), 
		          Vector2(ellipse_uv[i].x, ellipse_uv[i].z)]
		
		add_tri([c, ellipse[i+1], ellipse[i]], uv)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Width', width)
	add_tree_range(tree, 'Length', length)
	add_tree_range(tree, 'Segments', segments, 1, 3, 64)
	

