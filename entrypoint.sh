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

clientId=`echo $creds | jq --raw-output '.clientId'`
clientSecret=`echo $creds | jq --raw-output '.clientSecret'`
tenantId=`echo $creds | jq --raw-output '.tenantId'`

echo 'clientId:              '${clientId:0:4}'*********'
echo 'clientSecret:          '${clientSecret:0:4}'*********'
echo 'tenantId:              '${tenantId:0:4}'*********'

az login --service-principal -u $clientId -p $clientSecret --tenant $tenantId  

az account show 

SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
echo 'SUBSCRIPTION_ID: '$SUBSCRIPTION_ID

echo "==== Creating Resource Group: $RESOURCE_GROUP_NAME in Location: $LOCATION"
az group create \
    --name $RESOURCE_GROUP_NAME \
    --location $LOCATION


echo "====== Creating KEY VAULT:  $KV_NAME ================="
az keyvault create \
    --location $LOCATION \
    --name $KV_NAME \
    --resource-group $RESOURCE_GROUP_NAME
    
# Create storage account
az storage account create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $STORAGE_ACCOUNT_NAME \
    --sku Standard_LRS \
    --encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query [0].value -o tsv)
 
# Create blob container
az storage container create \
    --name $CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --account-key $ACCOUNT_KEY

echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
echo "container_name: $CONTAINER_NAME"


SECRET_NAME="terraform-backend-key"
echo "====== Setting Secret: $SECRET_NAME  in KeyVault:  $KV_NAME ================="
VALUE=$ACCOUNT_KEY
az keyvault secret set \
    -n $SECRET_NAME \
    --vault-name $KV_NAME \
    --value "$VALUE" \
    > /dev/null

echo 'export ARM_ACCESS_KEY=$(az keyvault secret show --name '$SECRET_NAME' --vault-name '$KV_NAME' --query value -o tsv)'


echo ::set-output name=storage_account_name::$STORAGE_ACCOUNT_NAME
echo ::set-output name=container_name::$CONTAINER_NAME
echo ::set-output name=secret_name::$SECRET_NAME
echo ::set-output name=keyvault_name::$KV_NAME


time=$(date)
echo ::set-output name=time::$time

