using './pim.bicep'

// Policy intent used by the PowerShell pre-deployment validator.
// These values do not themselves update Azure PIM policy settings.
param azureResourcePimPolicy = {
  owner: {
    enabled: true
    roleDefinitionId: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
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
    enabled: true
    roleDefinitionId: '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
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
