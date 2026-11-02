param location string
param vnetName string
param addressPrefixes array
param subnets array
param tags object

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [
      for subnet in subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
          networkSecurityGroup: contains(subnet, 'nsgName') && !empty(subnet.nsgName) ? {
            id: resourceId('Microsoft.Network/networkSecurityGroups', subnet.nsgName)
          } : null
        }
      }
    ]
  }
}

output vnetNameOut string = vnet.name
output vnetId string = vnet.id
output subnetIds array = [
  for subnet in subnets: {
    name: subnet.name
    id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, subnet.name)
  }
]
