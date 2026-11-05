# Azure Built-in RBAC Role IDs

This reference lists the Azure built-in role definition IDs used in BIFROST PIM examples. These IDs identify Azure RBAC roles; they are not tenant, subscription, or principal IDs.

## Built-in roles

| Role | Role definition GUID | Notes |
|---|---|---|
| Owner | `8e3af657-a8ff-443c-a75c-2fe8c4bcb635` | Full management access, including the ability to assign roles. Highly privileged. |
| Contributor | `b24988ac-6180-42a0-ab88-20f7382dd24c` | Can manage resources, but cannot assign Azure RBAC roles. |
| User Access Administrator | `18d7d88d-d35e-4fb5-a5c3-7773c20a72d9` | Can manage user access to Azure resources. Highly privileged. |

## Azure role definition resource ID

At subscription scope, the role definition resource ID is:

```text
/subscriptions/<SUBSCRIPTION_ID>/providers/Microsoft.Authorization/roleDefinitions/<ROLE_GUID>
```

Example (Contributor):

```text
/subscriptions/<SUBSCRIPTION_ID>/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c
```

## Retrieve a role GUID using Azure CLI

Sign in and select the target subscription first:

```powershell
az login
az account set --subscription "<SUBSCRIPTION_ID>"
```

Look up a role by its name:

```powershell
az role definition list --name "Contributor" --query "[0].name" --output tsv
```

Assign the result to a PowerShell variable:

```powershell
$RoleGuid = az role definition list `
    --name "Contributor" `
    --query "[0].name" `
    --output tsv

$RoleGuid
```

To look up other roles, replace `Contributor` with `Owner` or `User Access Administrator`.

## Verify role details

```powershell
az role definition list --name "Owner" --query "[0].{Name:roleName,Id:name,Description:description}" --output table
```

## BIFROST notes

- The role GUID is used to construct the `roleDefinitionId` for a PIM eligibility schedule request.
- A role's availability in BIFROST also depends on the local policy validation configuration. A role ID being listed here does not mean the policy allows requesting it.
- Azure enforces authorization and PIM configuration independently of local PowerShell policy checks.
- Use highly privileged roles such as Owner and User Access Administrator only when approved and in an appropriate test or production context.
- For current role definitions, query Azure CLI rather than relying exclusively on this static reference.

