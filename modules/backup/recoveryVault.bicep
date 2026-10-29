param vaultName string
param location string
param sku string = 'Standard'

resource vault 'Microsoft.RecoveryServices/vaults@2024-04-01' = {
  name: vaultName
  location: location

  sku: {
    name: sku
  }

  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

output vaultId string = vault.id
output vaultName string = vault.name


