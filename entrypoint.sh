#!/bin/sh -l
die () {
    echo >&2 "$@"
    echo "$ ./entrypoint.sh [SHORT_NAME] [LOCATION]"
    exit 1
}
REQUIRED_ARGS=2
[ "$#" -eq $REQUIRED_ARGS ] || die "$REQUIRED_ARGS argument required, $# provided"

echo "Positional Parameters"

echo '$1:           '$1
echo '$2:           '$2

SHORT_NAME=$1
LOCATION=$2

 if [ $length -lt 2 -o $length -gt 13 ] ;then
    echo "length invalid"
    die
fi

if grep '^[-0-9a-zA-Z]*$' <<<$SHORT_NAME ;
  then 
    SHORT_NAME=${SHORT_NAME,,}
    echo ok;
  else 
    echo $SHORT_NAME must be ALPHANUMERIC;
    die
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

time=$(date)
echo ::set-output name=time::$time
