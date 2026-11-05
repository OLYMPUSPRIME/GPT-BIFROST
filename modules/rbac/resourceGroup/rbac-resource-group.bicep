// Resource-group-scope Azure RBAC assignment.
targetScope = 'resourceGroup'
param principalId string
param roleDefinitionGuid string
param assignmentId string = 'bifrost-dev'
param principalType string = 'ServicePrincipal'
param condition string = ''
param conditionVersion string = '2.0'
var roleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionGuid)
var assignmentName = guid(resourceGroup().id, principalId, roleDefinitionId, assignmentId)
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: assignmentName
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: roleDefinitionId
    ...(condition != '' ? { condition: condition, conditionVersion: conditionVersion } : {})
  }
}
output roleAssignmentId string = roleAssignment.id
