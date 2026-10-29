targetScope = 'subscription'

// Required: Microsoft Entra object ID of the user, group, or service principal.
// For service principals, use the enterprise application's service-principal Object ID,
// not the application/client ID.
@description('Microsoft Entra object ID of the principal receiving the Azure RBAC role.')
param principalId string

// Required: full Azure role definition resource ID.
// Example: /subscriptions/<subscription-id>/providers/Microsoft.Authorization/roleDefinitions/<role-guid>
@description('Full resource ID of the built-in or custom Azure role definition.')
param roleDefinitionId string

// Optional: set to the actual identity type to avoid ambiguity during role assignment.
@description('Principal type for the role assignment.')
@allowed([
  'User'
  'Group'
  'ServicePrincipal'
])
param principalType string = 'User'

// Optional: supply only when the deployment process explicitly manages role-assignment names.
// Azure role-assignment names must be GUIDs.
@description('Optional GUID for the role assignment. If omitted, a deterministic GUID is generated.')
param roleAssignmentName string = guid(subscription().id, principalId, roleDefinitionId, 'rbac-role-assignment')

// Creates a direct Azure RBAC role assignment at the subscription scope.
// Unlike PIM eligibility, this assignment grants the role's permissions immediately.
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: roleDefinitionId
  }
}

output roleAssignmentId string = roleAssignment.id
output roleAssignmentName string = roleAssignment.name
