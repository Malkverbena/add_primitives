extends Reference

class PolygonDialog:
	extends ConfirmationDialog
	
	const Mode = {
		DRAW = 0,
		EDIT = 1
	}
	
	const Options = {
		USE_SNAP = 0,
		SHOW_GRID = 1,
		CONFIGURE_SNAP = 2,
		INVERT = 3,
		CLOSE = 4
	}
	
	var mode = Mode.DRAW
	var edit = -1
	var pressed = false
	var snap = false
	var show_grid = false
	var grid_step = Vector2(10,10)
	
	var handle
	var handle_offset
	
	#Default Values
	var data = {
		next = 1,
		clockwise = false,
		polygon_length = 0,
		invert = false,
		close = false,
		current_axis = Vector3.AXIS_X,
		axis = [Vector3.AXIS_Z, Vector3.AXIS_Y],
		depth = 1.0,
		radius = 1.0
	}
	
	var canvas
	var snap_popup
	var text_display
	var options
	var tools
	
	var mesh_instance
	
	var poly = []
	
	const LINE_COLOR = Color(1,0,0)
	const LINE_WIDTH = 2
	const GRID_COLOR = Color(0.2,0.5,0.8, 0.5)
	
	signal poly_edited
	
	static func is_clockwise(poly):
		var sum = 0
		
		for i in range(poly.size()):
			var j = (i + 1) % poly.size()
			sum += poly[i].x * poly[j].y;
			sum -= poly[j].x * poly[i].y;
			
		if sum > 0:
			return true
			
		else:
			return false
			
	func set_mode(mode):
		self.mode = mode 
		
		if mode == Mode.DRAW:
			canvas.set_default_cursor_shape(CURSOR_CROSS)
			
		elif mode == Mode.EDIT:
			canvas.set_default_cursor_shape(CURSOR_DRAG)
			
		else:
			canvas.set_default_cursor_shape(CURSOR_ARROW)
			
	func set_axis(id):
		if id == Vector3.AXIS_X:
			data.axis = [Vector3.AXIS_Z, Vector3.AXIS_Y]
			
		elif id == Vector3.AXIS_Y:
			data.axis = [Vector3.AXIS_Z, Vector3.AXIS_X]
			
		elif id == Vector3.AXIS_Z:
			data.axis = [Vector3.AXIS_X, Vector3.AXIS_Y]
			
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
		
	func uv_height():
		var uv = Vector2(0,1)
		
		if data.depth < data.radius:
			uv.y = data.depth/data.radius
			
		return uv
		
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
		var s = canvas.get_size()
		
		var ofs = Vector3()
		ofs[data.current_axis] = data.depth/2
		
		var index = Array(Geometry.triangulate_polygon(Vector2Array(poly)))
		
		if index.empty():
			return
			
		var surf = SurfaceTool.new()
		
		surf.begin(VS.PRIMITIVE_TRIANGLES)
		
		if data.current_axis == Vector3.AXIS_X and not data.invert:
			index.invert()
			
		elif data.invert and not data.current_axis == Vector3.AXIS_X:
			index.invert()
			
		surf.add_smooth_group(false)
			
		for i in index:
			surf.add_uv(poly[i]/s)
			surf.add_vertex(to_vec3(poly[i]/s) + ofs)
			
		if data.depth:
			if data.close:
				poly.push_back(poly[0])
				
			var h = uv_height()
			var b = 0
			
			data.clockwise = is_clockwise(poly)
			
			if data.invert:
				data.clockwise = not data.clockwise
				
			for i in get_index_array():
				var v1 = to_vec3(poly[i]/s)
				var v2 = to_vec3(poly[i + data.next]/s)
				
				var u1 = Vector2(0,0)
				
				if i > 0:
					var d = poly[i + data.next].distance_to(poly[i])
					u1 = Vector2(b + d, 0)/s
					b += d
					
				var u2 = Vector2(b + poly[i].distance_to(poly[i + data.next]), 0)/s
				
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
				
			if data.close:
				poly.remove(poly.size() - 1)
				
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
		
	func get_index_array():
		if data.current_axis == Vector3.AXIS_Y or data.current_axis == Vector3.AXIS_Z:
			if data.clockwise:
				data.next = -1
				
				return range(poly.size() - 1, 0, -1)
				
			else:
				data.next = 1
				
				return range(poly.size() - 1)
				
		else:
			if data.clockwise:
				data.next = 1
				
				return range(poly.size() -1)
				
			else:
				data.next = -1
				
				return range(poly.size() - 1, 0, -1)
				
	func show_dialog():
		var s = Vector2(300 + get_constant('margin', 'Dialogs') * 2, 370)
		
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
		data.invert = false
		data.close = false
		
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
							
					elif mode == Mode.DRAW:
						poly.push_back(snap_point(ev.pos))
						
						edit = poly.size() - 1
						
						canvas.update()
						
				elif not ev.pressed:
					pressed = false
					edit = -1
					
					set_mode(Mode.DRAW)
					
			elif ev.button_index == BUTTON_RIGHT:
				if ev.pressed and mode == Mode.DRAW:
					pressed = false
					
					edit = get_handle(ev.pos)
					
					if edit >= 0 and edit < poly.size():
						poly.remove(edit)
						
					canvas.update()
					
		elif ev.type == InputEvent.MOUSE_MOTION and pressed:
			if edit == -1:
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
				
	func _canvas_draw():
		var start = OS.get_ticks_msec()
		
		var s = canvas.get_size()
		var r = Rect2(Vector2(), s)
		
		var ci = canvas.get_canvas_item()
		
		VS.canvas_item_set_clip(ci, true)
		
		canvas.draw_rect(r, Color(0.3, 0.3, 0.3))
		
		if canvas.has_focus():
			canvas.draw_style_box(get_stylebox("EditorFocus","EditorStyles"), r)
			
		if poly.size() >= 3:
			canvas.draw_colored_polygon(poly, Color(0.9,0.9,0.9))
			
		if show_grid:
			for i in range(1, s.x/grid_step.x):
				canvas.draw_line(Vector2(i * grid_step.x, 0), Vector2(i * grid_step.x, s.y), GRID_COLOR, 1)
				
			for j in range(1, s.y/grid_step.y + 1):
				canvas.draw_line(Vector2(0, j * grid_step.y), Vector2(s.x, j * grid_step.y), GRID_COLOR, 1)
				
		# Draw Polygon handles and lines
		data.polygon_length = 0
		
		for i in range(poly.size() - 1):
				canvas.draw_line(poly[i], poly[i+1], LINE_COLOR, LINE_WIDTH)
				
				data.polygon_length += poly[i].distance_to(poly[i + 1])
				
		if poly.size() > 2 and data.close:
			canvas.draw_line(poly[poly.size() - 1], poly[0], LINE_COLOR, LINE_WIDTH)
			
			data.polygon_length += poly[poly.size() - 1].distance_to(poly[0])
			
		for i in range(poly.size()):
			canvas.draw_texture(handle, poly[i] - handle_offset)
			
		if mode >= 0:
			emit_signal("poly_edited")
			
		var ac = [Color(1.0,0.4,0.4), Color(0.4,1.0,0.4), Color(0.4,0.4,1.0)]
		
		canvas.draw_line(Vector2(0, s.y/2), Vector2(s.x, s.y/2), ac[data.axis[0]], 2)
		canvas.draw_line(Vector2(s.x/2, 0), Vector2(s.x/2, s.y), ac[data.axis[1]], 2)
		
		print("End in: " + str(OS.get_ticks_msec() - start) + " ms")
		
	func _notification(what):
		if what == NOTIFICATION_POPUP_HIDE:
			set_mode(-1)
			canvas.update()
			
	func _exit_tree():
		clear_canvas()
		
		data.clear()
		
		snap_popup.queue_free()
		queue_free()
		
	func _init(base):
		set_title("Draw New Polygon")
		set_exclusive(true)
		
		var main_vbox = VBoxContainer.new()
		add_child(main_vbox)
		main_vbox.set_area_as_parent_rect(get_constant("margin", "Dialogs"))
		main_vbox.set_margin(MARGIN_BOTTOM, get_constant("button_margin", "Dialogs")+10)
		
		var hb = HBoxContainer.new()
		main_vbox.add_child(hb)
		hb.set_h_size_flags(SIZE_EXPAND_FILL)
		
		var m_button = MenuButton.new()
		m_button.set_flat(false)
		m_button.set_text("Edit")
		
		options = m_button.get_popup()
		
		options.add_check_item("Use Snap", Options.USE_SNAP)
		options.add_check_item("Show Grid", Options.SHOW_GRID)
		options.add_item("Configure Snap", Options.CONFIGURE_SNAP)
		options.add_separator()
		options.add_check_item("Invert", Options.INVERT)
		options.add_check_item("Close Polygon", Options.CLOSE)
		
		hb.add_child(m_button)
		
		options.connect("item_pressed", self, "_options")
		
		var ob = OptionButton.new()
		ob.add_item('X')
		ob.add_item('Y')
		ob.add_item('Z')
		ob.select(data.current_axis)
		hb.add_child(ob)
		
		ob.connect("item_selected", self, "set_axis")
		
		var d_spin = SpinBox.new()
		d_spin.set_val(data.depth)
		d_spin.set_min(0)
		d_spin.set_max(50)
		d_spin.set_step(0.01)
		hb.add_child(d_spin)
		
		d_spin.connect("value_changed", self, "set_depth")
		
		var r_spin = SpinBox.new()
		r_spin.set_val(data.radius)
		r_spin.set_min(0)
		r_spin.set_max(50)
		r_spin.set_step(0.01)
		hb.add_child(r_spin)
		
		r_spin.connect("value_changed", self, "set_radius")
		
		tools = [ob, d_spin, r_spin]
		
		var sp = Control.new()
		hb.add_child(sp)
		sp.set_h_size_flags(SIZE_EXPAND_FILL)
		
		var clear = Button.new()
		clear.set_text("Clear")
		hb.add_child(clear)
		clear.connect("pressed", self, "clear_canvas")
		
		canvas = Control.new()
		canvas.set_custom_minimum_size(Vector2(300,300))
		main_vbox.add_child(canvas)
		
		handle = base.get_icon("Editor3DHandle", "EditorIcons")
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
		text_display.set_v_size_flags(SIZE_EXPAND_FILL)
		
		get_cancel().connect("pressed", self, "_cancel")
		
		connect("poly_edited", self, "update_mesh")
		
		# Snap Popup
		snap_popup = PopupPanel.new()
		snap_popup.set_size(Vector2(140, 40))
		
		var x = SpinBox.new()
		x.set_val(grid_step.x)
		x.set_min(0.01)
		x.set_max(100)
		x.set_step(0.01)
		
		var y = SpinBox.new()
		y.set_val(grid_step.y)
		y.set_min(0.01)
		y.set_max(100)
		y.set_step(0.01)
		
		var hb = HBoxContainer.new()
		snap_popup.add_child(hb)
		hb.set_area_as_parent_rect(get_constant("margin", "Dialogs"))
		
		hb.add_child(x)
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
	
