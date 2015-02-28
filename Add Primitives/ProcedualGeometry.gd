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
extends "Core/Core.gd"

var toolbar_menu
var popup_menu

var SettingsWindow
var AddMeshPopup

var experimental_builder = true

var current_mesh
var current_heigthmap

var heigthmaps = []
var images = []
var h_values = []
var material
var counter = 0

func _enter_tree():
	toolbar_menu = MenuButton.new()
	toolbar_menu.set_text('Add Mesh')
	popup_menu = toolbar_menu.get_popup()
	
	update_menu()
	
	SettingsWindow = preload("Windows/SettingsWindow.xml").instance()
	AddMeshPopup = preload("Windows/AddMeshPopup.xml").instance()
	
	material = preload("Core/Heigthmap/material.mtl")
	
	add_custom_control(CONTAINER_SPATIAL_EDITOR_MENU, toolbar_menu)
	popup_menu.connect('item_pressed', self, '_popup_signal')

func update_menu():
	popup_menu.add_item('Add Cube')
	popup_menu.add_item('Add Plane')
	popup_menu.add_item('Add Cylinder')
	popup_menu.add_item('Add Sphere')
	popup_menu.add_item('Add Cone')
	popup_menu.add_item('Add Capsule')
	
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
	
	elif command == 'Add Capsule':
		if experimental_builder:
			_add_mesh_popup(AddMeshPopup, 'capsule')
			var capsule = exp_build_capsule(1, 16, 1)
			exp_add_mesh(capsule)
		else:
			pass
	
	elif command == 'Add Heigthmap':
		if experimental_builder:
			if Heigthmap:
				heigthmaps.append(exp_build_heigthmap(null))
				images.append(null)
				h_values.append([])
				heigthmaps[counter].set_material_override(material.duplicate())
				exp_add_heigthmap(heigthmaps[counter])
				
				counter += 1
				
				#_add_mesh_popup(AddMeshPopup, 'heigthmap')
				
			if not is_processing():
				set_process(true)
			
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
	tree_item.set_range_config(1, _min, _max, step)
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
	
	elif mesh == 'capsule':
		current_mesh = 'capsule'
		parameters.append(settings.create_item())
		parameters[0].set_text(0, 'Capsule')
		parameters.append(settings.create_item(parameters[0]))
		_update_tree_range(parameters[1], 'C. Heigth', 1, 0.1, 100, 0.1)
		parameters.append(settings.create_item(parameters[0]))
		_update_tree_range(parameters[2], 'Segments', 16, 3)
		parameters.append(settings.create_item(parameters[0]))
		_update_tree_range(parameters[3], 'Cuts', 8, 3)
	
	#elif mesh == 'heigthmap':
	#	current_mesh = 'heigthmap'
	#	parameters.append(settings.create_item())
	#	parameters[0].set_text(0, 'Heigthmap')
	#	parameters.append(settings.create_item(parameters[0]))
	#	_update_tree_range(parameters[1], 'Range', 5, 1)
	#	parameters.append(settings.create_item(parameters[0]))
	#	_update_tree_range(parameters[2], 'Size', 50, 1)
	#	parameters.append(settings.create_item(parameters[0]))
	#	_update_tree_range(parameters[3], 'Resolution', 32, 1, 100, 1)
		
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
	
	elif current_mesh == 'capsule':
		var parameters = root.get_children()
		values.append(parameters.get_range(1))
		parameters = parameters.get_next()
		values.append(parameters.get_range(1))
		parameters = parameters.get_next()
		values.append(parameters.get_range(1))
		mesh_temp = exp_build_capsule(1, values[1], values[0], values[2], smooth)
	
	#elif current_mesh == 'heigthmap':
	#	var parameters = root.get_children()
	#	values.append(parameters.get_range(1))
	#	parameters = parameters.get_next()
	#	values.append(parameters.get_range(1))
	#	parameters = parameters.get_next()
	#	values.append(parameters.get_range(1))
	#	mesh_temp = exp_build_heigthmap(null, values[1], values[2], values[0], smooth)
	#	g_values = values
	#	g_values.append(smooth)
	
	if mesh_instance.get_mesh() != null:
		mesh_instance.set_mesh(mesh_temp)
	
	mesh_temp == null

func _process(delta):
	var root = get_tree().get_nodes_in_group('_viewports')[1].get_child(0)
	
	for i in range(counter):
		if not heigthmaps[i].is_inside_tree():
			heigthmaps.remove(i)
			counter -= 1
			
	for j in range(counter):
		if heigthmaps[j].heigthmap != images[j] or \
		   (h_values[j][0] != heigthmaps[j].factor or h_values[j][1] != heigthmaps[j].res or h_values[j][2] != heigthmaps[j].size):
			images[j] = heigthmaps[j].heigthmap
			h_values[j] = [heigthmaps[j].factor, heigthmaps[j].res, heigthmaps[j].size]
			var heigthmap_temp = exp_build_heigthmap(heigthmaps[j].heigthmap, h_values[j][2],\
			                                         h_values[j][1], h_values[j][0])
			heigthmaps[j].set_mesh(heigthmap_temp.get_mesh())
	
	if counter == 0:
		print('Not processing')
		set_process(false)

func _exit_tree():
	SettingsWindow = null
	AddMeshPopup = null
	
	popup_menu.free()
	popup_menu = null
	toolbar_menu.free()
	toolbar_menu = null
	
	set_process(false)