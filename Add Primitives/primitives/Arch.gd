extends "../Primitive.gd"

var inner_width = 0.8
var inner_height = 1.0
var base_width = 0.2
var top_height = 0.2
var depth = 2.0
var radial_segments = 16
var generate_front = true
var generate_back = true
var generate_outer = true
var generate_bottom = true

static func get_name():
	return "Arch"
	
static func get_container():
	return "Extra Objects"
	
static func build_arch(pos, segments, inner, outer, inner_circle, outer_circle):
	var hpi = PI/2
	
	var angle_inc = PI/segments
	
	inner_circle.resize(segments + 1)
	outer_circle.resize(segments + 1)
	
	for i in range(segments + 1):
		var a = angle_inc * i - hpi
		
		inner_circle[i] = Vector3(sin(a) * inner.width, cos(a) * inner.height, pos)
		outer_circle[i] = Vector3(sin(a) * outer.width, cos(a) * outer.height, pos)
		
func update():
	var outer_width = inner_width + base_width
	var outer_height = inner_height + top_height
	
	var inner_inc = (pow(PI, 2) * inner_width)/PI/radial_segments
	var outer_inc = (pow(PI, 2) * outer_width)/PI/radial_segments
	
	var ofs = Vector3(0, 0, -depth)
	
	var ic = []
	var oc = []
	
	build_arch(depth/2, radial_segments, Vector2(inner_width, inner_height), Vector2(outer_width, outer_height), ic, oc)
	
	begin()
	
	add_smooth_group(false)
	
	if generate_front or generate_back:
		for i in range(radial_segments):
			var uv = [
				Vector2(ic[i].x, ic[i].y),
				Vector2(oc[i].x, oc[i].y),
				Vector2(oc[i + 1].x, oc[i + 1].y),
				Vector2(ic[i + 1].x, ic[i + 1].y)
			]
			
			if generate_front:
				add_quad([ic[i], oc[i], oc[i + 1], ic[i + 1]], uv)
				
			if generate_back:
				if not flip_normals:
					uv.invert()
					
				add_quad([ic[i + 1] + ofs, oc[i + 1] + ofs, oc[i] + ofs, ic[i] + ofs], uv)
				
	if generate_bottom:
		var uv = [
			Vector2(),
			Vector2(0, ofs.z),
			Vector2(base_width, ofs.z),
			Vector2(base_width, 0)
		]
		
		add_quad([ic[0], ic[0] + ofs, oc[0] + ofs, oc[0]], uv)
		
		if not flip_normals:
			uv.invert()
			
		add_quad([oc[radial_segments], oc[radial_segments] + ofs,
		          ic[radial_segments] + ofs, ic[radial_segments]], uv)
		
	add_smooth_group(smooth)
	
	for i in range(radial_segments):
		var uv = [
			Vector2(inner_inc * i, 0),
			Vector2(inner_inc * (i + 1), 0),
			Vector2(inner_inc * (i + 1), ofs.z),
			Vector2(inner_inc * i, ofs.z)
		]
		
		add_quad([ic[i], ic[i + 1], ic[i + 1] + ofs, ic[i] + ofs], uv)
		
		if generate_outer:
			uv[0].x = outer_inc * (i + 1)
			uv[1].x = outer_inc * i
			uv[2].x = outer_inc * i
			uv[3].x = outer_inc * (i + 1)
			
			add_quad([oc[i + 1], oc[i], oc[i] + ofs, oc[i + 1] + ofs], uv)
			
	commit()
	
func mesh_parameters(editor):
	editor.add_numeric_parameter('inner_width', inner_width)
	editor.add_numeric_parameter('inner_height', inner_height)
	editor.add_numeric_parameter('base_width', base_width)
	editor.add_numeric_parameter('top_height', top_height)
	editor.add_numeric_parameter('depth', depth)
	editor.add_numeric_parameter('radial_segments', radial_segments, 3, 64, 1)
	editor.add_empty()
	editor.add_bool_parameter('generate_front', generate_front)
	editor.add_bool_parameter('generate_back', generate_back)
	editor.add_bool_parameter('generate_outer', generate_outer)
	editor.add_bool_parameter('generate_bottom', generate_bottom)
	
	

