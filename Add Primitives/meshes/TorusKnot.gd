extends "../Primitive.gd"

var segments = 16
var section_segments = 8
var radius = 1.0
var section_radius = 0.2
var p = 2
var q = 3

static func get_name():
	return "Torus Knot"
	
static func get_container():
	return "Extra Objects"
	
static func m3_from_dir(dir):
	var z = dir.normalized()
	
	var x = Vector3(0, 1, 0).cross(z)
	x = x.normalized()
	
	var y = z.cross(x)
	y = y.normalized()
	
	var m3 = Matrix3(x, y, z)
	
	return m3
	
func create():
	var v = []
	var index = 0
	
	begin()
	
	add_smooth_group(smooth)
	
	for i in range(segments * p):
		var phi = (PI * 2) * i / segments
		
		var x = radius * (2 + cos(q * phi / p)) * cos(phi) / 3
		var y = radius * sin(q * phi / p) / 3
		var z = radius * (2 + cos(q * phi / p)) * sin(phi) / 3
		
		var v1 = Vector3(x, y, z)
		
		phi = (PI * 2) * (i + 1) / segments
		
		x = radius * (2 + cos(q * phi / p)) * cos(phi) / 3
		y = radius * sin(q * phi / p) / 3
		z = radius * (2 + cos(q * phi / p)) * sin(phi) / 3
		
		var v2 = Vector3(x, y, z)
		
		var dir = (v2 - v1).normalized()
		
		var m3 = m3_from_dir(dir)
		
		for j in range(section_segments):
			var alpha = (PI * 2) * j / section_segments
			var vp = section_radius * m3.xform(Vector3(cos(alpha), sin(alpha), 0))
			
			v.push_back(v1 + vp)
			
			if i != segments * p and (i > 0 and j > 0):
				var idx = index - 1
				
				add_quad([v[idx], v[idx + 1], v[idx - section_segments + 1], v[idx - section_segments]])
				
			index += 1
			
		if i:
			var idx = index - 1
			
			add_quad([v[idx], v[idx - section_segments + 1],\
			          v[idx + 1 - (section_segments * 2)], v[idx - section_segments]])
			
	var b = v.size() - section_segments
	
	for i in range(section_segments - 1):
		var j = b + i
		
		add_quad([v[i], v[i + 1], v[j + 1], v[j]])
		
	add_quad([v[b], v[b + section_segments - 1], v[section_segments - 1], v[0]])
	
	commit()
	
func mesh_parameters(editor):
	editor.add_tree_range('Segments', segments, 1, 3, 64)
	editor.add_tree_range('Section Segments', section_segments, 1, 3, 64)
	editor.add_tree_range('Radius', radius, 0.01, 0.01, 100)
	editor.add_tree_range('Section Radius', section_radius, 0.01, 0.01, 100)
	editor.add_tree_range('P', p, 1, 1, 8)
	editor.add_tree_range('Q', q, 1, 1, 8)
	
