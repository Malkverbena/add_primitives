extends "builder/MeshBuilder.gd"

var radius = 1.0
var subdivisions = 2

static func get_name():
	return "IcoSphere"
	
func set_parameter(name, value):
	if name == 'Radius':
		radius = value
		
	elif name == 'Subdivisions':
		subdivisions = value
		
static func get_middle_point(p1, p2, verts, radius):
	var v1 = verts[p1]
	var v2 = verts[p2]
	
	var middle = (v1 + v2)/2
	
	var i = verts.size()
	
	verts.push_back(middle.normalized() * radius)
	
	return i
	
func create(smooth = false, invert = false):
	var t = (1.0 + sqrt(5))/2
	
	var v = [Vector3(-1,  t,  0).normalized() * radius,
	         Vector3( 1,  t,  0).normalized() * radius,
	         Vector3(-1, -t,  0).normalized() * radius,
	         Vector3( 1, -t,  0).normalized() * radius,
	         Vector3( 0, -1,  t).normalized() * radius,
	         Vector3( 0,  1,  t).normalized() * radius,
	         Vector3( 0, -1, -t).normalized() * radius,
	         Vector3( 0,  1, -t).normalized() * radius,
	         Vector3( t,  0, -1).normalized() * radius,
	         Vector3( t,  0,  1).normalized() * radius,
	         Vector3(-t,  0, -1).normalized() * radius,
	         Vector3(-t,  0,  1).normalized() * radius]
	
	var tri = [5, 11, 0,
	           1, 5, 0,
	           7, 1, 0,
	           10, 7, 0,
	           11, 10, 0,
	           9, 5, 1,
	           4, 11, 5,
	           2, 10, 11,
	           6, 7, 10,
	           8, 1, 7,
	           4, 9, 3,
	           2, 4, 3,
	           6, 2, 3,
	           8, 6, 3,
	           9, 8, 3,
	           5, 9, 4,
	           11, 4, 2,
	           10, 2, 6,
	           7, 6, 8,
	           1, 8, 9]
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(smooth)
	
	var last = false
	
	for i in range(subdivisions):
		last = i == subdivisions - 1
		
		var tri2 = []
		
		for idx in range(0, tri.size(), 3):
			var a = get_middle_point(tri[idx], tri[idx+1], v, radius)
			var b = get_middle_point(tri[idx+1], tri[idx+2], v, radius)
			var c = get_middle_point(tri[idx+2], tri[idx], v, radius)
			
			if last:
				add_tri([v[tri[idx]], v[a], v[c]], [], invert)
				add_tri([v[tri[idx+1]], v[b], v[a]], [], invert)
				add_tri([v[tri[idx+2]], v[c], v[b]], [], invert)
				add_tri([v[a], v[b], v[c]], [], invert)
				
				continue
				
			tri2 += [tri[idx], a, c,
			         tri[idx+1], b, a,
			         tri[idx+2], c, b,
			         a, b, c]
			
		if last:
			break
			
		tri = tri2
		
	# subdivisions is 0
	if not last:
		for i in range(0, tri.size(), 3):
			add_tri([v[tri[i]], v[tri[i+1]], v[tri[i+2]]], [], invert)
			
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Radius', 1)
	add_tree_range(tree, 'Subdivisions', 2, 1, 0, 4)
	

