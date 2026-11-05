# BIFROST PIM Mark-2 — standalone CLI testing

No Jira integration is included. Edit the .bicepparam file manually.

## 1. Prerequisites

- Azure CLI and Bicep installed.
- PIM for Azure resources configured in a test subscription.
- Permission to create role eligibility schedule requests.
- Correct principal Object ID, role definition resource ID and subscription.

## 2. Login

```powershell
az login
az account list --output table
az account set --subscription <SUBSCRIPTION_ID>
az account show
az bicep install
```

## 3. Compile

```powershell
az bicep build --file modules/pim/pim.bicep
```

## 4. Validate deployment

```powershell
az deployment sub validate --location eastus --template-file modules/pim/pim.bicep --parameters modules/pim/pim-request.bicepparam
```

## 5. Deploy eligible access

```powershell
az deployment sub create --location eastus --template-file modules/pim/pim.bicep --parameters modules/pim/pim-request.bicepparam
```

This creates Azure Resource PIM eligibility, not immediate active access.

## Policy implementation status

The parameter file stores the screenshot-derived policy values. The Bicep template currently does not apply them. Azure Resource role policies require Authorization API calls; Entra directory-role and PIM Group policies require Microsoft Graph calls. Policy writes and verification are not yet implemented in this branch.
