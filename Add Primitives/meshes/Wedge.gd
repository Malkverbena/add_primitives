extends "builder/MeshBuilder.gd"

var width = 1.0
var height = 1.0
var length = 2.0
var fill_bottom = true
var fill_end = true

static func get_name():
	return "Wedge"
	
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
		
func create(smooth, invert):
	var fd = Vector3(0, 0, length)
	var rd = Vector3(width, 0, 0)
	var ud = Vector3(0, height, 0)
	
	var ofs = -Vector3(width/2, height/2, length/2)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	add_smooth_group(smooth)
	
	if fill_bottom:
		build_plane(rd, fd, ofs)
		
	if fill_end:
		build_plane(ud, rd, ofs)
		
	var d = ofs.distance_to(ofs + Vector3(0, -height, length))
	
	ofs.y += height
	
	add_quad([ofs, ofs + rd, ofs + Vector3(width, -height, length), ofs + Vector3(0, -height, length)], plane_uv(width, d))
	
	add_tri([ofs + Vector3(0, -height, length), ofs - ud, ofs], plane_uv(length, height, false))
	add_tri([ofs + rd, ofs + rd - ud, ofs + Vector3(width, -height, length)], plane_uv(height, length, false))
	
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Width', width)
	add_tree_range(tree, 'Height', height)
	add_tree_range(tree, 'Length', length)
	add_tree_empty(tree)
	add_tree_check(tree, 'Fill Bottom', fill_bottom)
	add_tree_check(tree, 'Fill End', fill_end)
	

