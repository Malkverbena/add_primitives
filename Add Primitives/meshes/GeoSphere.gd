extends "../Primitive.gd"

const Solid = {
	OCTAHEDRON = 0,
	ICOSAHEDRON = 1
}

var solid = Solid.OCTAHEDRON
var radius = 1.0
var subdivisions = 2

static func get_name():
	return "GeoSphere"
	
static func get_middle_point(p1, p2, verts, radius):
	var v1 = verts[p1]
	var v2 = verts[p2]
	
	var middle = (v1 + v2)/2
	
	var i = verts.size()
	
	verts.push_back(middle.normalized() * radius)
	
	return i
	
static func create_octahedron(verts, radius):
	verts.resize(6)
	
	verts[0] = Vector3(0,-1,0) * radius
	verts[1] = Vector3(1,0,0) * radius
	verts[2] = Vector3(0,0,1) * radius
	verts[3] = Vector3(-1,0,0) * radius
	verts[4] = Vector3(0,0,-1) * radius
	verts[5] = Vector3(0,1,0) * radius
	
	var faces = [2, 1, 0,
	             3, 2, 0,
	             4, 3, 0,
	             1, 4, 0,
	             1, 2, 5,
	             2, 3, 5,
	             3, 4, 5,
	             4, 1, 5]
	
	return faces
	
static func create_icosahedron(verts, radius):
	var t = (1.0 + sqrt(5))/2
	
	verts.resize(12)
	
	verts[0] = Vector3(-1,  t,  0).normalized() * radius
	verts[1] = Vector3( 1,  t,  0).normalized() * radius
	verts[2] = Vector3(-1, -t,  0).normalized() * radius
	verts[3] = Vector3( 1, -t,  0).normalized() * radius
	verts[4] = Vector3( 0, -1,  t).normalized() * radius
	verts[5] = Vector3( 0,  1,  t).normalized() * radius
	verts[6] = Vector3( 0, -1, -t).normalized() * radius
	verts[7] = Vector3( 0,  1, -t).normalized() * radius
	verts[8] = Vector3( t,  0, -1).normalized() * radius
	verts[9] = Vector3( t,  0,  1).normalized() * radius
	verts[10] = Vector3(-t,  0, -1).normalized() * radius
	verts[11] = Vector3(-t,  0,  1).normalized() * radius
	
	var faces = [5, 11, 0,
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
	
	return faces
	
func create():
	var v = []
	var faces
	
	if solid == Solid.OCTAHEDRON:
		faces = create_octahedron(v, radius)
		
	elif solid == Solid.ICOSAHEDRON:
		faces = create_icosahedron(v, radius)
		
	var last = false
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(smooth)
	
	for i in range(subdivisions):
		last = i == subdivisions - 1
		
		var tri2 = []
		
		for idx in range(0, faces.size(), 3):
			var a = get_middle_point(faces[idx], faces[idx+1], v, radius)
			var b = get_middle_point(faces[idx+1], faces[idx+2], v, radius)
			var c = get_middle_point(faces[idx+2], faces[idx], v, radius)
			
			if last:
				add_tri([v[faces[idx]], v[a], v[c]])
				add_tri([v[faces[idx+1]], v[b], v[a]])
				add_tri([v[faces[idx+2]], v[c], v[b]])
				add_tri([v[a], v[b], v[c]])
				
				continue
				
			tri2 += [faces[idx], a, c,
			         faces[idx+1], b, a,
			         faces[idx+2], c, b,
			         a, b, c]
			
		if last:
			break
			
		faces = tri2
		
	# Subdivisions is 0
	if not last:
		for i in range(0, faces.size(), 3):
			add_tri([v[faces[i]], v[faces[i+1]], v[faces[i+2]]])
			
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(editor):
	editor.add_tree_combo('Solid', solid, 'Octahedron,Icosahedron')
	editor.add_tree_range('Radius', radius)
	editor.add_tree_range('Subdivisions', subdivisions, 1, 0, 4)
	

