# RBAC Pipeline Inputs and Execution

Workflow: `.github/workflows/rbac.yml`; GitHub environment: `bifrost-dev`.

## Scope input examples

Subscription:
```json
"scope": {"type":"Subscription","resourceGroupName":"","resourceId":""}
```

Resource Group:
```json
"scope": {"type":"ResourceGroup","resourceGroupName":"bifrost-rg","resourceId":""}
```

Individual resource:
```json
"scope": {"type":"Resource","resourceGroupName":"bifrost-rg","resourceId":"/subscriptions/<SUB_ID>/resourceGroups/bifrost-rg/providers/Microsoft.Compute/virtualMachines/bifrost-vm"}
```

## Workflow stages
1. Validate approval, subscription, principal, role, and selected scope.
2. Build both subscription and resource-group Bicep modules.
3. Preview: Subscription What-If; Resource Group What-If; individual resource preview/check (no ARM What-If for direct CLI RBAC).
4. Deploy only if `deploy_rbac=true`: subscription Bicep, RG Bicep, or `az role assignment create` based on scope.
5. Optional principal RBAC access report.

Assignment GUID is deterministic based on subscription + principal + role + exact scope, preventing accidental GUID collisions across different scopes. The workflow is manually dispatched. Review before deploying.
