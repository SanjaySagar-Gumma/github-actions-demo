echo "Connection"
$location="East US"
$resourceGroup="Windapp"
$login="azureuser"
$password="AlfaKumar@1234"
$storage="gitstorage8"
$container="gitcontainer"


az storage account create --name $storage --resource-group $resourceGroup --location "$location" --sku Standard_LRS
echo "Creating $container on $storage..."
key=$(az storage account keys list --account-name $storage --resource-group $resourceGroup -o json --query [0].value | tr -d '"')
az storage container create --name $container --account-key $key --account-name $storage