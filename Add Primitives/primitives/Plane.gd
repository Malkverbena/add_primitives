extends "../Primitive.gd"

var length = 2.0
var width = 2.0
var start_height = 0.0
var end_height = 0.0

static func get_name():
	return "Plane"
	
func update():
	var verts = [Vector3(-width/2, end_height, -length/2),
	             Vector3(width/2, end_height, -length/2),
	             Vector3(width/2, start_height, length/2),
	             Vector3(-width/2, start_height, length/2)]
	
	var uv_width = verts[0].distance_to(verts[1])
	var uv_length = verts[0].distance_to(verts[3])
	
	begin()
	
	add_smooth_group(smooth)
	
	add_quad(verts, Utils.plane_uv(uv_width, uv_length))
	
	commit()
	
func mesh_parameters(editor):
	editor.add_tree_range('Length', length)
	editor.add_tree_range('Width', width)
	editor.add_tree_range('Start Height', start_height)
	editor.add_tree_range('End Height', end_height)
	

