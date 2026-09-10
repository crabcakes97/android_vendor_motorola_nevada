#!/vendor/bin/sh

PATH=/sbin:/vendor/sbin:/vendor/bin:/vendor/xbin
export PATH

scriptname=${0##*/}

notice()
{
	echo "$*"
	echo "$scriptname: $*" > /dev/kmsg
}


# First check what was set already
mot_model=`getprop persist.vendor.mot.model_for_attestation`
notice "persist.vendor.mot.model_for_attestation=[$mot_model]"

# If empty this is first boot set to ro.product.vendor.model
if [[ -z $mot_model ]]; then
	mot_model=`getprop ro.product.vendor.model`
	notice "Setting persist.vendor.mot.model_for_attestation to [$mot_model]"
	# Need to set persist if it was empty
	setprop persist.vendor.mot.model_for_attestation "$mot_model"
fi

# Exit if this is a commerical unit. All prototype start with N
serialno=`getprop ro.vendor.boot.serialno`
if  [[ $serialno != N* ]] && [[ $serialno != n* ]]; then
	#No action needed
	exit 0;
fi

# Run only on user builds
# Exit if bootmode is not normal (factory etc)
# Check if mot_attest_check binary exists
buildtype=`getprop ro.vendor.build.type`
bootmode=`getprop ro.bootmode`
if  [[ $bootmode != "normal" ]] || [[ $buildtype != "user" ]] || [[ ! -f /vendor/bin/mot_attest_check ]]; then
	#No action needed
	exit 0;
fi


# Verify if current set model is good
if [[ ! -z $mot_model ]]; then
	notice "Checking $mot_model"
	status=`LD_LIBRARY_PATH=/vendor/lib64/hw:/vendor/lib/hw:/vendor/lib64/alt /vendor/bin/mot_attest_check  --tee --verify_model "$mot_model" | grep "Attestation check result" |cut -d "=" -f2- | tr -d '[:space:]'`

	if [[ $status == "0" ]]; then
		notice "$mot_model passed $status"
		#no need to iterate through the list
		exit 0
	fi
fi

# check if list file provided
if [[ $# -eq 1 ]]; then
	list_file=$1
else
	exit 1
fi

# iterate through the list to identify
status="1"
if [[ -f $list_file ]]; then
	while read -r model_id
	do
		notice "Checking $model_id"
		status=`LD_LIBRARY_PATH=/vendor/lib64/hw:/vendor/lib/hw:/vendor/lib64/alt /vendor/bin/mot_attest_check  --tee --verify_model "$model_id" | grep "Attestation check result" |cut -d "=" -f2- | tr -d '[:space:]'`

		if [[ $status == "0" ]]; then
			#notice "$model_id passed $status"
			# No need to iterate further
			break
		fi

	done < $list_file
	if [[ $status == "0" ]]; then
		notice "Setting persist.vendor.mot.model_for_attestation to [$model_id]"
		setprop persist.vendor.mot.model_for_attestation "$model_id"
	fi
else
	exit 2
fi

exit 0

