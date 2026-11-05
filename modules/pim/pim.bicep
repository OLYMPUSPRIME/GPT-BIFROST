targetScope = 'subscription'

// Creates an Azure Resource PIM eligibility schedule request only.
// Entra directory role and PIM Group policy writes require Graph API logic.

@description('Microsoft Entra Object ID of eligible principal.')
param principalId string
@description('Full Azure role definition resource ID.')
param roleDefinitionId string
@allowed(['AdminAssign', 'AdminUpdate', 'AdminRemove', 'AdminExtend', 'AdminRenew'])
param requestType string = 'AdminAssign'
param justification string
param duration string = 'P30D'
param startDateTime string = utcNow('yyyy-MM-ddTHH:mm:ssZ')
param requestName string
param ticketNumber string
param ticketSystem string = 'Manual'

// Desired policy config passed from .bicepparam. The Azure Resource itself
// below does not apply these policy objects; policy API automation is needed.
param azureResourcePimPolicy object = {}
param entraRolePimPolicy object = {}
param groupPimPolicy object = {}
param pimAssignmentDefaults object = {}

resource eligibilityRequest 'Microsoft.Authorization/roleEligibilityScheduleRequests@2024-09-01-preview' = {
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

output eligibilityRequestId string = eligibilityRequest.id
output eligibilityRequestName string = eligibilityRequest.name
