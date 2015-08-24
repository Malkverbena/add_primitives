extends "builder/MeshBuilder.gd"

static func get_name():
	return "Arch"
	
func build_mesh(params, smooth = false, reverse = false):
	var r = params[0]    #Radius
	var l = params[1]    #Length
	var s = params[2]    #Segments
	var fill_bottom = params[3]
	
	var angle_inc = PI/s
	var radius = Vector3(1, r, r)
	
	var next_pos = Vector3(0, 0, l) * -1
	var m3 = Matrix3(Vector3(0,1,0), PI/2)
	
	var uv
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	add_smooth_group(smooth)
	
	for i in range(s):
		i = float(i)
		
		var vector = m3.xform(Vector3(l/2, sin(angle_inc*i), cos(angle_inc*i)) * radius)
		var vector_2 = m3.xform(Vector3(l/2, sin(angle_inc*(i+1)), cos(angle_inc*(i+1))) * radius)
		
		uv = [Vector2((i+1)/s, 0), Vector2((i+1)/s, 1), Vector2(i/s, 1), Vector2(i/s, 0)]
		add_quad([vector_2, vector_2 + next_pos, vector + next_pos, vector], uv, reverse)
		
	add_smooth_group(false)
		
	if fill_bottom:
		uv = [Vector2(1, 1), Vector2(0, 1), Vector2(0, 0), Vector2(1, 0)]
		add_quad(build_plane_verts(Vector3(0, 0, l), Vector3(r*2, 0, 0), Vector3(r, 0, l/2) * -1), uv, reverse)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, 'Radius', 1, 0.1, 0.1, 100)
	add_tree_range(tree, 'Length', 2, 0.1, 0.1, 100)
	add_tree_range(tree, 'Segments', 16, 1, 2, 50)
	add_tree_empty(tree)
	add_tree_check(tree, 'Fill Bottom', true)
	
func container():
	return 'Extra Objects'
	
