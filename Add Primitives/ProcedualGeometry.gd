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
var text_editor

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

var resource_loader
var _shader

var custom_meshes = []
var custom_mesh_scripts = {}
var script_to_reload

func _init():
	_shader = ["uniform float factor;\n",\
              "\n",\
              "uniform texture heigthmap;\n",\
              "uniform texture high;\n",\
              "uniform texture low;\n",\
              "\n",\
              "vec3 mask = tex(heigthmap, UV).xyz;\n",\
              "vec3 first_map = tex(low, UV).xyz;\n",\
              "vec3 second_map = tex(high, UV).xyz;\n",\
              "\n",\
              "DIFFUSE = mix(first_map, second_map, mask/factor);"]

func _enter_tree():
	toolbar_menu = MenuButton.new()
	toolbar_menu.set_text('Add Mesh')
	popup_menu = toolbar_menu.get_popup()
	
	update_menu()
	
	resource_loader = ResourcePreloader.new()
	
	resource_loader.add_resource('settings_window', preload("Windows/SettingsWindow.xml"))
	resource_loader.add_resource('add_mesh_popup', preload("Windows/AddMeshPopup.xml"))
	resource_loader.add_resource('text_editor', preload("Windows/TextEditor.xml"))
	
	SettingsWindow = resource_loader.get_resource('settings_window').instance()
	AddMeshPopup = resource_loader.get_resource('add_mesh_popup').instance()
	
	text_editor = resource_loader.get_resource('text_editor').instance()
	
	add_custom_control(CONTAINER_SPATIAL_EDITOR_MENU, toolbar_menu)
	popup_menu.connect('item_pressed', self, '_popup_signal')

func _get_plugins_folder():
	var path = OS.get_data_dir()
	path = path.substr(0, path.find_last('/'))
	path = path.substr(0, path.find_last('/'))
	return path

func update_menu():
	var custom_meshes_submenu = PopupMenu.new()
	custom_meshes_submenu.set_name('custom_meshes')
	popup_menu.add_child(custom_meshes_submenu)
	
	popup_menu.clear()
	custom_meshes_submenu.clear()
	
	print(popup_menu.get_item_count())
	print(custom_meshes_submenu.get_item_count())
	
	popup_menu.add_item('Add Plane')
	popup_menu.add_item('Add Cube')
	popup_menu.add_item('Add Cylinder')
	popup_menu.add_item('Add Sphere')
	popup_menu.add_item('Add Cone')
	popup_menu.add_item('Add Capsule')
	
	popup_menu.add_separator()
	#popup_menu.add_item('Immediate Geometry')
	popup_menu.add_item('Add Heigthmap')
	popup_menu.add_separator()
	popup_menu.add_submenu_item('Custom Meshes', 'custom_meshes')
	popup_menu.add_separator()
	popup_menu.add_check_item('Custom Mesh')
	popup_menu.add_separator()
	popup_menu.add_item('Settings')
	
	if not custom_meshes_submenu.is_connected("item_pressed", self, "_add_custom_mesh"):
		custom_meshes_submenu.connect("item_pressed", self, "_add_custom_mesh")
	
	var dir = Directory.new()
	var path_to_config = _get_plugins_folder() + '/plugins/Add Primitives/Custom Meshes/Register.txt'
	var config_file = ConfigFile.new()
	if dir.file_exists(path_to_config):
		config_file.load(path_to_config)
		
		for key in config_file.get_section_keys('Custom Scripts'):
			custom_mesh_scripts['Add ' + key.substr(0, key.find_last('.'))] = config_file.get_value('Custom Scripts', key)
			key = key.substr(0, key.find_last('.'))
			var instance = load(custom_mesh_scripts['Add ' + key]).new()
			
			if instance.has_method('add_to_menu'):
				instance.add_to_menu(popup_menu, key)

