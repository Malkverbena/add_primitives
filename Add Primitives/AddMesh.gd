# Copyright (c) 2015 Franklin Sobrinho.                 
                                                                       
# Permission is hereby granted, free of charge, to any person obtaining 
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without 
# limitation the rights to use, copy, modify, merge, publish,   
# distribute, sublicense, and/or sell copies of the Software, and to    
# permit persons to whom the Software is furnished to do so, subject to 
# the following conditions:                                             
                                                                       
# The above copyright notice and this permission notice shall be        
# included in all copies or substantial portions of the Software.       
                                                                       
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,       
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF    
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY  
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE     
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

tool
extends EditorPlugin

var toolbar_menu
var popup_menu

var StaticMeshBuilder
var SettingsWindow
var AddMeshPopup

var experimental_builder = false

var current_mesh
var mesh_instance

var heigthmap

#MeshData class, it's function is generate and store the mesh arrays

class MeshData:
	var verts = []
	var uv = []
	var faces = []
	
	func find_last(array, element):
		var last = 0
		for i in range(array.size()):
			if element == array[i]:
				last = i
		return last
	
	func add_tri(coords_zero, coords_one, coords_two, reverse = false):
		var verts = []
		verts.append(coords_zero)
		verts.append(coords_one)
		verts.append(coords_two)
		
		var uv = []
		uv.append(Vector2(0,0))
		uv.append(Vector2(0,1))
		uv.append(Vector2(1,1))
	
		self.verts += verts
		self.uv += uv
		
		var faces = []
		var face1 = [find_last(self.verts, coords_one), find_last(self.verts, coords_two), find_last(self.verts, coords_zero)]
		faces.append(face1)
		
		if reverse:
			faces[0].invert()
		
		self.faces += faces
	
	func add_quad(four_vertex_array):
		var vertex = four_vertex_array
		var verts = []
		verts.append(vertex[0])
		verts.append(vertex[1])
		verts.append(vertex[2])
		verts.append(vertex[3])
		
		var uv = []
		uv.append(Vector2(1,1))
		uv.append(Vector2(0,0))
		uv.append(Vector2(1,0))
		uv.append(Vector2(0,1))
			
		self.verts += verts
		self.uv += uv
		
		var faces = []
		var face1 = [find_last(self.verts, vertex[2]),\
		             find_last(self.verts, vertex[0]),\
		             find_last(self.verts, vertex[1])]
		var face2 = [find_last(self.verts, vertex[1]),\
		             find_last(self.verts, vertex[0]),\
		             find_last(self.verts, vertex[3])]
		faces.append(face1)
		faces.append(face2)
		
		self.faces += faces

func _init():
	print("PLUGIN INIT")
	
func _enter_tree():
	toolbar_menu = MenuButton.new()
	toolbar_menu.set_text('Add Mesh')
	popup_menu = toolbar_menu.get_popup()
	
	update_menu()
	
	StaticMeshBuilder = preload("StaticMeshBuilder.gd").new()
	
	SettingsWindow = preload("Windows/SettingsWindow.xml").instance()
	AddMeshPopup = preload("Windows/AddMeshPopup.xml").instance()
	
	add_custom_control(CONTAINER_SPATIAL_EDITOR_MENU, toolbar_menu)
	popup_menu.connect('item_pressed', self, '_popup_signal')
	
func update_menu():
	popup_menu.add_item('Add Cube')
	popup_menu.add_item('Add Plane')
	popup_menu.add_item('Add Cylinder')
	popup_menu.add_item('Add Sphere')
	popup_menu.add_item('Add Cone')
	
	popup_menu.add_separator()
	#popup_menu.add_item('Immediate Geometry')
	popup_menu.add_item('Add Heigthmap')
	popup_menu.add_separator()
	popup_menu.add_item('Settings')
	
