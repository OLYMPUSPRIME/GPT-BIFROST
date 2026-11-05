# Create a Microsoft Entra User in Azure Portal

This guide explains how to create a user identity for a BIFROST PIM access request. Creating a user does **not** grant Azure access by itself. Azure PIM eligibility is a separate step.

## Before you begin

- Sign in to the [Azure Portal](https://portal.azure.com/).
- Ensure you have permission to create users in the Microsoft Entra tenant.
- Confirm whether the identity should be an internal member or external guest. Follow your organization's identity lifecycle standards.

## Create the user

1. Open **Microsoft Entra ID** in Azure Portal.
2. Go to **Users** → **New user** → **Create new user**.
3. Enter the user's **User principal name (UPN)** and display name.
4. Complete required profile fields and password/sign-in options according to your organization's process.
5. Select **Review + create** (or **Create**, depending on portal UI).
6. After creation, open the user's profile.

## Collect the user's identifiers

On the user's **Overview** page, record:

| Portal field | Used for |
|---|---|
| Display name | Human-readable identity in root input.json |
| User principal name (UPN) | Login identity and requestor reference |
| Object ID | principalId / entraObjectId in PIM configuration |

**Important:** Azure PIM requires the Microsoft Entra **Object ID (GUID)** for principalId. Do not substitute display name, email, UPN, or alias.

## Update BIFROST request configuration

- In root input.json, populate the requestor fields under pimAccessRequest.requestor.
- In modules/pim/pim-request.bicepparam, set principalId to the user's Entra Object ID.
- Confirm target subscription, role, scope, duration, and justification with the access owner before deployment.

## Verify the user

Azure CLI alternative:

```bash
az ad user show --id "user@yourdomain.com" --query id --output tsv
```

This requires Azure CLI authentication to the correct tenant and sufficient directory read permissions.

## Security reminders

- Follow your organization's approval process for identity creation.
- Do not share temporary passwords or credentials in GitHub, JSON files, or chat.
- Do not grant privileged roles directly just to create the account.
- Use least privilege and verify the tenant before making access changes.
