#==============================================================================#
# Copyright (c) 2015 Franklin Sobrinho.                                        #
#                                                                              #
# Permission is hereby granted, free of charge, to any person obtaining        #
# a copy of this software and associated documentation files (the "Software"), #
# to deal in the Software without restriction, including without               #
# limitation the rights to use, copy, modify, merge, publish,                  #
# distribute, sublicense, and/or sell copies of the Software, and to           #
# permit persons to whom the Software is furnished to do so, subject to        #
# the following conditions:                                                    #
#                                                                              #
# The above copyright notice and this permission notice shall be               #
# included in all copies or substantial portions of the Software.              #
#                                                                              #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,              #
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF           #
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.       #
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY         #
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,         #
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE            #
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                       #
#==============================================================================#

extends Reference

class MergeDialog extends AcceptDialog:
	
	var mesh
	var mesh_instance
	
	var tree
	
	func create_merge_options(surfaces):
		tree.clear()
		
		tree.set_hide_root(true)
		tree.set_columns(1)
		
		var root = tree.create_item()
		
		var icon = get_icon("MeshInstance", "EditorIcons")
		
		for s in surfaces:
			var item = tree.create_item(root)
			
			item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
			item.set_checked(0, true)
			item.set_text(0, s.get_name())
			item.set_icon(0, icon)
			item.set_editable(0, true)
			item.set_metadata(0, s.get_path())
			
	func edit(instance, instances = []):
		mesh_instance = instance
		
		mesh = Mesh.new()
		mesh.set_name("surfaces")
		
		mesh_instance.set_mesh(mesh)
		
		if mesh_instance == null:
			clear()
			
			return
			
		create_merge_options(instances)
		
		_merge_surfaces()
		
	func show_dialog():
		popup_centered(Vector2(300, 350))
		
	func clear():
		tree.clear()
		
	func _merge_surfaces():
		var surfaces = []
		
		var root = tree.get_root()
		
		var item = root.get_children()
		
		while item:
			if item.is_checked(0):
				var path = item.get_metadata(0)
				
				if not has_node(path):
					var next = item.get_next()
					root.remove_child(item)
					item = next
					
					continue
					
				var node = get_node(item.get_metadata(0))
				
				surfaces.push_back(node)
				
			item = item.get_next()
			
		tree.update()
		
		while mesh.get_surface_count():
			mesh.surface_remove(0)
			
		if not surfaces.size():
			return
			
		var data = MeshDataTool.new()
		
		for s in surfaces:
			var gt = s.get_global_transform()
			var basis = gt.basis.orthonormalized()
			var m = s.get_mesh()
			
			if m == null:
				continue
				
			var count = m.get_surface_count()
			
			for surf in range(count):
				if m.surface_get_primitive_type(surf) != Mesh.PRIMITIVE_TRIANGLES:
					continue
					
				data.create_from_surface(m, surf)
				
				if not data.get_material():
					var mat = s.get_material_override()
					
					if mat:
						data.set_material(mat)
						
				for i in range(data.get_vertex_count()):
					var v = data.get_vertex(i)
					var n = data.get_vertex_normal(i)
					
					v = gt.xform(v)
					n = basis.xform(n)
					
					data.set_vertex(i, v)
					data.set_vertex_normal(i, n)
					
				data.commit_to_surface(mesh)
				
		data.clear()
		
	func _init(base):
		set_title("Merge Surfaces")
		
		var vb = VBoxContainer.new()
		add_child(vb)
		vb.set_area_as_parent_rect(get_constant("margin", "Dialogs"))
		vb.set_margin(MARGIN_BOTTOM, get_constant("button_margin", "Dialogs")+10)
		
		var hb = HBoxContainer.new()
		vb.add_child(hb)
		hb.set_h_size_flags(SIZE_EXPAND_FILL)
		
		var l = Label.new()
		l.set_text("Select Instances:")
		hb.add_child(l)
		
		var s = Control.new()
		hb.add_child(s)
		s.set_h_size_flags(SIZE_EXPAND_FILL)
		
		tree = Tree.new()
		vb.add_child(tree)
		tree.set_v_size_flags(SIZE_EXPAND_FILL)
		
		tree.connect("item_edited", self, "_merge_surfaces")
		
		connect("confirmed", self, "_merge_surfaces")
		
var merge_dialog

static func get_name():
	return "Merge Surfaces"
	
func create(mesh_instance):
	var instances = []
	
	var parent = mesh_instance.get_parent()
	
	for c in parent.get_children():
		if c extends MeshInstance and c != mesh_instance:
			instances.push_back(c)
			
	mesh_instance.set_name("Surfaces")
	
	merge_dialog.edit(mesh_instance, instances)
	merge_dialog.show_dialog()
	
func edit_primitive():
	if merge_dialog.is_hidden():
		merge_dialog.show_dialog()
		
func clear():
	merge_dialog.clear()
	
func node_removed():
	merge_dialog.edit(null)
	
	if merge_dialog.is_visible():
		merge_dialog.hide()
		
func _init(base):
	var gui_base = base.get_node("/root/EditorNode").get_gui_base()
	
	merge_dialog = MergeDialog.new(gui_base)
	gui_base.add_child(merge_dialog)
	

