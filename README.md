# 🌌 BIFROST — Azure Privileged Identity Management (PIM)

BIFROST is a reusable Azure PIM configuration and implementation workspace. This branch contains request input, a subscription-scoped Azure Resource PIM eligibility Bicep template, PIM policy configuration, and a PowerShell request runner.

> **Current implementation:** The runner validates the JSON request against the compiled Azure Resource role policy in `pim-policy-settings.bicepparam` before deployment. A role must have an enabled policy entry and matching role definition GUID. Eligibility duration, assignment type, request type, justification, and ticket requirements are validated. Live PIM policy writes and live Azure policy verification are not yet implemented.

## Repository structure

```text
BIFROST/
├── input.json
├── scripts/
│   └── Invoke-PimRequest.ps1
├── docs/
│   ├── CLI_LOCAL_TESTING.md
│   └── PIM_REQUEST_FLOW.md
└── modules/pim/
    ├── pim.bicep
    ├── pim-policy-settings.bicepparam
    └── README.md
```

## Configuration responsibilities

### `input.json` — access request

Contains requestor identity, requested role and role definition GUID, subscription scope, eligible assignment, request operation, eligibility duration, justification, and ticket metadata. It does not define or override the security policy.

### `pim-policy-settings.bicepparam` — approved policy intent

Contains Azure Resource PIM policy entries. Currently configured Azure Resource roles are **Owner** and **User Access Administrator**. Each configured role has an `enabled` flag and role definition GUID. The policy defaults include a maximum eligibility duration and justification/ticket requirements.

The input sample currently requests **Contributor**, which is intentionally denied because Contributor has no approved policy entry yet. Add a policy entry only after the role and requirements have been approved.

### `Invoke-PimRequest.ps1` — policy validator and deployment orchestrator

The runner compiles the `.bicepparam` file to JSON using `az bicep build-params`, reads the compiled policy values, and fails closed if the request does not match. Only after the checks pass does it generate deployment parameters and invoke Azure CLI.

### `pim.bicep` — eligibility request resource

The Bicep template creates an Azure Resource PIM role eligibility schedule request at subscription scope. It requires `requestPolicyValidated=true` as a deployment guardrail. This is not a substitute for the PowerShell validator.

## Current limitations

- Subscription scope only; Resource Group and individual-resource scope are not supported by this runner.
- Live Azure PIM role-management policy updates/verification are not implemented.
- Entra directory-role and PIM for Groups policies require separate Microsoft Graph logic.
- MFA, Conditional Access, approval and activation-duration entries are policy intent only until live policy APIs are wired.
- GitHub Actions workflow and approval gate are not yet present in this branch.

## Documentation

- [Local CLI testing](docs/CLI_LOCAL_TESTING.md)
- [PIM request flow](docs/PIM_REQUEST_FLOW.md)
- [PIM module README](modules/pim/README.md)

## Security reminders

- Test in a non-production subscription.
- Do not store credentials in `input.json`.
- Verify tenant, subscription, principal, role and scope before deployment.
- PIM eligibility is not active access; activation is separate.
