// BIFROST RBAC entrypoint.
// Subscription and ResourceGroup assignments are represented as Bicep modules.
// Generic individual-resource scope is assigned by the PowerShell/Azure CLI runner
// using the exact existing ARM resource ID from input.json.
targetScope = 'subscription'

@allowed(['Subscription', 'ResourceGroup', 'Resource'])
param scopeLevel string

param principalId string
param roleDefinitionGuid string
param principalType string = 'ServicePrincipal'
param targetResourceGroupName string = ''
param targetResourceId string = ''
param assignmentId string = 'bifrost-dev'
param condition string = ''
param conditionVersion string = '2.0'

module subAssignment './subscription/rbac-subscription.bicep' = if (scopeLevel == 'Subscription') {
  name: 'bifrostRbacSubscription'
  params: {
    principalId: principalId
    roleDefinitionGuid: roleDefinitionGuid
    principalType: principalType
    assignmentId: assignmentId
    condition: condition
    conditionVersion: conditionVersion
  }
}

module rgAssignment './resourceGroup/rbac-resource-group.bicep' = if (scopeLevel == 'ResourceGroup') {
  name: 'bifrostRbacResourceGroup'
  scope: resourceGroup(targetResourceGroupName)
  params: {
    principalId: principalId
    roleDefinitionGuid: roleDefinitionGuid
    principalType: principalType
    assignmentId: assignmentId
    condition: condition
    conditionVersion: conditionVersion
  }
}

output selectedScope string = scopeLevel == 'Subscription'
  ? subscription().id
  : (scopeLevel == 'ResourceGroup'
      ? resourceGroup(targetResourceGroupName).id
      : targetResourceId)

output executionMethod string = scopeLevel == 'Resource'
  ? 'Invoke-RbacRequest.ps1 with exact existing resource ARM ID'
  : 'Bicep role assignment module'
