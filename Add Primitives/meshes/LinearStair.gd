extends "builder/MeshBuilder.gd"

var steps = 10
var width = 1.0
var height = 2.0
var length = 2.0
var fill_end = true
var fill_bottom = true

static func get_name():
	return "Linear Stair"
	
static func get_container():
	return "Add Stair"
	
func set_parameter(name, value):
	if name == 'Steps':
		steps = value
		
	elif name == 'Width':
		width = value
		
	elif name == 'Height':
		height = value
		
	elif name == 'Length':
		length = value
		
	elif name == 'Fill End':
		fill_end = value
		
	elif name == 'Fill Bottom':
		fill_bottom = value
		
func create(smooth = false, invert = false):
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(smooth)
	
	var sh = height/steps
	var sl = length/steps
	
	for i in range(steps):
		add_quad(build_plane_verts(Vector3(0, 0, sl), Vector3(width, 0, 0), Vector3(0, (i+1) * sh, i * sl)), [], invert)
		add_quad(build_plane_verts(Vector3(0, sh, 0), Vector3(width, 0, 0), Vector3(0, i * sh, i * sl)), [], invert)
		add_quad(build_plane_verts(Vector3(0, 0, sl), Vector3(0, (i+1)*sh, 0), Vector3(0, 0, i * sl)), [], invert)
		add_quad(build_plane_verts(Vector3(0, (i+1)*sh, 0), Vector3(0, 0, sl), Vector3(width, 0, i * sl)), [], invert)
		
	if fill_end:
		add_quad(build_plane_verts(Vector3(width, 0, 0), Vector3(0, steps * sh, 0), Vector3(0, 0, steps * sl)), [], invert)
	if fill_bottom:
		add_quad(build_plane_verts(Vector3(width, 0, 0), Vector3(0, 0, steps * sl)), [], invert)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Steps', 10, 1, 1, 64)
	add_tree_range(tree, 'Width', 1)
	add_tree_range(tree, 'Height', 2)
	add_tree_range(tree, 'Length', 2)
	add_tree_empty(tree)
	add_tree_check(tree, 'Fill End', true)
	add_tree_check(tree, 'Fill Bottom', true)

