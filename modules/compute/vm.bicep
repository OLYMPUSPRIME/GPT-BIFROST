param location string
param adminUsername string
param vmsize string
param privateIPAllocationMethod string
@secure()
param vmAdminPassword string
param vmName string
param tags object
output vmId string = vm.id
output vmNameOut string = vm.name
param subnetName string
param vnetName string
@description('Optional ASG Name')
param asgName string = ''
param keyVaultName string

resource nic 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {

          subnet: {
              id: existingSubnet.id
            }

          privateIPAllocationMethod:privateIPAllocationMethod
          

          applicationSecurityGroups: empty(asgName)
            ? null
            : [
                {
                  id: existingAsg.id
                }
              ]

        }
      }
    ]
  }
}


resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: vmName
  location: location
  tags: tags
  properties:{
    hardwareProfile: {
      vmSize: vmsize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: vmAdminPassword
     
    }


    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }

      // if you want to use the custom image then use below code and comment above imageReference code
      // storageProfile: {
      //   imageReference: {
      // // id: '/subscriptions/your-subscription-id/resourceGroups/your-resource-group/providers/Microsoft.VirtualMachineImages/images/your-custom-image' or 
      // id: imageId
      //   }
    // }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces:[
        {
        id:nic.id
      }
      ]
  }
}
}


resource existingVnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: vnetName
}

resource existingSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = {
  parent: existingVnet
  name: subnetName
}

resource existingAsg 'Microsoft.Network/applicationSecurityGroups@2023-04-01' existing = if (!empty(asgName)) {
  name: asgName
}


resource existingKv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
    name: keyVaultName
}
resource secretPassword 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = {
  parent: existingKv
  name: 'vmAdminPassword'
    properties:{
    value:vmAdminPassword
  }
}


