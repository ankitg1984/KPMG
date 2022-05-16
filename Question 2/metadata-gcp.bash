#!/bin/bash

URL_METADATA="http://metadata.google.internal/computeMetadata/v1"

while [ "$1" != "" ]; do
	case $1 in
                                                            ;;
        -d  | --disks )                 print_disks
                                                            ;;                                                            ;;	                                                        ;;
	    --all )                         print_all
	                                                        ;;
	    * )                             print_help && exit 1
	esac
	shift
done

#**
# @param index  disk index to fetch the details
# @param key  metric of the disk to fetch, like device-name, index, type & mode
# @return true (0) always
#
# prints the requested disk metrics
#
function _get_disk_value() {
    local index=$1 key=$2
    value=$(curl -fs -H "Metadata-Flavor: Google" "${URL_METADATA}/instance/disks/${index}/${key}")
    _print_response "$?" "${value}"
}

#**
# @return true (0) always
#
# prints all the attached disks along with their types
#
# shellcheck disable=SC2086,SC2207
function print_disks() {
    local disks
    echo "attached-disks: "
    disks=($(print_std_metric instance/disks/))
    for disk in "${disks[@]}"; do
        echo -e '\t' "device-index $(_get_disk_value ${disk} index):"
        echo -e '\t\t' "device-name: $(_get_disk_value ${disk} device-name)"
        echo -e '\t\t' "device-type: $(_get_disk_value ${disk} type)"
    done

}


#**
# @return true (0) always
#
# prints all the metrics
#
function print_all() {
    print_std_metric project/project-id project-id
    print_std_metric instance/image image
    print_std_metric instance/id instance-id
    print_resource_metric instance/machine-type instance-type
    print_std_metric instance/network-interfaces/0/ip local-ipv4
    print_std_metric instance/network-interfaces/0/access-configs/0/external-ip public-ipv4
    print_std_metric instance/network-interfaces/0/mac mac
    print_resource_metric instance/zone placement
    print_std_metric instance/description description
    print_disks
    print_resource_metric instance/attributes/instance-template instance-template
    print_resource_metric instance/attributes/created-by created-by
    print_std_metric instance/tags tags
    print_std_metric  instance/attributes/startup-script user-data
}

chk_config

#**
# command called in default mode, prints all the metrics
#
if [ "$#" -eq 0 ]; then
	print_all
fi

function print_help() {
    echo "use proper syntax"
}

#**
# @param metric_path  path of the metric to get
# @param metric_name  name of the metric to be displayed
# @return true (0) always
#
# get the requested standard metric and prints the metric based on the response
# eg: /project-id: <project-id>
#
function print_std_metric() {
    local metric_path=$1 metric_name=$2 response
    [[ -n ${metric_name} ]] && echo -n "${metric_name}: "
    response=$(curl -fs -H "Metadata-Flavor: Google" "${METADATA_URL}/${metric_path}")
    _print_response "$?" "${response}"
}

#**
# @param metric_path  path of the metric to get
# @param metric_name  name of the metric to be displayed
# @return true (0) always
#
# prints the metrics that has value as the last part of the resource
# eg: for /zone: projects/<project-id>/zones/us-central1-a
#
function print_resource_metric() {
    local metric_path=$1 metric_name=$2 response
    [[ -n ${metric_name} ]] && echo -n "${metric_name}: "
    response=$(print_std_metric "${metric_path}" | rev | cut -d '/' -f1 | rev)
    _print_response "$?" "${response}"
}

