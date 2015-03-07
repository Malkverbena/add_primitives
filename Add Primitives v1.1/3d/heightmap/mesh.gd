extends SurfaceTool

func build_mesh(heightmap, size, res, factor):
	var origin = Vector3(-size/2, 0, -size/2)
	var res_size = float(size)/res
	
	var image
	
	if heightmap:
		image = heightmap.get_data()
	else:
		image = null
	
	begin(4)
	add_smooth_group(true)
	
	for i in range(res):
		for j in range(res):
			var vertex_height = []
			if image != null:
				vertex_height += [image.get_pixel((image.get_width() - 1) * float(i)/res,\
				                                  (image.get_height() -1) * float(j)/res).gray()]
				vertex_height += [image.get_pixel((image.get_width() - 1) * float(i+1)/res,\
				                                  (image.get_height() -1) * float(j)/res).gray()]
				vertex_height += [image.get_pixel((image.get_width() - 1) * float(i+1)/res,\
				                                  (image.get_height() -1) * float(j+1)/res).gray()]
				vertex_height += [image.get_pixel((image.get_width() - 1) * float(i)/res,\
				                                  (image.get_height() -1) * float(j+1)/res).gray()]
			else:
				vertex_height = [0,0,0,0]
				
				
			add_uv(Vector2(0 + i, 0 + j)/res)
			add_vertex(Vector3(i * res_size, vertex_height[0] * factor, j * res_size) + origin)
			add_uv(Vector2(1 + i, 0 + j)/res)
			add_vertex(Vector3((i+1) * res_size, vertex_height[1] * factor, j * res_size) + origin)
			add_uv(Vector2(1 + i, 1 + j)/res)
			add_vertex(Vector3((i+1) * res_size, vertex_height[2] * factor, (j+1) * res_size) + origin)
			
			add_uv(Vector2(0 + i, 0 + j)/res)
			add_vertex(Vector3(i * res_size, vertex_height[0] * factor, j * res_size) + origin)
			add_uv(Vector2(1 + i, 1 + j)/res)
			add_vertex(Vector3((i+1) * res_size, vertex_height[2] * factor, (j+1) * res_size) + origin)
			add_uv(Vector2(0 + i, 1 + j)/res)
			add_vertex(Vector3(i * res_size, vertex_height[3] * factor, (j+1) * res_size) + origin)
			
	generate_normals()
	var mesh = commit()
	clear()
	
	return mesh