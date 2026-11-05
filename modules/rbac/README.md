# Reusable Azure RBAC module

Supported scopes: Subscription, ResourceGroup, and individual Resource.

| Scope | Implementation |
|---|---|
| Subscription | `subscription/rbac-subscription.bicep` |
| Resource group | `resourceGroup/rbac-resource-group.bicep` |
| Individual resource | `resource/rbac-resource.bicep` input contract plus Azure CLI exact-scope assignment from runner |

Inputs include principal object ID/type, role definition GUID, scope level, RG name or full resource ARM ID, ticket metadata, and justification. The runner checks required scope fields and tenant consistency. It never silently assigns at a broader scope.

RBAC creates active access. PIM eligibility/activation is separate.
