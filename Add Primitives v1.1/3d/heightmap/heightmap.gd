extends MeshInstance

export(ImageTexture) var heightmap setget set_heightmap, get_heightmap
export(float, 0.1, 25, 0.1) var Factor = 5 setget set_factor, get_factor
export(int, 1, 500) var Resolution = 32 setget set_resolution, get_resolution
export(int, 1, 200) var Size = 50 setget set_size, get_size

#utilites
func get_plugins_folder():
	var path = OS.get_data_dir()
	path = path.substr(0, path.find_last('/'))
	path = path.substr(0, path.find_last('/'))
	return path + '/plugins'
	
func _init():
#Fragment code########################################
	var fcode =\
"""uniform float factor = 1;

uniform texture heigthmap;
uniform texture high;
uniform texture low;

vec3 mask = tex(heigthmap, UV).xyz;
vec3 first_map = tex(low, UV).xyz;
vec3 second_map = tex(high, UV).xyz;

DIFFUSE = mix(first_map, second_map, mask/factor);"""
######################################################
	
	var shader = Shader.new()
	shader.set_code('', fcode, '')
	var material = ShaderMaterial.new()
	material.set_shader(shader)
	set_material_override(material)
	
func update_heightmap(heightmap, size, res, factor):
	var mesh_builder = load(get_plugins_folder() + '/Add Primitives v1.1/3d/heightmap/mesh.gd').new()
	
	var new_mesh
	
	if mesh_builder.has_method('build_mesh'):
		new_mesh = mesh_builder.build_mesh(heightmap, size, res, factor)
		
		set_mesh(new_mesh)
		
		if get_child_count():
			if get_child(0).get_type() == 'StaticBody':
				var col = get_child(0)
				#Get current static body parameters
				var parameters = []
				parameters.append(col.get_constant_linear_velocity())
				parameters.append(col.get_constant_angular_velocity())
				parameters.append(col.get_friction())
				parameters.append(col.get_bounce())
				
				remove_child(get_child(0))
				create_trimesh_collision()
				
				var col = get_child(0)
				#Set old static body parameters to new one
				col.set_constant_linear_velocity(parameters[0])
				col.set_constant_angular_velocity(parameters[1])
				col.set_friction(parameters[2])
				col.set_bounce(parameters[3])
		else:
			create_trimesh_collision()
		
#Setter functions
func set_heightmap(newvalue):
	heightmap = newvalue
	
	update_heightmap(self.heightmap, self.Size, self.Resolution, self.Factor)
	
func set_factor(newvalue):
	Factor = newvalue
	
	update_heightmap(self.heightmap, self.Size, self.Resolution, self.Factor)
	
func set_resolution(newvalue):
	Resolution = newvalue
	
	update_heightmap(self.heightmap, self.Size, self.Resolution, self.Factor)
	
func set_size(newvalue):
	Size = newvalue
	
	update_heightmap(self.heightmap, self.Size, self.Resolution, self.Factor)
	
#Getter functions
func get_heightmap():
	return heightmap
	
func get_factor():
	return Factor
	
func get_resolution():
	return Resolution
	
func get_size():
	return Size
	