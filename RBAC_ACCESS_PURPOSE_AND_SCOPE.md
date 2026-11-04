# RBAC Access Purpose and Scope

## Purpose
Provide approved, auditable direct Azure role assignment through Bicep and GitHub Actions.

## Supported scopes (choose one per run)
- **Subscription:** assignment at `/subscriptions/<subscriptionId>`
- **Resource Group:** assignment at `/subscriptions/<subscriptionId>/resourceGroups/<resourceGroupName>`
- **Individual Resource:** assignment at the full Azure resource ID

## Implementation
- Subscription: subscription-targeted Bicep deployment.
- Resource Group: resource-group-targeted Bicep deployment.
- Individual Resource: Azure CLI role assignment at exact resource scope, because arbitrary resource types cannot be declared as a generic Bicep existing-resource symbol. The workflow performs a scope preview/check; Azure ARM What-If is not supported for this direct CLI role assignment.

## Excluded
PIM eligibility/activation, identity creation, automatic ticket approval.

Direct RBAC is immediately active. Review least privilege and remove access when no longer needed.
