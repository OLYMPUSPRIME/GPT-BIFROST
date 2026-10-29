targetScope = 'subscription'

@description('Microsoft Entra object ID of the user, group, or service principal that will receive eligible access.')
param principalId string

@description('Full Azure role definition resource ID, for example /subscriptions/<subscriptionId>/providers/Microsoft.Authorization/roleDefinitions/<roleGuid>.')
param roleDefinitionId string

@description('Reason for requesting eligible privileged access.')
param justification string

@description('Eligibility duration in ISO 8601 format, for example P90D or P365D.')
param duration string = 'P90D'

@description('Optional start date and time in UTC. Defaults to the current deployment time.')
param startDateTime string = utcNow('u')

@description('Optional request name. If omitted, a stable GUID is generated from the target scope, principal, and role.')
param requestName string = guid(subscription().id, principalId, roleDefinitionId, 'pim-eligibility')

@description('Principal type for the eligible assignment.')
@allowed([
  'User'
  'Group'
  'ServicePrincipal'
])
param principalType string = 'User'

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
