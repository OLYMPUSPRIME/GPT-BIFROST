# RBAC Troubleshooting

## Verify first
- Workflow path `.github/workflows/rbac.yml`
- GitHub Environment `bifrost-dev`
- AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID
- OIDC issuer/audience/subject
- input.json approval, principal Object ID GUID, role GUID, and scope target
- Deployment identity role-assignment permissions

| Symptom | Resolution |
|---|---|
| Azure login/federation fails | Check client/tenant/sub IDs and OIDC federated subject/environment. |
| Environment vars empty | Job must use `environment: bifrost-dev`; set vars there. |
| Invalid principal GUID | Use Entra Object ID, not UPN/email/display name. |
| PrincipalNotFound | Confirm principal exists in target tenant and ID is correct. |
| AuthorizationFailed / roleAssignments/write | Grant appropriate least-privilege role-assignment admin permissions; Contributor is insufficient. |
| RoleDefinitionNotFound | Verify role GUID and subscription. |
| Resource Group scope validation fails | Confirm `scope.type=ResourceGroup` and exact `resourceGroupName`; RG must exist in the subscription. |
| Resource scope validation fails | Provide a complete resource ID under the configured subscription, including `/providers/<namespace>/<type>/<name>`. |
| What-If succeeds but deploy fails | Inspect ARM deployment error and runtime authorization. |
| Assignment/access not effective | Verify IAM principal/role/scope and allow propagation. |

## Scope deployment behavior
- Subscription: `az deployment sub what-if/create` using `modules/rbac/rbac.bicep`.
- Resource Group: `az deployment group what-if/create` using `modules/rbac/resourceGroup/rbac.bicep`.
- Individual resource: `az role assignment create --scope <full-resource-id>`. ARM What-If does not preview this CLI role assignment; the preview step prints target and lists existing role assignments at that scope.

## Portal verification
Azure Portal → target subscription/resource group/resource → Access control (IAM) → Role assignments. Filter principal and verify role and scope.

## CLI list
```bash
az role assignment list --assignee <PRINCIPAL_OBJECT_ID> --scope <TARGET_SCOPE_ID> --all --output table
```

## Remove
```bash
az role assignment delete --ids <ROLE_ASSIGNMENT_RESOURCE_ID>
```
Remove only the intended assignment. Direct RBAC has no PIM activation.

## Bicep build failure: BCP062, BCP079, and BCP139
The RBAC module failed due to a parameter named `description` being referenced as `description: description` and an explicit scope conflicting with the file target scope.

Fix: rename the parameter to `assignmentDescription`, use `description: assignmentDescription`, and allow the role assignment resource to inherit its deployment scope. Use `subscriptionResourceId` for role definition IDs.

Validation:
```bash
az bicep build --file modules/rbac/rbac.bicep --stdout >/dev/null
az bicep build --file modules/rbac/resourceGroup/rbac.bicep --stdout >/dev/null
```
