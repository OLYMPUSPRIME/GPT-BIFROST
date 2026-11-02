param location string
param nicName string
param vnetName string
param subnetName string
param publicIpName string
param attachPublicIp bool
param tags object = {}

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: vnet
  name: subnetName
}
resource publicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' existing = if (attachPublicIp) {
  name: publicIpName
}
resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: nicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [{
      name: 'ipconfig1'
      properties: {
        privateIPAllocationMethod: 'Dynamic'
        subnet: { id: subnet.id }
        publicIPAddress: attachPublicIp ? { id: publicIp.id } : null
      }
    }]
  }
}
output nicId string = nic.id
output nicNameOut string = nic.name
