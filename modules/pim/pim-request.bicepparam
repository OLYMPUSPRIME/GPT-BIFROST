using './pim.bicep'

param principalId = '<REQUESTOR_ENTRA_OBJECT_ID>'
param roleDefinitionId = '/subscriptions/<SUBSCRIPTION_ID>/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
param requestType = 'AdminAssign'
param justification = 'Temporary privileged access - request <REQUEST_REFERENCE>'
param duration = 'P30D'
param startDateTime = utcNow('yyyy-MM-ddTHH:mm:ssZ')
param requestName = newGuid()
param ticketNumber = '<REQUEST_REFERENCE>'
param ticketSystem = 'Manual'

// Policy intent based on supplied screenshots. These are inputs/configuration,
// not applied by the Azure eligibility resource below by themselves.
param azureResourcePimPolicy = {
  owner: {
    requireMfa: true
    requireConditionalAccess: true
    requireApproval: true
    approverObjectIds: ['<OTHER_SUBSCRIPTION_OWNER_OBJECT_ID>']
    notificationsEnabled: true
    activationDuration: 'PT1H'
    requireJustification: true
    requireTicketInformation: true
  }
  userAccessAdministrator: {
    requireMfa: true
    requireConditionalAccess: true
    requireApproval: false
    approverObjectIds: []
    notificationsEnabled: true
    activationDuration: 'PT1H'
    requireJustification: true
    requireTicketInformation: true
  }
}
param entraRolePimPolicy = {
  globalAdministrator: {
    requireMfa: true
    requireConditionalAccess: true
    requireApproval: true
    approverObjectIds: ['<OTHER_GLOBAL_ADMIN_OBJECT_ID>']
    notificationsEnabled: true
    activationDuration: 'PT1H'
    requireJustification: true
    requireTicketInformation: true
  }
  exchangeAdministrator: {
    requireMfa: true
    requireConditionalAccess: true
    requireApproval: false
    approverObjectIds: []
    notificationsEnabled: true
    activationDuration: 'PT2H'
    requireJustification: true
    requireTicketInformation: false
  }
}
param groupPimPolicy = {
  owner: {
    requireMfa: true
    requireConditionalAccess: true
    requireApproval: true
    approverObjectIds: ['<OTHER_GROUP_OWNER_OBJECT_ID>']
    notificationsEnabled: true
    activationDuration: 'PT1H'
  }
  member: {
    requireMfa: true
    requireConditionalAccess: true
    requireApproval: false
    approverObjectIds: []
    notificationsEnabled: true
    activationDuration: 'PT5H'
  }
}
param pimAssignmentDefaults = {
  eligibleByDefault: true
  maximumEligibilityDuration: 'P90D'
  requireJustification: true
  requireTicketReference: true
  allowPermanentEligible: false
  allowPermanentActive: false
}
