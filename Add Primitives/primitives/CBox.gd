extends "../Primitive.gd"

var center_length = 2
var center_width = 1
var side_length = 2
var side_width = 0.5
var height = 1

static func get_name():
	return "C Box"
	
static func get_container():
	return "Extra Objects"
	
func update():
	var h = Vector3(0, height, 0)
	
	var t = Vector2()
	var b = Vector2(0, height)
	var w = Vector2()
	
	var v = [Vector3(side_width, 0, center_width), Vector3(),
	         Vector3(0, 0, side_length), Vector3(side_width, 0, side_length),
	         Vector3(center_length-side_width, 0, side_length), Vector3(center_length, 0, side_length),
	         Vector3(center_length, 0, 0), Vector3(center_length-side_width, 0, center_width)]
	
	var uv = [Vector2(side_width, center_width), Vector2(),
	          Vector2(0, side_length), Vector2(side_width, side_length),
	          Vector2(center_length-side_width, side_length), Vector2(center_length, side_length),
	          Vector2(center_length, 0), Vector2(center_length-side_width, center_width)]
	
	begin()
	
	add_smooth_group(smooth)
	
	# Top
	add_quad([v[3] + h, v[2] + h, v[1] + h, v[0] + h], [uv[3], uv[2], uv[1], uv[0]])
	add_quad([v[7] + h, v[6] + h, v[5] + h, v[4] + h], [uv[7], uv[6], uv[5], uv[4]])
	add_quad([v[6] + h, v[7] + h, v[0] + h, v[1] + h], [uv[6], uv[7], uv[0], uv[1]])
	
	if h.y:
		# Bottom
		add_quad([v[0], v[1], v[2], v[3]], [uv[0], uv[1], uv[2], uv[3]])
		add_quad([v[4], v[5], v[6], v[7]], [uv[4], uv[5], uv[6], uv[7]])
		add_quad([v[1], v[0], v[7], v[6]], [uv[1], uv[0], uv[7], uv[6]])
		
		# Sides
		var idx = [1, 2, 3, 0, 7, 4, 5, 6, 1]
		
		for i in range(idx.size() - 1):
			w.x = v[idx[i+1]].distance_to(v[idx[i]])
			
			add_quad([v[idx[i]], v[idx[i]] + h, v[idx[i+1]] + h, v[idx[i+1]]], [t, b, b + w, t + w])
			
			t.x += w.x
			b.x += w.x
			
	commit()
	
func mesh_parameters(editor):
	editor.add_tree_range('Center Length', center_length)
	editor.add_tree_range('Center Width', center_width)
	editor.add_tree_range('Side Length', side_length)
	editor.add_tree_range('Side Width', side_width)
	editor.add_tree_range('Height', height, 0, 100)
	

