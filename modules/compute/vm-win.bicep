@description('Azure region for the Windows VM.')
param location string

@description('Azure VM resource name. Windows computerName must be 15 characters or fewer.')
param vmName string

@description('Windows guest computer name; maximum 15 characters.')
param computerName string

param adminUsername string

@secure()
@description('Local Windows administrator password. Supply through GitHub secret or secure deployment parameter.')
param adminPassword string

param vmSize string
param image object
param osDisk object
@description('Resource ID of the pre-created NIC.')
param networkInterfaceId string
param tags object

resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: computerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
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
          id: networkInterfaceId
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
