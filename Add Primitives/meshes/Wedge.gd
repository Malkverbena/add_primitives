extends "builder/MeshBuilder.gd"

var width = 1.0
var height = 1.0
var length = 2.0
var fill_bottom = true
var fill_end = true

static func get_name():
	return "Wedge"
	
static func get_container():
	return "Extra Objects"
	
func set_parameter(name, value):
	if name == 'Width':
		width = value
		
	elif name == 'Height':
		height = value
		
	elif name == 'Length':
		length = value
		
	elif name == 'Fill Bottom':
		fill_bottom = value
		
	elif name == 'Fill End':
		fill_end = value
		
func build_mesh(smooth = false, reverse = false):
	var fd = Vector3(0, 0, length)
	var rd = Vector3(width, 0, 0)
	var ud = Vector3(0, height, 0)
	
	var off = -Vector3(width/2, height/2, length/2)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(smooth)
	
	if fill_bottom:
		add_quad(build_plane_verts(rd, fd, off), plane_uv(width, length), reverse)
		
	if fill_end:
		add_quad(build_plane_verts(ud, rd, off), plane_uv(height, width), reverse)
		
	var d = off.distance_to(off + Vector3(0, -height, length))
	
	off.y += height
	
	add_quad([off, off + rd, off + Vector3(width, -height, length), off + Vector3(0, -height, length)], plane_uv(width, d), reverse)
	
	add_tri([off + Vector3(0, -height, length), off - ud, off], plane_uv(length, height, false), reverse)
	add_tri([off + rd, off + rd - ud, off + Vector3(width, -height, length)], plane_uv(height, length, false), reverse)
	
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Width', 1)
	add_tree_range(tree, 'Height', 1)
	add_tree_range(tree, 'Length', 2)
	add_tree_empty(tree)
	add_tree_check(tree, 'Fill Bottom', true)
	add_tree_check(tree, 'Fill End', true)
	

