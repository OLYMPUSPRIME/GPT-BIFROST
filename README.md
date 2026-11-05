# BIFROST — Azure Privileged Identity Management (PIM)

BIFROST is a reusable configuration and implementation workspace for Azure PIM access. This branch, `feature/PIM_mark_2`, currently contains the request-input example, an Azure Resource PIM eligibility Bicep template, and PIM policy configuration intent.

> **Implementation status:** The current Bicep template creates an Azure Resource PIM eligibility schedule request. The policy objects in the .bicepparam file document desired policy settings; they are not automatically applied. Entra directory-role PIM and PIM for Groups policy updates require separate Microsoft Graph implementation. No end-to-end runner that reads root input.json and maps every field into deployment parameters is currently present.

## Repository structure

```text
BIFROST/
├── input.json
├── README.md
├── docs/
│   ├── README.md
│   ├── CLI_LOCAL_TESTING.md
│   ├── CREATE_ENTRA_USER_AZURE_PORTAL.md
│   ├── PIM_AZURE_PORTAL_VARIABLES.md
│   └── hardcoded_values_audit.md
└── modules/
    └── pim/
        ├── pim.bicep
        ├── pim-policy-settings.bicepparam
        └── README.md
```

## Configuration responsibilities

### Root `input.json` — request-specific information

This file represents a request submitted by a user/requester. It currently includes:

- **Requestor identity:** display name, UPN, Entra Object ID.
- **Requested access:** platform, role name, role definition GUID, target scope, assignment type, request operation, eligibility duration, business justification.
- **Scope:** subscription ID, and optional Resource Group name or resource ID depending on the selected scope.
- **Request metadata:** requester UPN, environment, ticket ID, ticket number, and ticket system.

Use the real Entra **Object ID (GUID)** for the principal, not the display name or UPN. The ticket fields are request metadata and are not currently parameters in `pim.bicep`.

### `modules/pim/pim-policy-settings.bicepparam` — PIM policy configuration intent

This file holds the policy settings represented in the previously supplied policy screenshots, including:

- Azure Resource PIM settings for Owner and User Access Administrator.
- Entra directory-role PIM settings for Global Administrator and Exchange Administrator.
- PIM for Groups settings for Owner and Member.
- Assignment defaults such as eligible assignment preference, maximum eligibility duration, justification/ticket requirements, and permanent assignment restrictions.

Approver Object ID placeholders must be replaced with valid approver IDs where required. Do not confuse these policy settings with the individual request in `input.json`.

### `modules/pim/pim.bicep` — Azure Resource PIM eligibility request

The Bicep template is subscription-targeted:

```bicep
targetScope = 'subscription'
```

It declares required parameters for principal ID, role definition resource ID, request operation, justification, eligibility duration, and request name. It creates:

`Microsoft.Authorization/roleEligibilityScheduleRequests@2024-09-01-preview`

The template does **not**:
- Parse root `input.json` on its own.
- Select the subscription based on JSON without an orchestration layer.
- Apply activation-policy settings from the policy objects.
- Configure Entra directory-role PIM or PIM for Groups policies.
- Create an active assignment or activate the eligible user's role.

## Important parameter distinctions

- **Request operation** (`requestType`, e.g. `AdminAssign`) controls the Azure Resource PIM schedule request operation.
- **Eligibility duration** (`duration`, e.g. `P30D`) controls how long eligibility is scheduled.
- **Activation duration** (e.g. 1 hour for a particular policy) is a PIM policy setting, not the same as eligibility duration.
- The Bicep duration parameter uses a finite `@allowed` list of common ISO 8601 values. It does not accept every possible ISO 8601 expression.

## Subscription targeting

`targetScope = 'subscription'` declares deployment scope; it does not identify the subscription.

The deployment command or workflow must explicitly select the intended subscription (for example, with Azure CLI `--subscription <SUBSCRIPTION_ID>` or `az account set --subscription <SUBSCRIPTION_ID>`). Root `input.json` contains a subscription ID, but Bicep does not read JSON automatically. Until a runner maps that value into the CLI/deployment context, the JSON field alone does not control the subscription.

Verify the active CLI subscription:

```bash
az account show --query "{Name:name, SubscriptionId:id, TenantId:tenantId}" -o table
```

## Testing

See [docs/CLI_LOCAL_TESTING.md](docs/CLI_LOCAL_TESTING.md) for local Azure CLI testing instructions. Test in a non-production subscription and verify identity, scope, role, request type, duration, and policy approvals before deployment.

## Documentation

- [Documentation index](docs/README.md)
- [Create an Entra user](docs/CREATE_ENTRA_USER_AZURE_PORTAL.md)
- [Azure Portal values and variable guide](docs/PIM_AZURE_PORTAL_VARIABLES.md)
- [Local CLI testing](docs/CLI_LOCAL_TESTING.md)
- [Hardcoded values audit](docs/hardcoded_values_audit.md)

## Security

- Use least privilege and approvals for privileged access.
- Do not commit passwords, secrets, private keys, or production user identifiers.
- Protect deployment environments and review the requested role/scope carefully.
- Successful eligibility creation does not mean the user has activated the role.
