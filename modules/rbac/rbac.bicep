targetScope = 'subscription'

// Direct Azure RBAC role assignment. Grants permissions immediately (not PIM).
@description('Entra object ID for the user, group, or service principal.')
param principalId string
@description('Principal type.')
@allowed(['User', 'Group', 'ServicePrincipal'])
param principalType string = 'User'
@description('Azure role definition GUID.')
param roleDefinitionGuid string
@description('Target subscription ID.')
param subscriptionId string
@description('Deterministic role assignment GUID.')
param roleAssignmentName string
@description('Audit description.')
param description string = 'BIFROST RBAC assignment managed by Bicep'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  scope: subscription(subscriptionId)
  properties: {
    roleDefinitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${roleDefinitionGuid}'
    principalId: principalId
    principalType: principalType
    description: description
  }
}

output roleAssignmentId string = roleAssignment.id
output roleAssignmentName string = roleAssignment.name
output assignedPrincipalId string = principalId
output assignedRoleDefinitionId string = '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${roleDefinitionGuid}'
