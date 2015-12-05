extends "../Primitive.gd"

var width = 1.0
var length = 1.0
var segments = 16
var slice = 0

static func get_name():
	return "Ellipse"
	
static func get_container():
	return "Extra Objects"
	
func update():
	var c = Vector3()
	var r = Vector2(width, length)
	
	var sa = PI * 2 - deg2rad(slice)
	
	var ellipse = Utils.build_ellipse_verts(c, segments, r, sa)
	var ellipse_uv = Utils.build_ellipse_verts(Vector3(0.5, 0, 0.5), segments, r, sa)
	
	begin()
	
	add_smooth_group(smooth)
	
	for i in range(segments):
		var uv = [Vector2(0.5,0.5), Vector2(ellipse_uv[i+1].x, ellipse_uv[i+1].z), 
		          Vector2(ellipse_uv[i].x, ellipse_uv[i].z)]
		
		add_tri([c, ellipse[i+1], ellipse[i]], uv)
		
	commit()
	
func mesh_parameters(editor):
	editor.add_tree_range('Width', width)
	editor.add_tree_range('Length', length)
	editor.add_tree_range('Segments', segments, 3, 64, 1)
	editor.add_tree_range('Slice', slice, 0, 359, 1)
	

