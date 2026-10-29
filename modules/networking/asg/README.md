# Application Security Group Module

**Source template:** [`modules/networking/asg.bicep`](../asg.bicep)

## Purpose
Creates an Azure Application Security Group (ASG), which can be referenced by network interfaces and used in NSG rules to group workloads logically.

## Inputs
- `asgName` (required): ASG name.
- `location` (required): Azure region.

## Dependencies and permissions
The target resource group must exist. The deployment identity needs permission to create ASGs. This module creates the ASG only; it does not add NICs or NSG rules.

## Workflow
```mermaid
flowchart TD
 A[Choose ASG name and region] --> B[Create ASG]
 B --> C[Return ASG ID and name]
 C --> D[Reference ASG from NIC or NSG configuration]
```

## Outputs
- `asgId` — ASG resource ID.
- `asgName` — ASG name.
