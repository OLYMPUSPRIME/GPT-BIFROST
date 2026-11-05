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
@description('Eligibility duration using one of the supported ISO 8601 duration values listed below.')
@allowed(['PT1H', 'PT2H', 'PT3H', 'PT4H', 'PT5H', 'PT6H', 'PT8H', 'PT12H', 'PT24H', 'P1D', 'P2D', 'P3D', 'P5D', 'P7D', 'P10D', 'P14D', 'P15D', 'P21D', 'P30D', 'P45D', 'P60D', 'P90D', 'P120D', 'P180D', 'P270D', 'P365D', 'P1W', 'P2W', 'P3W', 'P4W', 'P1M', 'P2M', 'P3M', 'P4M', 'P6M', 'P9M', 'P12M', 'P1Y', 'P2Y'])
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
