#!/vendor/bin/sh
#
# Copyright (c) 2024, Motorola Mobility LLC,  All rights reserved.
#
# The purpose of this script is to annotate panic dumps with useful information
# about the context of the event.
#

export PATH=/vendor/bin:/system/bin:$PATH

build_type=`getprop ro.build.type`
expdb=`getprop vendor.debug.mtk.aeev.db`
aee_dir="/data/vendor/aee_exp"
db_history="/data/vendor/aee_exp/db_history"
current_db_path=$(echo "$expdb" | awk -F ':' '{print $2}')
current_db_name=$(basename "$current_db_path")
limit_size_in_mb=20

if [ $build_type == "user" ] && [ -n "$expdb" ]; then
	kp_type=("KE" "HWT" "HW_Reboot" "ManualMRDump" "HANG" "OCP_reboot")
	kp_found=0

	for va in ${kp_type[@]}; do
		has_str=$(cat $db_history | grep "${va}")
		if [[ "$has_str" != "" ]]; then
			current_db_record=$(cat $db_history | grep "${current_db_name}")
			kp_found=1
			break
		fi
	done

	if [ $kp_found == 0 ]; then
		exit 0
	fi

	echo "trigger=$kp_type,expdb=$current_db_record" >> /data/vendor/dontpanic/last_kmsg

	if [ ! -d /data/vendor/dontpanic/aee_exp ]
	then
		mkdir /data/vendor/dontpanic/aee_exp
	fi
	chmod -R 0750 /data/vendor/dontpanic/aee_exp/

	target_dir=/data/vendor/dontpanic/aee_exp/$current_db_name
	if [ ! -d $target_dir ]
	then
		mkdir $target_dir
	fi
	chmod -R 0750 $target_dir
	for file in "$current_db_path"/*; do
		if [ -f "$file" ]; then
			file_size=$(stat -c%s "$file")
			file_size_mb=$(echo "$file_size / 1024 / 1024" | bc)
			if [ "$file_size_mb" -le $limit_size_in_mb ]; then
				cp "$file" "$target_dir/"
				echo "copied $file to $target_dir/"
			else
				echo "ignored $file due to file size(${file_size_mb}M) is larger than ${limit_size_in_mb}M"
			fi
		fi
	done

	#cp -RF $current_db /data/vendor/dontpanic/aee_exp/
	chown -R root:log /data/vendor/dontpanic/aee_exp/
	chmod -R 0750 /data/vendor/dontpanic/aee_exp/

	exit 0
fi
