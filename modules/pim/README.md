# PIM Bicep Module

Creates a subscription-scoped Microsoft.Authorization role eligibility schedule request.

## Parameters
- `principalId`: Entra user Object ID.
- `roleDefinitionId`: Full role definition resource ID.
- `justification`: Business reason.
- `duration`: ISO 8601 duration, e.g. `P90D`.
- `requestName`: UUID for schedule request.
- `ticketNumber` / `ticketSystem`: Audit ticket metadata.

The module creates **eligible** access; the user must activate the role in Microsoft Entra PIM. The caller must have privileged permissions to create eligibility schedule requests.
