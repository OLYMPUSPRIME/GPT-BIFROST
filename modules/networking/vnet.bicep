
@description('Azure region where the resources will be deployed.')
param location string

@description('Name of the Virtual Network (VNet) to be created.')
param vnetName string

@description('List of address spaces (CIDR ranges) for the Virtual Network.')
param addressPrefixes array

@description('Array of subnet configurations including subnet names and address prefixes.')
param subnets array

@description('Key-value pairs of tags to apply to the Virtual Network and associated resources.')
param tags object


resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
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

        // ✅ Optional NSG22          
          networkSecurityGroup: contains(subnet, 'nsgName') && !empty(subnet.nsgName) ? {
            id: resourceId(
              'Microsoft.Network/networkSecurityGroups',
              subnet.nsgName
            )
          } : null
          // ✅ Optional Route Table          
          routeTable: contains(subnet, 'routeTableName') && !empty(subnet.routeTableName) ? {
            id: resourceId(
              'Microsoft.Network/routeTables',
              subnet.routeTableName
            )
          } : null
       }
     }
   ]
 }
}


output subnetIds array = [
  for subnet in subnets: {
    name: subnet.name
    id: resourceId(
      'Microsoft.Network/virtualNetworks/subnets',
      vnet.name,
      subnet.name
    )
  }
] 
output vnetName string = vnet.name
output vnetId string = vnet.id
















