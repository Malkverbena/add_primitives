extends "../Primitive.gd"

var steps = 10
var width = 1.0
var height = 2.0
var length = 2.0
var generate_sides = true
var generate_bottom = true
var generate_end = true

static func get_name():
	return "Linear Stair"
	
static func get_container():
	return "Stair"
	
func create():
	var ofs_x = -width/2
	
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
	
	begin()
	
	add_smooth_group(smooth)
	
	for i in range(steps):
		add_quad(Utils.build_plane_verts(d[1], d[0], Vector3(ofs_x, (i+1) * sh, i * sl)),\
		         [py, py+w, py+w+l, py+l])
		add_quad(Utils.build_plane_verts(d[2], d[0], Vector3(ofs_x, i * sh, i * sl)),\
		         [pz, pz+w, pz+w+h, pz+h])
		
		if generate_sides:
			var ch = Vector2(0, sh * (i+1))
			
			add_quad(Utils.build_plane_verts(d[1], Vector3(0, ch.y, 0), Vector3(ofs_x, 0, i * sl)),\
			         [py, py+ch, py+ch+l, py+l])
			add_quad(Utils.build_plane_verts(Vector3(0, ch.y, 0), d[1], Vector3(-ofs_x, 0, i * sl)),\
			         [py, py+l, py+l+ch, py+ch])
			
		py.x += sl
		pz.x += sh
		
	if generate_end:
		add_plane(d[0], Vector3(0, height, 0), Vector3(ofs_x, 0, length))
		
	if generate_bottom:
		add_plane(d[0], Vector3(0, 0, length), Vector3(ofs_x, 0, 0))
		
	commit()
	
func mesh_parameters(editor):
	editor.add_tree_range('Steps', steps, 1, 2, 64)
	editor.add_tree_range('Width', width)
	editor.add_tree_range('Height', height)
	editor.add_tree_range('Length', length)
	editor.add_tree_empty()
	editor.add_tree_check('Generate Sides', generate_sides)
	editor.add_tree_check('Generate Bottom', generate_bottom)
	editor.add_tree_check('Generate End', generate_end)
	

