// BIFROST RBAC entrypoint: subscription and resource-group scope.
// Resource scope is dispatched to Azure CLI by Invoke-RbacRequest.ps1.
targetScope = 'subscription'
@allowed(['Subscription', 'ResourceGroup'])
param scopeLevel string
param principalId string
param roleDefinitionGuid string
param principalType string = 'ServicePrincipal'
param targetResourceGroupName string = ''
param assignmentId string = 'bifrost-dev'
param condition string = ''
param conditionVersion string = '2.0'
module subAssignment './subscription/rbac-subscription.bicep' = if (scopeLevel == 'Subscription') {
  name: 'bifrostRbacSubscription'
  params: { principalId: principalId, roleDefinitionGuid: roleDefinitionGuid, principalType: principalType, assignmentId: assignmentId, condition: condition, conditionVersion: conditionVersion }
}
module rgAssignment './resourceGroup/rbac-resource-group.bicep' = if (scopeLevel == 'ResourceGroup') {
  name: 'bifrostRbacResourceGroup'
  scope: resourceGroup(targetResourceGroupName)
  params: { principalId: principalId, roleDefinitionGuid: roleDefinitionGuid, principalType: principalType, assignmentId: assignmentId, condition: condition, conditionVersion: conditionVersion }
}
output selectedScope string = scopeLevel == 'Subscription' ? subscription().id : resourceGroup(targetResourceGroupName).id