func _popup_signal(id):
	var command = popup_menu.get_item_text(popup_menu.get_item_index(id))
	
	if command == 'Add Plane':
		if experimental_builder:
			StaticMeshBuilder.begin(4)
			StaticMeshBuilder.add_quad(exp_build_plane_verts(Vector3(2,0,0), Vector3(0,0,2), Vector3(-1,0,-1)),\
			                           [Vector2(1,1), Vector2(0,0), Vector2(0,1), Vector2(1,0)], true)
			StaticMeshBuilder.generate_normals()
		
			exp_add_mesh(StaticMeshBuilder.commit())
			StaticMeshBuilder.clear()
		
		else:
			var quad = build_plane(Vector3(2,0,0), Vector3(0,0,2), Vector3(-1,0,-1))
			surface_tool(quad)
		
	elif command == 'Add Cube':
		if experimental_builder:
			var box = exp_build_box(Vector3(-1,-1,-1))
			exp_add_mesh(box)
		else:
			var box = build_box()
			surface_tool(box)
	
	elif command == 'Add Cylinder':
		if experimental_builder:
			_add_mesh_popup(AddMeshPopup, 'cylinder')
			var cylinder = exp_build_cylinder(1, 2, 16)
			exp_add_mesh(cylinder)
		else:
			var cylinder = build_cylinder(16, 2)
			surface_tool(cylinder)
	
	elif command == 'Add Sphere':
		if experimental_builder:
			_add_mesh_popup(AddMeshPopup, 'sphere')
			var sphere = exp_build_sphere(1, 16)
			exp_add_mesh(sphere)
		else:
			pass
	
	elif command == 'Add Cone':
		if experimental_builder:
			_add_mesh_popup(AddMeshPopup, 'cone')
			var cone = exp_build_cone(1, 2, 12, 4)
			exp_add_mesh(cone)
		else:
			pass
	
	elif command == 'Add Heigthmap':
		if experimental_builder:
			_add_mesh_popup(AddMeshPopup, 'heigthmap')
			var terrain = exp_build_heigthmap()
			exp_add_mesh(terrain)
		else:
			var heigthmap = build_heigthmap()
			surface_tool(heigthmap)
	
	#elif command == 'Immediate Geometry':
	#	#Here you can add any function here to use Immediate Geometry API
	#	var box = build_box()
	#	immediate_geometry(box)
	
	elif command == 'Settings':
		if SettingsWindow.is_hidden():
			SettingsWindow.show()
		elif SettingsWindow.get_parent() == null:
			add_child(SettingsWindow)
		elif has_node(get_path_to(SettingsWindow)):
			remove_child(SettingsWindow)
			add_child(SettingsWindow)
		
		SettingsWindow.popup_centered()
		
		var check_button = SettingsWindow.get_node('ExperimentalBuilder')
		check_button.set_pressed(experimental_builder)
		var close_button = SettingsWindow.get_node('close_button')
		
		if not check_button.is_connected('toggled', self, '_experimental_builder'):
			check_button.connect('toggled', self, '_experimental_builder')
		if not close_button.is_connected('pressed', self, '_ok_button'):
			close_button.connect('pressed', self, '_ok_button')
		
#Settings
func _experimental_builder(pressed):
	if not pressed:
		experimental_builder = false
	else:
		experimental_builder = true

func _ok_button():
	SettingsWindow.hide()

#Add mesh popup
func _update_tree_range(tree_item, text, value, _min, _max = 100, step = 1):
	tree_item.set_text(0, text)
	tree_item.set_cell_mode(1, 2)
	tree_item.set_range(1, value)
	tree_item.set_range_config(1, _min, 100.0, step)
	tree_item.set_editable(1, true)

