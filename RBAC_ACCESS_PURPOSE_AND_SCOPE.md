# RBAC Access Purpose and Scope

## Purpose
Provide auditable direct Azure role assignment through Bicep and GitHub Actions.

## Scope
- Subscription: BIFROST-SC
- Current target scope: subscription
- Principals: User, Group, ServicePrincipal
- Assignment: direct Azure RBAC
- Authentication: GitHub OIDC
- Workflow: manual dispatch

## Excluded
PIM eligibility, PIM activation, user provisioning, automatic ticket approval, and resource-group/resource scope in this initial version.

## Lifecycle
Request → approval → input.json update → validate/What-If → authorized deployment → verify assignment → remove when no longer required.

**RBAC is immediately active; PIM is not part of this branch.**
