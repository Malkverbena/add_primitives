extends "../Primitive.gd"

var width = 1.0
var height = 1.0
var length = 2.0
var generate_bottom = true
var generate_end = true

static func get_name():
	return "Wedge"
	
func create():
	var fd = Vector3(0, 0, length)
	var rd = Vector3(width, 0, 0)
	var ud = Vector3(0, height, 0)
	
	var ofs = -Vector3(width/2, height/2, length/2)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(smooth)
	
	if generate_bottom:
		add_plane(rd, fd, ofs)
		
	if generate_end:
		add_plane(ud, rd, ofs)
		
	var d = ofs.distance_to(ofs + Vector3(0, -height, length))
	
	ofs.y += height
	
	add_quad([ofs, ofs + rd, ofs + Vector3(width, -height, length), ofs + Vector3(0, -height, length)], Utils.plane_uv(width, d))
	
	add_tri([ofs + Vector3(0, -height, length), ofs - ud, ofs], Utils.plane_uv(length, height, false))
	add_tri([ofs + rd, ofs + rd - ud, ofs + Vector3(width, -height, length)], Utils.plane_uv(height, length, false))
	
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(editor):
	editor.add_tree_range('Width', width)
	editor.add_tree_range('Height', height)
	editor.add_tree_range('Length', length)
	editor.add_tree_empty()
	editor.add_tree_check('Generate Bottom', generate_bottom)
	editor.add_tree_check('Generate End', generate_end)
	

