param location string
param storageAccountName string
@description('Name of the storage account')
param tags object
@description('Name of the blob container')
param containerName string = 'mycontainer' // default container name



// // Optional tags (recommended for production)
// param tags object = {
//   environment: 'dev'
//   owner: 'krishnakant'
// }

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: tags

  sku: {
    name: 'Standard_LRS'   // cost-effective
  }

  kind: 'StorageV2'

  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'          // ✅ security
    supportsHttpsTrafficOnly: true       // ✅ HTTPS only
    allowBlobPublicAccess: false         // ✅ block public access
  }
}

// ✅ Optional: Blob container
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: containerName
  properties: {
    publicAccess: 'None'
  }
}

// Outputs
output storageAccountId string = storageAccount.id
output storageAccountNameOut string = storageAccount.name
output containerName string = container.name






















// az sig image-version create \
//   --resource-group NetworkWatcherRG \
//   --gallery-name testurl \
//   --gallery-image-definition myImage \
//   --gallery-image-version 1.0.0 \
//   --location westus \
//   --managed-image "/subscriptions/5853a972-d620-40f8-8547-c6549c33c839/providers/Microsoft.Compute/images/tempImage"
// ``
