# RBAC Configuration Audit

- Branch: `feature/RBAC_mark_1`
- Workflow: `.github/workflows/rbac.yml`
- Subscription module: `modules/rbac/rbac.bicep`
- Resource-group module: `modules/rbac/resourceGroup/rbac.bicep`
- Subscription guardrail: BIFROST-SC
- Deployment metadata location: centralindia
- GitHub Environment: bifrost-dev
- Supported scopes: Subscription, ResourceGroup, Resource
- Individual resource scope: Azure CLI `az role assignment create`
- Role assignment API: `Microsoft.Authorization/roleAssignments@2022-04-01`
- Sample role: Reader (`acdd72a7-3385-48ef-bd42-f606fba81ae7`)

Principal, role, and target scope are in input.json. Tenant/subscription/client IDs are GitHub environment variables. Role assignment GUID is generated deterministically per scope.

Direct RBAC grants access immediately; remove when no longer required. Do not store secrets in source.
