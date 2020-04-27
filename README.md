# Terraform State Storage in Azure Setup Action

To learn how this action was built, see "[Creating a Docker container action](https://help.github.com/en/articles/creating-a-docker-container-action)" in the GitHub Help documentation.

This action was based on the following tutorial;  
[Store Terraform state in Azure Storage](https://docs.microsoft.com/en-us/azure/terraform/terraform-backend) 

A dedicated resource group `"rg-terraform-<shortname>"` will contain the following resources;  
### A Key Vault
`"kv-tf-<shortname>"`
### A Storage Account
`"stterraform<shortname>"` **storage accounts have naming restrictions lowercase alphanumeric 24 long **  

A container call `"tfstate"` which terrafrom will use to store its state.  
For terraform to work, we will store the storage account key in our key vault named `"terraform-backend-key"`  
When using terraform you will need to export the key as such;
```bash
export ARM_ACCESS_KEY=$(az keyvault secret show --name terraform-backend-key --vault-name kv-tf-<shortname> --query value -o tsv)
```



## Inputs

### `shortName`

**Required** The shortname of the terraform project.  [alphanumeric][13 long]. i.e.  `"lunchmeat"`.

### `location`

**Required** The azure location. i.e.  `"eastus2"`.

### `creds`  

**Required** The azure credentials that is compliant with `"azure/login@v1"`.
Please follow these instructions for setting the `"AZURE_CREDENTIALS"`  
[github actions azure login](https://github.com/Azure/login)  

### `tags`

**Required** key=value key=value pairs ```[NO SPACES IN VALUES]```.   i.e.  ``` tags: 'owner=Firstname_Lastname application=cool-name'```.


## Outputs

### `storage_account_name`

The storage account name that was created.

### `container_name`

The storage container name that was created.

### `secret_name`

The secret name that was created.

### `keyvault_name`

The keyvault name that was created.
    
    
## Example usage

[test yaml](.github/workflows/test.yml)  

```yaml
jobs:
   hello_world_job:
    runs-on: ubuntu-latest
    steps:

    - name: 'github checkout'
      uses: actions/checkout@v1

    - name: Hello world action step
      id: hello
      uses: ./
      with:
        shortName: 'lunchMeat'
        location: 'eastus2'
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    # Use the output from the `hello` step

    - name: Get the output time
      shell: bash
      run: |
        echo "The time was ${{ steps.hello.outputs.time }}"
        echo "The storage_account_name was:   '${{ steps.hello.outputs.storage_account_name }}'"
        echo "The container_name was:         '${{ steps.hello.outputs.container_name }}'"
        echo "The secret_name was:            '${{ steps.hello.outputs.secret_name }}'"
        echo "The keyvault_name was:          '${{ steps.hello.outputs.keyvault_name }}'"
```

## Downstream usage
Once you setup terraform state storage you will need to export the storage account key so that terraform can write to azure storage.  

You have to first so an `"az login"` with an account that has access to the storage account and set the `"subscription"`.  

```bash
export ARM_ACCESS_KEY=$(az keyvault secret show --name terraform-backend-key --vault-name kv-tf-<short-name> --query value -o tsv)
```
I use a service principal that has access to create resources so I export the following as well; 
```bash
export ARM_CLIENT_ID="00000000-0000-0000-0000-00000000"
export ARM_CLIENT_SECRET= "00000000-0000-0000-0000-00000000"
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-00000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-00000000"
```

Here is a terraform example; 
```
terraform {
  backend "azurerm" {
    # Due to a limitation in backend objects, variables cannot be passed in.
    # Do not declare an access_key here. Instead, export the
    # ARM_ACCESS_KEY environment variable.

    storage_account_name  = "stterraformheidi"
    container_name        = "tstate"
    key                   = "terraform.tfstate"
  }
}
# Configure the Azure provider
provider "azurerm" {
  version = "=1.44.0"
}
resource "azurerm_resource_group" "rg" {
  name     = var.az_resource_group_name
  location = var.az_resource_group_location
}
```
