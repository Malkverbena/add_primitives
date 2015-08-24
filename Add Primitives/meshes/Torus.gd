extends "builder/MeshBuilder.gd"

static func get_name():
	return "Torus"
	
func build_mesh(params, smooth = false, reverse = false):
	var torus_radius = params[0]
	var radius = params[1]
	var steps_ = params[2]
	var cuts = params[3]
	
	var bend_angle_radians = PI*2
	var bend_radius = torus_radius/bend_angle_radians
	
	var angle_inc = bend_angle_radians/steps_
	
	var steps = build_circle_verts(Vector3(0,0,0), steps_, torus_radius)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	add_smooth_group(smooth)
	
	var circle
	var circle_2
	var temp_circle
	
	for i in range(steps.size() - 2):
		circle = build_circle_verts_rot(steps[i], cuts, radius, [PI/2, angle_inc * i], [Vector3(1,0,0), Vector3(0,1,0)])
		circle_2 = build_circle_verts_rot(steps[i + 1], cuts, radius, [PI/2, angle_inc * (i+1)], [Vector3(1,0,0), Vector3(0,1,0)])
		if i == steps.size() - 3:
			temp_circle = circle_2
		
		for idx in range(cuts):
			add_quad([circle[idx], circle_2[idx], circle_2[idx + 1], circle[idx + 1]], [], reverse)
	
	circle = temp_circle
	circle_2 = build_circle_verts_rot(steps[0], cuts, radius, [PI/2, angle_inc * 0], [Vector3(1,0,0), Vector3(0,1,0)])
	
	for idx in range(cuts):
		add_quad([circle[idx], circle_2[idx], circle_2[idx + 1], circle[idx + 1]], [], reverse)
		
	var mesh = commit()
	
	return mesh
	
func mesh_parameters(tree):
	add_tree_range(tree, "Major Radius", 0.8, 0.1, 0.1, 100)
	add_tree_range(tree, "Minor Radius", 0.2, 0.1, 0.1, 100)
	add_tree_range(tree, "Steps", 16, 1, 3, 50)
	add_tree_range(tree, "Cuts", 8, 1, 3, 50)
	

