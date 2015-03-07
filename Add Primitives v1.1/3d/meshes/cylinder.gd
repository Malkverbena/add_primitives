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
		params = [1, 2, 16, 1]
	#cuts = 1 means no cut
	var circle = build_circle_verts(Vector3(0,float(params[1])/2,0), params[2], params[0])
	var circle_uv = build_circle_verts(Vector3(0,0,0), params[2], 1)
	var min_pos = Vector3(0,params[1] * -1,0)
	
	var uv_coords
	
	begin(4)
	
	add_smooth_group(false)
	for idx in range(params[2] - 1):
		uv_coords = [Vector2(0.25, 0.25),\
		             Vector2(0.25 + (circle_uv[idx].x * 0.25), 0.25 + (circle_uv[idx].z * 0.25)),\
		             Vector2(0.25 + (circle_uv[idx + 1].x * 0.25), 0.25 + (circle_uv[idx + 1].z * 0.25))]
		
		add_tri([Vector3(0,float(params[1])/2,0), circle[idx], circle[idx + 1]], uv_coords, reverse)
		
		uv_coords = [Vector2(0.75, 0.25),\
		             Vector2(0.75 + (circle_uv[idx].x * 0.25), 0.25 + (circle_uv[idx].z * 0.25)),\
		             Vector2(0.75 + (circle_uv[idx + 1].x * 0.25), 0.25 + (circle_uv[idx + 1].z * 0.25))]
		             
		add_tri([min_pos * 0.5, circle[idx + 1] + min_pos, circle[idx] + min_pos], uv_coords, reverse)
		
	uv_coords = [Vector2(0.25, 0.25),\
	             Vector2(0.25 + (circle_uv[0].x * 0.25), 0.25 + (circle_uv[0].z * 0.25)),\
	             Vector2(0.25 + (circle_uv[params[2] - 1].x * 0.25), 0.25 + (circle_uv[params[2] - 1].z * 0.25))]
	
	add_tri([Vector3(0,float(params[1])/2,0), circle[params[2] - 1], circle[0]], uv_coords, reverse)
	
	uv_coords = [Vector2(0.75, 0.25),\
	             Vector2(0.75 + (circle_uv[0].x * 0.25), 0.25 + (circle_uv[0].z * 0.25)),\
	             Vector2(0.75 + (circle_uv[params[2] - 1].x * 0.25), 0.25 + (circle_uv[params[2] - 1].z * 0.25))]
	
	add_tri([min_pos * 0.5, circle[0] + min_pos, circle[params[2] - 1] + min_pos], uv_coords, reverse)
	
	var next_cut = Vector3(0, float(params[1])/params[3], 0) + min_pos
	var uv_offset = Vector2(0, 0.5)
	
	add_smooth_group(smooth)
	
	for i in range(params[3]):
		for idx in range(params[2] - 1):
			uv_coords = [Vector2(float(idx+1)/params[2], (float(i)/params[3])/2)  + uv_offset,\
			             Vector2(float(idx+1)/params[2], (float(i+1)/params[3])/2) + uv_offset,\
			             Vector2(float(idx)/params[2], (float(i+1)/params[3])/2)  + uv_offset,\
			             Vector2(float(idx)/params[2], (float(i)/params[3])/2) + uv_offset]
			
			add_quad([circle[idx + 1] + min_pos, circle[idx + 1] + next_cut,\
			          circle[idx] + next_cut, circle[idx] + min_pos], uv_coords, reverse)
			
			
		uv_coords = [(Vector2(1.0, (float(i)/params[3])/2) + uv_offset),\
		             (Vector2(1.0, (float(i+1)/params[3])/2) + uv_offset),\
		             (Vector2(float(params[2] - 1)/params[2], (float(i+1)/params[3])/2) + uv_offset),\
		             (Vector2(float(params[2] - 1)/params[2], (float(i)/params[3])/2) + uv_offset)]
		             
		add_quad([circle[0] + min_pos, circle[0] + next_cut,\
		          circle[params[2] - 1] + next_cut, circle[params[2] - 1] + min_pos], uv_coords, reverse)
		
		
		min_pos = next_cut
		next_cut.y += float(params[1])/params[3]
		
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

func mesh_parameters(settings, name = "Add Mesh"):
	var parameters = []
	parameters.append(settings.create_item())
	parameters[0].set_text(0, name)
	parameters.append(settings.create_item(parameters[0]))
	add_tree_range(parameters[1], 'Radius', 1)
	parameters.append(settings.create_item(parameters[0]))
	add_tree_range(parameters[2], 'Heigth', 2)
	parameters.append(settings.create_item(parameters[0]))
	add_tree_range(parameters[3], 'Segments', 16)
	parameters.append(settings.create_item(parameters[0]))
	add_tree_range(parameters[4], 'Cuts', 1)