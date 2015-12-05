extends "../Primitive.gd"

var width = 2.0
var length = 2.0
var height = 2.0
var right_face = true
var left_face = true
var top_face = true
var bottom_face = true
var front_face = true
var back_face = true

static func get_name():
	return "Box"
	
func update():
	var fd = Vector3(width, 0, 0)
	var rd = Vector3(0, 0, length)
	var ud = Vector3(0, height, 0)
	
	var ofs = Vector3(width/2,height/2,length/2)
	
	begin()
	
	add_smooth_group(smooth)
	
	if right_face:
		add_plane(-rd, -ud, ofs)
		
	if left_face:
		add_plane(ud, rd, -ofs)
		
	if top_face:
		add_plane(-fd, -rd, ofs)
		
	if bottom_face:
		add_plane(rd, fd, -ofs)
		
	if front_face:
		add_plane(-ud, -fd, ofs)
		
	if back_face:
		add_plane(fd, ud, -ofs)
		
	commit()
	
func mesh_parameters(editor):
	editor.add_tree_range('Width', width)
	editor.add_tree_range('Length', length)
	editor.add_tree_range('Height', height)
	editor.add_tree_empty()
	editor.add_tree_check('Right Face', right_face)
	editor.add_tree_check('Left Face', left_face)
	editor.add_tree_check('Top Face', top_face)
	editor.add_tree_check('Bottom Face', bottom_face)
	editor.add_tree_check('Front Face', front_face)
	editor.add_tree_check('Back Face', back_face)
	

