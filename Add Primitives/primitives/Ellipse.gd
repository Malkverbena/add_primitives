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
	var center = Vector3()
	var size = Vector2(width, length)
	var slice_angle = PI * 2 - deg2rad(slice)
	
	var ellipse = Utils.build_ellipse_verts(center, segments, size, slice_angle)
	var ellipse_uv = Utils.build_ellipse_verts(Vector3(0.5, 0, 0.5), segments, size, slice_angle)
	
	begin()
	
	add_smooth_group(smooth)
	
	for i in range(segments):
		var uv = [Vector2(0.5, 0.5), Vector2(ellipse_uv[i+1].x, ellipse_uv[i+1].z),
		          Vector2(ellipse_uv[i].x, ellipse_uv[i].z)]
		
		add_tri([center, ellipse[i+1], ellipse[i]], uv)
		
	commit()
	
func mesh_parameters(editor):
	editor.add_numeric_parameter('width', width)
	editor.add_numeric_parameter('length', length)
	editor.add_numeric_parameter('segments', segments, 3, 64, 1)
	editor.add_numeric_parameter('slice', slice, 0, 359, 1)
	

