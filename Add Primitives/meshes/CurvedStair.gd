extends "builder/MeshBuilder.gd"

var angle = PI/2
var stair_height = 2.0
var steps = 8
var outer_radius = 2.0
var inner_radius = 1.0
var fill_bottom = true
var fill_end = true

static func get_name():
	return "Curved Stair"
	
static func get_container():
	return "Add Stair"
	
func set_parameter(name, value):
	if name == 'Angle':
		angle = deg2rad(value)
		
	elif name == 'Stair Height':
		stair_height = value
		
	elif name == 'Steps':
		steps = value
		
	elif name == 'Outer Radius':
		outer_radius = value
		
	elif name == 'Inner Radius':
		inner_radius = value
		
	elif name == 'Fill Bottom':
		fill_bottom = value
		
	elif name == 'Fill End':
		fill_end = value
		
func create(smooth = false, invert = false):
	var h = stair_height/steps
	var or_ = Vector3(outer_radius, 1, outer_radius)
	var ir = Vector3(inner_radius, 1, inner_radius)
	
	var angle_inc = angle/steps
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(smooth)
	
	for i in range(steps):
		var v = Vector3(cos(angle_inc*i), (i+1)*h, sin(angle_inc*i))
		var v2 = Vector3(cos(angle_inc*(i+1)), (i+1)*h, sin(angle_inc*(i+1)))
		
		var base = Vector3(0, -h, 0)
		
		add_quad([v*ir, v*or_, v2*or_, v2*ir], [], invert)
		add_quad([v*or_ + base, v*or_, v*ir, v*ir + base], [], invert)
		
		base.y *= i + 1
		
		add_quad([v2*or_ + base, v2*or_, v*or_, v*or_ + base], [], invert)
		add_quad([v*ir + base, v*ir, v2*ir, v2*ir + base], [], invert)
		
		if fill_bottom:
			v.y = 0
			v2.y = 0
			
			add_quad([v2*ir, v2*or_, v*or_, v*ir], [], invert)
			
	if fill_end:
		var i = steps
		
		var v = Vector3(cos(angle_inc*i), i*h, sin(angle_inc*i))
		var v2 = Vector3(cos(angle_inc*(i+1)), i*h, sin(angle_inc*(i+1)))
		
		add_quad([v*ir + Vector3(0,-h*i,0), v*ir, v*or_, v*or_ + Vector3(0,-h*i,0)], [], invert)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Angle', angle, 1, 1, 360)
	add_tree_range(tree, 'Stair Height', stair_height)
	add_tree_range(tree, 'Steps', steps, 1, 2, 64)
	add_tree_range(tree, 'Outer Radius', outer_radius)
	add_tree_range(tree, 'Inner Radius', inner_radius)
	add_tree_empty(tree)
	add_tree_check(tree, 'Fill Bottom', fill_bottom)
	add_tree_check(tree, 'Fill End', fill_end)
	

