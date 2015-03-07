extends 'builder/mesh_builder.gd'

func build_circle_verts(pos, segments, radius = 1, rotation = null):
	var radians_circle = PI * 2
	var _radius = Vector3(radius, 1, radius)
	
	var circle_verts = []
	
	for i in range(segments):
		var angle = radians_circle * i/segments
		var x = cos(angle)
		var z = sin(angle)
		
		var vector = Vector3(x, 0, z)
		
		circle_verts.append((vector * _radius) + pos)
	
	return circle_verts
	
func build_mesh(params, smooth = false, reverse = false):
	if params == 'default':
		params = [1, 16, 8]
		
	var angle_inc = PI/params[2]
	var caps_center = Vector3(0,-params[0],0)
	
	var circle = build_circle_verts(Vector3(0,0,0), params[1], params[0])
	
	var radius = Vector3(sin(angle_inc), 0, sin(angle_inc))
	var pos
	
	begin(4)
	add_smooth_group(smooth)
	
	for idx in range(params[1] - 1):
		pos = Vector3(0,-cos(angle_inc),0) * params[0]
		add_tri([(circle[idx + 1] * radius) + pos, (circle[idx] * radius) + pos, caps_center], null, reverse)
		
		pos = Vector3(0,-cos(angle_inc * (params[2] - 1)),0) * params[0]
		add_tri([ -caps_center, (circle[idx] * radius) + pos, (circle[idx + 1] * radius + pos)], null, reverse)
	
	pos = Vector3(0,-cos(angle_inc),0) * params[0]
	add_tri([(circle[0] * radius) + pos, (circle[params[1] - 1] * radius) + pos, caps_center], null, reverse)
	
	pos = Vector3(0,-cos(angle_inc * (params[2] - 1)),0) * params[0]
	add_tri([-caps_center, (circle[params[1] - 1] * radius) + pos, (circle[0] * radius) + pos], null, reverse)
	
	pos = Vector3(0,-cos(angle_inc),0) * params[0]
	for i in range(params[2] - 2):
		radius = Vector3(sin(angle_inc * (i + 1)), 0, sin(angle_inc * (i + 1)))
		var next_radius = Vector3(sin(angle_inc * (i + 2)), 0, sin(angle_inc * (i + 2)))
		
		var next_pos = Vector3(0,-cos(angle_inc * (i + 2)), 0) * params[0]
		for idx in range(params[1] - 1):
			
			add_quad([(circle[idx + 1] * radius) + pos,\
			          (circle[idx + 1] * next_radius) + next_pos,\
			          (circle[idx] * next_radius) + next_pos,\
			          (circle[idx] * radius) + pos], null, reverse)
			
		add_quad([(circle[0] * radius) + pos,\
		          (circle[0] * next_radius) + next_pos,\
		          (circle[params[1] - 1] * next_radius) + next_pos,\
		          (circle[params[1] - 1] * radius) + pos], null, reverse)
		
		pos = next_pos
	
	generate_normals()
	var mesh = commit()
	clear()
	
	return mesh
	
func add_tree_range(tree_item, text, value, _min = 1, _max = 100, step = 1):
	tree_item.set_text(0, text)
	tree_item.set_cell_mode(1, 2)
	tree_item.set_range(1, value)
	tree_item.set_range_config(1, _min, _max, step)
	tree_item.set_editable(1, true)
	
func mesh_parameters(settings, name = 'Add Mesh'):
		var parameters = []
		parameters.append(settings.create_item())
		parameters[0].set_text(0, 'Sphere')
		parameters.append(settings.create_item(parameters[0]))
		add_tree_range(parameters[1], 'Radius', 1, 0.1, 100, 0.1)
		parameters.append(settings.create_item(parameters[0]))
		add_tree_range(parameters[2], 'Segments', 16, 3)
		parameters.append(settings.create_item(parameters[0]))
		add_tree_range(parameters[3], 'Cuts', 8, 3)
	
