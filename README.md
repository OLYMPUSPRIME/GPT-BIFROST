# GPT-BIFROST | Azure RBAC Assignment

**Branch:** `feature/RBAC_mark_1`  
This branch manages **direct Azure RBAC assignments** (not PIM). It supports three independent scopes: subscription, resource group, or individual resource.

## Supported scopes
| input.json `rbac.scope.type` | Deployment |
|---|---|
| `Subscription` | Subscription Bicep module + subscription What-If |
| `ResourceGroup` | Resource-group Bicep module + RG What-If |
| `Resource` | Azure CLI role assignment at exact resource ID; preview displays scope and existing assignment state |

Configure one scope per run. For resource-group scope, provide `resourceGroupName`. For resource scope, provide a full `resourceId` including provider/type/name.

## Repository layout
```text
.github/workflows/rbac.yml
modules/rbac/rbac.bicep
modules/rbac/resourceGroup/rbac.bicep
modules/rbac/README.md
input.json
RBAC_ACCESS_PURPOSE_AND_SCOPE.md
RBAC_PIPELINE_INPUTS_AND_EXECUTION.md
RBAC_TROUBLESHOOTING.md
hardcoded_values_audit.md
```

## GitHub Environment
Use `bifrost-dev` with `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`. Configure GitHub OIDC federated credentials for this environment.

## Run safely
1. Update `input.json` with the target principal, role and scope.
2. Run Actions → **BIFROST RBAC Mark-1** on `feature/RBAC_mark_1`.
3. First set `run_what_if=true`, `deploy_rbac=false`.
4. Review principal, role and exact scope.
5. Deploy only after authorization.

Direct RBAC grants access immediately. Remove assignments when no longer required. Contributor alone cannot create role assignments; the pipeline identity needs role-assignment write permissions at the target scope.
