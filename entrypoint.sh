#!/bin/sh -l
die () {
    echo >&2 "$@"
    echo "$ ./entrypoint.sh [SHORT_NAME] [LOCATION]"
    exit 1
}
REQUIRED_ARGS=3
[ "$#" -eq $REQUIRED_ARGS ] || die "$REQUIRED_ARGS argument required, $# provided"
 bash --version
echo "Positional Parameters"

echo '$1:           '$1
echo '$2:           '$2
echo '$3:           '$3

SHORT_NAME=$1
LOCATION=$2
creds=$3

length=${#SHORT_NAME}
if [ $length -lt 2 -o $length -gt 13 ] ;then
    echo "length invalid"
    die
fi
SHORT_NAME=`echo "$SHORT_NAME" | awk '{print tolower($0)}'`

 
echo $SHORT_NAME

MATCHES=`echo "$SHORT_NAME" | grep -iE '^[0-9a-zA-Z]*$' | wc -l`
if [ $MATCHES -eq 0 ]; 
    then
        die
    else 
        echo "SHORT_NAME: $SHORT_NAME is valid"
fi

RESOURCE_GROUP_NAME="rg-terraform-$SHORT_NAME"
CONTAINER_NAME="tstate"
STORAGE_ACCOUNT_NAME="stterraform$SHORT_NAME"
KV_NAME="kv-tf-$SHORT_NAME"

echo 'SHORT_NAME:           '$SHORT_NAME
echo 'LOCATION:             '$LOCATION
echo 'RESOURCE_GROUP_NAME:  '$RESOURCE_GROUP_NAME
echo 'CONTAINER_NAME:       '$CONTAINER_NAME
echo 'STORAGE_ACCOUNT_NAME: '$STORAGE_ACCOUNT_NAME
echo 'KV_NAME:              '$KV_NAME

client_id=`echo $creds | jq --raw-output '.clientId'`
clientSecret=`echo $creds | jq --raw-output '.clientSecret'`
tenantId=`echo $creds | jq --raw-output '.tenantId'`

echo 'client_id:             '$client_id
echo 'clientSecret:          '$clientSecret
echo 'tenantId:              '$tenantId

az login --service-principal -u $client_id -p $clientSecret --tenant $tenantId  

az account show 

time=$(date)
echo ::set-output name=time::$time
 