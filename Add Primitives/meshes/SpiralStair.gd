extends "../MeshBuilder.gd"

var spirals = 1
var height = 2.0
var steps_per_spiral = 8
var outer_radius = 2.0
var inner_radius = 1.0
var extra_step_height = 0.0

static func get_name():
	return "Spiral Stair"
	
static func get_container():
	return "Add Stair"
	
func create(smooth, invert):
	var angle = (PI*2)/steps_per_spiral
	
	var or_ = Vector3(outer_radius, 1, outer_radius)
	var ir = Vector3(inner_radius, 1, inner_radius)
	
	var c = build_circle_verts(Vector3(), steps_per_spiral, inner_radius)
	var c2 = build_circle_verts(Vector3(), steps_per_spiral, outer_radius)
	
	var s = height/steps_per_spiral
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	add_smooth_group(smooth)
	
	for sp in range(spirals):
		var ofs = Vector3(0, height*sp, 0)
		
		for i in range(steps_per_spiral):
			var h = Vector3(0, i * s, 0) + ofs
			
			var uv = [Vector2(c[i+1].x, c[i+1].z),
			          Vector2(c2[i+1].x, c2[i+1].z),
			          Vector2(c2[i].x, c2[i].z),
			          Vector2(c[i].x, c[i].z)]
			
			add_quad([c[i+1] + h, c2[i+1] + h, c2[i] + h, c[i] + h], uv)
			
			var sh = Vector3(0, h.y + s + extra_step_height, 0)
			
			uv.invert()
			
			add_quad([c[i] + sh, c2[i] + sh, c2[i+1] + sh, c[i+1] + sh], uv)
			
			var sides = [c[i], c2[i], c2[i+1], c[i+1], c[i]]
			
			var t = Vector2(0, h.y)
			var b = Vector2(0, sh.y)
			var w = Vector2()
			
			for i in range(sides.size() - 1):
				w.x = sides[i].distance_to(sides[i+1])
				
				add_quad([sides[i] + sh, sides[i] + h, sides[i+1] + h, sides[i+1] + sh], [t, b, b+w, t+w])
				
				t.x += w.x
				b.x += w.x
				
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(editor):
	editor.add_tree_range('Spirals', spirals, 1, 1, 64)
	editor.add_tree_range('Spiral Height', height)
	editor.add_tree_range('Steps per Spiral', steps_per_spiral, 1, 3, 64)
	editor.add_tree_range('Outer Radius', outer_radius)
	editor.add_tree_range('Inner Radius', inner_radius)
	editor.add_tree_range('Extra Step Height', extra_step_height, 0.01, -100, 100)
	

