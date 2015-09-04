extends "builder/MeshBuilder.gd"

var angle = PI/2
var stair_height = 2.0
var steps = 8
var outer_radius = 2.0
var inner_radius = 1.0
var generate_bottom = true
var generate_end = true

static func get_name():
	return "Curved Stair"
	
static func get_container():
	return "Add Stair"
	
func set_parameter(name, value):
	if name == 'angle':
		angle = deg2rad(value)
		
	elif name == 'stair_height':
		stair_height = value
		
	elif name == 'steps':
		steps = value
		
	elif name == 'outer_radius':
		outer_radius = value
		
	elif name == 'inner_radius':
		inner_radius = value
		
	elif name == 'generate_bottom':
		generate_bottom = value
		
	elif name == 'generate_end':
		generate_end = value
		
func create(smooth, invert):
	var h = stair_height/steps
	
	var oc = angle * outer_radius
	var ic = angle * inner_radius
	
	var c = build_circle_verts(Vector3(), steps, inner_radius, angle)
	var c2 = build_circle_verts(Vector3(), steps, outer_radius, angle)
	
	var w = abs(outer_radius - inner_radius)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	add_smooth_group(smooth)
	
	for i in range(steps):
		var sh = Vector3(0, (i+1) * h, 0)
		
		var uv = [Vector2(c[i].x, c[i].z),
		          Vector2(c2[i].x, c2[i].z),
		          Vector2(c2[i+1].x, c2[i+1].z),
		          Vector2(c[i+1].x, c[i+1].z)]
		
		add_quad([c[i]+sh, c2[i]+sh, c2[i+1]+sh, c[i+1]+sh], uv)
		
		if generate_bottom:
			if not invert:
				uv.invert()
				
			add_quad([c[i+1], c2[i+1], c2[i], c[i]], uv)
			
		var base = Vector3(0, h, 0)
		
		uv[0] = Vector2(0, h * i)
		uv[1] = Vector2(0, sh.y)
		uv[2] = Vector2(w, sh.y)
		uv[3] = Vector2(w, h * i)
		
		add_quad([c2[i] + sh - base, c2[i] + sh, c[i] + sh, c[i] + sh - base], uv)
		
		base.y *= i + 1
		
		var u1 = float(i) / steps
		var u2 = float(i+1) / steps
		var v = sh.y
		
		uv[0] = Vector2(u1 * oc, v)
		uv[1] = Vector2(u1 * oc, 0)
		uv[2] = Vector2(u2 * oc, 0)
		uv[3] = Vector2(u2 * oc, v)
		
		add_quad([c2[i] + base, c2[i], c2[i+1], c2[i+1] + base], uv)
		
		uv[0] = Vector2(u2 * ic, v)
		uv[1] = Vector2(u2 * ic, 0)
		uv[2] = Vector2(u1 * ic, 0)
		uv[3] = Vector2(u1 * ic, v)
		
		add_quad([c[i+1] + base, c[i+1], c[i], c[i] + base], uv)
		
	if generate_end:
		var sh = Vector3(0, h * steps, 0)
		
		var uv = [Vector2(0, 0),
		          Vector2(0, sh.y),
		          Vector2(w, sh.y),
		          Vector2(w, 0)]
		
		add_quad([c[steps], c[steps] + sh, c2[steps] + sh, c2[steps]], uv)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Angle', rad2deg(angle), 1, 1, 360)
	add_tree_range(tree, 'Stair Height', stair_height)
	add_tree_range(tree, 'Steps', steps, 1, 2, 64)
	add_tree_range(tree, 'Outer Radius', outer_radius)
	add_tree_range(tree, 'Inner Radius', inner_radius)
	add_tree_empty(tree)
	add_tree_check(tree, 'Generate Bottom', generate_bottom)
	add_tree_check(tree, 'Generate End', generate_end)
	

