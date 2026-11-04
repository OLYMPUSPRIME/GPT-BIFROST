# RBAC Configuration Audit

- Branch: `feature/RBAC_mark_1`
- Workflow: `.github/workflows/rbac.yml`
- Module: `modules/rbac/rbac.bicep`
- Subscription guardrail: BIFROST-SC
- Deployment metadata location: centralindia
- GitHub Environment: bifrost-env
- Supported scope: subscription
- Default sample role: Reader (`acdd72a7-3385-48ef-bd42-f606fba81ae7`)
- API: `Microsoft.Authorization/roleAssignments@2022-04-01`

Principal ID/type, role GUID, approval, ticket and description are in input.json. Tenant/subscription/client IDs are GitHub environment variables. Assignment GUID is generated deterministically.

Do not store secrets. Direct RBAC assignment is active immediately; remove when no longer needed.
