extends "builder/mesh_builder.gd"

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
		params = [1, 2, 16]
	var center_top = Vector3(0, params[1] * 0.5, 0)
	var min_pos = Vector3(0, params[1] * -0.5, 0)
	
	var circle = build_circle_verts(min_pos, params[2], params[0])
	var circle_uv = build_circle_verts(min_pos, params[2], 1)
	
	var uv_coords
	
	begin(4)
	
	add_smooth_group(smooth)
	for idx in range(params[2] - 1):
		uv_coords = [Vector2(0.25, 0.5),\
			         Vector2(0.25 + (circle_uv[idx].x * 0.25), 0.5 + (circle_uv[idx].z * 0.25)),\
			         Vector2(0.25 + (circle_uv[idx + 1].x * 0.25), 0.5 + (circle_uv[idx + 1].z * 0.25))]
			
		add_tri([center_top, circle[idx], circle[idx + 1]], uv_coords, reverse)
		
	uv_coords = [Vector2(0.25, 0.5),\
			     Vector2(0.25 + (circle_uv[params[2] - 1].x * 0.25), 0.5 + (circle_uv[params[2] - 1].z * 0.25)),\
			     Vector2(0.25 + (circle_uv[0].x * 0.25), 0.5 + (circle_uv[0].z * 0.25))]
			
	add_tri([center_top, circle[params[2] - 1], circle[0]], uv_coords, reverse)
	
	add_smooth_group(false)
	for idx in range(params[2] - 1):
		uv_coords = [Vector2(0.75 + (circle_uv[idx + 1].x * 0.25), 0.5 + (circle_uv[idx + 1].z * 0.25)),\
		             Vector2(0.75 + (circle_uv[idx].x * 0.25), 0.5 + (circle_uv[idx].z * 0.25)),\
		             Vector2(0.75, 0.5)]
		add_tri([circle[idx + 1], circle[idx], min_pos], uv_coords, reverse)
		
	uv_coords = [Vector2(0.75 + (circle_uv[0].x * 0.25), 0.5 + (circle_uv[0].z * 0.25)),\
	             Vector2(0.75 + (circle_uv[params[2] - 1].x * 0.25), 0.5 + (circle_uv[params[2] - 1].z * 0.25)),\
	             Vector2(0.75, 0.5)]
	             
	add_tri([circle[0], circle[params[2] - 1], min_pos], uv_coords, reverse)
	
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
	parameters[0].set_text(0, name)
	parameters.append(settings.create_item(parameters[0]))
	add_tree_range(parameters[1], 'Radius', 1, 0.1, 100, 0.1)
	parameters.append(settings.create_item(parameters[0]))
	add_tree_range(parameters[2], 'Heigth', 2, 0.1, 100, 0.1)
	parameters.append(settings.create_item(parameters[0]))
	add_tree_range(parameters[3], 'Segments', 16, 3)