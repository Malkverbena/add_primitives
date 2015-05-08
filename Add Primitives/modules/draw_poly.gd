extends Node

class ExtrudeDialog:
	extends ConfirmationDialog
	
	var canvas
	var snap_dialog
	
	const MODE = {
		DRAW = 0,
		EDIT = 1,
		ERASE = 2
	}
	
	var poly = []
	
	var pressed = false
	var mode
	var edit
	
	var handle
	var handle_offset
	
	#Default Values
	var clockwise = false
	var close = false
	var invert = false
	var next = 1
	var axis = [Vector3.AXIS_Z, Vector3.AXIS_Y]
	var current_axis = Vector3.AXIS_X
	var extrude = 1.0
	var radius = 1.0
	var length = 0
	
	var options
	var tools
	
	const OPTIONS = {
		USE_SNAP = 0,
		SHOW_GRID = 1,
		CONFIGURE_SNAP = 2,
		INVERT = 3,
		CLOSE = 4
	}
	
	var snap = false
	var show_grid = false
	var grid_step = Vector2(10,10)
	
	var mesh_instance
	
	const LINE_COLOR = Color(1,0,0)
	const LINE_WIDTH = 2
	const GRID_COLOR = Color(0.2,0.5,0.8, 0.5)
	
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
		
	func rad2rect(pos, radius):
		var p = pos - Vector2(radius, radius)
		var s = Vector2(radius, radius) * 2
		
		return Rect2(p, s)
		
	static func uv_scale(start, end):
		var scl = Vector2(1,1)
		
		if start < end:
			scl = start/end
		elif end < start:
			scl = end/start
			
		return scl
		
	func uv_height():
		var uv = Vector2(0,1)
		
		if extrude < radius:
			uv.y = extrude/radius
			
		return uv
		
	func get_handle(point):
		for i in range(poly.size() - 1, -1, -1):
			if rad2rect(poly[i], handle.get_width()/2).has_point(point):
				return i
				
		return -1
		
	func snap_point(pos):
		if snap:
			return pos.snapped(grid_step)
			
		return pos.snapped(Vector2(1, 1))
		
	func is_clockwise(poly):
		var sum = 0
		
		for i in range(poly.size()):
			var j = (i + 1) % poly.size()
			sum += poly[i].x * poly[j].y;
			sum -= poly[j].x * poly[i].y;
			
		if sum > 0:
			return true
		else:
			return false
			
	func get_index_array():
		var arr = []
		
		if current_axis == Vector3.AXIS_X or current_axis == Vector3.AXIS_Y:
			if clockwise:
				arr = range(poly.size() - 1, 0, -1)
				next = -1
				
			else:
				arr = range(poly.size() - 1)
				next = 1
		else:
			if clockwise:
				arr = range(poly.size() - 1)
				next = 1
				
			else:
				arr = range(poly.size() - 1, 0, -1)
				next = -1
				
		return arr
		
	func set_mode(mode):
		self.mode = mode 
		edit = -1
		
		if mode == MODE.DRAW:
			canvas.set_default_cursor_shape(CURSOR_CROSS)
			
		else:
			canvas.set_default_cursor_shape(CURSOR_ARROW)
			
	func canvas_input_event(ev):
		if ev.type == InputEvent.MOUSE_BUTTON:
			if ev.button_index == BUTTON_LEFT:
				if ev.pressed:
					pressed = true
					
					if ev.shift:
						set_mode(MODE.EDIT)
						
						edit = get_handle(ev.pos)
						
					elif mode == MODE.DRAW:
						poly.append(snap_point(canvas.get_local_mouse_pos()))
						
						if poly.size() < 2:
							poly.append(snap_point(canvas.get_local_mouse_pos()))
							
						canvas.update()
						
				elif not ev.pressed:
					pressed = false
					
					set_mode(MODE.DRAW)
					
			elif ev.button_index == BUTTON_RIGHT:
				if ev.pressed and mode != MODE.EDIT:
					pressed = false
					set_mode(MODE.ERASE)
					
					edit = get_handle(ev.pos)
					canvas.update()
					
				elif not ev.pressed and mode == MODE.ERASE:
					set_mode(MODE.DRAW)
					
		elif ev.type == InputEvent.MOUSE_MOTION and pressed:
			if mode == MODE.EDIT and ev.shift:
				if edit != -1:
					poly[edit] = vector_to_local(snap_point(canvas.get_local_mouse_pos()))
					
					canvas.update()
					
			elif mode == MODE.DRAW:
				poly[poly.size() - 1] = vector_to_local(snap_point(canvas.get_local_mouse_pos()))
				
				canvas.update()
				
		elif ev.type == InputEvent.KEY:
			if ev.shift:
				if ev.pressed:
					set_mode(MODE.EDIT)
					
				else:
					set_mode(MODE.DRAW)
					
	func draw_grid():
		var s = canvas.get_rect().size
		
		for i in range(s.x/grid_step.x + 1):
			canvas.draw_line(Vector2(i * grid_step.x, 0), Vector2(i * grid_step.x, s.y), GRID_COLOR, 1)
			
		for j in range(s.y/grid_step.y + 1):
			canvas.draw_line(Vector2(0, j * grid_step.y), Vector2(s.x, j * grid_step.y), GRID_COLOR, 1)
			
	func redraw_poly():
		length = 0
		
		if poly.size() >= 3:
			canvas.draw_colored_polygon(poly, Color(0.9,0.9,0.9))
			
		for i in range(poly.size() - 1):
				canvas.draw_line(poly[i], poly[i+1], LINE_COLOR, LINE_WIDTH)
				
				length += poly[i].distance_to(poly[i + 1])
				
		for i in range(poly.size()):
			canvas.draw_texture(handle, poly[i] - handle_offset)
			
		if poly.size() > 2 and close:
			canvas.draw_line(poly[poly.size() - 1], poly[0], LINE_COLOR, LINE_WIDTH)
			
			length += poly[poly.size() - 1].distance_to(poly[0])
			
	func canvas_draw():
		if show_grid:
			draw_grid()
			
		if mode == MODE.DRAW:
			redraw_poly()
			
			emit_signal("poly_edited")
			
		elif mode == MODE.EDIT and edit != -1:
			redraw_poly()
			
			emit_signal("poly_edited")
			
		elif mode == MODE.ERASE and edit >= -1:
			poly.remove(edit)
			
			redraw_poly()
			
			emit_signal("poly_edited")
			
		canvas.draw_circle(canvas.get_size()/2, 2, Color(0,0,0))
		
	func clear_canvas():
		poly.clear()
		set_mode(MODE.DRAW)
		
		canvas.update()
		
		emit_signal("poly_edited")
		
	func to_vec3(vector):
		var vec = Vector3()
		
		vec[axis[0]] = (vector.x - 0.5) * radius
		vec[axis[1]] = (vector.y - 0.5) * radius
		
		return vec
		
	func poly2mesh():
		var surf = SurfaceTool.new()
		
		var off = Vector3()
		off[current_axis] = extrude/2
		
		var index = Array(Geometry.triangulate_polygon(Vector2Array(poly)))
		
		if index.empty():
			return
			
		surf.begin(VS.PRIMITIVE_TRIANGLES)
		
		if current_axis == Vector3.AXIS_Z:
			index.invert()
			
		if invert:
			index.invert()
			
		surf.add_smooth_group(false)
			
		for i in index:
			surf.add_uv(poly[i]/canvas.get_size())
			surf.add_vertex(to_vec3(poly[i]/canvas.get_size()) + off)
			
		if extrude != 0:
			surf.add_smooth_group(false)
			
			if close:
				poly.append(poly[0])
				
			var h = uv_height()
			var b = 0
			
			clockwise = is_clockwise(poly)
			
			if invert:
				clockwise = not clockwise
				
			for i in get_index_array():
				var v1 = to_vec3(poly[i]/canvas.get_size())
				var v2 = to_vec3(poly[i + next]/canvas.get_size())
				
				var u1 = Vector2(0,0)
				
				if i > 0:
					var d = poly[i + next].distance_to(poly[i])
					u1 = Vector2(b + d, 0)/canvas.get_size()
					b += d
					
				var u2 = Vector2(b + poly[i].distance_to(poly[i + next]), 0)/canvas.get_size()
				
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
			
			if close:
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
		
	func set_mesh_instance(mesh_instance):
		self.mesh_instance = mesh_instance
		
	func set_axis(id):
		if id == Vector3.AXIS_X:
			axis = [Vector3.AXIS_Z, Vector3.AXIS_Y]
			
		elif id == Vector3.AXIS_Y:
			axis = [Vector3.AXIS_X, Vector3.AXIS_Z]
			
		elif id == Vector3.AXIS_Z:
			axis = [Vector3.AXIS_X, Vector3.AXIS_Y]
		
		current_axis = id
		
		emit_signal("poly_edited")
		
	func set_radius(val):
		radius = val
		
		emit_signal("poly_edited")
		
	func set_extrude(val):
		extrude = val
		
		emit_signal("poly_edited")
		
	func set_grid_step(val, axis):
		if axis == Vector3.AXIS_X:
			grid_step.x = val
			
		elif axis == Vector3.AXIS_Y:
			grid_step.y = val
			
		redraw()
		
	func _changed(arg1 = null):
		emit_signal("poly_edited")
		
	func redraw():
		set_mode(-1)
		canvas.update()
		set_mode(MODE.DRAW)
		
	func options(id):
		var idx = options.get_item_index(id)
		
		if id == OPTIONS.USE_SNAP:
			snap = not snap
			options.set_item_checked(idx, snap)
			
			redraw()
			
		elif id == OPTIONS.SHOW_GRID:
			show_grid = not show_grid
			options.set_item_checked(idx, show_grid)
			
			redraw()
			
		elif id == OPTIONS.CONFIGURE_SNAP:
			snap_dialog.popup_centered(Vector2(140, 80))
			
		elif id == OPTIONS.INVERT:
			invert = not invert
			options.set_item_checked(idx, invert)
			
			redraw()
			
		elif id == OPTIONS.CLOSE:
			close = not close
			options.set_item_checked(idx, close)
			
			redraw()
			
	func update_mesh():
		mesh_instance.set_mesh(poly2mesh())
		
	func default():
		clockwise = false
		close = false
		invert = false
		next = 1
		axis = [Vector3.AXIS_Z, Vector3.AXIS_Y]
		current_axis = Vector3.AXIS_X
		extrude = 1.0
		radius = 1.0
		length = 0
		
		snap = false
		show_grid = false
		
		tools[0].select(current_axis)
		tools[1].set_val(1)
		tools[2].set_val(1)
		
		for i in range(options.get_item_count()):
			if options.is_item_checkable(i):
				options.set_item_checked(i, false)
				
		canvas.update()
		
	func _notification(what):
		if what == NOTIFICATION_POPUP_HIDE:
			poly.clear()
			
			set_mode(-1)
			canvas.update()
			
		elif what == NOTIFICATION_POST_POPUP:
			default()
			set_mode(MODE.DRAW)
			
	func _enter_tree():
		handle = get_parent().get_icon("Editor3DHandle", "EditorIcons")
		handle_offset = Vector2(handle.get_width(), handle.get_height())/2
		
	func _exit_tree():
		clear_canvas()
		poly = null
		
		snap_dialog.remove_and_skip()
		remove_and_skip()
		
	func _init():
		set_title("Draw New Primitive")
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
		
		options.add_check_item("Use Snap", OPTIONS.USE_SNAP)
		options.add_check_item("Show Grid", OPTIONS.SHOW_GRID)
		options.add_item("Configure Snap", OPTIONS.CONFIGURE_SNAP)
		options.add_separator()
		options.add_check_item("Invert", OPTIONS.INVERT)
		options.add_check_item("Close Polygon", OPTIONS.CLOSE)
		
		hb.add_child(m_button)
		options.connect("item_pressed", self, "options")
		
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
		
		set_mode(MODE.DRAW)
		
		canvas.connect("input_event", self, "canvas_input_event")
		canvas.connect("draw", self, "canvas_draw")
		
		add_user_signal("poly_edited")
		
		connect("poly_edited", self, "update_mesh")
		
		#Snap Dialog
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
		
var extrude_dialog

static func get_name():
	return "Draw New Primitive"
	
func main(object):
	var instance = MeshInstance.new()
	instance.set_name("Extrude")
	
	var root = object.get_tree().get_edited_scene_root()
	object.add_child(instance)
	instance.set_owner(root)
	
	extrude_dialog.set_mesh_instance(instance)
	
	extrude_dialog.popup_centered(Vector2(300 + extrude_dialog.get_constant("margin", "Dialogs") * 2, 370))
	
func _init(base):
	var gui_base = base.get_node("/root/EditorNode").get_gui_base()
	
	extrude_dialog = ExtrudeDialog.new()
	gui_base.add_child(extrude_dialog)
	