param location string
param vmName string
param adminUsername string
param vmSize string
param sshPublicKey string
param image object
param osDisk object
param networkInterfaceName string
param tags object

resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' existing = {
  name: networkInterfaceName
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
        caching: osDisk.caching
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
}

output vmId string = vm.id
output vmNameOut string = vm.name
output networkInterfaceId string = nic.id
output networkInterfaceNameOut string = nic.name
