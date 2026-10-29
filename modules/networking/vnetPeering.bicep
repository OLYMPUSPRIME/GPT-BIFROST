@description('Peering Name')
param peeringName string

@description('Source VNet Name')
param sourceVnetName string

@description('Remote VNet Name')
param remoteVnetName string

@description('Remote VNet Resource Group Name')
param remoteVnetResourceGroupName string

resource remoteVnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  scope: resourceGroup(remoteVnetResourceGroupName)
  name: remoteVnetName
}

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  name: '${sourceVnetName}/${peeringName}'

  properties: {
    remoteVirtualNetwork: {
      id: remoteVnet.id
    }

    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

output peeringId string = peering.id