func _popup_signal(id):
	var command = popup_menu.get_item_text(popup_menu.get_item_index(id))
	var root = get_tree().get_edited_scene_root()
	
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
			var cylinder = exp_build_cylinder(1, 2, 16)
			exp_add_mesh(cylinder)
			_add_mesh_popup(AddMeshPopup, 'cylinder')
		else:
			var cylinder = build_cylinder(16, 2)
			surface_tool(cylinder)
	
	elif command == 'Add Sphere':
		if experimental_builder:
			var sphere = exp_build_sphere(1, 16)
			exp_add_mesh(sphere)
			if root != null:
				_add_mesh_popup(AddMeshPopup, 'sphere')
		else:
			pass
	
	elif command == 'Add Cone':
		if experimental_builder:
			var cone = exp_build_cone(1, 2, 12, 4)
			exp_add_mesh(cone)
			if root != null:
				_add_mesh_popup(AddMeshPopup, 'cone')
		else:
			pass
	
	elif command == 'Add Capsule':
		if experimental_builder:
			var capsule = exp_build_capsule(1, 16, 1)
			exp_add_mesh(capsule)
			if root != null:
				_add_mesh_popup(AddMeshPopup, 'capsule')
		else:
			pass
	
	elif command == 'Add Heigthmap':
		if experimental_builder:
			if Heigthmap:
				heigthmaps.append(exp_build_heigthmap(null))
				images.append(null)
				h_values.append([])
				
				var shr = ''
				var shader = MaterialShader.new()
				var material = ShaderMaterial.new()
				for i in _shader:
					shr += i
				shader.set_code('', shr, '')
				material.set_shader(shader)
				
				heigthmaps[counter].set_material_override(material)
				exp_add_heigthmap(heigthmaps[counter])
				
				counter += 1
				
				
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
	
	elif command == 'Custom Mesh':
		var button_array = text_editor.get_node('Menu')
		if not button_array.is_connected('button_selected', self, '_sel_script'):
			button_array.connect('button_selected', self, '_sel_script')
		
		var idx = popup_menu.get_item_index(id)
		
		#if not text_editor.is_inside_tree():
		var dir = Directory.new()
		var file = File.new()
		var path = _get_plugins_folder()
		
		if not text_editor.is_inside_tree():
			if dir.dir_exists(path + '/plugins/Add Primitives/Custom Meshes'):
				path += '/plugins/Add Primitives/Custom Meshes'
				if dir.file_exists(path + '/StaticMeshBuilder.gd'):
					add_custom_control(3, text_editor)
				else:
					path = path.substr(0, path.find_last('/'))
					if dir.file_exists(path + '/Core/StaticMeshBuilder.gd'):
						var paste_folder = path + '/Custom Meshes/StaticMeshBuilder.gd'
						dir.copy(path + '/Core/StaticMeshBuilder.gd', paste_folder)
					else:
						pass
			
		else:
			text_editor.free()
			text_editor = preload("Windows/TextEditor.xml").instance()
		

#Script Selection
func _sel_script(button):
	var menu = text_editor.get_node('Menu')
	
	if menu.get_button_text(button) == 'File':
		var file_dialog = FileDialog.new()
		if not file_dialog.is_inside_tree():
			add_child(file_dialog)
		file_dialog.set_mode(0)
		file_dialog.set_access(2)
		
		file_dialog.set_title('Select a Script')
		file_dialog.set_size(Vector2(280, 360))
		file_dialog.add_filter("*.gd ; GDScript")
		
		file_dialog.set_current_dir(_get_plugins_folder() + '/plugins/Add Primitives/Custom Meshes')
		file_dialog.set_current_path(_get_plugins_folder() + '/plugins/Add Primitives/Custom Meshes')
		
		if file_dialog.is_hidden():
			file_dialog.show()
			file_dialog.popup_centered()
		else:
			file_dialog.popup_centered()
		
		if not file_dialog.is_connected("file_selected", self, "_open_script"):
			file_dialog.connect("file_selected", self, "_open_script")
	
	elif menu.get_button_text(button) == 'Run':
		_run_script()
		
#Open, reload, and run script
func _open_script(path):
	var file = File.new()
	var file_name = path.substr(path.find_last('/') + 1, path.length() - 1)
	
	var text_edit = TextEdit.new()
	text_edit.set_name(file_name)
	
	file.open(path, 1)
	text_edit.set_text(file.get_as_text())
	file.close()
	
	var tab_container = text_editor.get_node('TabContainer')
	if custom_meshes.find(path) < 0:
		custom_meshes.append(path)
		if not text_edit.is_a_parent_of(tab_container):
			tab_container.add_child(text_edit)
	else:
		var conf_dialog = ConfirmationDialog.new()
		if not conf_dialog.is_inside_tree():
			add_child(conf_dialog)
		
		conf_dialog.set_size(Vector2(200, 80))
		conf_dialog.set_text("This script was already loaded,\n reload?")
		
		if conf_dialog.is_hidden():
			conf_dialog.show()
			conf_dialog.popup_centered()
		else:
			conf_dialog.popup_centered()
		
		if not conf_dialog.is_connected("confirmed", self, "_reload_script"):
			conf_dialog.connect("confirmed", self, "_reload_script")
			script_to_reload = path
		

func _reload_script():
	var file = File.new()
	var node = script_to_reload.substr(script_to_reload.find_last('/') + 1, script_to_reload.length() - 1)
	
	var text_edit = text_editor.get_node('TabContainer/' + node)
	
	file.open(script_to_reload, 1)
	text_edit.set_text(file.get_as_text())
	file.close()

