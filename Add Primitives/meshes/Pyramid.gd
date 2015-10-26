extends "../Primitive.gd"

var width = 2.0
var length = 2.0
var height = 1.0

static func get_name():
	return "Pyramid"
	
static func get_container():
	return "Extra Objects"
	
func update():
	var ofs = Vector3(width/2, height/2, length/2)
	
	var plane = Utils.build_plane_verts(Vector3(width, 0, 0), Vector3(0, 0, length), -ofs)
	
	var ch = Vector3(0, height, 0)
	var hw = sqrt(pow(width/2, 2) + pow(height, 2))
	var hl = sqrt(pow(length/2, 2) + pow(height, 2))
	
	var uv = [Vector2(length/2, 0), Vector2(length, hw), Vector2(0, hw)]
	
	begin()
	
	add_smooth_group(smooth)
	
	add_plane(Vector3(width, 0, 0), Vector3(0, 0, length), -ofs)
	
	add_tri([ch, plane[1], plane[0]], uv)
	add_tri([ch, plane[3], plane[2]], uv)
	
	uv[0].x = width/2
	uv[1] = Vector2(width, hl)
	uv[2].y = hl
	
	add_tri([ch, plane[2], plane[1]], uv)
	add_tri([ch, plane[0], plane[3]], uv)
	
	commit()
	
func mesh_parameters(editor):
	editor.add_tree_range('Width', width)
	editor.add_tree_range('Length', length)
	editor.add_tree_range('Height', height)
	

