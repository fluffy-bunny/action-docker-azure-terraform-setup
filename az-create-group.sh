#!/bin/sh -l
die () {
    echo >&2 "$@"
    echo "die"
    exit 1
}
# This works
# az group create --name "rg-terraform-lionking" --location "eastus2" --tags "a=b" "c=a dog"

REQUIRED_ARGS=3
[ "$#" -eq $REQUIRED_ARGS ] || die "$REQUIRED_ARGS argument required, $# provided"
 bash --version

resource_group_name=$1  
location=$2
tags=$3

echo "resource_group_name :" $resource_group_name
echo "location: "            $location
echo "tags: "                $tags

az group create --name "$resource_group_name" --location "$location"  --tags $tags



