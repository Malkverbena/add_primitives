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

class PolygonDialog extends AcceptDialog:
	
	const Mode = {
		DRAW = 0,
		EDIT = 1,
		KNIFE = 2
	}
	
	const Options = {
		SNAP = 0,
		GRID = 1,
		CONFIGURE_SNAP = 2,
		GENERATE_TOP = 3,
		GENERATE_SIDES = 4,
		GENERATE_BOTTOM = 5,
		INVERT = 6
	}
	
	var mode = Mode.DRAW
	var edit = -1
	var pressed = false
	var snap = false
	var show_grid = false
	var grid_step = Vector2(10, 10)
	
	# Knife Tool
	var knife_start = Vector2()
	var knife_end = Vector2()
	
	# Default Values
	var data = {
		axis = Vector3.AXIS_X,
		radius = 1.0,
		depth = 1.0,
		generate_top = true,
		generate_sides = true,
		generate_bottom = true,
		invert = false
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
	
	var mesh
	var mesh_instance
	
	var polygon = []
	
	const AXIS_X = [1, 2, 0]
	const AXIS_Y = [2, 0, 1]
	
	static func to_vec3(vector, radius, axis_x, axis_y):
		var vec = Vector3()
		
		vec[axis_x] = (vector.x - 0.5) * radius
		vec[axis_y] = -(vector.y - 0.5) * radius
		
		return vec
		
	static func is_clockwise(polygon):
		var sum = 0
		
		for i in range(polygon.size()):
			var j = (i + 1) % polygon.size()
			
			sum += polygon[i].x * polygon[j].y;
			sum -= polygon[j].x * polygon[i].y;
			
		return sum > 0
		
	static func get_range_config(size, clockwise):
		var config = {
			min_ = 0,
			max_ = size - 1,
			step = 1
		}
		
		if clockwise:
			config.min_ = size - 1
			config.max_ = 0
			config.step = -1
			
		return config
		
	static func knife_polygon(polygon, start, end):
		var intersections = {}
		
		for i in range(polygon.size()):
			var j = (i + 1) % polygon.size()
			
			var inter = Geometry.segment_intersects_segment_2d(polygon[i], polygon[j], start, end)
			
			if inter == null:
				continue
				
			intersections[j] = inter
			
		if intersections.empty():
			return
			
		var ofs = 0
		
		var keys = intersections.keys()
		keys.sort()
		
		for i in keys:
			polygon.insert(i + ofs, intersections[i])
			
			ofs += 1
			
	static func vector_to_local(control, vector):
		var s = control.get_size()
		
		vector.x = clamp(vector.x, 0, s.x)
		vector.y = clamp(vector.y, 0, s.y)
		
		return vector
		
	func edit(node):
		mesh_instance = node
		
		mesh = Mesh.new()
		mesh.set_name("polygon")
		
		mesh_instance.set_mesh(mesh)
		
		if node == null:
			clear()
			
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
			
	func set_axis(axis):
		data.axis = axis
		
		_update()
		
	func set_radius(val):
		data.radius = val
		
		update_mesh()
		
	func set_depth(val):
		data.depth = val
		
		update_mesh()
		
	func set_grid_step(val, axis):
		grid_step[axis] = ceil(val)
		
		redraw()
		
	func snap_point(pos):
		if snap:
			return pos.snapped(grid_step)
			
		return pos.snapped(Vector2(1, 1))
		
	func get_handle(pos):
		for i in range(polygon.size() - 1, -1, -1):
			if polygon[i].distance_to(pos) < handle_offset.width:
				return i
				
		return -1
		
	func show_dialog():
		var s = Vector2(324, 390)
		
		s.y += toolbar_top.get_size().y + toolbar_bottom.get_size().y
		s.y += text_display.get_line_height() * 1.5
		
		popup_centered(s)
		
		redraw()
		
	func update_mesh():
		var start = OS.get_ticks_msec()
		
		if not mesh_instance:
			return
			
		if mesh.get_surface_count():
			mesh.surface_remove(0)
			
		var index = Array(Geometry.triangulate_polygon(Vector2Array(polygon)))
		
		if index.empty():
			return
			
		var s = canvas.get_size()
		
		var ofs = Vector3()
		ofs[data.axis] = data.depth/2
		
		var axis_x = AXIS_X[data.axis]
		var axis_y = AXIS_Y[data.axis]
		
		var st = SurfaceTool.new()
		
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		
		st.add_smooth_group(false)
		
		if data.invert:
			index.invert()
			
		if data.generate_top:
			for i in index:
				st.add_uv(polygon[i]/s)
				st.add_vertex(to_vec3(polygon[i]/s, data.radius, axis_x, axis_y) + ofs)
				
		if data.depth:
			if data.generate_sides:
				polygon.push_back(polygon[0])
				
				var clockwise = is_clockwise(polygon)
				
				if data.invert:
					clockwise = not clockwise
					
				var cfg = get_range_config(polygon.size(), clockwise)
				
				var h = Vector2(0, data.depth/data.radius)
				var u1 = Vector2()
				var b = 0
				
				for i in range(cfg.min_, cfg.max_, cfg.step):
					var v1 = to_vec3(polygon[i]/s, data.radius, axis_x, axis_y)
					var v2 = to_vec3(polygon[i + cfg.step]/s, data.radius, axis_x, axis_y)
					
					b += polygon[i].distance_to(polygon[i + cfg.step])
					
					var u2 = Vector2(b, 0)/s
					
					st.add_uv(u1 + h)
					st.add_vertex(v1 + ofs)
					st.add_uv(u2 + h)
					st.add_vertex(v2 + ofs)
					st.add_uv(u2)
					st.add_vertex(v2 - ofs)
					
					st.add_uv(u2)
					st.add_vertex(v2 - ofs)
					st.add_uv(u1)
					st.add_vertex(v1 - ofs)
					st.add_uv(u1 + h)
					st.add_vertex(v1 + ofs)
					
					u1 = u2
					
				polygon.remove(polygon.size() - 1)
				
			if data.generate_bottom:
				for i in range(index.size() -1, -1, -1):
					i = index[i]
					
					st.add_uv(polygon[i]/s)
					st.add_vertex(to_vec3(polygon[i]/s, data.radius, axis_x, axis_y) - ofs)
					
		index.clear()
		
		st.generate_normals()
		st.index()
		
		st.commit(mesh)
		st.clear()
		
		var exec_time = OS.get_ticks_msec() - start
		text_display.set_text("Generation time: " + str(exec_time) + " ms")
		
	func default():
		data.axis = Vector3.AXIS_X
		data.radius = 1.0
		data.depth = 1.0
		data.generate_top = true
		data.generate_sides = true
		data.generate_bottom = true
		data.invert = false
		
		snap = false
		show_grid = false
		
		tools[0].select(data.axis)
		tools[1].set_val(data.depth)
		tools[2].set_val(data.radius) 
		
		for i in range(options.get_item_count()):
			if options.is_item_checkable(i):
				options.set_item_checked(i, false)
				
		for i in range(Options.GENERATE_TOP, Options.GENERATE_BOTTOM + 1):
			var idx = options.get_item_index(i)
			
			options.set_item_checked(idx, true)
			
		_clear_canvas()
		
	func redraw():
		set_mode(-1)
		canvas.update()
		set_mode(Mode.DRAW)
		
	func clear():
		polygon.clear()
		set_mode(Mode.DRAW)
		
	func _update():
		canvas.update()
		update_mesh()
		
	func _clear_canvas():
		clear()
		_update()
		
	func _changed(arg1 = null):
		update_mesh()
		
	func _options(id):
		var idx = options.get_item_index(id)
		
		if id == Options.SNAP:
			snap = not snap
			options.set_item_checked(idx, snap)
			
			redraw()
			
		elif id == Options.GRID:
			show_grid = not show_grid
			options.set_item_checked(idx, show_grid)
			
			redraw()
			
		elif id == Options.CONFIGURE_SNAP:
			var ws = get_size()
			var ps = snap_popup.get_size()
			
			snap_popup.set_pos(ws/2 - ps/2 + get_pos())
			snap_popup.popup()
			
		elif id == Options.GENERATE_TOP:
			data.generate_top = not data.generate_top
			options.set_item_checked(idx, data.generate_top)
			
			_update()
			
		elif id == Options.GENERATE_SIDES:
			data.generate_sides = not data.generate_sides
			options.set_item_checked(idx, data.generate_sides)
			
			_update()
			
		elif id == Options.GENERATE_BOTTOM:
			data.generate_bottom = not data.generate_bottom
			options.set_item_checked(idx, data.generate_bottom)
			
			_update()
			
		elif id == Options.INVERT:
			data.invert = not data.invert
			options.set_item_checked(idx, data.invert)
			
			_update()
			
	func _canvas_input_event(ev):
		if ev.type == InputEvent.MOUSE_BUTTON:
			if ev.button_index == BUTTON_LEFT:
				if ev.pressed:
					pressed = true
					
					if ev.shift:
						edit = get_handle(ev.pos)
						
						if edit >= 0:
							set_mode(Mode.EDIT)
							
					elif ev.control:
						var pos = snap_point(ev.pos)
						
						knife_start = pos
						
						set_mode(Mode.KNIFE)
						
					elif mode == Mode.DRAW:
						polygon.push_back(snap_point(ev.pos))
						
						edit = polygon.size() - 1
						
						_update()
				else:
					pressed = false
					edit = -1
					
					if mode == Mode.KNIFE:
						knife_polygon(polygon, knife_start, knife_end)
						
						_update()
						
					set_mode(Mode.DRAW)
					
			elif ev.button_index == BUTTON_RIGHT:
				if ev.pressed and mode == Mode.DRAW:
					pressed = false
					
					edit = get_handle(ev.pos)
					
					if edit >= 0:
						polygon.remove(edit)
						
					_update()
					
		elif ev.type == InputEvent.MOUSE_MOTION and pressed:
			if edit == -1 and mode != Mode.KNIFE:
				return
				
			var edit_pos = snap_point(ev.pos)
			
			if mode == Mode.EDIT:
				polygon[edit] = vector_to_local(canvas, edit_pos)
				
				_update()
				
			elif mode == Mode.DRAW:
				if polygon.size() == 1:
					polygon.push_back(edit_pos)
					
					edit = 1
					
				polygon[edit] = vector_to_local(canvas, edit_pos)
				
				_update()
				
			elif mode == Mode.KNIFE:
				knife_end = vector_to_local(canvas, edit_pos)
				
				_update()
				
	func _canvas_draw():
		var s = canvas.get_size()
		var r = Rect2(Vector2(), s)
		
		VS.canvas_item_set_clip(canvas.get_canvas_item(), true)
		
		canvas.draw_rect(r, Color(0.3, 0.3, 0.3))
		
		if canvas.has_focus():
			canvas.draw_style_box(get_stylebox("EditorFocus","EditorStyles"), r)
			
		if polygon.size() >= 3:
			canvas.draw_colored_polygon(polygon, Color(0.9,0.9,0.9))
			
		if show_grid:
			print(s.x/grid_step.x)
			
			for i in range(1, s.x/grid_step.x):
				canvas.draw_line(Vector2(i * grid_step.x, 0), Vector2(i * grid_step.x, s.y), Color(0.2, 0.5, 0.8, 0.5), 1)
				
			for j in range(1, s.y/grid_step.y):
				canvas.draw_line(Vector2(0, j * grid_step.y), Vector2(s.x, j * grid_step.y), Color(0.2, 0.5, 0.8, 0.5), 1)
				
		# Draw Polygon handles and lines
		for i in range(polygon.size()):
			var j = (i + 1) % polygon.size()
			
			canvas.draw_line(polygon[i], polygon[j], Color(1, 0, 0), 2)
			
		if mode == Mode.KNIFE:
			canvas.draw_line(knife_start, knife_end, Color(), 3)
			canvas.draw_line(knife_start, knife_end, Color(0.8, 0.8, 0.8), 1)
			
			var s = Vector2(8, 8)
			canvas.draw_rect(Rect2(knife_start - s/2, s), Color(0, 1, 0))
			canvas.draw_rect(Rect2(knife_end - s/2, s), Color(0, 1, 0))
			
		for i in range(polygon.size()):
			canvas.draw_texture(handle, polygon[i] - handle_offset)
			
		var ac = [Color(1.0, 0.4, 0.4), Color(0.4, 1.0, 0.4), Color(0.4, 0.4, 1.0)]
		
		canvas.draw_line(Vector2(0, s.y/2), Vector2(s.x, s.y/2), ac[AXIS_X[data.axis]], 2)
		canvas.draw_line(Vector2(s.x/2, 0), Vector2(s.x/2, s.y), ac[AXIS_Y[data.axis]], 2)
		
	func _exit_tree():
		data.clear()
		
		clear()
		
	func _init(base):
		handle = base.get_icon("EditorHandle", "EditorIcons")
		handle_offset = Vector2(handle.get_width(), handle.get_height())/2
		
		set_title("New Polygon")
		set_exclusive(true)
		
		var main_vbox = VBoxContainer.new()
		add_child(main_vbox)
		main_vbox.set_area_as_parent_rect(get_constant("margin", "Dialogs"))
		main_vbox.set_margin(MARGIN_BOTTOM, get_constant("button_margin", "Dialogs")+4)
		
		var hb = HBoxContainer.new()
		main_vbox.add_child(hb)
		
		var ob = OptionButton.new()
		ob.add_item('X')
		ob.add_item('Y')
		ob.add_item('Z')
		hb.add_child(ob)
		
		ob.connect("item_selected", self, "set_axis")
		
		var l = Label.new()
		l.set_text("Depth:")
		hb.add_child(l)
		
		var d_spin = SpinBox.new()
		d_spin.set_min(0)
		d_spin.set_max(50)
		d_spin.set_step(0.01)
		hb.add_child(d_spin)
		
		d_spin.connect("value_changed", self, "set_depth")
		
		l = Label.new()
		l.set_text("Radius:")
		hb.add_child(l)
		
		var r_spin = SpinBox.new()
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
		
		options.add_icon_check_item(base.get_icon("Snap", "EditorIcons"), "Snap", Options.SNAP)
		options.add_icon_check_item(base.get_icon("Grid", "EditorIcons"), "Grid", Options.GRID)
		options.add_item("Configure Snap", Options.CONFIGURE_SNAP)
		options.add_separator()
		options.add_check_item("Generate Top", Options.GENERATE_TOP)
		options.add_check_item("Generate Sides", Options.GENERATE_SIDES)
		options.add_check_item("Generate Bottom", Options.GENERATE_BOTTOM)
		options.add_separator()
		options.add_check_item("Invert", Options.INVERT)
		
		toolbar_top.add_child(m_button)
		
		options.connect("item_pressed", self, "_options")
		
		# Spacer
		var s = Control.new()
		toolbar_top.add_child(s)
		s.set_h_size_flags(SIZE_EXPAND_FILL)
		
		var clear = Button.new()
		clear.set_flat(true)
		clear.set_button_icon(base.get_icon("Remove", "EditorIcons"))
		toolbar_top.add_child(clear)
		clear.connect("pressed", self, "_clear_canvas")
		
		canvas = Control.new()
		vb.add_child(canvas)
		canvas.set_custom_minimum_size(Vector2(300, 300))
		canvas.set_focus_mode(FOCUS_ALL)
		
		canvas.connect("input_event", self, "_canvas_input_event")
		canvas.connect("draw", self, "_canvas_draw")
		
		toolbar_bottom = HBoxContainer.new()
		vb.add_child(toolbar_bottom)
		toolbar_bottom.set_h_size_flags(SIZE_EXPAND_FILL)
		
		mode_display = Label.new()
		toolbar_bottom.add_child(mode_display)
		
		# Spacer
		s = Control.new()
		toolbar_bottom.add_child(s)
		s.set_h_size_flags(SIZE_EXPAND_FILL)
		
		var help = TextureButton.new()
		help.set_normal_texture(base.get_icon("Help", "EditorIcons"))
		help.set_tooltip("Actions:\n  - Left-Click => Add Vertex\n  - Shift + Left-Click + Drag => Edit Vertex\n  - Right-Click => Delete Vertex\n  - Control + Left-Click + Drag => Knife Tool")
		toolbar_bottom.add_child(help)
		
		text_display = Label.new()
		text_display.set_text("Generation time: 0 ms")
		text_display.set_align(text_display.ALIGN_CENTER)
		text_display.set_valign(text_display.VALIGN_CENTER)
		main_vbox.add_child(text_display)
		
		# Snap Popup
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
		
		x.set_h_size_flags(SIZE_EXPAND_FILL)
		y.set_h_size_flags(SIZE_EXPAND_FILL)
		
		x.connect("value_changed", self, "set_grid_step", [Vector3.AXIS_X])
		y.connect("value_changed", self, "set_grid_step", [Vector3.AXIS_Y])
		
		add_child(snap_popup)
		
# End PolygonDialog

var polygon_dialog

static func get_name():
	return "Polygon"
	
func create(mesh_instance):
	mesh_instance.set_name("Polygon")
	
	polygon_dialog.edit(mesh_instance)
	polygon_dialog.default()
	polygon_dialog.show_dialog()
	
func edit_primitive():
	if polygon_dialog.is_hidden():
		polygon_dialog.show_dialog()
		
func clear():
	polygon_dialog.edit(null)
	polygon_dialog.clear()
	
func node_removed():
	polygon_dialog.edit(null)
	
	if polygon_dialog.is_visible():
		polygon_dialog.hide()
		
func _init(base):
	var gui_base = base.get_node("/root/EditorNode").get_gui_base()
	
	polygon_dialog = PolygonDialog.new(gui_base)
	gui_base.add_child(polygon_dialog)
	
