# BIFROST RBAC request flow

    flowchart TD
      A[Other module creates target OR target already exists] --> B[input.json identifies exact scope and resource]
      B --> C[PowerShell validates JSON and required fields]
      C --> D{Scope level}
      D -->|Subscription| E[Validate selected subscription]
      D -->|Resource Group| F[Check existing resource group]
      D -->|Resource| G[Check existing resource by full ARM ID]
      E --> H[Create RBAC role assignment only]
      F --> H
      G --> H
      C -->|Invalid input| X[Reject request; no access change]
      F -->|Target missing| X
      G -->|Target missing| X
      H --> I[Access granted at exact requested scope]

## Key controls

- The RBAC module does not deploy target infrastructure.
- Target resources may be created by independent infrastructure modules or pre-exist.
- The feeder selects Subscription, ResourceGroup, or Resource scope.
- Resource scope requires a full ARM ID belonging to the selected subscription.
- Missing targets fail closed; no broader-scope fallback is attempted.
- Azure creates a role-assignment authorization record, not target infrastructure.
