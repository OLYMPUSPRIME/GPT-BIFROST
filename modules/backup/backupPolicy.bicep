@description('Recovery Services Vault Name')
param vaultName string

@description('Backup Policy Name')
param policyName string

@description('Backup Time')
param backupTime string

resource vault 'Microsoft.RecoveryServices/vaults@2023-02-01' existing = {
  name: vaultName
}

resource backupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2023-02-01' = {
  parent: vault
  name: policyName

  properties: {
    backupManagementType: 'AzureIaasVM'

    // workloadType: 'VM'

    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'

      scheduleRunFrequency: 'Daily'

      scheduleRunTimes: [
        backupTime
      ]
    }

    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'

      dailySchedule: {
        retentionTimes: [
          backupTime
        ]

        retentionDuration: {
          count: 30
          durationType: 'Days'
        }
      }
    }
  }
}

output policyId string = backupPolicy.id
output policyNameOut string = backupPolicy.name
