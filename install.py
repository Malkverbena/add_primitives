#-*- coding:utf-8 -*-

import os
import shutil

__directory__ = "Add Primitives"

def main():
	wd = os.getcwd()
	
	src_path = os.path.join(wd, __directory__)
	
	if not os.path.exists(src_path):
		return
		
	# Unix
	env = os.getenv('HOME')
	name = '.godot'
	
	gd_path = os.path.join(env, name)
	
	if not os.path.exists(gd_path):
		return
		
	plugins_path = os.path.join(gd_path, "plugins")
	
	if not os.path.exists(plugins_path):
		return
		
	dst_path = os.path.join(plugins_path, __directory__)
	
	if os.path.exists(dst_path):
		shutil.rmtree(dst_path)
		
	shutil.copytree(src_path, dst_path)
	
if __name__ == '__main__':
	if os.name != 'posix':
		exit()
		
	main()
	