func _run_script():
	var tab_container = text_editor.get_node('TabContainer')
	
	var current_tab
	var text_edit
	
	if tab_container.get_child_count() > 0:
		current_tab = tab_container.get_current_tab()
		text_edit = tab_container.get_node(tab_container.get_tab_title(current_tab))
	
	var file = File.new()
	
	if file.file_exists(custom_meshes[current_tab]):
		file.open(custom_meshes[current_tab], 3)
		file.store_string(text_edit.get_text())
		var source_code = file.get_as_text()
		file.close()
		
		var custom_script = load(custom_meshes[current_tab])
		
		custom_script.reload()
		
		custom_script = custom_script.new()
		
		if custom_script.has_method('build_mesh'):
			var mesh = custom_script.build_mesh()
			exp_add_mesh(mesh)
			
		if custom_script.has_method('add_to_menu') and not custom_script.has_method('register'):
			var name = text_edit.get_name()
			name = name.substr(0, name.find_last('.'))
			custom_script.add_to_menu(popup_menu, name)
			
			if not custom_mesh_scripts.has('Add ' + name):
				custom_mesh_scripts['Add ' + name] = custom_meshes[current_tab]
				
		if custom_script.has_method('register'):
			var path_to_config = _get_plugins_folder() + '/plugins/Add Primitives/Custom Meshes'
			
			var config_file = ConfigFile.new()
			
			if file.file_exists(path_to_config + '/Register.txt'):
				config_file.load(path_to_config + '/Register.txt')
			else:
				file.open(path_to_config + '/Register.txt', 2)
				file.store_string('[Custom Scripts]\n')
				file.close()
				
				config_file.load(path_to_config + '/Register.txt')
			
			config_file.set_value('Custom Scripts', text_edit.get_name(), custom_meshes[current_tab])
			config_file.save(path_to_config + '/Register.txt')
			
			update_menu()

func _add_custom_mesh(id):
	var submenu = popup_menu.get_node('custom_meshes')
	var command = submenu.get_item_text(submenu.get_item_index(id))
	
	if custom_mesh_scripts.has(command):
		var script = load(custom_mesh_scripts[command])
		script = script.new()
		if script.has_method('build_mesh'):
			var mesh
			if not has_method('mesh_parameters'):
				mesh = script.build_mesh()
			else:
				mesh = script.build_mesh('default')
			exp_add_mesh(mesh)
			
			if script.has_method('mesh_parameters'):
				_add_mesh_popup(AddMeshPopup, command)
		else:
			pass
	
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
	
	var check_smooth = window.get_node('Smooth')
	check_smooth.set_pressed(true)
	var check_reverse = window.get_node('Reverse')
	check_reverse.set_pressed(false)
	
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
	
	elif custom_mesh_scripts.has(mesh):
		current_mesh = mesh
		var script = load(custom_mesh_scripts[mesh]).new()
		
		parameters = []
		
		parameters = script.mesh_parameters(settings)
		
func _refresh():
	var settings = AddMeshPopup.get_node('Settings')
	var check_smooth = AddMeshPopup.get_node('Smooth')
	var check_reverse = AddMeshPopup.get_node('Reverse')
	
	var smooth = check_smooth.is_pressed()
	var reverse = check_reverse.is_pressed()
	
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
		mesh_temp = exp_build_cylinder(values[0], values[1], values[2], values[3], smooth, reverse)
	
	elif current_mesh == 'sphere':
		var parameters = root.get_children()
		values.append(parameters.get_range(1))
		parameters = parameters.get_next()
		values.append(parameters.get_range(1))
		parameters = parameters.get_next()
		values.append(parameters.get_range(1))
		mesh_temp = exp_build_sphere(values[0], values[1], values[2], smooth, reverse)
		
	elif current_mesh == 'cone':
		var parameters = root.get_children()
		values.append(parameters.get_range(1))
		parameters = parameters.get_next()
		values.append(parameters.get_range(1))
		parameters = parameters.get_next()
		values.append(parameters.get_range(1))
		mesh_temp = exp_build_cone(values[0], values[1], values[2], smooth, reverse)
	
	elif current_mesh == 'capsule':
		var parameters = root.get_children()
		values.append(parameters.get_range(1))
		parameters = parameters.get_next()
		values.append(parameters.get_range(1))
		parameters = parameters.get_next()
		values.append(parameters.get_range(1))
		mesh_temp = exp_build_capsule(1, values[1], values[0], values[2], smooth, reverse)
	
	elif custom_mesh_scripts.has(current_mesh):
		root = root.get_children()
		while true:
			values.append(root.get_range(1))
			root = root.get_next()
			if root == null:
				break
		print(values)
		
		var custom_build = load(custom_mesh_scripts[current_mesh]).new()
		mesh_temp = custom_build.build_mesh(values, smooth, reverse)
	
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
	resource_loader.free()
	resource_loader = null
	text_editor.free()
	text_editor = null
	popup_menu.free()
	popup_menu = null
	toolbar_menu.free()
	toolbar_menu = null
	
	set_process(false)