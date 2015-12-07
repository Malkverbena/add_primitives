extends "../Primitive.gd"

var spirals = 1
var spiral_height = 2.0
var steps_per_spiral = 8
var inner_radius = 1.0
var step_width = 1.0
var extra_step_height = 0.0

static func get_name():
	return "Spiral Stair"
	
static func get_container():
	return "Stair"
	
func update():
	var outer_radius = inner_radius + step_width
	
	var c1 = Utils.build_circle_verts(Vector3(), steps_per_spiral, inner_radius)
	var c2 = Utils.build_circle_verts(Vector3(), steps_per_spiral, outer_radius)
	
	var height_inc = spiral_height/steps_per_spiral
	
	begin()
	
	add_smooth_group(smooth)
	
	for sp in range(spirals):
		var ofs = Vector3(0, spiral_height * sp, 0)
		
		for i in range(steps_per_spiral):
			var h = Vector3(0, i * height_inc, 0) + ofs
			
			var uv = [Vector2(c1[i+1].x, c1[i+1].z),
			          Vector2(c2[i+1].x, c2[i+1].z),
			          Vector2(c2[i].x, c2[i].z),
			          Vector2(c1[i].x, c1[i].z)]
			
			add_quad([c1[i+1] + h, c2[i+1] + h, c2[i] + h, c1[i] + h], uv)
			
			var sh = Vector3(0, h.y + height_inc + extra_step_height, 0)
			
			uv.invert()
			
			add_quad([c1[i] + sh, c2[i] + sh, c2[i+1] + sh, c1[i+1] + sh], uv)
			
			var sides = [c1[i], c2[i], c2[i+1], c1[i+1], c1[i]]
			
			var t = Vector2(0, h.y)
			var b = Vector2(0, sh.y)
			
			for i in range(sides.size() - 1):
				var w = Vector2(sides[i].distance_to(sides[i+1]), 0)
				
				add_quad([sides[i] + sh, sides[i] + h, sides[i+1] + h, sides[i+1] + sh], [t, b, b + w, t + w])
				
				t.x += w.x
				b.x += w.x
				
	commit()
	
func mesh_parameters(editor):
	editor.add_numeric_parameter('spirals', spirals, 1, 64, 1)
	editor.add_numeric_parameter('spiral_height', spiral_height)
	editor.add_numeric_parameter('steps_per_spiral', steps_per_spiral, 3, 64, 1)
	editor.add_numeric_parameter('inner_radius', inner_radius)
	editor.add_numeric_parameter('step_width', step_width)
	editor.add_numeric_parameter('extra_step_height', extra_step_height)
	

