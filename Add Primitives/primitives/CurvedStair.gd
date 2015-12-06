extends "../Primitive.gd"

var angle = 90
var stair_height = 2.0
var steps = 8
var inner_radius = 1.0
var step_width = 1.0
var generate_sides = true
var generate_bottom = true
var generate_end = true

static func get_name():
	return "Curved Stair"
	
static func get_container():
	return "Stair"
	
func update():
	var radians = deg2rad(angle)
	var height_inc = stair_height/steps
	var outer_radius = inner_radius + step_width
	
	var uv_inner = radians * inner_radius
	var uv_outer = radians * outer_radius
	
	var c = Utils.build_circle_verts(Vector3(), steps, inner_radius, radians)
	var c2 = Utils.build_circle_verts(Vector3(), steps, outer_radius, radians)
	
	begin()
	
	add_smooth_group(smooth)
	
	for i in range(steps):
		var sh = Vector3(0, (i+1) * height_inc, 0)
		
		var uv = [Vector2(c[i].x, c[i].z),
		          Vector2(c2[i].x, c2[i].z),
		          Vector2(c2[i+1].x, c2[i+1].z),
		          Vector2(c[i+1].x, c[i+1].z)]
		
		add_quad([c[i] + sh, c2[i] + sh, c2[i+1] + sh, c[i+1] + sh], uv)
		
		if generate_bottom:
			if not flip_normals:
				uv.invert()
				
			add_quad([c[i+1], c2[i+1], c2[i], c[i]], uv)
			
		var base = Vector3(0, height_inc * i, 0)
		
		uv[0] = Vector2(0, base.y)
		uv[1] = Vector2(0, sh.y)
		uv[2] = Vector2(step_width, sh.y)
		uv[3] = Vector2(step_width, base.y)
		
		add_quad([c2[i] + base, c2[i] + sh, c[i] + sh, c[i] + base], uv)
		
		if generate_sides:
			var u1 = i/steps
			var u2 = (i+1)/steps
			
			uv[0] = Vector2(u1 * uv_outer, sh.y)
			uv[1] = Vector2(u1 * uv_outer, 0)
			uv[2] = Vector2(u2 * uv_outer, 0)
			uv[3] = Vector2(u2 * uv_outer, sh.y)
			
			add_quad([c2[i] + sh, c2[i], c2[i+1], c2[i+1] + sh], uv)
			
			uv[0] = Vector2(u2 * uv_inner, sh.y)
			uv[1] = Vector2(u2 * uv_inner, 0)
			uv[2] = Vector2(u1 * uv_inner, 0)
			uv[3] = Vector2(u1 * uv_inner, sh.y)
			
			add_quad([c[i+1] + sh, c[i+1], c[i], c[i] + sh], uv)
			
	if generate_end:
		var sh = Vector3(0, stair_height, 0)
		
		var uv = [Vector2(),
		          Vector2(0, sh.y),
		          Vector2(step_width, sh.y),
		          Vector2(step_width, 0)]
		
		add_quad([c[steps], c[steps] + sh, c2[steps] + sh, c2[steps]], uv)
		
	commit()
	
func mesh_parameters(editor):
	editor.add_tree_range('Angle', angle, 1, 360, 1)
	editor.add_tree_range('Stair Height', stair_height)
	editor.add_tree_range('Steps', steps, 3, 64, 1)
	editor.add_tree_range('Inner Radius', inner_radius)
	editor.add_tree_range('Step Width', step_width)
	editor.add_tree_empty()
	editor.add_tree_check('Generate Sides', generate_sides)
	editor.add_tree_check('Generate Bottom', generate_bottom)
	editor.add_tree_check('Generate End', generate_end)
	