func _add_mesh_popup(window, mesh):
	if window.is_hidden():
		window.show()
	elif window.get_parent() == null:
		add_child(window)
	elif has_node(get_path_to(window)):
		remove_child(window)
		add_child(window)
	
	window.popup_centered()
	var settings = window.get_node('Settings')
	settings.clear()
	settings.set_columns(2)
	settings.set_column_title(0, 'Parameter')
	settings.set_column_title(1, 'Value')
	settings.set_column_titles_visible(true)
	
	var check_button = window.get_node('Smooth')
	check_button.set_pressed(true)
	
	var parameters = []
	
	var refresh = window.get_node('Refresh')
	if not refresh.is_connected('pressed', self, '_refresh'):
		refresh.connect('pressed', self, '_refresh')
	
	if mesh == 'cylinder':
		current_mesh = 'cylinder'
		parameters.append(settings.create_item())
		parameters[0].set_text(0, 'Cylinder')
		parameters.append(settings.create_item(parameters[0]))
		_update_tree_range(parameters[1], 'Radius', 1, 0.1, 100, 0.1)
		parameters.append(settings.create_item(parameters[0]))
		_update_tree_range(parameters[2], 'Heigth', 2, 0.1, 100, 0.1)
		parameters.append(settings.create_item(parameters[0]))
		_update_tree_range(parameters[3], 'Segments', 16, 3)
		parameters.append(settings.create_item(parameters[0]))
		_update_tree_range(parameters[4], 'Cuts', 1, 1)
	
	elif mesh == 'sphere':
		current_mesh = 'sphere'
		parameters.append(settings.create_item())
		parameters[0].set_text(0, 'Sphere')
		parameters.append(settings.create_item(parameters[0]))
		_update_tree_range(parameters[1], 'Radius', 1, 0.1, 100, 0.1)
		parameters.append(settings.create_item(parameters[0]))
		_update_tree_range(parameters[2], 'Segments', 16, 3)
		parameters.append(settings.create_item(parameters[0]))
		_update_tree_range(parameters[3], 'Cuts', 8, 3)
	
	elif mesh == 'cone':
		current_mesh = 'cone'
		parameters.append(settings.create_item())
		parameters[0].set_text(0, 'Cone')
		parameters.append(settings.create_item(parameters[0]))
		_update_tree_range(parameters[1], 'Radius', 1, 0.1, 100, 0.1)
		parameters.append(settings.create_item(parameters[0]))
		_update_tree_range(parameters[2], 'Heigth', 2, 0.1, 100, 0.1)
		parameters.append(settings.create_item(parameters[0]))
		_update_tree_range(parameters[3], 'Segments', 16, 3)
	
	elif mesh == 'heigthmap':
		current_mesh = 'heigthmap'
		parameters.append(settings.create_item())
		parameters[0].set_text(0, 'Heigthmap')
		parameters.append(settings.create_item(parameters[0]))
		_update_tree_range(parameters[1], 'Range', 5, 1)
		parameters.append(settings.create_item(parameters[0]))
		_update_tree_range(parameters[2], 'Size', 50, 1)
		parameters.append(settings.create_item(parameters[0]))
		_update_tree_range(parameters[3], 'Resolution', 32, 1)
		
func _refresh():
	var settings = AddMeshPopup.get_node('Settings')
	var check_button = AddMeshPopup.get_node('Smooth')
	
	var smooth = check_button.is_pressed()
	
	var root = settings.get_root()
	var values = []
	var mesh_temp
	
	if current_mesh == 'cylinder':
		var parameters = root.get_children()
		values.append(parameters.get_range(1))
		parameters = parameters.get_next()
		values.append(parameters.get_range(1))
		parameters = parameters.get_next()
		values.append(parameters.get_range(1))
		parameters = parameters.get_next()
		values.append(parameters.get_range(1))
		mesh_temp = exp_build_cylinder(values[0], values[1], values[2], values[3], smooth)
	
	elif current_mesh == 'sphere':
		var parameters = root.get_children()
		values.append(parameters.get_range(1))
		parameters = parameters.get_next()
		values.append(parameters.get_range(1))
		parameters = parameters.get_next()
		values.append(parameters.get_range(1))
		mesh_temp = exp_build_sphere(values[0], values[1], values[2], smooth)
		
	elif current_mesh == 'cone':
		var parameters = root.get_children()
		values.append(parameters.get_range(1))
		parameters = parameters.get_next()
		values.append(parameters.get_range(1))
		parameters = parameters.get_next()
		values.append(parameters.get_range(1))
		mesh_temp = exp_build_cone(values[0], values[1], values[2], smooth)
	
	elif current_mesh == 'heigthmap':
		var parameters = root.get_children()
		values.append(parameters.get_range(1))
		parameters = parameters.get_next()
		values.append(parameters.get_range(1))
		parameters = parameters.get_next()
		values.append(parameters.get_range(1))
		mesh_temp = exp_build_heigthmap(values[1], values[2], values[0], smooth)
	
	if mesh_instance.get_mesh() != null:
		mesh_instance.set_mesh(mesh_temp)
	
	mesh_temp == null
	
	
