#!/bin/bash
# Get files count to be created
echo Enter files count:
read count

path="/opt/"

sudo chmod 777 "$path" 

cd /opt/ && rm *.log && cd ~

i=1
while [ $i -le $count ]
do
	cur_date="$(date)"
	file="file_"$i"_"$cur_date".log"

	touch "$path$file"
	echo Log "$path$file" was created.
	i=$(( $i + 1 ))
done

echo "List of log files in $path :"
ls "$path"

