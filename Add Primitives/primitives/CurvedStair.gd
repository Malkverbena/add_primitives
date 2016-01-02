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
	
	var ic = Utils.build_circle(Vector3(), steps, inner_radius, 0, radians)
	var oc = Utils.build_circle(Vector3(), steps, outer_radius, 0, radians)
	
	begin()
	
	add_smooth_group(smooth)
	
	for i in range(steps):
		var sh = Vector3(0, (i + 1) * height_inc, 0)
		
		var uv = [
		    Vector2(ic[i].x, ic[i].z),
		    Vector2(oc[i].x, oc[i].z),
		    Vector2(oc[i + 1].x, oc[i + 1].z),
		    Vector2(ic[i + 1].x, ic[i + 1].z)
		]
		
		add_quad([ic[i] + sh, oc[i] + sh, oc[i + 1] + sh, ic[i + 1] + sh], uv)
		
		if generate_bottom:
			if not flip_normals:
				uv.invert()
				
			add_quad([ic[i + 1], oc[i + 1], oc[i], ic[i]], uv)
			
		var base = Vector3(0, height_inc * i, 0)
		
		uv[0] = Vector2(0, base.y)
		uv[1] = Vector2(0, sh.y)
		uv[2] = Vector2(step_width, sh.y)
		uv[3] = Vector2(step_width, base.y)
		
		add_quad([oc[i] + base, oc[i] + sh, ic[i] + sh, ic[i] + base], uv)
		
		if generate_sides:
			var u1 = float(i)/steps
			var u2 = float(i + 1)/steps
			
			uv[0] = Vector2(u1 * uv_outer, sh.y)
			uv[1] = Vector2(u1 * uv_outer, 0)
			uv[2] = Vector2(u2 * uv_outer, 0)
			uv[3] = Vector2(u2 * uv_outer, sh.y)
			
			add_quad([oc[i] + sh, oc[i], oc[i + 1], oc[i + 1] + sh], uv)
			
			uv[0] = Vector2(u2 * uv_inner, sh.y)
			uv[1] = Vector2(u2 * uv_inner, 0)
			uv[2] = Vector2(u1 * uv_inner, 0)
			uv[3] = Vector2(u1 * uv_inner, sh.y)
			
			add_quad([ic[i + 1] + sh, ic[i + 1], ic[i], ic[i] + sh], uv)
			
	if generate_end:
		var sh = Vector3(0, stair_height, 0)
		
		var uv = [Vector2(),
		          Vector2(0, sh.y),
		          Vector2(step_width, sh.y),
		          Vector2(step_width, 0)]
		
		add_quad([ic[steps], ic[steps] + sh, oc[steps] + sh, oc[steps]], uv)
		
	commit()
	
func mesh_parameters(editor):
	editor.add_numeric_parameter('angle', angle, 1, 360, 1)
	editor.add_numeric_parameter('stair_height', stair_height)
	editor.add_numeric_parameter('steps', steps, 3, 64, 1)
	editor.add_numeric_parameter('inner_radius', inner_radius)
	editor.add_numeric_parameter('step_width', step_width)
	editor.add_empty()
	editor.add_bool_parameter('generate_sides', generate_sides)
	editor.add_bool_parameter('generate_bottom', generate_bottom)
	editor.add_bool_parameter('generate_end', generate_end)
	