#Procedual algorithms
func exp_build_plane_verts(width_dir, length_dir, offset = Vector3(0,0,0)):
	var verts = []
	verts.append(Vector3(0,0,0) + offset)
	verts.append(Vector3(0,0,0) + offset + length_dir + width_dir)
	verts.append(Vector3(0,0,0) + offset + length_dir)
	verts.append(Vector3(0,0,0) + offset + width_dir)
	
	return verts

func exp_build_box(offset = Vector3(0,0,0)):
	var foward_dir = Vector3(2,0,0)
	var rigth_dir = Vector3(0,0,2)
	var up_dir = Vector3(0,2,0)
	
	StaticMeshBuilder.begin(4)
	
	var uv_coords = [Vector2(0,0), Vector2(1,1), Vector2(1,0), Vector2(0,1)]
	
	StaticMeshBuilder.add_quad(exp_build_plane_verts(foward_dir, rigth_dir, offset),\
	                           uv_coords)
	StaticMeshBuilder.add_quad(exp_build_plane_verts(rigth_dir, up_dir, offset),\
	                           [uv_coords[3], uv_coords[2], uv_coords[0], uv_coords[1]])
	StaticMeshBuilder.add_quad(exp_build_plane_verts(up_dir, foward_dir, offset),\
	                           [uv_coords[1], uv_coords[0], uv_coords[3], uv_coords[2]])
	StaticMeshBuilder.add_quad(exp_build_plane_verts(-rigth_dir, -foward_dir, -offset),\
	                           [uv_coords[2], uv_coords[3], uv_coords[1], uv_coords[0]])
	StaticMeshBuilder.add_quad(exp_build_plane_verts(-up_dir, -rigth_dir, -offset),\
	                           uv_coords)
	StaticMeshBuilder.add_quad(exp_build_plane_verts(-foward_dir, -up_dir, -offset),\
	                           [uv_coords[2], uv_coords[3], uv_coords[1], uv_coords[0]])
	
	StaticMeshBuilder.generate_normals()
	var mesh = StaticMeshBuilder.commit()
	StaticMeshBuilder.clear()
	return mesh

func exp_build_circle_verts(pos, segments, radius = 1):
	var radians_circle = PI * 2
	var _radius = Vector3(radius, 1, radius)
	
	var circle_verts = []
	
	for i in range(segments):
		var angle = radians_circle * i/segments
		var x = cos(angle)
		var z = sin(angle)
		
		var vector = Vector3(x, 0, z)
		
		circle_verts.append((vector * _radius) + pos)
	
	return circle_verts

func exp_build_cylinder(radius, heigth, segments, cuts = 1, smooth = true, caps = true):
	#cuts = 1 means no cut
	var circle = exp_build_circle_verts(Vector3(0,float(heigth)/2,0), segments, radius)
	var min_pos = Vector3(0,heigth * -1,0)
	
	StaticMeshBuilder.begin(4)
	
	var uv_coords
	
	if caps:
		StaticMeshBuilder.add_smooth_group(false)
		for idx in range(segments - 1):
			StaticMeshBuilder.add_tri([Vector3(0,float(heigth)/2,0), circle[idx + 1], circle[idx]])
			StaticMeshBuilder.add_tri([min_pos * 0.5, circle[idx + 1] + min_pos, circle[idx] + min_pos], null, true)
		
		StaticMeshBuilder.add_tri([Vector3(0,float(heigth)/2,0), circle[0], circle[segments - 1]])
		StaticMeshBuilder.add_tri([min_pos * 0.5, circle[0] + min_pos, circle[segments - 1] + min_pos], null, true)
	
	var next_cut = Vector3(0, float(heigth)/cuts, 0) + min_pos
	
	uv_coords = [Vector2(0, 0), Vector2(1, 1), Vector2(1, 0), Vector2(0, 1)]
	
	StaticMeshBuilder.add_smooth_group(smooth)
	
	for i in range(cuts):
		for idx in range(segments - 1):
			StaticMeshBuilder.add_quad([circle[idx] + min_pos, circle[idx + 1] + next_cut,\
			                            circle[idx] + next_cut, circle[idx + 1] + min_pos], uv_coords, true)
		StaticMeshBuilder.add_quad([circle[0] + min_pos, circle[segments - 1] + next_cut,\
		                            circle[0] + next_cut, circle[segments - 1] + min_pos], uv_coords)
		min_pos = next_cut
		next_cut.y += float(heigth)/cuts
		
	StaticMeshBuilder.generate_normals()
	var mesh = StaticMeshBuilder.commit()
	StaticMeshBuilder.clear()
	
	return mesh

