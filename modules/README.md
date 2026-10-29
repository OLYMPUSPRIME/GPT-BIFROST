# BIFROST Bicep Modules

This directory contains the reusable Bicep templates and module-specific documentation. The deployment source paths have been preserved; each additional module guide is in a dedicated subdirectory so that multiple modules in folders such as `backup/`, `networking/`, and `monitoring/` can each have their own `README.md`.

## Compute
- [Virtual Machine](compute/vm/README.md) — Windows VM, NIC, existing subnet/optional ASG, and Key Vault password secret.

## Resource groups and orchestration
- [Resource Group](resourcegroup/README.md) — subscription-scope resource group creation.
- [Main Infrastructure Orchestrator](main/README.md) — composes resource-group, network, compute, storage, backup, security, and monitoring modules.

## Networking
- [Virtual Network](networking/vnet/README.md) — VNet and subnet creation.
- [Network Security Group](networking/nsg/README.md) — NSG and security rules.
- [Application Security Group](networking/asg/README.md) — ASG creation.
- [Route Table](networking/routetable/README.md) — user-defined routes and BGP propagation setting.
- [VNet Peering](networking/vnetPeering/README.md) — source-to-remote VNet peering.
- [VPN Virtual Network Gateway](networking/vnetgateway/README.md) — VPN gateway and public IP.

## Storage and security
- [Storage Account and Blob Container](storage/storageAccount/README.md) — StorageV2 account and private blob container.
- [Key Vault](security/keyvault/README.md) — Key Vault configured for Azure RBAC authorization.

## Backup
- [Recovery Services Vault](backup/recoveryVault/README.md) — vault creation.
- [Backup Policy](backup/backupPolicy/README.md) — daily VM backup schedule and retention.
- [VM Backup Protection](backup/backupProtection/README.md) — associate an existing VM with an existing vault policy.

## Monitoring
- [Action Group](monitoring/actionGroup/README.md) — email receivers for alert notifications.
- [Metric Alert](monitoring/metricAlert/README.md) — VM metric threshold alert and action group.

## Identity and access
- [PIM](pim/README.md) — eligible Azure RBAC access through Privileged Identity Management.
- [Direct RBAC](rbac/README.md) — standing subscription-scope Azure role assignment.

## Documentation notes
- Each guide is based on the corresponding Bicep source in this repository and lists its inputs, dependencies, permissions, outputs, workflow, and operational cautions.
- These guides do not replace Bicep build validation, Azure what-if, or a controlled test deployment.
- Keep secrets out of committed source and parameter files.
