extends "../Primitive.gd"

var major_radius = 0.8
var minor_radius = 0.2
var torus_segments = 16
var segments = 8
var slice = 0
var generate_ends = true

static func get_name():
	return "Torus"
	
func update():
	var sa = PI * 2 - deg2rad(slice)
	var bend_radius = major_radius/sa
	
	var angle = sa/torus_segments
	
	var s = Utils.build_circle_verts(Vector3(), torus_segments, major_radius, sa)
	
	begin()
	
	add_smooth_group(smooth)
	
	var temp_circle
	
	var c1 = Utils.build_circle_verts_rot(s[0], segments, minor_radius, Matrix3(Vector3(1,0,0), PI/2))
	var c2 = []
	
	if not slice:
		c2.resize(segments + 1)
		
	for i in range(s.size() - 1):
		var m1 = Matrix3(Vector3(0,1,0), angle * i)
		
		if i < s.size() - 2 or slice:
			var m2 = Matrix3(Vector3(0,1,0), angle * (i+1))
			
			for idx in range(segments):
				add_quad([m1.xform(c1[idx]), m2.xform(c1[idx]), m2.xform(c1[idx + 1]), m1.xform(c1[idx + 1])])
				
		else:
			for idx in range(segments + 1):
				c2[idx] = m1.xform(c1[idx])
				
	if not slice:
		for idx in range(segments):
			add_quad([c2[idx], c1[idx], c1[idx + 1], c2[idx + 1]])
			
	elif generate_ends:
		var m = Matrix3(Vector3(0,1,0), sa)
		
		add_smooth_group(false)
		
		for idx in range(segments):
			add_tri([s[0], c1[idx], c1[idx+1]])
			add_tri([m.xform(c1[idx+1]), m.xform(c1[idx]), s[torus_segments]])
			
	commit()
	
func mesh_parameters(editor):
	editor.add_tree_range('Major Radius', major_radius)
	editor.add_tree_range('Minor Radius', minor_radius)
	editor.add_tree_range('Torus Segments', torus_segments, 3, 64, 1)
	editor.add_tree_range('Segments', segments, 3, 64, 1)
	editor.add_tree_range('Slice', slice, 0, 359, 1)
	editor.add_tree_empty()
	editor.add_tree_check('Generate Ends', generate_ends)
	

