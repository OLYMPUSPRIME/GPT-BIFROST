param location string
param publicIpName string
@allowed(['Static','Dynamic'])
param allocationMethod string
@allowed(['Basic','Standard'])
param sku string
param tags object = {}

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: publicIpName
  location: location
  sku: { name: sku }
  properties: { publicIPAllocationMethod: allocationMethod }
  tags: tags
}

output publicIpId string = publicIp.id
output publicIpNameOut string = publicIp.name
