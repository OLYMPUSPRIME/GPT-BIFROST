# BIFROST PIM Mark-2 — standalone Bicep configuration

Jira integration is out of scope. Requester/access inputs and admin policy settings are maintained manually in the Bicep parameter file.

## Files

- modules/pim/pim.bicep — Azure Resource PIM eligibility schedule request at subscription scope.
- modules/pim/pim-request.bicepparam — request values and policy configuration derived from the screenshots.

## Deployment

1. Replace placeholders in pim-request.bicepparam (principal ID, subscription ID, role ID, request reference, approver object IDs).
2. Login and set the correct subscription:
   ```powershell
   az login
   az account set --subscription <SUBSCRIPTION_ID>
   ```
3. Compile:
   ```powershell
   az bicep build --file modules/pim/pim.bicep
   ```
4. Validate:
   ```powershell
   az deployment sub validate --location eastus --template-file modules/pim/pim.bicep --parameters modules/pim/pim-request.bicepparam
   ```
5. Deploy only after review:
   ```powershell
   az deployment sub create --location eastus --template-file modules/pim/pim.bicep --parameters modules/pim/pim-request.bicepparam
   ```

This creates eligible access, not instant activation.

## Policy settings from supplied screenshots

| Area | Role | Configuration intent |
|---|---|---|
| Azure Resource PIM | Owner | MFA, Conditional Access, approval by another subscription owner, notifications, 1h |
| Azure Resource PIM | User Access Administrator | MFA, CA, no approval, notifications, 1h |
| Entra role PIM | Global Administrator | MFA, CA, approval by another Global Administrator, notifications, 1h |
| Entra role PIM | Exchange Administrator | MFA, CA, no approval, notifications, 2h |
| PIM for Groups | Owner | MFA, CA, approval by another group owner, notifications, 1h |
| PIM for Groups | Member | MFA, CA, no approval, notifications, 5h |

Assignment defaults: eligible preferred, maximum eligibility P90D, justification and ticket reference required, permanent eligible/active assignments disabled.

## Important capability boundary

The parameter file contains the settings, but the current Bicep resource only creates Azure Resource PIM eligibility. It does **not** apply the activation-policy values.

Policy changes require platform-specific API implementation:
- Azure Resource PIM: Azure Authorization role management policy API.
- Entra directory roles: Microsoft Graph role management policy API.
- PIM for Groups: Microsoft Graph group role management policy API.

The current branch does not yet automate policy writes or verification. Entra role PIM, PIM for Groups, Azure RG/resource assignment, and active assignment/activation are not yet implemented here. Do not assume settings were enforced just because the eligibility deployment succeeded.

Test in a non-production tenant/subscription first.
