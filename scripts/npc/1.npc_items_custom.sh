
# 读取所有文本文件，并把他们的内容合并到一个新的文件
# 可以自定义新文件的头部内容、尾部内容
# 


files_path="./items/"
output_file="npc_items_custom.txt"
output_head='"DOTAAbilities"\n{'
output_foot="\n}"

#判断文件是否存在,如果存在的话就备份文件
if [[ ! -f "$output_file" ]]; then
	echo "文件不存在：${output_file}"
else
	echo "备份文件：${output_file}"
	mv "$output_file" "${output_file}_backup"
fi



# 自定义头部内容
echo -e "${output_head}" >> $output_file

##########################################################

# find $files_path -name "*.txt" |
# while read file_name;
# do
    # # 用.为分隔符只要文件名，去掉文件后缀
    # # echo "${file_name%.*}:" >> all.txt
    # cat "$file_name" >> $output_file
    # #echo "" >> all.txt
# done


all_content=""

filelist=()
while IFS= read -r -d $'\0'; do
    filelist+=("$REPLY")
done < <(find $files_path -name "*.txt" -print0)

for file_name in ${filelist[@]};
do
	file_content=$(cat "${file_name}")
	all_content=$all_content$file_content
done

# 输出内容
echo -e "$all_content" >> $output_file

##########################################################

# 自定义尾部内容
echo -e "${output_foot}" >> $output_file

python 2.npc_items_custom_id_generator.py