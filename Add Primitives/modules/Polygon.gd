extends Node

class ExtrudeDialog:
	extends ConfirmationDialog
	
	const Mode = {
		DRAW = 0,
		EDIT = 1,
		ERASE = 2
	}
	
	const Options = {
		USE_SNAP = 0,
		SHOW_GRID = 1,
		CONFIGURE_SNAP = 2,
		INVERT = 3,
		CLOSE = 4
	}
	
	var pressed = false
	var snap = false
	var show_grid = false
	var grid_step = Vector2(10,10)
	
	#Default Values
	var data = {
		clockwise = false,
		close = false,
		invert = false,
		next = 1,
		axis = [Vector3.AXIS_Z, Vector3.AXIS_Y],
		current_axis = Vector3.AXIS_X,
		extrude = 1.0,
		radius = 1.0,
		length = 0
	}
	
	var canvas
	var snap_dialog
	
	var mode
	var edit
	
	var handle
	var handle_offset
	
	var options
	var tools
	
	var mesh_instance
	
	var poly = []
	
	const LINE_COLOR = Color(1,0,0)
	const LINE_WIDTH = 2
	const GRID_COLOR = Color(0.2,0.5,0.8, 0.5)
	
	signal poly_edited
	
	static func uv_scale(start, end):
		var scl = Vector2(1,1)
		
		if start < end:
			scl = start/end
		elif end < start:
			scl = end/start
			
		return scl
		
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
			
	func vector_to_local(vector2):
		var s = canvas.get_rect().size
		
		if vector2.x < 0:
			vector2.x = 0
			
		if vector2.x > s.x:
			vector2.x = s.x
			
		if vector2.y < 0:
			vector2.y = 0
			
		if vector2.y > s.y:
			vector2.y = s.y
			
		return vector2
		
	func uv_height():
		var uv = Vector2(0,1)
		
		if data.extrude < data.radius:
			uv.y = data.extrude/data.radius
			
		return uv
		
	func snap_point(pos):
		if snap:
			return pos.snapped(grid_step)
			
		return pos.snapped(Vector2(1, 1))
		
	func to_vec3(vector):
		var vec = Vector3()
		
		vec[data.axis[0]] = (vector.x - 0.5) * data.radius
		vec[data.axis[1]] = (vector.y - 0.5) * data.radius
		
		return vec
		
	func poly2mesh():
		var surf = SurfaceTool.new()
		
		var off = Vector3()
		off[data.current_axis] = data.extrude/2
		
		var index = Array(Geometry.triangulate_polygon(Vector2Array(poly)))
		
		if index.empty():
			return
			
		surf.begin(VS.PRIMITIVE_TRIANGLES)
		
		if data.current_axis == Vector3.AXIS_Z and not data.invert:
			index.invert()
			
		if data.invert:
			index.invert()
			
		surf.add_smooth_group(false)
			
		for i in index:
			surf.add_uv(poly[i]/canvas.get_size())
			surf.add_vertex(to_vec3(poly[i]/canvas.get_size()) + off)
			
		if data.extrude:
			surf.add_smooth_group(false)
			
			if data.close:
				poly.push_back(poly[0])
				
			var h = uv_height()
			var b = 0
			
			data.clockwise = is_clockwise(poly)
			
			if data.invert:
				data.clockwise = not data.clockwise
				
			for i in get_index_array():
				var v1 = to_vec3(poly[i]/canvas.get_size())
				var v2 = to_vec3(poly[i + data.next]/canvas.get_size())
				
				var u1 = Vector2(0,0)
				
				if i > 0:
					var d = poly[i + data.next].distance_to(poly[i])
					u1 = Vector2(b + d, 0)/canvas.get_size()
					b += d
					
				var u2 = Vector2(b + poly[i].distance_to(poly[i + data.next]), 0)/canvas.get_size()
				
				surf.add_uv(u1+h)
				surf.add_vertex(v1 + off)
				surf.add_uv(u2+h)
				surf.add_vertex(v2 + off)
				surf.add_uv(u2)
				surf.add_vertex(v2 - off)
				
				surf.add_uv(u2)
				surf.add_vertex(v2 - off)
				surf.add_uv(u1)
				surf.add_vertex(v1 - off)
				surf.add_uv(u1+h)
				surf.add_vertex(v1 + off)
				
			index.invert()
			
			if data.close:
				poly.remove(poly.size() - 1)
				
			surf.add_smooth_group(false)
			
			for i in index:
				surf.add_uv(poly[i]/canvas.get_size())
				surf.add_vertex(to_vec3(poly[i]/canvas.get_size()) - off)
				
		index.clear()
		
		surf.generate_normals()
		surf.index()
		
		var mesh = surf.commit()
		surf.clear()
		
		mesh.set_name(mesh_instance.get_name().to_lower())
		
		return mesh
		
	func set_mode(mode):
		self.mode = mode 
		edit = -1
		
		if mode == Mode.DRAW:
			canvas.set_default_cursor_shape(CURSOR_CROSS)
			
		else:
			canvas.set_default_cursor_shape(CURSOR_ARROW)
			
	func set_mesh_instance(mesh_instance):
		self.mesh_instance = mesh_instance
		
	func set_axis(id):
		if id == Vector3.AXIS_X:
			data.axis = [Vector3.AXIS_Z, Vector3.AXIS_Y]
			
		elif id == Vector3.AXIS_Y:
			data.axis = [Vector3.AXIS_X, Vector3.AXIS_Z]
			
		elif id == Vector3.AXIS_Z:
			data.axis = [Vector3.AXIS_X, Vector3.AXIS_Y]
		
		data.current_axis = id
		
		emit_signal("poly_edited")
		
	func set_radius(val):
		data.radius = val
		
		emit_signal("poly_edited")
		
	func set_extrude(val):
		data.extrude = val
		
		emit_signal("poly_edited")
		
	func set_grid_step(val, axis):
		if axis == Vector3.AXIS_X:
			grid_step.x = val
			
		elif axis == Vector3.AXIS_Y:
			grid_step.y = val
			
		redraw()
		
	func get_mesh_instance():
		return mesh_instance
		
	func get_handle(point):
		for i in range(poly.size() - 1, -1, -1):
			if poly[i].distance_to(point) < handle.get_width()/2:
				return i
				
		return -1
		
	func get_index_array():
		var arr = []
		
		if data.current_axis == Vector3.AXIS_X or data.current_axis == Vector3.AXIS_Y:
			if data.clockwise:
				arr = range(poly.size() - 1, 0, -1)
				data.next = -1
				
			else:
				arr = range(poly.size() - 1)
				data.next = 1
		else:
			if data.clockwise:
				arr = range(poly.size() - 1)
				data.next = 1
				
			else:
				arr = range(poly.size() - 1, 0, -1)
				data.next = -1
				
		return arr
		
	func show_dialog():
		popup_centered(Vector2(300 + get_constant("margin", "Dialogs") * 2, 370))
		
		redraw()
		
	func update_mesh():
		if mesh_instance:
			var mesh = poly2mesh()
			
			mesh_instance.set_mesh(mesh)
			
	func default():
		data.clockwise = false
		data.close = false
		data.invert = false
		data.next = 1
		data.axis = [Vector3.AXIS_Z, Vector3.AXIS_Y]
		data.current_axis = Vector3.AXIS_X
		data.extrude = 1.0
		data.radius = 1.0
		data.length = 0
		
		snap = false
		show_grid = false
		
		tools[0].select(data.current_axis)
		tools[1].set_val(1)
		tools[2].set_val(1)
		
		for i in range(options.get_item_count()):
			if options.is_item_checkable(i):
				options.set_item_checked(i, false)
				
		set_mode(Mode.DRAW)
		
		canvas.update()
		
	func redraw():
		set_mode(-1)
		canvas.update()
		set_mode(Mode.DRAW)
		
	func draw_grid():
		var s = canvas.get_rect().size
		
		for i in range(s.x/grid_step.x + 1):
			canvas.draw_line(Vector2(i * grid_step.x, 0), Vector2(i * grid_step.x, s.y), GRID_COLOR, 1)
			
		for j in range(s.y/grid_step.y + 1):
			canvas.draw_line(Vector2(0, j * grid_step.y), Vector2(s.x, j * grid_step.y), GRID_COLOR, 1)
			
	func redraw_poly():
		data.length = 0
		
		if poly.size() >= 3:
			canvas.draw_colored_polygon(poly, Color(0.9,0.9,0.9))
			
		for i in range(poly.size() - 1):
				canvas.draw_line(poly[i], poly[i+1], LINE_COLOR, LINE_WIDTH)
				
				data.length += poly[i].distance_to(poly[i + 1])
				
		if poly.size() > 2 and data.close:
			canvas.draw_line(poly[poly.size() - 1], poly[0], LINE_COLOR, LINE_WIDTH)
			
			data.length += poly[poly.size() - 1].distance_to(poly[0])
			
		for i in range(poly.size()):
			canvas.draw_texture(handle, poly[i] - handle_offset)
			
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
			snap_dialog.popup_centered(Vector2(140, 75))
			
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
						set_mode(Mode.EDIT)
						
						edit = get_handle(ev.pos)
						
					elif mode == Mode.DRAW:
						poly.push_back(snap_point(canvas.get_local_mouse_pos()))
						
						if poly.size() == 1:
							poly.push_back(snap_point(canvas.get_local_mouse_pos()))
							
						canvas.update()
						
				elif not ev.pressed:
					pressed = false
					
					set_mode(Mode.DRAW)
					
			elif ev.button_index == BUTTON_RIGHT:
				if ev.pressed and mode != Mode.EDIT:
					pressed = false
					
					set_mode(Mode.ERASE)
					
					edit = get_handle(ev.pos)
					
					canvas.update()
					
				elif not ev.pressed and mode == Mode.ERASE:
					set_mode(Mode.DRAW)
					
		elif ev.type == InputEvent.MOUSE_MOTION and pressed:
			if mode == Mode.EDIT and ev.shift:
				if edit != -1:
					poly[edit] = vector_to_local(snap_point(canvas.get_local_mouse_pos()))
					
					canvas.update()
					
			elif mode == Mode.DRAW:
				poly[poly.size() - 1] = vector_to_local(snap_point(canvas.get_local_mouse_pos()))
				
				canvas.update()
				
		elif ev.type == InputEvent.KEY:
			if ev.shift:
				if ev.pressed:
					set_mode(Mode.EDIT)
					
				else:
					set_mode(Mode.DRAW)
					
	func _canvas_draw():
		if show_grid:
			draw_grid()
			
		if mode == Mode.DRAW:
			redraw_poly()
			
			emit_signal("poly_edited")
			
		elif mode == Mode.EDIT and edit != -1:
			redraw_poly()
			
			emit_signal("poly_edited")
			
		elif mode == Mode.ERASE and edit >= -1:
			poly.remove(edit)
			
			redraw_poly()
			
			emit_signal("poly_edited")
			
		canvas.draw_circle(canvas.get_size()/2, 2, Color(0,0,0))
		
	func _notification(what):
		if what == NOTIFICATION_POPUP_HIDE:
			set_mode(-1)
			canvas.update()
			
	func _enter_tree():
		handle = get_parent().get_icon("Editor3DHandle", "EditorIcons")
		handle_offset = Vector2(handle.get_width(), handle.get_height())/2
		
	func _exit_tree():
		clear_canvas()
		
		data.clear()
		
		snap_dialog.queue_free()
		queue_free()
		
	func _init():
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
		
		var op = OptionButton.new()
		op.add_item('X')
		op.add_item('Y')
		op.add_item('Z')
		hb.add_child(op)
		op.connect("item_selected", self, "set_axis")
		
		var e_spin = SpinBox.new()
		e_spin.set_val(1)
		e_spin.set_min(0)
		e_spin.set_max(50)
		e_spin.set_step(0.01)
		hb.add_child(e_spin)
		e_spin.connect("value_changed", self, "set_extrude")
		
		set_axis(Vector3.AXIS_X)
		
		var r_spin = SpinBox.new()
		r_spin.set_val(1)
		r_spin.set_min(0)
		r_spin.set_max(50)
		r_spin.set_step(0.01)
		hb.add_child(r_spin)
		r_spin.connect("value_changed", self, "set_radius")
		
		tools = [op, e_spin, r_spin]
		
		var sp = Control.new()
		hb.add_child(sp)
		sp.set_h_size_flags(SIZE_EXPAND_FILL)
		
		var clear = Button.new()
		clear.set_text("Clear")
		hb.add_child(clear)
		clear.connect("pressed", self, "clear_canvas")
		
		canvas = ReferenceFrame.new()
		main_vbox.add_child(canvas)
		canvas.set_custom_minimum_size(Vector2(300,300))
		
		set_mode(Mode.DRAW)
		
		canvas.connect("input_event", self, "_canvas_input_event")
		canvas.connect("draw", self, "_canvas_draw")
		
		get_cancel().connect("pressed", self, "_cancel")
		
		connect("poly_edited", self, "update_mesh")
		
		# Snap Dialog
		snap_dialog = AcceptDialog.new()
		snap_dialog.set_title("Set Snap Step")
		var x = SpinBox.new()
		x.set_val(10)
		x.set_min(0.01)
		x.set_max(100)
		x.set_step(0.01)
		
		var y = SpinBox.new()
		y.set_val(10)
		y.set_min(0.01)
		y.set_max(100)
		y.set_step(0.01)
		
		var hb = HBoxContainer.new()
		snap_dialog.add_child(hb)
		hb.set_area_as_parent_rect(get_constant("margin", "Dialogs"))
		hb.set_margin(MARGIN_BOTTOM, get_constant("button_margin", "Dialogs") + 10)
		
		hb.add_child(x)
		hb.add_child(y)
		
		x.connect("value_changed", self, "set_grid_step", [Vector3.AXIS_X])
		y.connect("value_changed", self, "set_grid_step", [Vector3.AXIS_Y])
		
		add_child(snap_dialog)
		
# End ExtrudeDialog

var extrude_dialog

static func get_name():
	return "Polygon"
	
func clear():
	extrude_dialog.set_mesh_instance(null)
	
	extrude_dialog.clear_canvas()
	
func edit_primitive():
	if not extrude_dialog.get_mesh_instance():
		return
		
	extrude_dialog.show_dialog()
	
func exec(object):
	var instance = MeshInstance.new()
	instance.set_name("Polygon")
	
	var root = object.get_tree().get_edited_scene_root()
	object.add_child(instance)
	instance.set_owner(root)
	
	extrude_dialog.default()
	
	extrude_dialog.set_mesh_instance(instance)
	
	extrude_dialog.show_dialog()
	
func _init(base):
	var gui_base = base.get_node("/root/EditorNode").get_gui_base()
	
	extrude_dialog = ExtrudeDialog.new()
	gui_base.add_child(extrude_dialog)
	
