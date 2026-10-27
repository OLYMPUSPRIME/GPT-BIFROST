# 🧹 Azure Resource Group Deletion Workflow

This branch contains a **manual cleanup workflow** for deleting Azure resource groups from a specifically configured Azure subscription.

> ⚠️ **Destructive operation:** Deleting a resource group can permanently remove the resources and data it contains, including virtual machines, disks, networks, databases, and storage. Run only when you own the target environment and have explicit authorization. The workflow has not been run as part of setting up this branch.

## 🎯 Scope

The current workflow targets **all resource groups in one Azure subscription** identified by `AZURE_SUBSCRIPTION_ID`.

It does **not** automatically enumerate every subscription available to your Azure account, nor does it delete subscription-level resources that are outside resource groups. If your account has multiple subscriptions, this workflow does not clean them all up.

## 📁 Files

- `.github/workflows/delete-azure-resource-groups.yml` — manually triggered GitHub Actions workflow.
- `scripts/delete-resource-groups.sh` — lists resource groups and optionally requests their deletion.

## 🔐 GitHub Actions configuration

In **Repository → Settings → Secrets and variables → Actions → Variables**, configure:

| Variable | Description |
|---|---|
| `AZURE_CLIENT_ID` | Microsoft Entra application (client) ID for the federated identity |
| `AZURE_TENANT_ID` | Microsoft Entra tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Exact Azure subscription ID to target |

With OpenID Connect (OIDC) federation, no `AZURE_CLIENT_SECRET` is needed.

### Configure the Azure federated credential

In the Microsoft Entra app registration, add a federated credential with:

- **Issuer:** `https://token.actions.githubusercontent.com`
- **Audience:** `api://AzureADTokenExchange`
- **Organization:** `OLYMPUSPRIME`
- **Repository:** `GPT-BIFROST`
- **Branch:** `Delete/Azure/RG`
- **Subject:** `repo:OLYMPUSPRIME/GPT-BIFROST:ref:refs/heads/Delete/Azure/RG`

The identity must have sufficient permissions to list and delete resource groups and their contained resources. Grant only the permissions required, and check locks, deny assignments, policies, dependencies, and recovery requirements.

## ▶️ How to run

1. Open **GitHub → Actions → Delete Azure Resource Groups**.
2. Select branch `Delete/Azure/RG` and click **Run workflow**.
3. **First run:** keep `dry_run = true`. This only lists the resource groups; it does not delete them.
4. Review the logs carefully. Verify the tenant, subscription ID, and every resource group in the inventory.
5. Only if deletion of every listed resource group is approved, start a new run with `dry_run = false` and enter this exact confirmation phrase:

   `DELETE-ALL-RESOURCE-GROUPS`

6. Monitor the workflow, review the Azure Activity Log, and verify the resulting state in the Azure portal.

The workflow includes a dry-run default, branch and subscription checks, and a confirmation phrase. These safeguards do not make deletion reversible.

## ✅ Pre-deletion checklist

- Confirm the correct Azure tenant and subscription.
- Confirm that **every resource group** in that subscription is intended for deletion.
- Back up or export any data that must be retained.
- Check for production/shared workloads, dependencies, resource locks, policies, and recovery requirements.
- Obtain any required change approval.
- After execution, review the workflow logs and Azure Activity Log.

> **Never run destructive mode against a production or shared subscription unless an approved change explicitly authorizes it.**

## 🧭 Branch purpose

This README describes only the Azure resource-group cleanup task in the `Delete/Azure/RG` branch. It does not redefine the primary purpose of the GPT-BIFROST repository or its other branches.
