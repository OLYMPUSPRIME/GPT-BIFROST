// Resource-scope RBAC helper metadata.
// Dynamic ARM resource types cannot be strongly typed as a generic existing Bicep resource.
// Invoke-RbacRequest.ps1 validates the full resource ARM ID and creates the assignment
// using Azure CLI at that exact scope. This file documents/exports the role assignment inputs.
targetScope = 'subscription'
param targetResourceId string
param principalId string
param roleDefinitionGuid string
param assignmentId string = 'bifrost-dev'
var roleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionGuid)
var assignmentName = guid(targetResourceId, principalId, roleDefinitionId, assignmentId)
output targetScope string = targetResourceId
output roleDefinitionId string = roleDefinitionId
output assignmentName string = assignmentName
