# BIFROST — Azure RBAC Access Assignment

Branch: feature/RBAC_mark_2

## Scope and responsibility

This branch contains an RBAC-only access assignment workflow. Target infrastructure (VMs, resource groups, storage, networking, Key Vault, etc.) is provisioned by other modules or already exists.

The RBAC workflow:
- Reads the exact target scope from input.json.
- Validates the request and checks that the selected existing resource/resource group is present.
- Creates only an Azure Microsoft.Authorization/roleAssignments access grant.
- Does not create or modify target infrastructure.
- Never falls back to a broader scope if the requested scope fails.

## Scope choices

- Subscription: existing subscription.
- ResourceGroup: existing resource group.
- Resource: existing individual Azure resource using its full ARM resource ID.

## Repository layout

- input.json — JSON request feeder.
- scripts/Invoke-RbacRequest.ps1 — validation and exact-scope Azure CLI role assignment.
- modules/rbac/main.bicep — Bicep entrypoint for subscription/RG assignment.
- modules/rbac/subscription/rbac-subscription.bicep — subscription role assignment.
- modules/rbac/resourceGroup/rbac-resource-group.bicep — RG role assignment.
- modules/rbac/resource/rbac-resource.bicep — resource-scope input/helper.
- .github/workflows/rbac-request.yml — validation and optional assignment workflow.
- docs/RBAC_REQUEST_FLOW.md — process diagram.
- docs/RBAC_TROUBLESHOOTING.md — test issue log, to populate after testing.

## Local execution

1. Update placeholders in input.json with approved values.
2. Choose scopeLevel:
   - Subscription: leave RG/resource fields blank.
   - ResourceGroup: provide existing resourceGroupName.
   - Resource: provide full existing resourceId.
3. Validate:

    az login
    az account set --subscription '<subscription-id>'
    az bicep install
    az bicep build --file modules/rbac/main.bicep
    pwsh ./scripts/Invoke-RbacRequest.ps1 -WhatIf

4. After review and approval, execute:

    pwsh ./scripts/Invoke-RbacRequest.ps1

## GitHub Actions

Workflow .github/workflows/rbac-request.yml validates first and applies only when whatif=false. It uses OIDC and GitHub secrets AZURE_CLIENT_ID, AZURE_TENANT_ID, and AZURE_SUBSCRIPTION_ID. Configure the bifrost-dev GitHub environment with required reviewers.

## RBAC vs PIM

RBAC assignments grant active access immediately. PIM eligibility/activation is separate and is not part of this branch.
