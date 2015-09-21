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

class PolygonDialog:
	extends ConfirmationDialog
	
	const Mode = {
		DRAW = 0,
		EDIT = 1,
		KNIFE = 2
	}
	
	const Options = {
		USE_SNAP = 0,
		SHOW_GRID = 1,
		CONFIGURE_SNAP = 2,
		GENERATE_TOP = 3,
		GENERATE_SIDES = 4,
		GENERATE_BOTTOM = 5,
		INVERT = 6,
		CLOSE = 7
	}
	
	var mode = Mode.DRAW
	var edit = -1
	var pressed = false
	var snap = false
	var show_grid = false
	var grid_step = Vector2(10,10)
	
	#Knife Tool
	var knife_start = Vector2()
	var knife_end = Vector2()
	
	#Default Values
	var data = {
		next = 1,
		clockwise = false,
		polygon_length = 0,
		gen_top = true,
		gen_sides = true,
		gen_bottom = true,
		invert = false,
		close = true,
		current_axis = Vector3.AXIS_X,
		axis = [Vector3.AXIS_Z, Vector3.AXIS_Y],
		depth = 1.0,
		radius = 1.0
	}
	
	var handle
	var handle_offset
	
	var canvas
	var snap_popup
	var toolbar_top
	var toolbar_bottom
	var mode_display
	var text_display
	var options
	var tools
	
	var mesh_instance
	
	var poly = []
	
	const LINE_COLOR = Color(1, 0, 0)
	const LINE_WIDTH = 2
	const GRID_COLOR = Color(0.2, 0.5, 0.8, 0.5)
	
	signal poly_edited
	
	static func is_clockwise(poly):
		var sum = 0
		
		for i in range(poly.size()):
			var j = (i + 1) % poly.size()
			
			sum += poly[i].x * poly[j].y;
			sum -= poly[j].x * poly[i].y;
			
		return sum > 0
		
	static func knife_polygon(poly, start, end, close = false):
		var intersections = {}
		
		var size = poly.size() - 1
		
		if close:
			var inter = Geometry.segment_intersects_segment_2d(poly[size], poly[0], start, end)
			
			if inter != null:
				poly.push_back(inter)
				
		for i in range(size):
			var inter = Geometry.segment_intersects_segment_2d(poly[i], poly[i+1], start, end)
			
			if inter == null:
				continue
				
			intersections[i+1] = inter
			
		var ofs = 0
		var keys = intersections.keys()
		
		keys.sort()
		
		for i in keys:
			poly.insert(i + ofs, intersections[i])
			
			ofs += 1
			
	func set_mode(mode):
		self.mode = mode 
		
		if mode == Mode.DRAW:
			canvas.set_default_cursor_shape(CURSOR_CROSS)
			
			mode_display.set_text("Mode: Draw")
			
		elif mode == Mode.EDIT:
			canvas.set_default_cursor_shape(CURSOR_DRAG)
			
			mode_display.set_text("Mode: Edit")
			
		elif mode == Mode.KNIFE:
			canvas.set_default_cursor_shape(CURSOR_ARROW)
			
			mode_display.set_text("Mode: Knife")
			
		else:
			canvas.set_default_cursor_shape(CURSOR_ARROW)
			
			mode_display.set_text("Mode:")
			
	func set_axis(id):
		if id == Vector3.AXIS_X:
			data.axis[0] = Vector3.AXIS_Z
			data.axis[1] = Vector3.AXIS_Y
			
		elif id == Vector3.AXIS_Y:
			data.axis[0] = Vector3.AXIS_Z
			data.axis[1] = Vector3.AXIS_X
			
		elif id == Vector3.AXIS_Z:
			data.axis[0] = Vector3.AXIS_X
			data.axis[1] = Vector3.AXIS_Y
			
		data.current_axis = id
		
		emit_signal("poly_edited")
		
		canvas.update()
		
	func set_radius(val):
		data.radius = val
		
		emit_signal("poly_edited")
		
	func set_depth(val):
		data.depth = val
		
		emit_signal("poly_edited")
		
	func set_grid_step(val, axis):
		if axis == Vector3.AXIS_X:
			grid_step.x = val
			
		elif axis == Vector3.AXIS_Y:
			grid_step.y = val
			
		redraw()
		
	func set_mesh_instance(mesh_instance):
		self.mesh_instance = mesh_instance
		
	func get_mesh_instance():
		return mesh_instance
		
	func vector_to_local(vector):
		var s = canvas.get_size()
		
		if vector.x < 0:
			vector.x = 0
			
		elif vector.x > s.x:
			vector.x = s.x
			
		if vector.y < 0:
			vector.y = 0
			
		elif vector.y > s.y:
			vector.y = s.y
			
		return vector
		
	func snap_point(pos):
		if snap:
			return pos.snapped(grid_step)
			
		return pos.snapped(Vector2(1, 1))
		
	func to_vec3(vector):
		var vec = Vector3()
		
		vec[data.axis[0]] = (vector.x - 0.5) * data.radius
		vec[data.axis[1]] = -((vector.y - 0.5) * data.radius)
		
		return vec
		
	func poly2mesh():
		var index = Array(Geometry.triangulate_polygon(Vector2Array(poly)))
		
		if index.empty():
			return
			
		var s = canvas.get_size()
		
		var ofs = Vector3()
		ofs[data.current_axis] = data.depth/2
		
		var surf = SurfaceTool.new()
		
		surf.begin(VS.PRIMITIVE_TRIANGLES)
		
		surf.add_smooth_group(false)
		
		if data.current_axis == Vector3.AXIS_X and not data.invert:
			index.invert()
			
		elif data.invert and not data.current_axis == Vector3.AXIS_X:
			index.invert()
			
		if data.gen_top:
			for i in index:
				surf.add_uv(poly[i]/s)
				surf.add_vertex(to_vec3(poly[i]/s) + ofs)
				
		if data.depth:
			if data.gen_sides:
				if data.close:
					poly.push_back(poly[0])
					
				data.clockwise = is_clockwise(poly)
				
				if data.invert:
					data.clockwise = not data.clockwise
					
				var cfg = get_range_config()
				
				var h = Vector2(0, data.depth/data.radius)
				
				var u1 = Vector2(0, 0)
				
				var b = 0
				
				for i in range(cfg.min_, cfg.max_, cfg.step):
					var v1 = to_vec3(poly[i]/s)
					var v2 = to_vec3(poly[i + data.next]/s)
					
					b += poly[i].distance_to(poly[i + data.next])
					
					var u2 = Vector2(b, 0)/s
					
					surf.add_uv(u1+h)
					surf.add_vertex(v1 + ofs)
					surf.add_uv(u2+h)
					surf.add_vertex(v2 + ofs)
					surf.add_uv(u2)
					surf.add_vertex(v2 - ofs)
					
					surf.add_uv(u2)
					surf.add_vertex(v2 - ofs)
					surf.add_uv(u1)
					surf.add_vertex(v1 - ofs)
					surf.add_uv(u1+h)
					surf.add_vertex(v1 + ofs)
					
					u1 = u2
					
				if data.close:
					poly.remove(poly.size() - 1)
					
			if data.gen_bottom:
				for i in range(index.size() -1, -1, -1):
					i = index[i]
					
					surf.add_uv(poly[i]/s)
					surf.add_vertex(to_vec3(poly[i]/s) - ofs)
					
		index.clear()
		
		surf.generate_normals()
		surf.index()
		
		var mesh = surf.commit()
		surf.clear()
		
		mesh.set_name(mesh_instance.get_name().to_lower())
		
		return mesh
		
	func get_handle(pos):
		for i in range(poly.size() - 1, -1, -1):
			if poly[i].distance_to(pos) < handle.get_width()/2:
				return i
				
		return -1
		
	func get_range_config():
		var size = poly.size() - 1
		
		var config = {
			min_ = 0,
			max_ = size,
			step = 1
		}
		
		data.next = 1
		
		var inv = false
		
		if data.clockwise and data.current_axis != Vector3.AXIS_X:
			inv = true
			
		elif data.current_axis == Vector3.AXIS_X and not data.clockwise:
			inv = true
			
		if inv:
			data.next = -1
			
			config.min_ = size
			config.max_ = 0
			config.step = -1
			
		return config
		
	func show_dialog():
		var s = Vector2(324, 395)
		
		s.y += toolbar_top.get_size().y + toolbar_bottom.get_size().y
		s.y += text_display.get_size().y * 1.5
		
		popup_centered(s)
		
		redraw()
		
	func update_mesh():
		var start = OS.get_ticks_msec()
		
		if mesh_instance:
			var mesh = poly2mesh()
			
			mesh_instance.set_mesh(mesh)
			
		var exec_time = OS.get_ticks_msec() - start
		
		text_display.set_text("Generation time: " + str(exec_time) + " ms")
		
	func default():
		data.next = 1
		data.clockwise = false
		data.gen_top = true
		data.gen_sides = true
		data.gen_bottom = true
		data.invert = false
		data.close = true
		
		set_axis(Vector3.AXIS_X)
		
		data.depth = 1.0
		data.radius = 1.0
		data.polygon_length = 0
		
		snap = false
		show_grid = false
		
		tools[0].select(data.current_axis)
		tools[1].set_val(data.depth)
		tools[2].set_val(data.radius) 
		
		for i in range(options.get_item_count()):
			if options.is_item_checkable(i):
				options.set_item_checked(i, false)
				
		for i in range(Options.GENERATE_TOP, Options.GENERATE_BOTTOM + 1):
			var idx = options.get_item_index(i)
			
			options.set_item_checked(idx, true)
			
		options.set_item_checked(options.get_item_index(Options.CLOSE), true)
		
		clear_canvas()
		
	func redraw():
		set_mode(-1)
		canvas.update()
		set_mode(Mode.DRAW)
		
	func clear_canvas():
		poly.clear()
		set_mode(Mode.DRAW)
		
		canvas.update()
		
		emit_signal("poly_edited")
		
	func _cancel():
		if mesh_instance:
			mesh_instance.queue_free()
			
		mesh_instance = null
		
		clear_canvas()
		
	func _changed(arg1 = null):
		emit_signal("poly_edited")
		
	func _options(id):
		var idx = options.get_item_index(id)
		
		if id == Options.USE_SNAP:
			snap = not snap
			options.set_item_checked(idx, snap)
			
			redraw()
			
		elif id == Options.SHOW_GRID:
			show_grid = not show_grid
			options.set_item_checked(idx, show_grid)
			
			redraw()
			
		elif id == Options.CONFIGURE_SNAP:
			var ws = get_size()
			var ps = snap_popup.get_size()
			
			snap_popup.set_pos(ws/2 - ps/2 + get_pos())
			snap_popup.popup()
			
		elif id == Options.GENERATE_TOP:
			data.gen_top = not data.gen_top
			options.set_item_checked(idx, data.gen_top)
			
			redraw()
			
		elif id == Options.GENERATE_SIDES:
			data.gen_sides = not data.gen_sides
			options.set_item_checked(idx, data.gen_sides)
			
			redraw()
			
		elif id == Options.GENERATE_BOTTOM:
			data.gen_bottom = not data.gen_bottom
			options.set_item_checked(idx, data.gen_bottom)
			
			redraw()
			
		elif id == Options.INVERT:
			data.invert = not data.invert
			options.set_item_checked(idx, data.invert)
			
			redraw()
			
		elif id == Options.CLOSE:
			data.close = not data.close
			options.set_item_checked(idx, data.close)
			
			redraw()
			
	func _canvas_input_event(ev):
		if ev.type == InputEvent.MOUSE_BUTTON:
			if ev.button_index == BUTTON_LEFT:
				if ev.pressed:
					pressed = true
					
					if ev.shift:
						edit = get_handle(ev.pos)
						
						if edit != -1:
							set_mode(Mode.EDIT)
							
					elif ev.control:
						var pos = snap_point(ev.pos)
						
						knife_start = pos
						
						set_mode(Mode.KNIFE)
						
					elif mode == Mode.DRAW:
						poly.push_back(snap_point(ev.pos))
						
						edit = poly.size() - 1
						
						canvas.update()
						
				elif not ev.pressed:
					pressed = false
					edit = -1
					
					if mode == Mode.KNIFE:
						knife_polygon(poly, knife_start, knife_end, data.close)
						
						canvas.update()
						
					set_mode(Mode.DRAW)
					
			elif ev.button_index == BUTTON_RIGHT:
				if ev.pressed and mode == Mode.DRAW:
					pressed = false
					
					edit = get_handle(ev.pos)
					
					if edit >= 0 and edit < poly.size():
						poly.remove(edit)
						
					canvas.update()
					
		elif ev.type == InputEvent.MOUSE_MOTION and pressed:
			if edit == -1 and mode != Mode.KNIFE:
				return
				
			var edit_pos = snap_point(ev.pos)
				
			if mode == Mode.EDIT:
				poly[edit] = vector_to_local(edit_pos)
				
				canvas.update()
				
			elif mode == Mode.DRAW:
				if poly.size() == 1:
					poly.push_back(edit_pos)
					
					edit = poly.size() -1
					
				poly[edit] = vector_to_local(edit_pos)
				
				canvas.update()
				
			elif mode == Mode.KNIFE:
				knife_end = vector_to_local(edit_pos)
				
				canvas.update()
				
	func _canvas_draw():
		var s = canvas.get_size()
		var r = Rect2(Vector2(), s)
		
		VS.canvas_item_set_clip(canvas.get_canvas_item(), true)
		
		canvas.draw_rect(r, Color(0.3, 0.3, 0.3))
		
		if canvas.has_focus():
			canvas.draw_style_box(get_stylebox("EditorFocus","EditorStyles"), r)
			
		if poly.size() >= 3:
			canvas.draw_colored_polygon(poly, Color(0.9,0.9,0.9))
			
		if show_grid:
			for i in range(1, s.x/grid_step.x):
				canvas.draw_line(Vector2(i * grid_step.x, 0), Vector2(i * grid_step.x, s.y), GRID_COLOR, 1)
				
			for j in range(1, s.y/grid_step.y):
				canvas.draw_line(Vector2(0, j * grid_step.y), Vector2(s.x, j * grid_step.y), GRID_COLOR, 1)
				
		# Draw Polygon handles and lines
		data.polygon_length = 0
		
		for i in range(poly.size() - 1):
				canvas.draw_line(poly[i], poly[i+1], LINE_COLOR, LINE_WIDTH)
				
				data.polygon_length += poly[i].distance_to(poly[i + 1])
				
		if poly.size() > 2 and data.close:
			canvas.draw_line(poly[poly.size() - 1], poly[0], LINE_COLOR, LINE_WIDTH)
			
			data.polygon_length += poly[poly.size() - 1].distance_to(poly[0])
			
		if mode == Mode.KNIFE:
			canvas.draw_line(knife_start, knife_end, Color(0,0,1, 0.6), 3)
			
		for i in range(poly.size()):
			canvas.draw_texture(handle, poly[i] - handle_offset)
			
		if mode >= 0:
			emit_signal("poly_edited")
			
		var ac = [Color(1.0,0.4,0.4), Color(0.4,1.0,0.4), Color(0.4,0.4,1.0)]
		
		canvas.draw_line(Vector2(0, s.y/2), Vector2(s.x, s.y/2), ac[data.axis[0]], 2)
		canvas.draw_line(Vector2(s.x/2, 0), Vector2(s.x/2, s.y), ac[data.axis[1]], 2)
		
	func _exit_tree():
		clear_canvas()
		
		data.clear()
		
	func _init(base):
		set_title("New Polygon")
		set_exclusive(true)
		
		var main_vbox = VBoxContainer.new()
		add_child(main_vbox)
		main_vbox.set_area_as_parent_rect(get_constant("margin", "Dialogs"))
		main_vbox.set_margin(MARGIN_BOTTOM, get_constant("button_margin", "Dialogs")+10)
		
		var hb = HBoxContainer.new()
		main_vbox.add_child(hb)
		
		var ob = OptionButton.new()
		ob.add_item('X')
		ob.add_item('Y')
		ob.add_item('Z')
		ob.select(data.current_axis)
		hb.add_child(ob)
		
		ob.connect("item_selected", self, "set_axis")
		
		var l = Label.new()
		l.set_text("Depth:")
		hb.add_child(l)
		
		var d_spin = SpinBox.new()
		d_spin.set_val(data.depth)
		d_spin.set_min(0)
		d_spin.set_max(50)
		d_spin.set_step(0.01)
		hb.add_child(d_spin)
		
		d_spin.connect("value_changed", self, "set_depth")
		
		l = Label.new()
		l.set_text("Radius:")
		hb.add_child(l)
		
		var r_spin = SpinBox.new()
		r_spin.set_val(data.radius)
		r_spin.set_min(0)
		r_spin.set_max(50)
		r_spin.set_step(0.01)
		hb.add_child(r_spin)
		
		r_spin.connect("value_changed", self, "set_radius")
		
		tools = [ob, d_spin, r_spin]
		
		var panel = PanelContainer.new()
		main_vbox.add_child(panel)
		panel.set_v_size_flags(SIZE_EXPAND_FILL)
		
		var vb = VBoxContainer.new()
		panel.add_child(vb)
		
		toolbar_top = HBoxContainer.new()
		vb.add_child(toolbar_top)
		toolbar_top.set_h_size_flags(SIZE_EXPAND_FILL)
		
		var m_button = MenuButton.new()
		m_button.set_flat(true)
		m_button.set_text("Edit")
		
		options = m_button.get_popup()
		
		options.add_check_item("Use Snap", Options.USE_SNAP)
		options.add_check_item("Show Grid", Options.SHOW_GRID)
		options.add_item("Configure Snap", Options.CONFIGURE_SNAP)
		options.add_separator()
		options.add_check_item("Generate Top", Options.GENERATE_TOP)
		options.add_check_item("Generate Sides", Options.GENERATE_SIDES)
		options.add_check_item("Generate Bottom", Options.GENERATE_BOTTOM)
		options.add_separator()
		options.add_check_item("Invert", Options.INVERT)
		options.add_check_item("Close Polygon", Options.CLOSE)
		
		toolbar_top.add_child(m_button)
		
		options.connect("item_pressed", self, "_options")
		
		#Spacer
		var s = Control.new()
		toolbar_top.add_child(s)
		s.set_h_size_flags(SIZE_EXPAND_FILL)
		
		var clear = Button.new()
		clear.set_flat(true)
		clear.set_text("Clear")
		clear.set_button_icon(base.get_icon("RemoveHl", "EditorIcons"))
		toolbar_top.add_child(clear)
		clear.connect("pressed", self, "clear_canvas")
		
		canvas = Control.new()
		vb.add_child(canvas)
		canvas.set_v_size_flags(SIZE_EXPAND_FILL)
		
		toolbar_bottom = HBoxContainer.new()
		vb.add_child(toolbar_bottom)
		toolbar_bottom.set_h_size_flags(SIZE_EXPAND_FILL)
		
		mode_display = Label.new()
		toolbar_bottom.add_child(mode_display)
		
		#Spacer
		s = Control.new()
		toolbar_bottom.add_child(s)
		s.set_h_size_flags(SIZE_EXPAND_FILL)
		
		var help = TextureButton.new()
		help.set_normal_texture(base.get_icon("Help", "EditorIcons"))
		help.set_tooltip("Actions:\n  - Left-Click => Add Vertex\n  - Shift + Right-Click + Drag => Edit Vertex\n  - Right-Click => Delete Vertex\n  - Control + Left-Click + Drag => Knife Tool")
		toolbar_bottom.add_child(help)
		
		handle = base.get_icon("EditorHandle", "EditorIcons")
		handle_offset = Vector2(handle.get_width(), handle.get_height())/2
		
		canvas.set_focus_mode(FOCUS_ALL)
		
		set_mode(Mode.DRAW)
		
		canvas.connect("input_event", self, "_canvas_input_event")
		canvas.connect("draw", self, "_canvas_draw")
		
		text_display = Label.new()
		text_display.set_text("Generation time: 0 ms")
		text_display.set_align(text_display.ALIGN_CENTER)
		text_display.set_valign(text_display.VALIGN_CENTER)
		main_vbox.add_child(text_display)
		
		get_cancel().connect("pressed", self, "_cancel")
		
		connect("poly_edited", self, "update_mesh")
		
		#Snap Popup
		snap_popup = PopupPanel.new()
		snap_popup.set_size(Vector2(180, 40))
		
		var hb = HBoxContainer.new()
		snap_popup.add_child(hb)
		hb.set_area_as_parent_rect(get_constant("margin", "Dialogs"))
		
		l = Label.new()
		l.set_text("x")
		l.set_align(l.ALIGN_CENTER)
		l.set_valign(l.VALIGN_CENTER)
		
		var x = SpinBox.new()
		x.set_val(grid_step.x)
		x.set_min(1)
		x.set_max(100)
		x.set_suffix('px')
		
		hb.add_child(l)
		hb.add_child(x)
		
		l = Label.new()
		l.set_text("y")
		l.set_align(l.ALIGN_CENTER)
		l.set_valign(l.VALIGN_CENTER)
		
		var y = SpinBox.new()
		y.set_val(grid_step.y)
		y.set_min(1)
		y.set_max(100)
		y.set_suffix('px')
		
		hb.add_child(l)
		hb.add_child(y)
		
		x.connect("value_changed", self, "set_grid_step", [Vector3.AXIS_X])
		y.connect("value_changed", self, "set_grid_step", [Vector3.AXIS_Y])
		
		add_child(snap_popup)
		
# End PolygonDialog

var polygon_dialog

static func get_name():
	return "Polygon"
	
func create(object):
	var instance = MeshInstance.new()
	instance.set_name("Polygon")
	
	var root = object.get_tree().get_edited_scene_root()
	object.add_child(instance)
	instance.set_owner(root)
	
	polygon_dialog.set_mesh_instance(instance)
	
	polygon_dialog.default()
	polygon_dialog.show_dialog()
	
	return instance
	
func edit_primitive():
	if not polygon_dialog.get_mesh_instance():
		return
		
	polygon_dialog.show_dialog()
	
func clear():
	polygon_dialog.set_mesh_instance(null)
	
	polygon_dialog.clear_canvas()
	
func _init(base):
	var gui_base = base.get_node("/root/EditorNode").get_gui_base()
	
	polygon_dialog = PolygonDialog.new(gui_base)
	gui_base.add_child(polygon_dialog)
	
