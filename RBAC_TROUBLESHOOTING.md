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
