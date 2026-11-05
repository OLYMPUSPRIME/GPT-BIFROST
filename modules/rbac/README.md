# Reusable Azure RBAC access-assignment module

## Purpose and boundary

This module only grants Azure RBAC access to an existing target. The target resource or resource group must already exist, either because it was created manually or by a separate infrastructure module (VM, networking, storage, Key Vault, etc.).

This module does not create, update, or delete target infrastructure. Azure creates a Microsoft.Authorization/roleAssignments record as the access grant itself; this is not a new target resource.

## Scope selection

The caller specifies the exact scope in input.json:

| scopeLevel | Required input | Target |
|---|---|---|
| Subscription | subscriptionId | Existing subscription |
| ResourceGroup | subscriptionId, resourceGroupName | Existing resource group |
| Resource | subscriptionId, full resourceId | Existing individual ARM resource |

The PowerShell runner validates the feeder, tenant/subscription context, and existence of the target RG/resource before making an assignment. It does not broaden scope or provision infrastructure. Resource IDs must belong to the subscription specified in the feeder.

## Run

    pwsh ./scripts/Invoke-RbacRequest.ps1 -WhatIf

After review and approval, authenticate with Azure CLI and run:

    az login
    pwsh ./scripts/Invoke-RbacRequest.ps1

Assignment names are deterministic from scope, principal, role, and request key to reduce duplicate assignments on reruns.

## Permissions

The executing identity must have permission to create role assignments at the requested scope (typically Owner, User Access Administrator, or Role Based Access Control Administrator, subject to policy).

RBAC grants active access immediately. PIM eligibility/activation remains a separate workflow.
