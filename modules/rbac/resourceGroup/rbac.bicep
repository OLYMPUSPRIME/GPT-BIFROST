targetScope = 'resourceGroup'

// Direct Azure RBAC role assignment at the deployment resource-group scope.
// This assignment is active immediately and is not PIM.
@description('Microsoft Entra Object ID of the user, group, or service principal.')
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

@description('Subscription ID containing this resource group.')
param subscriptionId string

@description('Deterministic role assignment GUID.')
param roleAssignmentName string

@description('Audit description.')
param assignmentDescription string = 'BIFROST RBAC assignment managed by Bicep'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  properties: {
    roleDefinitionId: subscriptionResourceId(subscriptionId, 'Microsoft.Authorization/roleDefinitions', roleDefinitionGuid)
    principalId: principalId
    principalType: principalType
    description: assignmentDescription
  }
}

output roleAssignmentId string = roleAssignment.id
output assignedPrincipalId string = principalId
output assignedRoleDefinitionId string = subscriptionResourceId(subscriptionId, 'Microsoft.Authorization/roleDefinitions', roleDefinitionGuid)
