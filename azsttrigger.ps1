echo "Connection"
$location="East US"
$resourceGroup="Windapp"
$login="azureuser"
$password="AlfaKumar@1234"
$storage="gitstorage81"
$container="gitcontainer1"
$server="gitserverdemo1"
$database="gitdbdemo1"
$databasenew12="newgitdbdemo12"
$bacpac="backup.bacpac"


az storage account create --name $storage --resource-group $resourceGroup --location "$location" --sku Standard_LRS

echo "Creating $container on $storage..."
#$key=$(az storage account keys list --account-name $storage --resource-group $resourceGroup -o json --query [0].value | tr -d '"')
$key = az storage account keys list -n $storage --resource-group $resourceGroup --query [0].value -o tsv
az storage container create --name $container --account-key $key --account-name $storage

echo "Creating $server in $location..."
az sql server create --name $server --resource-group $resourceGroup --location "$location" --admin-user $login --admin-password $password
az sql server firewall-rule create --resource-group $resourceGroup --server $server --name AllowAzureServices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

echo "Creating $database..."
az sql db create --name $database --resource-group $resourceGroup --server $server --edition GeneralPurpose --sample-name AdventureWorksLT

echo "Backing up $database..."
az sql db export --admin-password $password --admin-user $login --storage-key $key --storage-key-type StorageAccessKey --storage-uri "https://$storage.blob.core.windows.net/$container/$bacpac" --name $database --resource-group $resourceGroup --server $server

echo "creating new database on same server"
az sql db create --name $databasenew12 --resource-group $resourceGroup --server $server --edition GeneralPurpose --sample-name AdventureWorksLT

#echo "import the back up into ne database"
#az sql db import --admin-password $password --admin-user $login --storage-key $key --storage-key-type StorageAccessKey --storage-uri https://$storage.blob.core.windows.net/$container/$bacpac --name $databasenew --resource-group $resourceGroup --server $server

echo "import the back up"
$SecurePass=ConvertTo-SecureString $password -AsPlainText -Force
$saskey = $key.ToString()
New-AzSqlDatabaseImport -ResourceGroupName $resourceGroup -ServerName $server -DatabaseName $databasenew12 -StorageKeyType StorageAccessKey -StorageKey $saskey -StorageUri https://$storage.blob.core.windows.net/$container/$bacpac -AdministratorLogin $login -AdministratorLoginPassword $SecurePass -Edition Standard -ServiceObjectiveName S3 -DatabaseMaxSizeBytes 1073741824
