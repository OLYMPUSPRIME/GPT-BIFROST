targetScope = 'subscription'

// PIM eligibility is granted at the deployment subscription scope.
// This creates eligibility; it does not activate the role immediately.

@description('Microsoft Entra Object ID of the eligible user.')
param principalId string

@description('Full subscription-scoped Azure role definition resource ID.')
param roleDefinitionId string

@description('PIM role eligibility schedule request action.')
@allowed(['AdminAssign', 'AdminUpdate', 'AdminRemove', 'AdminExtend', 'AdminRenew', 'SelfActivate', 'SelfDeactivate', 'SelfExtend', 'SelfRenew'])
param requestType string = 'AdminAssign'

@description('Eligibility request justification.')
param justification string

@description('Eligibility duration in ISO 8601 format, for example P90D.')
param duration string = 'P90D'

@description('Start time in UTC. Defaults to the current deployment time.')
param startDateTime string = utcNow('yyyy-MM-ddTHH:mm:ssZ')

@description('Deterministic GUID for the eligibility schedule request.')
param requestName string

@description('Request/ticket number for audit.')
param ticketNumber string

@description('Ticket system name.')
param ticketSystem string = 'Jira'

resource eligibleAssignment 'Microsoft.Authorization/roleEligibilityScheduleRequests@2024-09-01-preview' = {
  name: requestName
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinitionId
    requestType: requestType
    justification: justification
    ticketInfo: {
      ticketNumber: ticketNumber
      ticketSystem: ticketSystem
    }
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
