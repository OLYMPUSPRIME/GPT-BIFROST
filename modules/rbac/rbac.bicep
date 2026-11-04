targetScope = 'subscription'

// Direct Azure RBAC assignment. Grants access immediately; this is not PIM.
@description('Microsoft Entra object ID for the user, group, or service principal.')
param principalId string

@description('Principal type.')
@allowed([
  'User'
  'Group'
  'ServicePrincipal'
])
param principalType string = 'User'

@description('Azure role definition GUID.')
param roleDefinitionGuid string

@description('Target subscription ID (used for role definition resource ID).')
param subscriptionId string

@description('Deterministic role assignment GUID.')
param roleAssignmentName string

@description('Audit description for the role assignment.')
param assignmentDescription string = 'BIFROST RBAC assignment managed by Bicep'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  // Deployment is subscription-scoped; role assignment inherits this scope.
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionGuid)
    principalId: principalId
    principalType: principalType
    description: assignmentDescription
  }
}

output roleAssignmentId string = roleAssignment.id
output roleAssignmentName string = roleAssignment.name
output assignedPrincipalId string = principalId
output assignedRoleDefinitionId string = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionGuid)
