targetScope = 'resourceGroup'

@description('Microsoft Entra Object ID of the eligible principal.')
param principalId string

@description('Full role definition resource ID. For built-in roles, this is subscription-scoped.')
param roleDefinitionId string

@description('Justification for the PIM eligibility request.')
param justification string

@description('Eligibility duration in ISO 8601 format, e.g. P90D.')
param duration string = 'P90D'

@description('Deterministic schedule request GUID.')
param requestName string

@description('Ticket number.')
param ticketNumber string = ''

@description('Ticket system.')
param ticketSystem string = 'Jira'

@description('PIM eligibility start time in UTC. Defaults to deployment time.')
param startDateTime string = utcNow('yyyy-MM-ddTHH:mm:ssZ')

module eligibility './pim.bicep' = {
  name: 'pimEligibilityAssignment'
  params: {
    principalId: principalId
    roleDefinitionId: roleDefinitionId
    justification: justification
    duration: duration
    requestName: requestName
    ticketNumber: ticketNumber
    ticketSystem: ticketSystem
    startDateTime: startDateTime
  }
}

output eligibilityRequestId string = eligibility.outputs.eligibilityRequestId
output eligibilityRequestName string = eligibility.outputs.eligibilityRequestName
