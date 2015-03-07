extends SurfaceTool

func add_tri(vertex_array, uv_array = null, reverse = false):
	if vertex_array.size() == 3:
		var face_index = [0,1,2]
		
		if reverse:
			face_index.invert()
		
		for idx in face_index:
			if uv_array != null:
				add_uv(uv_array[idx])
			add_vertex(vertex_array[idx])
			
func add_quad(vertex_array, uv_array = null, reverse = false):
	if vertex_array.size() == 4:
		var face_index = [0,1,2,0,2,3]
		
		if reverse:
			face_index.invert()
		
		for idx in face_index:
			if uv_array != null:
				add_uv(uv_array[idx])
			add_vertex(vertex_array[idx])