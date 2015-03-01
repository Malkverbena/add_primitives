extends "StaticMeshBuilder.gd"

func build_mesh():
	var verts = []
	verts.append(Vector3(0,0,0))
	verts.append(Vector3(1,0,0))
	verts.append(Vector3(1,0,1))
	verts.append(Vector3(0,0,1))
	
	begin(4)
	add_quad([verts[0], verts[2], verts[1], verts[3]], null, false)
	generate_normals()

	var mesh = commit()
	clear()

	return mesh
