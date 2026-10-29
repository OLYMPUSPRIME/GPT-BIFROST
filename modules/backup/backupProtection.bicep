@description('VM Name')
param vmName string

@description('VM Resource Group')
param vmResourceGroup string

@description('Recovery Services Vault Name')
param vaultName string

@description('Backup Policy Name')
param policyName string

resource vault 'Microsoft.RecoveryServices/vaults@2023-02-01' existing = {
  name: vaultName
}

resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' existing = {
  scope: resourceGroup(vmResourceGroup)
  name: vmName
}

resource protectedItem 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2023-02-01' = {
  name: '${vaultName}/Azure/IaasVMContainer;iaasvmcontainerv2;${vmResourceGroup};${vmName}/VM;iaasvmcontainerv2;${vmResourceGroup};${vmName}'

  properties: {
    protectedItemType: 'Microsoft.Compute/virtualMachines'

    sourceResourceId: vm.id

    policyId: resourceId(
      'Microsoft.RecoveryServices/vaults/backupPolicies',
      vaultName,
      policyName
    )
  }
}

output backupProtectionId string = protectedItem.id
