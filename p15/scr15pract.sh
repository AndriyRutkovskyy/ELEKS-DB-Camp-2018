#!/bin/bash

user=$(whoami)
host=$(hostname)

mkdir -p logs arch

log_path="logs"
arch_path="arch"

getFilesCount(){
	logx=( $(ls $log_path |grep json) )
	archx=( $(ls $arch_path |grep tar) )
}

arch_expired_time=120 # in task 1 day

logTemplate='{"datetime":"%s","user":"%s","host":"%s","cpuInfo":{"user":"%s", "nice":"%s", "system":"%s", "idle":"%s","iowait":"%s","irq":"%s","softirq":"%s","steal":"%s"},"cpuUsage":"%s","status":"%s"}'

createFile(){
	local datetime=$(date +%F_%H:%M:%S)
	local fileName="$log_path/$(date +%s).json"
		    
	touch "$fileName"

	getCpuInfo $fileName

	chmod 640 $fileName
}

archivateLogs(){
	
	arch_file="$arch_path/$(date +%s).tar"
	
	for file in ${logx[@]} ; do
		tar -uf $arch_file "$log_path/$file"
		rm "$log_path/$file"
	done

	echo "===> Archive $arch_file was created!!!" 
}

deleteOldArchive(){
	
	cur_time=$(date +%s)

	for arch_file in ${archx[@]}; do
		
		filename=${arch_file%%.*}
		
		if [ $(( $cur_time-$filename )) -gt $arch_expired_time ]; then
			rm "$arch_path/$arch_file"
			echo "===> Archive $arch_file was removed !!!"
		fi
	done
}

getCpuInfo(){

	CPU=(`cat /proc/stat | grep '^cpu '`) # Get the total CPU statistics.
	unset CPU[0]                          # Discard the "cpu" prefix.

	cpuUser=${CPU[0]}
	nice=${CPU[1]}
	system=${CPU[2]}
	idle=${CPU[3]}
	iowait=${CPU[4]}
	irq=${CPU[5]}
	softirq=${CPU[6]}
	steal=${CPU[7]}

	let "tCPUtime=$cpuUser+$nice+$system+$idle+$iowait+$irq+$softirq+$steal"
	let "tCPUidle=$idle+$iowait"
	let "tCPUusage=$tCPUtime-$tCPUidle"

	tCPUsage=$(echo "$tCPUusage * 100 / $tCPUtime" | bc)

	if [ $tCPUsage -ge 50 ]; then
		status="CRITICAL"
	else
		status="NORMAL"
	fi

	local infoJsonF=$(printf "$logTemplate" "$datetime" "$user" "$host" "$cpuUser" "$nice" "$system" "$idle" "$iowait" "$irq" "$softirq" "$steal" "$cpuUsage" "$status")

	echo $infoJsonF > $1

	if [ $? -eq 0 ]; then
	  echo "===> $(date) log $1 created"
	else
	  echo "===> $(date) something wrong"
	fi
}

while true; 
do
	getFilesCount

	deleteOldArchive && sleep 1

	if [ ${#logx[@]} -ge 10 ]; then 
		archivateLogs && sleep 1
	fi

	createFile && sleep 2
done
