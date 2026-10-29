param location string

param gatewayName string

param vnetName string

param gatewaySubnetName string

param gatewaySku string = 'VpnGw1AZ'

resource existingVnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: vnetName
}

resource existingSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = {
  parent: existingVnet
  name: gatewaySubnetName
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: '${gatewayName}-pip'

  location: location

  sku: {
    name: 'Standard'
  }
    zones: [
          '1'
        ]

  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource vnetGateway 'Microsoft.Network/virtualNetworkGateways@2023-04-01' = {
  name: gatewayName

  location: location

  properties: {
    ipConfigurations: [
      {
        name: 'gwIpConfig'

        properties: {
          subnet: {
            id: existingSubnet.id
          }

          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]

    gatewayType: 'Vpn'

    vpnType: 'RouteBased'

    sku: {
      name: gatewaySku
      tier: gatewaySku
    }

    enableBgp: false
  }
}

output gatewayId string = vnetGateway.id
output gatewayNameOut string = vnetGateway.name
