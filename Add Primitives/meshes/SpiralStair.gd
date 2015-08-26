extends "builder/MeshBuilder.gd"

var spirals = 1
var height = 2.0
var steps = 8
var outer_radius = 2.0
var inner_radius = 1.0
var extra_height = 0.0

static func get_name():
	return "Spiral Stair"
	
static func get_container():
	return "Add Stair"
	
func set_parameter(name, value):
	if name == 'Spirals':
		spirals = value
		
	elif name == 'Spiral Height':
		height = value
		
	elif name == 'Steps per Spiral':
		steps = value
		
	elif name == 'Outer Radius':
		outer_radius = value
		
	elif name == 'Inner Radius':
		inner_radius = value
		
	elif name == 'Extra Step Height':
		extra_height = value
		
func build_mesh(smooth = false, reverse = false):
	var angle = (PI*2)/steps
	
	var or_ = Vector3(outer_radius, 1, outer_radius)
	var ir = Vector3(inner_radius, 1, inner_radius)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(smooth)
	
	for sp in range(spirals):
		var off = Vector3(0, height*sp, 0)
		
		var s = height/steps
		var h = Vector3(0,-(s + extra_height),0)
		
		for i in range(steps):
			var v = Vector3(cos(angle*i), (i+1)*s + extra_height, sin(angle*i)) + off
			var v2 = Vector3(cos(angle*(i+1)), (i+1)*s + extra_height, sin(angle*(i+1))) + off
			
			add_quad([v*ir, v*or_, v2*or_, v2*ir], [], reverse)
			add_quad([v*or_ + h, v*or_, v*ir, v*ir + h], [], reverse)
			add_quad([v2*or_ + h, v2*or_, v*or_, v*or_ + h], [], reverse)
			add_quad([v*ir + h, v*ir, v2*ir, v2*ir + h], [], reverse)
			add_quad([v2*ir + h, v2*ir, v2*or_, v2*or_ + h], [], reverse)
			
			v += h
			v2 += h
			
			add_quad([v2*ir, v2*or_, v*or_, v*ir], [], reverse)
			
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Spirals', 1, 1, 1, 64)
	add_tree_range(tree, 'Spiral Height', 2)
	add_tree_range(tree, 'Steps per Spiral', 8, 1, 3, 64)
	add_tree_range(tree, 'Outer Radius', 2)
	add_tree_range(tree, 'Inner Radius', 1)
	add_tree_range(tree, 'Extra Step Height', 0, 0.01, -100, 100)
	