func exp_build_sphere(s_radius, segments, cuts = 8, smooth = true):
	var angle_inc = PI/cuts
	var caps_center = Vector3(0,-s_radius,0)
	
	var circle = exp_build_circle_verts(Vector3(0,0,0), segments, s_radius)
	
	var radius = Vector3(sin(angle_inc), 0, sin(angle_inc))
	var pos
	
	StaticMeshBuilder.begin(4)
	StaticMeshBuilder.add_smooth_group(smooth)
	
	for idx in range(segments - 1):
		pos = Vector3(0,-cos(angle_inc),0) * s_radius
		StaticMeshBuilder.add_tri([caps_center, (circle[idx] * radius) + pos, (circle[idx + 1] * radius) + pos])
		pos = Vector3(0,-cos(angle_inc * (cuts - 1)),0) * s_radius
		StaticMeshBuilder.add_tri([-caps_center, (circle[idx] * radius) + pos, (circle[idx + 1] * radius + pos)], null, true)
	
	pos = Vector3(0,-cos(angle_inc),0) * s_radius
	StaticMeshBuilder.add_tri([caps_center, (circle[0] * radius) + pos, (circle[segments - 1] * radius) + pos], null, true)
	pos = Vector3(0,-cos(angle_inc * (cuts - 1)),0) * s_radius
	StaticMeshBuilder.add_tri([-caps_center, (circle[0] * radius) + pos, (circle[segments - 1] * radius) + pos])
	
	pos = Vector3(0,-cos(angle_inc),0) * s_radius
	for i in range(cuts - 1):
		radius = Vector3(sin(angle_inc * i), 0, sin(angle_inc * i))
		var next_radius = Vector3(sin(angle_inc * (i + 1)), 0, sin(angle_inc * (i + 1)))
		
		var next_pos = Vector3(0,-cos(angle_inc * (i + 1)), 0) * s_radius
		for idx in range(segments - 1):
			StaticMeshBuilder.add_quad([(circle[idx] * radius) + pos,\
			                            (circle[idx + 1] * next_radius) + next_pos,\
			                            (circle[idx] * next_radius) + next_pos,\
			                            (circle[idx + 1] * radius) + pos], null, true)
		StaticMeshBuilder.add_quad([(circle[0] * radius) + pos,\
		                            (circle[segments - 1] * next_radius) + next_pos,\
		                            (circle[0] * next_radius) + next_pos,\
		                            (circle[segments - 1] * radius) + pos])
		
		pos = next_pos
	
	StaticMeshBuilder.generate_normals()
	var mesh = StaticMeshBuilder.commit()
	StaticMeshBuilder.clear()
	
	return mesh

func exp_build_cone(radius, heigth, segments = 12, smooth = true):
	var center_top = Vector3(0, heigth * 0.5, 0)
	var min_pos = Vector3(0, heigth * -0.5, 0)
	
	var circle = exp_build_circle_verts(min_pos, segments, radius)
	
	StaticMeshBuilder.begin(4)
	
	StaticMeshBuilder.add_smooth_group(smooth)
	for idx in range(segments - 1):
		StaticMeshBuilder.add_tri([center_top, circle[idx + 1], circle[idx]])
	StaticMeshBuilder.add_tri([center_top, circle[0], circle[segments - 1]])
	
	StaticMeshBuilder.add_smooth_group(false)
	for idx in range(segments - 1):
		StaticMeshBuilder.add_tri([min_pos, circle[idx], circle[idx + 1]])
	StaticMeshBuilder.add_tri([min_pos, circle[segments - 1], circle[0]])
	
	StaticMeshBuilder.generate_normals()
	var mesh = StaticMeshBuilder.commit()
	StaticMeshBuilder.clear()
	
	return mesh
	
