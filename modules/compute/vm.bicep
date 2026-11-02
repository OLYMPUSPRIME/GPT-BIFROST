param location string
param vmName string
param adminUsername string
param vmSize string
param sshPublicKey string
param image object
param osDisk object
param subnetName string
param vnetName string
param networkInterfaceName string
param createPublicIp bool
param publicIpName string
@allowed([
  'Static'
  'Dynamic'
])
param publicIpAllocationMethod string
@allowed([
  'Basic'
  'Standard'
])
param publicIpSku string
param tags object

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = if (createPublicIp) {
  name: publicIpName
  location: location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIpAllocationMethod
  }
  tags: tags
}

resource existingVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}

resource existingSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: existingVnet
  name: subnetName
}

resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: networkInterfaceName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: existingSubnet.id
          }
          publicIPAddress: createPublicIp ? {
            id: publicIp.id
          } : null
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: image.publisher
        offer: image.offer
        sku: image.sku
        version: image.version
      }
      osDisk: {
        name: osDisk.name
        createOption: 'FromImage'
        diskSizeGB: osDisk.diskSizeGB
        managedDisk: {
          storageAccountType: osDisk.storageAccountType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
  dependsOn: [
    nic
  ]
}

output vmId string = vm.id
output vmNameOut string = vm.name
output networkInterfaceId string = nic.id
output publicIpId string = createPublicIp ? publicIp.id : ''
