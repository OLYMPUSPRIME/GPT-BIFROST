# PIM Bicep Module (Mark-1)

Creates Azure RBAC **PIM role eligibility schedule requests**. Eligibility does not activate the role; the target user must activate it when required.

## Scope configuration in input.json

The `pim.scope` object supports:

- **Subscription**: `{"type":"Subscription"}`
- **Resource Group**: `{"type":"ResourceGroup","resourceGroupName":"rg-example"}`
- **Individual resource**: `{"type":"Resource","resourceId":"/subscriptions/<sub>/resourceGroups/<rg>/providers/<provider>/<type>/<name>"}`

For ResourceGroup, the workflow derives `/subscriptions/<subscriptionId>/resourceGroups/<resourceGroupName>`. For Resource, the full Azure resource ID is used as scope. The resource must be within the configured subscription.

## Input JSON reference

| Key | Meaning |
|---|---|
| `request.ticketId` | Request reference |
| `request.requestedBy` | Requester metadata |
| `request.approved` | Approval flag; must be true |
| `request.environment` | Environment label |
| `request.project` | Project name |
| `request.deploymentMethod` | Deployment method |
| `subscription.name` | Subscription label, validated as BIFROST-SC |
| `subscription.subscriptionId` | Placeholder only; GitHub environment variable is authoritative |
| `pim.enabled` | Enable PIM operation |
| `pim.assignmentType` | Workflow currently supports Eligibility |
| `pim.requestType` | Request action, default AdminAssign |
| `pim.user.alias` | Target-user alias |
| `pim.user.principalId` | Entra object ID |
| `pim.user.principalType` | User (current workflow expectation) |
| `pim.role.roleName` | Role display name |
| `pim.role.roleDefinitionId` | Built-in role GUID or full role definition resource ID |
| `pim.scope.type` | Subscription, ResourceGroup, or Resource |
| `pim.scope.resourceGroupName` | Required for ResourceGroup scope |
| `pim.scope.resourceId` | Required for Resource scope |
| `pim.schedule.duration` | ISO 8601 duration such as P90D |
| `pim.schedule.expirationType` | AfterDuration, AfterDateTime, NoExpiration |
| `pim.schedule.startDateTime` | Optional UTC start; blank means current time |
| `pim.justification` | Business justification |
| `pim.ticketInfo.ticketSystem` | Ticket system name |
| `pim.ticketInfo.ticketNumber` | Ticket reference sent to Azure |

## Request types

The ARM role eligibility schedule request API recognizes:

| Type | Operation | Caveat |
|---|---|---|
| `AdminAssign` | Create eligibility | Supported default/create path |
| `AdminUpdate` | Update eligibility | Existing schedule context required |
| `AdminRemove` | Remove eligibility | Target schedule context required |
| `AdminExtend` | Admin extend eligibility | Existing schedule context required |
| `AdminRenew` | Admin renew eligibility | Existing/expired schedule context required |
| `SelfActivate` | User activation | User-context action |
| `SelfDeactivate` | User deactivation | User-context action |
| `SelfExtend` | User extension request | User-context action |
| `SelfRenew` | User renewal request | User-context action |

The Bicep module exposes the `requestType` parameter. The current workflow feeder validates the API action values, but its primary grant flow is `AdminAssign`; the other request types require target schedule IDs and/or a user-context flow. They are **not** drop-in alternatives for creating new eligibility.

## GitHub Actions workflow inputs

- `run_what_if`: ARM What-If preview (does not guarantee PIM service-side validation).
- `deploy_pim`: explicit deployment gate.
- `view_access`: generate user and access report.

## GitHub Environment: bifrost-dev

Set environment variables under **Settings → Environments → bifrost-dev → Environment variables**:

| Variable | Used for |
|---|---|
| `AZURE_CLIENT_ID` | OIDC client/application ID for azure/login |
| `AZURE_TENANT_ID` | Tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Target subscription ID |

Workflow uses `azure/login@v2` and GitHub OIDC (`id-token: write`); no client secret is expected. Configure a matching Entra federated credential. OIDC principal needs appropriate Azure RBAC/PIM permissions and any Microsoft Graph permissions used by reporting.

## Notes

- Workflow runs on `ubuntu-latest`; feeder validation uses Python and jq.
- ARM deployment location `centralindia` is deployment metadata, not the access scope.
- PIM onboarding/licensing and permissions are prerequisites; What-If cannot bypass them.
- Do not use Self* operations with the GitHub service principal as if it were the target user.
