# BIFROST documentation

This folder contains operator and requester documentation for the BIFROST Azure PIM project.

## Guides

| Document | Purpose |
|---|---|
| [CLI_LOCAL_TESTING.md](CLI_LOCAL_TESTING.md) | Azure CLI login, build, validation, and test deployment guidance. |
| [CREATE_ENTRA_USER_AZURE_PORTAL.md](CREATE_ENTRA_USER_AZURE_PORTAL.md) | How to create a Microsoft Entra user and obtain identity identifiers. |
| [PIM_AZURE_PORTAL_VARIABLES.md](PIM_AZURE_PORTAL_VARIABLES.md) | Azure Portal locations for request, role, scope, approver, and GitHub OIDC values. |
| [hardcoded_values_audit.md](hardcoded_values_audit.md) | Inventory of configuration values that are fixed or should be supplied externally. |

## Configuration file roles

- Root `input.json`: requestor, requested access, scope, request type/duration, justification, and ticket metadata.
- `modules/pim/pim-policy-settings.bicepparam`: PIM policy configuration intent and assignment defaults.
- `modules/pim/pim.bicep`: Azure Resource PIM eligibility schedule request resource.

## Implementation status

The current Bicep implementation creates Azure Resource PIM eligibility. The policy settings in the parameter file are not automatically enforced, and Entra directory-role PIM / PIM for Groups policy API operations remain separate implementation work. The JSON input is not automatically read by Bicep; a runner must map its values into deployment parameters and select the correct subscription.

Review the root [README.md](../README.md) and module [README.md](../modules/pim/README.md) for the architecture and implementation limitations.
