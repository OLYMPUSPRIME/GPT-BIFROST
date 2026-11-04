# RBAC Troubleshooting

## Verify first
- Workflow path `.github/workflows/rbac.yml`
- GitHub Environment `bifrost-env`
- AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID
- OIDC issuer/audience/subject
- input.json approval, principal Object ID GUID, role GUID and scope
- Deployment identity role-assignment permissions

| Symptom | Resolution |
|---|---|
| Azure login/federation fails | Check client/tenant/sub IDs and OIDC federated subject/environment. |
| Environment vars empty | Job must use `environment: bifrost-env`; set vars there. |
| Invalid principal GUID | Use Entra Object ID, not UPN/email/display name. |
| PrincipalNotFound | Confirm principal exists in target tenant and ID is correct. |
| AuthorizationFailed / roleAssignments/write | Grant least-privilege role-assignment administration permissions; Contributor is insufficient. |
| RoleDefinitionNotFound | Verify role GUID and subscription. |
| Existing assignment/conflict | Check principal + role + scope and deterministic assignment GUID. |
| What-If succeeds but deploy fails | Inspect ARM deployment error and runtime authorization. |
| Assignment/access not effective | Verify IAM principal/role/scope and allow propagation. |

## Portal verification
Azure Portal → Subscriptions → target subscription → Access control (IAM) → Role assignments. Filter by principal and verify role/scope.

## CLI list
```bash
az role assignment list --assignee <PRINCIPAL_OBJECT_ID> --scope /subscriptions/<SUBSCRIPTION_ID> --include-inherited --all --output table
```

## Remove
```bash
az role assignment delete --ids <ROLE_ASSIGNMENT_RESOURCE_ID>
```
Remove only the confirmed assignment. Direct RBAC has no PIM activation.


## Bicep build failure: BCP062, BCP079, and BCP139 (RBAC module)

### Symptoms
The GitHub Actions **Build RBAC Bicep module** step fails with:
- **BCP062**: referenced declaration named `description` is not valid.
- **BCP079**: expression references its own declaration (self-reference).
- **BCP139**: resource scope must match the scope of the Bicep file.

### Root cause
The RBAC module used a parameter named `description` and then assigned `description: description` in the role assignment properties. Bicep interpreted this as a declaration reference issue. The resource also specified `scope: subscription(subscriptionId)` even though the file declares `targetScope = 'subscription'`, causing a scope mismatch.

### Resolution
1. Rename the parameter to `assignmentDescription` and reference it in the resource as `description: assignmentDescription`.
2. Remove the explicit `scope: subscription(subscriptionId)` from the role assignment resource. The resource inherits the subscription scope from `targetScope = 'subscription'`.
3. Use `subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionGuid)` to construct the role definition resource ID.
4. Update both the What-If and deployment parameter-generation steps in `.github/workflows/rbac.yml` to use `assignmentDescription:{value:.rbac.description}`.

### Corrected resource pattern
```bicep
targetScope = 'subscription'

param assignmentDescription string = 'BIFROST RBAC assignment managed by Bicep'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionGuid)
    principalId: principalId
    principalType: principalType
    description: assignmentDescription
  }
}
```

### Validation
Run the Bicep build step again:
```bash
az bicep build --file modules/rbac/rbac.bicep --stdout >/dev/null
```
Then run GitHub Actions with What-If enabled and actual deployment disabled until the preview is reviewed.