func exp_build_heigthmap(size = 50, res = 32, _range = 5, smooth = true):
	var origin = Vector3(-size/2,0,-size/2)
	var res_size = float(size)/res
	
	var image = preload("Heigthmap.png").get_data()
	
	var verts = []
	
	for i in range(res + 1):
		verts.append([])
		for j in range(res + 1):
			var vert_heigth = image.get_pixel((image.get_height() -1) * (float(i)/res),\
			 (image.get_width() -1) * (float(j)/res))
			verts[i] += [Vector3(i * res_size, vert_heigth.gray() * _range, j * res_size)]
	
	StaticMeshBuilder.begin(4)
	StaticMeshBuilder.add_smooth_group(smooth)
	
	var uv_coords
	
	for i in range(res):
		for j in range(res):
			uv_coords = [Vector2(1 + i, 0 + j)/res, Vector2(0 + i, 1 + j)/res,\
			             Vector2(0 + i, 0 + j)/res, Vector2(1 + i, 1 + j)/res]
			
			StaticMeshBuilder.add_quad([verts[i+1][j] + origin,\
			                            verts[i][j+1] + origin,\
			                            verts[i][j] + origin,\
			                            verts[i+1][j+1] + origin],\
			                            uv_coords ,true)
	
	StaticMeshBuilder.generate_normals()
	var mesh = StaticMeshBuilder.commit()
	StaticMeshBuilder.clear()
	
	return mesh
	
func build_plane(width_dir, length_dir, offset = Vector3(0,0,0)):
	var verts = []
	verts.append(Vector3(0,0,0) + offset)
	verts.append(Vector3(0,0,0) + offset + length_dir)
	verts.append(Vector3(0,0,0) + offset + length_dir + width_dir)
	verts.append(Vector3(0,0,0) + offset + width_dir)
	
	var faces = []
	faces.append([2,1,0])
	faces.append([3,2,0])
	
	var uv = []
	uv.append(Vector2(0,0))
	uv.append(Vector2(0,1))
	uv.append(Vector2(1,1))
	uv.append(Vector2(1,0))
	
	var mesh = MeshData.new()
	mesh.add_quad([verts[0], verts[2], verts[1], verts[3]])
	
	return mesh
	
func build_box():
	var offset = Vector3(-1,-1,-1)
	
	var foward_dir = Vector3(2,0,0)
	var rigth_dir = Vector3(0,0,2)
	var up_dir = Vector3(0,2,0)
	
	var faces = []
	faces.append(build_plane(foward_dir, rigth_dir, offset))
	faces.append(build_plane(rigth_dir, up_dir, offset))
	faces.append(build_plane(up_dir, foward_dir, offset))
	faces.append(build_plane(-rigth_dir, -foward_dir, -offset))
	faces.append(build_plane(-up_dir, -rigth_dir, -offset))
	faces.append(build_plane(-foward_dir, -up_dir, -offset))
	
	var mesh = MeshData.new()
	for face in range(0, faces.size()):
		var temp = faces[face].verts
		mesh.add_quad([temp[1], temp[0], temp[2], temp[3]])
		
	return mesh

func build_cylinder(segments, heigth, caps = true):
	var radians_circle = PI * 2
	
	var h = Vector3(0, heigth/2, 0)
	
	var circle_verts = []
	
	for i in range(segments):
		var angle = radians_circle * i/segments
		var x = cos(angle)
		var z = sin(angle)
		
		circle_verts.append(Vector3(x, 0, z))
	
	var mesh = MeshData.new()
	
	for i in range(segments - 1):
		var index0 = 0 + i
		var index1 = 1 + i
		
		mesh.add_quad([circle_verts[index0] - h,\
		              circle_verts[index1] + h,\
		              circle_verts[index0] + h,\
		              circle_verts[index1] - h])
		
	mesh.add_quad([circle_verts[segments - 1] - h,\
	              circle_verts[0] + h,\
	              circle_verts[segments - 1] + h,\
	              circle_verts[0] - h])
	
	if caps:
		for i in range(segments - 1):
			var index0 = 0 + i 
			var index1 = 1 + i
		
			mesh.add_tri(circle_verts[index0] + h, circle_verts[index1] + h, h)
			mesh.add_tri(circle_verts[index0] - h, circle_verts[index1] - h, -h, true)
	
		mesh.add_tri(circle_verts[segments - 1] + h, circle_verts[0] + h, h)
		mesh.add_tri(circle_verts[segments - 1] - h, circle_verts[0] - h, -h, true)
	return mesh

