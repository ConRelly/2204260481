#!/usr/bin/python
# -*- coding: UTF-8 -*-

# 此文件用于给以下的文件生产唯一ID
# 运行在 npc_items_custom.sh 脚本之后
# npc_items_custom.txt
# 

import os, sys

item_filename = 'npc_items_custom.txt'
target_filename = item_filename + '_old.txt'
output_filename = item_filename

# 删除旧文件
if os.path.exists(target_filename):
    os.remove(target_filename)
# 文件改名
os.rename(item_filename, target_filename)

target_file = open(target_filename, 'r', encoding='UTF-8')
output_file = open(output_filename, 'w', encoding='UTF-8')
 
item_count = 0 
item_start_id = 2000
new_line = ''
for line in target_file:
	word_list = line.split()
	new_line = line
	if len(word_list) > 1:
		if word_list[0].lower() == '"id"' :
			item_count = item_count + 1
			id = item_start_id + item_count
			new_line = '\t\t"ID" \t\t "%s" \n' % (id)
		
	output_file.write(new_line)


print('Item Count: %d' % (item_count))
target_file.close()
output_file.close()
	

	


import os
os.system('pause')