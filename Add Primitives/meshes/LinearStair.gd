extends "builder/MeshBuilder.gd"

var steps = 10
var width = 1.0
var height = 2.0
var length = 2.0
var generate_end = true
var generate_bottom = true

static func get_name():
	return "Linear Stair"
	
static func get_container():
	return "Add Stair"
	
func set_parameter(name, value):
	if name == 'steps':
		steps = value
		
	elif name == 'width':
		width = value
		
	elif name == 'height':
		height = value
		
	elif name == 'length':
		length = value
		
	elif name == 'generate_end':
		generate_end = value
		
	elif name == 'generate_bottom':
		generate_bottom = value
		
func create(smooth, invert):
	var sh = height/steps
	var sl = length/steps
	
	var d = [Vector3(width, 0, 0),
	         Vector3(0, 0, sl),
	         Vector3(0, sh, 0)]
	
	var pz = Vector2()
	var py = Vector2()
	
	var w = Vector2(0, width)
	var l = Vector2(sl, 0)
	var h = Vector2(sh, 0)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	add_smooth_group(smooth)
	
	for i in range(steps):
		add_quad(build_plane_verts(d[1], d[0], Vector3(0, (i+1) * sh, i * sl)), [py+w, py+w+l, py+l, py])
		add_quad(build_plane_verts(d[2], d[0], Vector3(0, i * sh, i * sl)), [pz+w, pz+h+w, pz+h, pz])
		
		var ch = Vector2(0, sh * (i+1))
		
		add_quad(build_plane_verts(d[1], Vector3(0, ch.y, 0), Vector3(0, 0, i * sl)), [py+ch, py+ch+l, py+l, py])
		add_quad(build_plane_verts(Vector3(0, ch.y, 0), d[1], Vector3(width, 0, i * sl)), [py+l, py+l+ch, py+ch, py])
		
		py.x += sl
		pz.x += sh
		
	if generate_end:
		build_plane(d[0], Vector3(0, steps * sh, 0), Vector3(0, 0, steps * sl))
		
	if generate_bottom:
		build_plane(d[0], Vector3(0, 0, steps * sl))
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Steps', steps, 1, 2, 64)
	add_tree_range(tree, 'Width', width)
	add_tree_range(tree, 'Height', height)
	add_tree_range(tree, 'Length', length)
	add_tree_empty(tree)
	add_tree_check(tree, 'Generate End', generate_end)
	add_tree_check(tree, 'Generate Bottom', generate_bottom)