#This is just a experiment, and for now is just a bumpy surface
#WARNING: There is a perfomace issue related to it

func build_heigthmap(size = 50, res = 32):
	var origin = Vector3(-25,0,-25)
	var res_size = float(size)/res
	
	var verts = []
	
	for i in range(res + 1):
		verts.append([])
		for j in range(res + 1):
			verts[i] += [Vector3(i * res_size, randf(5), j * res_size)]
	
	var mesh = MeshData.new()
	
	for i in range(res):
		for j in range(res):
			mesh.add_quad([verts[i+1][j] + origin,\
			              verts[i][j+1] + origin,\
			              verts[i][j] + origin,\
			              verts[i+1][j+1] + origin])
			
	return mesh

#Function for the next way of adding geometry,
#it will use function Mesh.add_surface(), but it 
#still far to be functional

#func add_mesh(mesh):
#	var mesh_instance = MeshInstance.new()
#	
#	var root = get_tree().get_nodes_in_group('_viewports')[1].get_child(0)
#	
#	if root != null:
#		root.add_child(mesh_instance)
#		mesh_instance.set_owner(root)

func exp_add_mesh(mesh):
	mesh_instance = MeshInstance.new()
	mesh_instance.set_mesh(mesh)
	
	var root = get_tree().get_nodes_in_group('_viewports')[1].get_child(0)
	
	if root == null:
		pass
	else:
		if root.get_type() != 'Spatial':
			for node in root.get_children():
				if node.get_type() == 'Spatial':
					node.add_child(mesh_instance)
					mesh_instance.set_owner(root)
					break
		else:
			root.add_child(mesh_instance)
			mesh_instance.set_owner(root)

#Immediate Geometry, still experimental

func immediate_geometry(mesh):
	var immediate_geo = ImmediateGeometry.new()
	#Here it create a new texture to nescessary to add geometry
	var texture = ImageTexture.new()
	texture.create(256, 256, 0)
	
	immediate_geo.begin(4, texture)
	
	for face in mesh.faces:
		for idx in face:
			immediate_geo.set_normal(mesh.verts[idx].normalized())
			immediate_geo.add_vertex(mesh.verts[idx])
			print(mesh.verts[idx])
	
	var root = get_tree().get_nodes_in_group('_viewports')[1].get_child(0)
	
	immediate_geo.end()
	
	if root == null:
		pass
	else:
		if root.get_type() != 'Spatial':
			for node in root.get_children():
				if node.get_type() == 'Spatial':
					node.add_child(immediate_geo)
					immediate_geo.set_owner(root)
					break
		else:
			root.add_child(immediate_geo)
			immediate_geo.set_owner(root)

#Main function to add geometry, all the plugin engine is based on it

func surface_tool(mesh):
	var mesh_instance = MeshInstance.new()
	var _mesh = Mesh.new()
	var surf = SurfaceTool.new()
	var meshdata_tool = MeshDataTool.new()

	surf.begin(4)
	
	for face in mesh.faces:
		surf.add_smooth_group(false)
		for idx in face:
			surf.add_uv(mesh.uv[idx])
			surf.add_vertex(mesh.verts[idx])
		
	surf.generate_normals()
	_mesh = surf.commit()
	
	mesh = null
	
	_mesh.center_geometry()
	mesh_instance.set_mesh(_mesh)
	
	var root = get_tree().get_nodes_in_group('_viewports')[1].get_child(0)
	
	if root == null:
		pass
	else:
		if root.get_type() != 'Spatial':
			for node in root.get_children():
				if node.get_type() == 'Spatial':
					node.add_child(mesh_instance)
					mesh_instance.set_owner(root)
					break
		else:
			root.add_child(mesh_instance)
			mesh_instance.set_owner(root)
		
func _exit_tree():
	SettingsWindow = null
	AddMeshPopup = null
	
	popup_menu.free()
	popup_menu = null
	toolbar_menu.free()
	toolbar_menu = null
