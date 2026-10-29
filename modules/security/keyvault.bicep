@description('Location')
param location string 
// @secure()
// @description('Admin Password')
// param adminPassword string
@description('Name of the Key Vault')
param keyVaultName string


// resource secretPassword 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = {
//   parent: keyVault
//   name: 'adminPassword'
//     properties:{
//     value:adminPassword
//   }
// }

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01'={
  location: location
  name: keyVaultName
  properties: {
    tenantId: subscription().tenantId
    enableRbacAuthorization: true // Enable RBAC and disable access policies
    sku: {
      name: 'standard'
      family: 'A'
    }
    // accessPolicies: [
    //   {
    //     tenantId: subscription().tenantId
    //     objectId: '' // Replace with actual object ID
    //     permissions: {
    //       secrets: [
    //         'get','list','set','delete'
    //       ]
    //     }
    //   }
    // ]
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    // enable when going for review
    enableSoftDelete:false
    // enablePurgeProtection: true



  }
} 

output keyVaultId string = keyVault.id
output keyVaultNameOut string = keyVault.name


