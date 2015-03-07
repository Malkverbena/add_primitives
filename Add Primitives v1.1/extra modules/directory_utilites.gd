extends Directory

func is_extension(path, extension):
	if path.substr(path.find_last('.'), path.length()) == extension:
		return true
	else:
		return false

func get_scripts_from_list(list_files):
	var scripts = []
	
	for file in list_files:
		if is_extension(file, '.gd'):
			scripts.append(file)
		
	return scripts

func get_file_list(path):
	var list = []
	
	if dir_exists(path):
		open(path)
		list_dir_begin()
		
		while true:
			list.append(get_next())
			if list[list.size() - 1] != '.':
				continue
			else:
				list.append(get_next())
				break
				
		list_dir_end()
		
	return list

