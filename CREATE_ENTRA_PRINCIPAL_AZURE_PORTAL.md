# Find an Entra Principal for Azure RBAC

This guide locates the principal ID for the RBAC input. Creating identities is optional and must be authorized.

## User
Azure Portal → Microsoft Entra ID → Users → select user → Overview → copy Object ID.

## Group
Microsoft Entra ID → Groups → select group → copy Object ID.

## Service principal
Microsoft Entra ID → Enterprise applications → select app/service principal → copy **Object ID** (not Application/Client ID).

## Correct identifier
Use principal Object ID (GUID), not UPN, email, display name, or application Client ID.

Example:
```json
"principal": {
  "alias": "rbac_principal_1",
  "principalId": "PASTE_ENTRA_OBJECT_ID_GUID",
  "principalType": "User"
}
```

Update input.json, run validation/What-If first, review role/scope, obtain approval, then deploy. Verify in Azure Portal → Subscription → Access control (IAM).

**Direct RBAC grants access immediately.**
