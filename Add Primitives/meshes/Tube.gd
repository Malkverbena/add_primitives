extends "../MeshBuilder.gd"

var height = 2.0
var outer_radius = 1.0
var inner_radius = 0.5
var sides = 16
var slice = 0
var generate_caps = true
var generate_ends = true

static func get_name():
	return "Tube"
	
func create(smooth, invert):
	var sa = PI * 2 - deg2rad(slice)
	
	var ic = build_circle_verts(Vector3(), sides, inner_radius, sa)
	var oc = build_circle_verts(Vector3(), sides, outer_radius, sa)
	
	var ofs = Vector3(0, height/2, 0)
	
	begin(VS.PRIMITIVE_TRIANGLES)
	
	set_invert(invert)
	add_smooth_group(false)
	
	if generate_caps:
		for idx in range(sides):
			add_quad([oc[idx + 1] + ofs, ic[idx + 1] + ofs, ic[idx] + ofs, oc[idx] + ofs])
			add_quad([oc[idx] - ofs, ic[idx] - ofs, ic[idx + 1] - ofs, oc[idx + 1] - ofs])
			
	if generate_ends and slice:
		add_quad([oc[0] + ofs, ic[0] + ofs, ic[0] - ofs, oc[0] - ofs])
		add_quad([ic[sides] + ofs, oc[sides] + ofs, oc[sides] - ofs, ic[sides] - ofs])
		
	add_smooth_group(smooth)
	
	for idx in range(sides):
		add_quad([oc[idx + 1] + ofs, oc[idx] + ofs, oc[idx] - ofs, oc[idx + 1] -ofs])
		add_quad([ic[idx] + ofs, ic[idx + 1] + ofs, ic[idx + 1] - ofs, ic[idx] -ofs])
		
	var mesh = commit()
	
	return mesh

func mesh_parameters(editor):
	editor.add_tree_range('Height', height)
	editor.add_tree_range('Outer Radius', outer_radius)
	editor.add_tree_range('Inner Radius', inner_radius)
	editor.add_tree_range('Sides', sides, 1, 1, 50)
	editor.add_tree_range('Slice', slice, 1, 0, 359)
	editor.add_tree_empty()
	editor.add_tree_check('Generate Caps', generate_caps)
	editor.add_tree_check('Generate Ends', generate_ends)
	

