extends "../MeshBuilder.gd"

var radius = 1
var segments = 16
var slice = 0

static func get_name():
	return "Circle"
	
func create(smooth, invert):
	var c = Vector3(0,0,0)
	
	var sa = PI * 2 - deg2rad(slice)
	
	var circle = build_circle_verts(c, segments, radius, sa)
	var circle_uv = build_circle_verts(Vector3(0.5,0,0.5), segments, radius, sa)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	add_smooth_group(smooth)
	
	for i in range(segments):
		var uv = [Vector2(0.5,0.5), Vector2(circle_uv[i].x, circle_uv[i].z), 
		          Vector2(circle_uv[i+1].x, circle_uv[i+1].z)]
		
		add_tri([c, circle[i], circle[i+1]], uv)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(editor):
	editor.add_tree_range('Radius', radius)
	editor.add_tree_range('Segments', segments, 1, 3, 64)
	editor.add_tree_range('Slice', slice, 1, 0, 359)
	

