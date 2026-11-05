# BIFROST — Azure RBAC

This branch (`feature/RBAC_mark_2`) implements request-driven Azure RBAC assignment, patterned after the PIM branch's input/runner/docs approach.

## Supported scopes

- **Subscription:** assign access at subscription scope.
- **ResourceGroup:** assign access within one named resource group.
- **Resource:** assign access at one exact ARM resource ID.

The runner does not silently broaden the requested scope.

## Repository layout

- `input.json` — JSON request feeder
- `scripts/Invoke-RbacRequest.ps1` — request validation and Azure CLI execution
- `modules/rbac/main.bicep` — Bicep entrypoint for subscription and RG
- `modules/rbac/subscription/rbac-subscription.bicep` — subscription module
- `modules/rbac/resourceGroup/rbac-resource-group.bicep` — RG module
- `modules/rbac/resource/rbac-resource.bicep` — resource-scope helper
- `.github/workflows/rbac-request.yml` — validation/apply workflow
- `docs/RBAC_REQUEST_FLOW.md` — workflow diagram
- `AZURE_BUILTIN_RBAC_ROLE_IDS.md` — role GUID reference

## Local use

Prerequisites: Azure CLI, Bicep, PowerShell 7, and role-assignment permissions.

1. Replace placeholders in `input.json` with approved tenant/subscription, principal object ID, role and scope values.
2. For ResourceGroup, set `resourceGroupName`.
3. For Resource, set the full `resourceId` ARM ID.
4. Run:

```powershell
az login
az account set --subscription '<subscription-id>'
az bicep install
az bicep build --file modules/rbac/main.bicep
pwsh ./scripts/Invoke-RbacRequest.ps1 -WhatIf
```

After review and approval, run `pwsh ./scripts/Invoke-RbacRequest.ps1` to grant access.

## GitHub Actions

Workflow `.github/workflows/rbac-request.yml` validates first. It applies only when workflow input `whatif=false`, uses OIDC, and expects repository secrets `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`. Configure GitHub environment `bifrost-dev` with required reviewers.

## RBAC vs PIM

RBAC assignments grant active access immediately. PIM eligibility is separate and requires activation.
