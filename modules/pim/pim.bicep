targetScope = 'resourceGroup'

@description('Microsoft Entra Object ID of the eligible principal.')
param principalId string

@description('Principal type: User, Group, or ServicePrincipal.')
@allowed([
  'User'
  'Group'
  'ServicePrincipal'
])
param principalType string = 'User'

@description('Full subscription-scoped role definition resource ID.')
param roleDefinitionId string

@description('PIM eligibility justification / ticket reason.')
param justification string

@description('Eligibility duration ISO 8601, e.g. P90D.')
param duration string = 'P90D'

@description('Start time for PIM eligibility. Defaults to deployment UTC time.')
param startDateTime string = utcNow('yyyy-MM-ddTHH:mm:ssZ')

@description('Deterministic schedule request GUID.')
param requestName string

resource eligibleAssignment 'Microsoft.Authorization/roleEligibilityScheduleRequests@2022-04-01-preview' = {
  name: requestName
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: roleDefinitionId
    requestType: 'AdminAssign'
    justification: justification
    scheduleInfo: {
      startDateTime: startDateTime
      expiration: {
        type: 'AfterDuration'
        duration: duration
      }
    }
  }
}

output eligibilityRequestId string = eligibleAssignment.id
output eligibilityRequestName string = eligibleAssignment.name
