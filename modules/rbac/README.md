# RBAC Bicep Module

Creates a direct subscription-scoped Azure role assignment using `Microsoft.Authorization/roleAssignments@2022-04-01`.

Parameters: principal Object ID, principal type, role GUID, subscription ID, deterministic assignment GUID, and description.

This grants active access immediately; it is **not PIM**. The deployment identity must have roleAssignments/write permission. Contributor alone is not sufficient.

| Role | GUID |
|---|---|
| Reader | `acdd72a7-3385-48ef-bd42-f606fba81ae7` |
| Contributor | `b24988ac-6180-42a0-ab88-20f7382dd24c` |
| Owner | `8e3af657-a8ff-443c-a75c-2fe8c4bcb635` |
