# RBAC Pipeline Inputs and Execution

Workflow: `.github/workflows/rbac.yml`

Root `input.json` includes approval/ticket metadata, target subscription, principal Object ID/type, role GUID, scope type, and description. GitHub Environment `bifrost-dev` contains AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID.

## Jobs
1. Validate input and compile Bicep.
2. Optional What-If preview.
3. Direct role assignment only when `deploy_rbac=true`.
4. Optional access report/artifact.

Run Actions → BIFROST RBAC Mark-1 → choose `feature/RBAC_mark_1`. Preview first, inspect principal/role/scope, and deploy only after approval.

Assignment name is deterministic from subscription + principal + role + scope type, supporting idempotent repeat deployments.

OIDC identity needs role-assignment write permission. Contributor does not grant this.
