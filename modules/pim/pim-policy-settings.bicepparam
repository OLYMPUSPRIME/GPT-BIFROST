using './pim.bicep'

// Policy intent based on supplied screenshots. These are configuration inputs;
// they are not applied by the eligibility schedule request itself.
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
