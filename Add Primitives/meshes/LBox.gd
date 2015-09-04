extends "builder/MeshBuilder.gd"

var front_length = 2.0
var front_width = 1.0
var side_length = 2.0
var side_width = 1.0
var height = 1.0

static func get_name():
	return "L Box"
	
static func get_container():
	return "Extra Objects"
	
func set_parameter(name, value):
	if name == 'front_length':
		front_length = value
		
	elif name == 'front_width':
		front_width = value
		
	elif name == 'side_length':
		side_length = value
		
	elif name == 'side_width':
		side_width = value
		
	elif name == 'height':
		height = value
		
func create(smooth, invert):
	var h = Vector3(0, height, 0)
	
	var v = [Vector3(0, 0, 0),
	         Vector3(front_width, 0, side_width),
	         Vector3(front_width, 0, front_length),
	         Vector3(0, 0, front_length),
	         Vector3(side_length, 0, 0),
	         Vector3(side_length, 0, side_width),
	         Vector3(front_width, 0, side_width)]
	
	var uv = [Vector2(), Vector2(front_width, side_width),
	          Vector2(front_width, front_length), Vector2(0, front_length),
	          Vector2(side_length, 0), Vector2(side_length, side_width),
	          Vector2(front_width, side_width)]
	
	var t = Vector2()
	var b = Vector2(0, height)
	var w = Vector2()
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	add_smooth_group(smooth)
	
	add_quad([v[0]+h, v[1]+h, v[2]+h, v[3]+h], [uv[0], uv[1], uv[2], uv[3]])
	add_quad([v[0]+h, v[4]+h, v[5]+h, v[6]+h], [uv[0], uv[4], uv[5], uv[6]])
	
	if h.y:
		add_quad([v[3], v[2], v[1], v[0]], [uv[3], uv[2], uv[1], uv[0]])
		add_quad([v[1], v[5], v[4], v[0]], [uv[1], uv[5], uv[4], uv[0]])
		
		var idx = [0, 3, 2, 1, 5, 4, 0]
		
		for i in range(idx.size() - 1):
			var v1 = v[idx[i]]
			var v2 = v[idx[i+1]]
			
			w.x = v1.distance_to(v2)
			
			add_quad([v1, v1+h, v2+h, v2], [b, t, t+w, b+w])
			
			t.x = w.x
			b.x = w.x
			
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Front Length', front_length)
	add_tree_range(tree, 'Front Width', front_width)
	add_tree_range(tree, 'Side Length', side_length)
	add_tree_range(tree, 'Side Width', side_width)
	add_tree_range(tree, 'Height', height, 0.01, 0, 100)
	

