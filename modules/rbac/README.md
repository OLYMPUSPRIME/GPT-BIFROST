# Azure RBAC Module Library

This library supports independent direct RBAC assignments at **Subscription**, **Resource Group**, or **Individual Resource** scope. Select one scope per pipeline run using root `input.json`.

## Scope options

### Subscription
```json
"scope": {"type":"Subscription","resourceGroupName":"","resourceId":""}
```
Uses `modules/rbac/rbac.bicep` and subscription-level ARM What-If/deployment.

### Resource Group
```json
"scope": {"type":"ResourceGroup","resourceGroupName":"example-rg","resourceId":""}
```
Uses `modules/rbac/resourceGroup/rbac.bicep` and resource-group ARM What-If/deployment.

### Individual resource
```json
"scope": {"type":"Resource","resourceGroupName":"example-rg","resourceId":"/subscriptions/<SUB_ID>/resourceGroups/example-rg/providers/Microsoft.Compute/virtualMachines/example-vm"}
```
Uses `az role assignment create` with the complete resource ID. The preview step prints the proposed scope and checks existing assignments. Azure ARM What-If does not preview this direct CLI role-assignment operation.

## Inputs
- principal Object ID and type (User/Group/ServicePrincipal)
- role definition GUID
- scope type and scope target
- approval metadata and description

## Security
Direct RBAC grants access immediately. Validate least privilege, principal, role, and scope before enabling deployment. The identity running the workflow must have roleAssignments/write at the target scope (e.g., suitable RBAC Administrator/User Access Administrator grant). Contributor alone is insufficient.
