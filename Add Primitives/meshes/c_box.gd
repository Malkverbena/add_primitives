extends "builder/mesh_builder.gd"

func build_mesh(params, smooth = false, reverse = false):
	if params == DEFAULT:
		params = [2, 1, 2, 0.5, 1]
		
	var cl = params[0]
	var cw = params[1]
	var sl = params[2]
	var sw = params[3]
	
	var h = Vector3(0,params[4],0)
	
	var v = [Vector3(sw,0,cw), Vector3(0,0,0), Vector3(0,0,sl), Vector3(sw,0, sl),
	         Vector3(cl-sw,0,sl), Vector3(cl,0,sl), Vector3(cl,0,0), Vector3(cl-sw,0,cw)]
	
	begin(VS.PRIMITIVE_TRIANGLES)
	add_smooth_group(smooth)
	
	#Caps
	add_quad([v[0], v[1], v[2], v[3]],[], reverse)
	add_quad([v[4], v[5], v[6], v[7]],[], reverse)
	add_quad([v[1], v[0], v[7], v[6]], [], reverse)
	add_quad([v[3]+h, v[2]+h, v[1]+h, v[0]+h],[], reverse)
	add_quad([v[7]+h, v[6]+h, v[5]+h, v[4]+h],[], reverse)
	add_quad([v[6]+h, v[7]+h, v[0]+h, v[1]+h], [], reverse)
	
	
	add_quad([v[1],v[1]+h,v[2]+h,v[2]],[],reverse)
	add_quad([v[2],v[2]+h,v[3]+h,v[3]],[],reverse)
	add_quad([v[3],v[3]+h,v[0]+h,v[0]],[],reverse)
	add_quad([v[0],v[0]+h,v[7]+h,v[7]],[],reverse)
	add_quad([v[7],v[7]+h,v[4]+h,v[4]],[],reverse)
	add_quad([v[4],v[4]+h,v[5]+h,v[5]],[],reverse)
	add_quad([v[5],v[5]+h,v[6]+h,v[6]],[],reverse)
	add_quad([v[6],v[6]+h,v[1]+h,v[1]],[],reverse)
	
	generate_normals()
	var mesh = commit()
	clear()
	
	return mesh
	
func mesh_parameters(parameters):
	add_tree_range(parameters, 'Center Length', 2, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Center Width', 1, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Side Length', 2, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Side Width', 0.5, 0.1, 0.1, 100)
	add_tree_range(parameters, 'Height', 1, 0.1, 0.1, 100)
	
func container():
	return "Extra Objects"
	