# BIFROST RBAC request flow

```mermaid
flowchart TD
  A[input.json] --> B[PowerShell validation]
  B --> C{Scope level}
  C -->|Subscription| D[Subscription Bicep module]
  C -->|Resource Group| E[Resource Group Bicep module]
  C -->|Resource| F[Validate full ARM resource ID]
  D --> G[Azure role assignment]
  E --> G
  F --> H[Azure CLI assignment at exact resource scope]
  H --> G
  B -->|Invalid| X[Reject request]
```

Subscription scope uses `/subscriptions/<id>`. Resource group scope uses `/subscriptions/<id>/resourceGroups/<name>`. Resource scope uses the exact resource ARM ID. The runner never broadens scope.

RBAC grants active access immediately. It is distinct from PIM eligibility.
