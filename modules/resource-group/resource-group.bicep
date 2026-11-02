targetScope = 'subscription'

@description('Azure Resource Group name.')
param name string

@description('Azure region for the Resource Group.')
param location string

@description('Resource Group tags.')
param tags object = {}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: name
  location: location
  tags: tags
}

output resourceGroupName string = resourceGroup.name
output resourceGroupId string = resourceGroup.id
