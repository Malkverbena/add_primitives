extends "StaticMeshBuilder.gd"

func build_plane(start, end, offset = Vector3(0, 0, 0)):
	var verts = []
	verts.append(Vector3(0,0,0) + offset)
	verts.append(Vector3(0,0,0) + start + end + offset)
	verts.append(Vector3(0,0,0) + end + offset)
	verts.append(Vector3(0,0,0) + start + offset)

	return verts

func build_mesh():
	begin(4)
	for i in range(0 , 10):
		add_quad(build_plane(Vector3(5, 0, 0 ), Vector3(0, 0, 1 ), Vector3(0, float(i)/2 + 0.5, i * 1)), null, true)
		add_quad(build_plane(Vector3(5, 0, 0 ), Vector3(0,  float(-1)/2,  0), Vector3(0, float(i)/2 + 0.5, i * 1)))
		add_quad(build_plane(Vector3(0, 0, 1 ), Vector3(0,  float(-i)/2 - 0.5,  0), Vector3(0, float(i)/2 + 0.5, i * 1)), null, true)
		add_quad(build_plane(Vector3(0, 0, 1 ), Vector3(0,  float(-i)/2 - 0.5,  0), Vector3(5, float(i)/2 + 0.5, i * 1)))
	generate_normals()
	var mesh = commit()
	clear()
	
	return mesh
