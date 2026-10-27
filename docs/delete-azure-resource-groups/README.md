# 🧹 Azure Resource Group Cleanup

> ⚠️ DESTRUCTIVE: This workflow targets every resource group in one Azure subscription. Deletion can permanently remove resources and data and cause outages. Use only with explicit authorization.

## Files
- .github/workflows/delete-azure-resource-groups.yml — manual GitHub Actions workflow.
- scripts/delete-resource-groups.sh — inventory and guarded deletion script.

## GitHub Actions variables
In Settings → Secrets and variables → Actions → Variables, add:

| Variable | Value |
|---|---|
| AZURE_CLIENT_ID | Microsoft Entra app registration / service principal application (client) ID |
| AZURE_TENANT_ID | Microsoft Entra tenant ID |
| AZURE_SUBSCRIPTION_ID | Exact subscription ID to target |

### Secrets
With OIDC federation, no client secret is needed. Do not add AZURE_CLIENT_SECRET for this workflow.

## Configure Azure OIDC
In the Microsoft Entra app registration, add a federated credential:
- Issuer: https://token.actions.githubusercontent.com
- Audience: api://AzureADTokenExchange
- Organization: OLYMPUSPRIME
- Repository: GPT-BIFROST
- Entity type: Branch
- Branch: Delete/Azure/RG
- Expected subject: repo:OLYMPUSPRIME/GPT-BIFROST:ref:refs/heads/Delete/Azure/RG

Grant the identity only the permissions required at the intended subscription scope. Resource group deletion requires relevant resourceGroups/delete permission and permissions to inspect groups. Check locks, deny assignments, policies, dependencies, and recovery requirements before proceeding. Avoid Owner unless genuinely required.

## Safety controls
- Manual workflow_dispatch only; no push or pull-request trigger.
- Dry run defaults to true.
- Actual deletion requires dry_run=false and the exact phrase DELETE-ALL-RESOURCE-GROUPS.
- The workflow checks the authenticated subscription against the configured subscription ID.
- Resource groups are processed sequentially.

## Run
1. Open Actions → Delete Azure Resource Groups and choose Run workflow on branch Delete/Azure/RG.
2. First run with Dry run = true. Inspect the logs and verify the subscription and every group listed.
3. Only if all groups must be removed, run with Dry run = false and enter exactly DELETE-ALL-RESOURCE-GROUPS.
4. Monitor the run and verify the subscription afterward.

The script does not identify or preserve production, shared, or special-purpose groups automatically. Do not run against a production/shared subscription unless an approved plan explicitly calls for deleting all its resource groups.

## Local use (optional)
Requirements: Azure CLI, jq, and an authenticated Azure CLI session.

~~~bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
DRY_RUN=true EXPECTED_SUBSCRIPTION_ID="<SUBSCRIPTION_ID>" ./scripts/delete-resource-groups.sh
~~~

For destructive mode only after reviewing the inventory:

~~~bash
DRY_RUN=false EXPECTED_SUBSCRIPTION_ID="<SUBSCRIPTION_ID>" CONFIRM_DELETE=DELETE-ALL-RESOURCE-GROUPS ./scripts/delete-resource-groups.sh
~~~
